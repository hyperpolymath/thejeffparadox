# SPDX-FileCopyrightText: 2025 The Jeff Paradox Collaboration
# SPDX-License-Identifier: MIT

"""
Embedding generation and similarity computation.

Used for semantic distance calculations in metrics and convergence detection.
"""

# ============================================================================
# Embedding Providers
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

# ============================================================================
# Embedding Generation
# ============================================================================

"""
    get_embedding(text::String, provider::String="local") -> Vector{Float64}

Get embedding vector for text. Used for semantic similarity computations.
"""
function get_embedding(text::String, provider::String="local")::Vector{Float64}
    config = EMBEDDING_PROVIDERS[provider]
    api_key = get(ENV, config.key_env, "")

    url = config.base_url * config.endpoint

    headers = [
        "Content-Type" => "application/json",
        "Authorization" => "Bearer $(api_key)"
    ]

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

# ============================================================================
# Similarity Functions
# ============================================================================

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
