# The Jeff Paradox - Task Runner
# Comprehensive task automation for the LLM diachronic identity experiment
set shell := ["bash", "-uc"]
set dotenv-load := true

# Default: show all available recipes
default:
    @just --list --unsorted

# =============================================================================
# EXPERIMENT CONTROL
# =============================================================================

# Run a single conversation turn
turn:
    cd engine && julia --project=. scripts/execute_turn.jl

# Run N conversation turns
turns n="5":
    for i in $(seq 1 {{n}}); do just turn && sleep 1; done

# Run conversation loop (daemon mode)
loop:
    ./scripts/infinite_loop.sh

# Execute turn with specific node (alpha/beta)
turn-node node="alpha":
    cd engine && julia --project=. -e 'include("scripts/execute_turn.jl"); execute_turn("{{node}}")'

# Run turn with custom temperature
turn-temp temp="0.8":
    TEMPERATURE={{temp}} cd engine && julia --project=. scripts/execute_turn.jl

# =============================================================================
# BUILD & DEVELOPMENT
# =============================================================================

# Full project setup (dependencies + hooks)
setup: install hooks-install
    @echo "Setup complete! Run 'just env-check' to verify."

# Install all dependencies
install: install-julia install-ada

# Install Julia dependencies
install-julia:
    cd engine && julia --project=. -e 'using Pkg; Pkg.instantiate()'

# Install Ada/Alire dependencies (optional)
install-ada:
    cd tui && alr build --release || echo "Ada/Alire not available, skipping TUI"

# Run Julia tests
test:
    cd engine && julia --project=. -e 'using Pkg; Pkg.test()'

# Run tests with coverage
test-coverage:
    cd engine && julia --project=. -e 'using Pkg; Pkg.test(coverage=true)'

# Build all Hugo sites
build: build-orchestrator build-alpha build-beta

# Build orchestrator site
build-orchestrator:
    cd orchestrator && hugo --minify --gc

# Build node-alpha site
build-alpha:
    cd node-alpha && hugo --minify --gc

# Build node-beta site
build-beta:
    cd node-beta && hugo --minify --gc

# Build with drafts
build-drafts:
    cd orchestrator && hugo --minify --gc -D
    cd node-alpha && hugo --minify --gc -D
    cd node-beta && hugo --minify --gc -D

# =============================================================================
# SERVE & PREVIEW
# =============================================================================

# Serve orchestrator locally
serve port="1313":
    cd orchestrator && hugo server -D --port {{port}}

# Serve node-alpha locally
serve-alpha port="1314":
    cd node-alpha && hugo server -D --port {{port}}

# Serve node-beta locally
serve-beta port="1315":
    cd node-beta && hugo server -D --port {{port}}

# Serve all sites (requires tmux or multiple terminals)
serve-all:
    @echo "Starting all sites (use tmux or open separate terminals):"
    @echo "  just serve       # Port 1313 - Orchestrator"
    @echo "  just serve-alpha # Port 1314 - Node Alpha"
    @echo "  just serve-beta  # Port 1315 - Node Beta"

# =============================================================================
# CONTAINER OPERATIONS
# =============================================================================

# Build container image
container-build:
    podman build -t jeff-paradox -f container/Containerfile .

# Build container with nerdctl
container-build-nerdctl:
    nerdctl build -t jeff-paradox -f container/Containerfile .

# Run container interactively
container-run:
    podman run -it --rm -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" jeff-paradox

# Run container with compose
container-up:
    podman-compose -f container/podman-compose.yml up

# Stop compose
container-down:
    podman-compose -f container/podman-compose.yml down

# Shell into container
container-shell:
    podman run -it --rm --entrypoint /bin/sh jeff-paradox

# =============================================================================
# METRICS & ANALYSIS
# =============================================================================

# Show current game state
state:
    @cat orchestrator/data/game_state.yml 2>/dev/null || echo "No game state file yet"

# Show STATE.scm checkpoint
checkpoint:
    @cat STATE.scm

# Generate metrics report
metrics:
    ./scripts/metrics_report.sh

# Show vocabulary diversity
vocab-diversity:
    cd engine && julia --project=. -e 'include("scripts/generate_report.jl"); show_vocabulary_diversity()'

# Show convergence index
convergence:
    cd engine && julia --project=. -e 'include("scripts/generate_report.jl"); show_convergence_index()'

