/datum/objective/plague
	name = "Spread your disease."
	explanation_text = "Spread your disease among the station's inhabitants."
	var/diseaseID = ""
	var/total_infections = 0

/datum/objective/plague/extraInfo()
	var/current_infections = 0
	for (var/mob/living/L in mob_list)
		if (diseaseID in L.virus2)
			current_infections++
	explanation_text += " ([total_infections] infections caused in total. [current_infections] infected individuals remaining.)"

/datum/objective/plague/IsFulfilled()
	if (..())
		return TRUE

	if (total_infections > 1)
		for (var/mob/living/L in mob_list)
			if (diseaseID in L.virus2)
				return TRUE//if we infected at least one individual, and there is still an infected individual alive, that's good enough.

	return FALSE
