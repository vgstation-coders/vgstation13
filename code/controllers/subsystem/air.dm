#define SSAIR_TILES     1
#define SSAIR_DEFERRED  2
#define SSAIR_EDGES     3
#define SSAIR_FIRE_ZONE 4
#define SSAIR_HOTSPOT   5
#define SSAIR_ZONE      6

var/datum/subsystem/air/SSair
var/tick_multiplier = 2

/*
Overview:
	The air controller does everything. There are tons of procs in here.

Class Vars:
	zones - All zones currently holding one or more turfs.
	edges - All processing edges.

	tiles_to_update - Tiles scheduled to update next tick.
	zones_to_update - Zones which have had their air changed and need air archival.
	active_hotspots - All processing fire objects.

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
	wait          = 1 SECONDS
	display_order = SS_DISPLAY_AIR

	var/list/currentrun
	var/currentpart = SSAIR_TILES

	var/cost_tiles = 0
	var/cost_tiles_deferred = 0
	var/cost_edges = 0
	var/cost_fire_zone = 0
	var/cost_hotspot = 0
	var/cost_zone = 0

	var/list/zones = list()
	var/list/edges = list()

	//Geometry updates lists
	var/list/tiles_to_update = list()
	var/list/zones_to_update = list()
	var/list/active_fire_zones = list()
	var/list/active_hotspots = list()
	var/list/active_edges = list()
	var/list/deferred_tiles = list()

	var/active_zones = 0

	var/current_cycle = 0
	var/update_delay = 5 //How long between check should it try to process atmos again.
	var/failed_ticks = 0 //How many ticks have runtimed?

	var/next_id = 1 //Used to keep track of zone UIDs.



/datum/subsystem/air/New()
	NEW_SS_GLOBAL(SSair)


/datum/subsystem/air/stat_entry(msg)
	msg += "C:{"
	msg += "T:[round(cost_tiles, 1)]|"
	msg += "D:[round(cost_tiles_deferred, 1)]|"
	msg += "E:[round(cost_edges, 1)]|"
	msg += "F:[round(cost_fire_zone, 1)]|"
	msg += "H:[round(cost_hotspot, 1)]|"
	msg += "Z:[round(cost_zone, 1)]|"
	msg += "} T:{"
	msg += "Z:[zones.len]|"
	msg += "E:[edges.len]"
	msg += "} "
	msg += "T:[tiles_to_update.len]|"
	msg += "Z:[zones_to_update.len]|"
	msg += "F:[active_fire_zones.len]|"
	msg += "H:[active_hotspots.len]|"
	msg += "E:[active_edges.len]|"
	msg += "A:[active_zones]"
	..(msg)


/datum/subsystem/air/Initialize(timeofday)
	to_chat(world, "<span class='danger'>Processing Geometry...</span>")
	sleep(-1)

	var/simulated_turf_count = 0

	for(var/turf/simulated/S in world)
		simulated_turf_count++
		S.update_air_properties()

	to_chat(world, {"<span class='info'>Total Simulated Turfs: [simulated_turf_count]
Total Zones: [zones.len]
Total Edges: [edges.len]
Total Active Edges: [active_edges.len ? "<span class='danger'>[active_edges.len]</span>" : "None"]
Total Unsimulated Turfs: [world.maxx*world.maxy*world.maxz - simulated_turf_count]</span>"})

	..()


/datum/subsystem/air/fire(resumed=FALSE)
	if (!resumed)
		current_cycle++

	var/timer = world.tick_usage

	if (currentpart == SSAIR_TILES || !resumed)
		process_tiles(resumed)
		cost_tiles = MC_AVERAGE(cost_tiles, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = FALSE
		currentpart = SSAIR_DEFERRED

	//defer updating of self-zone-blocked turfs until after all other turfs have been updated.
	//this hopefully ensures that non-self-zone-blocked turfs adjacent to self-zone-blocked ones
	//have valid zones when the self-zone-blocked turfs update.
	
	//This ensures that doorways don't form their own single-turf zones, since doorways are self-zone-blocked and
	//can merge with an adjacent zone, whereas zones that are formed on adjacent turfs cannot merge with the doorway.
	if(currentpart == SSAIR_DEFERRED)
		timer = world.tick_usage
		process_tiles_deferred(resumed)
		cost_tiles_deferred = MC_AVERAGE(cost_tiles_deferred, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = FALSE
		currentpart = SSAIR_EDGES

	if(currentpart == SSAIR_EDGES)
		timer = world.tick_usage
		process_edges(resumed)
		cost_edges = MC_AVERAGE(cost_edges, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = FALSE
		currentpart = SSAIR_FIRE_ZONE

	if(currentpart == SSAIR_FIRE_ZONE)
		timer = world.tick_usage
		process_fire_zones(resumed)
		cost_fire_zone = MC_AVERAGE(cost_fire_zone, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = FALSE
		currentpart = SSAIR_HOTSPOT

	if(currentpart == SSAIR_HOTSPOT)
		timer = world.tick_usage
		process_hotspots(resumed)
		cost_hotspot = MC_AVERAGE(cost_hotspot, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = FALSE
		currentpart = SSAIR_ZONE

	if(currentpart == SSAIR_ZONE)
		timer = world.tick_usage
		process_zones(resumed)
		cost_zone = MC_AVERAGE(cost_zone, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = FALSE
	
	currentpart = SSAIR_TILES


/datum/subsystem/air/proc/process_tiles(resumed=FALSE)
	if (!resumed)
		src.currentrun = tiles_to_update
		tiles_to_update = list()
	
	var/list/currentrun = src.currentrun
	while (currentrun.len)
		var/turf/T = currentrun[currentrun.len]
		currentrun.len--
		if (T)
			if(T.c_airblock(T) & ZONE_BLOCKED)
				deferred_tiles += T
				continue

			T.update_air_properties()
			T.post_update_air_properties()
			T.needs_air_update = 0
			#ifdef ZASDBG
			T.overlays -= mark
			updated++
			#endif
			//sleep(1)

		if (MC_TICK_CHECK)
			return


/datum/subsystem/air/proc/process_tiles_deferred(resumed=FALSE)
	if (!resumed)
		src.currentrun = deferred_tiles
		deferred_tiles = list()
	
	var/list/currentrun = src.currentrun
	while (currentrun.len)
		var/turf/T = currentrun[currentrun.len]
		currentrun.len--
		if (T)
			T.update_air_properties()
			T.post_update_air_properties()
			T.needs_air_update = 0
			#ifdef ZASDBG
			T.overlays -= mark
			updated++
			#endif

		if (MC_TICK_CHECK)
			return


/datum/subsystem/air/proc/process_edges(resumed=FALSE)
	if (!resumed)
		src.currentrun = active_edges.Copy()
	
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/connection_edge/edge = currentrun[currentrun.len]
		currentrun.len--
		if (edge)
			edge.tick()
		else
			active_edges.Remove(edge)

		if (MC_TICK_CHECK)
			return


/datum/subsystem/air/proc/process_fire_zones(resumed=FALSE)
	if (!resumed)
		src.currentrun = active_fire_zones.Copy()
	
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/zone/Z = currentrun[currentrun.len]
		currentrun.len--
		if (Z)
			Z.process_fire()
		else
			active_edges.Remove(Z)

		if (MC_TICK_CHECK)
			return


/datum/subsystem/air/proc/process_hotspots(resumed=FALSE)
	if (!resumed)
		src.currentrun = active_hotspots.Copy()
	
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/effect/fire/fire = currentrun[currentrun.len]
		currentrun.len--
		if (fire)
			fire.process()
		else
			active_edges.Remove(fire)

		if (MC_TICK_CHECK)
			return


/datum/subsystem/air/proc/process_zones(resumed=FALSE)
	if (!resumed)
		src.currentrun = zones_to_update
		zones_to_update = list()
	
	var/list/currentrun = src.currentrun
	while (currentrun.len)
		var/zone/zone = currentrun[currentrun.len]
		currentrun.len--
		if (zone)
			zone.tick()
			zone.needs_update = 0

		if (MC_TICK_CHECK)
			return


/datum/subsystem/air/proc/add_zone(zone/z)
	zones.Add(z)
	z.name = "Zone [next_id++]"
	mark_zone_update(z)


/datum/subsystem/air/proc/remove_zone(zone/z)
	zones.Remove(z)
	zones_to_update.Remove(z)


/datum/subsystem/air/proc/air_blocked(turf/A, turf/B)
	#ifdef ZASDBG
	ASSERT(isturf(A))
	ASSERT(isturf(B))
	#endif
	var/ablock = A.c_airblock(B)
	if(ablock == BLOCKED) return BLOCKED
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
	if(block & AIR_BLOCKED) return

	var/direct = !(block & ZONE_BLOCKED)
	var/space = !istype(B)

	if(!space)
		if(min(A.zone.contents.len, B.zone.contents.len) < ZONE_MIN_SIZE || (direct && (equivalent_pressure(A.zone,B.zone) || current_cycle == 0)))
			merge(A.zone,B.zone)
			return

	var
		a_to_b = get_dir(A,B)
		b_to_a = get_dir(B,A)

	if(!A.connections) A.connections = new
	if(!B.connections) B.connections = new

	if(A.connections.get(a_to_b)) return
	if(B.connections.get(b_to_a)) return
	if(!space)
		if(A.zone == B.zone) return


	var/connection/c = new /connection(A,B)

	A.connections.place(c, a_to_b)
	B.connections.place(c, b_to_a)

	if(direct) c.mark_direct()


/datum/subsystem/air/proc/mark_for_update(turf/T)
	#ifdef ZASDBG
	ASSERT(isturf(T))
	#endif
	if(T.needs_air_update) return
	tiles_to_update |= T
	#ifdef ZASDBG
	T.overlays += mark
	#endif
	T.needs_air_update = 1


/datum/subsystem/air/proc/mark_zone_update(zone/Z)
	#ifdef ZASDBG
	ASSERT(istype(Z))
	#endif
	if(Z.needs_update) return
	zones_to_update.Add(Z)
	Z.needs_update = 1


/datum/subsystem/air/proc/mark_edge_sleeping(connection_edge/E)
	#ifdef ZASDBG
	ASSERT(istype(E))
	#endif
	if(E.sleeping) return
	active_edges.Remove(E)
	E.sleeping = 1


/datum/subsystem/air/proc/mark_edge_active(connection_edge/E)
	#ifdef ZASDBG
	ASSERT(istype(E))
	#endif
	if(!E.sleeping) return
	active_edges.Add(E)
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
			if(edge.contains_zone(B)) return edge
		var/connection_edge/edge = new/connection_edge/zone(A,B)
		edges.Add(edge)
		edge.recheck()
		return edge
	else
		for(var/connection_edge/unsimulated/edge in A.edges)
			if(has_same_air(edge.B,B)) return edge
		var/connection_edge/edge = new/connection_edge/unsimulated(A,B)
		edges.Add(edge)
		edge.recheck()
		return edge


/datum/subsystem/air/proc/has_same_air(turf/A, turf/B)
	if(A.oxygen != B.oxygen) return 0
	if(A.nitrogen != B.nitrogen) return 0
	if(A.toxins != B.toxins) return 0
	if(A.carbon_dioxide != B.carbon_dioxide) return 0
	if(A.temperature != B.temperature) return 0
	return 1


/datum/subsystem/air/proc/remove_edge(connection_edge/E)
	edges.Remove(E)
	if(!E.sleeping) active_edges.Remove(E)
