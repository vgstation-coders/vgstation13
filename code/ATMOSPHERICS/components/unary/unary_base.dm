/obj/machinery/atmospherics/unary
	dir = SOUTH
	initialize_directions = SOUTH
	layer = UNARY_PIPE_LAYER
	can_be_coloured = 0
	var/datum/gas_mixture/air_contents
	var/obj/machinery/atmospherics/node1
	var/datum/pipe_network/network
	var/frequency = -1

/obj/machinery/atmospherics/unary/New()
	..()
	update_dir()
	air_contents = new
	air_contents.temperature = T0C
	air_contents.volume = starting_volume

/obj/machinery/atmospherics/unary/update_dir()
	initialize_directions = dir

/obj/machinery/atmospherics/unary/get_node(node_id)
	switch(node_id)
		if(1)
			return node1
		else
			CRASH("Invalid node_id!")

/obj/machinery/atmospherics/unary/set_node(node_id, value)
	switch(node_id)
		if(1)
			node1 = value
		else
			CRASH("Invalid node_id!")


/obj/machinery/atmospherics/unary/update_planes_and_layers()
	if (level == LEVEL_BELOW_FLOOR)
		layer = UNARY_PIPE_LAYER
	else
		layer = EXPOSED_UNARY_PIPE_LAYER

	layer = PIPING_LAYER(layer, piping_layer)

/obj/machinery/atmospherics/unary/update_icon(var/adjacent_procd,node_list)
	node_list = list(node1)
	..(adjacent_procd,node_list)
	
/obj/machinery/atmospherics/unary/proc/set_frequency(new_frequency)

/obj/machinery/atmospherics/unary/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
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
	if(pipe.frequency)
		set_frequency(pipe.frequency)
	if(pipe.id_tag)
		id_tag = pipe.id_tag
	return 1

//this is used when a machine_flags = WRENCHMOVE machine gets anchored down
//we want to check that it doesn't form any connections where there is already a connection
/obj/machinery/atmospherics/unary/wrenchAnchor(var/mob/user, var/obj/item/I)
	//this has to be first because ..() already starts the anchoring
	if(!anchored)
		for(var/obj/machinery/atmospherics/M in src.loc)
			if(M == src || M.piping_layer != src.piping_layer && !(M.pipe_flags & ALL_LAYER))
				continue
			if(M.has_initialize_direction(dir, PIPE_TYPE_STANDARD))
				to_chat(user, "<span class='warning'>There is already a pipe connection in that direction.</span>")
				return FALSE
	. = ..()

// Housekeeping and pipe network stuff below
/obj/machinery/atmospherics/unary/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node1)
		network = new_network
	if(new_network.normal_members.Find(src))
		return 0
	new_network.normal_members += src
	return null

/obj/machinery/atmospherics/unary/Destroy()
	if(node1)
		node1.disconnect(src)
		if(network)
			qdel(network)
	node1 = null
	..()

/obj/machinery/atmospherics/unary/initialize()
	if(node1)
		return
	findAllConnections(initialize_directions)
	update_icon()
	add_self_to_holomap()

/obj/machinery/atmospherics/unary/build_network()
	if(!network && node1)
		network = new /datum/pipe_network
		network.normal_members += src
		network.build_network(node1, src)


/obj/machinery/atmospherics/unary/return_network(obj/machinery/atmospherics/reference)
	build_network()
	if(reference == node1 || reference == src)
		return network
	return null

/obj/machinery/atmospherics/unary/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network == old_network)
		network = new_network
	return 1

/obj/machinery/atmospherics/unary/return_network_air(datum/pipe_network/reference)
	var/list/results = list()
	if(network == reference)
		results += air_contents
	return results

/obj/machinery/atmospherics/unary/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node1)
		if(network)
			qdel(network)
		node1 = null
	return ..()

/obj/machinery/atmospherics/unary/unassign_network(datum/pipe_network/reference)
	if(network == reference)
		network = null
