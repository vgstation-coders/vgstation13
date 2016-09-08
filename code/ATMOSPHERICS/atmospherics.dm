/*
Quick overview:

Pipes combine to form pipelines
Pipelines and other atmospheric objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network

*/

#define PIPE_TYPE_STANDARD 0
#define PIPE_TYPE_HE       1

//Pipe bitflags
#define IS_MIRROR	1
#define ALL_LAYER	2 //if the pipe can connect at any layer, instead of just the specific one

/obj/machinery/atmospherics
	anchored = 1
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = ENVIRON
	var/nodealert = 0
	var/update_icon_ready = 0 // don't update icons before they're ready or if they don't want to be
	var/starting_volume = 200
	// Which directions can we connect with?
	var/initialize_directions = 0
	var/can_be_coloured = 0
	var/image/centre_overlay = null
	// Investigation logs
	var/log
	var/global/list/node_con = list()
	var/global/list/node_ex = list()
	var/pipe_flags = 0
	var/obj/machinery/atmospherics/mirror //not actually an object reference, but a type. The reflection of the current pipe
	var/default_colour = null
	var/image/pipe_image
	plane = ABOVE_TURF_PLANE
	layer = PIPE_LAYER
	var/piping_layer = PIPING_LAYER_DEFAULT //used in multi-pipe-on-tile - pipes only connect if they're on the same pipe layer

	internal_gravity = 1 // Ventcrawlers can move in pipes without gravity since they have traction.
	holomap = TRUE

	// If a pipe node isn't connected, should it be pixel shifted to fit the object?
	var/ex_node_offset = 0

/obj/machinery/atmospherics/New()
	..()
	machines.Remove(src)
	atmos_machines |= src
	update_planes_and_layers()

/obj/machinery/atmospherics/Destroy()
	for(var/mob/living/M in src) //ventcrawling is serious business
		M.remove_ventcrawl()
		M.forceMove(src.loc)
	if(pipe_image)
		for(var/mob/living/M in player_list)
			if(M.client)
				M.client.images -= pipe_image
				M.pipes_shown -= pipe_image
		pipe_image = null
	atmos_machines -= src
	centre_overlay = null
	..()

/obj/machinery/atmospherics/ex_act(severity)
	for(var/atom/movable/A in src) //ventcrawling is serious business
		A.ex_act(severity)
	..()

/obj/machinery/atmospherics/proc/update_planes_and_layers()
	return

/obj/machinery/atmospherics/proc/icon_node_con(var/dir)
	var/static/list/node_con = list(
		"[NORTH]" = image('icons/obj/pipes.dmi', "pipe_intact", dir = NORTH),
		"[SOUTH]" = image('icons/obj/pipes.dmi', "pipe_intact", dir = SOUTH),
		"[EAST]"  = image('icons/obj/pipes.dmi', "pipe_intact", dir = EAST),
		"[WEST]"  = image('icons/obj/pipes.dmi', "pipe_intact", dir = WEST)
	)

	return node_con["[dir]"]

/obj/machinery/atmospherics/proc/icon_node_ex(var/dir)
	var/static/list/node_ex = list(
		"[NORTH]" = image('icons/obj/pipes.dmi', "pipe_exposed", dir = NORTH),
		"[SOUTH]" = image('icons/obj/pipes.dmi', "pipe_exposed", dir = SOUTH),
		"[EAST]"  = image('icons/obj/pipes.dmi', "pipe_exposed", dir = EAST),
		"[WEST]"  = image('icons/obj/pipes.dmi', "pipe_exposed", dir = WEST)
	)

	return node_ex["[dir]"]

/obj/machinery/atmospherics/proc/icon_directions()
	. = list()
	for(var/direction in cardinal)
		if(direction & initialize_directions)
			. += direction

/obj/machinery/atmospherics/proc/node_color_for(var/obj/machinery/atmospherics/other)
	if (default_colour && other.default_colour && (other.default_colour != default_colour)) // if both pipes have special colours - average them
		var/list/centre_colour = GetHexColors(default_colour)
		var/list/other_colour = GetHexColors(other.default_colour)
		var/list/average_colour = list(((centre_colour[1]+other_colour[1])/2),((centre_colour[2]+other_colour[2])/2),((centre_colour[3]+other_colour[3])/2))
		return rgb(average_colour[1],average_colour[2],average_colour[3])
	if (color)
		return null
	if (other.color)
		return other.color

	if (default_colour)
		return default_colour

	if (other.default_colour && other.default_colour != PIPE_COLOR_GREY)
		return other.default_colour

	return PIPE_COLOR_GREY

/obj/machinery/atmospherics/proc/node_layer()
	return level == LEVEL_BELOW_FLOOR ? PIPE_LAYER : EXPOSED_PIPE_LAYER

