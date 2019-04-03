/datum/objective/eet/organs
	explanation_text = "Abduct sentients and exchange natural organs for originally archived organs."
	name = "Implant Surgery (EET)"

/datum/objective/eet/organs/IsFulfilled()
	if(eet_tracked_organs.len)
		return FALSE
	return TRUE

/datum/objective/eet/organs/DatacoreQuery()
	return ..() + "; Unexchanged: [english_list(eet_tracked_organs)]"