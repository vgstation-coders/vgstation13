/datum/objective/target/assassinate/erase
	name = "Erase <target>"
	var/target_erased = FALSE

/datum/objective/target/assassinate/erase/IsFulfilled()
	if(..())
		return TRUE
	return target_erased

/datum/objective/target/assassinate/erase/format_explanation()
	if(target_erased)
		return "Target erased."
	else
		return "Remove [target.current.real_name], the [target.assigned_role=="MODE" ? (target.special_role) : (target.assigned_role)] from the timeline with your timeline eraser. Dead or alive counts, but the process takes time and is very noticeable to anyone in the vicinity."

/datum/objective/target/assassinate/erase/proc/check(var/atom/eraser_target)
	if(istype(eraser_target, /mob))
		var/mob/M = eraser_target
		if(M.mind == target)
			target_erased = TRUE
	IsFulfilled()
