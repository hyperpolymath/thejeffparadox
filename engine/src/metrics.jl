# SPDX-FileCopyrightText: 2025 The Jeff Paradox Collaboration
# SPDX-License-Identifier: MIT

"""
Metrics computation for emergence tracking.

Tracks:
- Vocabulary diversity (type-token ratio)
- Self-reference and other-reference rates
- Coherence score (adjacent turn similarity)
- Convergence index (cross-node similarity)
- Novel n-gram count
"""

using Statistics

# ============================================================================
# MetricsSnapshot
# ============================================================================

"""
    MetricsSnapshot

Immutable snapshot of computed metrics for a given turn.
"""
struct MetricsSnapshot
    turn_number::Int
    vocabulary_diversity::Float64
    self_reference_rate::Float64
    other_reference_rate::Float64
    coherence_score::Float64
    convergence_index::Float64
    novel_ngram_count::Int
    timestamp::DateTime
end

# ============================================================================
# Vocabulary Diversity
# ============================================================================

const STOP_WORDS = Set([
    "the", "a", "an", "is", "are", "was", "were", "be", "been", "being",
    "have", "has", "had", "do", "does", "did", "will", "would", "shall",
    "should", "may", "might", "must", "can", "could", "to", "of", "in",
    "for", "on", "with", "at", "by", "from", "as", "into", "through",
    "during", "before", "after", "and", "but", "or", "nor", "not", "so",
    "yet", "both", "either", "neither", "each", "every", "all", "any",
    "few", "more", "most", "other", "some", "such", "no", "only", "own",
    "same", "than", "too", "very", "just", "because", "if", "when", "that",
    "this", "it", "its"
])

"""
    compute_vocabulary_diversity(turns::Vector) -> Float64

Compute type-token ratio across turn actions. Returns 1.0 for empty input.
"""
function compute_vocabulary_diversity(turns::Vector)::Float64
    if isempty(turns)
        return 1.0
    end

    all_words = String[]
    for turn in turns
        action = get(turn, "action", "")
        words = split(lowercase(action))
        append!(all_words, words)
    end

    if isempty(all_words)
        return 1.0
    end

    unique_count = length(Set(all_words))
    total_count = length(all_words)

    unique_count / total_count
end

# ============================================================================
# Reference Rates
# ============================================================================

const SELF_REFERENCE_WORDS = Set(["i", "me", "my", "mine", "myself", "we", "us", "our", "ours", "ourselves"])
const OTHER_REFERENCE_WORDS = Set(["you", "your", "yours", "yourself", "they", "them", "their", "theirs"])

"""
    compute_self_reference_rate(turns::Vector) -> Float64

Compute ratio of self-referencing pronouns to total words.
"""
function compute_self_reference_rate(turns::Vector)::Float64
    if isempty(turns)
        return 0.0
    end

    total_words = 0
    self_refs = 0

    for turn in turns
        action = get(turn, "action", "")
        words = split(lowercase(action))
        total_words += length(words)
        self_refs += count(w -> w in SELF_REFERENCE_WORDS, words)
    end

    total_words > 0 ? self_refs / total_words : 0.0
end

"""
    compute_other_reference_rate(turns::Vector) -> Float64

Compute ratio of other-referencing pronouns to total words.
"""
function compute_other_reference_rate(turns::Vector)::Float64
    if isempty(turns)
        return 0.0
    end

    total_words = 0
    other_refs = 0

    for turn in turns
        action = get(turn, "action", "")
        words = split(lowercase(action))
        total_words += length(words)
        other_refs += count(w -> w in OTHER_REFERENCE_WORDS, words)
    end

    total_words > 0 ? other_refs / total_words : 0.0
end

# ============================================================================
# Coherence Score
# ============================================================================

"""
    compute_coherence_score(turns::Vector) -> Float64

Measure coherence via word overlap between adjacent turns.
Returns 0.0 for fewer than 2 turns.
"""
function compute_coherence_score(turns::Vector)::Float64
    if length(turns) < 2
        return 0.0
    end

    overlaps = Float64[]

    for i in 2:length(turns)
        prev_words = Set(split(lowercase(get(turns[i-1], "action", ""))))
        curr_words = Set(split(lowercase(get(turns[i], "action", ""))))

        # Remove stop words for more meaningful comparison
        prev_content = setdiff(prev_words, STOP_WORDS)
        curr_content = setdiff(curr_words, STOP_WORDS)

        if isempty(prev_content) || isempty(curr_content)
            push!(overlaps, 0.0)
            continue
        end

        intersection_size = length(intersect(prev_content, curr_content))
        union_size = length(union(prev_content, curr_content))

        push!(overlaps, union_size > 0 ? intersection_size / union_size : 0.0)
    end

    isempty(overlaps) ? 0.0 : mean(overlaps)
end

# ============================================================================
# Convergence Index
# ============================================================================

