
// Regular pipe colors
//                         #RRGGBB
#define PIPE_COLOR_BLUE   "#0000FF"
#define PIPE_COLOR_CYAN   "#00FFFF"
#define PIPE_COLOR_GREEN  "#00FF00"
#define PIPE_COLOR_GREY   "#FFFFFF" // White
#define PIPE_COLOR_PURPLE "#800080"
#define PIPE_COLOR_RED    "#FF0000"
#define PIPE_COLOR_YELLOW "#FFA800" // Orange, actually. Yellow looked awful.

// Insulated pipes
#define IPIPE_COLOR_RED   PIPE_COLOR_RED
#define IPIPE_COLOR_BLUE  "#4285F4"

/obj/machinery/atmospherics/pipe
	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/datum/pipeline/parent
	var/volume = 0
	force = 20
	layer = 2.4 //under wires with their 2.44
	use_power = 0
	var/alert_pressure = 80*ONE_ATMOSPHERE
	var/baseicon=""

	available_colors = list(
		"grey"=PIPE_COLOR_GREY,
		"red"=PIPE_COLOR_RED,
		"blue"=PIPE_COLOR_BLUE,
		"cyan"=PIPE_COLOR_CYAN,
		"green"=PIPE_COLOR_GREEN,
		"yellow"=PIPE_COLOR_YELLOW,
		"purple"=PIPE_COLOR_PURPLE
	)

/obj/machinery/atmospherics/pipe/singularity_pull(/obj/machinery/singularity/S, size)
	return
/obj/machinery/atmospherics/pipe/proc/pipeline_expansion()
	return null


/obj/machinery/atmospherics/pipe/proc/check_pressure(pressure)
	//Return 1 if parent should continue checking other pipes
	//Return null if parent should stop checking other pipes. Recall: del(src) will by default return null
	return 1


/obj/machinery/atmospherics/pipe/return_air()
	if(!parent)
		parent = getFromDPool(/datum/pipeline)
		parent.build_pipeline(src)
	return parent.air


/obj/machinery/atmospherics/pipe/build_network()
	if(!parent)
		parent = getFromDPool(/datum/pipeline)
		parent.build_pipeline(src)
	return parent.return_network()


/obj/machinery/atmospherics/pipe/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(!parent)
		parent = getFromDPool(/datum/pipeline)
		parent.build_pipeline(src)
	return parent.network_expand(new_network, reference)


/obj/machinery/atmospherics/pipe/return_network(obj/machinery/atmospherics/reference)
	if(!parent)
		parent = getFromDPool(/datum/pipeline)
		parent.build_pipeline(src)
	return parent.return_network(reference)


/obj/machinery/atmospherics/pipe/Destroy()
	if(parent)
		returnToDPool(parent)
	for(var/obj/machinery/meter/M in src.loc)
		if(M.target == src)
			new /obj/item/pipe_meter(src.loc)
			qdel(M)
	if(air_temporary && loc)
		loc.assume_air(air_temporary)

	..()

/obj/machinery/atmospherics/pipe/simple
	icon = 'icons/obj/pipes.dmi'
	icon_state = "intact"
	name = "pipe"
	desc = "A one meter section of regular pipe"
	volume = 70
	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/minimum_temperature_difference = 300
	var/thermal_conductivity = 0 //WALL_HEAT_TRANSFER_COEFFICIENT No

	var/maximum_pressure = 100*ONE_ATMOSPHERE // 10132.5 kPa
	var/fatigue_pressure = 80 *ONE_ATMOSPHERE //  8106   kPa
	alert_pressure       = 80 *ONE_ATMOSPHERE

	// Type of burstpipe to use on burst()
	var/burst_type = /obj/machinery/atmospherics/unary/vent/burstpipe

	level = 1

/obj/machinery/atmospherics/pipe/simple/New()
	..()
	switch(dir)
		if(SOUTH || NORTH)
			initialize_directions = SOUTH|NORTH
		if(EAST || WEST)
			initialize_directions = EAST|WEST
		if(NORTHEAST)
			initialize_directions = NORTH|EAST
		if(NORTHWEST)
			initialize_directions = NORTH|WEST
		if(SOUTHEAST)
			initialize_directions = SOUTH|EAST
		if(SOUTHWEST)
			initialize_directions = SOUTH|WEST


