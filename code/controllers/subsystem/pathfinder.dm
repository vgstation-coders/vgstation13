var/datum/subsystem/pathfinder/SSpathfinder

/datum/subsystem/pathfinder
	name = "Pathfinder"
	init_order = SS_INIT_PATHFINDER
	flags = SS_NO_FIRE
	var/datum/flowcache/mobs
	var/static/space_type_cache

/datum/subsystem/pathfinder/New()
	NEW_SS_GLOBAL(SSpathfinder)

/datum/subsystem/pathfinder/Initialize()
	space_type_cache = typesof(/turf/space) + typesof(/turf/simulated/open)
	generate_type_list_cache(space_type_cache)
	mobs = new(10)
	return ..()

/datum/flowcache
	var/lcount
	var/run
	var/free
	var/list/flow

/datum/flowcache/New(n)
	. = ..()
	lcount = n
	run = 0
	free = 1
	flow = new/list(lcount)

/datum/flowcache/proc/getfree(atom/M)
	if(run < lcount)
		run += 1
		while(flow[free])
			CHECK_TICK
			free = (free % lcount) + 1
		var/t = add_timer(new /callback(src, nameof(src::toolong()), free), 15 SECONDS)
		flow[free] = t
		flow[t] = M
		return free
	else
		return 0

/datum/flowcache/proc/toolong(l)
	log_game("Pathfinder route took longer than 15 seconds, src bot [flow[flow[l]]]")
	found(l)

/datum/flowcache/proc/found(l)
	del_timer(flow[l])
	flow[l] = null
	run -= 1
