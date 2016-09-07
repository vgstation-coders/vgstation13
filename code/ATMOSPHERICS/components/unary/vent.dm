/obj/machinery/atmospherics/unary/vent
	icon = 'icons/obj/atmospherics/pipe_vent.dmi'
	icon_state = "base"
	name = "Vent"
	desc = "A large air vent"
	level = 1
	var/volume = 250
	dir = SOUTH
	initialize_directions = SOUTH
	var/build_killswitch = 1

	ex_node_offset = 3
	var/static/image/bezel = image('icons/obj/atmospherics/pipe_vent.dmi', "bezel")

/obj/machinery/atmospherics/unary/vent/high_volume
	name = "Larger vent"
	volume = 1000

/obj/machinery/atmospherics/unary/vent/New()
	..()
	air_contents.volume = volume

/obj/machinery/atmospherics/unary/vent/process()
	. = ..()

	CHECK_DISABLED(vents)
	if (!node)
		return// Turning off the vent is a PITA. - N3X

	// New GC does this sometimes
	if(!loc)
		return

	//air_contents.mingle_with_turf(loc)

	var/datum/gas_mixture/removed = air_contents.remove(volume)

	loc.assume_air(removed)
	if(network)
		network.update = TRUE

	return 1


/obj/machinery/atmospherics/unary/vent/update_icon()
	icon_state = "base"

	..()

	if (level == 1)
		bezel.layer = VENT_BEZEL_LAYER
		bezel.plane = ABOVE_PLATING_PLANE

	else
		bezel.layer = EXPOSED_PIPE_LAYER + 1
		bezel.plane = ABOVE_TURF_PLANE

	underlays += bezel

/obj/machinery/atmospherics/unary/vent/initialize()
	..()
	update_icon()


/obj/machinery/atmospherics/unary/vent/disconnect(obj/machinery/atmospherics/reference)
	..()
	update_icon()


/obj/machinery/atmospherics/unary/vent/hide(var/i)
	update_icon()
