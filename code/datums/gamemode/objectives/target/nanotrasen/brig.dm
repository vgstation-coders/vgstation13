
/datum/objective/target/anti_revolution
	name = "\[Nanotrasen\] Brig <target>"

/datum/objective/target/anti_revolution/brig
	var/already_completed = FALSE


/datum/objective/target/anti_revolutiontarget/brig/format_explanation()
	return "Brig [target.current.real_name], the [target.assigned_role] for 20 minutes to set an example."

/datum/objective/target/anti_revolution/brig/IsFulfilled()
	if (..())
		return TRUE
	if(already_completed)
		return TRUE

	if(target && target.current)
		if(target.current.isDead())
			return FALSE
		if(target.is_brigged(20 MINUTES))
			already_completed = TRUE
			return TRUE
		return FALSE
	return FALSE
