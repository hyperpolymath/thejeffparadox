# Methodological Validity Framework for The Jeff Paradox

## A Systematic Assessment of Internal, External, and Construct Validity

---

## 1. Overview

This document provides a systematic evaluation of validity threats and mitigations for The Jeff Paradox experiment. We follow the classical validity taxonomy (Campbell & Stanley, 1963; Cook & Campbell, 1979) adapted for computational experiments involving large language models.

**Validity Types Addressed:**
- **Internal Validity**: Can observed effects be attributed to the experimental manipulation?
- **External Validity**: Do results generalize beyond the specific experimental conditions?
- **Construct Validity**: Does the experiment actually measure "personality" as theoretically defined?
- **Statistical Conclusion Validity**: Are the statistical inferences sound?

---

## 2. Internal Validity

Internal validity concerns whether the observed relationship between variables reflects a true causal relationship or is contaminated by confounds.

### 2.1 Threat: History Effects

**Description**: Events occurring between measurements that affect the outcome.

**Specific Risks**:
- LLM API updates during experiment
- Provider rate limit changes
- Model fine-tuning or safety updates
- Network latency variations

**Mitigation**:
| Risk | Mitigation | Implementation |
|------|------------|----------------|
| API updates | Version lock where possible | Record model version in each turn |
| Rate limits | Graceful backoff | Exponential retry with logging |
| Model updates | Checkpoint before/after known updates | Monitor provider changelogs |
| Network issues | Log all latencies | Include timing in SamplePoint |

**Assessment**: Partially controllable. Major model updates are observable; minor changes may be invisible.

### 2.2 Threat: Maturation

**Description**: Natural changes in subjects over time.

**Specific Risks**:
- Context window effects (model "forgets" earlier turns)
- Embedding space drift as context grows
- Cumulative prompt length effects

**Mitigation**:
```julia
# Context window management
const MAX_CONTEXT_TURNS = 20  # Never include more than 20 recent turns
const CONTEXT_STRATEGY = :sliding_window  # Not full history

function build_context(game, window=MAX_CONTEXT_TURNS)
    recent = game.turn_history[max(1, end-window+1):end]
    # ...
end
```

**Assessment**: Well-controlled through fixed context window.

### 2.3 Threat: Testing Effects

**Description**: Prior measurements affect subsequent measurements.

**Specific Risks**:
- Embedding calls during experiment affect model state (N/A - separate models)
- Metrics computation alters game state

**Mitigation**: Metrics computation is read-only; embeddings use separate API calls.

**Assessment**: Low risk.

### 2.4 Threat: Instrumentation

**Description**: Changes in measurement instruments.

**Specific Risks**:
- Embedding model updates
- Temperature sampling variations
- Tokenizer changes

**Mitigation**:
```yaml
# Lock versions in configuration
embedding_model: "nomic-embed-text-v1.5"
embedding_dimensions: 768
# Record exact model hash
```

**Assessment**: Controllable with version pinning.

### 2.5 Threat: Selection

**Description**: Systematic differences between comparison groups.

**Specific Risks**:
- Nodes initialized with different prompts
- Asymmetric faction goals
- Different LLM providers per node

**Mitigation**:
- Symmetric initialization (mirror node configurations)
- Randomized node assignment to factions
- Same LLM provider for both nodes in each run

**Assessment**: Well-controlled through design.

### 2.6 Threat: Experimental Mortality

**Description**: Differential dropout.

**Specific Risks**:
- API failures terminate one node
- Rate limits hit for one provider
- One node produces filter-triggering content

**Mitigation**:
- Symmetric error handling
- Retry logic identical for both nodes
- Log all failures with node attribution

**Assessment**: Moderate risk; logging enables detection.

### 2.7 Threat: Diffusion of Treatment

**Description**: Treatment conditions contaminate each other.

**Specific Risks**:
- Nodes share context (by design)
- GM narration influences both nodes

**Mitigation**: This is inherent to the experimental design (shared body premise). Analysis accounts for shared context.

**Assessment**: Not a threat—shared context is the phenomenon of interest.

---

## 3. External Validity

External validity concerns generalization beyond the specific experimental conditions.

