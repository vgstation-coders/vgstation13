// Legacy cult

/datum/objective/defile
    name = "Defile the station"
    explanation_text = "Do not allow anyone to escape alive."

    flags =  FACTION_OBJECTIVE


/datum/objective/defile/IsFulfilled()
    for (var/mob/living/player in player_list)
        if (!iscultist(player) && !isconstruct(player))
            return FALSE