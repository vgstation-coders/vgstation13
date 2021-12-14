/datum/component/ai/target_finder
	var/range=0
	var/list/exclude_types=list(
			/obj/effect,
			/atom/movable/light,
			/turf
	)

/datum/component/ai/target_finder/initialize()
	parent.register_event(/event/comp_ai_cmd_find_targets, src, .proc/cmd_find_targets)
	return TRUE

/datum/component/ai/target_finder/Destroy()
	parent.unregister_event(/event/comp_ai_cmd_find_targets, src, .proc/cmd_find_targets)
	..()

/datum/component/ai/target_finder/proc/cmd_find_targets()
	return list()
