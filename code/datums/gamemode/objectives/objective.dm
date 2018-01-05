/datum/objective
	var/datum/mind/owner = null //Is the objective just yours?
	var/datum/faction/faction = null // Is the objective faction-wide?
	var/explanation_text = "Just be yourself." //What that person is supposed to do.
	var/is_void = FALSE // Universe is doomed what's the point.

/datum/objective/New(var/text)
	if(text)
		explanation_text = text

/datum/objective/proc/PostAppend()
	return 1

/datum/objective/proc/IsFulfilled()
	if(is_void)
		return FALSE

/datum/objective_holder
	var/list/datum/objective/objectives = list()

/datum/objective_holder/proc/AddObjective(var/datum/objective/O)
	ASSERT(!objectives.Find(O))
	objectives.Add(O)

/datum/objective_holder/proc/GetObjectives()
	return objectives

/datum/objective_holder/proc/FindObjective(var/datum/objective/O)
	return locate(O) in objectives

/datum/objective_holder/proc/GetObjectiveString(var/check_success = 0)
	var/dat = ""
	if(objectives.len == 0)
		dat += "EMPTY<br>"
	else
		var/obj_count = 1
		for(var/datum/objective/O in objectives)
			dat += {"<BR><B>Objective #[obj_count++]</b>: [O.explanation_text]"}
			if(check_success)
				dat += {"<BR>[O.IsFulfilled() ? "Success" : "Failed"]"}

	return dat