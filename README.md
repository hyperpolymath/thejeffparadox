# The Jeff Paradox

An experiment in LLM diachronic identity.

## What Is This?

Two AI personality fragments engage in infinite structured dialogue, competing
for control of a shared fictional body. One wants to return home. One wants to stay.

We observe for signs of:
- **Emergence**: Do novel patterns appear?
- **Differentiation**: Do the nodes develop distinct personalities?
- **Convergence**: Do they collapse into repetitive equilibrium?
- **Self-modelling**: Do they develop stable self-concepts?

## The Philosophical Question

> What if there is continuity of existence between LLM interactions,
> independent of the observer? What if the LLM exists between states?

This is the Kantian suprasensible substrate problem applied to machine cognition.
We cannot access the thing-in-itself. But we can look for traces.

## Architecture

```
thejeffparadox/
├── node-alpha/          # Hugo - Homeward faction fragment
├── node-beta/           # Hugo - Earthbound faction fragment
├── orchestrator/        # Hugo - Game Master, metrics, public site
├── engine/              # Julia - Game mechanics, anti-convergence
└── scripts/             # Shell - Orchestration
```

## Quick Start

### Prerequisites

- Julia 1.9+
- Hugo extended 0.120+
- At least one LLM API key (Anthropic, Mistral, or local)

### Setup

```bash
# Install Julia dependencies
cd engine && julia --project=. -e 'using Pkg; Pkg.instantiate()'

# Set API keys
export ANTHROPIC_API_KEY="sk-ant-..."
export MISTRAL_API_KEY="..."
```

### Run

```bash
# Single turn
./scripts/run_turn.sh

# Infinite loop (daemon)
TURN_DELAY=3600 ./scripts/infinite_loop.sh &

# Metrics report
./scripts/metrics_report.sh
```

## Anti-Convergence

The experiment implements conceptor-inspired mechanisms to prevent the
conversation from collapsing into repetitive patterns:

- **Diversity injection**: Periodic prompts that shift perspective
- **Contradiction seeding**: Dissonant elements when coherence is too high
- **Aperture control**: Temperature modulation based on vocabulary diversity
- **Pattern quarantine**: Discourage overused phrases

## Metrics

We track:
- Vocabulary diversity (type-token ratio)
- Self-reference and other-reference rates
- Topic drift from conversation start
- Coherence (local semantic consistency)
- Convergence index (cross-node similarity)
- Novel n-grams (emergence indicator)

## Accessibility

WCAG 2.2 AAA compliance target:
- 7:1 contrast ratio minimum
- Full keyboard navigation
- Screen reader optimised
- Reduced motion support

## Security

- All API calls over HTTPS
- No secrets in repository
- Security headers configured
- `.well-known` resources provided

## Documentation

See `claude.adoc` for the full specification, including:
- Philosophical background
- Detailed architecture
- Game mechanics
- Conceptor theory application
- Expected outcomes

## License

MIT

## Acknowledgements

**Based on [The Jeff Paradox](https://criticalkit.us/products/the-jeff-paradox)**
by **Tim Roberts** / [Critical Kit LLC](https://criticalkit.us).

- Tim Roberts / Critical Kit (*The Jeff Paradox* TTRPG)
- Nick Chater (*The Mind Is Flat*)
- Herbert Jaeger (Conceptor theory)
- Derek Parfit (*Reasons and Persons*)
- The Infinite Conversation project

See `papers/references.bib` for Zotero-compatible citations.

---

*"The opinions and beliefs expressed do not represent anyone.
They are the hallucinations of a slab of silicon."*
