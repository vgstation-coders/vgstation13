// Hunting controller from spiders
/datum/component/ai/hunt
	var/last_dir = 0 // cardinal direction
	var/last_was_bumped = 0 // Boolean, indicates whether the last movement resulted in a to_bump().
	var/life_tick = 0

	var/movement_range = 20 // Maximum range of points we move to (20 in spiders)

	var/targetfind_delay = 10

/datum/component/ai/hunt/initialize()
	active_components += src
	return TRUE

/datum/component/ai/hunt/Destroy()
	active_components -= src
	..()

/datum/component/ai/hunt/process()
	life_tick++
	if(parent.invoke_event(/event/comp_ai_cmd_get_busy))
		return
	switch(parent.invoke_event(/event/comp_ai_cmd_get_state))
		if(HOSTILE_STANCE_IDLE)
			var/atom/target = parent.invoke_event(/event/comp_ai_cmd_get_best_target)
			if(!isnull(target))
				parent.invoke_event(/event/comp_ai_cmd_set_target, list("target" = target))
				parent.invoke_event(/event/comp_ai_cmd_set_state, list("new_state" = HOSTILE_STANCE_ATTACK))
			else
				parent.invoke_event(/event/comp_ai_cmd_move, list("target" = pick(orange(movement_range, src))))
		if(HOSTILE_STANCE_ATTACK)
			var/atom/target = parent.invoke_event(/event/comp_ai_cmd_get_best_target)
			if(!isnull(target))
				// We're telling the attack modules that we have attack intention. They then individually decide whether to fire.
				parent.invoke_event(/event/comp_ai_cmd_attack, list("target" = target))
				var/turf/T = get_turf(target)
				if(T)
					parent.invoke_event(/event/comp_ai_cmd_move, list("target" = T))
					return
			parent.invoke_event(/event/comp_ai_cmd_set_state, list("new_state" = HOSTILE_STANCE_IDLE))