/obj/machinery/atmospherics/pipe/simple/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pipe_dir()
	var/turf/T = loc
	level = T.intact ? 2 : 1
	initialize(1)
	if(!node1&&!node2)
		usr << "<span class='warning'>There's nothing to connect this pipe section to! A pipe segment must be connected to at least one other object!</span>"
		return 0
	update_icon()
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	if (node2)
		node2.initialize()
		node2.build_network()
	return 1


/obj/machinery/atmospherics/pipe/simple/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()


/obj/machinery/atmospherics/pipe/simple/process()
	if(!parent) //This should cut back on the overhead calling build_network thousands of times per cycle
		build_network()
	else
		. = PROCESS_KILL

	/*if(!node1)
		parent.mingle_with_turf(loc, volume)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1

	else if(!node2)
		parent.mingle_with_turf(loc, volume)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if (nodealert)
		nodealert = 0


	else if(parent)
		var/environment_temperature = 0

		if(istype(loc, /turf/simulated/))
			if(loc:blocks_air)
				environment_temperature = loc:temperature
			else
				var/datum/gas_mixture/environment = loc.return_air()
				environment_temperature = environment.temperature

		else
			environment_temperature = loc:temperature

		var/datum/gas_mixture/pipe_air = return_air()

		if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
			parent.temperature_interact(loc, volume, thermal_conductivity)
	*/


/obj/machinery/atmospherics/pipe/simple/check_pressure(pressure)
	if(!loc)
		return

	// Note: This checks the difference between atmospheric pressure and pressure in the pipe.
	// So, a pipe rated at 8,000 kPa in a 104kPa environment will explode at 8,104kPa.
	var/datum/gas_mixture/environment = loc.return_air()

	var/pressure_difference = pressure - environment.return_pressure()

	// Burst check first.
	if(pressure_difference > maximum_pressure && prob(1))
		burst()

	// Groan if that check failed and we're above fatigue pressure
	else if(pressure_difference > fatigue_pressure && prob(1)) // 5 was too often
		groan()

	// Otherwise, continue on.
	else
		return 1

/obj/machinery/atmospherics/pipe/simple/examine(mob/user)
	..()
	user << "<span class='info'>This [src.name] is rated up to [format_num(alert_pressure)] kPa.</span>"

/obj/machinery/atmospherics/pipe/simple/proc/groan()
	src.visible_message("<span class='warning'>\The [src] groans from the pressure!</span>");

	// Need SFX for groaning metal.
	//playsound(get_turf(src), 'sound/effects/groan.ogg', 25, 1)


/obj/machinery/atmospherics/pipe/simple/proc/burst()
	src.visible_message("<span class='danger'>\The [src] bursts!</span>");

	var/turf/T=get_turf(src)

	message_admins("Pipe burst in area [formatJumpTo(T)]")
	var/area/A=get_area_master(src)
	log_game("Pipe burst in area [A.name] ")

	// Disconnect first.
	for(var/obj/machinery/atmospherics/node in pipeline_expansion())
		if(node)
			node.disconnect(src)

	// Move away from explosion
	loc=null

	if(prob(50))
		explosion(T, -1, 1, 2, adminlog=0)
	else
		explosion(T, 0, 1, 2, adminlog=0)

	// Now connect burstpipes.
	var/node_id=0
	for(var/direction in cardinal)
		if(initialize_directions & direction)
			node_id++
			var/obj/machinery/atmospherics/found
			var/node_type=getNodeType(node_id)
			switch(node_type)
				if(PIPE_TYPE_STANDARD)
					found = findConnecting(direction)
				if(PIPE_TYPE_HE)
					found = findConnectingHE(direction)
				else
					error("UNKNOWN RESPONSE FROM [src.type]/getNodeType([node_id]): [node_type]")
					return
			if(!found) continue

			var/obj/machinery/atmospherics/unary/vent/burstpipe/BP = new burst_type(T, setdir=direction)
			BP.color=src.color
			BP.invisibility=src.invisibility
			BP.level=src.level
			BP.do_connect()

	del(src) // NOT qdel.


