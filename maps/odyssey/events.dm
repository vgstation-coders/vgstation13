#define ODYSSEY_STATE_HYPERSPACE (1<<0)
#define ODYSSEY_STATE_DEEPSPACE  (1<<1)

/*
 * Odyssey Map Events
 *
 * Roll-based events that fire when the shuttle enters hyperspace or deep space.
 * Independent from the standard event scheduler (/datum/event).
 */

/datum/odyssey_event
	var/name = "Odyssey Event"
	var/required_roll = 0       // Minimum roll (1-100) to qualify
	var/state_flags = 0         // Bitfield: ODYSSEY_STATE_HYPERSPACE, ODYSSEY_STATE_DEEPSPACE
	var/announce_message = ""   // Warning sent to crew before impact
	var/announce_delay = 5 SECONDS // Delay between announcement and execution

/datum/odyssey_event/proc/can_fire(datum/shuttle/odyssey/shuttle)
	return TRUE

/datum/odyssey_event/proc/announce(datum/shuttle/odyssey/shuttle)
	if(announce_message)
		captain_announce(announce_message)

/datum/odyssey_event/proc/execute(datum/shuttle/odyssey/shuttle)
	return

/datum/odyssey_event/proc/fire(datum/shuttle/odyssey/shuttle)
	announce(shuttle)
	spawn(announce_delay)
		execute(shuttle)

/datum/shuttle/odyssey
	var/list/possible_events = list()
	var/odyssey_event_active = FALSE
	var/obj/docking_port/destination/event_trigger_port = null

/datum/shuttle/odyssey/proc/get_odyssey_state()
	if(!current_port)
		return 0
	var/datum/virtual_z/vz = current_port.get_virtual_z()
	if(!vz)
		return 0
	if(vz.level_type == VZ_TRANSIT)
		return ODYSSEY_STATE_HYPERSPACE
	if(vz.level_type == VZ_PARKING)
		return ODYSSEY_STATE_DEEPSPACE
	return 0

/datum/shuttle/odyssey/proc/start_event_loop()
	if(odyssey_event_active)
		return
	var/state = get_odyssey_state()
	if(!state)
		return
	odyssey_event_active = TRUE
	event_trigger_port = current_port
	var/first_delay = rand(30 SECONDS, 5 MINUTES)
	spawn(first_delay)
		event_roll_loop()

/datum/shuttle/odyssey/proc/stop_event_loop()
	odyssey_event_active = FALSE
	event_trigger_port = null

/datum/shuttle/odyssey/proc/event_roll_loop()
	if(!odyssey_event_active || current_port != event_trigger_port)
		stop_event_loop()
		return

	var/roll = rand(1, 100)
	var/state = get_odyssey_state()
	var/list/eligible = list()

	for(var/datum/odyssey_event/E in possible_events)
		if(E.required_roll <= roll && (E.state_flags & state) && E.can_fire(src))
			eligible += E

	if(eligible.len)
		var/datum/odyssey_event/picked = pick(eligible)
		picked.fire(src)

	// Subsequent rolls: 5-15 minute delay
	var/next_delay = rand(5 MINUTES, 15 MINUTES)
	spawn(next_delay)
		event_roll_loop()

/// Spawn a meteor projectile from the edge of the shuttle's current virtual z-level aimed at the shuttle
/datum/shuttle/odyssey/proc/spawn_vz_meteor(meteor_type)
	var/datum/virtual_z/vz = current_port.get_virtual_z()
	if(!vz)
		return null
	var/z_level = vz.z()

	// Pick a random shuttle turf as the target
	var/list/shuttle_turfs = list()
	for(var/turf/T in shuttle_contents())
		shuttle_turfs += T
	if(!shuttle_turfs.len)
		return null
	var/turf/target = pick(shuttle_turfs)

	// Pick a random edge of the VZ as the origin
	var/dir = pick(cardinal)
	var/startx
	var/starty
	switch(dir)
		if(NORTH)
			startx = rand(vz.x_min + 2, vz.x_max - 2)
			starty = vz.y_max - 2
		if(SOUTH)
			startx = rand(vz.x_min + 2, vz.x_max - 2)
			starty = vz.y_min + 2
		if(EAST)
			startx = vz.x_max - 2
			starty = rand(vz.y_min + 2, vz.y_max - 2)
		if(WEST)
			startx = vz.x_min + 2
			starty = rand(vz.y_min + 2, vz.y_max - 2)

	var/turf/start = locate(startx, starty, z_level)
	if(start && target)
		return new meteor_type(start, target)
	return null

