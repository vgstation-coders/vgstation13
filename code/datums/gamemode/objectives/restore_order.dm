/datum/objective/restore_order
	explanation_text = "Restore order to the station."
	name = "Restore order"

/datum/objective/restore_order/IsFulfilled()
	return count_living_antags() == 0

/proc/count_living_antags()
	var/living_antags = 0
	for(var/mob/guy in player_list)
		if(!guy.client)
			continue
		if(istype(guy, /mob/new_player))
			continue
		if(guy.stat == DEAD)
			continue
		if(!guy.mind || !length(guy.mind.antag_roles))
			continue
		living_antags++
	return living_antags
