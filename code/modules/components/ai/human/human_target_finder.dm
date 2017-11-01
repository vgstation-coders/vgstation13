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
		if(M.stat)
			continue
		if((M in B.enemies) || (M.faction && M.faction in B.enemy_factions) || (M.type in B.enemy_types))
			o += M
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species && H.species.name in B.enemy_species)
				o += M
	return o