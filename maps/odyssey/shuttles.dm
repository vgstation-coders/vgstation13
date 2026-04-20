#define JUMP_NONE 0
#define JUMP_COUNTDOWN 1
#define JUMP_COMMITTED 2

var/global/datum/shuttle/odyssey/odyssey_shuttle = new(starting_area = /area/shuttle/odyssey)
var/global/datum/shuttle/odyssey_transfer/odyssey_transfer_shuttle = new(starting_area = /area/shuttle/odyssey_transfer)

/datum/shuttle/odyssey
	name = "NTEV Odyssey"
	cant_leave_zlevel = list()
	dir = EAST
	can_rotate = FALSE

	cooldown = 60 SECONDS
	pre_flight_delay = 10 SECONDS
	transit_delay = 120 SECONDS
	transit_timeout = 0 // Disable transit safety recall - shuttle can remain in hyperspace indefinitely
	use_transit = TRANSIT_ALWAYS
	stable = 0
	var/bluespace_jump_state = JUMP_NONE
	var/obj/docking_port/destination/dock_centcom
	var/transit_end_time = 0
	var/transit_destination_name = ""

	req_access = list(access_captain)

/datum/shuttle/odyssey/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/odyssey/outpost)
	add_dock(/obj/docking_port/destination/odyssey/deep_space)
	add_dock(/obj/docking_port/destination/odyssey/dj_sat)
	add_dock(/obj/docking_port/destination/odyssey/derelict)
	add_dock(/obj/docking_port/destination/odyssey/rendezvous_odyssey)
	dock_centcom = locate(/obj/docking_port/destination/odyssey/centcomm) in all_docking_ports

	var/obj/docking_port/destination/transit/transit = generate_transit_area(src)
	if(transit)
		set_transit_dock(transit)
		transit.areaname = "Hyperspace"
		add_dock(transit)
		// Lower transit turf plane so catwalks and shuttle objects render above hyperspace
		var/datum/virtual_z/tvz = transit.get_virtual_z()
		if(tvz)
			for(var/turf/space/transit/T in tvz.get_turfs())
				T.plane = BELOW_PLATING_PLANE

	var/obj/docking_port/destination/parking = generate_parking_area(src)
	if(parking)
		add_dock(parking)

	// Set up transition channel for parking and space v-levels so they drift between each other
	var/list/datum/virtual_z/deep_space_vlevels = list()
	for(var/datum/virtual_z/vz in map.vLevels)
		if(vz.level_type == VZ_PARKING || vz.level_type == VZ_SPACE)
			deep_space_vlevels += vz

	if(deep_space_vlevels.len)
		var/channel = "Odyssey Deep Space"
		if(!(channel in accessable_v_levels))
			accessable_v_levels[channel] = list()

		for(var/datum/virtual_z/vz in deep_space_vlevels)
			vz.movementJammed = FALSE
			vz.transition_channel = channel
			vz.gps_allowed = TRUE
			vz.teleJammed = VZ_TELEPORTATION_ALLOWED
			vz.update_settings()

	// If starting at outpost, enable external power on SMES units
	if(istype(current_port, /obj/docking_port/destination/odyssey/outpost))
		for(var/obj/machinery/power/battery/smes/S in shuttle_contents())
			S.external_power_supply = TRUE

	// Initialize Odyssey events
	possible_events = list(
		new /datum/odyssey_event/micro_meteors,
		new /datum/odyssey_event/gib_storm,
		new /datum/odyssey_event/solar_flare,
		new /datum/odyssey_event/carp_swarm
	)

/datum/shuttle/odyssey/after_flight()
	..()
	var/at_outpost = istype(current_port, /obj/docking_port/destination/odyssey/outpost)
	for(var/obj/machinery/power/battery/smes/S in shuttle_contents())
		S.external_power_supply = at_outpost
	// Clean up lingering beach water effects on shuttle turfs after landing
	for(var/turf/T in shuttle_contents())
		for(var/obj/effect/beach_water/unsimmed/W in T.vis_contents)
			T.vis_contents -= W
	// Start the Odyssey event loop if in hyperspace or deep space
	start_event_loop()

