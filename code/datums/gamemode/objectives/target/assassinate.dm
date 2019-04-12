/datum/objective/target/assassinate
	name = "Assassinate <target>"

/datum/objective/target/assassinate/find_target()
	..()
	if(target && target.current)
		explanation_text = format_explanation()
		return TRUE
	return FALSE


/datum/objective/target/assassinate/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = format_explanation()
		return TRUE
	return FALSE

/datum/objective/target/assassinate/select_target()
	var/list/possible_targets = get_targets()

	var/new_target = input("Select target:", "Objective target", null) as null|anything in possible_targets
	if(new_target)
		target = new_target
		explanation_text = format_explanation()
		return TRUE
	return FALSE

/datum/objective/target/assassinate/format_explanation()
	return "Assassinate [target.current.real_name], the [target.assigned_role=="MODE" ? (target.special_role) : (target.assigned_role)]."

/datum/objective/target/assassinate/get_targets()
	var/list/possible_targets = list()
	for(var/mob/living/carbon/human/H in player_list)
		if(!H.mind || H.gcDestroyed)
			continue
		var/datum/mind/possible_target = H.mind
		if(possible_target != owner && (possible_target.current.z != map.zCentcomm) && (possible_target.current.stat != DEAD) && !(possible_target.assigned_role in bad_assassinate_targets))
			possible_targets += possible_target
	return possible_targets

/datum/objective/target/assassinate/IsFulfilled()
	if (..())
		return TRUE
	//Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
	// If they're in an away mission/custom z-level by the time you're checking this might as well count them as MIA
	if(target && target.current)
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || target.current.z > 6 || !target.current.ckey || isborer(target.current))
			return TRUE
		return FALSE
	return TRUE