### 3.1 Threat: Scenario Specificity

**Description**: Results may only apply to The Jeff Paradox narrative.

**Specific Risks**:
- Alien/science-fiction framing
- Specific faction goals
- Two-node structure

**Generalizability Questions**:
- Would results differ with a corporate scenario?
- What if there were three nodes?
- Does the "shared body" mechanic drive all results?

**Mitigation**:
```julia
# Scenario variants for replication
const SCENARIOS = [
    :jeff_paradox,      # Original
    :corporate_merger,  # Two departments sharing resources
    :family_estate,     # Siblings with competing inheritance goals
    :ai_council,        # Three AI systems sharing compute
]
```

**Assessment**: Requires explicit replication with scenario variants.

### 3.2 Threat: Provider Specificity

**Description**: Results may only apply to specific LLM providers.

**Specific Risks**:
- Anthropic Claude may behave differently than GPT-4
- Local models may lack personality consistency
- Fine-tuned models may show different dynamics

**Mitigation**:
```julia
# Multi-provider experiments
const EXPERIMENT_CONFIGS = [
    (alpha = "anthropic/claude-3-sonnet", beta = "anthropic/claude-3-sonnet"),
    (alpha = "mistral/mistral-large", beta = "mistral/mistral-large"),
    (alpha = "local/llama3-8b", beta = "local/llama3-8b"),
    # Cross-provider (if theoretically interesting)
    (alpha = "anthropic/claude-3-sonnet", beta = "mistral/mistral-large"),
]
```

**Assessment**: Requires explicit cross-provider experiments.

### 3.3 Threat: Temporal Validity

**Description**: Results may not replicate at different times.

**Specific Risks**:
- Models are updated frequently
- Training data cutoff affects "personality"
- Safety fine-tuning changes behavior

**Mitigation**:
- Record exact model versions
- Run replications after known updates
- Analyze effect of model generation

**Assessment**: Inherent limitation of LLM research; document thoroughly.

### 3.4 Threat: Scale Specificity

**Description**: Results at one scale may not apply at another.

**Specific Risks**:
- 1,000-turn results may not predict 100,000-turn behavior
- Attractor found at turn 5,000 may destabilize at turn 50,000

**Mitigation**:
- Log-scale sampling (more dense early, sparser late)
- Continue successful runs to maximum feasible length
- Report stability duration, not just presence

**Assessment**: Requires extended runs; acknowledge limitations.

---

## 4. Construct Validity

Construct validity concerns whether the operational measures actually capture the theoretical construct of "personality."

### 4.1 Threat: Inadequate Operationalization

**Description**: Measures may not capture the construct.

**Theoretical Definition of Personality**:
> Personality consists of stable patterns of behavior, cognition, and affect that persist across time and situations, distinguishing individuals from one another.

**Operational Definition**:
> Stable regions in embedding space toward which conversational trajectories converge.

**Gap Analysis**:

| Theoretical Element | Operational Measure | Gap |
|---------------------|---------------------|-----|
| Stable patterns | Embedding trajectory convergence | Embeddings capture semantics, not all behavior |
| Persist across time | ADF test for stationarity | Time defined as turns, not real time |
| Distinguishing individuals | Inter-node distance | Two nodes may not generalize to "individuals" |
| Behavior, cognition, affect | Text embeddings | Text may not capture internal states |

**Mitigation**:
- Multiple operationalizations (embedding + vocabulary + syntax)
- Explicit acknowledgment of construct limitations
- Avoid overclaiming ("stable embedding patterns" not "personality")

**Assessment**: Moderate gap; language carefully bounds claims.

### 4.2 Threat: Mono-Operation Bias

**Description**: Single operationalization may not capture full construct.

**Current Operations**:
1. Semantic embeddings (primary)

**Additional Operations** (recommended):
```julia
struct MultiModalMeasure
    embedding_centroid::Vector{Float64}    # Semantic
    vocabulary_fingerprint::Vector{Float64} # Lexical
    syntax_patterns::Vector{Float64}        # Structural
    topic_distribution::Vector{Float64}     # Thematic
    sentiment_trajectory::Vector{Float64}   # Affective
end
```

