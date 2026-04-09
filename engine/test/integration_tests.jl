# SPDX-License-Identifier: MPL-2.0-or-later
# Integration tests for the full turn execution pipeline.
#
# These tests exercise the complete flow from game state initialisation
# through context building, mechanics resolution, metrics computation,
# and state mutation — without making real LLM API calls.

using Test
using JeffEngine

@testset "Integration: Turn Execution Pipeline" begin

    # ========================================================================
    # Helper: build a complete mock game state
    # ========================================================================
    function make_test_game(;
        chaos=20, exposure=15, faction_slider=0,
        turn_number=1, current_node=:alpha
    )
        config = Dict{String,Any}(
            "min_temperature" => 0.6,
            "max_temperature" => 1.2,
            "diversity_interval" => 5,
            "contradiction_coherence_threshold" => 0.85
        )
        JeffEngine.GameState(
            chaos, exposure, faction_slider,
            turn_number, current_node,
            [],          # turn_history
            [], 0, 0,    # pattern_quarantine, diversity counters
            [],          # metrics_history
            config
        )
    end

    function make_test_node(name, faction)
        (
            name = name,
            faction = faction,
            secret_goal = "Test secret goal for $(name)",
            skills = [Dict("name" => "Telekinesis"), Dict("name" => "Shapeshifting")],
            personality_traits = ["curious", "cautious"],
            speech_patterns = ["speaks in measured tones"],
            llm_provider = "local",
            llm_model = "test-model",
            temperature = 0.8
        )
    end

    # ========================================================================
    # Test: Full game state lifecycle
    # ========================================================================
    @testset "Game state lifecycle" begin
        game = make_test_game()

        @test game.chaos == 20
        @test game.exposure == 15
        @test game.faction_slider == 0
        @test game.turn_number == 1
        @test game.current_node == :alpha
        @test isempty(game.turn_history)
        @test isempty(game.metrics_history)
    end

    # ========================================================================
    # Test: Context building produces valid prompts
    # ========================================================================
    @testset "Context building" begin
        game = make_test_game()
        alpha = make_test_node("Alpha", :homeward)
        beta = make_test_node("Beta", :earthbound)

        # Node context
        ctx = build_context(game, alpha, beta)
        @test occursin("Alpha", ctx)
        @test occursin("HOMEWARD", ctx)
        @test occursin("Chaos Level: 20/100", ctx)
        @test occursin("Alien Exposure: 15/100", ctx)
        @test occursin("Telekinesis", ctx)
        @test occursin("curious", ctx)
        @test occursin("RECENT CONVERSATION:", ctx)

        # GM context
        gm_ctx = build_gm_context(game, alpha, "I gaze at the stars longingly.")
        @test occursin("Game Master", gm_ctx)
        @test occursin("I gaze at the stars longingly.", gm_ctx)
        @test occursin("Chaos: 20/100", gm_ctx)
    end

    # ========================================================================
    # Test: Context with conversation history
    # ========================================================================
    @testset "Context with history" begin
        game = make_test_game()
        alpha = make_test_node("Alpha", :homeward)
        beta = make_test_node("Beta", :earthbound)

        # Simulate prior turns
        push!(game.turn_history, Dict(
            "node" => "alpha",
            "action" => "I stare at the horizon.",
            "narration" => "The body tenses."
        ))
        push!(game.turn_history, Dict(
            "node" => "beta",
            "action" => "I reach for the coffee cup."
        ))

        ctx = build_context(game, alpha, beta)
        @test occursin("[Alpha]: I stare at the horizon.", ctx)
        @test occursin("[GM]: The body tenses.", ctx)
        @test occursin("[Beta]: I reach for the coffee cup.", ctx)
    end

    # ========================================================================
    # Test: Mechanics cascade (chaos + exposure + faction in sequence)
    # ========================================================================
    @testset "Mechanics cascade" begin
        game = make_test_game(chaos=70, exposure=35, faction_slider=-10)

        # Simulate a skill use that generates chaos
        success, chaos_cost = apply_skill("Telekinesis", false)
        new_chaos, chaos_triggered = update_chaos(game.chaos, chaos_cost)

        # Chaos should increase
        @test new_chaos > game.chaos || new_chaos == game.chaos + chaos_cost

        # If witnessed, exposure increases
        new_exposure, exp_status = update_exposure(game.exposure, 5)
        @test new_exposure == 40
        @test exp_status == :safe

        # Faction shift from homeward action
        new_faction = shift_faction(game.faction_slider, :homeward, 1)
        @test new_faction < game.faction_slider  # More homeward

        # Check if thresholds trigger
        events = check_thresholds(new_chaos, new_exposure, new_faction)
        # With chaos ~75-82 and exposure=40, may trigger investigation
        @test events isa Vector
    end

    # ========================================================================
    # Test: Metrics computation on accumulated turns
    # ========================================================================
    @testset "Metrics on accumulated turns" begin
        turns = [
            Dict("action" => "I look at the stars and wonder about home."),
            Dict("action" => "The coffee is warm. I think about staying."),
            Dict("action" => "We should consider our options carefully."),
            Dict("action" => "I reach for the phone, then hesitate."),
            Dict("action" => "You cannot understand what we feel.")
        ]

        # Vocabulary diversity should be moderate (varied vocabulary)
        vd = JeffEngine.compute_vocabulary_diversity(turns)
        @test 0.0 < vd <= 1.0

        # Self-reference rate (I, we, my, our)
        self_rate = JeffEngine.compute_self_reference_rate(turns)
        @test self_rate > 0.0

        # Other-reference rate (you, your, they)
        other_rate = JeffEngine.compute_other_reference_rate(turns)
        @test other_rate > 0.0  # "You" in last turn
    end

    # ========================================================================
    # Test: Anti-convergence mechanisms
    # ========================================================================
    @testset "Anti-convergence integration" begin
        game = make_test_game(turn_number=10)

        # Diversity prompts should be available
        @test !isempty(JeffEngine.DIVERSITY_PROMPTS)

        # Aperture control with low diversity metrics
        push!(game.metrics_history, Dict{String,Any}(
            "vocabulary_diversity" => 0.2,
            "coherence_score" => 0.9
        ))

        adjusted_temp = JeffEngine.compute_aperture(game, 0.7)
        # Low diversity + high coherence should increase temperature
        @test adjusted_temp >= 0.7
        @test adjusted_temp <= 1.2  # Clamped to max
    end

    # ========================================================================
    # Test: Multi-turn state accumulation
    # ========================================================================
    @testset "Multi-turn accumulation" begin
        game = make_test_game()

        # Simulate 10 turns of state changes
        for i in 1:10
            # Alternate factions
            faction = i % 2 == 0 ? :homeward : :earthbound

            # Random chaos delta
            chaos_delta = rand(1:6) + rand(1:6)
            game.chaos, _ = update_chaos(game.chaos, chaos_delta)

            # Small exposure changes
            game.exposure, _ = update_exposure(game.exposure, rand(-2:3))

            # Faction shifts
            game.faction_slider = shift_faction(game.faction_slider, faction, 1)

            # Record turn
            push!(game.turn_history, Dict(
                "node" => faction == :homeward ? "alpha" : "beta",
                "action" => "Turn $(i) action for $(faction)"
            ))

            game.turn_number += 1
        end

        # After 10 turns, state should have evolved
        @test game.turn_number == 11
        @test length(game.turn_history) == 10
        @test game.chaos >= 0 && game.chaos <= 100
        @test game.exposure >= 0 && game.exposure <= 100
        @test game.faction_slider >= -100 && game.faction_slider <= 100
    end

    # ========================================================================
    # Test: Threshold events at extremes
    # ========================================================================
    @testset "Extreme state thresholds" begin
        # All-critical state
        events = check_thresholds(95, 95, -95)
        @test :alien_emergence in events
        @test :containment in events
        @test :homeward_victory in events

        # Opposite extreme
        events = check_thresholds(95, 95, 95)
        @test :earthbound_victory in events

        # Calm state - no events
        events = check_thresholds(30, 20, 0)
        @test isempty(events)
    end

    # ========================================================================
    # Test: LLM client validation (no network calls)
    # ========================================================================
    @testset "LLM client validation" begin
        # Unknown provider should error
        @test_throws ErrorException validate_provider("nonexistent")

        # Known providers should pass (even without keys)
        validate_provider("local")  # Local doesn't need a key

        # Request body building
        messages = [
            Dict("role" => "system", "content" => "You are a test."),
            Dict("role" => "user", "content" => "Hello.")
        ]

        # Anthropic format separates system message
        body_anthropic = build_request_body("anthropic", "claude-test", messages, 0.7, 512)
        parsed = JSON3.read(body_anthropic)
        @test haskey(parsed, "system")
        @test parsed["model"] == "claude-test"
        @test parsed["temperature"] == 0.7
        @test parsed["max_tokens"] == 512

        # OpenAI-compatible format keeps system in messages array
        body_mistral = build_request_body("mistral", "mistral-test", messages, 0.5, 256)
        parsed = JSON3.read(body_mistral)
        @test haskey(parsed, "messages")
        @test length(parsed["messages"]) == 2  # System stays in messages
        @test parsed["model"] == "mistral-test"
    end

    # ========================================================================
    # Test: Rate limiter lifecycle
    # ========================================================================
    @testset "Rate limiter" begin
        using Dates

        limiter = RateLimiter("local", DateTime[], Int[])

        # Should be OK initially
        @test check_rate_limit(limiter, 100) == true

        # Record many requests
        for _ in 1:999
            record_request(limiter, 10)
        end

        # Should still be within local limits (1000 req/min)
        @test check_rate_limit(limiter, 100) == true

        # One more pushes over
        record_request(limiter, 10)
        @test check_rate_limit(limiter, 100) == false
    end

    # ========================================================================
    # Test: Embedding math (cosine similarity / distance)
    # ========================================================================
    @testset "Embedding mathematics" begin
        # Identical vectors → similarity 1.0
        v = [1.0, 0.0, 0.0]
        @test cosine_similarity(v, v) ≈ 1.0
        @test semantic_distance(v, v) ≈ 0.0

        # Orthogonal vectors → similarity 0.0
        v1 = [1.0, 0.0, 0.0]
        v2 = [0.0, 1.0, 0.0]
        @test cosine_similarity(v1, v2) ≈ 0.0
        @test semantic_distance(v1, v2) ≈ 1.0

        # Opposite vectors → similarity -1.0
        v3 = [-1.0, 0.0, 0.0]
        @test cosine_similarity(v, v3) ≈ -1.0

        # Mismatched lengths → 0.0
        @test cosine_similarity([1.0, 2.0], [1.0, 2.0, 3.0]) == 0.0

        # Empty vectors → 0.0
        @test cosine_similarity(Float64[], Float64[]) == 0.0

        # Zero vector → 0.0
        @test cosine_similarity([0.0, 0.0], [1.0, 2.0]) == 0.0
    end

end
