/datum/component/ai/target_finder/human
	range = 7
	var/datum/component/ai/human_brain/B

/datum/component/ai/target_finder/human/GetTargets()
	ASSERT(container.holder!=null)
	if(!B)
		B = GetComponent(/datum/component/ai/human_brain)
	var/list/o = list()
	for(var/mob/M in view(range, container.holder))
		if(is_type_in_list(M, exclude_types))
			continue
		if(M.isUnconscious())
			continue
		if((M in B.enemies) || (M.faction && M.faction in B.enemy_factions) || (M.type in B.enemy_types))
			o += M
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species && H.species.name in B.enemy_species)
				o += M
	return o

/datum/component/ai/target_finder/human/RecieveSignal(var/message_type, var/list/args)
	..()
	if(message_type == COMSIG_ATTACKEDBY) //YOU HAVE JUST MADE AN ENEMY FOR LIFE
		var/assailant = args["assailant"]
		var/damage_done = args["damage"]
		if(damage_done > 15) //Intent to kill!
			B.friends.Remove(assailant)
		if(damage_done > 2)
			B.enemies |= assailant