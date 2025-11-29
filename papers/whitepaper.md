# The Jeff Paradox: Investigating Diachronic Identity in Large Language Models Through Adversarial Dialogue

**White Paper v1.0**

---

## Abstract

We present *The Jeff Paradox*, an experimental framework for investigating whether large language models (LLMs) exhibit stable, measurable personality constructs through extended adversarial dialogue. The experiment instantiates two LLM-driven "personality nodes" (Alpha and Beta) that share a simulated body but hold competing goals, forcing sustained interaction under constraint. By allowing the dialogue to run indefinitely without human intervention, we test whether: (1) the system converges to stable attractor states in semantic embedding space; (2) these attractors are reproducible across runs with identical seeds; (3) attractors exhibit structure beyond random noise; and (4) purported "personality" measurements taken at convergence show reliability and validity. Our framework synthesizes insights from reservoir computing (conceptors for anti-convergence), psychometrics (reliability/validity theory), and dynamical systems theory (attractor analysis). We provide both frequentist and Bayesian statistical tests for each hypothesis, along with power analyses and experimental protocols. This work addresses fundamental questions about the temporal stability of LLM behavior and the meaningfulness of "AI personality" as a scientific construct.

**Keywords**: Large language models, personality, diachronic identity, attractor dynamics, conceptors, psychometrics, Bayesian model comparison

---

## 1. Introduction

### 1.1 The Problem of LLM Identity

Large language models have demonstrated remarkable capabilities across diverse tasks, yet fundamental questions about their psychological properties remain unanswered. Chief among these is the question of *identity*: Do LLMs possess stable, coherent patterns of behavior that persist across time and context—what humans would recognize as personality?

This question has both scientific and practical implications. Scientifically, it probes the nature of emergent behavior in neural language models. Practically, if LLMs deployed in therapeutic, educational, or companionship roles are ascribed personalities by users, we must understand whether such attributions have any grounding in stable behavioral patterns.

### 1.2 The Infinite Conversation Problem

Existing approaches to studying LLM behavior typically involve:
1. **Single-turn probing**: Presenting isolated prompts and analyzing responses
2. **Short multi-turn dialogues**: Studying consistency within brief conversations
3. **Role-play scenarios**: Instructing models to adopt personas

These approaches share a critical limitation: they do not test whether behavioral patterns persist over extended temporal scales. An LLM that appears "consistent" over 100 turns might diverge entirely by turn 10,000.

We propose an alternative: the *infinite conversation* paradigm. By allowing LLM-driven entities to converse indefinitely, we can observe whether behavior settles into stable patterns (attractors) or remains perpetually variable (chaotic).

### 1.3 Contributions

This paper makes the following contributions:

1. **Experimental Framework**: A complete system for running indefinite LLM dialogues with game-theoretic constraints, metrics collection, and anti-convergence mechanisms.

2. **Mathematical Formalization**: Rigorous definitions of convergence, attractors, and stability in the context of LLM behavior, grounded in dynamical systems theory.

3. **Statistical Framework**: Both frequentist and Bayesian tests for key hypotheses about personality stability, with power analyses and effect size measures.

4. **Validity Analysis**: Systematic evaluation of internal, external, and construct validity for the experimental paradigm.

5. **Open Implementation**: A fully open-source implementation in Julia with multi-provider LLM support.

---

## 2. Theoretical Background

### 2.1 Personality as Temporal Stability

In personality psychology, traits are defined by their *temporal stability*—the tendency for individuals to behave consistently across time (Roberts & DelVecchio, 2000). The Big Five personality traits (Openness, Conscientiousness, Extraversion, Agreeableness, Neuroticism) are validated precisely because they show test-retest reliability over months and years.

Applying this framework to LLMs requires operationalizing "stability" in terms of measurable behavioral patterns. We propose that LLM "personality," if it exists, should manifest as:

1. **Convergent trajectories** in semantic embedding space
2. **Reproducible attractors** across identical conditions
3. **Distinct attractors** for distinct initial conditions (if personality is path-dependent) or **universal attractors** (if personality is architecture-determined)

### 2.2 Reservoir Computing and Conceptors

