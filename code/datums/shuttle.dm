#define NO_TRANSIT 0 //Don't use transit areas
#define TRANSIT_ACROSS_Z_LEVELS 1 //Only use transit areas if moving to another z-level
#define TRANSIT_ALWAYS 2 //Always use transit areas
#define CHEAP_TRANSIT 3 //Only use transit areas when moving to another z-level, with free travel between the station and roid

//Whether this shuttle can be linked to a shuttle control console.
#define LINK_FREE 0
#define LINK_PASSWORD_ONLY 1
#define LINK_FORBIDDEN 2

//Whether the shuttle destroys stuff it collides with, or displaces it
#define COLLISION_DESTROY 0
#define COLLISION_DISPLACE 1 //this is same as COLLISION_DISPLACE as for now

//One of these values is returned at initialize()
#define INIT_SUCCESS	1 //everything is good
#define INIT_NO_AREA	2 //can't find starting area
#define INIT_NO_PORT	3 //can't find shuttle's docking port
#define INIT_NO_START	4 //shuttle's docking port isn't connected to a destination port

/datum/shuttle
	var/name = "shuttle"

	//List of ALL docking ports the shuttle can move to
	var/list/docking_ports = list()

	//The shuttle's main area - it contains the linked_port
	var/area/linked_area

	//The shuttle's linked shuttle docking port - essential
	var/obj/docking_port/shuttle/linked_port

	//The shuttle's current location
	var/obj/docking_port/destination/current_port

	//The shuttle's transit location
	var/obj/docking_port/destination/transit_port

	//The shuttle's destination
	var/obj/docking_port/destination/destination_port

	//List of ALL docking ports on the shuttle. Setup at initialize(), the shuttle can only move docking ports in this list
	//(which means those which are placed in the shuttle's area on the map). This exists to prevent shuttles from moving on top
	//of another docking port and then moving it away
	var/list/docking_ports_aboard = list()

	var/use_transit = TRANSIT_ACROSS_Z_LEVELS

	var/dir = NORTH

	var/can_rotate = 1

	//This is the time it takes for the shuttle to depart (if there's a transit area) or to travel (if there are no transit areas)
	var/pre_flight_delay = 50

	//If there is a transit port, this is the time the shuttle spends in it
	//If there isn't a transit port, this has no effect. Use the pre_flight_delay var instead
	var/transit_delay = 100

	//If the shuttle is currently moving
	var/moving = 0

	var/list/cant_leave_zlevel = list(
		/obj/item/weapon/disk/nuclear = "The nuclear authentication disk can't be transported on a shuttle.",
		)

	//This list is transferred to all linked shuttle control consoles
	var/list/req_access = list()

	var/last_moved = 0
	var/cooldown = 100

	//When the shuttle moves, coordinates of its final location will be offset by rand(-innacuracy, innacuracy)
	var/innacuracy = 0

	//When the shuttle moves, if stable is 0 then all unbuckled mobs will be stunned
	var/stable = 0

	var/password = null
	var/can_link_to_computer = LINK_FORBIDDEN

	//Whether the shuttle gibs or displaces stuff. Change this to COLLISION_DISPLACE to make all shuttles displace stuff by default
	var/collision_type = COLLISION_DESTROY

	var/list/control_consoles = list()

	var/lockdown = 0

	var/destroy_everything = 0

/datum/shuttle/New(var/area/starting_area)
	.=..()

	if(starting_area)
		if(ispath(starting_area))
			linked_area = locate(starting_area)
		else if(isarea(starting_area))
			linked_area = starting_area
		else
			linked_area = starting_area
			warning("Unable to find area [starting_area] in world - [src.type] ([src.name]) won't be able to function properly.")

	if(istype(linked_area)) //Only add the shuttle to the list if its area exists and it has something in it
		shuttles |= src
	if(password)
		password = rand(10000,99999)

//initialize() proc - called automatically in proc/setup_shuttles() below.
//Returns INIT_SUCCESS, INIT_NO_AREA, INIT_NO_START or INIT_NO_PORT, depending on whether there were any errors
/datum/shuttle/initialize()
	. = INIT_SUCCESS
	src.docking_ports = list()
	src.docking_ports_aboard = list()
	src.transit_port = null

	if(!linked_area || !istype(linked_area))
		//No linked area - the shuttle doesn't exist (very bad)
		return INIT_NO_AREA

	//This line below used to cause weird bugs with some maps (https://github.com/d3athrow/vgstation13/issues/6773)

	//var/obj/docking_port/shuttle/shuttle_docking_port = locate() in linked_area.contents.Copy()

	//I have no idea what was causing it, but after replacing it with the following five lines everything started working as intended
	var/obj/docking_port/shuttle/shuttle_docking_port

	for(var/obj/docking_port/shuttle/S in linked_area)
		shuttle_docking_port = S
		break
	//

	if(shuttle_docking_port)
		//In case this shuttle already has a shuttle docking port, unlink it
		if(linked_port)
			linked_port.unlink_from_shuttle(src)

		shuttle_docking_port.link_to_shuttle(src)

		//The following few lines ensure that if there's a docking port at the shuttle's starting location, the shuttle is docked to it
		var/turf/check_turf = shuttle_docking_port.get_docking_turf()
		if(check_turf)
			for(var/obj/docking_port/P in check_turf.contents)
				shuttle_docking_port.dock(P)
				src.current_port = shuttle_docking_port.docked_with
				break

		if(!src.current_port)
			//This isn't really a problem, but if the shuttle moves somewhere it won't be able to return to its starting location
			. = INIT_NO_START

	else
		//No docking port - the shuttle can't be moved (bad but fixable with admin intervention)
		. = INIT_NO_PORT


	for(var/obj/docking_port/D in linked_area)
		docking_ports_aboard |= D

	for(var/obj/structure/shuttle/engine/propulsion/P in linked_area) // Use any shuttle engine to set the shuttle's direction
		if(istype(P))
			dir = P.dir
			break

	for(var/turf/T in linked_area.area_turfs)
		var/corner = FALSE
		if(!isopensurface(T) || !istype(T,/turf/space))
			for(var/obj/O in T.contents)
				if(istype(O,/obj/structure/shuttle))
					if(istype(T,/turf/space))
						corner = TRUE
						break
			if(corner)
				continue
			T.turf_flags |= SHUTTLE_TURF
	return

/datum/shuttle/Destroy()
	shuttles -= src
	..()

/datum/shuttle/proc/get_transit_delay()
	return transit_delay

/datum/shuttle/proc/get_pre_flight_delay()
	return pre_flight_delay

/datum/shuttle/proc/get_cooldown()
	return cooldown

//Shuttles like the emergency shuttle (which moves to pre-defined locations) and vox shuttle (which ends the round once moved to a pre-defined location)
//should have this proc return 1, so they can't be deleted.
/datum/shuttle/proc/is_special()
	return 0

