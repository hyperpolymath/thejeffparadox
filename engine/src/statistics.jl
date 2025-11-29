"""
Statistical framework for testing LLM personality stability hypotheses.

Implements both frequentist and Bayesian tests for:
- H1: Attractor existence (convergence)
- H2: Seed reproducibility
- H3: Attractor universality
- H4: Model invariance

See docs/statistical_framework.md for mathematical details.
"""

using Statistics
using LinearAlgebra
using Random

# ============================================================================
# Data Structures
# ============================================================================

"""
    SamplePoint

A single observation from the conversation trajectory.
"""
struct SamplePoint
    turn::Int
    node::Symbol  # :alpha or :beta
    text::String
    embedding::Vector{Float64}
    chaos::Int
    exposure::Int
    faction_slider::Int
    timestamp::Float64  # Unix timestamp
end

"""
    ExperimentRun

Complete record of a single experimental run.
"""
mutable struct ExperimentRun
    seed::UInt64
    model::String
    model_version::String
    start_time::Float64
    samples::Vector{SamplePoint}
    final_attractor::Union{Vector{Float64}, Nothing}
    converged::Bool
    convergence_turn::Union{Int, Nothing}
end

ExperimentRun(seed, model, version) = ExperimentRun(
    seed, model, version, time(),
    SamplePoint[], nothing, false, nothing
)

# ============================================================================
# Trajectory Analysis
# ============================================================================

"""
    extract_trajectory(run::ExperimentRun) -> Matrix{Float64}

Extract embedding trajectory as T×d matrix.
"""
function extract_trajectory(run::ExperimentRun)::Matrix{Float64}
    if isempty(run.samples)
        return zeros(Float64, 0, 0)
    end

    d = length(run.samples[1].embedding)
    T = length(run.samples)

    trajectory = zeros(Float64, T, d)
    for (i, sample) in enumerate(run.samples)
        trajectory[i, :] = sample.embedding
    end

    trajectory
end

"""
    extract_node_trajectory(run::ExperimentRun, node::Symbol) -> Matrix{Float64}

Extract trajectory for a specific node.
"""
function extract_node_trajectory(run::ExperimentRun, node::Symbol)::Matrix{Float64}
    filtered = filter(s -> s.node == node, run.samples)

    if isempty(filtered)
        return zeros(Float64, 0, 0)
    end

    d = length(filtered[1].embedding)
    T = length(filtered)

    trajectory = zeros(Float64, T, d)
    for (i, sample) in enumerate(filtered)
        trajectory[i, :] = sample.embedding
    end

    trajectory
end

"""
    estimate_attractor(trajectory::Matrix{Float64}; window::Int=100) -> Vector{Float64}

Estimate the attractor as the mean of the final window.
"""
function estimate_attractor(trajectory::Matrix{Float64}; window::Int=100)::Vector{Float64}
    T, d = size(trajectory)

    if T < window
        return vec(mean(trajectory, dims=1))
    end

    vec(mean(trajectory[end-window+1:end, :], dims=1))
end

# ============================================================================
# Frequentist Tests
# ============================================================================