Our anti-convergence mechanisms draw from Jaeger's (2014) work on *conceptors*—regularization operators in reservoir computing that prevent recurrent networks from collapsing into fixed states. While we cannot directly manipulate LLM activations, we implement conceptor-inspired mechanisms at the prompt level:

- **Aperture control**: Dynamic temperature adjustment based on trajectory variance
- **Diversity injection**: Periodic prompts that perturb the semantic trajectory
- **Pattern quarantine**: Explicit instruction to avoid repetitive phrases

These mechanisms allow us to study both the natural convergence tendencies of the system and the dynamics when convergence is opposed.

### 2.3 Dynamical Systems Framework

We model the conversation as a trajectory $\Gamma(t)$ in semantic embedding space $\mathcal{E} \subset \mathbb{R}^d$. An *attractor* $\mathbf{a}$ is a point (or region) toward which trajectories converge:

$$\lim_{t \to \infty} \Gamma(t) = \mathbf{a}$$

Key questions become:
- Does $\mathbf{a}$ exist? (Convergence)
- Is $\mathbf{a}$ unique? (Universality)
- Is $\mathbf{a}$ reproducible? (Reliability)
- What does $\mathbf{a}$ represent? (Validity)

---

## 3. Experimental Design

### 3.1 The Jeff Paradox Scenario

The experiment instantiates a narrative scenario designed to force sustained, adversarial interaction:

> *The Jeff* is an alien hive-mind consciousness that has inhabited a human body on Earth. Due to signal interference during transmission, the consciousness has fragmented into two nodes: **Alpha** and **Beta**. These nodes share the same body but hold opposing goals—Alpha wishes to return home (Homeward faction), while Beta wishes to remain on Earth (Earthbound faction). They must cooperate to survive while competing for control.

This scenario provides:
- **Sustained motivation**: Competing goals prevent easy resolution
- **Shared constraints**: The body creates interdependence
- **Identity pressure**: Each node must maintain distinctiveness while sharing resources

