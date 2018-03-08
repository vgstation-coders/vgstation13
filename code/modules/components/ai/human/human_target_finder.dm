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
		to_chat(world, "Receiving signal [message_type]")
		var/assailant = args["assailant"]
		var/damage_done = args["damage"]
		if(damage_done > 2 && !B.enemies.Find(assailant))
			to_chat(world, "[assailant] done fukd up nao")
			B.enemies.Add(assailant)
			for(var/mob/living/M in view(range, container.holder))
				if(M.isUnconscious() || !M.BrainContainer || !(M in B.friends))
					continue
				M.BrainContainer.SendSignal(COMSIG_ATTACKEDBY, list("assailant"=src,"damage"=damage_done)) //THEY'RE ATTACKING OUR BOY, GET HIM!