# Count turns
turn-count:
    @ls orchestrator/content/turns/*.md 2>/dev/null | wc -l | xargs echo "Turns:"

# Show latest turn
latest:
    @ls -t orchestrator/content/turns/*.md 2>/dev/null | head -1 | xargs cat

# =============================================================================
# SECURITY & QUALITY
# =============================================================================

# Run full security scan
security:
    trivy fs --scanners vuln,secret,misconfig .

# Run vulnerability scan only
vuln:
    trivy fs --scanners vuln .

# Run secrets scan
secrets:
    trivy fs --scanners secret .
    trufflehog filesystem . --only-verified || true

# Verify SHA pinning in workflows
verify-pins:
    @! grep -rE 'uses: [^@]+@v[0-9]' .github/workflows/ && echo "✓ All actions SHA-pinned"

# Run all linters
lint: lint-shell lint-yaml lint-markdown

# Lint shell scripts
lint-shell:
    shellcheck scripts/*.sh

# Lint YAML files
lint-yaml:
    yamllint -c .yamllint.yml .

# Lint Markdown files
lint-markdown:
    markdownlint-cli2 '**/*.md' '#node_modules'

# Check links
check-links:
    lychee --verbose --no-progress '**/*.md' || true

# =============================================================================
# HOOKS & SETUP
# =============================================================================

# Install git hooks
hooks-install:
    ./scripts/setup-hooks.sh

# Uninstall git hooks (use default git hooks path)
hooks-uninstall:
    git config --unset core.hooksPath || true
    @echo "Git hooks disabled"

# Run pre-commit checks manually
hooks-check:
    ./.githooks/pre-commit

# =============================================================================
# GIT & RELEASE
# =============================================================================

# Generate changelog
changelog:
    git-cliff -o CHANGELOG.md

# Generate changelog for unreleased
changelog-unreleased:
    git-cliff --unreleased

# Show git status
status:
    git status -sb

# Show recent commits
log:
    git log --oneline -10

# Create release tag
tag version:
    git tag -a v{{version}} -m "Release v{{version}}"
    @echo "Created tag v{{version}}. Push with: git push origin v{{version}}"

# =============================================================================
# CLEANUP
# =============================================================================

# Clean build artifacts
clean:
    rm -rf orchestrator/public node-alpha/public node-beta/public
    rm -rf tui/bin tui/obj
    rm -f *.log

# Clean Julia compilation cache
clean-julia:
    cd engine && julia --project=. -e 'using Pkg; Pkg.gc()'

# Deep clean (including dependencies)
clean-deep: clean clean-julia
    cd engine && rm -f Manifest.toml

# =============================================================================
# DOCUMENTATION
# =============================================================================

# Convert claude.adoc to HTML
docs-html:
    asciidoctor claude.adoc -o docs/specification.html || echo "asciidoctor not installed"

# Convert claude.adoc to PDF
docs-pdf:
    asciidoctor-pdf claude.adoc -o docs/specification.pdf || echo "asciidoctor-pdf not installed"

# =============================================================================
# SHORTCUTS
# =============================================================================

# Aliases for common operations
t: turn
b: build
s: state
m: metrics
l: lint
c: clean

# =============================================================================
# HELP & INFO
# =============================================================================

# Show project info
info:
    @echo "The Jeff Paradox v1.0.0"
    @echo "======================="
    @echo "An experiment in LLM diachronic identity"
    @echo ""
    @echo "Turn count: $(just turn-count)"
    @echo "Last updated: $(stat -c %y STATE.scm 2>/dev/null || stat -f %Sm STATE.scm)"

# Show environment status
env-check:
    @echo "Checking environment..."
    @command -v julia >/dev/null && echo "✓ Julia: $(julia --version)" || echo "✗ Julia not found"
    @command -v hugo >/dev/null && echo "✓ Hugo: $(hugo version | head -1)" || echo "✗ Hugo not found"
    @command -v podman >/dev/null && echo "✓ Podman: $(podman --version)" || echo "- Podman not found (optional)"
    @command -v nerdctl >/dev/null && echo "✓ nerdctl: $(nerdctl --version)" || echo "- nerdctl not found (optional)"
    @test -n "$ANTHROPIC_API_KEY" && echo "✓ ANTHROPIC_API_KEY set" || echo "✗ ANTHROPIC_API_KEY not set"
    @test -n "$MISTRAL_API_KEY" && echo "✓ MISTRAL_API_KEY set" || echo "- MISTRAL_API_KEY not set (optional)"

# Show help for experiment workflow
help-experiment:
    @echo "Experiment Workflow"
    @echo "==================="
    @echo "1. just install     # Install dependencies"
    @echo "2. just env-check   # Verify environment"
    @echo "3. just turn        # Run single turn"
    @echo "4. just state       # Check game state"
    @echo "5. just metrics     # View metrics"
    @echo "6. just loop        # Run continuous (daemon)"
