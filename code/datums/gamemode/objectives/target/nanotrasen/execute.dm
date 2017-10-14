/datum/objective/target/anti_revolution/execute/find_target()
	..()
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [target.assigned_role] has extracted confidential information above their clearance. Execute \him[target.current]."
	return target


/datum/objective/target/anti_revolution/execute/find_target_by_role(role, role_type=FALSE)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] has extracted confidential information above their clearance. Execute \him[target.current]."
	return target

/datum/objective/target/anti_revolution/execute/IsFulfilled()
	..()
	if(target && target.current)
		if(target.current.isDead() || !ishuman(target.current))
			return TRUE
		return FALSE
	return TRUE
