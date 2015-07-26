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

	var/starting_volume = 200
	// Which directions can we connect with?
	var/initialize_directions = 0

	// Pipe painter color setting.
	var/_color

	var/list/available_colors

	// Investigation logs
	var/log

	var/pipe_flags = 0
	var/obj/machinery/atmospherics/mirror //not actually an object reference, but a type. The reflection of the current pipe

	var/image/pipe_image

	var/piping_layer = PIPING_LAYER_DEFAULT //used in multi-pipe-on-tile - pipes only connect if they're on the same pipe layer

/obj/machinery/atmospherics/New()
	..()
	machines.Remove(src)
	atmos_machines |= src

/obj/machinery/atmospherics/Destroy()
	for(var/mob/living/M in src) //ventcrawling is serious business
		M.remove_ventcrawl()
		M.forceMove(src.loc)
	if(pipe_image)
		del(pipe_image) //we have to del it, or it might keep a ref somewhere else
	atmos_machines -= src
	..()

/obj/machinery/atmospherics/proc/setPipingLayer(new_layer = PIPING_LAYER_DEFAULT)
	piping_layer = new_layer
	pixel_x = (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
	pixel_y = (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y
	layer = initial(layer) + ((piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE)

// Find a connecting /obj/machinery/atmospherics in specified direction.
/obj/machinery/atmospherics/proc/findConnecting(var/direction, var/given_layer = src.piping_layer)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/atmospherics/proc/findConnecting() called tick#: [world.time]")
	for(var/obj/machinery/atmospherics/target in get_step(src,direction))
		if(target.initialize_directions & get_dir(target,src))
			if(isConnectable(target, direction, given_layer) && target.isConnectable(src, turn(direction, 180), given_layer))
				return target

// Ditto, but for heat-exchanging pipes.
/obj/machinery/atmospherics/proc/findConnectingHE(var/direction, var/given_layer = src.piping_layer)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/atmospherics/proc/findConnectingHE() called tick#: [world.time]")
	for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,direction))
		if(target.initialize_directions_he & get_dir(target,src))
			if(isConnectable(target, direction, given_layer) && target.isConnectable(src, turn(direction, 180), given_layer))
				return target

//Called when checking connectability in findConnecting()
//This is checked for both pipes in establishing a connection - the base behaviour will work fine nearly every time
/obj/machinery/atmospherics/proc/isConnectable(var/obj/machinery/atmospherics/target, var/direction, var/given_layer)
	return (target.piping_layer == given_layer || target.pipe_flags & ALL_LAYER)

/obj/machinery/atmospherics/proc/getNodeType(var/node_id)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/atmospherics/proc/getNodeType() called tick#: [world.time]")
	return PIPE_TYPE_STANDARD

// A bit more flexible.
// @param connect_dirs integer Directions at which we should check for connections.
/obj/machinery/atmospherics/proc/findAllConnections(var/connect_dirs)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/atmospherics/proc/findAllConnections() called tick#: [world.time]")
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
			if(!found) continue
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
	. = build_network()
	//testing("[src] called parent process to build_network()")

/obj/machinery/atmospherics/proc/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/atmospherics/proc/network_expand() called tick#: [world.time]")
	// Check to see if should be added to network. Add self if so and adjust variables appropriately.
	// Note don't forget to have neighbors look as well!

	return null

/obj/machinery/atmospherics/proc/build_network()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/atmospherics/proc/build_network() called tick#: [world.time]")
	// Called to build a network from this node
	return null

/obj/machinery/atmospherics/proc/return_network(obj/machinery/atmospherics/reference)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/atmospherics/proc/return_network() called tick#: [world.time]")
	// Returns pipe_network associated with connection to reference
	// Notes: should create network if necessary
	// Should never return null

	return null

/obj/machinery/atmospherics/proc/unassign_network(datum/pipe_network/reference)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/atmospherics/proc/unassign_network() called tick#: [world.time]")

/obj/machinery/atmospherics/proc/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/atmospherics/proc/reassign_network() called tick#: [world.time]")
	// Used when two pipe_networks are combining

/obj/machinery/atmospherics/proc/return_network_air(datum/network/reference)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/atmospherics/proc/return_network_air() called tick#: [world.time]")
	// Return a list of gas_mixture(s) in the object
	//		associated with reference pipe_network for use in rebuilding the networks gases list
	// Is permitted to return null

/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/atmospherics/proc/disconnect() called tick#: [world.time]")

/obj/machinery/atmospherics/update_icon()
	return null

/obj/machinery/atmospherics/proc/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/atmospherics/proc/buildFrom() called tick#: [world.time]")
	error("[src] does not define a buildFrom!")
	return FALSE

/obj/machinery/atmospherics/cultify()
	if(src.invisibility != INVISIBILITY_MAXIMUM)
		src.invisibility = INVISIBILITY_MAXIMUM


/obj/machinery/atmospherics/attackby(var/obj/item/W, mob/user)
	if(istype(W, /obj/item/pipe)) //lets you autodrop
		var/obj/item/pipe/pipe = W
		user.drop_item(pipe)
		pipe.setPipingLayer(src.piping_layer) //align it with us
		return 1
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if(src.machine_flags & WRENCHMOVE)
		return ..()
	var/turf/T = src.loc
	if (level==1 && isturf(T) && T.intact)
		user << "<span class='warning'>You must remove the plating first.</span>"
		return 1
	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	add_fingerprint(user)
	if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
		if(istype(W, /obj/item/weapon/wrench/socket) && istype(src, /obj/machinery/atmospherics/pipe))
			user << "<span class='warning'>You begin to open the pressure release valve on the pipe...</span>"
			if(do_after(user, src, 50))
				if(!loc) return
				playsound(get_turf(src), 'sound/machines/hiss.ogg', 50, 1)
				user.visible_message("[user] vents \the [src].",
									"You have vented \the [src].",
									"You hear a ratchet.")
				var/obj/machinery/atmospherics/pipe/P = src
				var/datum/gas_mixture/transit = new
				transit.add(int_air)
				var/datum/pipeline/pipe_parent = P.parent
				if(pipe_parent)
					transit.divide(pipe_parent.members.len) //we get the total pressure over the number of pipes to find gas per pipe
					env_air.add(transit) //put it in the air
				del(transit) //remove the carrier
		else
			user << "<span class='warning'>You cannot unwrench this [src], it too exerted due to internal pressure.</span>"
			return 1
	playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
	user << "<span class='notice'>You begin to unfasten \the [src]...</span>"
	if (do_after(user, src, 40))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			"<span class='notice'>You have unfastened \the [src].</span>", \
			"You hear a ratchet.")
		getFromPool(/obj/item/pipe, loc, null, null, src)
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
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/atmospherics/proc/can_crawl_through() called tick#: [world.time]")
	return 1
