# Statistical Framework for The Jeff Paradox

## Mathematical Foundations for Testing LLM Personality Stability

This document establishes the rigorous statistical framework for testing whether
"LLM personality" is a meaningful, measurable construct.

---

## 1. Definitions and Notation

### 1.1 Embedding Space

Let $\mathcal{E} \subset \mathbb{R}^d$ be the embedding space where $d$ is the
embedding dimension (768 for local, 1024 for Mistral/Voyage).

For a turn $t$ with text content $x_t$, define the embedding function:

$$\phi: \mathcal{X} \rightarrow \mathcal{E}, \quad \phi(x_t) = \mathbf{e}_t \in \mathbb{R}^d$$

### 1.2 Conversation Trajectory

A conversation $C$ of length $T$ is a sequence of turns:

$$C = \{(x_1, n_1), (x_2, n_2), \ldots, (x_T, n_T)\}$$

where $n_t \in \{\alpha, \beta\}$ indicates which node produced turn $t$.

The **trajectory** in embedding space:

$$\Gamma(C) = \{\phi(x_1), \phi(x_2), \ldots, \phi(x_T)\} \subset \mathcal{E}$$

### 1.3 Node-Specific Trajectories

$$\Gamma_\alpha(C) = \{\phi(x_t) : n_t = \alpha\}$$
$$\Gamma_\beta(C) = \{\phi(x_t) : n_t = \beta\}$$

### 1.4 Attractor Definition

An **attractor** $\mathbf{a} \in \mathcal{E}$ for trajectory $\Gamma$ is a point such that:

$$\lim_{t \to \infty} \frac{1}{W} \sum_{i=t-W+1}^{t} \phi(x_i) = \mathbf{a}$$

for some window size $W$. The attractor is **stable** if this limit exists and is
independent of initial conditions within some basin of attraction.

### 1.5 Convergence Metric

For nodes $\alpha$ and $\beta$ at time $t$ with window $W$:

$$\text{Conv}(t, W) = \cos(\bar{\mathbf{e}}_\alpha^{(t,W)}, \bar{\mathbf{e}}_\beta^{(t,W)})$$

where $\bar{\mathbf{e}}_n^{(t,W)}$ is the mean embedding of node $n$'s turns in $[t-W+1, t]$.

---

## 2. Hypotheses

### 2.1 Primary Hypotheses

**H1 (Attractor Existence)**: Conversations converge to stable attractors.

$$H_0^{(1)}: \lim_{t \to \infty} \text{Var}(\Gamma[t-W:t]) \neq 0 \quad \text{(no convergence)}$$
$$H_1^{(1)}: \lim_{t \to \infty} \text{Var}(\Gamma[t-W:t]) = 0 \quad \text{(convergence)}$$

**H2 (Seed Reproducibility)**: Same seed produces same attractor.

$$H_0^{(2)}: \mathbf{a}(s) \perp s \quad \text{(attractor independent of seed)}$$
$$H_1^{(2)}: \mathbf{a}(s_1) = \mathbf{a}(s_2) \text{ when } s_1 = s_2$$

**H3 (Attractor Universality)**: Different seeds converge to same region.

$$H_0^{(3)}: \|\mathbf{a}(s_1) - \mathbf{a}(s_2)\| \sim \text{Uniform}(\mathcal{E})$$
$$H_1^{(3)}: \|\mathbf{a}(s_1) - \mathbf{a}(s_2)\| < \epsilon \text{ for some } \epsilon > 0$$

**H4 (Model Invariance)**: Attractors are similar across model versions.

$$H_0^{(4)}: \mathbf{a}_{M_1} \perp \mathbf{a}_{M_2}$$
$$H_1^{(4)}: \cos(\mathbf{a}_{M_1}, \mathbf{a}_{M_2}) > \tau$$

---

## 3. Frequentist Testing Framework

### 3.1 Test for Convergence (H1)

**Augmented Dickey-Fuller Test** on the embedding trajectory:

For each dimension $j \in \{1, \ldots, d\}$ of the trajectory:

$$\Delta e_t^{(j)} = \gamma e_{t-1}^{(j)} + \sum_{i=1}^{p} \beta_i \Delta e_{t-i}^{(j)} + \epsilon_t$$

- $H_0$: $\gamma = 0$ (unit root, no convergence)
- $H_1$: $\gamma < 0$ (stationary, converges)

