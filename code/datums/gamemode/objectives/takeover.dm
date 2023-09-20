/datum/objective/takeover
	explanation_text = "Assume control."

/datum/objective/takeover/IsFulfilled()
	if (..())
		return TRUE
	var/datum/faction/malf/M = faction
	if(!M || !istype(M) || (M.stage < MALF_CHOOSING_NUKE))
		return FALSE
	return TRUE