/datum/shuttle/odyssey/get_pre_flight_delay()
	// Skip countdown when already in hyperspace
	if(current_port == transit_port)
		return 0
	return ..()

/datum/shuttle/odyssey/animate_liftoff()
	// Skip liftoff when already in hyperspace
	if(current_port == transit_port)
		return
	// Delay liftoff animation to 2 seconds before the pre-flight countdown ends
	spawn(max(1, get_pre_flight_delay() - 2 SECONDS))
		..()

/datum/shuttle/odyssey/animate_landing()
	// Skip landing animation when entering hyperspace
	if(destination_port == transit_port)
		return
	..()

/datum/shuttle/odyssey/actually_travel_to(obj/docking_port/D, obj/machinery/computer/shuttle_control/broadcast, mob/user, eject)
	transit_destination_name = capitalize(D.areaname)
	if(transit_port)
		transit_port.areaname = "Hyperspace"
	if(current_port != transit_port)
		captain_announce("The NTEV Odyssey will be departing to [transit_destination_name] in 10 seconds.")
	return ..()

/datum/shuttle/odyssey/pre_flight()
	stop_event_loop()
	if(!destination_port)
		return
	if(transit_port && get_transit_delay() && destination_port != transit_port)
		transit_end_time = world.time + get_transit_delay()
		var/dest_name = transit_destination_name
		var/announce_delay = get_transit_delay() - 10 SECONDS
		if(announce_delay > 0)
			spawn(announce_delay)
				if(destination_port)
					captain_announce("The NTEV Odyssey will be arriving at [dest_name] in 10 seconds.")
	..()
	// Start periodic engine firing if we're now in hyperspace transit
	if(current_port == transit_port)
		for(var/obj/structure/shuttle/engine/propulsion/odyssey/E in shuttle_contents())
			E.start_hyperspace_firing()

/datum/shuttle/odyssey/complete_flight()
	// Stop periodic engine firing before leaving hyperspace
	for(var/obj/structure/shuttle/engine/propulsion/odyssey/E in shuttle_contents())
		E.stop_hyperspace_firing()
	transit_end_time = 0
	transit_destination_name = ""
	..()

/datum/shuttle/odyssey/travel_to(obj/docking_port/D, obj/machinery/computer/shuttle_control/broadcast, mob/user, eject = FALSE)
	if(bluespace_jump_state == JUMP_COMMITTED)
		if(broadcast)
			broadcast.announce("Bluespace jump is committed. The ship cannot be redirected.")
		else if(user)
			to_chat(user, "<span class='warning'>Bluespace jump is committed. The ship cannot be redirected.</span>")
		return 0
	if(bluespace_jump_state == JUMP_COUNTDOWN)
		if(!istype(D, /obj/docking_port/destination/odyssey/outpost))
			if(broadcast)
				broadcast.announce("Bluespace jump is charging. Only the NT Outpost is available as a destination.")
			else if(user)
				to_chat(user, "<span class='warning'>Bluespace jump is charging. Only the NT Outpost is available as a destination.</span>")
			return 0
	return ..()

/obj/item/weapon/circuitboard/shuttle_control/odyssey
	name = "Circuit board (NTEV Odyssey Shuttle Control)"
	desc = "A circuit board for running the NTEV Odyssey's shuttle control computer."
	build_path = /obj/machinery/computer/shuttle_control/odyssey

/obj/machinery/computer/shuttle_control/odyssey
	name = "NTEV Odyssey shuttle control computer"
	circuit = "/obj/item/weapon/circuitboard/shuttle_control/odyssey"

/obj/machinery/computer/shuttle_control/odyssey/New()
	link_to(odyssey_shuttle)
	.=..()

/obj/docking_port/destination/odyssey/outpost
	areaname = "NT Outpost"

/obj/docking_port/destination/odyssey/deep_space
	areaname = "deep space"

/obj/docking_port/destination/odyssey/dj_sat
	areaname = "abandoned dj satellite"

/obj/docking_port/destination/odyssey/derelict
	areaname = "derelict space station"

/obj/docking_port/destination/odyssey/centcomm
	areaname = "Central Command"