//Adds a docking port to list of travel destinations, accepts path or the port itself
/datum/shuttle/proc/add_dock(var/D)
	if(ispath(D))
		for(var/obj/docking_port/destination/dock in all_docking_ports)
			if(istype(dock,D))
				dock.link_to_shuttle(src)
				return dock
	else if(istype(D,/obj/docking_port/destination))
		var/obj/docking_port/destination/dock = D
		dock.link_to_shuttle(src)
		return dock

	return D

//The reverse
/datum/shuttle/proc/remove_dock(var/D)
	if(ispath(D))
		for(var/obj/docking_port/destination/dock in all_docking_ports)
			if(istype(dock,D))
				dock.unlink_from_shuttle(src)
				return dock
	else if(istype(D,/obj/docking_port/destination))
		var/obj/docking_port/destination/dock = D
		dock.unlink_from_shuttle(src)
		return dock

	return D

//Adds a docking port as a transit area, accepts path or the port itself
/datum/shuttle/proc/set_transit_dock(var/D)
	if(ispath(D))
		for(var/obj/docking_port/destination/dock in all_docking_ports)
			if(istype(dock,D))
				transit_port = dock
				return dock
	else if(istype(D,/obj/docking_port/destination))
		transit_port = D
	return D

/datum/shuttle/proc/can_move()
	if(lockdown)
		return 0
	if(last_moved + cooldown < world.time)
		return 1

//Checks the shuttle for any offending atoms
/datum/shuttle/proc/forbid_movement()
	var/atom/A = linked_area.contains_atom_from_list(cant_leave_zlevel) //code/game/atoms.dm, 243
	if(A)
		return A
	for(var/mob/living/M in get_contents_in_object(linked_area, /mob/living))
		var/datum/virtual_z/destination_port_vz = destination_port.get_virtual_z()
		if(M.locked_to_v && M.locked_to_v != destination_port_vz)
			return M
	return 0

