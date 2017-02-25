/datum/component/ai/target_holder/prioritizing
	var/list/targets= list()
	var/list/type_priorities = list(
			/mob/living = 1,
			// /mob/living/simple_animal/hostile/giant_spider=0,
			/obj/machinery/door = 2,
			/obj/machinery/light = 3
		)
	var/default_priority=2

	var/max_priority=3

	var/datum/component/ai/target_finder/finder = null

/datum/component/ai/target_holder/prioritizing/proc/attach()
	if(!finder)
		finder = GetComponent(/datum/component/ai/target_finder)

/datum/component/ai/target_holder/prioritizing/AddTarget(var/atom/A)
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

/datum/component/ai/target_holder/prioritizing/RemoveTarget(var/atom/A)
	for(var/priority in targets)
		if(A in targets[priority])
			targets[priority] -= A

/datum/component/ai/target_holder/prioritizing/GetBestTarget(var/objRef, var/procName, var/from_finder=1)
	if(from_finder)
		attach()
		targets.Cut() // Clear first
		//var/n=0
		for(var/atom/target in finder.GetTargets())
			AddTarget(target)
			//n++
		//testing("  TH: Got [n] targets from TF")
	for(var/priority=1;priority<=max_priority;priority++)
		var/list/priority_targets = targets["[priority]"]
		if(priority_targets == null)
			continue
		for(var/atom/target in sortMerge(priority_targets, cmp=/proc/cmp_dist_asc, associative=0, fromIndex=1, toIndex=priority_targets.len))
			if(call(objRef, procName)(target))
				return target
	return null
