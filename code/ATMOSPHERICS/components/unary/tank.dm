#define STARTING_PRESSURE 45*ONE_ATMOSPHERE
#define MAX_EXPLOSION_PRESSURE 45*ONE_ATMOSPHERE

/obj/machinery/atmospherics/unary/tank
	icon = 'icons/obj/atmospherics/pipe_tank.dmi'
	icon_state = "co2"
	name = "Pressure Tank"
	desc = "A large vessel containing pressurized gas."
	starting_volume = 2500 //in liters, 1x1x2.5m to match our standard cell size (volume of one tile)
	dir = SOUTH
	initialize_directions = SOUTH
	density = 1
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

/obj/machinery/atmospherics/unary/tank/Destroy()
	getFromPool(/obj/item/stack/sheet/metal, get_turf(src), 5)
	..()

/obj/machinery/atmospherics/unary/tank/ex_act()
	punctured()

/obj/machinery/atmospherics/unary/tank/proc/punctured(var/mob/user as mob)
	var/internal_pressure = air_contents.return_pressure()
	var/datum/gas_mixture/environment = loc.return_air()
	var/external_pressure = environment.return_pressure()
	var/pressure_delta = internal_pressure - external_pressure
	if(pressure_delta >= 500) //only explode if there's this much pressure differential
		if(user)
			to_chat(user, "<span class='warning'>Air violently rushes out of the punctured tank!</span>")
		environment.merge(air_contents) //this actually dupes gas, but that's fine because air_contents will be deleted soon
		var/explosion_pressure = min(pressure_delta, MAX_EXPLOSION_PRESSURE)
		var/light_range = round(explosion_pressure / 1000, 1)
		explosion(src.loc, -1, -1, light_range)
	else
		environment.merge(air_contents)
	if(src)
		qdel(src)

/obj/machinery/atmospherics/unary/tank/process()
	if(!network) //this apparently cuts down on build_network calls or something?? pipes do it too
		. = ..() //all I know is that removing it breaks the tank.


/obj/machinery/atmospherics/unary/tank/carbon_dioxide
	name = "Pressure Tank (Carbon Dioxide)"

/obj/machinery/atmospherics/unary/tank/carbon_dioxide/New()
	..()

	air_contents.adjust_gas(GAS_CARBON, (STARTING_PRESSURE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature))


/obj/machinery/atmospherics/unary/tank/toxins
	icon_state = "plasma"
	name = "Pressure Tank (Plasma)"

/obj/machinery/atmospherics/unary/tank/toxins/New()
	..()

	air_contents.adjust_gas(GAS_PLASMA, (STARTING_PRESSURE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature))


/obj/machinery/atmospherics/unary/tank/oxygen_agent_b
	icon_state = "plasma"
	name = "Pressure Tank (Oxygen + Plasma)"

/obj/machinery/atmospherics/unary/tank/oxygen_agent_b/New()
	..()

	air_contents.adjust_gas(GAS_OXAGENT, (STARTING_PRESSURE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature))


/obj/machinery/atmospherics/unary/tank/oxygen
	icon_state = "o2"
	name = "Pressure Tank (Oxygen)"

/obj/machinery/atmospherics/unary/tank/oxygen/New()
	..()

	air_contents.adjust_gas(GAS_OXYGEN, (STARTING_PRESSURE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature))

/obj/machinery/atmospherics/unary/tank/nitrogen
	icon_state = "n2"
	name = "Pressure Tank (Nitrogen)"

/obj/machinery/atmospherics/unary/tank/nitrogen/New()
	..()

	air_contents.adjust_gas(GAS_NITROGEN, (STARTING_PRESSURE)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature))

/obj/machinery/atmospherics/unary/tank/air
	icon_state = "air"
	name = "Pressure Tank (Air)"

/obj/machinery/atmospherics/unary/tank/air/New()
	..()

	air_contents.adjust_multi(
		GAS_OXYGEN, (STARTING_PRESSURE*O2STANDARD)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature),
		GAS_NITROGEN, (STARTING_PRESSURE*N2STANDARD)*(starting_volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature))

/obj/machinery/atmospherics/unary/tank/empty
	icon_state = "grey"
	name = "Pressure Tank"
	can_be_coloured = 1
	color = "#b4b4b4"

/obj/machinery/atmospherics/unary/tank/empty/unanchored
	anchored = 0

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
		update_icon()

/obj/machinery/atmospherics/unary/tank/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if (istype(W, /obj/item/device/analyzer) && get_dist(user, src) <= 1)
		var/obj/item/device/analyzer/analyzer = W
		user.show_message(analyzer.output_gas_scan(air_contents, src, 0), 1)
	
	//deconstruction
	if(iswelder(W) && !anchored)
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.remove_fuel(1,user))
			return
		playsound(src, 'sound/items/Welder2.ogg', 100, 1)
		user.visible_message("<span class='notice'>[user] starts disassembling \the [src].</span>", \
							"<span class='notice'>You start disassembling \the [src].</span>")
		if(do_after(user, src, 40))
			user.visible_message("<span class='warning'>[user] dissasembles \the [src].</span>", \
			"<span class='notice'>You dissasemble \the [src].</span>")
			//getFromPool(/obj/item/stack/sheet/metal, get_turf(src), 5)
			punctured(user)
		return

	return ..()

/obj/machinery/atmospherics/unary/tank/isConnectable(var/obj/machinery/atmospherics/target, var/direction, var/given_layer)
	if(!anchored)
		return FALSE
	return ..()

/obj/machinery/atmospherics/unary/tank/hide(var/i)
	update_icon()

#undef STARTING_PRESSURE
#undef MAX_EXPLOSION_PRESSURE
