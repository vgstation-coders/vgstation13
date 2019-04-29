/datum/objective/killorstealAI
	name = "\[Ninja\] Dominate AI"
	explanation_text = "Assert our dominance of artificial intelligence. Steal a functional AI or kill all AIs on the station."

/datum/objective/killorstealAI/IsFulfilled()
	if (..())
		return TRUE
	var/all_ai_dead = TRUE
	var/turf/goal_turf = get_turf(owner.current)
	for(var/mob/living/silicon/ai/A in ai_list)
		var/turf/T = get_turf(A)
		if(T == goal_turf)
			return TRUE //An AI was located on the same tile as us, so we stole it.
		if(T.z == STATION_Z && !(A.stat==DEAD))
			all_ai_dead = FALSE
			break
	return all_ai_dead