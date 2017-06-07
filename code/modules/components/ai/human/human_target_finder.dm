/datum/component/ai/target_finder/human
	range = 7
	var/datum/component/ai/human_brain/B

/datum/component/ai/target_finder/human/GetTargets()
	ASSERT(container.holder!=null)
	if(!B)
		B = GetComponent(/datum/component/ai/human_brain)
	var/list/o = list()
	for(var/mob/M in view(range, container.holder))
		if(is_type_in_list(A, exclude_types))
			continue
		if((M in B.enemies) || (M.faction && M.faction in B.enemy_factions) || (M.type in B.enemy_types))
			o += M
	return o