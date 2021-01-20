var/list/assassination_objectives = list()

/datum/objective/target/assassinate
	name = "Assassinate <target>"
	var/syndicate_checked = 0

/datum/objective/target/assassinate/New(var/text,var/auto_target = TRUE, var/mob/user = null)
	..()
	assassination_objectives += src

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
	switch (syndicate_checked)
		if (SYNDICATE_VALIDATED)
			return TRUE
		if (SYNDICATE_CANCELED)
			return FALSE
	if(target && target.current)
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || target.current.z > 6 || !target.current.ckey || isborer(target.current))
			return TRUE
		return FALSE
	return TRUE

/datum/objective/target/assassinate/proc/SyndicateCertification()
	if (syndicate_checked == SYNDICATE_CANCELED)//if your death was reported prior, you're out of the race. Better luck next time.
		return

	syndicate_checked = SYNDICATE_VALIDATED

	//The syndicate has confirmed that the double agent has taken out their target.
	//They will now assign the new objective of assassinating their old target's target.
	//Unless said target is themselves, which then means that all other agents have been eliminated and they have won.
	var/datum/role/traitor/challenger/self = owner.GetRole(CHALLENGER)
	var/datum/role/traitor/challenger/enemy = target.GetRole(CHALLENGER)
	if (!self ||!enemy)
		return

	for (var/datum/objective/target/assassinate/A in enemy.objectives.objectives)
		if (A.syndicate_checked)
			continue
		if (A.target == owner)
			to_chat(owner.current, "<span class='notice'>The Syndicate congratulates you on your Victory. Look forward to be assigned on higher risk operations another day.</span>")
		else
			var/obj/item/device/uplink/hidden/guplink = owner.find_syndicate_uplink()
			if (guplink)
				guplink.uses += DOUBLE_AGENT_TC_REWARD
				to_chat(owner.current, "<span class='notice'>Good work agent. [DOUBLE_AGENT_TC_REWARD] additional tele-crystals have been sent to your uplink.</span>")
			else
				to_chat(owner.current, "<span class='notice'>Good work agent. Unfortunately we couldn't find your uplink on your person, so no additional tele-crystals could be distributed.</span>")
			var/datum/objective/target/assassinate/new_kill_target = new(auto_target = FALSE)
			if(new_kill_target.set_target(A.target))
				self.AppendObjective(new_kill_target)
				to_chat(owner.current, "<b>New Objective</b>: [new_kill_target.explanation_text]<br>")
			A.syndicate_checked = SYNDICATE_CANCELED
			to_chat(target.current, "<span class='warning'>The Syndicate has taken note of your demise. You are therefore ineligible for victory this time around. Better luck next time!</span>")
