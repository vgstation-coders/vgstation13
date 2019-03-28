/datum/objective/eet/mindescape
	explanation_text = "Ensure no EET mind is left behind."
	name = "All EET Minds Escape"

/datum/objective/eet/mindescape/IsFulfilled()
	if (..())
		return TRUE
	if(!faction)
		return FALSE //no faction
	for(var/datum/role/R in faction.members)
		var/turf/T = get_turf(R.antag.current)
		if(!istype(T.loc,/area/shuttle/eet_mothership))
			return FALSE
	return TRUE