//This is the proc you generally want to use when moving a shuttle. Runs all sorts of checks (cooldown, if already moving, etc)
//If you want to bypass it, set destination_port to something and call pre_flight()
//Alternatively, call move_to_dock(destination)
/datum/shuttle/proc/travel_to(var/obj/docking_port/D, var/obj/machinery/computer/shuttle_control/broadcast = null, var/mob/user, var/eject = FALSE)
	if(!D)
		return 0 //no docking port
	if(!linked_port)
		return 0 //no shuttle port

	if(destination_port)
		if(broadcast)
			broadcast.announce( "The shuttle is currently in process of moving." )
		else if(user)
			to_chat(user, "The shuttle is currently moving")
		return 0 //shuttle already travelling

	if(lockdown)
		if(broadcast)
			broadcast.announce( "This shuttle is locked down." )
		else if(user)
			to_chat(user, "The shuttle can't move (locked down)")
		return 0

	if(!can_move())
		if(broadcast)
			broadcast.announce( "The engines are still cooling down from the previous trip." )
		else if(user)
			to_chat(user, "The shuttle can't move (on cooldown)")
		return 0

	if(D.docked_with)
		if(broadcast)
			broadcast.announce( "[capitalize(D.areaname)] is currently used by another shuttle. Please wait until the docking port is free, or select another destination." )
		else if(user)
			to_chat(user, "The shuttle can't move ([D.areaname] is used by another shuttle)")
		return 0

	if(broadcast)
		//Check if the selected docking port is valid (can be selected)
		if(!broadcast.allow_selecting_all && !(D in docking_ports))
			//Check disks too
			if(!broadcast.disk)
				if(user)
					to_chat(user, "<span class='warning'>No disk detected.</span>")
				return 0
			if(!broadcast.disk.compatible(src))
				if(user)
					to_chat(user, "<span class='warning'>Current disk not compatible with current shuttle.</span>")
				return 0
			if(broadcast.disk.destination != D)
				if(user)
					to_chat(user, "<span class='warning'>Currently selected docking port not valid.</span>")
				return 0

	if(D.require_admin_permission && !isAdminGhost(user))
		if(broadcast)
			broadcast.announce( "Currently requesting permission to reach [D.areaname]..." )
		else if(user)
			to_chat(user, "Waiting for permission...")
		if(user)
			var/reason = input(user, "State your reasons for wanting to dock at [D.areaname].", "Docking Request", "")
			message_admins("[key_name(user)] is requesting permission to fly their [name] to [D.areaname]. [reason ? "Reason:[reason]" : "They didn't give a reason"]. (<a href='?_src_=holder;shuttlepermission=1;shuttle=\ref[src];docking_port=\ref[D];broadcast=\ref[broadcast];user=\ref[user];answer=1'>ACCEPT</a>/<a href='?_src_=holder;shuttlepermission=1;shuttle=\ref[src];docking_port=\ref[D];broadcast=\ref[broadcast];user=\ref[user];answer=0'>DENY</a>)")
	else
		actually_travel_to(D, broadcast, user, eject)

/datum/shuttle/proc/actually_travel_to(var/obj/docking_port/D, var/obj/machinery/computer/shuttle_control/broadcast = null, var/mob/user, var/eject = FALSE)
	//Handle the message
	var/time = "as soon as possible"
	switch(pre_flight_delay)
		if(0)
			time = "immediately"
		if(1 to 30)
			time = "in a few seconds"
		if(31 to 50)
			time = "shortly"
		if(51 to 80)
			time = "after a short delay"
		if(81 to INFINITY)
			time = "in [max(round((pre_flight_delay) / 10, 1), 0)] seconds"
	if(broadcast)
		broadcast.announce("The shuttle has received your message and will be sent [time].")

	animate_liftoff()
	if(eject)
		eject_mobs()

	destination_port = D
	last_moved = world.time
	moving = 1

	log_game("[usr ? key_name(usr) : "Something"] sent [name] ([type]) to [D.areaname]")

	if(get_pre_flight_delay())
		spawn(max(1,get_pre_flight_delay()-5))
			for(var/obj/structure/shuttle/engine/propulsion/P in linked_area)
				spawn()
					P.shoot_exhaust()
	if(current_port)
		current_port.start_warning_lights()
	destination_port.start_warning_lights()

	spawn(get_pre_flight_delay())
		if(eject)
			eject_mobs(TRUE) //Make sure there aren't any stowaways
		if(current_port)
			current_port.stop_warning_lights()
		if(destination_port)
			destination_port.stop_warning_lights()
		//If moving to another zlevel, check for items which can't leave the zlevel (nuke disk, primarily)
		if(linked_port.z != D.z)
			var/atom/A = forbid_movement()
			if( A )
				if(cant_leave_zlevel[A.type])
					if(broadcast)
						broadcast.announce("ERROR: [cant_leave_zlevel[A.type]]")
					else if(user)
						to_chat(user, cant_leave_zlevel[A.type])
				else
					if(broadcast)
						broadcast.announce("ERROR: [A.name] is preventing the shuttle from departing.")
					else if(user)
						to_chat(user, "[A.name] is preventing the shuttle from departing.")
				moving = 0
				destination_port = null
				reset_visuals()
				return
			for(var/atom/movable/AA in linked_area)
				INVOKE_EVENT(AA, /event/v_transition, "user" = AA, "to_v" = D.get_virtual_z(), "from_v" = linked_port.get_virtual_z())
		if(D.get_virtual_z() != linked_port.get_virtual_z())
			var/datum/virtual_z/to_v = D.get_virtual_z()
			var/datum/virtual_z/from_v = linked_port.get_virtual_z()
			for(var/atom/movable/AA in linked_area)
				if(!istype(AA, /mob/living))
					continue
				var/mob/living/LL = AA
				to_v.mob_entered(LL)
				from_v.mob_exited(LL)


		if(transit_port && get_transit_delay())
			if(broadcast)
				broadcast.announce( "The shuttle has departed and is now moving towards [D.areaname]." )
			else if(user)
				to_chat(user, "The shuttle has departed towards [D.areaname]")
		else
			if(broadcast)
				broadcast.announce( "The shuttle has arrived at [D.areaname]." )
			else if(user)
				to_chat(user, "The shuttle has arrived at [D.areaname]")

		pre_flight()

	return 1

/datum/shuttle/proc/pre_flight()
	if(!destination_port)
		return

	var/datum/virtual_z/vz = destination_port.get_virtual_z()
	if(vz.planet)
		vz.spawn_lz_warnings(src)
	if(transit_port && get_transit_delay())
		if(transit_check())
			close_all_doors()
			move_to_dock(transit_port)
			spawn(max(1,get_transit_delay()-5))
				for(var/obj/structure/shuttle/engine/propulsion/P in linked_area)
					spawn()
						P.shoot_exhaust()
			for(var/atom/A in linked_area.contents)
				animate(A)
				if(istype(A,/mob/living))
					var/mob/living/M = A
					M << sound("sound/machines/hyperspace_progress.ogg", repeat = 0, wait = 1, channel = CHANNEL_AMBIENCE, volume = 75)
			spawn(get_transit_delay())
				complete_flight()
			return

	complete_flight()

/datum/shuttle/proc/complete_flight()
	if(destination_port)
		animate_landing()
		move_to_dock(destination_port)
		destination_port = null

	moving = 0

/datum/shuttle/proc/transit_check()
	if(use_transit == NO_TRANSIT) // no transit
		return FALSE
	else if(use_transit == TRANSIT_ALWAYS) // always transit
		return TRUE
	else if(linked_area.z == destination_port.z) // same z-level
		if(istype(destination_port,/obj/docking_port/destination/planet_surface) || istype(linked_port,/obj/docking_port/destination/planet_surface)) //transit to/from a planet
			return TRUE
		else
			return FALSE
	else if(use_transit == CHEAP_TRANSIT) // station <-> roid no transit
		if(linked_area.z == map.zMainStation) // no transit from station to the roid
			if(destination_port.z == map.zAsteroid)
				return FALSE
			else
				return TRUE
		else if(destination_port.z == map.zMainStation) // no transit from roid to station
			if(linked_area.z == map.zAsteroid)
				return FALSE
			else
				return TRUE
		else
			return TRUE
	else if(use_transit == TRANSIT_ACROSS_Z_LEVELS) // transit across a z-level
		if(linked_area.z != destination_port.z)
			return TRUE
		else
			return FALSE
	else
		return FALSE

/datum/shuttle/proc/animate_liftoff()
	var/variation = rand(1,2)
	for(var/atom/A in linked_area.contents)
		var/skip = FALSE
		if(istype(A,/obj/structure/shuttle/engine/heater))
			var/obj/structure/shuttle/engine/heater/H = A
			H.activate()
		if(istype(A,/mob/living))
			var/mob/living/M = A
			M << sound("sound/machines/hyperspace_begin.ogg", repeat = 0, wait = 0, channel = CHANNEL_AMBIENCE, volume = 50)
		if(istype(A,/turf))
			var/turf/T = A
			for(var/obj/O in T.contents)
				if(istype(O,/obj/structure/shuttle/diag_wall))
					skip = TRUE
					break
		if(skip)
			continue
		var/base_y = A.pixel_y + 5
		animate(A, pixel_y = base_y, time = 5, easing = SINE_EASING | EASE_OUT)
		animate(pixel_y = base_y + variation, time = 10, easing = SINE_EASING, loop = -1)
		animate(pixel_y = base_y - variation, time = 10, easing = SINE_EASING)
		A.pixel_y = base_y - 5

/datum/shuttle/proc/animate_landing()
	for(var/atom/A in linked_area.contents)
		var/skip = FALSE
		if(istype(A,/mob/living))
			var/mob/living/M = A
			M << sound("sound/machines/hyperspace_end.ogg", repeat = 0, wait = 0, channel = CHANNEL_AMBIENCE, volume = 50)
		if(istype(A,/turf))
			var/turf/T = A
			for(var/obj/O in T.contents)
				if(istype(O,/obj/structure/shuttle/diag_wall))
					skip = TRUE
					break
		if(skip)
			continue
		A.pixel_y += 5
		animate(A, pixel_y = A.pixel_y - 5, time = 10, easing = SINE_EASING|EASE_OUT)
	spawn(15)
		reset_visuals()

/datum/shuttle/proc/reset_visuals()
	for(var/atom/A in linked_area.contents)
		if(istype(A,/obj/structure/shuttle/engine/heater))
			var/obj/structure/shuttle/engine/heater/H = A
			H.deactivate()
		animate(A)

//This is the proc you want to use to FORCE a shuttle to move. It always moves it, unless the shuttle or its area don't exist. Transit is skipped, after_flight() is called
/datum/shuttle/proc/move_to_dock(var/obj/docking_port/D, var/ignore_innacuracy = 0, var/rotate_after = 0) //A direct proc with no bullshit
	if(!D)
		return
	if(!linked_port)
		return

	// Track source virtual_z before moving for departure event (use current_port, not linked_port)
	var/datum/virtual_z/source_vz = current_port?.get_virtual_z()

	//List of all shuttles docked to this shuttle. They will be moved together with their parent.
	//In the list, shuttles are associated with the docking port they are docked to
	var/list/docked_shuttles = list()

	//To prevent two shuttles that are docked to each other from potentially breaking everything, all moved shuttles are added to this list
	var/list/moved_shuttles = list()

	moved_shuttles += src

	//See all destination ports in current area
	for(var/obj/docking_port/destination/dock in linked_area)
		//If somebody is docked to it (and it isn't us (that would be weird but better be sure))
		if(dock.docked_with && !(dock.docked_with == linked_port))
			//Get the docking port that's docked to it, and then its shuttle
			var/obj/docking_port/shuttle/S = dock.docked_with
			if(!S || !S.linked_shuttle)
				continue

			docked_shuttles |= S.linked_shuttle
			docked_shuttles[S.linked_shuttle]=dock

	//******Handle rotation*********
	var/rotate = 0
	if(src.can_rotate)

		if(linked_port.dir != turn(D.dir,180))

			rotate = dir2angle(turn(D.dir,180)) - dir2angle(linked_port.dir)

			rotate += rotate_after

			if(rotate < 0)
				rotate += 360
			else if(rotate >= 360)
				rotate -= 360

	//******Get the turf to move to**
	var/turf/target_turf = D.get_docking_turf()

	if(!ignore_innacuracy && innacuracy) //Handle innacuracy
		var/list/turf_list = list()

		for(var/turf/T in orange(innacuracy,D.get_docking_turf()))
			turf_list|=T

		target_turf = pick(turf_list)

	//****Finally, move the area***
	if(move_area_to(get_turf(linked_port), target_turf, rotate))

		linked_port.dock(D) //Dock our docking port with the destination

		//****Move shuttles docked to us**
		if(docked_shuttles.len)
			for(var/datum/shuttle/S in docked_shuttles)
				if(S in moved_shuttles)
					continue
				var/obj/docking_port/destination/our_moved_dock = docked_shuttles[S]
				if(!our_moved_dock)
					continue

				moved_shuttles |= S
				S.move_to_dock(our_moved_dock, ignore_innacuracy = 1)

		log_game("[name] ([type]) moved to [D.areaname]")

		current_port = D

		if(source_vz)
			INVOKE_EVENT(src, /event/shuttle_departed, "vz" = source_vz, "shuttle" = src)
		var/datum/virtual_z/dest_vz = D.get_virtual_z()
		if(dest_vz)
			INVOKE_EVENT(src, /event/shuttle_arrived, "vz" = dest_vz, "shuttle" = src)

		after_flight() //Shake the shuttle, weaken unbuckled mobs, etc.

		return 1
	return

/datum/shuttle/proc/close_all_doors()
	for(var/obj/machinery/door/unpowered/shuttle/D in linked_area)
		spawn(0)
			D.close()

/datum/shuttle/proc/open_all_doors()
	for(var/obj/machinery/door/unpowered/shuttle/D in linked_area)
		spawn(0)
			D.open()

//Shakes cameras for mobs
/datum/shuttle/proc/after_flight()
	var/datum/virtual_z/vz = current_port.get_virtual_z()
	if(vz.planet)
		vz.clear_lz_warnings(src)
	for(var/atom/movable/AM in linked_area)
		if(AM.anchored)
			continue

		if(istype(AM,/mob/living))
			var/mob/living/M = AM

			if(!M.locked_to)
				shake_camera(M, 10, 1) // unbuckled, HOLY SHIT SHAKE THE ROOM

				if(!src.stable)
					if(istype(M, /mob/living/carbon))
						M.Knockdown(3)
			else
				shake_camera(M, 3, 1) // buckled, not a lot of shaking

//Gibs or moves mobs and stuff
/datum/shuttle/proc/collide(var/atom/movable/AM as mob|obj)
	AM.shuttle_act(src)

//This is awful
/datum/shuttle/proc/supercharge()
	cooldown = 0
	pre_flight_delay = 0
	transit_delay = 0

//Like (input() in shuttles), but better
/proc/select_shuttle_from_all(var/mob/user, var/message = "Select a shuttle", var/title = "Shuttle selection", var/list/omit_shuttles = null, var/show_lockdown = 0, var/show_cooldown = 0)
	if(!user)
		return

	var/list/shuttle_list = list()
	for(var/datum/shuttle/S in shuttles)
		if(omit_shuttles)
			if(S.type in omit_shuttles)
				continue
			if(S in omit_shuttles)
				continue
			if(S.name in omit_shuttles)
				continue
		var/name = S.name
		if(show_lockdown && S.lockdown)
			name = "[name] (LOCKDOWN)"
		else
			if(show_cooldown && !S.can_move())
				name = "[name] (ON COOLDOWN)"
		shuttle_list += name
		shuttle_list[name]=S

	var/my_shuttle = input(usr, message, title) as null|anything in shuttle_list

	if( my_shuttle && shuttle_list[my_shuttle] && istype(shuttle_list[my_shuttle], /datum/shuttle) )
		return shuttle_list[my_shuttle]

/datum/shuttle/proc/move(var/mob/user) //a very simple proc which selects a random area and sends the shuttle there
	var/list/possible_locations = list()
	for(var/obj/docking_port/destination/S in src.docking_ports)
		if(S == current_port)
			continue
		if(S.docked_with)
			continue

		possible_locations += S

	if(!possible_locations.len)
		return
	var/obj/docking_port/destination/target = pick(possible_locations)

	travel_to(target,,user)

/datum/shuttle/proc/get_occupants(var/find_stowaways)
	var/list/occupants = list()
	if(!find_stowaways)
		for(var/mob/living/L in linked_area) //Yeah they could be hiding in lockers, but that's a stowaway not an occupant
			occupants.Add(L)
	else
		for(var/mob/living/L in mob_list)
			if(get_area(L) == linked_area)
				occupants.Add(L)
	return occupants

/datum/shuttle/proc/get_size()
	if(!linked_area)
		return null

	var/low_x = world.maxx
	var/low_y = world.maxy
	var/high_x = 1
	var/high_y = 1

	for(var/turf/T in linked_area)
		if(T.x < low_x)
			low_x = T.x
		if(T.x > high_x)
			high_x = T.x
		if(T.y < low_y)
			low_y = T.y
		if(T.y > high_y)
			high_y = T.y

	return list(abs(high_x - low_x) + 1, abs(high_y - low_y) + 1)

/proc/get_refill_area(var/obj/docking_port/destination/D)
	if(ispath(D?.refill_area))
		return locate(D.refill_area)
	else
		return get_space_area()

//The proc that does most of the work
//RETURNS: 1 if everything is good, 0 if everything is bad
/datum/shuttle/proc/move_area_to(var/turf/our_center, var/turf/new_center, var/rotate = 0)
	if(!our_center)
		return
	if(!new_center)
		return
	if((rotate % 90) != 0) //If not divisible by 90, make it
		rotate += (rotate % 90)

	var/datum/coords/our_center_coords = new(our_center.x,our_center.y)
	var/datum/coords/new_center_coords = new(new_center.x,new_center.y)

	var/datum/coords/offset = new_center_coords.subtract(our_center_coords)

	//For displacing
	var/throwy = world.maxy

	var/obj/docking_port/destination/D = linked_port.docked_with
	var/area/refill_area //the area that will be stamped over where the shuttle left

	refill_area = get_refill_area(D)
	if(!refill_area)
		warning("Unable to find refill area for shuttle [src.type]")

	//Make a list of coordinates of turfs to move, and associate the coordinates with the turfs they represent
	var/list/turfs_to_move = list()

	//Now here's the dumb part - since there's no fast way I know to check if a coord datum has a coord datum with the same values in a list,
	//this coordinates list stores every coordinate of a moved turf as a string (example: "52;61").
	var/list/our_own_turfs = list()

	//Go through all turfs in our area
	for(var/turf/T in linked_area.contents)
		var/datum/coords/C = new(T.x,T.y)
		turfs_to_move += C
		turfs_to_move[C] = T

		our_own_turfs += "[T.x];[T.y];[T.z]"

	var/cosine	= cos(rotate)
	var/sine	= sin(rotate)

	//Calculate new coordinates
	var/list/new_turfs = list() //Coordinates of turfs that WILL be created
	for(var/datum/coords/C in turfs_to_move)
		var/datum/coords/new_coords = C.add(offset) //Get the coordinates of new turfs by adding offset

		new_turfs += new_coords
		new_turfs[new_coords] = C //Associate the old coordinates with the new ones for an easier time

		if(rotate != 0)
			//Oh god this works

			var/newX = (cosine	* (new_coords.x_pos - new_center.x))	+ (sine		* (new_coords.y_pos - new_center.y))	+ new_center.x
			var/newY = -(sine	* (new_coords.x_pos - new_center.x))	+ (cosine	* (new_coords.y_pos - new_center.y))	+ new_center.y

			new_coords.x_pos = newX
			new_coords.y_pos = newY

		if(new_coords.y_pos < throwy)
			throwy = new_coords.y_pos

		var/area/A = get_area( locate(new_coords.x_pos, new_coords.y_pos, new_center.z) )

		if(!A)
			message_admins("<span class='notice'>WARNING: Unable to find an area at [new_coords.x_pos];[new_coords.y_pos];[new_center.z]. [src.name] ([src.type]) will not be moved.")
			return
		if(!destroy_everything && !A.shuttle_can_crush) //Breaking blueprint areas and space is fine, breaking the station is not. Breaking randomly generated vaults is fine, in case they spawn in a bad spot!
			message_admins("<span class='notice'>WARNING: [src.name] ([src.type]) attempted to destroy [A] ([A.type]).</span> If you want [src.name] to be able to move freely and destroy areas, change its \"destroy_everything\" variable to 1.")
			return
		//If any of the new turfs are in the moved shuttle's current area, EMERGENCY ABORT (this leads to the shuttle destroying itself & potentially gibbing everybody inside)
		if("[new_coords.x_pos];[new_coords.y_pos];[new_center.z]" in our_own_turfs)
			warning("Shuttle ([src.name]; [src.type]) has attempted to move to a location which overlaps with its current position. Offending turf: [new_coords.x_pos];[new_coords.y_pos];[new_center.z]")
			message_admins("WARNING: A shuttle ([src.name]; [src.type]) has attempted to move to a location which overlaps with its current position. The shuttle will not be moved.")
			return


	var/list/turfs_to_update = list()
	var/list/corner_turfs = list()
	var/list/old_turfs = list() // Turfs that need weather re-registered after shuttle leaves

	//Move turfs
	for(var/datum/coords/C in new_turfs)
		//Get old turf type
		var/datum/coords/old_C = new_turfs[C]
		var/turf/old_turf = turfs_to_move[old_C]
		var/turf/new_turf = locate(C.x_pos,C.y_pos,new_center.z)
		var/add_underlay = 0

		if(!old_turf)
			message_admins("ERROR when moving [src.name] ([src.type]) - failed to get original turf at [old_C.x_pos];[old_C.y_pos];[our_center.z]")
			continue

		if(!new_turf)
			message_admins("ERROR when moving [src.name] ([src.type]) - failed to get new turf at [C.x_pos];[C.y_pos];[new_center.z]")
			continue

		// stop the shuttle corners from stealing turfs
		if(locate(/obj/structure/shuttle/diag_wall) in old_turf)
			corner_turfs[new_turf] = 1

		var/turf/displace_to = locate(C.x_pos,throwy,new_center.z)
		for(var/atom/movable/AM as mob|obj in new_turf.contents)
			if(AM.anchored || src.collision_type == COLLISION_DESTROY)
				src.collide(AM)
			else
				AM.forceMove(displace_to)

		var/area/old_area = get_area(new_turf) //this is the area that is being replaced by shuttle area in the destination
		if(!old_area)
			old_area = get_space_area()

		for(var/O in old_turf.overlays)
			var/image/I = O
			if(I.icon == 'icons/obj/projectiles.dmi')
				old_turf.overlays.Remove(I)		//remove beam overlays so they don't stay on the new turfs forever

		//Get the turf's image before it's gone!
		var/image/undlay
		if(add_underlay)
			undlay = image("icon"=new_turf.icon,"icon_state"=new_turf.icon_state,"dir"=new_turf.dir)
			undlay.overlays = new_turf.overlays

		//****Add the new turf to shuttle's area****

		linked_area.contents.Add(new_turf)
		new_turf.change_area(old_area,linked_area)
		if(isshuttleturf(old_turf) || (old_turf.turf_flags & SHUTTLE_TURF))
			new_turf.ChangeTurf(old_turf.type, allow = 1)
			new_turf.turf_flags |= SHUTTLE_TURF
			old_turf.turf_flags &= ~SHUTTLE_TURF
		new_turfs[C] = new_turf

		old_turf.pixel_y = initial(old_turf.pixel_y)
		new_turf.pixel_y = old_turf.pixel_y

		//***Remove old turf from shuttle's area****

		refill_area.contents.Add(old_turf)
		old_turf.change_area(linked_area,refill_area)

		//All objects which can't be moved by the shuttle have their area changed to refill_area!
		for(var/atom/movable/AM in old_turf.contents)
			if(!AM.can_shuttle_move(src))
				AM.change_area(linked_area,refill_area)

		if(old_turf.transform)
			new_turf.transform = old_turf.transform

		//****Prepare underlays**** (only do this if add_underlay is 1 -> see above)
		if(add_underlay && undlay)
			new_turf.underlays = list(undlay) //Remove all old underlays, add space
		else
			new_turf.underlays = old_turf.underlays
		/*
		if(ispath(replaced_turf_type,/turf/space))//including the transit hyperspace turfs
			if(old_turf.underlays.len)
				new_turf.underlays = old_turf.underlays
			else
				new_turf.underlays += undlay
		else
			new_turf.underlays += undlay*/

		if(!istype(old_turf, /turf/space))
			new_turf.dir = old_turf.dir
			new_turf.icon_state = old_turf.icon_state
			new_turf.icon = old_turf.icon
			new_turf.plane = old_turf.plane
			new_turf.layer = old_turf.layer
			new_turf.color = old_turf.color

			//***Moving the paint overlay****
			new_turf.paint_overlay = old_turf.paint_overlay
			if (new_turf.paint_overlay)
				new_turf.paint_overlay.my_turf = new_turf
				new_turf.update_paint_overlay()
				old_turf.overlays.len = 0
				old_turf.paint_overlay = null

			//***Moving decals****
			if (old_turf.turfdecals && old_turf.turfdecals.len > 0)
				for (var/image/decal in old_turf.turfdecals)
					new_turf.AddDecal(decal)

		// Hack: transfer the ownership of old_turf's floor_tile to new_tile.
		// Floor turfs create their `floor_tile` in New() if it's null.
		// The better solution would be to not do that at all in New(), or use
		// something like the map loader's atom preloader to transfer the
		// floor_tile before New().
		if(istype(old_turf, /turf/simulated/floor) && istype(new_turf, /turf/simulated/floor))
			var/turf/simulated/floor/ancient = old_turf
			var/turf/simulated/floor/modern = new_turf
			modern.floor_tile = ancient.floor_tile
			ancient.floor_tile = null
		if(rotate)
			new_turf.map_element_rotate(rotate)

		//*****Move air*****

		var/turf/simulated/S_OLD = old_turf

		if(istype(S_OLD) && S_OLD.zone)
			var/turf/simulated/S_NEW = new_turf

			if(!S_NEW.air)
				S_NEW.make_air()

			S_NEW.air.copy_from(S_OLD.zone.air)
			S_OLD.zone.remove(S_OLD)

		//*****Move objects and mobs*****
		for(var/mob/M in old_turf)	//mobs first
			if(!M.can_shuttle_move(src))
				continue
			move_atom(M, new_turf, rotate)
		for(var/atom/movable/AM in old_turf)
			if(!AM.can_shuttle_move(src))
				continue
			move_atom(AM, new_turf, rotate)


		//Move landmarks - for moving the arrivals shuttle
		for(var/list/L in moved_landmarks) //moved_landmarks: code/game/area/areas.dm, 527 (above the move_contents_to proc)
			if(old_turf in L)
				L -= old_turf
				L += new_turf

		//Add the new turf to the list of turfs to update
		turfs_to_update += new_turf

		//Delete the old turf
		var/replacing_turf_type = old_turf.get_underlying_turf()

		if(D && istype(D) && D.base_turf_type)
			replacing_turf_type = D.base_turf_type

		old_turf.ChangeTurf(replacing_turf_type, allow = 1)

		if(D && istype(D))
			if(D.base_turf_icon)
				old_turf.icon = D.base_turf_icon
			if(D.base_turf_icon_state)
				old_turf.icon_state = D.base_turf_icon_state

		if(istype(old_turf,/turf/space))
			old_turf.lighting_clear_overlay() //A horrible band-aid fix for lighting overlays appearing over space

		old_turfs += old_turf

	// shuttle corner adjustments
	for(var/turf/diag_turf in corner_turfs)
		var/obj/structure/shuttle/diag_wall/wall = locate(/obj/structure/shuttle/diag_wall) in diag_turf
		if(!wall)
			continue

		if(istype(diag_turf, /turf/space))
			var/turf/space/nextturf = null
			for(var/direction in list(NORTH, SOUTH, EAST, WEST))
				var/turf/check_turf = get_step(diag_turf, direction)
				if(check_turf && istype(check_turf, /turf/space))
					nextturf = check_turf
					break

			if(nextturf)
				diag_turf.icon = nextturf.icon
				diag_turf.icon_state = nextturf.icon_state
			else
				diag_turf.icon = initial(diag_turf.icon)
				diag_turf.icon_state = initial(diag_turf.icon_state)

	//Update doors
	if(turfs_to_update.len)
		for(var/turf/simulated/T1 in turfs_to_update)
			for(var/obj/machinery/door/D2 in T1)
				D2.update_nearby_tiles()

	// Unregister shuttle turfs from weather system
	// doing this for source and destination in case we move between planets
	var/datum/virtual_z/source_v = our_center.get_virtual_z()
	var/datum/climate/source_climate = SSweather.get_climate(source_v)
	if(!source_climate)
		source_climate = SSweather.get_climate(source_v)
	var/datum/virtual_z/dest_v = new_center.get_virtual_z()
	var/datum/climate/dest_climate = SSweather.get_climate(dest_v)
	if(!dest_climate)
		dest_climate = SSweather.get_climate(dest_v)

	for(var/turf/T in linked_area.contents)
		for(var/obj/effect/edge_overlay/E in T)
			qdel(E)
		if(T in corner_turfs)
			continue
		if(source_climate)
			source_climate.unregister_weather_turf(T)
		if(dest_climate)
			dest_climate.unregister_weather_turf(T)
		for(var/obj/effect/weather_holder/WH in T.vis_contents)
			T.vis_contents -= WH

	// Re-register turfs left behind by the shuttle with the source climate
	if(source_climate)
		for(var/turf/old_turf in old_turfs)
			source_climate.register_weather_turf(old_turf, TRUE)

	if(source_v.daynight_turfs.len)
		SSDayNight.update_turf_lighting(old_turfs, source_v)

	return 1

/datum/shuttle/proc/move_atom(var/atom/movable/AM, var/new_turf, var/rotate)
	if(AM.locs.len > 1) //If the moved object is on multiple tiles, move it after everything else (using spawn())
		AM.forceMove(null) //Without this, ALL neighbouring turfs attempt to move this object too, resulting in the object getting shifted to north/east

		spawn()
			AM.forceMove(new_turf)

	else
		AM.forceMove(new_turf)

	if(rotate)
		AM.map_element_rotate(rotate)

/proc/setup_shuttles()

	for(var/datum/shuttle/S in shuttles)
		switch(S.initialize())
			if(INIT_NO_AREA)
				if(S.is_special())
					var/msg = S.linked_area ? "- \"[S.linked_area]\" was given as a starting area." : ""
					warning("Invalid or missing starting area for [S.name] ([S.type]) [msg]")
				else
					var/msg = S.linked_area ? "- \"[S.linked_area]\" was given as a starting area." : ""
					log_debug("Invalid or missing starting area for [S.name] ([S.type]) [msg]")
			if(INIT_NO_PORT)
				if(S.is_special())
					warning("Couldn't find a shuttle docking port for [S.name] ([S.type]).")
				else
					log_debug("Couldn't find a shuttle docking port for [S.name] ([S.type]).")
			if(INIT_NO_START)
				if(S.is_special())
					warning("[S.name] ([S.type]) couldn't connect to a destination port on init - unless this is intended, there might be problems.")
				else
					log_debug("[S.name] ([S.type]) couldn't connect to a destination port on init - unless this is intended, there might be problems.")


	//THE MOST IMPORTANT PIECE OF CODE HERE
	emergency_shuttle.shuttle = escape_shuttle

	if(!emergency_shuttle || !emergency_shuttle.shuttle)
		warning("Emergency shuttle is broken.")

//Custom shuttles
/datum/shuttle/custom
	name = "custom shuttle"
	can_link_to_computer = LINK_FREE

/datum/shuttle/proc/show_outline(var/mob/user, var/turf/centered_at)
	if(!user)
		return

	if(!centered_at)
		var/turf/user_turf = get_turf(user)
		if(!user_turf)
			to_chat(user, "You must be standing on a turf!")
			return

		centered_at = get_step(user_turf,usr.dir)

	var/turf/original_center = get_turf(linked_port)

	if(!centered_at)
		to_chat(user, "ERROR: Unable to find center turf!")
		return

	var/offsetX = centered_at.x - original_center.x
	var/offsetY = centered_at.y - original_center.y
	var/datum/coords/offset = new(offsetX,offsetY)

	var/rotate = dir2angle(turn(user.dir,180)) - dir2angle(linked_port.dir)

	var/list/original_coords = list()
	for(var/turf/T in linked_area.contents)
		var/datum/coords/C = new(T.x,T.y)
		original_coords += C

	var/list/new_coords = list()

	var/cosine	= cos(rotate)
	var/sine	= sin(rotate)

	for(var/datum/coords/C in original_coords)
		var/datum/coords/NC = C.add(offset)
		new_coords += NC

		if(rotate)
			var/newX = (cosine	* (NC.x_pos - centered_at.x))	+ (sine		* (NC.y_pos - centered_at.y))	+ centered_at.x
			var/newY = -(sine	* (NC.x_pos - centered_at.x))	+ (cosine	* (NC.y_pos - centered_at.y))	+ centered_at.y

			NC.x_pos = newX
			NC.y_pos = newY

	var/list/images = list()
	for(var/datum/coords/C in new_coords)
		var/turf/T = locate(C.x_pos,C.y_pos,centered_at.z)
		if(!T)
			continue

		var/image/I = image('icons/turf/areas.dmi', icon_state="bluenew")
		I.loc = T
		images += I
		user << I

	var/image/center_img = image('icons/turf/areas.dmi', icon_state="blue") //This is actually RED, honk
	center_img.loc = centered_at
	images += center_img
	user << center_img

	alert(usr,"Press \"Ok\" to remove the images","Magic","Ok")

	if(usr.client)
		for(var/image/I in images)
			usr.client.images -= I
	return

//Throws people off a shuttle back into the station
/datum/shuttle/proc/eject_mobs(var/harder = FALSE)
	var/turf/initial_turf
	var/turf/target_turf
	if(!harder)
		initial_turf = get_step(get_turf(linked_port), opposite_dirs[linked_port.dir])
		target_turf = get_ranged_target_turf(initial_turf, linked_port.dir, 10)

		// Open any doors along the ejection path
		var/turf/check_turf = initial_turf
		var/safety = 0
		var/list/doors_to_open = list()
		while(check_turf)
			for(var/obj/machinery/door/D in check_turf)
				doors_to_open += D
			if(check_turf == target_turf)
				break
			check_turf = get_step(check_turf, linked_port.dir)
			safety++
			if(safety > 12)
				break

		for(var/obj/machinery/door/D in doors_to_open)
			D.open()

	var/list/mobs_to_eject = get_occupants(TRUE)

	if(harder)
		var/obj/structure/inflatable/shelter/S = new(get_turf(linked_port))
		for(var/mob/living/M in mobs_to_eject)
			M.anchored = FALSE
			M.forceMove(S)
			to_chat(M, "<span class='warning'>\The [src] has ejected you!</span>")
		S.ThrowAtStation()
	else
		for(var/mob/living/M in mobs_to_eject)
			M.anchored = FALSE
			M.forceMove(initial_turf)
			M.throw_at(target_turf, rand(5,10), 2)
			M.Knockdown(3)
			to_chat(M, "<span class='warning'>\The [src] has ejected you!</span>")

/datum/shuttle/proc/get_docking_port_offset()
	if(!linked_port)
		return null

	var/low_x = world.maxx
	var/low_y = world.maxy

	for(var/turf/T in linked_area)
		if(T.x < low_x)
			low_x = T.x
		if(T.y < low_y)
			low_y = T.y

	var/offset_x = linked_port.x - low_x
	var/offset_y = linked_port.y - low_y

	return list(offset_x, offset_y)

/datum/shuttle/proc/update_appearance(obj/item/O, mob/user)
	if(!O || !user)
		return
	var/obj/item/device/shuttle_holopainter/sam = O
	if(!istype(sam))
		return
	if(sam.emagged)
		for(var/turf/simulated/wall/shuttle/W in linked_area)
			W.walltype = "swall"
			W.relativewall()
			W.color = "#ff00dd"
		for(var/obj/structure/shuttle/diag_wall/WD in linked_area)
			WD.icon_state = "diagonalWallS"
			WD.color = "#ff00dd"
		for(var/turf/simulated/floor/shuttle/F in linked_area)
			F.icon_state = "clown"
		return
	if(sam.target == "Walls")
		var/used_walltype
		switch(sam.preset)
			if("White Smoothed")
				used_walltype = "swall"
			if("Black Smoothed")
				used_walltype = "bswall"
			if("White Unsmoothed")
				used_walltype = "wall1"
			if("Black Unsmoothed")
				used_walltype = "wall3"
			if("Syndicate")
				used_walltype = "satwall"
			if("Layered")
				used_walltype = "vwall"
			else
				used_walltype = "swall"
		for(var/turf/simulated/wall/shuttle/W in linked_area)
			W.walltype = used_walltype
			W.relativewall()
			if(sam.sel_color)
				W.color = sam.sel_color
		for(var/obj/structure/shuttle/diag_wall/WD in linked_area)
			if(sam.sel_color)
				if(istype(WD,/obj/structure/shuttle/diag_wall/smooth))
					WD.icon_state = "diagonalWallS"
				else
					WD.icon_state = "diagonalWall"
				WD.color = sam.sel_color
			else
				switch(sam.preset)
					if("White Smoothed")
						used_walltype = "diagonalWallS"
					if("Black Smoothed")
						used_walltype = "diagonalWall3S"
					if("White Unsmoothed")
						used_walltype = "diagonalWall"
					if("Black Unsmoothed")
						used_walltype = "diagonalWall3"
					if("Syndicate")
						used_walltype = "diagonalWall3"
					if("Layered")
						used_walltype = "vwall"
					else
						used_walltype = "diagonalWallS"
				WD.icon_state = used_walltype
	else if(sam.target == "Floors")
		var/used_floortype
		switch(sam.preset)
			if("White")
				used_floortype = "floor3"
			if("Blue")
				used_floortype = "floor"
			if("Yellow")
				used_floortype = "floor2"
			if("Red")
				used_floortype = "floor4"
			if("Purple")
				used_floortype = "floor5"
			if("Plated")
				used_floortype = "vfloor"
			if("Cult")
				used_floortype = "cult"
			else
				used_floortype = "floor_recolor"

		for(var/turf/simulated/floor/shuttle/F in linked_area)
			F.icon_state = used_floortype
			if(sam.sel_color)
				F.color = sam.sel_color
	else
		for(var/turf/simulated/floor/shuttle/F in linked_area)
			F.icon_state = initial(F.icon_state)
			F.color = initial(F.color)
		for(var/turf/simulated/wall/shuttle/W in linked_area)
			W.walltype = initial(W.walltype)
			W.update_icon()
			W.color = initial(W.color)
		for(var/obj/structure/shuttle/diag_wall/WD in linked_area)
			WD.icon_state = initial(WD.icon_state)
			WD.color = initial(WD.color)

//Planetary landing zone datum
/datum/landing_zone
	var/list/turf/turf_list = list()
	var/datum/weakref/shuttle_ref
	var/datum/weakref/planet_ref
	var/datum/virtual_z/vz
	var/obj/docking_port/destination/planet_surface/docking_port
	var/min_x = 0
	var/min_y = 0
	var/max_x = 0
	var/max_y = 0
	var/port_x = 0
	var/port_y = 0

/datum/landing_zone/New(var/datum/shuttle/shuttle, var/datum/planet_type/planet)
	. = ..()
	if(!shuttle || !planet)
		qdel(src)
		return

	if(!shuttle.linked_port || !shuttle.linked_area)
		qdel(src)
		return

	vz = planet.v
	if(!vz)
		qdel(src)
		return

	shuttle_ref = makeweakref(shuttle)
	planet_ref = makeweakref(planet)

	var/list/size = shuttle.get_size()
	if(!size)
		qdel(src)
		return

	var/width = size[1]
	var/height = size[2]

	var/list/landing_info = find_landing_location(shuttle, width, height)
	if(!landing_info)
		qdel(src)
		return

	var/turf/bottom_left = landing_info["bottom_left"]
	min_x = bottom_left.x
	min_y = bottom_left.y
	max_x = bottom_left.x + width - 1
	max_y = bottom_left.y + height - 1
	var/turf/port_turf = landing_info["port_turf"]
	port_x = port_turf.x
	port_y = port_turf.y
	var/port_dir = landing_info["port_dir"]

	// Populate turf list
	turf_list = block(locate(min_x, min_y, vz.z()), locate(max_x, max_y, vz.z()))

	// Create the docking port
	docking_port = new(port_turf)
	docking_port.dir = port_dir
	docking_port.areaname = "[planet.planet_name] surface"
	docking_port.planet = planet

	if(planet.default_baseturf)
		docking_port.base_turf_type = planet.default_baseturf

/datum/landing_zone/proc/update_turfs()
	turf_list = block(locate(min_x, min_y, vz.z()), locate(max_x, max_y, vz.z()))

/datum/landing_zone/proc/find_landing_location(var/datum/shuttle/shuttle, var/x_dim, var/y_dim)
	if(!shuttle?.linked_port || !vz)
		return null

	var/list/search_turfs = vz.get_turfs()

	var/list/offsets = shuttle.get_docking_port_offset()
	if(!offsets || offsets.len < 2)
		return null
	var/port_offset_x = offsets[1]
	var/port_offset_y = offsets[2]

	// Create matrix with relative coordinates
	var/list/turf_matrix = list()
	for(var/turf/T in search_turfs)
		var/rel_x = T.x - vz.x_min + 1
		var/rel_y = T.y - vz.y_min + 1
		var/key = "[rel_x],[rel_y]"
		turf_matrix[key] = T

	// Define safe zone boundaries (accounting for edge buffer and shuttle size)
	var/safe_x_min = LANDING_ZONE_EDGE_BUFFER + 1
	var/safe_x_max = vz.size_x - LANDING_ZONE_EDGE_BUFFER - x_dim + 1
	var/safe_y_min = LANDING_ZONE_EDGE_BUFFER + 1
	var/safe_y_max = vz.size_y - LANDING_ZONE_EDGE_BUFFER - y_dim + 1

	if(safe_x_max < safe_x_min || safe_y_max < safe_y_min)
		return // Not enough space for safe landing

	// Create randomized search list within safe boundaries
	var/list/search_positions = list()
	for(var/rel_x = safe_x_min; rel_x <= safe_x_max; rel_x++)
		for(var/rel_y = safe_y_min; rel_y <= safe_y_max; rel_y++)
			var/key = "[rel_x],[rel_y]"
			if(!turf_matrix[key])
				continue
			var/turf/T = turf_matrix[key]
			if(T && !iswall(T) && !istype(T, /turf/unsimulated/mineral) && istype(T.loc, /area/planet) && !istype(T, /turf/unsimulated/beach/water) && !istype(T,/turf/unsimulated/floor/planetary/lava))
				search_positions += T

	// Shuffle the search positions for randomization
	if(!search_positions.len)
		return null
	search_positions = shuffle(search_positions)

	// Search through randomized positions
	for(var/turf/T in search_positions)
		var/rel_x = T.x - vz.x_min + 1
		var/rel_y = T.y - vz.y_min + 1
		var/found = TRUE

		for(var/dx = 0; dx < x_dim && found; dx++)
			for(var/dy = 0; dy < y_dim && found; dy++)
				var/check_x = rel_x + dx
				var/check_y = rel_y + dy
				if(check_x < 1 || check_x > vz.size_x || check_y < 1 || check_y > vz.size_y) // Out of sector bounds
					found = FALSE
					continue
				var/check_key = "[check_x],[check_y]"
				if(!turf_matrix[check_key]) // Check if turf exists at this coordinate
					found = FALSE
					continue
				var/turf/target = turf_matrix[check_key]
				if(!target || !istype(target, T.type))
					found = FALSE

		if(found)
			// Calculate the destination docking port position
			var/port_x = T.x + port_offset_x
			var/port_y = T.y + port_offset_y
			var/turf/port_base_turf = locate(port_x, port_y, vz.z())
			var/turf/port_turf = get_step(port_base_turf, shuttle.linked_port.dir)

			// The destination port direction is opposite to the shuttle's port direction
			var/port_dir = turn(shuttle.linked_port.dir, 180)

			return list("bottom_left" = T, "port_turf" = port_turf, "port_dir" = port_dir)

/datum/landing_zone/proc/spawn_warnings()
	clear_warnings()
	for(var/turf/T in turf_list)
		var/is_corner = is_corner_turf(T)
		new /obj/effect/landing_zone(T, corner = is_corner)

/datum/landing_zone/proc/clear_warnings()
	update_turfs()
	for(var/turf/T in turf_list)
		for(var/obj/effect/landing_zone/overlay in T)
			qdel(overlay)

/datum/landing_zone/proc/reset_turfs()
	var/datum/climate/C = SSweather.get_climate(vz)
	for(var/turf/T in turf_list)
		C?.register_weather_turf(T, TRUE)
		var/area/A = T.loc
		if(isopensurface(A))
			vz.daynight_turfs |= T
	if(turf_list.len && vz)
		SSDayNight.update_turf_lighting(turf_list, vz)

/datum/landing_zone/proc/is_corner_turf(var/turf/T)
	if(!turf_list.len || !T)
		return FALSE

	var/min_x = world.maxx
	var/max_x = 0
	var/min_y = world.maxy
	var/max_y = 0

	for(var/turf/check in turf_list)
		if(check.x < min_x) min_x = check.x
		if(check.x > max_x) max_x = check.x
		if(check.y < min_y) min_y = check.y
		if(check.y > max_y) max_y = check.y

	return (T.x == min_x || T.x == max_x) && (T.y == min_y || T.y == max_y)

/datum/landing_zone/Destroy()
	clear_warnings()
	if(docking_port)
		qdel(docking_port)
		docking_port = null
	turf_list = null
	shuttle_ref = null
	planet_ref = null
	return ..()

#undef INIT_SUCCESS
#undef INIT_NO_AREA
#undef INIT_NO_PORT
#undef INIT_NO_START
