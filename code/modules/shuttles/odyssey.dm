var/global/datum/shuttle/odyssey/odyssey_shuttle = new(starting_area = /area/shuttle/odyssey)

/datum/shuttle/odyssey
	name = "NTEV Odyssey"
	cant_leave_zlevel = list()
	dir = EAST

	cooldown = 60 SECONDS
	transit_delay = 30 SECONDS
	transit_timeout = 0 // Disable transit safety recall - shuttle can remain in hyperspace indefinitely
	stable = 0

	req_access = list(access_captain)

/datum/shuttle/odyssey/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/odyssey/outpost)
	add_dock(/obj/docking_port/destination/odyssey/deep_space)
	add_dock(/obj/docking_port/destination/odyssey/dj_sat)
	add_dock(/obj/docking_port/destination/odyssey/derelict)

	var/obj/docking_port/destination/transit/transit = generate_transit_area(src)
	if(transit)
		set_transit_dock(transit)
		transit.areaname = "hyperspace exploration"
		add_dock(transit)

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
