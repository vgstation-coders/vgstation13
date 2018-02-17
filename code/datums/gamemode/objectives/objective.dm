/datum/objective
	var/datum/mind/owner = null //Is the objective just yours?
	var/datum/faction/faction = null // Is the objective faction-wide?
	var/explanation_text = "Just be yourself." //What that person is supposed to do.
	var/is_void = FALSE // Universe is doomed what's the point.
	var/force_success = FALSE //Allows admins to toggle the completion of custom objectives.

/datum/objective/New(var/text)
	if(text)
		explanation_text = text

/datum/objective/proc/PostAppend()
	return 1

/datum/objective/proc/IsFulfilled()
	if(is_void)
		return FALSE
	if(force_success)
		return TRUE
	return FALSE

/datum/objective_holder
	var/list/datum/objective/objectives = list()

/datum/objective_holder/proc/AddObjective(var/datum/objective/O, var/datum/mind/M)
	ASSERT(!objectives.Find(O))
	objectives.Add(O)
	if(M)
		O.owner = M

/datum/objective_holder/proc/GetObjectives()
	return objectives

/datum/objective_holder/proc/FindObjective(var/datum/objective/O)
	return locate(O) in objectives

/datum/objective_holder/proc/GetObjectiveString(var/check_success = 0,var/admin_edit = 0)
	var/dat = ""
	if(objectives.len)
		var/obj_count = 1
		for(var/datum/objective/O in objectives)
			var/current_completion = O.IsFulfilled()
			dat += {"<b>Objective #[obj_count++]</b>: [O.explanation_text]
				[admin_edit ? " - <a href='?src=\ref[src];obj_edit=\ref[O]'>(edit)</a> - <a href='?src=\ref[src];obj_delete=\ref[O]'>(remove)</a> - <a href='?src=\ref[src];obj_completed=\ref[O]'>(toggle:[current_completion ? "<font color='green'>SUCCESS" : "<font color='red'>FAILURE" ]</font>)</a>" : ""]
				<br>"}
			if(check_success)
				dat += {"<BR>[current_completion ? "Success" : "Failed"]"}
	if(admin_edit)
		dat += "<a href='?src=\ref[src];obj_add=1'>(add personnal objective)</a>"
	return dat
