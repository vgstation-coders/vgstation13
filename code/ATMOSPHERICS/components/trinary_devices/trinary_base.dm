/obj/machinery/atmospherics/trinary
	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST
	use_power = MACHINE_POWER_USE_IDLE
	can_be_coloured = 0

	var/datum/gas_mixture/air1
	var/datum/gas_mixture/air2
	var/datum/gas_mixture/air3

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3

	var/datum/pipe_network/network1
	var/datum/pipe_network/network2
	var/datum/pipe_network/network3

	var/activity_log = ""

/obj/machinery/atmospherics/trinary/update_planes_and_layers()
	if (level == LEVEL_BELOW_FLOOR)
		layer = TRINARY_PIPE_LAYER
	else
		layer = EXPOSED_BINARY_PIPE_LAYER

	layer = PIPING_LAYER(layer, piping_layer)

/obj/machinery/atmospherics/trinary/update_icon(var/adjacent_procd)
	var/node_list = list(node1,node2,node3)
	..(adjacent_procd,node_list)

/obj/machinery/atmospherics/trinary/New()
	..()
	update_dir()
	air1 = new
	air2 = new
	air3 = new
	air1.volume = starting_volume
	air2.volume = starting_volume
	air3.volume = starting_volume

/obj/machinery/atmospherics/trinary/update_dir()
	switch(dir)
		if(NORTH)
			initialize_directions = SOUTH|NORTH|EAST
		if(SOUTH)
			initialize_directions = NORTH|SOUTH|WEST
		if(EAST)
			initialize_directions = WEST|EAST|SOUTH
		if(WEST)
			initialize_directions = EAST|WEST|NORTH
	..()

/obj/machinery/atmospherics/trinary/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	if(!(pipe.dir in list(NORTH, SOUTH, EAST, WEST)) && src.mirror) //because the dir isn't in the right set, we want to make the mirror kind
		var/obj/machinery/atmospherics/trinary/mirrored_pipe = new mirror(src.loc)
		pipe.dir = turn(pipe.dir, -45)
		qdel(src)
		mirrored_pipe.setPipingLayer(pipe.piping_layer)
		return mirrored_pipe.buildFrom(usr, pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pipe_dir()
	if (pipe.pipename)
		name = pipe.pipename
	var/turf/T = loc
	level = T.intact ? LEVEL_ABOVE_FLOOR : LEVEL_BELOW_FLOOR
	update_planes_and_layers()
	initialize()
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


/obj/machinery/atmospherics/trinary/get_node(node_id)
	switch(node_id)
		if(1)
			return node1
		if(2)
			return node2
		if(3)
			return node3
		else
			CRASH("Invalid node_id!")

/obj/machinery/atmospherics/trinary/set_node(node_id, value)
	switch(node_id)
		if(1)
			node1 = value
		if(2)
			node2 = value
		if(3)
			node3 = value
		else
			CRASH("Invalid node_id!")


// Housekeeping and pipe network stuff below
/obj/machinery/atmospherics/trinary/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node1)
		network1 = new_network

	else if(reference == node2)
		network2 = new_network

	else if (reference == node3)
		network3 = new_network

	if(new_network.normal_members.Find(src))
		return 0

	new_network.normal_members += src

	return null

/obj/machinery/atmospherics/trinary/Destroy()
	if(node1)
		node1.disconnect(src)
		if(network1)
			qdel(network1)
	if(node2)
		node2.disconnect(src)
		if(network2)
			qdel(network2)
	if(node3)
		node3.disconnect(src)
		if(network3)
			qdel(network3)

	node1 = null
	node2 = null
	node3 = null

	..()

/obj/machinery/atmospherics/trinary/initialize()
	if(node1 && node2 && node3)
		return

	//mirrored pipes face the same way and have their nodes in the same place
	//The 1 and 3 nodes are reversed, however.
	//   1           3
	// 2-- becomes 2-- facing south, for example
	//   3           1
	if(!(pipe_flags & IS_MIRROR))
		node1 = findConnecting(turn(dir, -180))
		node2 = findConnecting(turn(dir, -90))
		node3 = findConnecting(dir)
	else
		node1 = findConnecting(dir)
		node2 = findConnecting(turn(dir, -90))
		node3 = findConnecting(turn(dir, -180))


	update_icon()
	add_self_to_holomap()

/obj/machinery/atmospherics/trinary/build_network()
	if(!network1 && node1)
		network1 = new /datum/pipe_network
		network1.normal_members += src
		network1.build_network(node1, src)

	if(!network2 && node2)
		network2 = new /datum/pipe_network
		network2.normal_members += src
		network2.build_network(node2, src)

	if(!network3 && node3)
		network3 = new /datum/pipe_network
		network3.normal_members += src
		network3.build_network(node3, src)


/obj/machinery/atmospherics/trinary/return_network(obj/machinery/atmospherics/reference)
	build_network()

	if(reference==node1)
		return network1

	if(reference==node2)
		return network2

	if(reference==node3)
		return network3

	return null

/obj/machinery/atmospherics/trinary/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network1 == old_network)
		network1 = new_network
	if(network2 == old_network)
		network2 = new_network
	if(network3 == old_network)
		network3 = new_network

	return 1

/obj/machinery/atmospherics/trinary/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	if(network1 == reference)
		results += air1
	if(network2 == reference)
		results += air2
	if(network3 == reference)
		results += air3

	return results

/obj/machinery/atmospherics/trinary/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node1)
		if(network1)
			qdel(network1)
		node1 = null

	else if(reference==node2)
		if(network2)
			qdel(network2)
		node2 = null

	else if(reference==node3)
		if(network3)
			qdel(network3)
		node3 = null

	return ..()

/obj/machinery/atmospherics/trinary/unassign_network(datum/pipe_network/reference)
	if(network1 == reference)
		network1 = null
	if(network2 == reference)
		network2 = null
	if(network3 == reference)
		network3 = null
