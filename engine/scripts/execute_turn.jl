#!/usr/bin/env julia
#
# execute_turn.jl - Run a single conversation turn
#
# Usage: julia --project=. scripts/execute_turn.jl [--force-node=alpha|beta] [--force-diversity]
#

# First, ensure the local package is available
using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))
Pkg.instantiate()

# Now include the module directly (more reliable than registry lookup)
include(joinpath(@__DIR__, "..", "src", "JeffEngine.jl"))
using .JeffEngine

using Dates
using Printf

function main()
    # Parse command line / environment
    force_node = get(ENV, "FORCE_NODE", "auto")
    force_diversity = get(ENV, "FORCE_DIVERSITY", "false") == "true"

    # Paths
    base_dir = dirname(dirname(@__DIR__))
    config_path = joinpath(base_dir, "orchestrator", "data", "game_state.yml")

    # Load or initialise game state
    game = if isfile(config_path)
        println("Loading existing game state from $config_path")
        load_game_state(config_path, Dict())
    else
        println("Initialising new game state")
        # Create directory if needed
        mkpath(dirname(config_path))
        # Create a minimal initial config
        initial_config = Dict("version" => "1.0")
        initialise_game_state(config_path)
    end

    # Load node states
    alpha_path = joinpath(base_dir, "node-alpha", "data", "node_state.yml")
    beta_path = joinpath(base_dir, "node-beta", "data", "node_state.yml")

    if !isfile(alpha_path) || !isfile(beta_path)
        error("Node state files not found. Expected:\n  $alpha_path\n  $beta_path")
    end

    alpha = initialise_node_state(alpha_path)
    beta = initialise_node_state(beta_path)
    nodes = Dict(:alpha => alpha, :beta => beta)

    # Force node if specified
    if force_node != "auto"
        game.current_node = Symbol(force_node)
        println("Forcing node: $force_node")
    end

    # Force diversity if specified
    if force_diversity
        game.last_diversity_turn = 0
        println("Forcing diversity injection")
    end

    # Execute turn
    println("\n" * "="^60)
    println("Executing turn $(game.turn_number + 1)...")
    println("Current node: $(game.current_node)")
    println("="^60 * "\n")

    result = execute_turn(game, nodes)

    # Save state
    save_game_state(game, config_path)
    println("Game state saved to $config_path")

    # Save turn as markdown
    turn_filename = @sprintf("%04d-%s.md", result.turn_number, lowercase(result.node_name))

    # Save to orchestrator
    orch_path = joinpath(base_dir, "orchestrator", "content", "turns", turn_filename)
    mkpath(dirname(orch_path))
    save_turn_to_markdown(result, orch_path)
    println("Turn saved to $orch_path")

    # Save to node
    node_dir = result.node_name == "Alpha" ? "node-alpha" : "node-beta"
    node_path = joinpath(base_dir, node_dir, "content", "turns", turn_filename)
    mkpath(dirname(node_path))
    save_turn_to_markdown(result, node_path)
    println("Turn saved to $node_path")

    # Output for GitHub Actions (using newer GITHUB_OUTPUT format)
    github_output = get(ENV, "GITHUB_OUTPUT", nothing)
    if github_output !== nothing
        open(github_output, "a") do f
            println(f, "turn_number=$(result.turn_number)")
            println(f, "node=$(result.node_name)")
            println(f, "chaos=$(game.chaos)")
            println(f, "exposure=$(game.exposure)")
            println(f, "faction=$(game.faction_slider)")
        end
    end

    # Print summary
    println("\n" * "="^60)
    println("TURN COMPLETE")
    println("="^60)
    println("Turn:     $(result.turn_number)")
    println("Node:     $(result.node_name)")
    println("Chaos:    $(game.chaos)/100")
    println("Exposure: $(game.exposure)/100")
    println("Faction:  $(game.faction_slider)")
    println("="^60)

    # Print metrics if available
    if isdefined(JeffEngine, :metrics_summary)
        println("\n$(metrics_summary(game))")
    end

    # Check for threshold events
    if isdefined(JeffEngine, :check_thresholds)
        events = check_thresholds(game.chaos, game.exposure, game.faction_slider)
        if !isempty(events)
            println("\n⚠️  THRESHOLD EVENTS: $(events)")
        end
    end
end

# Run if executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
