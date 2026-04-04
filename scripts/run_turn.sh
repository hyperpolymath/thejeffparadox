#!/usr/bin/env bash
# run_turn.sh - Execute a single turn of The Jeff Paradox
# Requires: Julia 1.10+, Hugo 0.120+, environment variables for API keys

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENGINE_DIR="$PROJECT_ROOT/engine"
ORCHESTRATOR_DIR="$PROJECT_ROOT/orchestrator"
LOG_DIR="$PROJECT_ROOT/logs"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Timestamp for logging
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

log() {
    echo "[$TIMESTAMP] $*" | tee -a "$LOG_DIR/turns.log"
}

error() {
    echo "[$TIMESTAMP] ERROR: $*" >&2 | tee -a "$LOG_DIR/errors.log"
    exit 1
}

# Check prerequisites
command -v julia >/dev/null 2>&1 || error "Julia not found in PATH"

# Check for API keys (at least one required)
if [[ -z "${ANTHROPIC_API_KEY:-}" ]] && [[ -z "${MISTRAL_API_KEY:-}" ]] && [[ -z "${LOCAL_API_KEY:-}" ]]; then
    error "No API keys found. Set ANTHROPIC_API_KEY, MISTRAL_API_KEY, or LOCAL_API_KEY"
fi

log "Starting turn execution"

# Run the Julia engine
cd "$ENGINE_DIR"
julia --project=. -e '
using JeffEngine

# Load configuration
config_path = joinpath(dirname(@__DIR__), "orchestrator", "data", "game_state.yml")
game = if isfile(config_path)
    load_game_state(config_path, Dict())
else
    initialise_game_state(config_path)
end

# Load nodes (Hugo uses data/ not _data/)
alpha_path = joinpath(dirname(@__DIR__), "node-alpha", "data", "node_state.yml")
beta_path = joinpath(dirname(@__DIR__), "node-beta", "data", "node_state.yml")

alpha = initialise_node_state(alpha_path)
beta = initialise_node_state(beta_path)

nodes = Dict(:alpha => alpha, :beta => beta)

# Execute turn
result = execute_turn(game, nodes)

# Save state
save_game_state(game, config_path)

# Save turn as markdown
turn_filename = @sprintf("%04d-%s.md", result.turn_number, lowercase(result.node_name))
turn_path = joinpath(dirname(@__DIR__), "orchestrator", "content", "turns", turn_filename)
save_turn_to_markdown(result, turn_path)

# Also save to appropriate node (Hugo uses content/ not _posts/)
node_dir = result.node_name == "Alpha" ? "node-alpha" : "node-beta"
node_turn_path = joinpath(dirname(@__DIR__), node_dir, "content", "turns", turn_filename)
mkpath(dirname(node_turn_path))
save_turn_to_markdown(result, node_turn_path)

println("Turn $(result.turn_number) completed: $(result.node_name)")
println(metrics_summary(game))
'

if [[ $? -eq 0 ]]; then
    log "Turn execution completed successfully"
else
    error "Turn execution failed"
fi

# Rebuild static sites (optional, for local preview)
if [[ "${REBUILD_SITES:-false}" == "true" ]]; then
    log "Rebuilding Hugo sites"
    cd "$ORCHESTRATOR_DIR"
    hugo --quiet

    cd "$PROJECT_ROOT/node-alpha"
    hugo --quiet

    cd "$PROJECT_ROOT/node-beta"
    hugo --quiet
fi

log "Turn complete"
