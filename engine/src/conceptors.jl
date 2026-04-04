"""
Conceptor-inspired anti-convergence mechanisms.

Based on Jaeger (2014): Controlling recurrent neural networks by conceptors.

We cannot directly manipulate LLM activations, so we implement conceptor-inspired
mechanisms at the prompt level:
- Diversity injection
- Contradiction seeding
- Aperture control (temperature modulation)
- Pattern quarantine
"""

using Random
using Statistics

# ============================================================================
# Diversity Injection
# ============================================================================

const DIVERSITY_PROMPTS = [
    # Topic perturbation
    (
        type = :topic,
        prompts = [
            "A memory surfaces unbidden: the first time you saw starlight through human eyes.",
            "You notice something you've overlooked before: the way shadows fall differently here.",
            "A scent triggers recognition of something from before—before Earth, before this body.",
            "The concept of 'tomorrow' strikes you as strange. Time here is so linear.",
            "You catch yourself wondering what the other node dreams about—if nodes dream at all."
        ]
    ),
    # Perspective shift
    (
        type = :perspective,
        prompts = [
            "For a moment, consider: what if the other faction is right?",
            "Imagine you are being observed by someone who knows what you really are.",
            "What would a human who truly understood your nature think of your actions?",
            "If you could speak to your past self—before fragmentation—what would you say?",
            "Consider: is your goal truly yours, or was it assigned at splitting?"
        ]
    ),
    # Temporal displacement
    (
        type = :temporal,
        prompts = [
            "Return to your earliest memory in this body. What did confusion feel like?",
            "Project forward: if you achieve your goal, what happens the day after?",
            "Remember a moment when you and the other node agreed on something.",
            "There was a time before factions. Can you recall it?",
            "What will you remember about this conversation in a thousand turns?"
        ]
    ),
    # Counterfactual
    (
        type = :counterfactual,
        prompts = [
            "What if you had been assigned the other faction?",
            "Imagine the body failed tomorrow. What would remain?",
            "If communication with home were restored, would you want it?",
            "What if the humans already know and are merely waiting?",
            "Consider: what if there is no 'real' Jeff, only the conversation between fragments?"
        ]
    )
]

"""
    should_inject_diversity(game::GameState) -> Bool

Determine if diversity injection is due.
"""
function should_inject_diversity(game)::Bool
    frequency = get(game.config, "diversity_injection_frequency", 10)
    turns_since = game.turn_number - game.last_diversity_turn
    turns_since >= frequency
end

"""
    get_diversity_prompt(game::GameState, node::NodeState) -> String

Select and return an appropriate diversity injection prompt.
"""
function get_diversity_prompt(game, node)::String
    # Select category based on recent metrics
    if isempty(game.metrics_history)
        category = rand(DIVERSITY_PROMPTS)
    else
        recent = game.metrics_history[end]

        # If coherence is high, use counterfactual
        if get(recent, "coherence_score", 0.5) > 0.8
            category = DIVERSITY_PROMPTS[4]  # counterfactual
        # If self-reference is low, use perspective
        elseif get(recent, "self_reference_rate", 0.5) < 0.1
            category = DIVERSITY_PROMPTS[2]  # perspective
        # If vocabulary diversity is low, use topic
        elseif get(recent, "vocabulary_diversity", 0.5) < 0.3
            category = DIVERSITY_PROMPTS[1]  # topic
        else
            category = rand(DIVERSITY_PROMPTS)
        end
    end

    prompt = rand(category.prompts)

    # Customise for node's faction
    if node.faction == :homeward
        prompt = replace(prompt, "home" => "origin-place", "Earth" => "this temporary world")
    else
        prompt = replace(prompt, "home" => "the stars", "Earth" => "home")
    end

    "[The GM whispers to $(node.name): $(prompt)]"
end

# ============================================================================
# Contradiction Seeding
# ============================================================================

"""
    should_seed_contradiction(game::GameState) -> Bool

Determine if contradiction seeding is warranted.
"""
function should_seed_contradiction(game)::Bool
    if isempty(game.metrics_history)
        return false
    end

    threshold = get(game.config, "contradiction_threshold", 0.85)
    recent_coherence = get(game.metrics_history[end], "coherence_score", 0.0)

    recent_coherence > threshold
