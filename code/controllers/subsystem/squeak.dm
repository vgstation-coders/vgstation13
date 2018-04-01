// The Squeak
// because this is about placement of mice mobs, and nothing to do with
// mice - the computer peripheral

SUBSYSTEM_DEF(squeak)
	name = "Squeak"
	init_order = INIT_ORDER_SQUEAK
	flags = SS_NO_FIRE

	var/list/exposed_wires = list()

/datum/controller/subsystem/squeak/Initialize(timeofday)
	trigger_migration(CONFIG_GET(number/mice_roundstart))
	return ..()

/datum/controller/subsystem/squeak/proc/trigger_migration(num_mice=10)
	if(!num_mice)
		return
	find_exposed_wires()

	var/mob/living/simple_animal/mouse/M
	var/turf/proposed_turf

	while((num_mice > 0) && exposed_wires.len)
		proposed_turf = pick_n_take(exposed_wires)
		if(!M)
			M = new(proposed_turf)
		else
			M.forceMove(proposed_turf)
		if(M.environment_is_safe())
			num_mice -= 1
			M = null

/datum/controller/subsystem/squeak/proc/find_exposed_wires()
	exposed_wires.Cut()
	var/list/all_turfs
	for (var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		all_turfs += block(locate(1,1,z), locate(world.maxx,world.maxy,z))
	for(var/turf/open/floor/plating/T in all_turfs)
		if(is_blocked_turf(T))
			continue
		if(locate(/obj/structure/cable) in T)
			exposed_wires += T
