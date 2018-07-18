/datum/component/ai/escape_confinement
	var/life_tick=0

/datum/component/ai/escape_confinement/Initialize()
	..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_LIFE, .proc/OnLife)

/datum/component/ai/escape_confinement/proc/OnLife()
	life_tick++
	var/mob/M = parent
	if(!controller)
		controller = parent.GetComponent(/datum/component/controller)
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
	var/mob/M = parent
	if(M.locked_to)
		M.locked_to.attack_animal(M)
	if(!isturf(M.loc) && M.loc != null)//Did someone put us in something?
		var/atom/locM = M.loc
		locM.attack_animal(M)//Bang on it till we get out

/datum/component/ai/escape_confinement/proc/DestroySurroundings()
	var/atom/parent = src.parent
	EscapeConfinement()
	var/list/smash_dirs = list(0)
	var/atom/target = controller.getTarget()
	if(!target || !controller.canAttack(target))
		smash_dirs |= alldirs //if no target, attack everywhere
	else
		var/targdir = get_dir(src, target)
		smash_dirs |= widen_dir(targdir) //otherwise smash towards the target
	for(var/dir in smash_dirs)
		var/turf/T = get_step(src, dir)
		if(istype(T, /turf/simulated/wall) && parent.Adjacent(T))
			T.attack_animal(src)
		var/static/list/attackables = list(
			/obj/structure/window,
			/obj/structure/closet,
			/obj/structure/table,
			/obj/structure/grille,
			/obj/structure/rack
		)
		for(var/_A in T)
			var/atom/A = _A
			if(is_type_in_list(A, attackables) && parent.Adjacent(A))
				A.attack_animal(src)
