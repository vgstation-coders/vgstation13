/datum/objective/target/delayed/assassinate
	name = "Assassinate Unknown Target"

/datum/objective/target/delayed/assassinate/New()
	..()
	explanation_text = "Assassinate the [pick("data leaker","critical personnel","loved one of our enemy","mole","Nanotrasen asset","brilliant mind")]. We will have their identity in [delay/600] minutes."

/datum/objective/target/delayed/assassinate/PostDelay()
	if(auto_target && !target)
		if(find_target())
			explanation_text = format_explanation()
			if(owner)
				to_chat(owner.current,"<span class='warning'><BIG>We have identified our objective!</BIG></span>")
				to_chat(owner.current,"<span class='warning'>The target is [target.current.real_name], the [target.assigned_role=="MODE" ? (target.special_role) : (target.assigned_role)]. Commit that name to memory.</span>")
		else
			if(owner)
				to_chat(owner.current,"<span class='warning'><BIG>We have determined the target is not on this station. Redact assassination order.</BIG></warning>")
			qdel(src)

/datum/objective/target/delayed/assassinate/find_target()
	..()
	if(target && target.current)
		return TRUE
	return FALSE

/datum/objective/target/delayed/assassinate/select_target()
	//Not designed for manual selection
	return FALSE

/datum/objective/target/delayed/assassinate/format_explanation()
	if(target)
		return "Assassinate [target.current.real_name], the [target.assigned_role=="MODE" ? (target.special_role) : (target.assigned_role)]."
	else
		return "Assassinate the [pick("data leaker","critical personnel","loved one of our enemy","mole","potential threat to the Syndicate","Nanotrasen asset","brilliant mind")]."

/datum/objective/target/delayed/assassinate/get_targets()
	var/list/possible_targets = list()
	for(var/mob/living/carbon/human/H in player_list)
		if(!H.mind || H.gcDestroyed)
			continue
		var/datum/mind/possible_target = H.mind
		if(possible_target != owner && (possible_target.current.z != map.zCentcomm) && (possible_target.current.stat != DEAD) && !(possible_target.assigned_role in bad_assassinate_targets))
			possible_targets += possible_target
	return possible_targets

/datum/objective/target/delayed/assassinate/IsFulfilled()
	if (..())
		return TRUE
	//Same conditionals as normal assassinate
	if(target && target.current)
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || target.current.z > 6 || !target.current.ckey || isborer(target.current))
			return TRUE
		return FALSE
	return TRUE
