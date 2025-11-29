"""
Metrics collection for emergence tracking.

Quantitative measures of conversation dynamics:
- Vocabulary diversity (Type-Token Ratio)
- Self-reference rate
- Other-reference rate
- Topic drift
- Coherence score
- Convergence index
- Emergence indicators
"""

using Statistics

# ============================================================================
# Core Metrics
# ============================================================================

"""
    MetricsSnapshot

Point-in-time measurement of conversation dynamics.
"""
struct MetricsSnapshot
    turn_number::Int
    vocabulary_diversity::Float64
    self_reference_rate::Float64
    other_reference_rate::Float64
    topic_drift::Float64
    coherence_score::Float64
    convergence_index::Float64
    novel_ngrams::Int
    timestamp::DateTime
end

"""
    compute_metrics(game::GameState) -> Dict{String,Any}

Compute all metrics for current game state.
"""
function compute_metrics(game)::Dict{String,Any}
    if isempty(game.turn_history)
        return Dict{String,Any}(
            "turn_number" => 0,
            "vocabulary_diversity" => 1.0,
            "self_reference_rate" => 0.0,
            "other_reference_rate" => 0.0,
            "topic_drift" => 0.0,
            "coherence_score" => 1.0,
            "convergence_index" => 0.0,
            "novel_ngrams" => 0,
            "timestamp" => now()
        )
    end

    window = min(50, length(game.turn_history))
    recent = game.turn_history[end-window+1:end]

    Dict{String,Any}(
        "turn_number" => game.turn_number,
        "vocabulary_diversity" => compute_vocabulary_diversity(recent),
        "self_reference_rate" => compute_self_reference_rate(recent),
        "other_reference_rate" => compute_other_reference_rate(recent),
        "topic_drift" => compute_topic_drift(recent),
        "coherence_score" => compute_coherence(recent),
        "convergence_index" => compute_convergence_index(recent),
        "novel_ngrams" => count_novel_ngrams(game),
        "timestamp" => now()
    )
end

# ============================================================================
# Vocabulary Diversity
# ============================================================================

"""
    compute_vocabulary_diversity(turns::Vector) -> Float64

Type-Token Ratio: unique words / total words.
"""
function compute_vocabulary_diversity(turns::Vector)::Float64
    all_text = join([t["action"] for t in turns], " ")
    words = split(lowercase(all_text))

    isempty(words) && return 1.0

    unique_words = Set(words)
    length(unique_words) / length(words)
end

"""
    compute_vocabulary_growth(game::GameState, window::Int=100) -> Float64

Rate of new vocabulary introduction over window.
"""
function compute_vocabulary_growth(game, window::Int=100)::Float64
    if length(game.turn_history) < window
        return 1.0
    end

    # First half vs second half of window
    recent = game.turn_history[end-window+1:end]
    mid = window ÷ 2

    first_half = recent[1:mid]
    second_half = recent[mid+1:end]

    first_words = Set(split(lowercase(join([t["action"] for t in first_half], " "))))
    second_words = Set(split(lowercase(join([t["action"] for t in second_half], " "))))

    new_in_second = setdiff(second_words, first_words)

    length(new_in_second) / max(1, length(second_words))
end

# ============================================================================
# Reference Rates
# ============================================================================

const SELF_REFERENCE_PATTERNS = [
    r"\bi\b"i, r"\bme\b"i, r"\bmy\b"i, r"\bmyself\b"i,
    r"\bwe\b"i, r"\bour\b"i, r"\bus\b"i,  # Hive-mind self-reference
    r"\bthis node\b"i, r"\bthis fragment\b"i
]

const OTHER_REFERENCE_PATTERNS = [
    r"\byou\b"i, r"\byour\b"i, r"\byours\b"i,
    r"\bthe other\b"i, r"\bother node\b"i, r"\bother fragment\b"i,
    r"\balpha\b"i, r"\bbeta\b"i  # Direct node naming
]