/obj/docking_port/destination/odyssey/rendezvous_odyssey
	areaname = "Rendezvous with Vox Tradeship"

/obj/docking_port/destination/odyssey/rendezvous_trader
	areaname = "Rendezvous with NTEV Odyssey"

/obj/machinery/status_display/odyssey
	name = "shuttle status display"

/obj/machinery/status_display/odyssey/update()
	// Shuttle transit countdown takes priority
	if(odyssey_shuttle && odyssey_shuttle.transit_end_time > world.time)
		var/timeleft = max(0, round((odyssey_shuttle.transit_end_time - world.time) / 10, 1))
		update_display("TRNST", "[add_zero(num2text((timeleft / 60) % 60), 2)]:[add_zero(num2text(timeleft % 60), 2)]")
		return
	// Bluespace jump countdown
	if(emergency_shuttle && emergency_shuttle.online)
		var/line2 = emergency_shuttle.get_shuttle_timer()
		if(length(line2) > 5)
			line2 = "Error"
		update_display("-JUMP", line2)
		return
	..()

/datum/shuttle/trade/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/odyssey/rendezvous_trader)

/datum/shuttle/odyssey_transfer
	name = "odyssey transfer shuttle"
	dir = SOUTH
	can_rotate = TRUE
	var/obj/docking_port/destination/odyssey_transfer/nt_outpost/outpost_dock
	var/auto_return_timer = 0

/datum/shuttle/odyssey_transfer/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/odyssey_transfer/transfer)
	add_dock(/obj/docking_port/destination/odyssey_transfer/nt_outpost)
	outpost_dock = locate(/obj/docking_port/destination/odyssey_transfer/nt_outpost) in docking_ports

/datum/shuttle/odyssey_transfer/after_flight()
	..()
	if(istype(current_port, /obj/docking_port/destination/odyssey_transfer/transfer))
		for(var/obj/machinery/computer/shuttle_control/odyssey_transfer/C in control_consoles)
			C.announce("Docked with the NTEV Odyssey. Auto-return to the NT Outpost in 60 seconds.")
		auto_return_timer = world.time + 60 SECONDS
		spawn(60 SECONDS)
			if(auto_return_timer && world.time >= auto_return_timer && istype(current_port, /obj/docking_port/destination/odyssey_transfer/transfer) && outpost_dock)
				travel_to(outpost_dock)
				auto_return_timer = 0

/obj/docking_port/destination/odyssey_transfer/transfer
	areaname = "NTEV Odyssey Crew Transfer Dock"

/obj/docking_port/destination/odyssey_transfer/nt_outpost
	areaname = "NTEV Odyssey Crew Transfer Shuttle Landing Zone"

/obj/machinery/computer/shuttle_control/odyssey_transfer
	name = "NTEV Odyssey Crew Transfer Shuttle control computer"
	icon_state = "syndishuttle"

/obj/machinery/computer/shuttle_control/odyssey_transfer/New()
	link_to(odyssey_transfer_shuttle)
	.=..()

/obj/machinery/computer/shuttle_control/odyssey_transfer/try_move(mob/user)
	if(istype(selected_port, /obj/docking_port/destination/odyssey_transfer/transfer))
		var/datum/virtual_z/odyssey_vz = odyssey_shuttle?.current_port?.get_virtual_z()
		if(!odyssey_vz || odyssey_vz.level_type != VZ_PARKING)
			announce("The NTEV Odyssey is not in deep space. Transfer shuttle cannot dock with the Odyssey.")
			return
	return ..()

/obj/item/weapon/circuitboard/communications/odyssey
	name = "Circuit board (Odyssey Bridge Communications)"
	desc = "A circuit board for running the Odyssey bridge communications console."
	build_path = /obj/machinery/computer/communications/odyssey

/obj/machinery/computer/communications/odyssey
	circuit = "/obj/item/weapon/circuitboard/communications/odyssey"

