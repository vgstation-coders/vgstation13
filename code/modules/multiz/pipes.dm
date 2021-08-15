////////////////////////////
// parent class for pipes //
////////////////////////////
obj/machinery/atmospherics/pipe/zpipe
	icon = 'icons/obj/pipes.dmi'
	icon_state = "down"

	name = "upwards pipe"
	desc = "A pipe segment to connect upwards."

	volume = 70

	dir = SOUTH
	initialize_directions = SOUTH

	// node1 is the connection on the same Z
	// node2 is the connection on the other Z

	var/minimum_temperature_difference = 300
	var/thermal_conductivity = 0 //WALL_HEAT_TRANSFER_COEFFICIENT No

	var/maximum_pressure = 70*ONE_ATMOSPHERE
	var/fatigue_pressure = 55*ONE_ATMOSPHERE
	alert_pressure = 55*ONE_ATMOSPHERE


	level = 1

obj/machinery/atmospherics/pipe/zpipe/New()
	..()
	switch(dir)
		if(SOUTH)
			initialize_directions = SOUTH
		if(NORTH)
			initialize_directions = NORTH
		if(WEST)
			initialize_directions = WEST
		if(EAST)
			initialize_directions = EAST
		if(NORTHEAST)
			initialize_directions = NORTH
		if(NORTHWEST)
			initialize_directions = WEST
		if(SOUTHEAST)
			initialize_directions = EAST
		if(SOUTHWEST)
			initialize_directions = SOUTH

