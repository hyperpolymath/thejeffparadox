# SPDX-FileCopyrightText: 2025 The Jeff Paradox Collaboration
# SPDX-License-Identifier: MIT

"""
Rate limiting for LLM API calls.

Enforces per-provider request and token limits using a sliding window.
"""

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
    RateLimiter(provider::String) -> RateLimiter

Create a new rate limiter for the given provider.
"""
RateLimiter(provider::String) = RateLimiter(provider, DateTime[], Int[])

"""
    check_rate_limit(limiter::RateLimiter, estimated_tokens::Int) -> Bool

Check if request would exceed rate limits. Returns true if OK to proceed.
"""
function check_rate_limit(limiter::RateLimiter, estimated_tokens::Int)::Bool
    now_time = now()
    minute_ago = now_time - Minute(1)

    # Clean old entries (both request times and corresponding token counts)
    valid_indices = findall(t -> t > minute_ago, limiter.request_times)
    limiter.request_times = limiter.request_times[valid_indices]
    limiter.token_counts = limiter.token_counts[valid_indices]

    limits = RATE_LIMITS[limiter.provider]

    # Check request count limit
    if length(limiter.request_times) >= limits.requests_per_minute
        return false
    end

    # Check token count limit
    recent_tokens = isempty(limiter.token_counts) ? 0 : sum(limiter.token_counts)
    if recent_tokens + estimated_tokens > limits.tokens_per_minute
        return false
    end

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
