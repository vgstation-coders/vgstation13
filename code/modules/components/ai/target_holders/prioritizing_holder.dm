/datum/component/ai/target_holder/prioritizing
	var/list/targets= list()
	var/list/type_priorities = list(
		/mob/living = 1,
		// /mob/living/simple_animal/hostile/giant_spider=0,
		/obj/machinery/door = 2,
		/obj/machinery/light = 3
		)
	var/default_priority = 2

	var/max_priority = 3

	var/datum/component/ai/target_finder/finder = null

/datum/component/ai/target_holder/prioritizing/cmd_add_target(atom/A)
	var/priority=-1
	for(var/priority_type in type_priorities)
		if(istype(A, priority_type))
			priority = type_priorities[priority_type]
			break
	if(priority==-1) // Use default
		priority=default_priority
	if(priority==0) // Don't add
		return
	if(!("[priority]" in targets))
		targets["[priority]"] = list()
	if(!(A in targets["[priority]"]))
		targets["[priority]"] += A

/datum/component/ai/target_holder/prioritizing/cmd_remove_target(atom/A)
	for(var/priority in targets)
		if(A in targets[priority])
			targets[priority] -= A

/datum/component/ai/target_holder/prioritizing/cmd_get_best_target()
	targets.Cut() // Clear first
	for(var/atom/target in INVOKE_EVENT(parent, /event/comp_ai_cmd_find_targets))
		INVOKE_EVENT(parent, /event/comp_ai_cmd_add_target, "target" = target)
	for(var/priority in 1 to max_priority)
		var/list/priority_targets = targets["[priority]"]
		if(priority_targets == null)
			continue
		for(var/atom/target in sortMerge(priority_targets, cmp=/proc/cmp_dist_asc, associative=0, fromIndex=1, toIndex=priority_targets.len))
			return target
	return null
