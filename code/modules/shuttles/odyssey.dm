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

	// If starting at outpost, enable external power on SMES units
	if(istype(current_port, /obj/docking_port/destination/odyssey/outpost))
		for(var/obj/machinery/power/battery/smes/S in shuttle_contents())
			S.external_power_supply = TRUE

/datum/shuttle/odyssey/after_flight()
	..()
	var/at_outpost = istype(current_port, /obj/docking_port/destination/odyssey/outpost)
	for(var/obj/machinery/power/battery/smes/S in shuttle_contents())
		S.external_power_supply = at_outpost
	// Clean up lingering beach water effects on shuttle turfs after landing
	for(var/turf/T in shuttle_contents())
		for(var/obj/effect/beach_water/unsimmed/W in T.vis_contents)
			T.vis_contents -= W

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

/obj/machinery/computer/shuttle_control/odyssey
	name = "NTEV Odyssey shuttle control computer"

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

/datum/shuttle/odyssey_transfer/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/odyssey_transfer/transfer)
	add_dock(/obj/docking_port/destination/odyssey_transfer/nt_outpost)

/obj/docking_port/destination/odyssey_transfer/transfer
	areaname = "NTEV Odyssey Crew Transfer Dock"

/obj/docking_port/destination/odyssey_transfer/nt_outpost
	areaname = "NTEV Odyssey Crew Transfer Shuttle Landing Zone"

/obj/machinery/computer/shuttle_control/odyssey_transfer
	name = "NTEV Odyssey Crew Transfer Shuttle control computer"

/obj/machinery/computer/shuttle_control/odyssey_transfer/New()
	link_to(odyssey_transfer_shuttle)
	.=..()

/proc/odyssey_bluespace_transit()
	if(!odyssey_shuttle || !odyssey_shuttle.transit_port)
		return
	var/datum/virtual_z/transit_vz = odyssey_shuttle.transit_port.get_virtual_z()
	if(!transit_vz)
		return
	var/datum/emergency_shuttle/odyssey/ES = emergency_shuttle
	if(!istype(ES))
		return
	// Toggle: remove if already active
	if(ES.bs_overlay)
		for(var/turf/space/transit/T in transit_vz.get_turfs())
			T.vis_contents -= ES.bs_overlay
		qdel(ES.bs_overlay)
		ES.bs_overlay = null
		return
	ES.bs_overlay = new /obj/effect/overlay/bluespacify()
	ES.bs_overlay.plane = FLOAT_PLANE
	for(var/turf/space/transit/T in transit_vz.get_turfs())
		T.vis_contents += ES.bs_overlay