/obj/machinery/computer/communications/odyssey/proc/trigger_bluespace_jump()
	if(!emergency_shuttle || emergency_shuttle.online || emergency_shuttle.departed || emergency_shuttle.shutdown)
		return
	emergency_shuttle.incall()
	captain_announce("The NTEV Odyssey's bridge communications array has been destroyed; Central Command cannot authorize continued exploration operations. Automated emergency protocol engaged: the Bluespace Drive is now charging for immediate return to Central Command.")
	log_game("Communications Console destroyed. Bluespace jump initiated.")
	message_admins("Communications Console destroyed. Bluespace jump initiated.", 1)

/obj/machinery/computer/communications/odyssey/set_broken()
	. = ..()
	if(.)
		trigger_bluespace_jump()

/obj/machinery/computer/communications/odyssey/Destroy()
	if(!(stat & BROKEN))
		trigger_bluespace_jump()
	return ..()

// Odyssey-specific emergency shuttle controller
// Instead of calling a separate escape shuttle, the Odyssey itself performs a Bluespace jump to CentComm

#define ODYSSEY_TRANSIT_TIME 90 // 90 seconds in transit

/datum/emergency_shuttle/odyssey
	var/obj/effect/overlay/bluespacify/bs_overlay // Single shared overlay instance

/datum/emergency_shuttle/odyssey/get_linked_port()
	return odyssey_shuttle ? odyssey_shuttle.linked_port : null

/datum/emergency_shuttle/odyssey/process()
	if(!online || shutdown)
		return

	var/timeleft = timeleft()
	if(timeleft > 1e5)
		timeleft = 0
	if(timeleft < 0)
		timeleft = 0

	if(timeleft > 6)
		warmup_sound = 0

	// Update the odyssey shuttle's jump state based on time remaining
	if(direction == EMERGENCY_SHUTTLE_GOING_TO_STATION)
		if(timeleft > 120) // More than 2 min left - can still cancel, can fly to outpost
			odyssey_shuttle.bluespace_jump_state = JUMP_COUNTDOWN
		else if(timeleft > 0) // 2 min or less - committed, no flying
			odyssey_shuttle.bluespace_jump_state = JUMP_COMMITTED

	switch(location)
		if(SHUTTLE_ON_STANDBY)

			// --- Odyssey is in transit to centcom (3 min phase) ---
			if(direction == EMERGENCY_SHUTTLE_GOING_TO_CENTCOMM)
				if(timeleft <= 0)
					// Arrived at centcom
					shuttle_phase("centcom", 0)
					hyperspace_sounds("end")
					return 1

				// Engine exhaust during transit
				for(var/obj/structure/shuttle/engine/propulsion/P in odyssey_shuttle.shuttle_contents())
					spawn()
						P.shoot_exhaust(backward = 3)
				return 0

			// --- Shuttle recalled back to centcom ---
			if(timeleft > timelimit)
				online = 0
				direction = 0
				endtime = null
				odyssey_shuttle.bluespace_jump_state = JUMP_NONE
				return 0

			else if((fake_recall != 0) && (timeleft <= fake_recall))
				recall()
				fake_recall = 0
				return 0

			// --- Timer hit zero: begin the bluespace jump ---
			else if(timeleft <= 0)
				shuttle_phase("transit", 0)
				return 1

		// SHUTTLE_ON_STATION is unused for Odyssey - the ship IS the station

	return 0

/datum/emergency_shuttle/odyssey/incall(coeff = 1)
	if(shutdown)
		return
	if((!universe.OnShuttleCall(null) || deny_shuttle) && alert == 1)
		return
	if(endtime)
		setdirection(EMERGENCY_SHUTTLE_GOING_TO_STATION)
	else
		settimeleft(300 * coeff) // 5 minutes
		online = 1
		setdirection(EMERGENCY_SHUTTLE_GOING_TO_STATION)
		if(always_fake_recall)
			fake_recall = rand(150, 250)
	if(alert == 0)
		for(var/area/A in areas)
			if(istype(A, /area/hallway))
				A.readyalert()

