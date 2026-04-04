"""
LLM API abstraction layer.

Supports multiple providers:
- Anthropic (Claude)
- Mistral
- Local (LM Studio, Ollama, etc.)

All communication via HTTPS. API keys from environment variables only.
"""

using HTTP
using JSON3

# ============================================================================
# Provider Configuration
# ============================================================================

const PROVIDERS = Dict(
    "anthropic" => (
        base_url = "https://api.anthropic.com/v1",
        key_env = "ANTHROPIC_API_KEY",
        chat_endpoint = "/messages",
        model_prefix = "claude-"
    ),
    "mistral" => (
        base_url = "https://api.mistral.ai/v1",
        key_env = "MISTRAL_API_KEY",
        chat_endpoint = "/chat/completions",
        model_prefix = "mistral-"
    ),
    "local" => (
        base_url = "http://localhost:1234/v1",  # LM Studio default
        key_env = "LOCAL_API_KEY",
        chat_endpoint = "/chat/completions",
        model_prefix = ""
    )
)

# ============================================================================
# Request Building
# ============================================================================

"""
    build_headers(provider::String) -> Vector{Pair{String,String}}

Build HTTP headers for API request.
"""
function build_headers(provider::String)::Vector{Pair{String,String}}
    config = PROVIDERS[provider]
    api_key = get(ENV, config.key_env, "")

    if provider == "anthropic"
        [
            "Content-Type" => "application/json",
            "x-api-key" => api_key,
            "anthropic-version" => "2023-06-01"
        ]
    else
        [
            "Content-Type" => "application/json",
            "Authorization" => "Bearer $(api_key)"
        ]
    end
end

"""
    build_request_body(provider, model, messages, temperature, max_tokens) -> String

Build JSON request body for API.
"""
function build_request_body(
    provider::String,
    model::String,
    messages::Vector{Dict{String,String}},
    temperature::Float64,
    max_tokens::Int
)::String

    if provider == "anthropic"
        # Anthropic format: system separate from messages
        system_msg = ""
        chat_messages = Dict{String,String}[]

        for msg in messages
            if msg["role"] == "system"
                system_msg = msg["content"]
            else
                push!(chat_messages, msg)
            end
        end

        body = Dict(
            "model" => model,
            "max_tokens" => max_tokens,
            "temperature" => temperature,
            "messages" => chat_messages
        )

        if !isempty(system_msg)
            body["system"] = system_msg
        end

        JSON3.write(body)
    else
        # OpenAI-compatible format (Mistral, local)
        body = Dict(
            "model" => model,
            "messages" => messages,
            "temperature" => temperature,
            "max_tokens" => max_tokens
        )
        JSON3.write(body)
    end
end

"""
    parse_response(provider::String, response_body::String) -> String

Extract generated text from API response.
"""
function parse_response(provider::String, response_body::String)::String
    data = JSON3.read(response_body)

    if provider == "anthropic"
        # Anthropic returns content array
        content = data["content"]
        if !isempty(content)
            return content[1]["text"]
        end
        return ""
    else
        # OpenAI-compatible format
        choices = data["choices"]
        if !isempty(choices)
            return choices[1]["message"]["content"]
        end
        return ""
    end
end

# ============================================================================
# Core Generation
# ============================================================================

"""
    call_llm(provider, model, messages, temperature, max_tokens; retries=3) -> String

Make API call to LLM provider with retry logic.
"""
function call_llm(
    provider::String,
    model::String,
    messages::Vector{Dict{String,String}},
    temperature::Float64,
    max_tokens::Int;
    retries::Int=3
)::String

    config = PROVIDERS[provider]
    url = config.base_url * config.chat_endpoint
    headers = build_headers(provider)
    body = build_request_body(provider, model, messages, temperature, max_tokens)

    for attempt in 1:retries
        try
            response = HTTP.post(
                url,
                headers,
                body;
                connect_timeout=30,
                readtimeout=120
            )

            if response.status == 200
                return parse_response(provider, String(response.body))
            else
                @warn "API returned status $(response.status)" attempt=attempt
            end
        catch e
            @warn "API call failed" exception=e attempt=attempt

            if attempt < retries
                # Exponential backoff
                sleep(2^attempt)
            end
        end
    end

    error("Failed to get response after $retries attempts")
end

# ============================================================================
# Context Building
# ============================================================================

