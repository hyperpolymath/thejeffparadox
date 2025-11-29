# Getting Started

This guide will help you set up and run The Jeff Paradox locally.

## Prerequisites

### Required Software

| Software | Version | Purpose |
|----------|---------|---------|
| Julia | 1.9+ | Game engine |
| Hugo | 0.120+ (extended) | Static site generation |
| Git | 2.0+ | Version control |

### Optional Software

| Software | Purpose |
|----------|---------|
| shellcheck | Shell script linting |
| markdownlint | Markdown linting |

### API Keys

You need at least one LLM API key:

- **Anthropic** (Claude): https://console.anthropic.com/
- **Mistral**: https://console.mistral.ai/
- **Local** (LM Studio, Ollama): No key needed

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Hyperpolymath/thejeffparadox.git
cd thejeffparadox
```

### 2. Install Julia Dependencies

```bash
cd engine
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

### 3. Verify Hugo Installation

```bash
hugo version
# Should show "extended" in the output
```

### 4. Set Environment Variables

```bash
# Add to your shell profile (.bashrc, .zshrc, etc.)
export ANTHROPIC_API_KEY="sk-ant-..."
export MISTRAL_API_KEY="..."

# Or for local LLM:
export LOCAL_API_KEY="not-needed"
```

## Running the Experiment

### Single Turn

Execute one turn of the conversation:

```bash
./scripts/run_turn.sh
```

This will:
1. Load game state
2. Generate a response from the current node
3. Generate GM narration
4. Update game state
5. Save the turn as markdown

### Continuous Mode

Run the experiment continuously:

```bash
# Default: 1 hour between turns
./scripts/infinite_loop.sh &

# Custom interval (in seconds)
TURN_DELAY=300 ./scripts/infinite_loop.sh &

# Limited turns
MAX_TURNS=100 ./scripts/infinite_loop.sh &
```

### View the Results

Build and serve the Hugo sites:

```bash
# Orchestrator (main site)
cd orchestrator
hugo server --buildDrafts

# Visit http://localhost:1313
```

### Generate Metrics Report

```bash
./scripts/metrics_report.sh
```

## Configuration

### Node Configuration

Edit `node-alpha/data/node_state.yml` or `node-beta/data/node_state.yml`:

```yaml
node:
  name: "Alpha"
  faction: "homeward"
  secret_goal: "Your secret goal here"

llm:
  provider: "anthropic"  # or "mistral", "local"
  model: "claude-sonnet-4-20250514"
  temperature: 0.85
```

### Game Configuration

Edit `orchestrator/data/game_state.yml`:

```yaml
chaos: 15
exposure: 5
faction_slider: 0
turn_number: 0
```

### Anti-Convergence Settings

Edit `orchestrator/hugo.toml`:

```toml
[params.conceptors]
  diversity_injection_frequency = 10
  contradiction_threshold = 0.85
  min_temperature = 0.6
  max_temperature = 1.2
```

## Troubleshooting

### Julia Package Errors

```bash
# Clear and reinstall
cd engine
rm -f Manifest.toml
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

### Hugo Build Errors

```bash
# Clean build
rm -rf public resources
hugo --gc
```

### API Errors

1. Check API key is set: `echo $ANTHROPIC_API_KEY | head -c 10`
2. Check API key format (should start with correct prefix)
3. Check API quotas/limits

### Rate Limiting

If you hit rate limits:

```bash
# Increase delay between turns
TURN_DELAY=7200 ./scripts/infinite_loop.sh &
```

## Next Steps

- Read [Architecture](Architecture.md) to understand the system
- Read [Game Mechanics](Game-Mechanics.md) to understand the rules
- Read [Philosophy](Philosophy.md) for theoretical background
- Check [FAQ](FAQ.md) for common questions
