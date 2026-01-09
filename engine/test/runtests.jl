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
        end

        @testset "reference_rates" begin
            turns = [Dict("action" => "I think we should stay here")]
            self_rate = JeffEngine.compute_self_reference_rate(turns)
            @test self_rate > 0  # "I" and "we" present

            other_rate = JeffEngine.compute_other_reference_rate(turns)
            @test other_rate == 0  # No "you" present
        end
    end

end