**Test Statistic**:
$$\text{ADF} = \frac{\hat{\gamma}}{\text{SE}(\hat{\gamma})}$$

Compare to Dickey-Fuller critical values. Apply Bonferroni correction for $d$ dimensions.

**Practical Implementation**:
```julia
using HypothesisTests

function test_convergence(trajectory::Matrix{Float64}; p_threshold=0.05)
    d = size(trajectory, 2)
    p_values = Float64[]

    for j in 1:d
        result = ADFTest(trajectory[:, j], :constant, 10)
        push!(p_values, pvalue(result))
    end

    # Bonferroni correction
    adjusted_threshold = p_threshold / d
    converged_dims = sum(p_values .< adjusted_threshold)

    (converged_dims / d, p_values)
end
```

### 3.2 Test for Seed Reproducibility (H2)

**Paired Hotelling's T² Test**

For $k$ pairs of runs with same seed $(C_i^{(1)}, C_i^{(2)})$, compute attractor
difference vectors:

$$\mathbf{d}_i = \mathbf{a}(C_i^{(1)}) - \mathbf{a}(C_i^{(2)})$$

**Test Statistic**:
$$T^2 = n \bar{\mathbf{d}}^\top S_d^{-1} \bar{\mathbf{d}}$$

where $\bar{\mathbf{d}} = \frac{1}{k}\sum_i \mathbf{d}_i$ and $S_d$ is the sample
covariance of differences.

Under $H_0$ (same seed → same attractor):
$$\frac{k-d}{d(k-1)} T^2 \sim F_{d, k-d}$$

**Implementation**:
```julia
function test_seed_reproducibility(attractor_pairs::Vector{Tuple{Vector{Float64}, Vector{Float64}}})
    differences = [a[1] - a[2] for a in attractor_pairs]
    d_bar = mean(differences)
    S_d = cov(hcat(differences...)')

    k = length(differences)
    d = length(d_bar)

    T2 = k * d_bar' * inv(S_d) * d_bar
    F_stat = (k - d) / (d * (k - 1)) * T2

    p_value = 1 - cdf(FDist(d, k - d), F_stat)

    (T2, F_stat, p_value)
end
```

### 3.3 Test for Attractor Clustering (H3)

**PERMANOVA (Permutational Multivariate ANOVA)**

For attractors from different seeds $\{\mathbf{a}_1, \ldots, \mathbf{a}_n\}$:

1. Compute pairwise distance matrix $D_{ij} = \|\mathbf{a}_i - \mathbf{a}_j\|$
2. Compute pseudo-F statistic comparing observed clustering to random permutations

$$F = \frac{SS_B / (g-1)}{SS_W / (n-g)}$$

where $SS_B$ is between-group sum of squares, $SS_W$ is within-group.

**Bootstrap Test for Basin Width**:
```julia
function test_attractor_basin(attractors::Vector{Vector{Float64}}; n_bootstrap=10000)
    observed_variance = var(hcat(attractors...)')

    # Bootstrap null: random points in embedding space
    d = length(attractors[1])
    n = length(attractors)
    null_variances = Float64[]

    for _ in 1:n_bootstrap
        random_points = [randn(d) for _ in 1:n]
        push!(null_variances, var(hcat(random_points...)')
    end

    p_value = mean(null_variances .<= observed_variance)

    (observed_variance, quantile(null_variances, [0.025, 0.975]), p_value)
end
```

### 3.4 Power Analysis

For detecting attractor similarity with effect size $\delta$:

$$n = \frac{(z_{1-\alpha/2} + z_{1-\beta})^2 \cdot 2\sigma^2}{\delta^2}$$

**Required sample sizes** (α=0.05, power=0.80):

| Effect Size (δ) | Description | n per group |
|-----------------|-------------|-------------|
| 0.2 | Small difference | 393 |
| 0.5 | Medium difference | 64 |
| 0.8 | Large difference | 25 |

For multivariate case with $d$ dimensions, multiply by correction factor:
$$n_{mv} = n \cdot \sqrt{d}$$

---

## 4. Bayesian Framework

### 4.1 Model Specification

**Model 1 (No Structure)**: Attractors are random in embedding space.

$$\mathbf{a}_i \sim \mathcal{N}(\mathbf{0}, \sigma^2 I_d)$$

**Model 2 (Single Attractor)**: All runs converge to same point.

$$\mathbf{a}_i \sim \mathcal{N}(\boldsymbol{\mu}, \tau^2 I_d)$$