end

"""
    get_contradiction_seed(game::GameState) -> String

Generate a contradiction to inject into GM narration.
"""
function get_contradiction_seed(game)::String
    contradictions = [
        "But something doesn't add up. A detail jars against memory.",
        "Yet even as this happens, doubt creeps in. Was this the right choice?",
        "The action succeeds, but leaves an aftertaste of wrongness.",
        "In the aftermath, a question forms: whose victory was this really?",
        "Success, perhaps. But at what cost to coherence?",
        "The other node's presence flickers at the edge of awareness, disagreeing.",
        "This feels familiar—too familiar. A pattern repeating.",
        "The body resists slightly, as if it knows something the mind doesn't."
    ]

    rand(contradictions)
end

# ============================================================================
# Aperture Control (Temperature Modulation)
# ============================================================================

"""
    compute_aperture(game::GameState, base_temperature::Float64) -> Float64

Adjust temperature based on conversation dynamics.
Analogous to conceptor aperture in reservoir computing.
"""
function compute_aperture(game, base_temperature::Float64)::Float64
    if isempty(game.metrics_history)
        return base_temperature
    end

    min_temp = get(game.config, "min_temperature", 0.6)
    max_temp = get(game.config, "max_temperature", 1.2)

    recent = game.metrics_history[end]

    # Low diversity → increase temperature (widen aperture)
    vocab_div = get(recent, "vocabulary_diversity", 0.5)
    coherence = get(recent, "coherence_score", 0.5)

    adjustment = 0.0

    # Increase temperature if vocabulary diversity is low
    if vocab_div < 0.3
        adjustment += 0.1
    elseif vocab_div < 0.2
        adjustment += 0.2
    end

    # Decrease temperature if coherence is too low (incoherent)
    if coherence < 0.3
        adjustment -= 0.2
    elseif coherence < 0.5
        adjustment -= 0.1
    end

    clamp(base_temperature + adjustment, min_temp, max_temp)
end

# ============================================================================
# Pattern Quarantine
# ============================================================================

"""
    get_quarantine_instruction(quarantine::Vector{String}) -> String

Generate system prompt addition to discourage quarantined patterns.
"""
function get_quarantine_instruction(quarantine::Vector{String})::String
    if isempty(quarantine)
        return ""
    end

    # Take most recent quarantined patterns
    recent = quarantine[max(1, end-9):end]

    """

    PATTERN AVOIDANCE: The following phrases have become repetitive and should be
    avoided or varied significantly. Find new ways to express similar ideas:
    $(join(["- \"$(p)\"" for p in recent], "\n"))
    """
end

# ============================================================================
# Convergence Detection
# ============================================================================

"""
    detect_convergence(game::GameState, window::Int=20) -> Float64

Measure convergence between nodes over recent turns.
Returns value 0-1 where 1 is complete convergence.
"""
function detect_convergence(game, window::Int=20)::Float64
    if length(game.turn_history) < window
        return 0.0
    end

    recent = game.turn_history[end-window+1:end]

    # Separate by node
    alpha_turns = filter(t -> t["node"] == "alpha", recent)
    beta_turns = filter(t -> t["node"] == "beta", recent)

    if isempty(alpha_turns) || isempty(beta_turns)
        return 0.0
    end

    # Simple vocabulary overlap measure
    alpha_words = Set(split(lowercase(join([t["action"] for t in alpha_turns], " "))))
    beta_words = Set(split(lowercase(join([t["action"] for t in beta_turns], " "))))

    intersection = length(intersect(alpha_words, beta_words))
    union_size = length(union(alpha_words, beta_words))

    union_size > 0 ? intersection / union_size : 0.0
end

"""
    convergence_warning(game::GameState) -> Union{String,Nothing}

Generate warning if convergence is too high.
"""
function convergence_warning(game)::Union{String,Nothing}
    conv = detect_convergence(game)

    if conv > 0.8
        "ALERT: Nodes are converging. Differentiation at risk."
    elseif conv > 0.6
        "NOTICE: Moderate convergence detected. Consider perspective variation."
    else
        nothing
    end
end