**Assessment**: Implement multiple measures before making personality claims.

### 4.3 Threat: Mono-Method Bias

**Description**: All measures use the same method.

**Current Method**: Automated text analysis

**Recommended Additional Methods**:
1. **Human rater judgment**: Blind rating of personality traits from transcripts
2. **Behavioral prediction**: Can attractor state predict future responses?
3. **Perturbation studies**: Does "personality" persist under intervention?

**Implementation**:
```julia
# Human validation protocol
struct HumanValidation
    rater_id::String
    transcript_sample::Vector{String}
    big_five_ratings::NamedTuple{(:O, :C, :E, :A, :N), NTuple{5, Float64}}
    consistency_rating::Float64  # 1-7 scale
    distinctiveness_rating::Float64
end
```

**Assessment**: Requires human study component for full construct validity.

### 4.4 Threat: Confounding Constructs

**Description**: Measured construct may be confounded with others.

**Potential Confounds**:

| Apparent Construct | Confound | Discrimination |
|-------------------|----------|----------------|
| Personality | Topic persistence | Control topics, measure residual stability |
| Personality | Prompt following | Vary prompts, measure invariance |
| Personality | Context effects | Compare same prompts in different contexts |
| Convergence | Vocabulary depletion | Track vocabulary growth, not just similarity |

**Mitigation**:
```julia
# Topic-controlled analysis
function compute_topic_residual_convergence(game, provider)
    # 1. Extract topic vectors
    topics_alpha = extract_topics(filter_node(game, :alpha))
    topics_beta = extract_topics(filter_node(game, :beta))

    # 2. Regress out topic effects
    residuals_alpha = regress_out(embeddings_alpha, topics_alpha)
    residuals_beta = regress_out(embeddings_beta, topics_beta)

    # 3. Compute convergence on residuals
    cosine_similarity(mean(residuals_alpha), mean(residuals_beta))
end
```

**Assessment**: Implement confound controls before publication.

### 4.5 Threat: Reactivity

**Description**: Measurement process affects the measured phenomenon.

**Specific Risks**:
- Anti-convergence mechanisms alter natural behavior
- Diversity injections create artificial differentiation
- Pattern quarantine prevents natural expression

**Mitigation**:
- Run parallel experiments with/without mechanisms
- Compare "natural" (uncontrolled) vs. "managed" runs
- Report both conditions transparently

**Assessment**: Design includes both conditions; analysis compares them.

---

## 5. Statistical Conclusion Validity

Statistical conclusion validity concerns whether the statistical analyses support valid conclusions.

### 5.1 Threat: Low Statistical Power

**Description**: Insufficient sample size to detect effects.

**Power Analysis** (from statistical_framework.md):

| Effect Size | Required n per group (α=0.05, power=0.80) |
|-------------|-------------------------------------------|
| d = 0.2 (small) | 393 |
| d = 0.5 (medium) | 64 |
| d = 0.8 (large) | 25 |

For multivariate (d=768 dimensions):
$$n_{mv} \approx n \cdot \sqrt{d} \approx 64 \cdot 28 \approx 1800$$

**Mitigation**:
- Dimensionality reduction (PCA) before testing
- Focus on effect size estimation, not just significance
- Report confidence intervals

**Assessment**: High-dimensional embedding space requires large samples or dimensionality reduction.

### 5.2 Threat: Violated Assumptions

**Description**: Statistical tests require assumptions that may not hold.

**Assumptions and Checks**:

| Test | Assumption | Check | Fallback |
|------|------------|-------|----------|
| ADF | No structural breaks | Chow test | Segmented analysis |
| Hotelling's T² | Multivariate normal | Mardia's test | Bootstrap T² |
| Bayes factors | Prior sensitivity | Prior robustness check | Report range |

**Implementation**:
```julia
function validate_assumptions(trajectory::Matrix{Float64})
    # 1. Normality (Mardia's test)
    mardia = mardias_test(trajectory)

    # 2. Stationarity (excluding trend)
    kpss = kpss_test(trajectory)

    # 3. Homoscedasticity
    breusch_pagan = bp_test(trajectory)

    ValidationResult(mardia, kpss, breusch_pagan)
end
```

