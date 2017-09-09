// Similar to the anti-rev objective, but for traitors
/datum/objective/target/brig
	var/already_completed = FALSE

/datum/objective/target/brig/find_target()
	..()
	if(target && target.current)
		explanation_text = "Have [target.current.real_name], the [target.assigned_role] brigged for 5 minutes."
	return target


/datum/objective/target/brig/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Have [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] brigged for 10 minutes."
	return target

/datum/objective/target/brig/IsFulfilled()
	..()
	if(already_completed)
		return TRUE
	if(target && target.current)
		if(target.current.stat == DEAD)
			return FALSE
		// Make the actual required time a bit shorter than the official time
		if(target.is_brigged(5 MINUTES))
			already_completed = TRUE
			return TRUE
		return FALSE
	return FALSE