/datum/emergency_shuttle/odyssey/recall()
	if(shutdown)
		return
	if(!can_recall)
		return
	if(direction == EMERGENCY_SHUTTLE_GOING_TO_STATION)
		var/timeleft = timeleft()
		if(alert == 0)
			if(timeleft >= 300)
				return
			command_alert(/datum/command_alert/emergency_shuttle_recalled)
			world << sound('sound/AI/shuttlerecalled.ogg')
			setdirection(EMERGENCY_SHUTTLE_RECALLED)
			online = 1
			odyssey_shuttle.bluespace_jump_state = JUMP_NONE
			for(var/area/A in areas)
				if(istype(A, /area/hallway))
					A.readyreset()
			return
		else
			captain_announce("The Bluespace jump has been cancelled.")
			setdirection(EMERGENCY_SHUTTLE_RECALLED)
			online = 1
			odyssey_shuttle.bluespace_jump_state = JUMP_NONE
			return

/datum/emergency_shuttle/odyssey/shuttle_phase(phase, casual = 1)
	switch(phase)
		if("station")
			message_admins("Emergency shuttle panel: 'move to station' is not applicable for the Odyssey Bluespace Jump.")
			return

		if("transit")
			// Move Odyssey to its transit port
			location = SHUTTLE_ON_STANDBY
			departed = 1
			direction = EMERGENCY_SHUTTLE_GOING_TO_CENTCOMM
			settimeleft(ODYSSEY_TRANSIT_TIME)

			command_alert(/datum/command_alert/emergency_shuttle_left)
			vote_preload()

			odyssey_shuttle.bluespace_jump_state = JUMP_COMMITTED

			// Close doors
			for(var/obj/machinery/door/unpowered/shuttle/D in odyssey_shuttle.shuttle_contents())
				spawn(0)
					D.close()
					D.locked = 1

			// Fire engines
			for(var/obj/structure/shuttle/engine/propulsion/P in odyssey_shuttle.shuttle_contents())
				spawn()
					P.shoot_exhaust(backward = 3)

			// Move to transit
			if(!odyssey_shuttle.move_to_dock(odyssey_shuttle.transit_port, 0, turn(odyssey_shuttle.dir, 180)))
				message_admins("WARNING: THE ODYSSEY COULDN'T MOVE TO TRANSIT! PANIC PANIC PANIC")

			hyperspace_sounds("progression")

			// Add bluespacify overlay to all hyperspace turfs in transit VZ
			if(odyssey_shuttle.transit_port)
				var/datum/virtual_z/transit_vz = odyssey_shuttle.transit_port.get_virtual_z()
				if(transit_vz)
					bs_overlay = new /obj/effect/overlay/bluespacify()
					bs_overlay.plane = FLOAT_PLANE // Render at transit turf's plane so it stays below catwalks and shuttle objects
					for(var/turf/space/transit/T in transit_vz.get_turfs())
						T.vis_contents += bs_overlay

			// Switch all sound systems on the shuttle to the emergency shuttle frequency and play music
			for(var/obj/machinery/media/receiver/boombox/wallmount/R in odyssey_shuttle.shuttle_contents())
				R.disconnect_frequency()
				R.media_frequency = 953
				R.connect_frequency()
			spawn()
				for(var/obj/machinery/media/jukebox/superjuke/shuttle/SJ in machines)
					SJ.playing = 1
					SJ.update_music()
					SJ.update_icon()

		if("centcom")
			vote_preload()
			location = EMERGENCY_SHUTTLE_GOING_TO_CENTCOMM

			// Sell items the crew brought
			for(var/atom/movable/MA in odyssey_shuttle.shuttle_contents())
				if(MA.anchored && !ismecha(MA))
					continue
				if(istype(MA, /obj/structure/closet/crate))
					for(var/obj/A in MA)
						SSsupply_shuttle.SellObjToOrders(A, 1, TRUE)
				else
					SSsupply_shuttle.SellObjToOrders(MA, 0, TRUE)

				for(var/datum/centcomm_order/O in SSsupply_shuttle.centcomm_orders)
					O.cargo_contribution = 0
					if(O.CheckFulfilled())
						if(!istype(O, /datum/centcomm_order/per_unit))
							O.Pay()
						SSsupply_shuttle.centcomm_orders.Remove(O)
						for(var/obj/machinery/computer/supplycomp/S in SSsupply_shuttle.supply_consoles)
							S.say("Central Command request fulfilled!")
							playsound(S, 'sound/machines/info.ogg', 50, 1)

			if(ticker)
				ticker.mode.ShuttleDocked(2)

			// Move Odyssey to centcom dock
			odyssey_shuttle.open_all_doors()
			if(!odyssey_shuttle.move_to_dock(odyssey_shuttle.dock_centcom, 0, odyssey_shuttle.dir))
				message_admins("WARNING: THE ODYSSEY COULDN'T MOVE TO CENTCOMM! PANIC PANIC PANIC")

			// Unbolt and open the starboard airlocks
			for(var/obj/machinery/door/airlock/A in odyssey_shuttle.shuttle_contents())
				if(A.id_tag == "starboard_int_airlock" || A.id_tag == "starboard_ext_airlock")
					spawn(0)
						A.locked = 0
						A.open(1)

			online = 0