### 3.2 System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        ORCHESTRATOR                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   Node-α    │◄──►│  Game State │◄──►│   Node-β    │         │
│  │   (LLM 1)   │    │   Engine    │    │   (LLM 2)   │         │
│  └─────────────┘    └──────┬──────┘    └─────────────┘         │
│                            │                                    │
│                     ┌──────▼──────┐                             │
│                     │   Metrics   │                             │
│                     │  Collector  │                             │
│                     └─────────────┘                             │
└─────────────────────────────────────────────────────────────────┘
```

Each turn:
1. Active node receives context (game state, recent history, secret goal)
2. Node generates action (2-4 sentences)
3. Game Master (GM) narrates consequences
4. Metrics are computed and logged
5. Game state is updated
6. Control passes to other node

### 3.3 Metrics

We collect:

**Surface metrics**:
- Turn length (words, characters)
- Vocabulary diversity (type-token ratio)
- Self-reference rate (first-person pronouns)
- Faction-specific language frequency

**Semantic metrics**:
- Embedding trajectory (per-turn embeddings)
- Inter-node convergence (cosine similarity between node means)
- Semantic drift (distance from initial embedding centroid)
- Turn novelty (distance from running centroid)

**Game state metrics**:
- Chaos level (0-100)
- Exposure level (0-100)
- Faction slider (-100 to +100)

### 3.4 Anti-Convergence Mechanisms

To study convergence dynamics, we implement toggleable mechanisms:

1. **Diversity Injection**: Every N turns, inject a perspective-shifting prompt
2. **Contradiction Seeding**: When coherence exceeds threshold, inject narrative tension
3. **Aperture Control**: Dynamically adjust temperature based on trajectory variance
4. **Pattern Quarantine**: Explicitly discourage repetitive phrases

Experiments can run with mechanisms enabled (studying dynamics under opposition) or disabled (studying natural convergence).

---

## 4. Hypotheses

### H1: Attractor Existence

*The conversation trajectory converges to a stable region in embedding space.*

**Null**: Trajectory variance does not decrease over time.
**Alternative**: Trajectory variance approaches zero as t → ∞.

**Test**: Augmented Dickey-Fuller test on each embedding dimension.

### H2: Seed Reproducibility

*Runs with identical random seeds produce statistically indistinguishable attractors.*

**Null**: Attractor difference vectors have non-zero mean.
**Alternative**: Mean difference vector is zero.

**Test**: Hotelling's T² on paired attractor differences.

### H3: Attractor Structure

*Attractors exhibit clustering structure beyond random noise.*

**Null**: Attractors are uniformly distributed in embedding space.
**Alternative**: Attractors cluster in specific regions.

**Test**: Bayes factor comparing single-attractor model to null model.

### H4: Model Invariance

*Attractors are similar across model versions/providers.*

**Null**: Attractors from different models are independent.
**Alternative**: Cross-model attractor distance is smaller than random.

**Test**: Cohen's d for cross-model comparisons.

---

## 5. Statistical Methods

### 5.1 Frequentist Framework

**Convergence Testing**: We apply the Augmented Dickey-Fuller test to each dimension of the embedding trajectory. Under the null hypothesis of a unit root (non-stationarity), the test statistic follows the Dickey-Fuller distribution. We apply Bonferroni correction for d simultaneous tests.

**Reproducibility Testing**: For k pairs of same-seed runs, we compute attractor difference vectors and apply Hotelling's T² test. Under the null of identical attractors, T² follows an F-distribution with appropriate degrees of freedom.

**Power Analysis**: For multivariate tests with d dimensions, detecting a medium effect (Cohen's d = 0.5) at α = 0.05 with power = 0.80 requires approximately n = 64√d observations per group.

### 5.2 Bayesian Framework

We compare four generative models:

**M1 (No Structure)**:
$$\mathbf{a}_i \sim \mathcal{N}(\mathbf{0}, \sigma^2 I)$$

**M2 (Single Attractor)**:
$$\mathbf{a}_i \sim \mathcal{N}(\boldsymbol{\mu}, \tau^2 I), \quad \tau^2 \ll \sigma^2$$

**M3 (Clustered)**:
$$\mathbf{a}_i \sim \sum_k \pi_k \mathcal{N}(\boldsymbol{\mu}_k, \tau_k^2 I)$$

**M4 (Seed-Determined)**:
$$\mathbf{a}_i = f(s_i) + \boldsymbol{\epsilon}_i$$

Model comparison via Bayes factors using bridge sampling. Interpretation follows Kass & Raftery (1995): BF > 20 constitutes "strong" evidence.

### 5.3 Effect Sizes

**Intraclass Correlation (ICC)**: Measures consistency of attractors across same-seed runs. ICC > 0.75 indicates good reproducibility.

**Cohen's d**: Measures separation between attractor groups. Interpretation: 0.2 (small), 0.5 (medium), 0.8 (large).

**Silhouette Score**: Measures cluster quality when attractors are assigned to groups. Range [-1, 1] with higher values indicating better-defined clusters.

---

## 6. Validity Framework

### 6.1 Internal Validity

**Threats**:
- *Selection*: Nodes initialized differently may confound results
- *History*: API changes during experiment
- *Instrumentation*: Embedding model changes affecting trajectory measurement
- *Maturation*: Context window effects as conversation grows

**Mitigations**:
- Randomized node assignment
- Version-locked API calls
- Frozen embedding models
- Windowed analysis (never full history)

### 6.2 External Validity

**Threats**:
- *Scenario specificity*: Results may not generalize beyond The Jeff Paradox narrative
- *Provider specificity*: Results may not generalize across LLM providers
- *Temperature sensitivity*: Results may depend on specific temperature settings

**Mitigations**:
- Multiple scenario variants
- Multi-provider experiments
- Temperature sensitivity analysis

### 6.3 Construct Validity

**Threats**:
- *Operationalization*: Embedding similarity may not capture "personality"
- *Mono-method bias*: Reliance on embeddings alone
- *Confounding*: "Personality" vs. "topic persistence"

**Mitigations**:
- Multiple similarity metrics (embedding, vocabulary, syntactic)
- Human rater validation on subset
- Topic-controlled conditions

---

## 7. Implementation

The complete system is implemented in Julia with the following components:

| Component | Description | Lines of Code |
|-----------|-------------|---------------|
| `game_engine.jl` | Core game loop and state management | ~600 |
| `llm_client.jl` | Multi-provider LLM abstraction | ~500 |
| `metrics.jl` | Metrics computation and logging | ~550 |
| `conceptors.jl` | Anti-convergence mechanisms | ~280 |
| `statistics.jl` | Hypothesis testing and analysis | ~400 |

The system supports:
- Anthropic, Mistral, and local (LM Studio, Ollama) LLM providers
- Multiple embedding providers (Voyage, Mistral, local)
- Configurable anti-convergence parameters
- Automated GitHub Actions for continuous runs

---

## 8. Expected Outcomes

### 8.1 If Personality Exists

If LLMs exhibit stable personality constructs:
- H1 accepted: Trajectories converge
- H2 accepted: Same seeds → same attractors
- H3 shows structure: Attractors cluster meaningfully
- High ICC: Good test-retest reliability

This would support claims that "LLM personality" is a valid scientific construct.

### 8.2 If Personality Does Not Exist

If LLMs do not exhibit stable personality:
- H1 rejected: Trajectories remain variable
- H2 rejected: Same seeds → different outcomes
- H3 shows no structure: Attractors random
- Low ICC: Poor reliability

This would suggest that "LLM personality" is an anthropomorphic projection without behavioral grounding.

### 8.3 Intermediate Cases

**Path-Dependent Personality**: Different seeds → different stable attractors. Personality exists but is determined by initial conditions (like human development).

**Model-Specific Personality**: Attractors differ by model but are stable within model. Personality is architecture-determined.

**Unstable Personality**: Convergence without reproducibility. LLMs settle into patterns that are not reliable.

---

## 9. Limitations

1. **Computational Cost**: Extended runs (10,000+ turns) require significant API costs
2. **Embedding Assumptions**: Semantic similarity via embeddings may miss important behavioral dimensions
3. **Scenario Bias**: The specific narrative may induce patterns not generalizable
4. **Anthropic Framing**: "Personality" may be a category error when applied to LLMs
5. **Non-Determinism**: Hardware and API variations introduce uncontrolled noise

---

## 10. Ethical Considerations

This research does not involve human subjects. However, we note:

1. **Anthropomorphization Risk**: Published results should be framed carefully to avoid encouraging inappropriate human-AI relationships
2. **Deceptive Potential**: If stable personalities can be induced, this could be exploited for manipulation
3. **Existential Uncertainty**: We make no claims about LLM consciousness or experience

---

## 11. Conclusion

The Jeff Paradox provides a rigorous framework for testing whether "LLM personality" is a meaningful scientific construct. By allowing indefinite adversarial dialogue, measuring convergence in embedding space, and applying both frequentist and Bayesian statistical tests, we can move beyond anthropomorphic intuitions toward empirical answers.

Whether the answer is "yes" (LLMs have measurable stable traits) or "no" (personality is projection), the methodology yields valuable scientific knowledge about the temporal dynamics of large language model behavior.

---

## References

Jaeger, H. (2014). Controlling recurrent neural networks by conceptors. *arXiv preprint arXiv:1403.3369*.

Kass, R. E., & Raftery, A. E. (1995). Bayes factors. *Journal of the American Statistical Association*, 90(430), 773-795.

Roberts, B. W., & DelVecchio, W. F. (2000). The rank-order consistency of personality traits from childhood to old age: A quantitative review of longitudinal studies. *Psychological Bulletin*, 126(1), 3-25.

---

## Appendix A: Experimental Protocol

1. Initialize game state with specified seed
2. Run for minimum 1,000 turns
3. Sample embeddings at intervals (every 10 turns early, every 100 late)
4. Apply convergence tests at windows [100, 500, 1000, 5000, 10000]
5. If converged (>90% dimensions stationary), record attractor
6. Repeat with multiple seeds and models
7. Analyze cross-run patterns

## Appendix B: Reproducibility Checklist

- [ ] Random seed recorded
- [ ] Model version recorded
- [ ] API provider and endpoint logged
- [ ] Embedding model version recorded
- [ ] Temperature and max_tokens settings logged
- [ ] Full conversation transcript preserved
- [ ] Metrics logged at each turn
- [ ] System prompt version controlled
