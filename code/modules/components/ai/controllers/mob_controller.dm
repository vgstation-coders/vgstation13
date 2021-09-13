/datum/component/controller/mob
	var/walk_delay = 4

/datum/component/controller/mob/initialize()
	parent.register_event(/event/comp_ai_cmd_move, src, .proc/cmd_move)
	return TRUE

/datum/component/controller/mob/Destroy()
	parent.unregister_event(/event/comp_ai_cmd_move, src, .proc/cmd_move)
	..()

/datum/component/controller/mob/proc/cmd_move(target)
	if(!isnum(target))
		CRASH("unknown dir [target]")
	step(parent, target, walk_delay)