**Assessment**: Implement assumption checks; use robust alternatives when violated.

### 5.3 Threat: Multiple Comparisons

**Description**: Testing many hypotheses inflates Type I error.

**Tests Conducted**:
1. Convergence (d dimensions × k runs)
2. Reproducibility (k₂ pairs)
3. Clustering (model comparison)
4. Model invariance (m models)

**Correction**:
- Bonferroni for convergence tests within run
- FDR (Benjamini-Hochberg) for cross-run comparisons
- Bayesian approach naturally handles multiplicity

**Assessment**: Correction methods specified; report both corrected and uncorrected.

### 5.4 Threat: Fishing and Error Rate Inflation

**Description**: Selective reporting of favorable results.

**Mitigation**:
1. **Pre-registration**: Specify hypotheses and analysis plan before running
2. **Transparency**: Report all runs, including failures
3. **Open data**: Publish all conversation transcripts and metrics
4. **Reproducible analysis**: All analysis scripts in repository

**Assessment**: Strong commitment to transparency mitigates this threat.

---

## 6. Validity Summary Matrix

| Threat Category | Threat | Severity | Mitigation Quality | Residual Risk |
|-----------------|--------|----------|-------------------|---------------|
| **Internal** | History | Medium | Medium (logging) | Medium |
| | Maturation | Low | High (fixed window) | Low |
| | Instrumentation | Medium | High (version lock) | Low |
| | Selection | Low | High (symmetric design) | Low |
| **External** | Scenario | High | Medium (variants planned) | Medium |
| | Provider | High | Medium (multi-provider) | Medium |
| | Temporal | High | Low (inherent) | High |
| | Scale | Medium | Medium (extended runs) | Medium |
| **Construct** | Operationalization | High | Medium (careful language) | Medium |
| | Mono-operation | High | Medium (multiple planned) | Medium |
| | Mono-method | High | Low (requires human study) | High |
| | Confounds | Medium | Medium (controls planned) | Medium |
| **Statistical** | Power | High | Medium (reduction/CI) | Medium |
| | Assumptions | Medium | High (checks + fallbacks) | Low |
| | Multiple comparisons | Medium | High (corrections) | Low |
| | Fishing | Medium | High (pre-registration) | Low |

---

## 7. Recommended Enhancements

### 7.1 Priority 1: Essential Before Publication

1. **Pre-registration**: Register hypotheses and analysis plan on OSF
2. **Multi-operationalization**: Add vocabulary and syntax measures
3. **Assumption validation**: Implement all statistical assumption checks
4. **Power analysis**: Run pilot to estimate effect sizes

### 7.2 Priority 2: Important for Strong Claims

1. **Scenario variants**: Run at least 2 alternative scenarios
2. **Cross-provider**: Run with 3+ LLM providers
3. **Human validation**: Expert ratings on transcript samples
4. **Confound controls**: Topic-residualized convergence analysis

### 7.3 Priority 3: Desirable for Comprehensive Validity

1. **Longitudinal replication**: Re-run after major model updates
2. **Perturbation studies**: Test personality stability under intervention
3. **Predictive validity**: Can attractor predict held-out responses?
4. **Cross-cultural**: Vary language/cultural context in scenarios

---

## 8. Reporting Checklist

When publishing results, report:

- [ ] Pre-registration link
- [ ] Full experimental configuration
- [ ] All runs attempted (including failures)
- [ ] Assumption check results
- [ ] Both corrected and uncorrected p-values
- [ ] Effect sizes with confidence intervals
- [ ] Limitations section addressing each validity threat
- [ ] Data and code availability statement

---

## References

Campbell, D. T., & Stanley, J. C. (1963). *Experimental and quasi-experimental designs for research*. Houghton Mifflin.

Cook, T. D., & Campbell, D. T. (1979). *Quasi-experimentation: Design and analysis issues for field settings*. Houghton Mifflin.

Shadish, W. R., Cook, T. D., & Campbell, D. T. (2002). *Experimental and quasi-experimental designs for generalized causal inference*. Houghton Mifflin.