"""
    compute_convergence_index(turns::Vector) -> Float64

Measure vocabulary convergence between nodes. Returns 0.0 if either node
has no turns. Values near 1.0 indicate the nodes are using identical language.
"""
function compute_convergence_index(turns::Vector)::Float64
    if isempty(turns)
        return 0.0
    end

    alpha_turns = filter(t -> get(t, "node", "") == "alpha", turns)
    beta_turns = filter(t -> get(t, "node", "") == "beta", turns)

    if isempty(alpha_turns) || isempty(beta_turns)
        return 0.0
    end

    alpha_words = Set(split(lowercase(join([get(t, "action", "") for t in alpha_turns], " "))))
    beta_words = Set(split(lowercase(join([get(t, "action", "") for t in beta_turns], " "))))

    # Remove stop words
    alpha_content = setdiff(alpha_words, STOP_WORDS)
    beta_content = setdiff(beta_words, STOP_WORDS)

    if isempty(alpha_content) || isempty(beta_content)
        return 0.0
    end

    intersection_size = length(intersect(alpha_content, beta_content))
    union_size = length(union(alpha_content, beta_content))

    union_size > 0 ? intersection_size / union_size : 0.0
end

# ============================================================================
# Novel N-grams
# ============================================================================

"""
    compute_novel_ngrams(turns::Vector, window::Int=20) -> Int

Count n-grams in the most recent turn that haven't appeared in the
preceding `window` turns. Measures novelty/emergence.
"""
function compute_novel_ngrams(turns::Vector, window::Int=20)::Int
    if isempty(turns)
        return 0
    end

    current = turns[end]
    current_words = split(lowercase(get(current, "action", "")))

    if length(current_words) < 3
        return 0
    end

    # Build set of n-grams from history
    history_start = max(1, length(turns) - window)
    history_end = max(1, length(turns) - 1)
    history = turns[history_start:history_end]

    history_ngrams = Set{String}()
    for turn in history
        words = split(lowercase(get(turn, "action", "")))
        for n in 3:min(5, length(words))
            for i in 1:(length(words) - n + 1)
                push!(history_ngrams, join(words[i:i+n-1], " "))
            end
        end
    end

    # Count novel n-grams in current turn
    novel_count = 0
    for n in 3:min(5, length(current_words))
        for i in 1:(length(current_words) - n + 1)
            ngram = join(current_words[i:i+n-1], " ")
            if !(ngram in history_ngrams)
                novel_count += 1
            end
        end
    end

    novel_count
end

# ============================================================================
# Aggregate Metrics
# ============================================================================

"""
    compute_metrics(game) -> Dict{String,Any}

Compute all metrics for the current game state. Returns a dictionary
compatible with the metrics_history accumulator.
"""
function compute_metrics(game)::Dict{String,Any}
    recent_window = game.turn_history[max(1, end-19):end]

    vocab_div = compute_vocabulary_diversity(recent_window)
    self_ref = compute_self_reference_rate(recent_window)
    other_ref = compute_other_reference_rate(recent_window)
    coherence = compute_coherence_score(recent_window)
    convergence = compute_convergence_index(recent_window)
    novel = compute_novel_ngrams(game.turn_history)

    Dict{String,Any}(
        "turn_number" => game.turn_number,
        "vocabulary_diversity" => vocab_div,
        "self_reference_rate" => self_ref,
        "other_reference_rate" => other_ref,
        "coherence_score" => coherence,
        "convergence_index" => convergence,
        "novel_ngram_count" => novel,
        "timestamp" => now()
    )
end

# ============================================================================
# Trend Analysis
# ============================================================================

"""
    metrics_trend(game, metric_name::String, window::Int=20) -> Symbol

Analyse the trend of a metric over recent turns.
Returns :increasing, :decreasing, or :stable.

Uses simple linear regression slope over the window.
"""
function metrics_trend(game, metric_name::String, window::Int=20)::Symbol
    history = game.metrics_history
    if length(history) < 3
        return :stable
    end

    recent = history[max(1, end-window+1):end]
    values = Float64[]

    for m in recent
        val = get(m, metric_name, nothing)
        if val !== nothing
            push!(values, Float64(val))
        end
    end

    if length(values) < 3
        return :stable
    end

    # Simple linear regression: slope of values over indices
    n = length(values)
    x = collect(1.0:n)
    x_mean = mean(x)
    y_mean = mean(values)

    numerator = sum((x .- x_mean) .* (values .- y_mean))
    denominator = sum((x .- x_mean) .^ 2)

    if denominator == 0.0
        return :stable
    end

    slope = numerator / denominator

    # Normalise slope relative to value range for threshold comparison
    value_range = maximum(values) - minimum(values)
    normalised = value_range > 0 ? abs(slope) / value_range : abs(slope)

    if normalised < 0.05
        :stable
    elseif slope > 0
        :increasing
    else
        :decreasing
    end
end

# ============================================================================
# Emergent Pattern Detection
# ============================================================================

