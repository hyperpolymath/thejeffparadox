#!/usr/bin/env julia
#
# generate_report.jl - Generate daily metrics report
#

using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))
Pkg.instantiate()

include(joinpath(@__DIR__, "..", "src", "JeffEngine.jl"))
using .JeffEngine

using Dates

function main()
    base_dir = dirname(dirname(@__DIR__))
    config_path = joinpath(base_dir, "orchestrator", "data", "game_state.yml")

    if !isfile(config_path)
        println("No game state found at $config_path")
        return
    end

    println("Loading game state...")
    game = load_game_state(config_path, Dict())

    # Generate report
    report = """
    # The Jeff Paradox - Metrics Report

    Generated: $(Dates.format(now(), "yyyy-mm-dd HH:MM:SS")) UTC

    ## Game State

    | Metric | Value |
    |--------|-------|
    | Turn | $(game.turn_number) |
    | Chaos | $(game.chaos)/100 |
    | Exposure | $(game.exposure)/100 |
    | Faction | $(game.faction_slider) |
    | Current Node | $(game.current_node) |

    ## Threshold Status

    $(let events = check_thresholds(game.chaos, game.exposure, game.faction_slider)
        isempty(events) ? "No thresholds triggered" : join(["- $(e)" for e in events], "\n")
    end)

    ## Pattern Quarantine

    $(isempty(game.pattern_quarantine) ? "No patterns quarantined" :
        "$(length(game.pattern_quarantine)) patterns quarantined")

    ---
    *Report generated automatically by The Jeff Paradox metrics system.*
    """

    # Save report
    report_dir = joinpath(base_dir, "docs", "reports")
    mkpath(report_dir)

    report_path = joinpath(report_dir, "daily-$(Dates.format(now(), "yyyy-mm-dd")).md")
    write(report_path, report)

    println("Report saved to $report_path")
    println(report)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