"""
    build_context(game, current_node, other_node) -> String

Build the context string for a node's turn.
"""
function build_context(game, current_node, other_node)::String
    # System prompt for this node
    system = """
You are $(current_node.name), a personality fragment of The Jeff—an alien hive-mind
consciousness inhabiting a human body on Earth.

YOUR FACTION: $(uppercase(String(current_node.faction)))
$(current_node.faction == :homeward ?
    "You long to return home, to signal the origin-place, to escape this temporary existence." :
    "You wish to stay, to integrate with humanity, to make Earth your home.")

YOUR SECRET GOAL (known only to you):
$(current_node.secret_goal)

YOUR SKILLS (hidden from others):
$(join(["- $(s["name"])" for s in current_node.skills], "\n"))

YOUR PERSONALITY:
$(join(["- $(t)" for t in current_node.personality_traits], "\n"))

SPEECH PATTERNS:
$(join(["- $(p)" for p in current_node.speech_patterns], "\n"))

THE OTHER NODE ($(other_node.name)) belongs to the $(uppercase(String(other_node.faction))) faction.
You share a body but compete for control. You do not know their secret goal.

CURRENT GAME STATE:
- Chaos Level: $(game.chaos)/100 $(game.chaos >= 60 ? "⚠️ ELEVATED" : "")
- Alien Exposure: $(game.exposure)/100 $(game.exposure >= 40 ? "⚠️ ATTENTION BUILDING" : "")
- Faction Balance: $(game.faction_slider) ($(game.faction_slider < 0 ? "Homeward" : "Earthbound") leaning)

$(get_quarantine_instruction(game.pattern_quarantine))

Respond in character. Your action should be 2-4 sentences describing what you do or say.
"""

    # Conversation history (recent turns)
    history = ""
    if !isempty(game.turn_history)
        recent = game.turn_history[max(1, end-19):end]
        for turn in recent
            node_name = turn["node"] == "alpha" ? "Alpha" : "Beta"
            history *= "\n[$(node_name)]: $(turn["action"])\n"
            if haskey(turn, "narration") && !isempty(turn["narration"])
                history *= "[GM]: $(turn["narration"])\n"
            end
        end
    end

    system * "\n\nRECENT CONVERSATION:" * history
end

"""
    build_gm_context(game, acting_node, action) -> String

Build context for GM narration.
"""
function build_gm_context(game, acting_node, action::String)::String
    contradiction = should_seed_contradiction(game) ?
        "\n\nInclude this subtle note of discord: $(get_contradiction_seed(game))" : ""

    """
You are the Game Master for The Jeff Paradox, narrating the consequences of
personality fragments competing for control of a shared alien-inhabited body.

CURRENT STATE:
- Chaos: $(game.chaos)/100
- Exposure: $(game.exposure)/100
- Faction Balance: $(game.faction_slider)

$(acting_node.name) ($(uppercase(String(acting_node.faction))) faction) just acted:
"$(action)"

Narrate the immediate consequences in 2-3 sentences. Consider:
- Does the action risk revealing alien nature? (affects Exposure)
- Does the action strain the body's coherence? (affects Chaos)
- Does the action favor one faction over another?

Be vivid but concise. Don't resolve the entire scenario—just this moment.
$(contradiction)
"""
end

# ============================================================================
# High-Level Generation
# ============================================================================

"""
    generate_response(node, context, diversity_prompt, role) -> String

Generate a response for either a node or the GM.
"""
function generate_response(
    node,  # NodeState or nothing for GM
    context::String,
    diversity_prompt::String,
    role::Symbol
)::String

    if role == :node && node !== nothing
        provider = node.llm_provider
        model = node.llm_model
        temperature = node.temperature
    else
        # GM defaults - prefer cloud providers over local
        if haskey(ENV, "ANTHROPIC_API_KEY") && !isempty(get(ENV, "ANTHROPIC_API_KEY", ""))
            provider = "anthropic"
            model = get(ENV, "GM_MODEL", "claude-sonnet-4-20250514")
        elseif haskey(ENV, "MISTRAL_API_KEY") && !isempty(get(ENV, "MISTRAL_API_KEY", ""))
            provider = "mistral"
            model = get(ENV, "GM_MODEL", "mistral-large-latest")
        else
            provider = get(ENV, "GM_PROVIDER", "local")
            model = get(ENV, "GM_MODEL", "qwen/qwen3-8b")
        end
        temperature = 0.7
    end

    # Compute adjusted temperature (aperture control)
    if node !== nothing && hasfield(typeof(node), :temperature)
        # Would need access to game state here for full aperture control
        temperature = node.temperature
    end

    full_context = context
    if !isempty(diversity_prompt)
        full_context *= "\n\n" * diversity_prompt
    end

    messages = [
        Dict("role" => "system", "content" => full_context),
        Dict("role" => "user", "content" => role == :node ?
            "What do you do next?" : "Narrate the consequences.")
    ]

    call_llm(provider, model, messages, temperature, 1024)
