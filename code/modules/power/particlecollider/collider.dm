//all this shit with parent networks is there incase processing the particles normally becomes too expensive
//had a plan to simplify the network and simulate the particles but i'm not doing that yet
/datum/particle_collider
	var/list/connected_sections = list()
	
/datum/particle_collider/proc/rebuild_entire_network()
	for (var/obj/machinery/power/collider/C in connected_sections)
		C.parent_collider = new /datum/particle_collider
		C.parent_collider.connected_sections += C
	for (var/obj/machinery/power/collider/C in connected_sections)
		C.connect_to_neighbors()
	qdel(src)
	
/proc/rotate_directions(var/list/L, var/basedir)
	var/angle
	var/list/result = list()
	switch(basedir)
		if(NORTH)
			angle = 180
		if(EAST)
			angle = 90
		if(WEST)
			angle = 270
		else
			angle = 0
	for(var/I in L)
		result += turn(I, angle)
	return result

/obj/machinery/power/collider
	name = "unconfigured particle accelerator section"
	desc = "You should not be seeing this."
	icon = 'icons/obj/machines/particle_collider.dmi'
	icon_state = "collider_error"
	monitoring_enabled = TRUE
	anchored = 0
	density = 1
	machine_flags = SCREWTOGGLE | CROWDESTROY | FIXED2WORK | WRENCHMOVE 
	
	var/datum/particle_collider/parent_collider = null
	var/list/connected_neighbors
	var/list/connectable_directions = list(NORTH, SOUTH, EAST, WEST) //provided we're facing south
	var/acceleration_power = 0
	  
/obj/machinery/power/collider/New()
	..()
	parent_collider = new /datum/particle_collider
	parent_collider.connected_sections += src
	connect_to_neighbors()

/obj/machinery/power/collider/proc/particle_event(var/obj/item/projectile/particle/P)
	//base type, this should never happen
	P.dir = pick(rotate_directions(connectable_directions,dir))
	message_admins("uh oh, someone didn't overwrite the parent particle_event in [src]!")

/obj/machinery/power/collider/proc/connect_unary(var/obj/machinery/power/collider/C, direction)
	if(!C.anchored)
		return 0 //neighbor not anchored
	var/list/cdirs = rotate_directions(C.connectable_directions, C.dir)
	if(! turn(direction,180) in cdirs)
		return 0 //neighbor facing the wrong way
	var/datum/particle_collider/my_parent = parent_collider
	var/datum/particle_collider/his_parent = C.parent_collider
	if(my_parent == his_parent)
		C.update_icon()
		return 0  //already connected
		
	var/datum/particle_collider/smaller = my_parent
	var/datum/particle_collider/larger = his_parent
	if(his_parent.connected_sections.len < my_parent.connected_sections.len)
		smaller = his_parent
		larger = my_parent
	for (var/obj/machinery/power/collider/temp in smaller.connected_sections)
		temp.parent_collider = larger
		larger.connected_sections += temp
		qdel(smaller)
	C.update_icon()
	return 1
	
/obj/machinery/power/collider/proc/connect_to_neighbors()
	if(!anchored)
		visible_message("not anchored")
		return 0
	var/result = 0
	var/list/D = rotate_directions(connectable_directions, dir)
	for (var/direction in D)
		var/turf/T = get_step(loc, direction)
		for (var/obj/machinery/power/collider/C in T)
			connect_unary(C,direction)
	update_icon()
	return result
	
/obj/machinery/power/collider/Del()
	parent_collider.connected_sections.Remove(src)
	parent_collider.rebuild_entire_network() 
	//this isnt necessary as long as the thing doesn't get deleted randomly
	//which actually now that i think about it is pretty often (explosions, singularities)
	//TODO fix this so it doesn't wait 10 seconds for the garbage collector
	..()
	
/obj/machinery/power/collider/wrenchAnchor(var/mob/user, var/obj/item/O)
	if(..())
		if(!anchored)
			parent_collider.connected_sections.Remove(src)
			parent_collider.rebuild_entire_network() 
			parent_collider = new /datum/particle_collider
			parent_collider.connected_sections += src
		else
			connect_to_neighbors()
		
		var/list/D = rotate_directions(connectable_directions, dir)
		for (var/direction in D)
			var/turf/T = get_step(loc, direction)
			for (var/obj/machinery/power/collider/C in T)
				C.update_icon()
		update_icon()

/obj/machinery/power/collider/crowbarDestroy(mob/user, obj/item/tool/crowbar/I)
	if (..())
		parent_collider.connected_sections.Remove(src)
		parent_collider.rebuild_entire_network() 
		qdel(src)
	
/obj/machinery/power/collider/verb/rotate_cw()
	set name = "Rotate (Clockwise)"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	if (usr.incapacitated() || !Adjacent(usr))
		return 0
	src.dir = turn(src.dir, -90)

/obj/machinery/power/collider/AltClick(mob/user)
	rotate_cw()
	
	
	
/obj/machinery/power/collider/merger
	name = "particle merger"
	desc = "merges particle streams"
	icon_state = "merger"
	connectable_directions = list(NORTH, SOUTH, EAST)
	component_parts = newlist(
		/obj/item/weapon/circuitboard/particle_collider/merger,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/scanning_module)
	
