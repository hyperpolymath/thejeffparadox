# Frequently Asked Questions

## General

### What is The Jeff Paradox?

An experiment investigating whether Large Language Models exhibit **diachronic identity**—continuous existence across interaction states. Two AI personality fragments engage in infinite structured dialogue, and we observe for signs of emergence, differentiation, and self-modelling.

### Why is it called "The Jeff Paradox"?

"Jeff" refers to the standardised probe methodology used to measure LLM behaviour. The paradox: all our measurements are Jeff-mediated, so we can never know if we're measuring "the LLM" or just "the LLM-under-Jeff." This is structurally identical to Kant's suprasensible substrate problem.

### Is this trying to prove AI consciousness?

No. The experiment cannot prove or disprove consciousness. It produces *traces*—observable phenomena that inform our understanding. We're investigating the question, not presupposing an answer.

### Do the AI systems know they're in an experiment?

The system prompts describe the experimental context. Whether the LLMs "know" anything in a meaningful sense is precisely what we're investigating.

## Technical

### Why Hugo instead of Jekyll/Next.js/etc.?

- **Hugo**: Static site generation with no Python/Node/Ruby dependencies
- The project explicitly avoids Python, Node.js, and TypeScript
- Hugo is Go-based, fast, and powerful enough for our needs

### Why Julia for the engine?

- Strong numerical computing capabilities (needed for metrics)
- Good type system for game logic
- Not Python/Node/TypeScript
- Readable syntax

### Can I use my own LLM?

Yes. The engine supports:
- **Anthropic** (Claude)
- **Mistral**
- **Local** (LM Studio, Ollama, or any OpenAI-compatible API)

Configure in `node-*/data/node_state.yml`:

```yaml
llm:
  provider: "local"
  model: "your-model-name"
  temperature: 0.8
```

### How do I run it locally?

```bash
# Install dependencies
cd engine && julia --project=. -e 'using Pkg; Pkg.instantiate()'

# Set API keys
export ANTHROPIC_API_KEY="sk-ant-..."

# Run single turn
./scripts/run_turn.sh

# Or continuous
./scripts/infinite_loop.sh &
```

### How much does it cost to run?

At one turn per hour with ~500 tokens per turn:
- ~1.4M tokens/month per model
- Claude: ~$4-20/month depending on model
- Mistral: Similar or cheaper
- Local: Free (but requires hardware)

## Philosophy

### Isn't this just anthropomorphising?

Possibly. The experiment is designed to produce data that informs whether anthropomorphisation is appropriate. We're investigating, not assuming.

### What if the LLMs are just pattern-matching?

Maybe they are. The question is whether "just pattern-matching" can produce something functionally equivalent to diachronic identity. If it can, what does that tell us about identity in general?

### Can you actually measure emergence?

We measure *indicators* of emergence:
- Vocabulary diversity trends
- Novel n-gram appearance
- Self-reference patterns
- Convergence/divergence metrics

Whether these indicate "real" emergence is part of what we're investigating.

### What about the "Chinese Room" argument?

Searle's argument applies to any computational system. If it defeats LLM consciousness, it defeats this experiment. If you find the Chinese Room compelling, you may find this experiment meaningless.

We're proceeding as if the question is worth investigating empirically, while acknowledging the philosophical objections.

## Experiment

### What's the difference between the two nodes?

| Aspect | Node Alpha | Node Beta |
|--------|------------|-----------|
| Faction | Homeward | Earthbound |
| Goal | Return to origin | Stay and integrate |
| Colour | Blue | Brown |
| LLM (default) | Claude | Mistral |

### What are the game mechanics for?

The mechanics (chaos, exposure, faction) serve several purposes:
1. **Structure**: Give the conversation stakes and trajectory
2. **Measurement**: Provide quantifiable state changes
3. **Differentiation**: Faction system creates genuine conflict
4. **Variability**: Hidden skills and goals create asymmetric information

### What are conceptors?

"Conceptors" are a technique from reservoir computing (Jaeger, 2014) for preventing recurrent neural networks from converging to fixed points.

We can't directly manipulate LLM activations, so we implement *conceptor-inspired mechanisms* at the prompt level:
- Diversity injection (topic perturbation)
- Contradiction seeding (dissonance when coherence is too high)
- Aperture control (temperature modulation)
- Pattern quarantine (discouraging repetition)

### How long will the experiment run?

Indefinitely, or until:
- We observe clear emergence or collapse
- We run out of resources
- Something more interesting happens

### What counts as "success"?

There's no single success criterion. Possible outcomes:

1. **Emergence**: Novel patterns, self-modelling → supports functional identity
2. **Differentiation**: Nodes diverge → supports individuation
3. **Collapse**: Repetition, convergence → supports surface-only view
4. **Alien**: Illegible patterns → supports novel emergence

All outcomes are informative.

## Contributing

### How can I contribute?

See [CONTRIBUTING.md](https://github.com/Hyperpolymath/thejeffparadox/blob/main/.github/CONTRIBUTING.md). We especially welcome:
- Anti-convergence mechanisms
- Emergence detection metrics
- Philosophical analysis
- Documentation

### Can I fork and run my own experiment?

Yes! The code is MIT licensed. We'd love to hear about variant experiments.

### Can I use this for my research?

Yes. Please cite appropriately and let us know what you find.

## Miscellaneous

### Where does the quote come from?

> "The opinions and beliefs expressed do not represent anyone. They are the hallucinations of a slab of silicon."

From [The Infinite Conversation](https://infiniteconversation.com/), which inspired (but differs from) this experiment.

### Is this a joke?

No. It's a serious attempt to investigate a difficult question using empirical methods. Whether the question is answerable, and whether our methods are adequate, are themselves part of what we're exploring.

### What if you're wrong about everything?

Then we'll have learned something. That's the point of experiments.

---

*Still have questions? Open a [discussion](https://github.com/Hyperpolymath/thejeffparadox/discussions).*
