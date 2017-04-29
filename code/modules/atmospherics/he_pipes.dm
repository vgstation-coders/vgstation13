#define NO_GAS 0.01
#define SOME_GAS 1

/obj/machinery/atmospherics/pipe/simple/heat_exchanging
	icon = 'icons/obj/pipes/heat.dmi'
	icon_state = "intact"
	level = 2

	minimum_temperature_difference = 20
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT

	var/const/RADIATION_CAPACITY = 32000 // Radiation isn't particularly effective (TODO BALANCE)
	                                     //  Plate value is 30000, increased it a bit because of additional surface area. - N3X
	var/const/ENERGY_MULT        = 6.4   // Not sure what this is, keeping it the same as plates.

	burst_type = /obj/machinery/atmospherics/unary/vent/burstpipe/heat_exchanging

	can_be_coloured = 0

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/getNodeType(var/node_id)
	return PIPE_TYPE_HE

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/update_icon(var/adjacent_procd)
	var/node_list = list(node1,node2)
	if(!node1 && !node2)
		qdel(src)
	if(!adjacent_procd)
		for(var/obj/machinery/atmospherics/node in node_list)
			if(node.update_icon_ready && !(istype(node,/obj/machinery/atmospherics/pipe/simple)))
				node.update_icon(1)

	// BubbleWrap
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/New()
	..()
	initialize_directions_he = initialize_directions	// The auto-detection from /pipe is good enough for a simple HE pipe
	// BubbleWrap END

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = 0
	initialize_directions_he = pipe.get_pipe_dir()
	//var/turf/T = loc
	//level = T.intact ? 2 : 1
	if(!initialize(1))
		to_chat(usr, "Unable to build pipe here;  It must be connected to a machine, or another pipe that has a connection.")
		return 0
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	if (node2)
		node2.initialize()
		node2.build_network()
	return 1

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/initialize(var/suppress_icon_check=0)
	normalize_dir()

	findAllConnections(initialize_directions_he)

	if(!suppress_icon_check)
		update_icon()
	return node1 || node2

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/process()
	if(!parent)
		. = ..()

	// Get gas from pipenet
	var/datum/gas_mixture/internal = return_air()
	var/remove_ratio = volume/internal.volume
	var/datum/gas_mixture/internal_removed = internal.remove_ratio(remove_ratio)

	//Get processable air sample and thermal info from environment
	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_moles = environment.total_moles()
	var/transfer_moles = 0.25 * environment_moles
	var/datum/gas_mixture/external_removed = environment.remove(transfer_moles)

	// No environmental gas?  We radiate it, then.
	if(!external_removed)
		if(internal_removed)
			internal.merge(internal_removed)
		return radiate()

	// Not enough gas in the air around us to care about.  Radiate. Less gas than airless tiles start with.
	if(environment_moles < NO_GAS)
		if(internal_removed)
			internal.merge(internal_removed)
		environment.merge(external_removed)
		return radiate()
	// A tiny bit of air so this isn't really space, but its not worth activating exchange procs
	else if(environment_moles < SOME_GAS)
		return 0

	// No internal gas.  Screw this, we're out.
	if(!internal_removed)
		environment.merge(external_removed)
		return

	//Get same info from connected gas
	var/combined_heat_capacity = internal_removed.heat_capacity() + external_removed.heat_capacity()
	var/combined_energy = internal_removed.temperature * internal_removed.heat_capacity() + external_removed.heat_capacity() * external_removed.temperature

	if(!combined_heat_capacity)
		combined_heat_capacity = 1
	var/final_temperature = combined_energy / combined_heat_capacity

	external_removed.temperature = final_temperature
	environment.merge(external_removed)

	internal_removed.temperature = final_temperature
	internal.merge(internal_removed)


	if(parent && parent.network)
		parent.network.update = 1
	return 1

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/proc/radiate()
	var/datum/gas_mixture/internal = return_air()
	var/remove_ratio = volume/internal.volume
	var/datum/gas_mixture/internal_removed = internal.remove_ratio(remove_ratio)

	if (!internal_removed)
		return

	var/combined_heat_capacity = internal_removed.heat_capacity() + RADIATION_CAPACITY
	var/combined_energy = internal_removed.temperature * internal_removed.heat_capacity() + (RADIATION_CAPACITY * ENERGY_MULT)

	var/final_temperature = combined_energy / combined_heat_capacity

	internal_removed.temperature = final_temperature
	internal.merge(internal_removed)

	if(parent && parent.network)
		parent.network.update = 1

	return 1

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/hidden
	level=1
	icon_state="intact-f"

/////////////////////////////////
// JUNCTION
/////////////////////////////////
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction
	icon = 'icons/obj/pipes/junction.dmi'
	icon_state = "intact"
	level = 2
	minimum_temperature_difference = 300
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

	// BubbleWrap
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/New()
	.. ()
	switch ( dir )
		if ( SOUTH )
			initialize_directions = NORTH
			initialize_directions_he = SOUTH
		if ( NORTH )
			initialize_directions = SOUTH
			initialize_directions_he = NORTH
		if ( EAST )
			initialize_directions = WEST
			initialize_directions_he = EAST
		if ( WEST )
			initialize_directions = EAST
			initialize_directions_he = WEST
	// BubbleWrap END

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pdir()
	initialize_directions_he = pipe.get_hdir()
	if (!initialize(1))
		to_chat(usr, "There's nothing to connect this junction to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)")
		return 0
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	if (node2)
		node2.initialize()
		node2.build_network()
	return 1

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/update_icon()
	if(node1&&node2)
		icon_state = "intact[invisibility ? "-f" : "" ]"
	else
		var/have_node1 = node1?1:0
		var/have_node2 = node2?1:0
		icon_state = "exposed[have_node1][have_node2]"

	if(!node1&&!node2)
		qdel(src)

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/initialize(var/suppress_icon_check=0)
	node1 = findConnecting(initialize_directions)
	node2 = findConnectingHE(initialize_directions_he)

	if(!suppress_icon_check)
		update_icon()

	return node1 || node2

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/hidden
	level=1
	icon_state="intact-f"
