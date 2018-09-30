#define SSAIR_TILES     1
#define SSAIR_DEFERRED  2
#define SSAIR_EDGES     3
//#define SSAIR_FIRE_ZONE 4 //This involves behavior to be added in a future PR.
#define SSAIR_HOTSPOT   4 //These two should each be increased by one once that one is uncommented.
#define SSAIR_ZONE      5 //These two should each be increased by one once that one is uncommented.

#define SSAIR_FIRST_PART SSAIR_TILES //The first part to be processed.
#define SSAIR_LAST_PART  SSAIR_ZONE  //The last part to be processed.

#define SSAIR_PROCESS_UPDATE SSAIR_TILES, SSAIR_DEFERRED, SSAIR_ZONE //The lists corresponding to these parts are cleared when processed.
                                                                     //In other words, these are only processed each time they are marked for an update.
                                                                     //The default behavior is not clearing the list, meaning the corresponding objects are processed every tick.

var/datum/subsystem/air/SSair
var/tick_multiplier = 2

/*
Overview:
	The air controller does everything. There are tons of procs in here.
Class Vars:
	zones - All zones currently holding one or more turfs.
	edges - All processing edges.
	processing_parts[SSAIR_TILES] - Tiles scheduled to update next tick.
	processing_parts[SSAIR_ZONE] - Zones which have had their air changed and need air archival.
	processing_parts[SSAIR_HOTSPOT] - All processing fire objects.
	active_zones - The number of zones which were archived last tick. Used in debug verbs.
	next_id - The next UID to be applied to a zone. Mostly useful for debugging purposes as zones do not need UIDs to function.
Class Procs:
	mark_for_update(turf/T)
		Adds the turf to the update list. When updated, update_air_properties() will be called.
		When stuff changes that might affect airflow, call this. It's basically the only thing you need.
	add_zone(zone/Z) and remove_zone(zone/Z)
		Adds zones to the zones list. Does not mark them for update.
	air_blocked(turf/A, turf/B)
		Returns a bitflag consisting of:
		AIR_BLOCKED - The connection between turfs is physically blocked. No air can pass.
		ZONE_BLOCKED - There is a door between the turfs, so zones cannot cross. Air may or may not be permeable.
	has_valid_zone(turf/T)
		Checks the presence and validity of T's zone.
		May be called on unsimulated turfs, returning 0.
	merge(zone/A, zone/B)
		Called when zones have a direct connection and equivalent pressure and temperature.
		Merges the zones to create a single zone.
	connect(turf/simulated/A, turf/B)
		Called by turf/update_air_properties(). The first argument must be simulated.
		Creates a connection between A and B.
	mark_zone_update(zone/Z)
		Adds zone to the update list. Unlike mark_for_update(), this one is called automatically whenever
		air is returned from a simulated turf.
	equivalent_pressure(zone/A, zone/B)
		Currently identical to A.air.compare(B.air). Returns 1 when directly connected zones are ready to be merged.
	get_edge(zone/A, zone/B)
	get_edge(zone/A, turf/B)
		Gets a valid connection_edge between A and B, creating a new one if necessary.
	has_same_air(turf/A, turf/B)
		Used to determine if an unsimulated edge represents a specific turf.
		Simulated edges use connection_edge/contains_zone() for the same purpose.
		Returns 1 if A has identical gases and temperature to B.
	remove_edge(connection_edge/edge)
		Called when an edge is erased. Removes it from processing.
*/

