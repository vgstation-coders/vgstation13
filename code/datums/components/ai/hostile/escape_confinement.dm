/datum/component/ai/escape_confinement
	var/life_tick=0

/datum/component/ai/escape_confinement/ReceiveSignal(var/message_type, var/list/args)
	switch(message_type)
		if(COMSIG_LIFE)
			OnLife()

/datum/component/ai/escape_confinement/proc/OnLife()
	life_tick++
	var/mob/M = owner
	if(!controller)
		controller = owner.TryGetComponent(/datum/component/controller)
	if(controller.getBusy())
		return
	switch(controller.getState())
		if(HOSTILE_STANCE_IDLE)
			EscapeConfinement()
		if(HOSTILE_STANCE_ATTACK)
			if(!(M.flags & INVULNERABLE))
				DestroySurroundings()
		if(HOSTILE_STANCE_ATTACKING)
			if(!(M.flags & INVULNERABLE))
				DestroySurroundings()

/datum/component/ai/escape_confinement/proc/EscapeConfinement()
	var/atom/A = owner
	if(istype(A, /mob))
		var/mob/M = A
		if(M.locked_to)
			M.locked_to.attack_animal(A)
	if(!isturf(A.loc) && A.loc != null)//Did someone put us in something?
		var/atom/locA = A.loc
		locA.attack_animal(A)//Bang on it till we get out

/datum/component/ai/escape_confinement/proc/DestroySurroundings()
	EscapeConfinement()
	var/mob/owner_mob = owner
	if(!istype(owner_mob))
		return
	var/list/smash_dirs = list(0)
	var/atom/target = controller.getTarget()
	if(!target || !controller.canAttack(target))
		smash_dirs |= alldirs //if no target, attack everywhere
	else
		var/targdir = get_dir(src, target)
		smash_dirs |= widen_dir(targdir) //otherwise smash towards the target
	for(var/dir in smash_dirs)
		var/turf/T = get_step(src, dir)
		if(istype(T, /turf/simulated/wall) && owner_mob.Adjacent(T))
			T.attack_animal(src)
		for(var/atom/A in T)
			if((istype(A, /obj/structure/window) || istype(A, /obj/structure/closet) || istype(A, /obj/structure/table) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/rack)) && owner_mob.Adjacent(A))
				A.attack_animal(src)
