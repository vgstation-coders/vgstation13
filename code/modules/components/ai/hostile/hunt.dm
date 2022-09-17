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
	if(INVOKE_EVENT(parent, /event/comp_ai_cmd_get_busy))
		return
	var/result = INVOKE_EVENT(parent, /event/comp_ai_cmd_get_state)
	switch(result)
		if(HOSTILE_STANCE_IDLE)
			var/atom/target = INVOKE_EVENT(parent, /event/comp_ai_cmd_get_best_target)
			if(!isnull(target))
				INVOKE_EVENT(parent, /event/comp_ai_cmd_set_target, "target" = target)
				INVOKE_EVENT(parent, /event/comp_ai_cmd_set_state, "new_state" = HOSTILE_STANCE_ATTACK)
			else
				INVOKE_EVENT(parent, /event/comp_ai_cmd_move, "target" = pick(orange(movement_range, src)))
		if(HOSTILE_STANCE_ATTACK)
			var/atom/target = INVOKE_EVENT(parent, /event/comp_ai_cmd_get_best_target)
			if(!isnull(target))
				// We're telling the attack modules that we have attack intention. They then individually decide whether to fire.
				INVOKE_EVENT(parent, /event/comp_ai_cmd_attack, "target" = target)
				var/turf/T = get_turf(target)
				if(T)
					INVOKE_EVENT(parent, /event/comp_ai_cmd_move, "target" = T)
					return
			INVOKE_EVENT(parent, /event/comp_ai_cmd_set_state, "new_state" = HOSTILE_STANCE_IDLE)