/datum/subsystem/air
	name          = "Air"
	init_order    = SS_INIT_AIR
	priority      = SS_PRIORITY_AIR
	wait          = 2 SECONDS
	display_order = SS_DISPLAY_AIR

	var/list/currentrun
	var/currentpart = SSAIR_TILES

	var/list/cost_parts = list(SSAIR_TILES     = 0,\
	                           SSAIR_DEFERRED  = 0,\
	                           SSAIR_EDGES     = 0,\
/*	                           SSAIR_FIRE_ZONE = 0,*/\
	                           SSAIR_HOTSPOT   = 0,\
	                           SSAIR_ZONE      = 0)

	var/list/zones = list()
	var/list/edges = list()

	//Geometry process lists
	var/list/processing_parts = list(SSAIR_TILES     = list(),\
	                                 SSAIR_DEFERRED  = list(),\
	                                 SSAIR_EDGES     = list(),\
/*	                                 SSAIR_FIRE_ZONE = list(),*/\
	                                 SSAIR_HOTSPOT   = list(),\
	                                 SSAIR_ZONE      = list())

	var/active_zones = 0

	var/current_cycle = 0
	var/update_delay = 5 //How long between check should it try to process atmos again.
	var/failed_ticks = 0 //How many ticks have runtimed?

	var/next_id = 1 //Used to keep track of zone UIDs.



/datum/subsystem/air/New()
	NEW_SS_GLOBAL(SSair)


/datum/subsystem/air/stat_entry(msg)
	var/list/p_tiles = processing_parts[SSAIR_TILES]
	var/list/p_zone = processing_parts[SSAIR_ZONE]
//	var/list/p_fire_zone = processing_parts[SSAIR_FIRE_ZONE]
	var/list/p_hotspot = processing_parts[SSAIR_HOTSPOT]
	var/list/p_edges = processing_parts[SSAIR_EDGES]

	msg += "C:{\
	        T:[round(cost_parts[SSAIR_TILES], 1)]|\
	        D:[round(cost_parts[SSAIR_DEFERRED], 1)]|\
	        E:[round(cost_parts[SSAIR_EDGES], 1)]|\
"/*	        F:[round(cost_parts[SSAIR_FIRE_ZONE], 1)]|*/+"\
	        H:[round(cost_parts[SSAIR_HOTSPOT], 1)]|\
	        Z:[round(cost_parts[SSAIR_ZONE], 1)]|\
	        } T:{\
	        Z:[zones.len]|\
	        E:[edges.len]\
	        } \
	        T:[p_tiles.len]|\
	        Z:[p_zone.len]|\
"/*	        F:[p_fire_zone.len]|*/+"\
	        H:[p_hotspot.len]|\
	        E:[p_edges.len]|\
	        A:[active_zones]"
	..(msg) //Note to self: Don't fuck that up when uncommenting after adding fire zones


