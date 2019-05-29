// Hunting controller from spiders
/datum/component/ai/hunt
	var/last_dir=0 // cardinal direction
	var/last_was_bumped=0 // Boolean, indicates whether the last movement resulted in a to_bump().
	var/life_tick=0

	var/movement_range=20 // Maximum range of points we move to (20 in spiders)

	var/targetfind_delay=10
	var/datum/component/ai/target_holder/target_holder = null

/datum/component/ai/hunt/Initialize()
	..()
	RegisterSignal(parent, COMSIG_LIFE, .proc/OnLife)
	RegisterSignal(parent, COMSIG_BUMPED, .proc/OnBumped)

/datum/component/ai/hunt/proc/OnLife()
	life_tick++
	//testing("HUNT LIFE, controller=[!isnull(controller)], busy=[controller && controller.getBusy()], state=[controller && controller.getState()]")
	if(!target_holder)
		target_holder = parent.GetComponent(/datum/component/ai/target_holder)
	if(!controller)
		controller = parent.GetComponent(/datum/component/controller)
	if(controller.getBusy())
		return
	switch(controller.getState())
		if(HOSTILE_STANCE_IDLE)
			var/atom/target = target_holder.GetBestTarget(src, "target_evaluator")
			//testing("  IDLE STANCE, target=\ref[target]")
			if(!isnull(target))
				SEND_SIGNAL(parent, COMSIG_TARGET, target)
				SEND_SIGNAL(parent, COMSIG_STATE, HOSTILE_STANCE_ATTACK)
			else
				SEND_SIGNAL(parent, COMSIG_MOVE, pick(orange(movement_range, src)))
		if(HOSTILE_STANCE_ATTACK)
			var/atom/target = target_holder.GetBestTarget(src, "target_evaluator")
			//testing("  ATTACK STANCE, target=\ref[target]")
			if(!isnull(target))
				var/turf/T = get_turf(target)
				SEND_SIGNAL(parent, COMSIG_ATTACKING, target) // We're telling the attack modules that we have attack intention.  They then individually decide whether to fire.
				if(T)
					SEND_SIGNAL(parent, COMSIG_MOVE, T)
					return
			SEND_SIGNAL(parent, COMSIG_STATE, HOSTILE_STANCE_IDLE) // Lost target

/datum/component/ai/hunt/proc/OnBumped(var/atom/movable/AM)
	// TODO

/datum/component/ai/hunt/proc/target_evaluator(var/atom/target)
	return TRUE
