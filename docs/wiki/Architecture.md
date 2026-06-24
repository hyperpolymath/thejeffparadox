<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Architecture

The Jeff Paradox is built on a simple but carefully designed architecture that separates concerns while enabling the core experiment.

## Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           THE JEFF PARADOX                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌─────────────────┐            ┌─────────────────┐                    │
│   │   NODE ALPHA    │◄──────────►│   NODE BETA     │                    │
│   │   (Hugo)        │            │   (Hugo)        │                    │
│   │                 │            │                 │                    │
│   │  Homeward       │            │  Earthbound     │                    │
│   │  Faction        │            │  Faction        │                    │
│   │                 │            │                 │                    │
│   │  Secret goals   │            │  Secret goals   │                    │
│   │  Hidden skills  │            │  Hidden skills  │                    │
│   └────────┬────────┘            └────────┬────────┘                    │
│            │                              │                             │
│            │      ┌──────────────┐        │                             │
│            └─────►│ ORCHESTRATOR │◄───────┘                             │
│                   │    (Hugo)    │                                      │
│                   │              │                                      │
│                   │ Game Master  │                                      │
│                   │ Public Site  │                                      │
│                   │ Metrics      │                                      │
│                   └──────┬───────┘                                      │
│                          │                                              │
│                   ┌──────▼───────┐                                      │
│                   │   ENGINE     │                                      │
│                   │   (Julia)    │                                      │
│                   │              │                                      │
│                   │ Mechanics    │                                      │
│                   │ Anti-Conv.   │                                      │
│                   │ Metrics      │                                      │
│                   │ LLM Client   │                                      │
│                   └──────────────┘                                      │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Components

### Node Alpha & Node Beta (Hugo)

Two identical Hugo sites representing the personality fragments.

**Directory Structure:**
```
node-alpha/
├── hugo.toml           # Site configuration
├── content/
│   ├── _index.md       # Home page
│   └── turns/          # This node's turns
├── data/
│   └── node_state.yml  # Hidden state (goals, skills)
├── layouts/            # Templates
└── static/css/         # Styles
```

**Key Files:**
- `data/node_state.yml`: Secret goals, skills, personality traits, LLM config
- `content/turns/`: Markdown files for each turn this node takes

**Faction Colours:**
- Alpha (Homeward): Blue (`#2c5282`)
- Beta (Earthbound): Brown (`#744210`)

### Orchestrator (Hugo)

The "Game Master" site that coordinates everything.

**Directory Structure:**
```
orchestrator/
├── hugo.toml           # Main configuration
├── content/
│   ├── _index.md       # Home page
│   └── turns/          # All turns (both nodes)
├── data/
│   ├── game_state.yml  # Global state
│   └── metrics.yml     # Accumulated metrics
├── layouts/            # Templates
└── static/             # CSS, .well-known
```

**Responsibilities:**
- Render the public conversation view
- Display game state (chaos, exposure, faction)
- Show metrics and emergence indicators
- Serve as the canonical record

### Engine (Julia)

The computational core that runs the game mechanics.

**Directory Structure:**
```
engine/
├── Project.toml        # Dependencies
├── src/
│   ├── JeffEngine.jl   # Main module
│   ├── mechanics.jl    # Dice, chaos, exposure, faction
│   ├── conceptors.jl   # Anti-convergence
│   ├── metrics.jl      # Emergence tracking
│   └── llm_client.jl   # API abstraction
└── test/
    └── runtests.jl     # Test suite
```

**Modules:**

| Module | Purpose |
|--------|---------|
| `JeffEngine` | Core types and turn execution |
| `mechanics` | Game rules (dice, skills, thresholds) |
| `conceptors` | Anti-convergence mechanisms |
| `metrics` | Emergence and convergence tracking |
| `llm_client` | LLM API abstraction |

### Scripts (Shell)

Orchestration and automation scripts.

| Script | Purpose |
|--------|---------|
| `run_turn.sh` | Execute single turn |
| `infinite_loop.sh` | Continuous execution daemon |
| `metrics_report.sh` | Generate metrics report |

## Data Flow

### Turn Execution

```
1. Script invoked
      │
      ▼
2. Load game state from orchestrator/data/game_state.yml
      │
      ▼
3. Load node state from node-{alpha,beta}/data/node_state.yml
      │
      ▼
4. Build context (history, state, diversity prompt)
      │
      ▼
5. Call LLM API for node response
      │
      ▼
6. Call LLM API for GM narration
      │
      ▼
7. Parse mechanical effects (chaos, exposure, faction)
      │
      ▼
8. Update game state
      │
      ▼
9. Compute metrics
      │
      ▼
10. Save turn as markdown to:
    - orchestrator/content/turns/
    - node-{current}/content/turns/
      │
      ▼
11. Save state to orchestrator/data/game_state.yml
```

### Context Building

The context provided to each node includes:

1. **System prompt**: Node identity, faction, goals, skills, personality
2. **Game state**: Current chaos, exposure, faction slider
3. **Conversation history**: Recent turns from both nodes
4. **Diversity injection**: Periodic prompts to prevent convergence
5. **Pattern quarantine**: Phrases to avoid (overused patterns)

## Technology Choices

### Why Hugo?

- **No runtime**: Static site generation
- **No Ruby/Python/Node**: Go-based
- **Fast**: Sub-second builds
- **Flexible**: Powerful templating

### Why Julia?

- **Numerical computing**: Natural for metrics
- **Type system**: Catches errors early
- **Performance**: Near-C speed when needed
- **Readable**: Clean syntax for game logic

### Why Not...?

| Technology | Why Not |
|------------|---------|
| Python | Explicit requirement to avoid |
| Node.js | Explicit requirement to avoid |
| TypeScript | Explicit requirement to avoid |
| Jekyll | Requires Ruby |
| Database | Unnecessary complexity for static experiment |
| Docker | Adds complexity; static sites don't need it |

## Deployment

### GitHub Actions

- **CI**: Runs on every PR (lint, test, build)
- **Conversation**: Hourly automated turns
- **Deploy**: Pushes to GitHub Pages

### GitHub Pages

Static hosting with:
- Custom domain support
- HTTPS by default
- CDN distribution

## Extensibility

### Adding a New Node

1. Copy `node-alpha/` to `node-gamma/`
2. Update `hugo.toml` with new identity
3. Update `data/node_state.yml` with new faction/goals
4. Update engine to handle three-way competition

### Adding New Metrics

1. Add computation function to `engine/src/metrics.jl`
2. Add to `compute_metrics()` return dict
3. Add display in `orchestrator/layouts/partials/metrics-display.html`

### Adding New Anti-Convergence Mechanisms

1. Add to `engine/src/conceptors.jl`
2. Hook into context building in `JeffEngine.jl`
3. Document in wiki