/obj/machinery/atmospherics/pipe/zpipe/hide(var/i)
	if(istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()

obj/machinery/atmospherics/pipe/zpipe/process()
	if(!parent) //This should cut back on the overhead calling build_network thousands of times per cycle
		..()
	else
		. = PROCESS_KILL

obj/machinery/atmospherics/pipe/zpipe/check_pressure(pressure)
	var/datum/gas_mixture/environment = loc.return_air()

	var/pressure_difference = pressure - environment.return_pressure()

	if(pressure_difference > maximum_pressure)
		burst()

	else if(pressure_difference > fatigue_pressure)
		//TODO: leak to turf, doing pfshhhhh
		if(prob(5))
			burst()

	else return 1

obj/machinery/atmospherics/pipe/zpipe/proc/burst()
	src.visible_message("<span class='warning'>\The [src] bursts!</span>");
	playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
	var/datum/effect/system/smoke_spread/smoke = new
	smoke.set_up(1,0, src.loc, 0)
	smoke.start()
	qdel(src) // NOT qdel.

obj/machinery/atmospherics/pipe/zpipe/proc/normalize_dir()
	if(dir == (NORTH|SOUTH))
		set_dir(NORTH)
	else if(dir == (EAST|WEST))
		set_dir(EAST)

obj/machinery/atmospherics/pipe/zpipe/Destroy()
	if(node1)
		node1.disconnect(src)
	if(node2)
		node2.disconnect(src)
	..()

obj/machinery/atmospherics/pipe/zpipe/pipeline_expansion()
	return list(node1, node2)

obj/machinery/atmospherics/pipe/zpipe/update_icon()
	//color = pipe_color
	return

obj/machinery/atmospherics/pipe/zpipe/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node2 = null

	return null
/////////////////////////
// the elusive up pipe //
/////////////////////////
obj/machinery/atmospherics/pipe/zpipe/up
	icon_state = "up"
	name = "upwards pipe"
	desc = "A pipe segment to connect upwards."

obj/machinery/atmospherics/pipe/zpipe/up/initialize()
	normalize_dir()
	var/node1_dir

	for(var/direction in cardinal)
		if(direction&initialize_directions)
			if (!node1_dir)
				node1_dir = direction

	node1 = findConnecting(node1_dir)

	var/turf/above = GetAbove(src)
	if(above)
		for(var/obj/machinery/atmospherics/target in above)
			if(target.initialize_directions && istype(target, /obj/machinery/atmospherics/pipe/zpipe/down))
				if(target.piping_layer == src.piping_layer || target.pipe_flags & ALL_LAYER)
					node2 = target


	var/turf/T = src.loc			// hide if turf is not intact
	hide(!T.is_plating())

///////////////////////
// and the down pipe //
///////////////////////

obj/machinery/atmospherics/pipe/zpipe/down
	icon_state = "down"
	name = "downwards pipe"
	desc = "A pipe segment to connect downwards."

obj/machinery/atmospherics/pipe/zpipe/down/initialize()
	normalize_dir()
	var/node1_dir

	for(var/direction in cardinal)
		if(direction&initialize_directions)
			if (!node1_dir)
				node1_dir = direction

	node1 = findConnecting(node1_dir)

	var/turf/below = GetBelow(src)
	if(below)
		for(var/obj/machinery/atmospherics/target in below)
			if(target.initialize_directions && istype(target, /obj/machinery/atmospherics/pipe/zpipe/up))
				if(target.piping_layer == src.piping_layer || target.pipe_flags & ALL_LAYER)
					node2 = target


	var/turf/T = src.loc			// hide if turf is not intact
	hide(!T.is_plating())

///////////////////////
// supply/scrubbers  //
///////////////////////

obj/machinery/atmospherics/pipe/zpipe/up/scrubbers
	icon_state = "up"
	name = "upwards scrubbers pipe"
	desc = "A scrubbers pipe segment to connect upwards."
	//connect_types = CONNECT_TYPE_SCRUBBER
	layer = 2.38
	//icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

obj/machinery/atmospherics/pipe/zpipe/up/supply
	icon_state = "up"
	name = "upwards supply pipe"
	desc = "A supply pipe segment to connect upwards."
	//connect_types = CONNECT_TYPE_SUPPLY
	layer = 2.39
	//icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

obj/machinery/atmospherics/pipe/zpipe/down/scrubbers
	icon_state = "down"
	name = "downwards scrubbers pipe"
	desc = "A scrubbers pipe segment to connect downwards."
	//connect_types = CONNECT_TYPE_SCRUBBER
	layer = 2.38
	//icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

obj/machinery/atmospherics/pipe/zpipe/down/supply
	icon_state = "down"
	name = "downwards supply pipe"
	desc = "A supply pipe segment to connect downwards."
	//connect_types = CONNECT_TYPE_SUPPLY
	layer = 2.39
	//icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/datum/rcd_schematic/pipe/z_up
	name		= "Up Pipe"

	pipe_id		= PIPE_Z_UP
	pipe_type	= PIPE_Z_UP_BINARY

/datum/rcd_schematic/pipe/z_down
	name		= "Down Pipe"

	pipe_id		= PIPE_Z_DOWN
	pipe_type	= PIPE_Z_DOWN_BINARY

// Disposal Pipes

///// Z-Level stuff
/obj/structure/disposalpipe/up
	icon_state = "pipe-u"

/obj/structure/disposalpipe/up/New()
	..()
	dpdir = dir
	update()
	return

/obj/structure/disposalpipe/up/nextdir(var/fromdir)
	var/nextdir
	if(fromdir == 11)
		nextdir = dir
	else
		nextdir = 12
	return nextdir

/obj/structure/disposalpipe/up/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.set_dir(nextdir)

	var/turf/T
	var/obj/structure/disposalpipe/P

	if(nextdir == 12)
		T = GetAbove(src)
		if(!T)
			H.forceMove(loc)
			return
		else
			for(var/obj/structure/disposalpipe/down/F in T)
				P = F

	else
		T = get_step(src.loc, H.dir)
		P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.forceMove(P)
	else			// if wasn't a pipe, then set loc to turf
		H.forceMove(T)
		return null

	return P

/obj/structure/disposalpipe/down
	icon_state = "pipe-d"

/obj/structure/disposalpipe/down/New()
	..()
	dpdir = dir
	update()
	return

/obj/structure/disposalpipe/down/nextdir(var/fromdir)
	var/nextdir
	if(fromdir == 12)
		nextdir = dir
	else
		nextdir = 11
	return nextdir

/obj/structure/disposalpipe/down/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.dir = nextdir

	var/turf/T
	var/obj/structure/disposalpipe/P

	if(nextdir == 11)
		T = GetBelow(src)
		if(!T)
			H.forceMove(src.loc)
			return
		else
			for(var/obj/structure/disposalpipe/up/F in T)
				P = F

	else
		T = get_step(src.loc, H.dir)
		P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.forceMove(P)
	else			// if wasn't a pipe, then set loc to turf
		H.forceMove(T)
		return null

	return P