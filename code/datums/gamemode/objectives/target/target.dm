/datum/objective/target
	var/datum/mind/target = null	//If they are focused on a particular person.
	var/target_amount = 0	//If they are focused on a particular number. Steal objectives have their own counter.
	var/list/bad_assassinate_targets = list("AI","Cyborg","Mobile MMI","Trader")
	var/auto_target = TRUE //Whether we pick a target automatically on PostAppend()
	name = ""

/datum/objective/target/delayed
	var/delay = 10 MINUTES

/datum/objective/target/delayed/proc/PostDelay()

/datum/objective/target/delayed/ShuttleDocked(state)
	if(state == 1)
		PostDelay()

/datum/objective/target/New(var/text,var/auto_target = TRUE, var/mob/user = null)
	src.auto_target = auto_target
	if(text)
		explanation_text = text

/datum/objective/target/PostAppend()
	if(auto_target)
		return find_target()
	return TRUE

/datum/objective/target/delayed/PostAppend()
	if(emergency_shuttle.location || emergency_shuttle.direction == 2)
		PostDelay() //If the shuttle is docked or en route to centcomm, no delay
		return TRUE
	spawn(delay)
		PostDelay()
	return TRUE

/datum/objective/target/proc/find_target()
	var/list/possible_targets = get_targets()
	if(possible_targets.len > 0)
		target = pick(possible_targets)
		return TRUE
	return FALSE

/datum/objective/target/proc/get_targets()
	var/list/targets = list()
	for(var/datum/mind/possible_target in ticker.minds)
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.z != map.zCentcomm) && (possible_target.current.stat != DEAD) && !(possible_target.assigned_role in bad_assassinate_targets))
			targets += possible_target
	return targets

/datum/objective/target/proc/find_target_by_role(role, role_type = 0)//Option sets either to check assigned role or special role. Default to assigned.
	for(var/datum/mind/possible_target in ticker.minds)
		if((possible_target != owner) && ishuman(possible_target.current) && (possible_target.current.z != map.zCentcomm) && ((role_type ? possible_target.special_role : possible_target.assigned_role) == role) && !(possible_target.assigned_role in bad_assassinate_targets))
			target = possible_target
			return TRUE
			break
	return FALSE

/datum/objective/target/proc/is_valid_target(var/datum/mind/possible_target)
	if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.z != map.zCentcomm) && (possible_target.current.stat != DEAD) && !(possible_target.assigned_role in bad_assassinate_targets))
		return TRUE
	return FALSE

/datum/objective/target/proc/set_target(var/datum/mind/possible_target)
	if(is_valid_target(possible_target))
		target = possible_target
		explanation_text = format_explanation()
		return TRUE
	return FALSE


/datum/objective/target/proc/select_target()
	var/new_target = input("Select target:", "Objective target", null) as null|anything in get_targets()
	if(!new_target)
		return FALSE
	else
		target = new_target
		explanation_text = format_explanation()
		return TRUE
	return FALSE

/datum/objective/target/proc/format_explanation()
	return "Somebody didn't override the format explanation text here. Objective type is [type]. Target is [target.name], have fun."