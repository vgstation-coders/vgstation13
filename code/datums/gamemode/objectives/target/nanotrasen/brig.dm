/datum/objective/target/anti_revolution/brig
	var/already_completed = FALSE

/datum/objective/target/anti_revolutiontarget/brig/find_target()
	..()
	if(target && target.current)
		explanation_text = "Brig [target.current.real_name], the [target.assigned_role] for 20 minutes to set an example."
	return target


/datum/objective/target/anti_revolution/brig/find_target_by_role(role, role_type=FALSE)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Brig [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] for 20 minutes to set an example."
	return target

/datum/objective/target/anti_revolution/brig/IsFulfilled()
	..()
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
