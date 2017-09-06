/datum/objective
	var/datum/mind/owner = null //Is the objective just yours?
	var/datum/faction/faction = null // Is the objective faction-wide?
	var/explanation_text = "Just be yourself." //What that person is supposed to do.
	var/is_void = FALSE // Universe is doomed what's the point.

/datum/objective/New(var/text)
	if(text)
		explanation_text = text

/datum/objective/proc/IsFulfilled()
	if(is_void)
		return FALSE

/datum/objective_holder
	var/list/datum/objective/objectives = list()