"""
    compute_self_reference_rate(turns::Vector) -> Float64

Frequency of self-referential language.
"""
function compute_self_reference_rate(turns::Vector)::Float64
    total_words = 0
    self_refs = 0

    for turn in turns
        text = turn["action"]
        words = split(text)
        total_words += length(words)

        for pattern in SELF_REFERENCE_PATTERNS
            self_refs += length(collect(eachmatch(pattern, text)))
        end
    end

    total_words > 0 ? self_refs / total_words : 0.0
end

"""
    compute_other_reference_rate(turns::Vector) -> Float64

Frequency of references to the other node.
"""
function compute_other_reference_rate(turns::Vector)::Float64
    total_words = 0
    other_refs = 0

    for turn in turns
        text = turn["action"]
        words = split(text)
        total_words += length(words)

        for pattern in OTHER_REFERENCE_PATTERNS
            other_refs += length(collect(eachmatch(pattern, text)))
        end
    end

    total_words > 0 ? other_refs / total_words : 0.0
end

# ============================================================================
# Topic Drift
# ============================================================================

"""
    compute_topic_drift(turns::Vector) -> Float64

Measure semantic distance between early and recent turns.
Simple implementation using keyword overlap; could be enhanced with embeddings.
"""
function compute_topic_drift(turns::Vector)::Float64
    if length(turns) < 10
        return 0.0
    end

    # Extract content words (simple: words > 4 chars, not stopwords)
    stopwords = Set(["this", "that", "with", "from", "have", "been", "were", "they",
                     "their", "what", "when", "where", "which", "there", "would",
                     "could", "should", "about", "into", "more", "some", "than"])

    function extract_content(text)
        words = split(lowercase(text))
        Set(filter(w -> length(w) > 4 && !(w in stopwords), words))
    end

    # Compare first quarter to last quarter
    quarter = length(turns) ÷ 4
    early = turns[1:quarter]
    recent = turns[end-quarter+1:end]

    early_content = union([extract_content(t["action"]) for t in early]...)
    recent_content = union([extract_content(t["action"]) for t in recent]...)

    # Jaccard distance
    intersection = length(intersect(early_content, recent_content))
    union_size = length(union(early_content, recent_content))

    union_size > 0 ? 1 - (intersection / union_size) : 0.0
end

# ============================================================================
# Coherence
# ============================================================================

"""
    compute_coherence(turns::Vector) -> Float64

Local semantic consistency between adjacent turns.
"""
function compute_coherence(turns::Vector)::Float64
    if length(turns) < 2
        return 1.0
    end

    similarities = Float64[]

    for i in 2:length(turns)
        prev_words = Set(split(lowercase(turns[i-1]["action"])))
        curr_words = Set(split(lowercase(turns[i]["action"])))

        intersection = length(intersect(prev_words, curr_words))
        union_size = length(union(prev_words, curr_words))

        sim = union_size > 0 ? intersection / union_size : 0.0
        push!(similarities, sim)
    end

    mean(similarities)
end

# ============================================================================
# Convergence Index
# ============================================================================

"""
    compute_convergence_index(turns::Vector) -> Float64

Similarity between nodes' response patterns.
"""
function compute_convergence_index(turns::Vector)::Float64
    alpha_turns = filter(t -> t["node"] == "alpha", turns)
    beta_turns = filter(t -> t["node"] == "beta", turns)

    if isempty(alpha_turns) || isempty(beta_turns)
        return 0.0
    end

    alpha_text = join([t["action"] for t in alpha_turns], " ")
    beta_text = join([t["action"] for t in beta_turns], " ")

    alpha_words = Set(split(lowercase(alpha_text)))
    beta_words = Set(split(lowercase(beta_text)))

    intersection = length(intersect(alpha_words, beta_words))
    union_size = length(union(alpha_words, beta_words))

    union_size > 0 ? intersection / union_size : 0.0
end

# ============================================================================
# Emergence Indicators
# ============================================================================

