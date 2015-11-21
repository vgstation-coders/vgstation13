/obj/machinery/atmospherics/unary/vent
	icon = 'icons/obj/atmospherics/pipe_vent.dmi'
	icon_state = "intact"
	name = "Vent"
	desc = "A large air vent"
	level = 1
	var/volume = 250
	dir = SOUTH
	initialize_directions = SOUTH
	var/build_killswitch = 1

/obj/machinery/atmospherics/unary/vent/high_volume
	name = "Larger vent"
	volume = 1000

/obj/machinery/atmospherics/unary/vent/New()
	..()
	air_contents.volume=volume

/obj/machinery/atmospherics/unary/vent/process()
	. = ..()

	CHECK_DISABLED(vents)
	if (!node)
		return// Turning off the vent is a PITA. - N3X

	// New GC does this sometimes
	if(!loc) return

	//air_contents.mingle_with_turf(loc)

	var/datum/gas_mixture/removed = air_contents.remove(volume)

	loc.assume_air(removed)

	return 1


/obj/machinery/atmospherics/unary/vent/update_icon()
	if(node)
		icon_state = "intact"
	else
		icon_state = "exposed"
	..()
	if (istype(loc, /turf/simulated/floor) && node)
		var/turf/simulated/floor/floor = loc
		if(floor.floor_tile && node.alpha == 128)
			underlays.Cut()



/obj/machinery/atmospherics/unary/vent/initialize()
	..()
	update_icon()


/obj/machinery/atmospherics/unary/vent/disconnect(obj/machinery/atmospherics/reference)
	..()
	update_icon()


/obj/machinery/atmospherics/unary/vent/hide(var/i)
	update_icon()

/obj/machinery/atmospherics/unary/vent/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	if(pipe)
		dir = pipe.dir
		initialize_directions = pipe.get_pipe_dir()
		if (pipe.pipename)
			name = pipe.pipename
	else
		initialize_directions = dir
	var/turf/T = loc
	level = T.intact ? 2 : 1
	initialize()
	build_network()
	if (node)
		node.initialize()
		node.build_network()
	return 1