/obj/machinery/atmospherics/pipe/simple/proc/normalize_dir()
	if(dir==3)
		dir = 1
	else if(dir==12)
		dir = 4


/obj/machinery/atmospherics/pipe/simple/Destroy()
	if(node1)
		node1.disconnect(src)
	if(node2)
		node2.disconnect(src)

	..()


/obj/machinery/atmospherics/pipe/simple/pipeline_expansion()
	return list(node1, node2)


/obj/machinery/atmospherics/pipe/simple/update_icon()
	alpha = invisibility ? 128 : 255
	color = available_colors[_color]
	if(node1&&node2)
		icon_state = "intact"

	else
		if(!node1&&!node2)
			qdel(src) //TODO: silent deleting looks weird
		var/have_node1 = node1?1:0
		var/have_node2 = node2?1:0
		icon_state = "exposed[have_node1][have_node2]"


/obj/machinery/atmospherics/pipe/simple/initialize(var/suppress_icon_check=0)
	normalize_dir()

	findAllConnections(initialize_directions)

	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
	if(!suppress_icon_check)
		update_icon()


/obj/machinery/atmospherics/pipe/simple/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			returnToDPool(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			returnToDPool(parent)
		node2 = null

	update_icon()
	return null

/obj/machinery/atmospherics/pipe/simple/scrubbers
	name = "Scrubbers pipe"
	_color = "red"
	color=PIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/simple/supply
	name = "Air supply pipe"
	_color = "blue"
	color=PIPE_COLOR_BLUE
/obj/machinery/atmospherics/pipe/simple/supplymain
	name = "Main air supply pipe"
	_color = "purple"
	color=PIPE_COLOR_PURPLE
/obj/machinery/atmospherics/pipe/simple/general
	name = "Pipe"
	_color = "grey"
	color=PIPE_COLOR_GREY
/obj/machinery/atmospherics/pipe/simple/yellow
	name = "Pipe"
	_color="yellow"
	color=PIPE_COLOR_YELLOW
/obj/machinery/atmospherics/pipe/simple/cyan
	name = "Pipe"
	_color="cyan"
	color=PIPE_COLOR_CYAN
/obj/machinery/atmospherics/pipe/simple/filtering
	name = "Pipe"
	_color = "green"
	color=PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/simple/scrubbers/visible
	level = 2
/obj/machinery/atmospherics/pipe/simple/scrubbers/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/simple/supply/visible
	level = 2
/obj/machinery/atmospherics/pipe/simple/supply/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/simple/supplymain/visible
	level = 2
/obj/machinery/atmospherics/pipe/simple/supplymain/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/simple/general/visible
	level = 2
/obj/machinery/atmospherics/pipe/simple/general/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/simple/yellow/visible
	level = 2
/obj/machinery/atmospherics/pipe/simple/yellow/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/simple/cyan/visible
	level = 2
/obj/machinery/atmospherics/pipe/simple/cyan/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/simple/filtering/visible
	level = 2
/obj/machinery/atmospherics/pipe/simple/filtering/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/simple/insulated
	name = "Insulated pipe"
	//icon = 'icons/obj/atmospherics/red_pipe.dmi'
	icon = 'icons/obj/atmospherics/insulated.dmi'
	minimum_temperature_difference = 10000
	thermal_conductivity = 0

	maximum_pressure = 1000000 // 1M   kPa
	fatigue_pressure =  900000 // 900k kPa
	alert_pressure   =  900000

	available_colors = list(
		"red"=IPIPE_COLOR_RED,
		"blue"=IPIPE_COLOR_BLUE
	)
	_color = "red"
/obj/machinery/atmospherics/pipe/simple/insulated/visible
	icon_state = "intact"
	level = 2
	color=IPIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/simple/insulated/visible/blue
	color=IPIPE_COLOR_BLUE
	_color = "blue"
/obj/machinery/atmospherics/pipe/simple/insulated/hidden
	icon_state = "intact"
	alpha=128
	level = 1
	color=IPIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/simple/insulated/hidden/blue
	color=IPIPE_COLOR_BLUE
	_color = "blue"

/obj/machinery/atmospherics/pipe/manifold
	icon = 'icons/obj/atmospherics/pipe_manifold.dmi'
	icon_state = "manifold"
	baseicon = "manifold"
	name = "pipe manifold"
	desc = "A manifold composed of regular pipes"
	volume = 105
	dir = SOUTH
	initialize_directions = EAST|NORTH|WEST
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3
	level = 1
	layer = 2.4 //under wires with their 2.44

/obj/machinery/atmospherics/pipe/manifold/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pipe_dir()
	var/turf/T = loc
	level = T.intact ? 2 : 1
	initialize(1)
	if(!node1&&!node2&&!node3)
		usr << "<span class='warning'>There's nothing to connect this manifold to! A pipe segment must be connected to at least one other object!</span>"
		return 0
	update_icon() // Skipped in initialize()!
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	if (node2)
		node2.initialize()
		node2.build_network()
	if (node3)
		node3.initialize()
		node3.build_network()
	return 1


/obj/machinery/atmospherics/pipe/manifold/New()
	switch(dir)
		if(NORTH)
			initialize_directions = EAST|SOUTH|WEST
		if(SOUTH)
			initialize_directions = WEST|NORTH|EAST
		if(EAST)
			initialize_directions = SOUTH|WEST|NORTH
		if(WEST)
			initialize_directions = NORTH|EAST|SOUTH

	..()


/obj/machinery/atmospherics/pipe/manifold/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()


/obj/machinery/atmospherics/pipe/manifold/pipeline_expansion()
	return list(node1, node2, node3)


/obj/machinery/atmospherics/pipe/manifold/process()
	if(!parent)
		..()
	else
		. = PROCESS_KILL
	/*
	if(!node1)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if(!node2)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if(!node3)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if (nodealert)
		nodealert = 0
	*/


/obj/machinery/atmospherics/pipe/manifold/Destroy()
	if(node1)
		node1.disconnect(src)
	if(node2)
		node2.disconnect(src)
	if(node3)
		node3.disconnect(src)

	..()


/obj/machinery/atmospherics/pipe/manifold/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			returnToDPool(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			returnToDPool(parent)
		node2 = null

	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			returnToDPool(parent)
		node3 = null

	update_icon()

	..()


/obj/machinery/atmospherics/pipe/manifold/update_icon()
	alpha = invisibility ? 128 : 255
	color = available_colors[_color]
	overlays = 0
	if(node1&&node2&&node3)
		icon_state="manifold"
	else
		icon_state = "[baseicon]_ex"
		var/icon/con = new/icon(icon,"[baseicon]_con") //Since 4-ways are supposed to be directionless, they need an overlay instead it seems.

		if(node1)
			overlays += new/image(con,dir=get_dir(src, node1))
		if(node2)
			overlays += new/image(con,dir=get_dir(src, node2))
		if(node3)
			overlays += new/image(con,dir=get_dir(src, node3))

		if(!node1 && !node2 && !node3)
			qdel(src)

	return


/obj/machinery/atmospherics/pipe/manifold/initialize(var/skip_icon_update=0)
	var/connect_directions = (NORTH|SOUTH|EAST|WEST)&(~dir)

	findAllConnections(connect_directions)

	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
	if(!skip_icon_update)
		update_icon()

/obj/machinery/atmospherics/pipe/manifold/scrubbers
	name = "Scrubbers pipe"
	_color = "red"
	color=PIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/manifold/supply
	name = "Air supply pipe"
	_color = "blue"
	color=PIPE_COLOR_BLUE
/obj/machinery/atmospherics/pipe/manifold/supplymain
	name = "Main air supply pipe"
	_color = "purple"
	color=PIPE_COLOR_PURPLE
/obj/machinery/atmospherics/pipe/manifold/general
	name = "Gas pipe"
	_color = "gray"
	color=PIPE_COLOR_GREY
/obj/machinery/atmospherics/pipe/manifold/yellow
	name = "Air supply pipe"
	_color = "yellow"
	color=PIPE_COLOR_YELLOW
/obj/machinery/atmospherics/pipe/manifold/cyan
	name = "Air supply pipe"
	_color = "cyan"
	color=PIPE_COLOR_CYAN
/obj/machinery/atmospherics/pipe/manifold/filtering
	name = "Air filtering pipe"
	_color = "green"
	color=PIPE_COLOR_GREEN
/obj/machinery/atmospherics/pipe/manifold/insulated
	name = "Insulated pipe"
	//icon = 'icons/obj/atmospherics/red_pipe.dmi'
	icon = 'icons/obj/atmospherics/insulated.dmi'
	icon_state = "manifold"
	alert_pressure = 900*ONE_ATMOSPHERE
	_color = "red"
	color=IPIPE_COLOR_RED
	level = 2
	available_colors = list(
		"red"=IPIPE_COLOR_RED,
		"blue"=IPIPE_COLOR_BLUE
	)
/obj/machinery/atmospherics/pipe/manifold/scrubbers/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold/scrubbers/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold/supply/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold/supply/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold/supplymain/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold/supplymain/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold/general/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold/general/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold/insulated/visible
	level = 2
	color=IPIPE_COLOR_RED
	_color = "red"
/obj/machinery/atmospherics/pipe/manifold/insulated/visible/blue
	color=IPIPE_COLOR_BLUE
	_color = "blue"
/obj/machinery/atmospherics/pipe/manifold/insulated/hidden
	level = 1
	color=IPIPE_COLOR_RED
	alpha=128
	_color = "red"
/obj/machinery/atmospherics/pipe/manifold/insulated/hidden/blue
	color=IPIPE_COLOR_BLUE
	_color = "blue"
/obj/machinery/atmospherics/pipe/manifold/yellow/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold/yellow/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold/cyan/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold/cyan/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold/filtering/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold/filtering/hidden
	level = 1
	alpha=128

/obj/machinery/atmospherics/pipe/manifold4w
	icon = 'icons/obj/atmospherics/pipe_manifold.dmi'
	icon_state = "manifold4w"
	name = "4-way pipe manifold"
	desc = "A manifold composed of regular pipes"
	volume = 140
	dir = SOUTH
	initialize_directions = NORTH|SOUTH|EAST|WEST
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3
	var/obj/machinery/atmospherics/node4
	level = 1
	layer = 2.4 //under wires with their 2.44
	baseicon="manifold4w"

/obj/machinery/atmospherics/pipe/manifold4w/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pipe_dir()
	var/turf/T = loc
	level = T.intact ? 2 : 1
	initialize(1)
	if(!node1 && !node2 && !node3 && !node4)
		usr << "<span class='warning'>There's nothing to connect this manifold to! A pipe segment must be connected to at least one other object!</span>"
		return 0
	update_icon()
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	if (node2)
		node2.initialize()
		node2.build_network()
	if (node3)
		node3.initialize()
		node3.build_network()
	if (node4)
		node4.initialize()
		node4.build_network()
	return 1


/obj/machinery/atmospherics/pipe/manifold4w/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()


/obj/machinery/atmospherics/pipe/manifold4w/pipeline_expansion()
	return list(node1, node2, node3, node4)


/obj/machinery/atmospherics/pipe/manifold4w/process()
	if(!parent)
		..()
	else
		. = PROCESS_KILL
	/*
	if(!node1)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if(!node2)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if(!node3)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if (nodealert)
		nodealert = 0
	*/


/obj/machinery/atmospherics/pipe/manifold4w/Destroy()
	if(node1)
		node1.disconnect(src)
	if(node2)
		node2.disconnect(src)
	if(node3)
		node3.disconnect(src)
	if(node4)
		node4.disconnect(src)

	..()


/obj/machinery/atmospherics/pipe/manifold4w/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			returnToDPool(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			returnToDPool(parent)
		node2 = null

	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			returnToDPool(parent)
		node3 = null

	if(reference == node4)
		if(istype(node4, /obj/machinery/atmospherics/pipe))
			returnToDPool(parent)
		node4 = null

	update_icon()

	..()


/obj/machinery/atmospherics/pipe/manifold4w/update_icon()
	overlays=0
	alpha = invisibility ? 128 : 255
	color = available_colors[_color]
	if(node1&&node2&&node3&&node4)
		icon_state = "[baseicon]"
	else
		icon_state = "[baseicon]_ex"
		var/icon/con = new/icon(icon,"[baseicon]_con") //Since 4-ways are supposed to be directionless, they need an overlay instead it seems.

		if(node1)
			overlays += new/image(con,dir=1)
		if(node2)
			overlays += new/image(con,dir=2)
		if(node3)
			overlays += new/image(con,dir=4)
		if(node4)
			overlays += new/image(con,dir=8)

		if(!node1 && !node2 && !node3 && !node4)
			qdel(src)
	return


/obj/machinery/atmospherics/pipe/manifold4w/initialize(var/skip_update_icon=0)

	findAllConnections(initialize_directions)

	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
	if(!skip_update_icon)
		update_icon()

/obj/machinery/atmospherics/pipe/manifold4w/scrubbers
	name = "Scrubbers pipe"
	_color = "red"
	color=PIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/manifold4w/supply
	name = "Air supply pipe"
	_color = "blue"
	color=PIPE_COLOR_BLUE
/obj/machinery/atmospherics/pipe/manifold4w/supplymain
	name = "Main air supply pipe"
	_color = "purple"
	color=PIPE_COLOR_PURPLE
/obj/machinery/atmospherics/pipe/manifold4w/general
	name = "Air supply pipe"
	_color = "gray"
	color=PIPE_COLOR_GREY
/obj/machinery/atmospherics/pipe/manifold4w/yellow
	name = "Air supply pipe"
	_color = "yellow"
	color=PIPE_COLOR_YELLOW
/obj/machinery/atmospherics/pipe/manifold4w/filtering
	name = "Air filtering pipe"
	_color = "green"
	color=PIPE_COLOR_GREEN
/obj/machinery/atmospherics/pipe/manifold4w/insulated
	icon = 'icons/obj/atmospherics/insulated.dmi'
	name = "Insulated pipe"
	_color = "red"
	alert_pressure = 900*ONE_ATMOSPHERE
	color=IPIPE_COLOR_RED
	level = 2
	available_colors = list(
		"red"=IPIPE_COLOR_RED,
		"blue"=IPIPE_COLOR_BLUE
	)
/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold4w/supply/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold4w/supply/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold4w/supplymain/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold4w/supplymain/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold4w/general/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold4w/general/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold4w/filtering/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold4w/filtering/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold4w/yellow/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold4w/yellow/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold4w/insulated/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold4w/insulated/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold4w/insulated/hidden/blue
	color=IPIPE_COLOR_BLUE
	_color = "blue"
/obj/machinery/atmospherics/pipe/manifold4w/insulated/visible/blue
	color=IPIPE_COLOR_BLUE
	_color = "blue"


/obj/machinery/atmospherics/pipe/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/weapon/pipe_dispenser) || istype(W, /obj/item/device/pipe_painter))
		return // Coloring pipes.

	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/red))
		src._color = "red"
		src.color = PIPE_COLOR_RED
		user << "<span class='notice'>You paint the pipe red.</span>"
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/blue))
		src._color = "blue"
		src.color = PIPE_COLOR_BLUE
		user << "<span class='notice'>You paint the pipe blue.</span>"
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/green))
		src._color = "green"
		src.color = PIPE_COLOR_GREEN
		user << "<span class='notice'>You paint the pipe green.</span>"
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/yellow))
		src._color = "yellow"
		src.color = PIPE_COLOR_YELLOW
		user << "<span class='notice'>You paint the pipe yellow.</span>"
		update_icon()
		return 1
	return ..()