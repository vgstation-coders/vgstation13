/datum/component/ai/escape_confinement
	var/life_tick = 0

/datum/component/ai/escape_confinement/initialize()
	active_components += src
	return TRUE

/datum/component/ai/escape_confinement/Destroy()
	active_components -= src
	..()

/datum/component/ai/escape_confinement/process()
	life_tick++
	if(INVOKE_EVENT(parent, /event/comp_ai_cmd_get_busy))
		return
	var/atom/parent_atom = parent
	var/result = INVOKE_EVENT(parent, /event/comp_ai_cmd_get_state)
	switch(result)
		if(HOSTILE_STANCE_IDLE)
			EscapeConfinement()
		if(HOSTILE_STANCE_ATTACK)
			if(!(parent_atom.flags & INVULNERABLE))
				DestroySurroundings()
		if(HOSTILE_STANCE_ATTACKING)
			if(!(parent_atom.flags & INVULNERABLE))
				DestroySurroundings()

/datum/component/ai/escape_confinement/proc/EscapeConfinement()
	var/atom/A = parent
	if(istype(A, /mob))
		var/mob/M = A
		if(M.locked_to)
			M.locked_to.attack_animal(A)
	if(!isturf(A.loc) && A.loc != null)//Did someone put us in something?
		var/atom/locA = A.loc
		locA.attack_animal(A)//Bang on it till we get out

/datum/component/ai/escape_confinement/proc/DestroySurroundings()
	EscapeConfinement()
	var/list/smash_dirs = list(0)
	var/atom/target = INVOKE_EVENT(parent, /event/comp_ai_cmd_get_target)
	if(!target || INVOKE_EVENT(!parent, /event/comp_ai_cmd_can_attack, "target" = target))
		smash_dirs |= alldirs //if no target, attack everywhere
	else
		var/targdir = get_dir(src, target)
		smash_dirs |= widen_dir(targdir) //otherwise smash towards the target
	for(var/dir in smash_dirs)
		var/turf/T = get_step(src, dir)
		var/atom/parent_atom = parent
		if(istype(T, /turf/simulated/wall) && parent_atom.Adjacent(T))
			T.attack_animal(src)
		for(var/atom/A in T)
			var/static/list/attackable_objs = list(
				/obj/structure/window,
				/obj/structure/closet,
				/obj/structure/table,
				/obj/structure/grille,
				/obj/structure/rack,
			)
			if(is_type_in_list(A, attackable_objs) && parent_atom.Adjacent(A))
				A.attack_animal(src)
