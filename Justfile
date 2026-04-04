# The Jeff Paradox - Task Runner
set shell := ["bash", "-uc"]
set dotenv-load := true

default:
    @just --list

# Run a single conversation turn
turn:
    cd engine && julia --project=. scripts/execute_turn.jl

# Run conversation loop
loop:
    ./scripts/infinite_loop.sh

# Install dependencies
install:
    cd engine && julia --project=. -e 'using Pkg; Pkg.instantiate()'

# Run tests
test:
    cd engine && julia --project=. -e 'using Pkg; Pkg.test()'

# Build all Hugo sites
build:
    cd orchestrator && hugo --minify --gc
    cd node-alpha && hugo --minify --gc
    cd node-beta && hugo --minify --gc

# Serve orchestrator locally
serve:
    cd orchestrator && hugo server -D --port 1313

# Build container
container-build:
    podman build -t jeff-paradox -f container/Containerfile .

# Show game state
state:
    @cat orchestrator/data/game_state.yml

# Generate metrics report
metrics:
    ./scripts/metrics_report.sh

# Run security scan
security:
    trivy fs --scanners vuln,secret,misconfig .

# Verify SHA pinning
verify-pins:
    @! grep -rE 'uses: [^@]+@v[0-9]' .github/workflows/ && echo "All pinned ✓"

# Clean build artifacts
clean:
    rm -rf orchestrator/public node-alpha/public node-beta/public

# Shorthands
t: turn
b: build
s: state