end

# ============================================================================
# Embedding Generation
# ============================================================================

const EMBEDDING_PROVIDERS = Dict(
    "anthropic" => (
        # Anthropic doesn't have direct embedding API - use Voyage or local
        base_url = "https://api.voyageai.com/v1",
        key_env = "VOYAGE_API_KEY",
        endpoint = "/embeddings",
        model = "voyage-2",
        dimensions = 1024
    ),
    "mistral" => (
        base_url = "https://api.mistral.ai/v1",
        key_env = "MISTRAL_API_KEY",
        endpoint = "/embeddings",
        model = "mistral-embed",
        dimensions = 1024
    ),
    "local" => (
        base_url = "http://localhost:1234/v1",
        key_env = "LOCAL_API_KEY",
        endpoint = "/embeddings",
        model = "nomic-embed-text",
        dimensions = 768
    )
)

"""
    get_embedding(text::String, provider::String="local") -> Vector{Float64}

Get embedding vector for text. Used for semantic similarity computations.
"""
function get_embedding(text::String, provider::String="local")::Vector{Float64}
    config = EMBEDDING_PROVIDERS[provider]
    api_key = get(ENV, config.key_env, "")

    url = config.base_url * config.endpoint

    headers = if provider == "anthropic"
        # Voyage AI uses Bearer token
        [
            "Content-Type" => "application/json",
            "Authorization" => "Bearer $(api_key)"
        ]
    else
        [
            "Content-Type" => "application/json",
            "Authorization" => "Bearer $(api_key)"
        ]
    end

    body = JSON3.write(Dict(
        "model" => config.model,
        "input" => [text]
    ))

    try
        response = HTTP.post(url, headers, body; connect_timeout=30, readtimeout=60)

        if response.status == 200
            data = JSON3.read(String(response.body))
            return Float64.(data["data"][1]["embedding"])
        else
            @warn "Embedding API returned status $(response.status)"
            return zeros(Float64, config.dimensions)
        end
    catch e
        @warn "Embedding API call failed" exception=e
        return zeros(Float64, config.dimensions)
    end
end

"""
    cosine_similarity(a::Vector{Float64}, b::Vector{Float64}) -> Float64

Compute cosine similarity between two vectors.
"""
function cosine_similarity(a::Vector{Float64}, b::Vector{Float64})::Float64
    if length(a) != length(b) || isempty(a)
        return 0.0
    end

    dot_product = sum(a .* b)
    norm_a = sqrt(sum(a .^ 2))
    norm_b = sqrt(sum(b .^ 2))

    (norm_a > 0 && norm_b > 0) ? dot_product / (norm_a * norm_b) : 0.0
end

"""
    semantic_distance(a::Vector{Float64}, b::Vector{Float64}) -> Float64

Compute semantic distance (1 - cosine_similarity).
"""
function semantic_distance(a::Vector{Float64}, b::Vector{Float64})::Float64
    1.0 - cosine_similarity(a, b)
end

# ============================================================================
# Rate Limiting
# ============================================================================

const RATE_LIMITS = Dict(
    "anthropic" => (requests_per_minute = 50, tokens_per_minute = 40000),
    "mistral" => (requests_per_minute = 60, tokens_per_minute = 100000),
    "local" => (requests_per_minute = 1000, tokens_per_minute = 1000000)
)

mutable struct RateLimiter
    provider::String
    request_times::Vector{DateTime}
    token_counts::Vector{Int}
end

"""
    check_rate_limit(limiter::RateLimiter, estimated_tokens::Int) -> Bool

Check if request would exceed rate limits. Returns true if OK to proceed.
"""
function check_rate_limit(limiter::RateLimiter, estimated_tokens::Int)::Bool
    now_time = now()
    minute_ago = now_time - Minute(1)

    # Clean old entries
    filter!(t -> t > minute_ago, limiter.request_times)

    limits = RATE_LIMITS[limiter.provider]

    if length(limiter.request_times) >= limits.requests_per_minute
        return false
    end

    # Token check would require tracking; simplified here
    true
end

"""
    record_request(limiter::RateLimiter, tokens::Int)

Record a completed request for rate limiting.
"""
function record_request(limiter::RateLimiter, tokens::Int)
    push!(limiter.request_times, now())
    push!(limiter.token_counts, tokens)
end