/datum/subsystem/air/Initialize(timeofday)
	#ifndef ZASDBG
	set background = 1 //The for loop later is sufficiently long to trip BYOND's infinite loop detection.
	#endif

	to_chat(world, "<span class='danger'>Processing Geometry...</span>")
	sleep(-1)

	var/simulated_turf_count = 0

	for(var/turf/simulated/S in world)
		simulated_turf_count++
		S.update_air_properties()

	to_chat(world, {"<span class='info'>Total Simulated Turfs: [simulated_turf_count]
Total Zones: [zones.len]
Total Edges: [edges.len]
Total Active Edges: [length(processing_parts[SSAIR_EDGES]) ? "<span class='danger'>[length(processing_parts[SSAIR_EDGES])]</span>" : "None"]
Total Unsimulated Turfs: [world.maxx*world.maxy*world.maxz - simulated_turf_count]</span>"})

	..()


/datum/subsystem/air/fire(resumed = FALSE)
	if (!resumed)
		current_cycle++
		currentpart = SSAIR_FIRST_PART

	var/timer

	while(currentpart <= SSAIR_LAST_PART)
		timer = world.tick_usage

		if(!resumed)
			switch(currentpart)
				if(SSAIR_PROCESS_UPDATE)
					currentrun = processing_parts[currentpart]
					processing_parts[currentpart] = list()
				else
					currentrun = processing_parts[currentpart]
					currentrun = currentrun.Copy() //Thanks, list aliasing

		process_part(currentpart)

		cost_parts[currentpart] = MC_AVERAGE(cost_parts[currentpart], TICK_DELTA_TO_MS(world.tick_usage - timer))

		if(state != SS_RUNNING)
			return

		resumed = FALSE
		currentpart++

/datum/subsystem/air/proc/process_part(part = currentpart) //This whole proc is pretty disgusting, but I don't want to fuck EVERYTHING up at the same time. Rewrite later, maybe.
	var/list/currentrun = src.currentrun //Accessing a proc var is faster than acccessing an object var. In the unlikely event Lummox ever fixes this, delete this line.

	#define LOOP_DECLARATION(iter_type, iterator) for(var/iter_type/iterator;currentrun.len && !(MC_TICK_CHECK) && (iterator = currentrun[currentrun.len]);currentrun.len--)
		//The loop declaration is a macro so it can be duplicated without just copying+pasting. This removes the need for the following switch() to be evaluated every iteration.
		//It also contains EXTREME quantities of bullshit in order to have all the checks and list manipulation built in. I strongly recommend you don't actually read it.

	switch(part)
		if(SSAIR_TILES)
			LOOP_DECLARATION(turf, T)
				if(T.c_airblock(T) & ZONE_BLOCKED)
					processing_parts[SSAIR_DEFERRED] += T
					continue

				T.update_air_properties()
				T.post_update_air_properties()
				T.needs_air_update = 0
				#ifdef ZASDBG
				T.overlays -= mark
				updated++
				#endif
				//sleep(1)

		if(SSAIR_DEFERRED)
			LOOP_DECLARATION(turf, T)
				T.update_air_properties()
				T.post_update_air_properties()
				T.needs_air_update = 0
				#ifdef ZASDBG
				T.overlays -= mark
				updated++
				#endif

		if(SSAIR_EDGES)
			LOOP_DECLARATION(connection_edge, edge)
				edge.tick()

//		if(SSAIR_FIRE_ZONE)
//			LOOP_DECLARATION(zone, Z)
//				Z.process_fire()

		if(SSAIR_HOTSPOT)
			LOOP_DECLARATION(obj/effect/fire, fire)
				fire.process()

		if(SSAIR_ZONE)
			LOOP_DECLARATION(zone, zone)
				zone.tick()
				zone.needs_update = 0

#undef LOOP_DECLARATION //Let's pretend that never existed now

/datum/subsystem/air/proc/add_zone(zone/z)
	zones.Add(z)
	z.name = "Zone [next_id++]"
	mark_zone_update(z)


/datum/subsystem/air/proc/remove_zone(zone/z)
	zones.Remove(z)
	processing_parts[SSAIR_ZONE] -= z


/datum/subsystem/air/proc/air_blocked(turf/A, turf/B)
	#ifdef ZASDBG
	ASSERT(isturf(A))
	ASSERT(isturf(B))
	#endif
	var/ablock = A.c_airblock(B)
	if(ablock == BLOCKED)
		return BLOCKED
	return ablock | B.c_airblock(A)


/datum/subsystem/air/proc/has_valid_zone(turf/simulated/T)
	#ifdef ZASDBG
	ASSERT(istype(T))
	#endif
	return istype(T) && T.zone && !T.zone.invalid


/datum/subsystem/air/proc/merge(zone/A, zone/B)
	#ifdef ZASDBG
	ASSERT(istype(A))
	ASSERT(istype(B))
	ASSERT(!A.invalid)
	ASSERT(!B.invalid)
	ASSERT(A != B)
	#endif
	if(A.contents.len < B.contents.len)
		A.c_merge(B)
		mark_zone_update(B)
	else
		B.c_merge(A)
		mark_zone_update(A)


/datum/subsystem/air/proc/connect(turf/simulated/A, turf/simulated/B)
	#ifdef ZASDBG
	ASSERT(istype(A))
	ASSERT(isturf(B))
	ASSERT(A.zone)
	ASSERT(!A.zone.invalid)
	//ASSERT(B.zone)
	ASSERT(A != B)
	#endif

	var/block = SSair.air_blocked(A,B)
	if(block & AIR_BLOCKED)
		return

	var/direct = !(block & ZONE_BLOCKED)
	var/space = !istype(B)

	if(!space)
//		if(min(A.zone.contents.len, B.zone.contents.len) < ZONE_MIN_SIZE || (direct && (equivalent_pressure(A.zone,B.zone) || current_cycle == 0))) //This is the new behavior, but I don't want to include a balance change with a system change where avoidable. To be uncommented later.
		if(direct && (equivalent_pressure(A.zone,B.zone) || current_cycle == 0)) //This is the old behavior, albeit with one check moved down an if().
			merge(A.zone,B.zone)
			return

	var/a_to_b = get_dir(A,B)
	var/b_to_a = get_dir(B,A)

	if(!A.connections)
		A.connections = new
	if(!B.connections)
		B.connections = new

	if(A.connections.get(a_to_b))
		return
	if(B.connections.get(b_to_a))
		return
	if(!space)
		if(A.zone == B.zone)
			return


	var/connection/c = new /connection(A,B)

	A.connections.place(c, a_to_b)
	B.connections.place(c, b_to_a)

	if(direct)
		c.mark_direct()


/datum/subsystem/air/proc/mark_for_update(turf/T)
	#ifdef ZASDBG
	ASSERT(isturf(T))
	#endif
	if(T.needs_air_update)
		return
	processing_parts[SSAIR_TILES] |= T
	#ifdef ZASDBG
	T.overlays += mark
	#endif
	T.needs_air_update = 1


/datum/subsystem/air/proc/mark_zone_update(zone/Z)
	#ifdef ZASDBG
	ASSERT(istype(Z))
	#endif
	if(Z.needs_update)
		return
	processing_parts[SSAIR_ZONE] |= Z
	Z.needs_update = 1


/datum/subsystem/air/proc/mark_edge_sleeping(connection_edge/E)
	#ifdef ZASDBG
	ASSERT(istype(E))
	#endif
	if(E.sleeping)
		return
	processing_parts[SSAIR_EDGES] -= E
	E.sleeping = 1


/datum/subsystem/air/proc/mark_edge_active(connection_edge/E)
	#ifdef ZASDBG
	ASSERT(istype(E))
	#endif
	if(!E.sleeping)
		return
	processing_parts[SSAIR_EDGES] |= E
	E.sleeping = 0
	#ifdef ZASDBG
	if(istype(E, /connection_edge/zone/))
		var/connection_edge/zone/ZE = E
		world << "ZASDBG: Active edge! Areas: [get_area(pick(ZE.A.contents))] / [get_area(pick(ZE.B.contents))]"
	else
		world << "ZASDBG: Active edge! Area: [get_area(pick(E.A.contents))]"
	#endif


/datum/subsystem/air/proc/equivalent_pressure(zone/A, zone/B)
	return A.air.compare(B.air)


/datum/subsystem/air/proc/get_edge(zone/A, zone/B)

	if(istype(B))
		for(var/connection_edge/zone/edge in A.edges)
			if(edge.contains_zone(B))
				return edge
		var/connection_edge/edge = new/connection_edge/zone(A,B)
		edges.Add(edge)
		edge.recheck()
		return edge
	else
		for(var/connection_edge/unsimulated/edge in A.edges)
			if(has_same_air(edge.B,B))
				return edge
		var/connection_edge/edge = new/connection_edge/unsimulated(A,B)
		edges.Add(edge)
		edge.recheck()
		return edge


/datum/subsystem/air/proc/has_same_air(turf/A, turf/B)
	if(A.oxygen != B.oxygen)
		return 0
	if(A.nitrogen != B.nitrogen)
		return 0
	if(A.toxins != B.toxins)
		return 0
	if(A.carbon_dioxide != B.carbon_dioxide)
		return 0
	if(A.temperature != B.temperature)
		return 0
	return 1


/datum/subsystem/air/proc/remove_edge(connection_edge/E)
	edges.Remove(E)
	if(!E.sleeping)
		processing_parts[SSAIR_EDGES] -= E


/datum/subsystem/air/proc/add_hotspot(var/obj/effect/fire/H)
	#ifdef ZASDBG
	ASSERT(istype(H))
	#endif
	processing_parts[SSAIR_HOTSPOT] |= H


/datum/subsystem/air/proc/remove_hotspot(var/obj/effect/fire/H)
	#ifdef ZASDBG
	ASSERT(istype(H))
	#endif
	processing_parts[SSAIR_HOTSPOT] -= H
