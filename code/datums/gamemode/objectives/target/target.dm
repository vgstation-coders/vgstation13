/datum/objective/target
	var/datum/mind/target = null	//If they are focused on a particular person.
	var/datum/mind/delayed_target = null	//will become target after a delay
	var/target_amount = 0	//If they are focused on a particular number. Steal objectives have their own counter.
	var/list/bad_assassinate_targets = list("AI","Cyborg","Mobile MMI","Trader")
	var/auto_target = TRUE //Whether we pick a target automatically on PostAppend()
	var/delay = 0
	name = ""

/datum/objective/target/New(var/text,var/auto_target = TRUE, var/mob/user = null)
	src.auto_target = auto_target
	if(text)
		explanation_text = text

/datum/objective/target/PostAppend()
	if(auto_target)
		return find_target()
	if(delay && (emergency_shuttle.location || emergency_shuttle.direction == 2))
		PostDelay() //If the shuttle is docked or en route to centcomm, no delay
		return TRUE
	if (delay)
		spawn(delay)
			PostDelay()
	return TRUE

/datum/objective/target/ShuttleDocked(state)
	if (delay && !target && (state == 1))
		PostDelay()

/datum/objective/target/proc/PostDelay() // reveals the target
	target = delayed_target
	explanation_text = format_explanation()
	owner.current.playsound_local(owner.current.loc, 'sound/machines/twobeep.ogg', 75, 0)
	to_chat(owner.current, "<span class='userdanger'>Target Revealed</span>: <b>[explanation_text]</b>")

/datum/objective/target/proc/find_target()
	var/list/possible_targets = get_targets()
	if(possible_targets.len > 0)
		if (delay)
			delayed_target = pick(possible_targets)
			to_chat(owner.current, "<span class='danger'>Your target's identity will be revealed to you in [delay/600] MINUTE[(delay > 600) ? "S":""].</span>")
		else
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
	return FALSE

/datum/objective/target/proc/is_valid_target(var/datum/mind/possible_target)
	if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.z != map.zCentcomm) && (possible_target.current.stat != DEAD) && !(possible_target.assigned_role in bad_assassinate_targets))
		return TRUE
	return FALSE

/datum/objective/target/proc/set_target(var/datum/mind/possible_target,var/override = FALSE)
	if(override || is_valid_target(possible_target))
		if (delay)
			delayed_target = possible_target
			if (owner)
				to_chat(owner.current, "<span class='danger'>Your target's identity will be revealed to you in [delay/600] MINUTE[(delay > 600) ? "S":""].</span>")
		else
			target = possible_target
		explanation_text = format_explanation()
		return TRUE
	return FALSE


/datum/objective/target/proc/select_target()
	var/new_target = input("Select target:", "Objective target", null) as null|anything in get_targets()
	if(!new_target)
		return FALSE
	else
		if (delay)
			delayed_target = new_target
			to_chat(owner.current, "<span class='danger'>Your target's identity will be revealed to you in [delay/600] MINUTE[(delay > 600) ? "S":""].</span>")
		else
			target = new_target
		explanation_text = format_explanation()
		return TRUE

/datum/objective/target/format_explanation()
	return "Somebody didn't override the format explanation text here. Objective type is [type]. Target is [target.name], have fun."
