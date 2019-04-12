// Legacy cult

/datum/objective/massacre
    name = "Clean the station of unbelievers."
    explanation_text = "Nar-Sie wants to watch you as you massacre the remaining unbelievers on the station (until less than 5 unbelievers are left alive)."
    var/massacre_target = 5
    flags =  FACTION_OBJECTIVE


/datum/objective/massacre/IsFulfilled()
    var/living_still = 0
    for (var/mob/living/player in player_list)
        if (!islegacycultist(player) && !isconstruct(player))
            living_still++
        
    return (living_still < massacre_target)