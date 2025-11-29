#!/usr/bin/env bash
# infinite_loop.sh - Run The Jeff Paradox continuously
# This is the main daemon that keeps the conversation going

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_ROOT/logs"
PID_FILE="$PROJECT_ROOT/.jeff_paradox.pid"

# Configuration
TURN_DELAY="${TURN_DELAY:-3600}"  # Default: 1 hour between turns
MAX_TURNS="${MAX_TURNS:-0}"       # 0 = infinite
REBUILD_SITES="${REBUILD_SITES:-false}"

mkdir -p "$LOG_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

log() {
    echo "[$TIMESTAMP] $*" | tee -a "$LOG_DIR/daemon.log"
}

cleanup() {
    log "Shutting down The Jeff Paradox"
    rm -f "$PID_FILE"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Check if already running
if [[ -f "$PID_FILE" ]]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "The Jeff Paradox is already running (PID: $OLD_PID)"
        exit 1
    fi
    rm -f "$PID_FILE"
fi

# Write PID
echo $$ > "$PID_FILE"

log "The Jeff Paradox daemon starting"
log "Turn delay: ${TURN_DELAY}s"
log "Max turns: ${MAX_TURNS:-infinite}"

TURN_COUNT=0

while true; do
    TURN_COUNT=$((TURN_COUNT + 1))

    log "=== Turn $TURN_COUNT ==="

    # Execute turn
    if REBUILD_SITES="$REBUILD_SITES" "$SCRIPT_DIR/run_turn.sh"; then
        log "Turn $TURN_COUNT succeeded"
    else
        log "Turn $TURN_COUNT failed, continuing..."
    fi

    # Check max turns
    if [[ "$MAX_TURNS" -gt 0 ]] && [[ "$TURN_COUNT" -ge "$MAX_TURNS" ]]; then
        log "Reached max turns ($MAX_TURNS), exiting"
        break
    fi

    # Wait for next turn
    log "Sleeping for ${TURN_DELAY}s until next turn"
    sleep "$TURN_DELAY"
done

cleanup