/obj/machinery/atmospherics/proc/node_plane()
	return level == LEVEL_BELOW_FLOOR ? ABOVE_PLATING_PLANE : ABOVE_TURF_PLANE

/obj/machinery/atmospherics/update_icon(var/adjacent_procd,node_list)
	update_planes_and_layers()
	if(!can_be_coloured && color)
		default_colour = color
		color = null
	else if(can_be_coloured && default_colour)
		color = default_colour
		default_colour = null
	alpha = invisibility ? 128 : 255
	if (!update_icon_ready)
		update_icon_ready = 1
	else
		underlays.Cut()
	var/list/missing_nodes = icon_directions()
	for (var/obj/machinery/atmospherics/connected_node in node_list)
		var/con_dir = get_dir(src, connected_node)
		missing_nodes -= con_dir // finds all the directions that aren't pointed to by a node
		var/image/nodecon = icon_node_con(con_dir)
		if(nodecon)
			nodecon.color = node_color_for(connected_node)
			nodecon.plane = node_plane()
			nodecon.layer = node_layer()
			underlays += nodecon
		if (!adjacent_procd && connected_node.update_icon_ready && !(istype(connected_node,/obj/machinery/atmospherics/pipe/simple)))
			connected_node.update_icon(1)
	for (var/missing_dir in missing_nodes)
		var/image/nodeex = icon_node_ex(missing_dir)
		if(!color)
			nodeex.color = default_colour ? default_colour : PIPE_COLOR_GREY
		else
			nodeex.color = null
		nodeex.plane = node_plane()
		nodeex.layer = node_layer()
		switch (missing_dir)
			if (NORTH)
				nodeex.pixel_y = ex_node_offset

			if (SOUTH)
				nodeex.pixel_y = -ex_node_offset

			if (EAST)
				nodeex.pixel_x = ex_node_offset

			if (WEST)
				nodeex.pixel_x = -ex_node_offset

		underlays += nodeex


/obj/machinery/atmospherics/proc/setPipingLayer(new_layer = PIPING_LAYER_DEFAULT)
	piping_layer = new_layer
	pixel_x = (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
	pixel_y = (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y
	update_planes_and_layers()

// Find a connecting /obj/machinery/atmospherics in specified direction.
/obj/machinery/atmospherics/proc/findConnecting(var/direction, var/given_layer = src.piping_layer)
	for(var/obj/machinery/atmospherics/target in get_step(src,direction))
		if(target.initialize_directions & get_dir(target,src))
			if(isConnectable(target, direction, given_layer) && target.isConnectable(src, turn(direction, 180), given_layer))
				return target

// Ditto, but for heat-exchanging pipes.
/obj/machinery/atmospherics/proc/findConnectingHE(var/direction, var/given_layer = src.piping_layer)
	for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,direction))
		if(target.initialize_directions_he & get_dir(target,src))
			if(isConnectable(target, direction, given_layer) && target.isConnectable(src, turn(direction, 180), given_layer))
				return target

//Called when checking connectability in findConnecting()
//This is checked for both pipes in establishing a connection - the base behaviour will work fine nearly every time
/obj/machinery/atmospherics/proc/isConnectable(var/obj/machinery/atmospherics/target, var/direction, var/given_layer)
	return (target.piping_layer == given_layer || target.pipe_flags & ALL_LAYER)

/obj/machinery/atmospherics/proc/getNodeType(var/node_id)
	return PIPE_TYPE_STANDARD

// A bit more flexible.
// @param connect_dirs integer Directions at which we should check for connections.
/obj/machinery/atmospherics/proc/findAllConnections(var/connect_dirs)
	var/node_id=0
	for(var/direction in cardinal)
		if(connect_dirs & direction)
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
			if(!found)
				continue
			var/node_var="node[node_id]"
			if(!(node_var in vars))
				testing("[node_var] not in vars.")
				return
			if(!vars[node_var])
				vars[node_var] = found

// Wait..  What the fuck?
// I asked /tg/ and bay and they have no idea why this is here, so into the trash it goes. - N3X
// Re-enabled for debugging.
/obj/machinery/atmospherics/process()

	if(timestopped)
		return 0 //under effects of time magick
	. = build_network()
	//testing("[src] called parent process to build_network()")

/obj/machinery/atmospherics/proc/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	// Check to see if should be added to network. Add self if so and adjust variables appropriately.
	// Note don't forget to have neighbors look as well!

	return null

/obj/machinery/atmospherics/proc/build_network()
	// Called to build a network from this node
	return null

/obj/machinery/atmospherics/proc/return_network(obj/machinery/atmospherics/reference)
	// Returns pipe_network associated with connection to reference
	// Notes: should create network if necessary
	// Should never return null

	return null

/obj/machinery/atmospherics/proc/unassign_network(datum/pipe_network/reference)

/obj/machinery/atmospherics/proc/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	// Used when two pipe_networks are combining

