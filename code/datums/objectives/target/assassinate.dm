/datum/objective/target/assassinate/find_target_by_role(var/role)
	for(var/datum/mind/possible_target in ticker.minds)
		if((possible_target != owner) && istype(possible_target.current, /mob/living/carbon/human) && (possible_target.assigned_role == role))
			target = possible_target
			break

	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [target.role_alt_title ? target.role_alt_title : target.assigned_role]."
	else
		explanation_text = "Free Objective"

	return target

/datum/objective/target/assassinate/find_target()
	var/list/possible_targets = list()

	for(var/datum/mind/possible_target in ticker.minds)
		if((possible_target != owner) && istype(possible_target.current, /mob/living/carbon/human))
			possible_targets += possible_target

	if(possible_targets.len > 0)
		target = pick(possible_targets)

	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [target.role_alt_title ? target.role_alt_title : target.assigned_role]."
	else
		explanation_text = "Free Objective"

	return target

/datum/objective/target/assassinate/find_target()
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role=="MODE" ? (target.special_role) : (target.assigned_role)]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/target/assassinate/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/target/assassinate/IsFulfilled()
	..()
	if(target && target.current)
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || target.current.z > 6 || !target.current.ckey || isborer(target.current)) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return TRUE
		return FALSE
	return TRUE
