// For legacy cult

/datum/objective/target/assassinate/sacrifice
	name = "Sacrifice <target>"
	flags = FACTION_OBJECTIVE

/datum/objective/target/assassinate/sacrifice/PostAppend()
	faction = find_active_faction(LEGACY_CULT)
	if (!find_target())
		message_admins("Could not find a target to sacrifice, rerolling objectives the hard way.")
		var/datum/faction/cult/narsie/cult = faction
		cult.getNewObjective()
		CRASH("Could not find a target to sacrifice, rereolling objectives the hard way.") // Crash, so that it doesn't try to pass the bugged objective to the rest of the proc.
		return FALSE
	return TRUE

/datum/objective/target/assassinate/sacrifice/find_target()
	target = pick(get_targets())
	if(target && target.current)
		name = "Sacrifice [target.name]"
		explanation_text = "We need to sacrifice [target.name], the [target.assigned_role=="MODE" ? (target.special_role) : (target.assigned_role)], for his blood is the key that will lead our master to this realm. You will need 3 cultists around a Sacrifice rune (Hell Blood Join) to perform the ritual."
		return TRUE
	return FALSE

/datum/objective/target/assassinate/sacrifice/proc/get_targets()
	var/list/possible_targets = list()
	for(var/mob/living/carbon/human/player in player_list)
		if(player.z == map.zCentcomm) //We can't sacrifice people that are on the centcom z-level
			continue
		if(player.mind && !is_convertable_to_cult(player.mind) && (player.stat != DEAD))
			possible_targets += player.mind

	if(!possible_targets.len)
		//There are no living Unconvertables on the station. Looking for a Sacrifice Target among the ordinary crewmembers
		for(var/mob/living/carbon/human/player in player_list)
			if(player.z == map.zCentcomm) //We can't sacrifice people that are on the centcom z-level
				continue
			if(player.mind && !(islegacycultist(player)))
				possible_targets += player.mind

	if(!possible_targets.len)
		message_admins("Didn't find a suitable sacrifice target...what the hell? Shout at Deity.")
		return FALSE

	return possible_targets

/datum/objective/target/assassinate/sacrifice/feedbackText()
	if(target && target.current)
		return "<span class = 'sinister'>You succesfully sacrificied [target.current.real_name]. The veil between this world and Nar'Sie grows thinner.</span>"
