# The Jeff Paradox

[![MPL-2.0](https://img.shields.io/badge/License-MPL_2.0-blue.svg)](https://opensource.org/licenses/MPL-2.0)
[![GitHub Stars](https://img.shields.io/github/stars/hyperpolymath/thejeffparadox.svg)](https://github.com/hyperpolymath/thejeffparadox/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/hyperpolymath/thejeffparadox.svg)](https://github.com/hyperpolymath/thejeffparadox/issues)

## Overview

**The Jeff Paradox** is an experiment in LLM diachronic identity. Two AI personality fragments (Alpha and Beta) engage in infinite structured dialogue, competing for control of a shared fictional body. One wants to return home. One wants to stay.

We observe for signs of **emergence**, **differentiation**, **convergence**, and **self-modelling** -- investigating whether LLMs can develop stable, reproducible personalities over time.

## Architecture

```
thejeffparadox/
├── engine/              # Julia - Game mechanics, LLM APIs, metrics, anti-convergence
├── node-alpha/          # Hugo - Homeward faction fragment
├── node-beta/           # Hugo - Earthbound faction fragment
├── orchestrator/        # Hugo - Game Master, turn sequencing, public rendering
├── tui/                 # Ada - Terminal UI for experiment control
├── container/           # Podman/Wolfi - Containerised deployment
├── papers/              # Research - Whitepaper, validity framework
├── scripts/             # Shell - Orchestration
└── docs/                # Documentation - Architecture, FAQ, guides
```

## Prerequisites

- Julia 1.10+
- Hugo extended 0.120+
- At least one LLM API key (Anthropic, Mistral, or local via LM Studio/Ollama)

Optional:
- Ada/GNAT with Alire (for TUI)
- Podman (for containerised deployment)

## Installation

```bash
# Clone the repository
git clone https://github.com/hyperpolymath/thejeffparadox.git
cd thejeffparadox

# Install Julia dependencies
cd engine && julia --project=. -e 'using Pkg; Pkg.instantiate()'
cd ..

# Set API keys
export ANTHROPIC_API_KEY="sk-ant-..."
export MISTRAL_API_KEY="..."

# Optional: Build Ada TUI
cd tui && alr build
```

## Usage

```bash
# Run a single turn
./scripts/run_turn.sh

# Run in daemon mode (infinite loop)
TURN_DELAY=3600 ./scripts/infinite_loop.sh &

# Generate metrics report
./scripts/metrics_report.sh

# Run tests
just test
```

## Key Concepts

### Game Mechanics
- **Chaos** (0-100): Measures reality destabilisation from skill usage
- **Exposure** (0-100): Tracks how much of The Jeff's alien nature is revealed
- **Faction Slider** (-100 to +100): Balance between Homeward and Earthbound factions

### Anti-Convergence (Conceptor-Inspired)
- Diversity injection (periodic topic/perspective prompts)
- Contradiction seeding (triggered when coherence exceeds threshold)
- Aperture control (temperature modulation based on vocabulary diversity)
- Pattern quarantine (discourages overused n-grams)

### Metrics Tracked
- Vocabulary diversity (type-token ratio)
- Self-reference and other-reference rates
- Coherence score (adjacent turn similarity)
- Convergence index (cross-node vocabulary overlap)
- Novel n-gram emergence

## Documentation

For detailed documentation, see the [docs](./docs) directory:
- [Architecture](./docs/wiki/Architecture.md)
- [Philosophy](./docs/wiki/Philosophy.md)
- [FAQ](./docs/wiki/FAQ.md)
- [Getting Started](./docs/wiki/Getting-Started.md)

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting pull requests.

## Research & References

This project draws on research in LLM identity, conceptor theory (Jaeger 2014), Kantian philosophy, and Derek Parfit's work on personal identity. Key references can be found in `papers/references.bib`.

## License

This project is licensed under MPL-2.0-or-later. See the [LICENSE](LICENSE) file for details.

## Author

**hyperpolymath**
- GitHub: [@hyperpolymath](https://github.com/hyperpolymath)
