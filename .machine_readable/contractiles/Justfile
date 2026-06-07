import? "contractile.just"

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

# ── CRG Grade B: 6 independently runnable test targets ──────────────────────

# T1: Julia engine tests
test-engine:
    @if command -v julia &>/dev/null; then \
        cd engine && julia --project=. -e 'using Pkg; Pkg.test()'; \
    else \
        echo "SKIP: julia not installed"; \
    fi

# T2: Zig FFI integration test
test-zig:
    @if command -v zig &>/dev/null; then \
        zig test ffi/zig/test/integration_test.zig; \
    else \
        echo "SKIP: zig not installed"; \
    fi

# T3: Structural validation (required files and directories)
test-structure:
    bash tests/validate_structure.sh

# T4: Nickel k9 contractile typecheck (strips K9! header before checking)
test-nickel:
    @if command -v nickel &>/dev/null; then \
        tail -n +2 contractiles/k9/template-yard.k9.ncl | nickel typecheck /dev/stdin && echo "PASS: nickel typecheck"; \
    else \
        echo "SKIP: nickel not installed"; \
    fi

# T5: Hugo config validation for node-alpha and node-beta
test-hugo-check:
    bash tests/validate_hugo_config.sh

# T6: Orchestrator structural validation
test-orchestrator:
    bash tests/validate_orchestrator.sh

# Run all 6 Grade B test targets
test: test-engine test-zig test-structure test-nickel test-hugo-check test-orchestrator

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