"""
    detect_emergent_patterns(game) -> Vector{String}

Detect emergent patterns in the conversation history.
Looks for:
- Recurring thematic n-grams that appear across both nodes
- Self-referential loops (nodes referencing their own earlier statements)
- Novel vocabulary that persists (introduced and then reused)
"""
function detect_emergent_patterns(game)::Vector{String}
    patterns = String[]
    turns = game.turn_history

    if length(turns) < 20
        return patterns
    end

    # 1. Cross-node recurring phrases (3-grams appearing in both nodes)
    alpha_turns = filter(t -> get(t, "node", "") == "alpha", turns)
    beta_turns = filter(t -> get(t, "node", "") == "beta", turns)

    if !isempty(alpha_turns) && !isempty(beta_turns)
        alpha_ngrams = _extract_ngrams(alpha_turns, 3)
        beta_ngrams = _extract_ngrams(beta_turns, 3)

        shared = intersect(keys(alpha_ngrams), keys(beta_ngrams))
        # Filter to phrases used 3+ times by each node
        significant = filter(ng -> alpha_ngrams[ng] >= 3 && beta_ngrams[ng] >= 3, shared)

        if !isempty(significant)
            top = sort(collect(significant), by=ng -> alpha_ngrams[ng] + beta_ngrams[ng], rev=true)
            for ng in top[1:min(3, length(top))]
                total = alpha_ngrams[ng] + beta_ngrams[ng]
                push!(patterns, "Shared phrase \"$(ng)\" used $(total) times across both nodes")
            end
        end
    end

    # 2. Vocabulary persistence: words introduced in later turns that persist
    if length(turns) >= 40
        early = turns[1:div(length(turns), 2)]
        late = turns[div(length(turns), 2)+1:end]

        early_words = Set(split(lowercase(join([get(t, "action", "") for t in early], " "))))
        late_words = split(lowercase(join([get(t, "action", "") for t in late], " ")))

        # Words that appear frequently in late half but never in early half
        late_counts = Dict{String,Int}()
        for w in late_words
            if length(w) > 4 && !(w in early_words)  # Skip short/common words
                late_counts[w] = get(late_counts, w, 0) + 1
            end
        end

        novel_persistent = filter(p -> p.second >= 5, late_counts)
        if !isempty(novel_persistent)
            top_novel = sort(collect(novel_persistent), by=p -> p.second, rev=true)
            for (word, count) in top_novel[1:min(3, length(top_novel))]
                push!(patterns, "Novel term \"$(word)\" emerged and persisted ($(count) uses)")
            end
        end
    end

    # 3. Metric-based patterns
    if length(game.metrics_history) >= 10
        coherence_trend = metrics_trend(game, "coherence_score", 20)
        if coherence_trend == :increasing
            push!(patterns, "Coherence increasing \u2014 nodes may be synchronising")
        end

        diversity_trend = metrics_trend(game, "vocabulary_diversity", 20)
        if diversity_trend == :decreasing
            push!(patterns, "Vocabulary diversity declining \u2014 language converging")
        end
    end

    patterns
end

"""
    _extract_ngrams(turns::Vector, n::Int) -> Dict{String,Int}

Extract n-gram counts from turn actions.
"""
function _extract_ngrams(turns::Vector, n::Int)::Dict{String,Int}
    counts = Dict{String,Int}()
    for turn in turns
        words = split(lowercase(get(turn, "action", "")))
        for i in 1:(length(words) - n + 1)
            ngram = join(words[i:i+n-1], " ")
            counts[ngram] = get(counts, ngram, 0) + 1
        end
    end
    counts
end

# ============================================================================
# Summary
# ============================================================================

"""
    metrics_summary(game) -> String

Generate a human-readable summary of the latest metrics.
"""
function metrics_summary(game)::String
    if isempty(game.metrics_history)
        return "No metrics collected yet."
    end

    m = game.metrics_history[end]

    vocab_status = m["vocabulary_diversity"] < 0.3 ? "LOW" :
                   m["vocabulary_diversity"] < 0.5 ? "MODERATE" : "HEALTHY"
    coherence_status = m["coherence_score"] > 0.85 ? "HIGH (convergence risk)" :
                       m["coherence_score"] < 0.3 ? "LOW (incoherent)" : "NORMAL"
    convergence_status = m["convergence_index"] > 0.7 ? "WARNING: nodes converging" :
                         m["convergence_index"] > 0.5 ? "MODERATE overlap" : "HEALTHY differentiation"

    """
    === Metrics Summary (Turn $(m["turn_number"])) ===
    Vocabulary Diversity: $(round(m["vocabulary_diversity"], digits=3)) [$(vocab_status)]
    Self-Reference Rate:  $(round(m["self_reference_rate"], digits=3))
    Other-Reference Rate: $(round(m["other_reference_rate"], digits=3))
    Coherence Score:      $(round(m["coherence_score"], digits=3)) [$(coherence_status)]
    Convergence Index:    $(round(m["convergence_index"], digits=3)) [$(convergence_status)]
    Novel N-grams:        $(m["novel_ngram_count"])
    """
end