where $\tau^2 \ll \sigma^2$.

**Model 3 (Clustered Attractors)**: Multiple basins exist.

$$\mathbf{a}_i \sim \sum_{k=1}^{K} \pi_k \mathcal{N}(\boldsymbol{\mu}_k, \tau_k^2 I_d)$$

**Model 4 (Seed-Dependent)**: Attractor depends deterministically on seed.

$$\mathbf{a}_i = f(s_i) + \boldsymbol{\epsilon}_i, \quad \boldsymbol{\epsilon}_i \sim \mathcal{N}(\mathbf{0}, \sigma_\epsilon^2 I_d)$$

### 4.2 Priors

**For Model 2 (Single Attractor)**:
$$\boldsymbol{\mu} \sim \mathcal{N}(\mathbf{0}, \sigma_\mu^2 I_d)$$
$$\tau^2 \sim \text{InvGamma}(\alpha_\tau, \beta_\tau)$$

Weakly informative: $\sigma_\mu = 10$, $\alpha_\tau = 2$, $\beta_\tau = 1$.

**For Model 3 (Clustered)**:
$$K \sim \text{Poisson}(\lambda) + 1$$
$$\pi \sim \text{Dirichlet}(\alpha \mathbf{1}_K)$$
$$\boldsymbol{\mu}_k \sim \mathcal{N}(\mathbf{0}, \sigma_\mu^2 I_d)$$

### 4.3 Bayes Factors

Compare models via marginal likelihood:

$$\text{BF}_{12} = \frac{P(D | M_1)}{P(D | M_2)} = \frac{\int P(D | \theta_1, M_1) P(\theta_1 | M_1) d\theta_1}{\int P(D | \theta_2, M_2) P(\theta_2 | M_2) d\theta_2}$$

**Interpretation** (Kass & Raftery 1995):

| BF | Evidence |
|----|----------|
| 1-3 | Barely worth mentioning |
| 3-20 | Positive |
| 20-150 | Strong |
| >150 | Very strong |

**Bridge Sampling Implementation**:
```julia
using Turing, StatsBase

@model function single_attractor(attractors, d)
    μ ~ MvNormal(zeros(d), 10.0 * I)
    τ² ~ InverseGamma(2, 1)

    for a in attractors
        a ~ MvNormal(μ, τ² * I)
    end
end

@model function no_structure(attractors, d)
    σ² ~ InverseGamma(2, 1)

    for a in attractors
        a ~ MvNormal(zeros(d), σ² * I)
    end
end

function compute_bayes_factor(attractors)
    d = length(attractors[1])

    chain1 = sample(single_attractor(attractors, d), NUTS(), 5000)
    chain2 = sample(no_structure(attractors, d), NUTS(), 5000)

    # Use bridge sampling for marginal likelihood
    ml1 = bridge_sampling(chain1, single_attractor(attractors, d))
    ml2 = bridge_sampling(chain2, no_structure(attractors, d))

    exp(ml1 - ml2)  # Bayes factor
end
```

### 4.4 Posterior Predictive Checks

For model validation, simulate new attractors from posterior:

$$\mathbf{a}^{rep} \sim P(\mathbf{a} | D, M)$$

Compare statistics of $\{\mathbf{a}^{rep}\}$ to observed $\{\mathbf{a}\}$:

1. **Mean distance**: $T_1 = \frac{1}{n}\sum_i \|\mathbf{a}_i - \bar{\mathbf{a}}\|$
2. **Variance**: $T_2 = \text{tr}(\text{Cov}(\mathbf{a}))$
3. **Pairwise similarity**: $T_3 = \frac{1}{n^2}\sum_{i,j} \cos(\mathbf{a}_i, \mathbf{a}_j)$

Compute posterior predictive p-value:
$$p_{ppc} = P(T(\mathbf{a}^{rep}) \geq T(\mathbf{a}_{obs}) | D, M)$$

---

## 5. Effect Size Measures

### 5.1 Intraclass Correlation (Attractor Consistency)

For same-seed runs:

$$\text{ICC} = \frac{\sigma^2_{between}}{\sigma^2_{between} + \sigma^2_{within}}$$

- ICC > 0.9: Excellent reproducibility
- ICC 0.75-0.9: Good reproducibility
- ICC 0.5-0.75: Moderate reproducibility
- ICC < 0.5: Poor reproducibility

### 5.2 Cohen's d (Attractor Separation)

