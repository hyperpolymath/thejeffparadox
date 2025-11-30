"""
JeffEngine: Core game mechanics for The Jeff Paradox experiment.

This module provides:
- Game state management (chaos, exposure, faction)
- Dice mechanics and skill resolution
- LLM API abstraction
- Conceptor-inspired anti-convergence mechanisms
- Metrics collection for emergence tracking
"""
module JeffEngine

using HTTP
using JSON3
using YAML
using Random
using Dates
using Statistics
using LinearAlgebra
using SHA

# Sub-modules - ORDER MATTERS: llm_client before metrics (metrics uses get_embedding)
include("mechanics.jl")
include("conceptors.jl")
include("llm_client.jl")
include("metrics.jl")

# Core types
export GameState, NodeState, TurnResult

# Mechanics (from mechanics.jl)
export roll_dice, apply_skill, update_chaos, update_exposure, shift_faction
export check_thresholds

# Anti-convergence (from conceptors.jl)
export should_inject_diversity, get_diversity_prompt, should_seed_contradiction
export get_contradiction_seed, get_quarantine_instruction

# Metrics (from metrics.jl)
export compute_metrics, MetricsSnapshot, metrics_summary

# LLM (from llm_client.jl)
export generate_response, build_context, build_gm_context
export get_embedding, cosine_similarity, semantic_distance

# State management (from this file)
export initialise_game_state, initialise_node_state
export load_game_state, save_game_state, save_turn_to_markdown
export execute_turn

# ============================================================================
# Core State Types
# ============================================================================

"""
    NodeState

Represents one personality fragment of The Jeff.
"""
mutable struct NodeState
    name::String
    faction::Symbol  # :homeward or :earthbound
    secret_goal::String
    skills::Vector{Dict{String,Any}}
    personality_traits::Vector{String}
    speech_patterns::Vector{String}
    llm_provider::String
    llm_model::String
    temperature::Float64
    revealed_to_other::Set{String}  # What this node has revealed about itself
end

"""
    GameState

Global state of The Jeff Paradox experiment.
"""
mutable struct GameState
    # Core mechanics
    chaos::Int
    exposure::Int
    faction_slider::Int  # -100 (Homeward) to +100 (Earthbound)

    # Turn tracking
    turn_number::Int
    current_node::Symbol  # :alpha or :beta

    # History (for context building)
    turn_history::Vector{Dict{String,Any}}

    # Anti-convergence state
    pattern_quarantine::Vector{String}
    diversity_injection_counter::Int
    last_diversity_turn::Int

    # Metrics accumulator
    metrics_history::Vector{Dict{String,Any}}

    # Configuration
    config::Dict{String,Any}
end

"""
    TurnResult

Output of a single turn in the conversation.
"""
struct TurnResult
    turn_number::Int
    node_name::String
    action::String
    gm_narration::String
    chaos_delta::Int
    exposure_delta::Int
    faction_delta::Int
    metrics::Dict{String,Any}
    timestamp::DateTime
end

# ============================================================================
# State Initialisation
# ============================================================================

"""
    initialise_game_state(config_path::String) -> GameState

Create initial game state. If config_path exists, load it; otherwise use defaults.
"""
function initialise_game_state(config_path::String)::GameState
    config = if isfile(config_path)
        YAML.load_file(config_path)
    else
        # Default config when no file exists
        Dict{String,Any}(
            "version" => "1.0",
            "diversity_injection_frequency" => 10,
            "contradiction_threshold" => 0.85,
            "min_temperature" => 0.6,
            "max_temperature" => 1.2
        )
    end

    GameState(
        15,    # Starting chaos
        5,     # Starting exposure
        0,     # Neutral faction
        0,     # Turn 0
        :alpha,  # Alpha starts
        Dict{String,Any}[],
        String[],
        0,
        0,
        Dict{String,Any}[],
        config
    )
end

"""
    initialise_node_state(node_path::String) -> NodeState

Load node configuration from YAML.
"""
function initialise_node_state(node_path::String)::NodeState
    data = YAML.load_file(node_path)
    node = data["node"]
    skills = data["skills"]
    personality = data["personality"]
    llm = data["llm"]

    NodeState(
        node["name"],
        Symbol(lowercase(node["faction"])),
        node["secret_goal"],
        skills,
        personality["traits"],
        personality["speech_patterns"],
        llm["provider"],
        llm["model"],
        llm["temperature"],
        Set{String}()
    )
end

# ============================================================================
# Turn Execution
# ============================================================================