/obj/machinery/power/collider/merger/particle_event(var/obj/item/projectile/particle/P)
	P.dir = dir
	
/obj/machinery/power/collider/filter
	name = "particle filter"
	desc = "deflects slow particles left while letting more energetic ones pass straight"
	icon_state = "filter"
	connectable_directions = list(NORTH, SOUTH, EAST)
	component_parts = newlist(
		/obj/item/weapon/circuitboard/particle_collider/filter,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/scanning_module)
	
	var/filterspeed = 20
	
/obj/machinery/power/collider/filter/particle_event(var/obj/item/projectile/particle/P)
	if(P.speed < filterspeed)
		P.dir = turn(P.dir, 90)
	
/obj/machinery/power/collider/filter/attack_hand(mob/user as mob)
	filterspeed = input("particle filter", "Set deflection strength", filterspeed)
	
/obj/machinery/power/collider/filter/examine(mob/user)
	. = ..()
	to_chat(user, "currently set to deflect particles slower than [filterspeed] units.")
	
/obj/machinery/power/collider/emitter
	name = "particle emitter"
	desc = "emits slow-moving particles"
	icon_state = "emitter"
	connectable_directions = list(SOUTH)
	component_parts = newlist(
		/obj/item/weapon/circuitboard/particle_collider/emitter,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser)
		
	var/on = FALSE
	var/emitted_particle = /obj/item/projectile/particle

/obj/machinery/power/collider/emitter/attack_hand(mob/user as mob)
	src.on = !src.on
	to_chat(user, "<span class='info'>You turn [src] [src.on? "on" : "off"].</span>")

/obj/machinery/power/collider/emitter/process()
	if(!on)
		return
	if(stat & (FORCEDISABLE|NOPOWER))
		return
	if(!anchored)
		return
	var/obj/item/projectile/particle/P = new emitted_particle(src.loc)
	P.dir = dir
	
/obj/machinery/power/collider/bottler
	name = "particle bottler"
	desc = "collects particles into easily transportable jars"
	icon_state = "bottler"
	connectable_directions = list(SOUTH)
	component_parts = newlist(
		/obj/item/weapon/circuitboard/particle_collider/bottler,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/micro_laser)
	
/obj/machinery/power/collider/collider
	name = "hadron collider"
	desc = "smashes high speed particles into each other, creating new ones. higher speeds make collisions more likely."
	icon_state = "collider"
	connectable_directions = list(WEST, SOUTH, EAST)
	component_parts = newlist(
		/obj/item/weapon/circuitboard/particle_collider/collider,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser)
	
	var/obj/item/projectile/particle/chamber_left = null
	var/obj/item/projectile/particle/chamber_right = null
	
/obj/machinery/power/collider/collider/proc/collide_chambers()
	if (chamber_left && chamber_right)
		src.visible_message("the [chamber_left] and [chamber_right] collide with a combined energy of [chamber_left.speed + chamber_right.speed]!")
		QDEL_NULL(chamber_left)
		QDEL_NULL(chamber_right)
	
/obj/machinery/power/collider/collider/particle_event(var/obj/item/projectile/particle/P)
	if(turn(dir, 90) == P.dir)
		if(chamber_left)
			QDEL_NULL(chamber_left)
		chamber_left = P
		chamber_left.active = FALSE
	if(turn(dir, -90) == P.dir)
		if(chamber_right)
			QDEL_NULL(chamber_right)
		chamber_right = P
		chamber_right.active = FALSE
	collide_chambers()	
	
	
/obj/machinery/power/collider/pipe
	name = "particle collider tube"
	desc = "transports and accelerates particles"
	anchored = 1
	acceleration_power = 1
	component_parts = newlist(
		/obj/item/weapon/circuitboard/particle_collider/pipe,
		/obj/item/weapon/stock_parts/micro_laser)
	
	var/required_connections = 2
	var/list/particle_outputs = list() //this gets updated in update_icon
	
/obj/machinery/power/collider/pipe/northsouth_only
	connectable_directions = list(NORTH, SOUTH)
	
/obj/machinery/power/collider/pipe/particle_event(var/obj/item/projectile/particle/P)
	P.speed += acceleration_power
	if (P.dir in particle_outputs)
		return
	var/a = turn(P.dir, 90)
	if(a in particle_outputs)
		P.dir = a
		return 
	a = turn(P.dir, -90)
	if(a in particle_outputs)
		P.dir = a
	
	
/obj/machinery/power/collider/pipe/update_icon()
	if (!parent_collider)
		icon_state = "tube_error"
		return
	particle_outputs = list()
	var/neighbors = 0
	var/n = 0
	var/list/D = rotate_directions(connectable_directions, dir)
	for (var/direction in D)
		var/turf/T = get_step(loc, direction)
		for (var/obj/machinery/power/collider/C in T)
			if(C.parent_collider == parent_collider)
				var/list/cdirs = rotate_directions(C.connectable_directions, C.dir)
				if(turn(direction,180) in cdirs)
					neighbors += direction
					n += 1
					particle_outputs += direction
	if(n && n <= required_connections)
		icon_state = "tube_[neighbors]"
	else
		icon_state = "tube_error"
	