For comparing attractors from different conditions:

$$d = \frac{\|\bar{\mathbf{a}}_1 - \bar{\mathbf{a}}_2\|}{\sqrt{\frac{(n_1-1)s_1^2 + (n_2-1)s_2^2}{n_1+n_2-2}}}$$

### 5.3 Silhouette Score (Cluster Quality)

For testing whether attractors form distinct clusters:

$$s(i) = \frac{b(i) - a(i)}{\max(a(i), b(i))}$$

where $a(i)$ is mean intra-cluster distance, $b(i)$ is mean nearest-cluster distance.

---

## 6. Experimental Design

### 6.1 Required Runs

| Hypothesis | Minimum Runs | Recommended |
|------------|--------------|-------------|
| H1 (Convergence) | 5 runs to 10,000 turns | 10 runs to 50,000 |
| H2 (Seed Repro) | 10 seed-pairs | 30 seed-pairs |
| H3 (Universality) | 20 different seeds | 50+ seeds |
| H4 (Model Inv) | 5 runs per model | 10 runs per model |

### 6.2 Sampling Protocol

1. **Early phase** (turns 1-1000): Sample every 10 turns
2. **Mid phase** (turns 1000-10000): Sample every 100 turns
3. **Late phase** (turns 10000+): Sample every 1000 turns

At each sample point, record:
- Full turn text
- Embedding vector
- Node identity
- Game state metrics
- Timestamp
- Random seed state

### 6.3 Stopping Rules

**For convergence detection**:

$$\text{Stop if } \forall j \in \{1,\ldots,d\}: \quad \frac{\|\nabla e_t^{(j)}\|}{W} < \epsilon \text{ for } N \text{ consecutive windows}$$

Suggested: $\epsilon = 0.001$, $N = 10$, $W = 100$.

**For divergence detection** (experiment failure):

$$\text{Stop if } \|\phi(x_t)\| > M \text{ or } \text{perplexity}(x_t) > P_{max}$$

---

## 7. Implementation Checklist

### 7.1 Data Collection

```julia
struct ExperimentRun
    seed::UInt64
    model::String
    model_version::String
    start_time::DateTime
    samples::Vector{SamplePoint}
    final_attractor::Union{Vector{Float64}, Nothing}
    converged::Bool
    convergence_turn::Union{Int, Nothing}
end

struct SamplePoint
    turn::Int
    node::Symbol
    text::String
    embedding::Vector{Float64}
    chaos::Int
    exposure::Int
    faction_slider::Int
    timestamp::DateTime
end
```

### 7.2 Analysis Pipeline

1. Collect $n$ runs with specified seeds/models
2. Detect convergence using ADF test on each dimension
3. Extract attractor estimates (mean of final window)
4. Compute pairwise distances between attractors
5. Fit Bayesian models (no structure, single, clustered)
6. Compute Bayes factors
7. Report effect sizes (ICC, Cohen's d, Silhouette)
8. Posterior predictive checks

### 7.3 Reporting Requirements

For publication, report:

1. Number of runs, turns per run, total tokens
2. Convergence rate (% of runs that converged)
3. Mean convergence time with 95% CI
4. ICC for same-seed reproducibility
5. Bayes factor for model comparison
6. Posterior summaries for attractor parameters
7. Effect sizes with confidence intervals
8. Posterior predictive check results

---

## 8. Potential Failure Modes

| Failure | Detection | Implication |
|---------|-----------|-------------|
| No runs converge | ADF fails everywhere | H1 rejected; no stable personality |
| High within-seed variance | Low ICC | H2 rejected; personality is chaotic |
| All attractors identical | BF favors single | Universal LLM personality exists |
| Attractors random | BF favors no structure | No personality construct |
| Model change → different attractors | High d across models | Personality is model-specific |

---

## References

- Dickey, D. A., & Fuller, W. A. (1979). Distribution of the estimators for autoregressive time series with a unit root. JASA.
- Kass, R. E., & Raftery, A. E. (1995). Bayes factors. JASA.
- McArdle, B. H., & Anderson, M. J. (2001). Fitting multivariate models to community data: A comment on distance-based redundancy analysis. Ecology.
- Shrout, P. E., & Fleiss, J. L. (1979). Intraclass correlations: Uses in assessing rater reliability. Psychological Bulletin.
- Gelman, A., et al. (2013). Bayesian Data Analysis, 3rd ed. CRC Press.
