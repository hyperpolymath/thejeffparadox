#!/usr/bin/env bash
# metrics_report.sh - Generate a metrics report for The Jeff Paradox

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENGINE_DIR="$PROJECT_ROOT/engine"

# Run Julia to generate report
cd "$ENGINE_DIR"
julia --project=. -e '
using JeffEngine
using Dates

# Load game state
config_path = joinpath(dirname(@__DIR__), "orchestrator", "data", "game_state.yml")

if !isfile(config_path)
    println("No game state found. Has the experiment started?")
    exit(1)
end

game = load_game_state(config_path, Dict())

# Header
println("=" ^ 60)
println("THE JEFF PARADOX - METRICS REPORT")
println("Generated: $(Dates.format(now(), "yyyy-mm-dd HH:MM:SS"))")
println("=" ^ 60)
println()

# Game state
println("GAME STATE")
println("-" ^ 40)
println("Turn Number:     $(game.turn_number)")
println("Chaos:           $(game.chaos)/100")
println("Exposure:        $(game.exposure)/100")
println("Faction Slider:  $(game.faction_slider)")
println("Current Node:    $(game.current_node)")
println()

# Thresholds
println("THRESHOLD STATUS")
println("-" ^ 40)
events = check_thresholds(game.chaos, game.exposure, game.faction_slider)
if isempty(events)
    println("No thresholds triggered")
else
    for event in events
        println("  - $(event)")
    end
end
println()

# Metrics
if !isempty(game.metrics_history)
    println("CURRENT METRICS")
    println("-" ^ 40)
    print(metrics_summary(game))
    println()

    # Trends
    println("METRIC TRENDS (last 20 turns)")
    println("-" ^ 40)
    for metric in ["vocabulary_diversity", "coherence_score", "convergence_index"]
        trend = metrics_trend(game, metric, 20)
        symbol = trend == :increasing ? "↑" : (trend == :decreasing ? "↓" : "→")
        println("  $(metric): $(symbol) $(trend)")
    end
    println()
end

# Convergence warning
warning = convergence_warning(game)
if warning !== nothing
    println("⚠️  $(warning)")
    println()
end

# Pattern quarantine
if !isempty(game.pattern_quarantine)
    println("QUARANTINED PATTERNS ($(length(game.pattern_quarantine)))")
    println("-" ^ 40)
    for (i, pattern) in enumerate(game.pattern_quarantine[max(1,end-9):end])
        println("  $(i). \"$(pattern)\"")
    end
    println()
end

# Emergent patterns
if !isempty(game.turn_history) && length(game.turn_history) >= 50
    patterns = detect_emergent_patterns(game)
    if !isempty(patterns)
        println("DETECTED EMERGENT PATTERNS")
        println("-" ^ 40)
        for pattern in patterns
            println("  - $(pattern)")
        end
        println()
    end
end

println("=" ^ 60)
println("END OF REPORT")
'
