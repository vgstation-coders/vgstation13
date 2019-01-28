/datum/component/ai/target_finder/zombie
	var/list/masters = list()

/datum/component/ai/target_finder/zombie/GetTargets()
	var/list/targets = list()
	for(var/mob/living/M in view(range, container.holder))
		if(is_type_in_list(M, exclude_types))
			continue
		if(iszombie(M))
			continue
		if(masters.Find(M))
			continue
		targets.Add(M)

	return targets


/datum/component_container/zombie