/obj/machinery/atmospherics/proc/return_network_air(datum/network/reference)
	// Return a list of gas_mixture(s) in the object
	//		associated with reference pipe_network for use in rebuilding the networks gases list
	// Is permitted to return null

/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)
	update_icon()

/obj/machinery/atmospherics/proc/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	error("[src] does not define a buildFrom!")
	return FALSE

/obj/machinery/atmospherics/cultify()
	if(src.invisibility != INVISIBILITY_MAXIMUM)
		src.invisibility = INVISIBILITY_MAXIMUM


/obj/machinery/atmospherics/attackby(var/obj/item/W, mob/user)
	if(istype(W, /obj/item/pipe)) //lets you autodrop
		var/obj/item/pipe/pipe = W
		if(user.drop_item(pipe))
			pipe.setPipingLayer(src.piping_layer) //align it with us
			return 1
	if (!iswrench(W))
		return ..()
	if(src.machine_flags & WRENCHMOVE)
		return ..()
	var/turf/T = src.loc
	if (level==LEVEL_BELOW_FLOOR && isturf(T) && T.intact)
		to_chat(user, "<span class='warning'>You must remove the plating first.</span>")
		return 1
	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	add_fingerprint(user)
	if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
		if(istype(W, /obj/item/weapon/wrench/socket) && istype(src, /obj/machinery/atmospherics/pipe))
			to_chat(user, "<span class='warning'>You begin to open the pressure release valve on the pipe...</span>")
			if(do_after(user, src, 50))
				if(!loc)
					return
				playsound(get_turf(src), 'sound/machines/hiss.ogg', 50, 1)
				user.visible_message("[user] vents \the [src].",
									"You have vented \the [src].",
									"You hear a ratchet.")
				var/datum/gas_mixture/internal_removed = int_air.remove(int_air.total_moles()*starting_volume/int_air.volume)
				env_air.merge(internal_removed)
		else
			to_chat(user, "<span class='warning'>You cannot unwrench this [src], it's too exerted due to internal pressure.</span>")
			return 1
	playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
	if (do_after(user, src, 40))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			"<span class='notice'>You have unfastened \the [src].</span>", \
			"You hear a ratchet.")
		getFromPool(/obj/item/pipe, loc, null, null, src)
		investigation_log(I_ATMOS,"was removed by [user]/([user.ckey]) at [formatJumpTo(loc)].")
		//P.New(loc, make_from=src) //new /obj/item/pipe(loc, make_from=src)
		qdel(src)
	return 1

#define VENT_SOUND_DELAY 30

/obj/machinery/atmospherics/Entered(atom/movable/Obj)
	if(istype(Obj, /mob/living))
		var/mob/living/L = Obj
		L.ventcrawl_layer = src.piping_layer

/obj/machinery/atmospherics/relaymove(mob/living/user, direction)
	if(!(direction & initialize_directions)) //can't go in a way we aren't connecting to
		return

	var/obj/machinery/atmospherics/target_move = findConnecting(direction, user.ventcrawl_layer)
	if(target_move)
		if(is_type_in_list(target_move, ventcrawl_machinery) && target_move.can_crawl_through())
			user.remove_ventcrawl()
			user.forceMove(target_move.loc) //handles entering and so on
			user.visible_message("You hear something squeezing through the ducts.", "You climb out the ventilation system.")
		else if(target_move.can_crawl_through())
			if(target_move.return_network(target_move) != return_network(src))
				user.remove_ventcrawl()
				user.add_ventcrawl(target_move)
			user.forceMove(target_move)
			user.client.eye = target_move //if we don't do this, Byond only updates the eye every tick - required for smooth movement
			if(world.time - user.last_played_vent > VENT_SOUND_DELAY)
				user.last_played_vent = world.time
				playsound(src, 'sound/machines/ventcrawl.ogg', 50, 1, -3)
	else
		if((direction & initialize_directions) || is_type_in_list(src, ventcrawl_machinery) && src.can_crawl_through()) //if we move in a way the pipe can connect, but doesn't - or we're in a vent
			user.remove_ventcrawl()
			user.forceMove(src.loc)
			user.visible_message("You hear something squeezing through the pipes.", "You climb out the ventilation system.")
	user.canmove = 0
	spawn(1)
		user.canmove = 1

/obj/machinery/atmospherics/proc/can_crawl_through()
	return 1

/obj/machinery/atmospherics/is_airtight() //Technically, smoke would be able to pop up from a vent, but enabling ventcrawling mobs to do that still doesn't sound like a good idea
	return 1

// Tiny helper to see if the object is "exposed".
// Basically whether it's partially covered up by a floor tile or not.
/obj/machinery/atmospherics/proc/exposed()
	if (level == LEVEL_ABOVE_FLOOR || !isturf(loc))
		return TRUE

	var/turf/T = loc
	return !T.intact