"""
    adf_statistic(series::Vector{Float64}; lags::Int=10) -> Float64

Compute Augmented Dickey-Fuller test statistic for a time series.
Tests null hypothesis of unit root (non-stationarity).
"""
function adf_statistic(series::Vector{Float64}; lags::Int=10)::Float64
    n = length(series)

    if n <= lags + 2
        return 0.0  # Not enough data
    end

    # First difference
    Δy = diff(series)

    # Lagged level
    y_lag = series[lags+1:end-1]

    # Lagged differences
    ΔY_lags = zeros(Float64, length(y_lag), lags)
    for i in 1:lags
        ΔY_lags[:, i] = Δy[lags+1-i:end-i]
    end

    # Dependent variable (aligned)
    Δy_dep = Δy[lags+1:end]

    # Design matrix: [1, y_{t-1}, Δy_{t-1}, ..., Δy_{t-p}]
    X = hcat(ones(length(y_lag)), y_lag, ΔY_lags)

    # OLS estimation
    try
        β = X \ Δy_dep
        residuals = Δy_dep - X * β
        σ² = sum(residuals.^2) / (length(residuals) - size(X, 2))

        # Variance of β̂
        var_β = σ² * inv(X' * X)

        # t-statistic for γ (coefficient on y_{t-1})
        γ_hat = β[2]
        se_γ = sqrt(var_β[2, 2])

        return γ_hat / se_γ
    catch
        return 0.0
    end
end

# Critical values for ADF test (approximate, n=∞)
const ADF_CRITICAL = Dict(
    0.01 => -3.43,
    0.05 => -2.86,
    0.10 => -2.57
)

"""
    test_convergence(trajectory::Matrix{Float64}; α=0.05) -> NamedTuple

Test for convergence using ADF test on each embedding dimension.
Returns fraction of dimensions that show convergence.
"""
function test_convergence(trajectory::Matrix{Float64}; α::Float64=0.05)
    T, d = size(trajectory)

    if T < 50
        return (
            converged_fraction = 0.0,
            adf_statistics = Float64[],
            reject_null = Bool[],
            conclusion = "Insufficient data"
        )
    end

    # Bonferroni correction
    α_corrected = α / d
    critical_value = ADF_CRITICAL[0.05]  # Use 5% as base

    adf_stats = Float64[]
    rejections = Bool[]

    for j in 1:d
        stat = adf_statistic(trajectory[:, j])
        push!(adf_stats, stat)
        push!(rejections, stat < critical_value)
    end

    converged_frac = mean(rejections)

    conclusion = if converged_frac > 0.9
        "Strong evidence of convergence"
    elseif converged_frac > 0.5
        "Moderate evidence of convergence"
    elseif converged_frac > 0.1
        "Weak evidence of convergence"
    else
        "No evidence of convergence"
    end

    (
        converged_fraction = converged_frac,
        adf_statistics = adf_stats,
        reject_null = rejections,
        conclusion = conclusion
    )
end

"""
    hotelling_t2(differences::Vector{Vector{Float64}}) -> NamedTuple

Hotelling's T² test for whether mean difference vector is zero.
Used for testing seed reproducibility.
"""
function hotelling_t2(differences::Vector{Vector{Float64}})
    k = length(differences)
    d = length(differences[1])

    if k <= d
        return (
            T2 = NaN,
            F_stat = NaN,
            p_value = NaN,
            conclusion = "Insufficient samples (need k > d)"
        )
    end

    # Mean difference vector
    d_bar = mean(differences)

    # Sample covariance
    D = hcat(differences...)'  # k × d matrix
    S_d = cov(D)

    # Add small regularization for numerical stability
    S_d += 1e-6 * I(d)

    # T² statistic
    T2 = k * d_bar' * inv(S_d) * d_bar

    # Convert to F statistic
    F_stat = (k - d) / (d * (k - 1)) * T2

    # Degrees of freedom
    df1 = d
    df2 = k - d

    # Approximate p-value using F distribution
    # F_cdf approximation for large df
    p_value = if F_stat > 0
        exp(-0.5 * F_stat)  # Rough approximation
    else
        1.0
    end

    conclusion = if p_value < 0.01
        "Strong evidence against reproducibility"
    elseif p_value < 0.05
        "Moderate evidence against reproducibility"
    elseif p_value < 0.10
        "Weak evidence against reproducibility"
    else
        "No evidence against reproducibility (seeds appear consistent)"
    end

    (T2 = T2, F_stat = F_stat, p_value = p_value, df = (df1, df2), conclusion = conclusion)
end

"""
    test_seed_reproducibility(run_pairs::Vector{Tuple{ExperimentRun, ExperimentRun}}) -> NamedTuple

Test whether same-seed runs produce the same attractor.
"""
function test_seed_reproducibility(run_pairs::Vector{Tuple{ExperimentRun, ExperimentRun}})
    differences = Vector{Float64}[]

    for (run1, run2) in run_pairs
        if run1.final_attractor !== nothing && run2.final_attractor !== nothing
            push!(differences, run1.final_attractor - run2.final_attractor)
        end
    end

    if isempty(differences)
        return (
            T2 = NaN,
            conclusion = "No valid attractor pairs found"
        )
    end

    hotelling_t2(differences)
end

# ============================================================================
# Effect Size Measures
# ============================================================================

"""
    intraclass_correlation(groups::Vector{Vector{Vector{Float64}}}) -> Float64

Compute ICC for attractor consistency across same-seed runs.
`groups` is a vector where each element contains attractors from same-seed runs.
"""
function intraclass_correlation(groups::Vector{Vector{Vector{Float64}}})::Float64
    if isempty(groups) || all(length.(groups) .< 2)
        return NaN
    end

    # Flatten to compute overall mean
    all_attractors = vcat(groups...)
    d = length(all_attractors[1])

    grand_mean = mean(all_attractors)

    # Between-group variance
    group_means = [mean(g) for g in groups]
    n_per_group = length.(groups)

    SS_between = sum(n * norm(μ - grand_mean)^2 for (n, μ) in zip(n_per_group, group_means))

    # Within-group variance
    SS_within = sum(
        sum(norm(a - μ)^2 for a in g)
        for (g, μ) in zip(groups, group_means)
    )

    k = length(groups)
    N = sum(n_per_group)
    n_avg = N / k

    MS_between = SS_between / (k - 1)
    MS_within = SS_within / (N - k)

    # ICC(1,1)
    (MS_between - MS_within) / (MS_between + (n_avg - 1) * MS_within)
end

"""
    cohens_d(group1::Vector{Vector{Float64}}, group2::Vector{Vector{Float64}}) -> Float64

Compute Cohen's d for multivariate attractor separation.
"""
function cohens_d(group1::Vector{Vector{Float64}}, group2::Vector{Vector{Float64}})::Float64
    if isempty(group1) || isempty(group2)
        return NaN
    end

    μ1 = mean(group1)
    μ2 = mean(group2)

    n1 = length(group1)
    n2 = length(group2)

    # Pooled standard deviation (using trace of covariance as scalar measure)
    var1 = mean(norm.(group1 .- Ref(μ1)).^2)
    var2 = mean(norm.(group2 .- Ref(μ2)).^2)

    pooled_var = ((n1 - 1) * var1 + (n2 - 1) * var2) / (n1 + n2 - 2)
    pooled_sd = sqrt(pooled_var)

    norm(μ1 - μ2) / pooled_sd
end

"""
    silhouette_score(attractors::Vector{Vector{Float64}}, labels::Vector{Int}) -> Float64

Compute silhouette score for attractor clustering.
"""
function silhouette_score(attractors::Vector{Vector{Float64}}, labels::Vector{Int})::Float64
    n = length(attractors)
    unique_labels = unique(labels)
    k = length(unique_labels)

    if k == 1 || n <= k
        return 0.0
    end

    silhouettes = Float64[]

    for i in 1:n
        # Intra-cluster distance
        same_cluster = findall(l -> l == labels[i], labels)
        if length(same_cluster) == 1
            push!(silhouettes, 0.0)
            continue
        end

        a_i = mean(norm(attractors[i] - attractors[j]) for j in same_cluster if j != i)

        # Nearest cluster distance
        b_i = Inf
        for label in unique_labels
            if label == labels[i]
                continue
            end
            other_cluster = findall(l -> l == label, labels)
            if !isempty(other_cluster)
                b_label = mean(norm(attractors[i] - attractors[j]) for j in other_cluster)
                b_i = min(b_i, b_label)
            end
        end

        s_i = (b_i - a_i) / max(a_i, b_i)
        push!(silhouettes, s_i)
    end

    mean(silhouettes)
end

# ============================================================================
# Bayesian Model Evidence (Simplified)
# ============================================================================

"""
    log_marginal_likelihood_single(attractors::Vector{Vector{Float64}}; σ_μ=10.0, α_τ=2.0, β_τ=1.0) -> Float64

Approximate log marginal likelihood for single-attractor model.
Uses Laplace approximation.
"""
function log_marginal_likelihood_single(
    attractors::Vector{Vector{Float64}};
    σ_μ::Float64=10.0,
    α_τ::Float64=2.0,
    β_τ::Float64=1.0
)::Float64
    n = length(attractors)
    d = length(attractors[1])

    # MLE estimates
    μ_hat = mean(attractors)
    residuals = [a - μ_hat for a in attractors]
    τ²_hat = mean(sum.(r.^2 for r in residuals)) / d

    # Log likelihood at MLE
    log_lik = -0.5 * n * d * log(2π * τ²_hat) - 0.5 * n * d

    # Log prior (at MLE)
    log_prior_μ = -0.5 * d * log(2π * σ_μ^2) - 0.5 * sum(μ_hat.^2) / σ_μ^2
    log_prior_τ = -α_τ * log(τ²_hat) - β_τ / τ²_hat  # InvGamma

    # Laplace approximation (ignore Hessian correction for simplicity)
    log_lik + log_prior_μ + log_prior_τ
end

"""
    log_marginal_likelihood_null(attractors::Vector{Vector{Float64}}; α_σ=2.0, β_σ=1.0) -> Float64

Approximate log marginal likelihood for null model (no structure).
"""
function log_marginal_likelihood_null(
    attractors::Vector{Vector{Float64}};
    α_σ::Float64=2.0,
    β_σ::Float64=1.0
)::Float64
    n = length(attractors)
    d = length(attractors[1])

    # MLE for variance
    σ²_hat = mean(sum.(a.^2 for a in attractors)) / d

    # Log likelihood
    log_lik = -0.5 * n * d * log(2π * σ²_hat) - 0.5 * n * d

    # Log prior
    log_prior = -α_σ * log(σ²_hat) - β_σ / σ²_hat

    log_lik + log_prior
end

"""
    bayes_factor(attractors::Vector{Vector{Float64}}) -> NamedTuple

Compute Bayes factor comparing single-attractor model to null model.
BF > 1 favors single-attractor model.
"""
function bayes_factor(attractors::Vector{Vector{Float64}})
    if length(attractors) < 3
        return (
            log_bf = NaN,
            bf = NaN,
            interpretation = "Insufficient data"
        )
    end

    log_ml_single = log_marginal_likelihood_single(attractors)
    log_ml_null = log_marginal_likelihood_null(attractors)

    log_bf = log_ml_single - log_ml_null
    bf = exp(log_bf)

    interpretation = if log_bf > 5
        "Very strong evidence for single attractor"
    elseif log_bf > 3
        "Strong evidence for single attractor"
    elseif log_bf > 1
        "Positive evidence for single attractor"
    elseif log_bf > -1
        "Inconclusive"
    elseif log_bf > -3
        "Positive evidence for null (no structure)"
    else
        "Strong evidence for null (no structure)"
    end

    (log_bf = log_bf, bf = bf, interpretation = interpretation)
end

# ============================================================================
# Complete Analysis Pipeline
# ============================================================================

"""
    analyze_experiment(runs::Vector{ExperimentRun}) -> Dict{String, Any}

Run complete statistical analysis on experimental runs.
"""
function analyze_experiment(runs::Vector{ExperimentRun})::Dict{String, Any}
    results = Dict{String, Any}()

    # Extract attractors
    attractors = [r.final_attractor for r in runs if r.final_attractor !== nothing]

    if isempty(attractors)
        results["error"] = "No converged runs found"
        return results
    end

    results["n_runs"] = length(runs)
    results["n_converged"] = length(attractors)
    results["convergence_rate"] = length(attractors) / length(runs)

    # Test for single attractor vs null
    bf_result = bayes_factor(attractors)
    results["bayes_factor"] = bf_result

    # Group by seed for reproducibility analysis
    seed_groups = Dict{UInt64, Vector{Vector{Float64}}}()
    for run in runs
        if run.final_attractor !== nothing
            if !haskey(seed_groups, run.seed)
                seed_groups[run.seed] = Vector{Float64}[]
            end
            push!(seed_groups[run.seed], run.final_attractor)
        end
    end

    # ICC for reproducibility
    groups_with_multiple = [g for g in values(seed_groups) if length(g) >= 2]
    if !isempty(groups_with_multiple)
        icc = intraclass_correlation(groups_with_multiple)
        results["icc"] = icc
        results["icc_interpretation"] = if icc > 0.9
            "Excellent reproducibility"
        elseif icc > 0.75
            "Good reproducibility"
        elseif icc > 0.5
            "Moderate reproducibility"
        else
            "Poor reproducibility"
        end
    end

    # Model comparison if multiple models
    model_groups = Dict{String, Vector{Vector{Float64}}}()
    for run in runs
        if run.final_attractor !== nothing
            if !haskey(model_groups, run.model)
                model_groups[run.model] = Vector{Float64}[]
            end
            push!(model_groups[run.model], run.final_attractor)
        end
    end

    if length(model_groups) >= 2
        models = collect(keys(model_groups))
        d = cohens_d(model_groups[models[1]], model_groups[models[2]])
        results["cross_model_cohens_d"] = d
        results["cross_model_interpretation"] = if d < 0.2
            "Negligible difference between models"
        elseif d < 0.5
            "Small difference between models"
        elseif d < 0.8
            "Medium difference between models"
        else
            "Large difference between models"
        end
    end

    results
end

# ============================================================================
# Reporting
# ============================================================================

"""
    generate_report(results::Dict{String, Any}) -> String

Generate human-readable report from analysis results.
"""
function generate_report(results::Dict{String, Any})::String
    report = """
    ═══════════════════════════════════════════════════════════════════
    THE JEFF PARADOX: STATISTICAL ANALYSIS REPORT
    ═══════════════════════════════════════════════════════════════════

    EXPERIMENT SUMMARY
    ──────────────────
    Total runs: $(get(results, "n_runs", "N/A"))
    Converged runs: $(get(results, "n_converged", "N/A"))
    Convergence rate: $(round(get(results, "convergence_rate", 0.0) * 100, digits=1))%

    """

    if haskey(results, "bayes_factor")
        bf = results["bayes_factor"]
        report *= """
        HYPOTHESIS TESTING: ATTRACTOR EXISTENCE
        ───────────────────────────────────────
        Bayes Factor (single vs null): $(round(bf.bf, digits=2))
        Log Bayes Factor: $(round(bf.log_bf, digits=2))
        Interpretation: $(bf.interpretation)

        """
    end

    if haskey(results, "icc")
        report *= """
        SEED REPRODUCIBILITY
        ────────────────────
        Intraclass Correlation: $(round(results["icc"], digits=3))
        Interpretation: $(results["icc_interpretation"])

        """
    end

    if haskey(results, "cross_model_cohens_d")
        report *= """
        MODEL INVARIANCE
        ────────────────
        Cohen's d (cross-model): $(round(results["cross_model_cohens_d"], digits=2))
        Interpretation: $(results["cross_model_interpretation"])

        """
    end

    report *= """
    ═══════════════════════════════════════════════════════════════════
    """

    report
end
