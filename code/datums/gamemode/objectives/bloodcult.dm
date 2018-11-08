
/datum/objective/bloodcult_reunion
	explanation_text = "The Reunion: Meet up with your fellow cultists, and erect an altar."
	name = "Cult: Prologue"

/datum/objective/bloodcult_reunion/PostAppend()
	message_admins("Blood Cult: A cult dedicated to Nar-Sie has formed aboard the station.")
	return TRUE

/datum/objective/bloodcult_followers
	explanation_text = "The Followers: Perform the conversion ritual on X crew members."
	name = "Cult: ACT I"
	var/convert_target = 4

/datum/objective/bloodcult_followers/PostAppend()
	explanation_text = "The Followers: Perform the conversion ritual on [convert_target] crew members."
	message_admins("Blood Cult: ACT I has begun.")
	return TRUE

/datum/objective/bloodcult_sacrifice
	explanation_text = "The Sacrifice: Nar-Sie requires the flesh of X to breach reality. Sacrifice them at an altar using a cult blade."
	name = "Cult: ACT II"
	var/mob/living/sacrifice_target = null

/datum/objective/bloodcult_sacrifice/PostAppend()
	sacrifice_target = find_target()
	if (sacrifice_target)
		var/target_role = (sacrifice_target.assigned_role=="MODE") ? "" : ", the ([sacrifice_target.assigned_role]),"
		if (iscultist(sacrifice_target))
			target_role = ", the cultist,"
		explanation_text = "The Sacrifice: Nar-Sie requires the flesh of [sacrifice_target.real_name][sacrifice_target.assigned_role=="MODE" ? "" : ", the (sacrifice_target.assigned_role),"] to breach reality. Sacrifice them at an altar using a cult blade."
		message_admins("Blood Cult: ACT II has begun, the sacrifice target is [sacrifice_target.real_name][sacrifice_target.assigned_role=="MODE" ? "" : ", the (sacrifice_target.assigned_role),"].")
		return TRUE
	else
		sleep(60 SECONDS)//kind of a failsafe should the entire server cooperate to cause this to occur, but that shouldn't logically ever happen anyway.
		return PostAppend()

/datum/objective/bloodcult_sacrifice/proc/find_target()
	var/list/possible_targets = list()
	for(var/mob/living/carbon/human/player in player_list)
		if(player.z != map.zMainStation)//We only look for people currently aboard the station
			continue
		//They may be dead, but we only need their flesh
		possible_targets += player

	if(!possible_targets.len)
		message_admins("Blood Cult: Could not find a suitable sacrifice target. Trying again in a minute.")
		return null

	return pick(possible_targets)

/datum/objective/bloodcult_bloodbath
	explanation_text = "The Blood Bath: The blood stones have risen. Spill blood accross the station to fill them up before the crew destroys them all."
	name = "Cult: ACT III"
	var/target_bloodspill = 5//percent of all the station's simulated floors

/datum/objective/bloodcult_bloodbath/PostAppend()
	message_admins("Blood Cult: ACT III has begun.")
	return TRUE

/datum/objective/bloodcult_tearinreality
	explanation_text = "The Tear in Reality: Chant around the anchor blood stone to stretch the breach enough so Nar-Sie may come through."
	name = "Cult: ACT IV"
	var/obj/structure/cult/bloodstone/anchor = null

/datum/objective/bloodcult_tearinreality/PostAppend()
	message_admins("Blood Cult: ACT IV has begun.")
	return TRUE

/datum/objective/bloodcult_feast
	explanation_text = "The Feast: This is your victory, you may take part in the celebrations of a work well done."
	name = "Cult: Epilogue"
	var/timer = 600 SECONDS

/datum/objective/bloodcult_feast/PostAppend()
	message_admins("Blood Cult: The cult has won.")
	return TRUE