"""
    execute_turn(game::GameState, nodes::Dict{Symbol,NodeState}) -> TurnResult

Execute a single turn of the conversation.
"""
function execute_turn(game::GameState, nodes::Dict{Symbol,NodeState})::TurnResult
    current = nodes[game.current_node]
    other_symbol = game.current_node == :alpha ? :beta : :alpha
    other = nodes[other_symbol]

    # Build context for current node
    context = build_context(game, current, other)

    # Check for diversity injection
    diversity_prompt = ""
    if should_inject_diversity(game)
        diversity_prompt = get_diversity_prompt(game, current)
        game.last_diversity_turn = game.turn_number
    end

    # Generate node's action
    node_response = generate_response(
        current,
        context,
        diversity_prompt,
        :node
    )

    # Generate GM narration
    gm_context = build_gm_context(game, current, node_response)
    gm_narration = generate_response(
        nothing,  # GM uses default model
        gm_context,
        "",
        :gm
    )

    # Parse and apply mechanical effects
    chaos_delta, exposure_delta, faction_delta = parse_mechanical_effects(
        node_response,
        gm_narration,
        current,
        game
    )

    # Update game state
    game.chaos = clamp(game.chaos + chaos_delta, 0, 100)
    game.exposure = clamp(game.exposure + exposure_delta, 0, 100)
    game.faction_slider = clamp(game.faction_slider + faction_delta, -100, 100)
    game.turn_number += 1

    # Update quarantine if needed
    update_pattern_quarantine!(game, node_response)

    # Record turn
    turn_record = Dict{String,Any}(
        "turn" => game.turn_number,
        "node" => String(game.current_node),
        "action" => node_response,
        "narration" => gm_narration,
        "chaos" => game.chaos,
        "exposure" => game.exposure,
        "faction" => game.faction_slider,
        "timestamp" => now()
    )
    push!(game.turn_history, turn_record)

    # Compute metrics
    metrics = compute_metrics(game)
    push!(game.metrics_history, metrics)

    # Switch to other node
    game.current_node = other_symbol

    TurnResult(
        game.turn_number,
        current.name,
        node_response,
        gm_narration,
        chaos_delta,
        exposure_delta,
        faction_delta,
        metrics,
        now()
    )
end

"""
    parse_mechanical_effects(action, narration, node, game) -> (Int, Int, Int)

Determine chaos/exposure/faction changes from action and narration.
"""
function parse_mechanical_effects(
    action::String,
    narration::String,
    node::NodeState,
    game::GameState
)::Tuple{Int,Int,Int}

    chaos_delta = 0
    exposure_delta = 0
    faction_delta = 0

    # Check for skill use in action
    for skill in node.skills
        skill_name = lowercase(skill["name"])
        if occursin(lowercase(skill_name), lowercase(action))
            # Skill was used - roll for chaos
            chaos_delta += sum(roll_dice(2, 6))
        end
    end

    # Check for public display of alien behaviour
    alien_keywords = ["telekinesis", "shift", "transform", "memory", "probability", "temporal", "future", "past"]
    for kw in alien_keywords
        if occursin(kw, lowercase(narration)) && occursin("witness", lowercase(narration))
            exposure_delta += sum(roll_dice(1, 10))
            break
        end
    end

    # Check faction alignment of action
    homeward_keywords = ["home", "return", "signal", "stars", "origin", "escape"]
    earthbound_keywords = ["stay", "integrate", "human", "belong", "earth", "adapt"]

    homeward_count = sum(occursin(kw, lowercase(action)) for kw in homeward_keywords)
    earthbound_count = sum(occursin(kw, lowercase(action)) for kw in earthbound_keywords)

    if node.faction == :homeward
        faction_delta -= homeward_count * 2
    else
        faction_delta += earthbound_count * 2
    end

    (chaos_delta, exposure_delta, faction_delta)
end

"""
    update_pattern_quarantine!(game, response)

Track repeated patterns and add to quarantine if threshold exceeded.
"""
function update_pattern_quarantine!(game::GameState, response::String)
    # Simple n-gram tracking (3-5 grams)
    words = split(lowercase(response))

    for n in 3:5
        for i in 1:(length(words) - n + 1)
            ngram = join(words[i:i+n-1], " ")

            # Count occurrences in recent history
            count = 0
            for turn in game.turn_history[max(1, end-19):end]
                if occursin(ngram, lowercase(turn["action"]))
                    count += 1
                end
            end

            if count >= 5 && !(ngram in game.pattern_quarantine)
                push!(game.pattern_quarantine, ngram)
            end
        end
    end
end

# ============================================================================
# Persistence
# ============================================================================

"""
    save_game_state(game::GameState, path::String)

Persist game state to YAML.
"""
function save_game_state(game::GameState, path::String)
    state_dict = Dict(
        "chaos" => game.chaos,
        "exposure" => game.exposure,
        "faction_slider" => game.faction_slider,
        "turn_number" => game.turn_number,
        "current_node" => String(game.current_node),
        "pattern_quarantine" => game.pattern_quarantine,
        "diversity_injection_counter" => game.diversity_injection_counter,
        "last_diversity_turn" => game.last_diversity_turn
    )

    YAML.write_file(path, state_dict)
end

"""
    load_game_state(path::String, config::Dict) -> GameState

Load game state from YAML.
"""
function load_game_state(path::String, config::Dict)::GameState
    data = YAML.load_file(path)

    GameState(
        data["chaos"],
        data["exposure"],
        data["faction_slider"],
        data["turn_number"],
        Symbol(data["current_node"]),
        Dict{String,Any}[],  # History loaded separately
        data["pattern_quarantine"],
        data["diversity_injection_counter"],
        data["last_diversity_turn"],
        Dict{String,Any}[],  # Metrics loaded separately
        config
    )
end

"""
    save_turn_to_markdown(result::TurnResult, path::String)

Write turn result as Jekyll/Hugo compatible markdown.
"""
function save_turn_to_markdown(result::TurnResult, path::String)
    frontmatter = """
---
title: "Turn $(result.turn_number): $(result.node_name)"
date: $(Dates.format(result.timestamp, "yyyy-mm-ddTHH:MM:SS"))
node: $(lowercase(result.node_name))
turn: $(result.turn_number)
chaos: $(result.chaos_delta)
exposure: $(result.exposure_delta)
faction: $(result.faction_delta)
---

"""

    content = """
## Action

$(result.action)

## Narration

$(result.gm_narration)
"""

    open(path, "w") do f
        write(f, frontmatter * content)
    end
end

end # module
