/datum/objective/target/assassinate/find_target()
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role=="MODE" ? (target.special_role) : (target.assigned_role)]."
	return target


/datum/objective/target/assassinate/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
	return target


/datum/objective/target/assassinate/IsFulfilled()
	..()
	//Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
	// If they're in an away mission/custom z-level by the time you're checking this might as well count them as MIA
	if(target && target.current)
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || target.current.z > 6 || !target.current.ckey || isborer(target.current))
			return TRUE
		return FALSE
	return TRUE
