/datum/objective/target/protect/find_target() //The opposite of killing a dude.
	..()
	if(target && target.current)
		explanation_text = "Protect [target.current.real_name], the [target.assigned_role]."
	return target

/datum/objective/target/protect/find_target_by_role(role, role_type=FALSE)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Protect [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
	return target

/datum/objective/target/protect/IsFulfilled()
	..()
	if(target.current)
		if(target.current.isDead() || issilicon(target.current) || isbrain(target.current) || isborer(target.current))
			return FALSE
		return TRUE
	return FALSE
