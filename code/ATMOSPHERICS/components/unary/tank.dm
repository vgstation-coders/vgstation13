/obj/machinery/atmospherics/unary/tank
	icon = 'icons/obj/atmospherics/pipe_tank.dmi'
	icon_state = "co2"
	name = "Pressure Tank"
	desc = "A large vessel containing pressurized gas."
	starting_volume = 2000 //in liters, 1 meters by 1 meters by 2 meters
	dir = SOUTH
	initialize_directions = SOUTH
	density = 1
	default_colour = "#b77900"
	anchored = 1
	machine_flags = WRENCHMOVE

	var/list/rotate_verbs = list(
		/obj/machinery/atmospherics/unary/tank/verb/rotate,
		/obj/machinery/atmospherics/unary/tank/verb/rotate_ccw,
	)

/obj/machinery/atmospherics/unary/tank/New()
	..()
	air_contents.temperature = T20C
	atmos_machines.Remove(src)
	initialize_directions = dir
	if(anchored)
		verbs -= rotate_verbs

/obj/machinery/atmospherics/unary/tank/process()
	if(!network) //this apparently cuts down on build_network calls or something?? pipes do it too
		. = ..() //all I know is that removing it breaks the tank.


/obj/machinery/atmospherics/unary/tank/carbon_dioxide
	name = "Pressure Tank (Carbon Dioxide)"

/obj/machinery/atmospherics/unary/tank/carbon_dioxide/New()
	..()

	air_contents.adjust_gas(GAS_CARBON, (25*ONE_ATMOSPHERE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature))


/obj/machinery/atmospherics/unary/tank/toxins
	icon_state = "plasma"
	name = "Pressure Tank (Plasma)"

/obj/machinery/atmospherics/unary/tank/toxins/New()
	..()

	air_contents.adjust_gas(GAS_PLASMA, (25*ONE_ATMOSPHERE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature))


/obj/machinery/atmospherics/unary/tank/oxygen_agent_b
	icon_state = "plasma"
	name = "Pressure Tank (Oxygen + Plasma)"

/obj/machinery/atmospherics/unary/tank/oxygen_agent_b/New()
	..()

	air_contents.adjust_gas(GAS_OXAGENT, (25*ONE_ATMOSPHERE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature))


/obj/machinery/atmospherics/unary/tank/oxygen
	icon_state = "o2"
	name = "Pressure Tank (Oxygen)"
	default_colour = "#00b8b8"

/obj/machinery/atmospherics/unary/tank/oxygen/New()
	..()

	air_contents.adjust_gas(GAS_OXYGEN, (25*ONE_ATMOSPHERE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature))

/obj/machinery/atmospherics/unary/tank/nitrogen
	icon_state = "n2"
	name = "Pressure Tank (Nitrogen)"
	default_colour = "#00b8b8"

/obj/machinery/atmospherics/unary/tank/nitrogen/New()
	..()

	air_contents.adjust_gas(GAS_NITROGEN, (25*ONE_ATMOSPHERE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature))

/obj/machinery/atmospherics/unary/tank/air
	icon_state = "air"
	name = "Pressure Tank (Air)"
	default_colour = "#0000b7"

/obj/machinery/atmospherics/unary/tank/air/New()
	..()

	air_contents.adjust_multi(
		GAS_OXYGEN, (25*ONE_ATMOSPHERE*O2STANDARD)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature),
		GAS_NITROGEN, (25*ONE_ATMOSPHERE*N2STANDARD)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature))

/obj/machinery/atmospherics/unary/tank/update_icon()
	..()

/obj/machinery/atmospherics/unary/tank/disconnect(obj/machinery/atmospherics/reference)
	..()
	update_icon()

/obj/machinery/atmospherics/unary/tank/verb/rotate()
	set name = "Rotate Clockwise"
	set category = "Object"
	set src in oview(1)

	if(src.anchored || usr:stat)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.dir = turn(src.dir, -90)
	return 1

/obj/machinery/atmospherics/unary/tank/verb/rotate_ccw()
	set name = "Rotate Counter Clockwise"
	set category = "Object"
	set src in oview(1)

	if(src.anchored || usr:stat)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.dir = turn(src.dir, 90)
	return 1

/obj/machinery/atmospherics/unary/tank/wrenchAnchor(var/mob/user)
	. = ..()
	if(!.)
		return
	if(anchored)
		verbs -= rotate_verbs
		initialize_directions = dir
		initialize()
		build_network()
		if (node1)
			node1.initialize()
			node1.build_network()
	else
		verbs += rotate_verbs
		if(node1)
			node1.disconnect(src)
			node1 = null
		if(network)
			qdel(network)
			network = null
		initialize_directions = 0 //this prevents things from attaching to us when we're unanchored
		update_icon()

/obj/machinery/atmospherics/unary/tank/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/device/rcd/rpd) || istype(W, /obj/item/device/pipe_painter))
		return // Coloring pipes.
	if (istype(W, /obj/item/device/analyzer) && get_dist(user, src) <= 1)
		user.visible_message("<span class='attack'>[user] has used [W] on [bicon(icon)] [src]</span>", "<span class='attack'>You use \the [W] on [bicon(icon)] [src]</span>")
		var/obj/item/device/analyzer/analyzer = W
		user.show_message(analyzer.output_gas_scan(air_contents, src, 0), 1)
	
	return ..()

/obj/machinery/atmospherics/unary/tank/isConnectable(var/obj/machinery/atmospherics/target, var/direction, var/given_layer)
	if(!anchored)
		return FALSE
	return ..()

/obj/machinery/atmospherics/unary/tank/hide(var/i)
	update_icon()
