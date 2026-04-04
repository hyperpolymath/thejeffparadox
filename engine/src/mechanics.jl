"""
Game mechanics: dice, skills, chaos, exposure, faction.
"""

# ============================================================================
# Dice Mechanics
# ============================================================================

"""
    roll_dice(count::Int, sides::Int) -> Vector{Int}

Roll `count` dice with `sides` sides each.
"""
function roll_dice(count::Int, sides::Int)::Vector{Int}
    [rand(1:sides) for _ in 1:count]
end

"""
    roll_with_modifier(count::Int, sides::Int, modifier::Int) -> Int

Roll dice and add modifier.
"""
function roll_with_modifier(count::Int, sides::Int, modifier::Int)::Int
    sum(roll_dice(count, sides)) + modifier
end

"""
    contested_roll(roller_mod::Int, target_mod::Int) -> Tuple{Int,Int,Symbol}

Perform contested roll. Returns (roller_result, target_result, winner).
"""
function contested_roll(roller_mod::Int, target_mod::Int)::Tuple{Int,Int,Symbol}
    roller = roll_with_modifier(2, 6, roller_mod)
    target = roll_with_modifier(2, 6, target_mod)

    winner = roller > target ? :roller : (target > roller ? :target : :tie)
    (roller, target, winner)
end

# ============================================================================
# Skill Resolution
# ============================================================================

const SKILL_CHAOS_RISK = Dict(
    "telekinesis" => (2, 6),
    "shape-shifting" => (1, 6),
    "memory extraction" => (3, 6),
    "probability manipulation" => (1, 6),
    "temporal perception" => (2, 6)
)

"""
    apply_skill(skill_name::String, witnessed::Bool) -> Tuple{Bool,Int}

Attempt to use a skill. Returns (success, chaos_increase).
"""
function apply_skill(skill_name::String, witnessed::Bool)::Tuple{Bool,Int}
    skill_lower = lowercase(skill_name)

    if !haskey(SKILL_CHAOS_RISK, skill_lower)
        return (false, 0)
    end

    dice_count, dice_sides = SKILL_CHAOS_RISK[skill_lower]
    chaos_roll = sum(roll_dice(dice_count, dice_sides))

    # Double chaos if witnessed
    if witnessed
        chaos_roll *= 2
    end

    # Skill succeeds on 2d6 >= 7
    success_roll = sum(roll_dice(2, 6))
    success = success_roll >= 7

    (success, chaos_roll)
end

# ============================================================================
# Chaos Management
# ============================================================================

"""
    update_chaos(current::Int, delta::Int, trigger_check::Bool) -> Tuple{Int,Bool}

Update chaos counter. Returns (new_value, threshold_triggered).
"""
function update_chaos(current::Int, delta::Int, trigger_check::Bool=true)::Tuple{Int,Bool}
    new_value = clamp(current + delta, 0, 100)
    triggered = trigger_check && new_value >= 80 && current < 80
    (new_value, triggered)
end

"""
    chaos_event_description(chaos_level::Int) -> String

Generate description of chaos state for narration.
"""
function chaos_event_description(chaos_level::Int)::String
    if chaos_level < 20
        "The Jeff maintains coherent control. The body moves smoothly, unified."
    elseif chaos_level < 40
        "Slight tremors of internal discord. A moment's hesitation before actions."
    elseif chaos_level < 60
        "The competing voices grow louder. Decisions come with visible strain."
    elseif chaos_level < 80
        "The body stutters between intentions. Observers might notice something wrong."
    else
        "CRITICAL: The alien nature threatens to surface. Reality bends around The Jeff."
    end
end

# ============================================================================
# Exposure Management
# ============================================================================

"""
    update_exposure(current::Int, delta::Int) -> Tuple{Int,Symbol}

Update exposure counter. Returns (new_value, status).
Status: :safe, :investigation, :containment
"""
function update_exposure(current::Int, delta::Int)::Tuple{Int,Symbol}
    new_value = clamp(current + delta, 0, 100)

    status = if new_value < 50
        :safe
    elseif new_value < 90
        :investigation
    else
        :containment
    end

    (new_value, status)
end

"""
    exposure_event_description(exposure_level::Int) -> String

Generate description of exposure state for narration.
"""
function exposure_event_description(exposure_level::Int)::String
    if exposure_level < 20
        "The Jeff blends seamlessly. Another face in the crowd."
    elseif exposure_level < 50
        "Some glances linger too long. Questions unasked but forming."
    elseif exposure_level < 70
        "Rumours circulate. Someone is taking notes."
    elseif exposure_level < 90
        "Authorities have been notified. The net tightens."
    else
        "CRITICAL: Containment protocols activated. The Jeff is hunted."
    end
end

# ============================================================================
# Faction Mechanics
# ============================================================================

"""
    shift_faction(current::Int, action_alignment::Symbol, intensity::Int) -> Int

Shift faction slider based on action alignment.
"""
function shift_faction(current::Int, action_alignment::Symbol, intensity::Int=1)::Int
    delta = intensity * (action_alignment == :homeward ? -5 : 5)
    clamp(current + delta, -100, 100)
end

"""
    faction_dominance(slider::Int) -> Union{Symbol,Nothing}

Check if either faction has achieved dominance (|slider| >= 75).
"""
function faction_dominance(slider::Int)::Union{Symbol,Nothing}
    if slider <= -75
        :homeward
    elseif slider >= 75
        :earthbound
    else
        nothing
    end
end

"""
    faction_state_description(slider::Int) -> String

Describe the current faction balance.
"""
function faction_state_description(slider::Int)::String
    if slider <= -75
        "Homeward dominance: The pull of origin overwhelms. Earth fades to memory."
    elseif slider <= -40
        "Homeward leaning: The stars call. Integration feels like betrayal."
    elseif slider <= -10
        "Slight Homeward tendency: Nostalgia colours perception."
    elseif slider < 10
        "Balance: Both factions hold equal sway. Every choice matters."
    elseif slider < 40
        "Slight Earthbound tendency: This place begins to feel like home."
    elseif slider < 75
        "Earthbound leaning: Human connections deepen. Return seems abstract."
    else
        "Earthbound dominance: The Jeff chooses Earth. There is no going back."
    end
end

# ============================================================================
# Threshold Events
# ============================================================================

"""
    check_thresholds(chaos::Int, exposure::Int, faction::Int) -> Vector{Symbol}

Check all thresholds and return triggered events.
"""
function check_thresholds(chaos::Int, exposure::Int, faction::Int)::Vector{Symbol}
    events = Symbol[]

    if chaos >= 80
        push!(events, :alien_emergence)
    end

    if exposure >= 50 && exposure < 90
        push!(events, :investigation)
    elseif exposure >= 90
        push!(events, :containment)
    end

    dominance = faction_dominance(faction)
    if dominance !== nothing
        push!(events, dominance == :homeward ? :homeward_victory : :earthbound_victory)
    end

    events
end
