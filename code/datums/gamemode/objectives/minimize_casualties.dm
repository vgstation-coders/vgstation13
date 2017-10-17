/datum/objective/minimize_casualties
	explanation_text = "Minimise casualties."

/datum/objective/minimize_casualties/IsFulfilled()
	..()
	if(owner.kills.len > 5) //THIS IS TERRIBLE.
		return FALSE
	return TRUE
