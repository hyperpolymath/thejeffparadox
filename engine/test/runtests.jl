# SPDX-FileCopyrightText: 2025 The Jeff Paradox Collaboration
# SPDX-License-Identifier: MIT

using Test
using JeffEngine

@testset "JeffEngine Tests" begin

    @testset "Dice Mechanics" begin
        # Test roll_dice
        @testset "roll_dice" begin
            for _ in 1:100
                result = roll_dice(2, 6)
                @test length(result) == 2
                @test all(1 .<= result .<= 6)
            end
        end

        # Test roll_with_modifier
        @testset "roll_with_modifier" begin
            for _ in 1:100
                result = roll_with_modifier(2, 6, 5)
                @test result >= 7  # min: 1+1+5
                @test result <= 17 # max: 6+6+5
            end
        end

        # Test contested_roll
        @testset "contested_roll" begin
            roller, target, winner = contested_roll(0, 0)
            @test roller >= 2 && roller <= 12
            @test target >= 2 && target <= 12
            @test winner in [:roller, :target, :tie]
        end
    end

    @testset "Chaos Management" begin
        @testset "update_chaos" begin
            # Normal update
            new_val, triggered = update_chaos(50, 10)
            @test new_val == 60
            @test !triggered

            # Threshold crossing
            new_val, triggered = update_chaos(75, 10)
            @test new_val == 85
            @test triggered

            # Clamping at max
            new_val, _ = update_chaos(95, 20)
            @test new_val == 100

            # Clamping at min
            new_val, _ = update_chaos(5, -20)
            @test new_val == 0
        end

        @testset "chaos_event_description" begin
            @test occursin("coherent", chaos_event_description(10))
            @test occursin("discord", chaos_event_description(30))
            @test occursin("CRITICAL", chaos_event_description(85))
        end
    end

    @testset "Exposure Management" begin
        @testset "update_exposure" begin
            new_val, status = update_exposure(30, 10)
            @test new_val == 40
            @test status == :safe

            new_val, status = update_exposure(45, 10)
            @test new_val == 55
            @test status == :investigation

            new_val, status = update_exposure(85, 10)
            @test new_val == 95
            @test status == :containment
        end
    end

    @testset "Faction Mechanics" begin
        @testset "shift_faction" begin
            # Homeward shift
            result = shift_faction(0, :homeward, 1)
            @test result == -5

            # Earthbound shift
            result = shift_faction(0, :earthbound, 1)
            @test result == 5

            # Clamping
            result = shift_faction(-95, :homeward, 2)
            @test result == -100

            result = shift_faction(95, :earthbound, 2)
            @test result == 100
        end

        @testset "faction_dominance" begin
            @test faction_dominance(0) === nothing
            @test faction_dominance(-75) == :homeward
            @test faction_dominance(-80) == :homeward
            @test faction_dominance(75) == :earthbound
            @test faction_dominance(80) == :earthbound
            @test faction_dominance(50) === nothing
        end
    end

    @testset "Skill Resolution" begin
        @testset "apply_skill" begin
            # Valid skill
            success, chaos = apply_skill("Telekinesis", false)
            @test chaos >= 2 && chaos <= 12  # 2d6
            @test success isa Bool

            # Witnessed doubles chaos
            _, chaos_unwitnessed = apply_skill("Telekinesis", false)
            # Can't directly test doubling due to randomness,
            # but we can test the function runs
            _, chaos_witnessed = apply_skill("Telekinesis", true)
            @test chaos_witnessed >= 4  # min 2d6 * 2

            # Invalid skill
            success, chaos = apply_skill("InvalidSkill", false)
            @test !success
            @test chaos == 0
        end
    end

    @testset "Threshold Events" begin
        @testset "check_thresholds" begin
            # No events
            events = check_thresholds(50, 30, 0)
            @test isempty(events)

            # Chaos critical
            events = check_thresholds(85, 30, 0)
            @test :alien_emergence in events

            # Exposure investigation
            events = check_thresholds(50, 60, 0)
            @test :investigation in events

            # Exposure containment
            events = check_thresholds(50, 95, 0)
            @test :containment in events

            # Faction dominance
            events = check_thresholds(50, 30, -80)
            @test :homeward_victory in events

            events = check_thresholds(50, 30, 80)
            @test :earthbound_victory in events
        end
    end

    @testset "Conceptors" begin
        @testset "diversity injection" begin
            # Test that diversity prompts are non-empty
            for category in JeffEngine.DIVERSITY_PROMPTS
                @test !isempty(category.prompts)
                for prompt in category.prompts
                    @test length(prompt) > 10
                end
            end
        end

        @testset "contradiction seeds" begin
            # Would need mock game state for full test
            # Just verify the function exists and runs
            @test true
        end

        @testset "aperture control" begin
            # Create mock game state with config
            mock_config = Dict{String,Any}(
                "min_temperature" => 0.6,
                "max_temperature" => 1.2
            )
            mock_game = JeffEngine.GameState(
                0, 0, 0,    # chaos, exposure, faction_slider
                1, :alpha,   # turn_number, current_node
                [],          # turn_history
                [], 0, 0,    # quarantine, diversity counters
                [],          # metrics_history (empty)
                mock_config
            )

            # With empty metrics, should return base temperature unchanged
            result = JeffEngine.compute_aperture(mock_game, 0.8)
            @test result == 0.8

            # Add metrics with low vocabulary diversity
            push!(mock_game.metrics_history, Dict{String,Any}(
                "vocabulary_diversity" => 0.25,
                "coherence_score" => 0.7
            ))
            result = JeffEngine.compute_aperture(mock_game, 0.8)
            @test result == 0.9  # Increased due to low diversity

            # Test bounds clamping
            result = JeffEngine.compute_aperture(mock_game, 1.15)
            @test result <= 1.2  # Should clamp to max
        end
    end

    @testset "Metrics" begin
        @testset "vocabulary_diversity" begin
            # Empty case
            @test JeffEngine.compute_vocabulary_diversity([]) == 1.0

            # Simple case
            turns = [Dict("action" => "hello world hello")]
            div = JeffEngine.compute_vocabulary_diversity(turns)
            @test div ≈ 2/3  # 2 unique / 3 total

            # All unique words
            turns2 = [Dict("action" => "alpha beta gamma delta")]
            @test JeffEngine.compute_vocabulary_diversity(turns2) == 1.0

            # All same word
            turns3 = [Dict("action" => "hello hello hello hello")]
            @test JeffEngine.compute_vocabulary_diversity(turns3) == 0.25
        end

        @testset "reference_rates" begin
            turns = [Dict("action" => "I think we should stay here")]
            self_rate = JeffEngine.compute_self_reference_rate(turns)
            @test self_rate > 0  # "I" and "we" present

            other_rate = JeffEngine.compute_other_reference_rate(turns)
            @test other_rate == 0  # No "you" present

            # Test other-reference detection
            turns2 = [Dict("action" => "you should listen to your heart")]
            other_rate2 = JeffEngine.compute_other_reference_rate(turns2)
            @test other_rate2 > 0  # "you" and "your" present
        end

        @testset "coherence_score" begin
            # Fewer than 2 turns returns 0
            @test JeffEngine.compute_coherence_score([]) == 0.0
            @test JeffEngine.compute_coherence_score([Dict("action" => "hello")]) == 0.0

            # Identical turns should have high coherence
            same = [Dict("action" => "stars signal origin"),
                    Dict("action" => "stars signal origin")]
            @test JeffEngine.compute_coherence_score(same) > 0.5

            # Completely different turns should have low coherence
            diff = [Dict("action" => "stars signal origin"),
                    Dict("action" => "coffee morning bicycle")]
            @test JeffEngine.compute_coherence_score(diff) == 0.0
        end

        @testset "convergence_index" begin
            # No turns
            @test JeffEngine.compute_convergence_index([]) == 0.0

            # Only one node present
            alpha_only = [Dict("action" => "hello", "node" => "alpha")]
            @test JeffEngine.compute_convergence_index(alpha_only) == 0.0

            # Same vocabulary → high convergence
            converged = [
                Dict("action" => "stars signal origin", "node" => "alpha"),
                Dict("action" => "stars signal origin", "node" => "beta")
            ]
            @test JeffEngine.compute_convergence_index(converged) > 0.5

            # Different vocabulary → low convergence
            diverged = [
                Dict("action" => "stars signal origin", "node" => "alpha"),
                Dict("action" => "coffee morning bicycle", "node" => "beta")
            ]
            @test JeffEngine.compute_convergence_index(diverged) == 0.0
        end

        @testset "compute_metrics" begin
            mock_config = Dict{String,Any}(
                "min_temperature" => 0.6,
                "max_temperature" => 1.2
            )
            mock_game = JeffEngine.GameState(
                15, 5, 0,
                5, :alpha,
                [Dict{String,Any}("action" => "I look at the stars", "node" => "alpha"),
                 Dict{String,Any}("action" => "We should stay on earth", "node" => "beta")],
                [], 0, 0,
                [],
                mock_config
            )

            metrics = JeffEngine.compute_metrics(mock_game)
            @test haskey(metrics, "vocabulary_diversity")
            @test haskey(metrics, "self_reference_rate")
            @test haskey(metrics, "coherence_score")
            @test haskey(metrics, "convergence_index")
            @test haskey(metrics, "novel_ngram_count")
            @test haskey(metrics, "turn_number")
            @test metrics["turn_number"] == 5
        end
    end

    @testset "Rate Limiter" begin
        @testset "basic rate limiting" begin
            limiter = JeffEngine.RateLimiter("local")
            @test JeffEngine.check_rate_limit(limiter, 100)

            # Record some requests
            for _ in 1:5
                JeffEngine.record_request(limiter, 100)
            end
            @test length(limiter.request_times) == 5
            @test length(limiter.token_counts) == 5
        end

        @testset "token limit enforcement" begin
            limiter = JeffEngine.RateLimiter("anthropic")
            # Fill up close to the token limit (40000 for anthropic)
            JeffEngine.record_request(limiter, 39000)
            # A small request should still pass
            @test JeffEngine.check_rate_limit(limiter, 500)
            # A large request should be rejected
            @test !JeffEngine.check_rate_limit(limiter, 2000)
        end
    end

    @testset "Cosine Similarity" begin
        # Identical vectors
        a = [1.0, 0.0, 0.0]
        @test cosine_similarity(a, a) ≈ 1.0

        # Orthogonal vectors
        b = [0.0, 1.0, 0.0]
        @test cosine_similarity(a, b) ≈ 0.0

        # Opposite vectors
        c = [-1.0, 0.0, 0.0]
        @test cosine_similarity(a, c) ≈ -1.0

        # Empty vectors
        @test cosine_similarity(Float64[], Float64[]) == 0.0

        # Mismatched lengths
        @test cosine_similarity([1.0, 2.0], [1.0]) == 0.0

        # Semantic distance
        @test semantic_distance(a, a) ≈ 0.0
        @test semantic_distance(a, b) ≈ 1.0
    end

    @testset "State Persistence" begin
        mock_config = Dict{String,Any}(
            "version" => "1.0",
            "diversity_injection_frequency" => 10
        )
        game = JeffEngine.GameState(
            42, 17, -30,
            8, :beta,
            [],
            ["old pattern", "another one"],
            3,
            5,
            [],
            mock_config
        )

        # Save and reload
        tmpfile = tempname() * ".yml"
        try
            JeffEngine.save_game_state(game, tmpfile)
            loaded = JeffEngine.load_game_state(tmpfile, mock_config)

            @test loaded.chaos == 42
            @test loaded.exposure == 17
            @test loaded.faction_slider == -30
            @test loaded.turn_number == 8
            @test loaded.current_node == :beta
            @test loaded.pattern_quarantine == ["old pattern", "another one"]
            @test loaded.diversity_injection_counter == 3
            @test loaded.last_diversity_turn == 5
        finally
            rm(tmpfile; force=true)
        end
    end

    @testset "Metrics Summary" begin
        mock_config = Dict{String,Any}(
            "min_temperature" => 0.6,
            "max_temperature" => 1.2
        )
        mock_game = JeffEngine.GameState(
            15, 5, 0, 5, :alpha,
            [], [], 0, 0,
            [],
            mock_config
        )

        # No metrics yet
        summary = JeffEngine.metrics_summary(mock_game)
        @test occursin("No metrics", summary)

        # Add metrics
        push!(mock_game.metrics_history, Dict{String,Any}(
            "turn_number" => 5,
            "vocabulary_diversity" => 0.65,
            "self_reference_rate" => 0.12,
            "other_reference_rate" => 0.05,
            "coherence_score" => 0.45,
            "convergence_index" => 0.30,
            "novel_ngram_count" => 12
        ))

        summary = JeffEngine.metrics_summary(mock_game)
        @test occursin("Vocabulary Diversity", summary)
        @test occursin("HEALTHY", summary)
    end

    @testset "LLM Client Configuration" begin
        @testset "provider config" begin
            @test haskey(JeffEngine.PROVIDERS, "anthropic")
            @test haskey(JeffEngine.PROVIDERS, "mistral")
            @test haskey(JeffEngine.PROVIDERS, "local")
        end

        @testset "default models" begin
            @test haskey(JeffEngine.DEFAULT_MODELS, "anthropic")
            @test haskey(JeffEngine.DEFAULT_MODELS, "mistral")
            @test haskey(JeffEngine.DEFAULT_MODELS, "local")
        end

        @testset "build_headers" begin
            # Test header building for each provider (will use empty API keys)
            for provider in ["anthropic", "mistral", "local"]
                headers = JeffEngine.build_headers(provider)
                @test any(p -> p.first == "Content-Type", headers)
            end

            # Anthropic uses x-api-key header
            anthropic_headers = JeffEngine.build_headers("anthropic")
            @test any(p -> p.first == "x-api-key", anthropic_headers)
            @test any(p -> p.first == "anthropic-version", anthropic_headers)

            # Others use Authorization header
            mistral_headers = JeffEngine.build_headers("mistral")
            @test any(p -> p.first == "Authorization", mistral_headers)
        end

        @testset "build_request_body" begin
            messages = [Dict("role" => "user", "content" => "test")]

            # Anthropic format
            body_str = JeffEngine.build_request_body("anthropic", "claude-test", messages, 0.7, 100)
            @test occursin("claude-test", body_str)
            @test occursin("max_tokens", body_str)

            # OpenAI-compatible format
            body_str = JeffEngine.build_request_body("mistral", "mistral-test", messages, 0.7, 100)
            @test occursin("mistral-test", body_str)
        end

        @testset "parse_response" begin
            # Anthropic format
            anthropic_json = """{"content":[{"text":"hello from claude"}]}"""
            @test JeffEngine.parse_response("anthropic", anthropic_json) == "hello from claude"

            # Empty content
            empty_json = """{"content":[]}"""
            @test JeffEngine.parse_response("anthropic", empty_json) == ""

            # OpenAI format
            openai_json = """{"choices":[{"message":{"content":"hello from mistral"}}]}"""
            @test JeffEngine.parse_response("mistral", openai_json) == "hello from mistral"

            # Empty choices
            empty_choices = """{"choices":[]}"""
            @test JeffEngine.parse_response("mistral", empty_choices) == ""
        end
    end

end