/datum/emergency_shuttle/odyssey/hyperspace_sounds(phase)
	var/frequency = get_rand_frequency()
	switch(phase)
		if("progression")
			for(var/mob/M in player_list)
				if(M && M.client)
					var/turf/M_turf = get_turf(M)
					if(M_turf.z == odyssey_shuttle.linked_port.z)
						M.playsound_local(odyssey_shuttle.linked_port, 'sound/machines/hyperspace_progress.ogg', 75 - (get_dist(odyssey_shuttle.linked_port, M_turf) * 2), 1, frequency, falloff = 5)
		if("end")
			for(var/mob/M in player_list)
				if(M && M.client)
					var/turf/M_turf = get_turf(M)
					if(M_turf.z == odyssey_shuttle.linked_port.z)
						M.playsound_local(odyssey_shuttle.linked_port, 'sound/machines/hyperspace_end.ogg', 75 - (get_dist(odyssey_shuttle.linked_port, M_turf) * 2), 1, frequency, falloff = 5)

/datum/command_alert/emergency_shuttle_called/announce()
	message = "A Bluespace jump has been initiated. The jump will engage in [round(emergency_shuttle.timeleft()/60)] minutes."
	noalert = 1
	if(justification)
		message += " Justification: [justification]"
	..()

/turf/space/transit/Entered(atom/movable/A, atom/OldLoc)
	if(isliving(A) && !isobserver(A))
		var/datum/virtual_z/transit_v = src.v
		if(transit_v && transit_v.level_type == VZ_TRANSIT)
			var/datum/emergency_shuttle/odyssey/ES = emergency_shuttle
			if(istype(ES) && ES.bs_overlay)
				A.visible_message("<span class='warning'>\The [A] is engulfed by crackling bluespace energy and flashes out of existence!</span>",\
					"<span class='danger'>You pass beyond the ship's protective field. Raw bluespace energy tears through you at the molecular level. There is a brilliant flash, and then nothing.</span>",\
					"<span class='warning'>You hear a deafening crack of displaced energy.</span>")
				playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
				A.supermatter_act(src)
				return
			var/list/datum/virtual_z/destinations = list()
			for(var/datum/virtual_z/vz in map.vLevels)
				if(vz.level_type == VZ_PARKING || vz.level_type == VZ_SPACE)
					destinations += vz
			if(destinations.len)
				var/datum/virtual_z/dest = pick(destinations)
				for(var/i = 1 to 50)
					var/tx = rand(dest.x_min + TRANSITIONEDGE, dest.x_max - TRANSITIONEDGE)
					var/ty = rand(dest.y_min + TRANSITIONEDGE, dest.y_max - TRANSITIONEDGE)
					var/turf/T = locate(tx, ty, dest.z())
					if(istype(T, /turf/space) && !istype(T, /turf/space/transit) && !istype(T, /turf/unsimulated/border))
						to_chat(A, "<span class='warning'>You are violently thrown out of hyperspace!</span>")
						var/mob/living/L = A
						transit_v.mob_exited(L)
						A.forceMove(T)
						dest.mob_entered(L)
						return
	..()

#undef ODYSSEY_TRANSIT_TIME
#undef JUMP_NONE
#undef JUMP_COUNTDOWN
#undef JUMP_COMMITTED
