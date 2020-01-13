/datum/objective/infect
	name = "Infect the crew."
	explanation_text = "Infect all humans."

/datum/objective/infect/IsFulfilled()
	if (..())
		return TRUE
	var/datum/faction/junglefever/F = find_active_faction_by_type(/datum/faction/junglefever)
	if(!F)
		return FALSE
	return F.lastratio >= 1