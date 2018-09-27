/datum/objective
	var/datum/mind/owner = null //Is the objective just yours?
	var/datum/faction/faction = null // Is the objective faction-wide?
	var/explanation_text = "Just be yourself." //What that person is supposed to do.
	var/force_success = FALSE //Allows admins to toggle the completion of custom objectives.
	var/name = ""

	var/flags = 0 // Objective flags.

/datum/objective/target/New(var/text,var/auto_target = TRUE)
	if(text)
		explanation_text = text

/datum/objective/target/Destroy()
	owner = null
	faction = null
	..()

/**
	Used for post-adding things, such as objective/target finding a target that isn't the owner of this objective.
	Return: TRUE if succesful, FALSE otherwise
*/

/datum/objective/proc/PostAppend()
	return TRUE

/datum/objective/proc/IsFulfilled()
	if(force_success)
		return TRUE
	return FALSE

/datum/objective/proc/feedbackText()

/datum/objective_holder
	var/list/datum/objective/objectives = list()
	var/datum/mind/owner = null
	var/datum/faction/faction = null

/datum/objective_holder/proc/AddObjective(var/datum/objective/O, var/datum/mind/M, var/datum/faction/F)
	ASSERT(!objectives.Find(O))
	objectives.Add(O)
	if(M)
		O.owner = M
	if(F)
		faction = F
	if(O.PostAppend())
		return TRUE
	else
		objectives.Remove(O)
		qdel(O)
		return FALSE

/datum/objective_holder/proc/GetObjectives()
	return objectives

/datum/objective_holder/proc/FindObjective(var/datum/objective/O)
	return locate(O) in objectives

/datum/objective_holder/proc/GetObjectiveString(var/check_success = 0,var/admin_edit = 0,var/datum/mind/M, var/datum/role/R)
	var/dat = ""
	if(objectives.len)
		var/obj_count = 1
		for(var/datum/objective/O in objectives)
			var/current_completion = O.IsFulfilled()
			dat += {"<b>Objective #[obj_count++]</b>: [O.explanation_text]
				[admin_edit ? " - <a href='?src=\ref[M];obj_delete=\ref[O];obj_holder=\ref[src]'>(remove)</a> - <a href='?src=\ref[M];obj_completed=\ref[O];obj_holder=\ref[src]'>(toggle:[current_completion ? "<font color='green'>SUCCESS" : "<font color='red'>FAILURE" ]</font>)</a>" : ""]
				<br>"}
			if(check_success)
				dat += {"<BR>[current_completion ? "Success" : "Failed"]"}
	if(admin_edit)
		if (owner)
			dat += "<a href='?src=\ref[M];obj_add=1;obj_holder=\ref[src]'>(add personal objective)</a>"
		else if (faction)
			dat += "<a href='?src=\ref[M];obj_add=1;obj_holder=\ref[src]'>(add faction objective)</a>"
		dat += "<br><a href='?src=\ref[M];obj_gen=1;obj_holder=\ref[src];[faction?"obj_owner=\ref[faction]":"obj_owner=\ref[R]"]'>(generate objectives)</a>"
	return dat