/datum/odyssey_event/micro_meteors
	name = "Micro Meteors"
	required_roll = 20
	state_flags = ODYSSEY_STATE_HYPERSPACE
	announce_message = "Sensors detect incoming micro-debris field. Brace for impact."

/datum/odyssey_event/micro_meteors/execute(datum/shuttle/odyssey/shuttle)
	var/count = rand(5, 10)
	for(var/i = 1 to count)
		shuttle.spawn_vz_meteor(/obj/item/projectile/meteor/small)
		sleep(rand(3, 5))

/datum/odyssey_event/gib_storm
	name = "Gib Storm"
	required_roll = 35
	state_flags = ODYSSEY_STATE_HYPERSPACE
	announce_message = "Warning: Unidentified organic matter on collision course."

/datum/odyssey_event/gib_storm/execute(datum/shuttle/odyssey/shuttle)
	var/count = rand(8, 15)
	for(var/i = 1 to count)
		shuttle.spawn_vz_meteor(/obj/item/projectile/meteor/gib)
		sleep(rand(2, 4))

/datum/odyssey_event/solar_flare
	name = "Solar Flare"
	required_roll = 50
	state_flags = ODYSSEY_STATE_HYPERSPACE | ODYSSEY_STATE_DEEPSPACE
	announce_message = "Solar flare detected. Electrical systems may be affected."

/datum/odyssey_event/solar_flare/execute(datum/shuttle/odyssey/shuttle)
	var/duration = rand(1 MINUTES, 3 MINUTES)
	var/list/affected_apcs = list()

	for(var/obj/machinery/power/apc/A in shuttle.shuttle_contents())
		A.overload_lighting()
		if(A.cell)
			A.cell.charge = 0
		A.chargemode = 0
		A.operating = 0
		A.update()
		A.update_icon()
		affected_apcs += A

	spawn(duration)
		for(var/obj/machinery/power/apc/A in affected_apcs)
			if(A && !A.gcDestroyed)
				A.chargemode = 1
				A.operating = 1
				A.update()
				A.update_icon()
		captain_announce("Electrical systems have stabilized. Power is being restored.")

/datum/odyssey_event/carp_swarm
	name = "Carp Swarm"
	required_roll = 40
	state_flags = ODYSSEY_STATE_DEEPSPACE
	announce_message = "Biosensors detect hostile fauna approaching the ship."

/datum/odyssey_event/carp_swarm/execute(datum/shuttle/odyssey/shuttle)
	var/datum/virtual_z/vz = shuttle.current_port.get_virtual_z()
	if(!vz)
		return

	var/count = rand(4, 8)

	// Find space turfs near the shuttle
	var/list/shuttle_turfs = list()
	for(var/turf/T in shuttle.shuttle_contents())
		shuttle_turfs += T
	if(!shuttle_turfs.len)
		return

	// Use a central shuttle turf as reference point
	var/turf/center = shuttle_turfs[round(shuttle_turfs.len / 2) + 1]
	var/list/space_turfs = list()
	for(var/turf/space/S in range(15, center))
		if(!(S in shuttle_turfs))
			space_turfs += S

	if(!space_turfs.len)
		return

	for(var/i = 1 to count)
		var/turf/T = pick(space_turfs)
		new /mob/living/simple_animal/hostile/carp(T)

#undef ODYSSEY_STATE_HYPERSPACE
#undef ODYSSEY_STATE_DEEPSPACE
