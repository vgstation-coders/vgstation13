// Hunting controller from spiders
/datum/component/ai/hunt
	var/last_dir=0 // cardinal direction
	var/last_was_bumped=0 // Boolean, indicates whether the last movement resulted in a to_bump().
	var/life_tick=0

	var/movement_range=20 // Maximum range of points we move to (20 in spiders)

	var/targetfind_delay=10
	var/datum/component/ai/target_holder/target_holder = null

/datum/component/ai/hunt/RecieveSignal(var/message_type, var/list/args)
	switch(message_type)
		if(COMSIG_LIFE) // no arguments
			OnLife()

		if(COMSIG_BUMPED) // list("movable"=AM)
			OnBumped(args["movable"])

/datum/component/ai/hunt/proc/OnLife()
	life_tick++
	//testing("HUNT LIFE, controller=[!isnull(controller)], busy=[controller && controller.getBusy()], state=[controller && controller.getState()]")
	if(!target_holder)
		target_holder = GetComponent(/datum/component/ai/target_holder)
	if(!controller)
		controller = GetComponent(/datum/component/controller)
	if(controller.getBusy())
		return
	switch(controller.getState())
		if(HOSTILE_STANCE_IDLE)
			var/atom/target = target_holder.GetBestTarget(src, "target_evaluator")
			//testing("  IDLE STANCE, target=\ref[target]")
			if(!isnull(target))
				SendSignal(COMSIG_TARGET, list("target"=target))
				SendSignal(COMSIG_STATE, list("state"=HOSTILE_STANCE_ATTACK))
			else
				SendSignal(COMSIG_MOVE, list("loc" = pick(orange(movement_range, src))))
		if(HOSTILE_STANCE_ATTACK)
			var/atom/target = target_holder.GetBestTarget(src, "target_evaluator")
			//testing("  ATTACK STANCE, target=\ref[target]")
			if(!isnull(target))
				var/turf/T = get_turf(target)
				container.SendSignalToFirst(/datum/component/ai, COMSIG_ATTACKING, list("target"=target)) // We're telling the attack modules that we have attack intention.  They then individually decide whether to fire.
				if(T)
					SendSignal(COMSIG_MOVE, list("loc" = T))
					return
			SendSignal(COMSIG_STATE, list("state"=HOSTILE_STANCE_IDLE)) // Lost target

/datum/component/ai/hunt/proc/OnBumped(var/atom/movable/AM)
	// TODO

/datum/component/ai/hunt/proc/target_evaluator(var/atom/target)
	return TRUE