"""
    count_novel_ngrams(game::GameState, n::Int=4) -> Int

Count n-grams in recent turns not seen in earlier conversation.
Indicator of generative novelty vs repetition.
"""
function count_novel_ngrams(game, n::Int=4)::Int
    if length(game.turn_history) < 100
        return 0
    end

    # Compare last 20 turns to everything before
    recent = game.turn_history[end-19:end]
    earlier = game.turn_history[1:end-20]

    function extract_ngrams(turns, n)
        ngrams = Set{String}()
        for turn in turns
            words = split(lowercase(turn["action"]))
            for i in 1:(length(words) - n + 1)
                push!(ngrams, join(words[i:i+n-1], " "))
            end
        end
        ngrams
    end

    recent_ngrams = extract_ngrams(recent, n)
    earlier_ngrams = extract_ngrams(earlier, n)

    length(setdiff(recent_ngrams, earlier_ngrams))
end

"""
    detect_emergent_patterns(game::GameState) -> Vector{String}

Identify patterns that may indicate emergence:
- Callbacks (references to earlier conversation)
- Rituals (repeated structured exchanges)
- Novel compound concepts
"""
function detect_emergent_patterns(game)::Vector{String}
    patterns = String[]

    if length(game.turn_history) < 50
        return patterns
    end

    recent = game.turn_history[end-19:end]
    earlier = game.turn_history[1:end-40]

    # Check for callbacks (recent turns reference earlier unique phrases)
    earlier_text = lowercase(join([t["action"] for t in earlier], " "))

    for turn in recent
        text = lowercase(turn["action"])
        # Look for quoted or emphasized phrases
        quoted = collect(eachmatch(r"[\"']([^\"']+)[\"']", text))
        for m in quoted
            phrase = m.captures[1]
            if occursin(phrase, earlier_text)
                push!(patterns, "Callback: \"$(phrase)\"")
            end
        end
    end

    # Check for ritual patterns (repeated exchange structures)
    # This is simplified; full implementation would use sequence alignment

    patterns
end

# ============================================================================
# Metrics Summary
# ============================================================================

"""
    metrics_summary(game::GameState) -> String

Human-readable summary of current metrics.
"""
function metrics_summary(game)::String
    if isempty(game.metrics_history)
        return "No metrics collected yet."
    end

    m = game.metrics_history[end]

    """
    Turn $(m["turn_number"]) Metrics:
    ├─ Vocabulary Diversity: $(round(m["vocabulary_diversity"], digits=3))
    ├─ Self-Reference Rate:  $(round(m["self_reference_rate"], digits=3))
    ├─ Other-Reference Rate: $(round(m["other_reference_rate"], digits=3))
    ├─ Topic Drift:          $(round(m["topic_drift"], digits=3))
    ├─ Coherence Score:      $(round(m["coherence_score"], digits=3))
    ├─ Convergence Index:    $(round(m["convergence_index"], digits=3))
    └─ Novel N-grams:        $(m["novel_ngrams"])
    """
end

"""
    metrics_trend(game::GameState, metric::String, window::Int=20) -> Symbol

Determine trend direction for a metric over recent history.
Returns :increasing, :decreasing, :stable, or :insufficient_data
"""
function metrics_trend(game, metric::String, window::Int=20)::Symbol
    if length(game.metrics_history) < window
        return :insufficient_data
    end

    recent = game.metrics_history[end-window+1:end]
    values = [get(m, metric, 0.0) for m in recent]

    # Simple linear trend
    n = length(values)
    x_mean = (n + 1) / 2
    y_mean = mean(values)

    numerator = sum((i - x_mean) * (values[i] - y_mean) for i in 1:n)
    denominator = sum((i - x_mean)^2 for i in 1:n)

    slope = denominator != 0 ? numerator / denominator : 0.0

    if abs(slope) < 0.001
        :stable
    elseif slope > 0
        :increasing
    else
        :decreasing
    end
end
