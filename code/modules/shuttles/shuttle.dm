#define NO_TRANSIT 0 //Don't use transit areas
#define TRANSIT_ACROSS_Z_LEVELS 1 //Only use transit areas if moving to another z-level
#define TRANSIT_ALWAYS 2 //Always use transit areas

//Whether this shuttle can be linked to a shuttle control console.
#define LINK_FREE 0
#define LINK_PASSWORD_ONLY 1
#define LINK_FORBIDDEN 2

//Whether the shuttle destroys stuff it collides with, or displaces it
#define COLLISION_DESTROY 0
#define COLLISION_DISPLACE 1

//One of these values is returned at initialize()
#define INIT_SUCCESS	1 //everything is good
#define INIT_NO_AREA	2 //can't find starting area
#define INIT_NO_PORT	3 //can't find shuttle's docking port
#define INIT_NO_START	4 //shuttle's docking port isn't connected to a destination port

/datum/shuttle
	var/name = "shuttle"

	var/list/docking_ports = list() //All ports the shuttle can move to
	var/list/docking_ports_aboard = list() //Exists to prevent from moving directly onto an outside docking port then taking it away
	
	var/area/linked_area //The main, linked area
	
	var/obj/docking_port/shuttle/linked_port //The main, linked port in the linked_area
	var/obj/docking_port/destination/current_port //Current port
	var/obj/docking_port/destination/transit_port //Used for Z2 travel
	var/obj/docking_port/destination/destination_port //Destination port

	var/transit_method = TRANSIT_ACROSS_Z_LEVELS

	var/can_rotate = 1

	var/pre_flight_delay = 50 //Delay before takeoff
	var/transit_delay = 100 //Travel time in Z2

	var/list/cant_leave_zlevel = list(
		/obj/item/weapon/disk/nuclear = "The nuclear authentication disk can't be transported on a shuttle.",
	)

	var/moving = 0
	var/last_moved = 0
	var/cooldown = 100
	var/dir = NORTH
	
	var/innacuracy = 0 //Random offset of range (-inaccuracy,inaccuracy) in x and y
	var/stable = 0 //Whether all mobs are stunned on movement

	var/collision_type = COLLISION_DESTROY //Alternative: COLLISION_DISPLACE
	var/destroy_everything = 0
	
	var/list/control_consoles = list()
	var/list/req_access = list()
	var/password = null //Unused
	var/can_link_to_computer = LINK_FORBIDDEN
	
	var/lockdown = 0


/datum/shuttle/New(var/area/starting_area)
	. = ..()

	if(starting_area)
		if(ispath(starting_area))
			linked_area = locate(starting_area)
		else if(isarea(starting_area))
			linked_area = starting_area
		else
			linked_area = starting_area
			warning("Unable to find area [starting_area] in world - [src.type] ([src.name]) won't be able to function properly.")

	if(istype(linked_area) && linked_area.contents.len) //Only add the shuttle to the list if its area exists and it has something in it
		shuttles |= src
	if(password)
		password = rand(10000,99999)

//Setup on creation. Returns INIT_SUCCESS, INIT_NO_AREA, INIT_NO_START or INIT_NO_PORT.
/datum/shuttle/proc/initialize()
	. = INIT_SUCCESS
	src.docking_ports = list()
	src.docking_ports_aboard = list()
	src.transit_port = null

	if(!linked_area || !istype(linked_area))
		return INIT_NO_AREA

	var/obj/docking_port/shuttle/shuttle_docking_port
	for(var/obj/docking_port/shuttle/S in linked_area)
		shuttle_docking_port = S
		break

	if(shuttle_docking_port)
		if(linked_port)
			linked_port.unlink_from_shuttle(src)

		shuttle_docking_port.link_to_shuttle(src)

		var/turf/check_turf = shuttle_docking_port.get_docking_turf()
		if(check_turf)
			for(var/obj/docking_port/P in check_turf.contents)
				shuttle_docking_port.dock(P)
				src.current_port = shuttle_docking_port.docked_with
				break

		if(!src.current_port)
			. = INIT_NO_START

		src.dir = turn(linked_port.dir, 180)
	else
		. = INIT_NO_PORT


	for(var/obj/docking_port/D in linked_area)
		docking_ports_aboard |= D

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

//Shuttles like the emergency shuttle have this to prevent them from being deleted.
/datum/shuttle/proc/is_special()
	return 0

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

/datum/shuttle/proc/forbidden_item_check()
	var/atom/A = linked_area.contains_atom_from_list(cant_leave_zlevel)
	if(A)
		return A
	for(var/mob/living/M in get_contents_in_object(linked_area, /mob/living))
		if(M.locked_to_z && M.locked_to_z != destination_port.z)
			return M
	return 0

/datum/shuttle/proc/shuttle_message(var/message, var/obj/machinery/computer/shuttle_control/broadcast, var/mob/user)
	if(broadcast)
		broadcast.announce(message)
	else if(user)
		to_chat(user, message)




/datum/shuttle/proc/travel_to(var/obj/docking_port/destination, var/obj/machinery/computer/shuttle_control/broadcast = null, var/mob/user)
	if(!destination)
		return 0
	if(!linked_port)
		return 0

	if(destination_port)
		shuttle_message("The shuttle is already moving.", broadcast, user)
		return 0 //shuttle already travelling

	if(lockdown)
		shuttle_message("The shuttle is locked down.", broadcast, user)
		return 0

	if(!can_move())
		shuttle_message("The engines are still cooling down from the last trip.", broadcast, user)
		return 0

	if(destination.docked_with)
		shuttle_message("[capitalize(destination.areaname)] is currently used by another shuttle. Please wait until the docking port is free, or select another destination.", broadcast, user)
		return 0

	if(destination.require_admin_permission && !isAdminGhost(user))
		shuttle_message("Currently requesting Centcomm permission to reach [destination.areaname]...", broadcast, user)
		var/reason = input(user, "State your reasons for wanting to dock at [destination.areaname].", "Docking Request", "")
		message_admins("[key_name(user)] is requesting permission to fly their [name] to [destination.areaname]. [reason ? "Reason:[reason]" : "They didn't give a reason"]. (<a href='?_src_=holder;shuttlepermission=1;shuttle=\ref[src];docking_port=\ref[destination];broadcast=\ref[broadcast];user=\ref[user];answer=1'>ACCEPT</a>/<a href='?_src_=holder;shuttlepermission=1;shuttle=\ref[src];docking_port=\ref[destination];broadcast=\ref[broadcast];user=\ref[user];answer=0'>DENY</a>)")
	
	else
		begin_travel_routine(destination, broadcast, user)

/datum/shuttle/proc/begin_travel_routine(var/obj/docking_port/destination, var/obj/machinery/computer/shuttle_control/broadcast = null, var/mob/user)
	if(broadcast)
		broadcast.announce("The shuttle has received your message and will be sent in [round(get_pre_flight_delay()/10)] second[get_pre_flight_delay() == 1 ? "" : "s"].")

	destination_port = destination
	last_moved = world.time
	moving = 1

	log_game("[user ? key_name(user) : "Something"] sent [name] ([type]) to [destination_port.areaname]")
	
	if(current_port)
		current_port.start_warning_lights()
	destination_port.start_warning_lights()
	
	spawn(max(1,get_pre_flight_delay()-5))
		for(var/obj/structure/shuttle/engine/propulsion/P in linked_area)
			spawn()
				P.shoot_exhaust()

	spawn(get_pre_flight_delay())
		if(current_port)
			current_port.stop_warning_lights()
		if(destination_port)
			destination_port.stop_warning_lights()

		if(linked_port.z != destination_port.z)
			var/atom/forbidden = forbidden_item_check()
			if(forbidden) //Illegal item check
				if(cant_leave_zlevel[forbidden.type])
					if(broadcast)
						broadcast.announce("ERROR: [cant_leave_zlevel[forbidden.type]]")
					else if(user)
						to_chat(user, cant_leave_zlevel[forbidden.type])
				else
					if(broadcast)
						broadcast.announce("ERROR: [forbidden.name] is preventing the shuttle from departing.")
					else if(user)
						to_chat(user, "[forbidden.name] is preventing the shuttle from departing.")
				moving = 0
				destination_port = null
				return 0
			for(var/atom/A in linked_area) //Z-level travel effect
				INVOKE_EVENT(A.on_z_transition, list("user" = A, "to_z" = destination_port.z, "from_z" = linked_port.z))

		if(transit_port && get_transit_delay())
			shuttle_message("The shuttle has departed and is now moving towards [destination.areaname].", broadcast, user)
		else
			shuttle_message("The shuttle has arrived at [destination.areaname].", broadcast, user)

		pre_flight()
	return 1

/datum/shuttle/proc/pre_flight()
	if(!destination_port)
		return

	if(transit_port && get_transit_delay())
		if(transit_method == TRANSIT_ALWAYS || (transit_method == TRANSIT_ACROSS_Z_LEVELS && (linked_area.z != destination_port.z)))
			move_to_dock(transit_port)
			spawn(max(1,get_transit_delay()-5))
				for(var/obj/structure/shuttle/engine/propulsion/P in linked_area)
					spawn()
						P.shoot_exhaust()
			sleep(get_transit_delay())

	if(destination_port)
		move_to_dock(destination_port)
		destination_port = null

	moving = 0

/datum/shuttle/proc/after_flight()
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
				
				
				
/datum/shuttle/proc/move_to_dock(var/obj/docking_port/D, var/ignore_innacuracy = 0) //A direct proc with no bullshit
	if(!D)
		return
	if(!linked_port)
		return

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

/datum/shuttle/proc/collide(var/atom/movable/AM as mob|obj)
	AM.shuttle_act(src)



/datum/shuttle/proc/supercharge()
	cooldown = 0
	pre_flight_delay = 0
	transit_delay = 0



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
			if(get_area(src) == linked_area)
				occupants.Add(L)
	return occupants

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

	var/area/space

	space = get_space_area()
	if(!space)
		warning("Unable to find space area for shuttle [src.type]")

	//Make a list of coordinates of turfs to move, and associate the coordinates with the turfs they represent
	var/list/turfs_to_move = list()

	//Now here's the dumb part - since there's no fast way I know to check if a coord datum has a coord datum with the same values in a list,
	//this coordinates list stores every coordinate of a moved turf as a string (example: "52;61").
	var/list/our_own_turfs = list()

	//Go through all turfs in our area
	for(var/turf/T in linked_area.get_turfs())
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
		else if(old_turf.preserve_underlay == 0 && istype(old_turf,/turf/simulated/shuttle/wall)) //Varediting a turf's "preserve_underlay" to 1 will protect its underlay from being changed
			if(old_turf.icon_state in transparent_icons)
				add_underlay = 1
				if(old_turf.underlays.len) //this list is in code/game/area/areas.dm
					var/image/I = locate(/image) in old_turf.underlays //bandaid
					if(I.icon == 'icons/turf/shuttle.dmi') //Don't change underlay to space if CURRENT underlay is a shuttle floor!
						add_underlay = 0

		if(!new_turf)
			message_admins("ERROR when moving [src.name] ([src.type]) - failed to get new turf at [C.x_pos];[C.y_pos];[new_center.z]")
			continue

		var/turf/displace_to = locate(C.x_pos,throwy,new_center.z)
		for(var/atom/movable/AM as mob|obj in new_turf.contents)
			if(AM.anchored || src.collision_type == COLLISION_DESTROY)
				src.collide(AM)
			else
				AM.forceMove(displace_to)

		var/area/old_area = get_area(new_turf)
		if(!old_area)
			old_area = space

		//Get the turf's image before it's gone!
		var/image/undlay
		if(add_underlay)
			undlay = image("icon"=new_turf.icon,"icon_state"=new_turf.icon_state,"dir"=new_turf.dir)
			undlay.overlays = new_turf.overlays

		//****Add the new turf to shuttle's area****

		linked_area.contents.Add(new_turf)
		new_turf.change_area(old_area,linked_area)
		new_turf.ChangeTurf(old_turf.type, allow = 1)
		new_turfs[C] = new_turf

		//***Remove old turf from shuttle's area****

		space.contents.Add(old_turf)
		old_turf.change_area(linked_area,space)

		//All objects which can't be moved by the shuttle have their area changed to space!
		for(var/atom/movable/AM in old_turf.contents)
			if(!AM.can_shuttle_move(src))
				AM.change_area(linked_area,space)

		//****Move all variables from the old turf over to the new turf****

		for(var/key in old_turf.vars)
			if(key in ignored_keys)
				continue
			//ignored_keys: code/game/area/areas.dm, 526 (above the move_contents_to proc)
			//as of 06/08/2015: list("loc", "locs", "parent_type", "vars", "verbs", "type", "x", "y", "z","group","contents","air","light","areaMaster","underlays","lighting_overlay")
			if(istype(old_turf.vars[key],/list))
				var/list/L = old_turf.vars[key]
				new_turf.vars[key] = L.Copy()
			else if(old_turf.vars)
				new_turf.vars[key] = old_turf.vars[key]
		if(old_turf.transform)
			new_turf.transform = old_turf.transform

		//****Prepare underlays**** (only do this if add_underlay is 1 -> see above)
		if(add_underlay && undlay)
			new_turf.underlays = list(undlay) //Remove all old underlays, add space
		else
			new_turf.underlays = old_turf.underlays

		new_turf.dir = old_turf.dir
		new_turf.icon_state = old_turf.icon_state
		new_turf.icon = old_turf.icon
		if(rotate)
			new_turf.shuttle_rotate(rotate)

		//*****Move air*****

		var/turf/simulated/S_OLD = old_turf

		if(istype(S_OLD) && S_OLD.zone)
			var/turf/simulated/S_NEW = new_turf

			if(!S_NEW.air)
				S_NEW.make_air()

			S_NEW.air.copy_from(S_OLD.zone.air)
			S_OLD.zone.remove(S_OLD)

		//*****Move objects and mobs*****
		for(var/atom/movable/AM in old_turf)
			if(!AM.can_shuttle_move(src))
				continue

			if(AM.bound_width > WORLD_ICON_SIZE || AM.bound_height > WORLD_ICON_SIZE) //If the moved object's bounding box is more than the default, move it after everything else (using spawn())
				AM.forceMove(null) //Without this, ALL neighbouring turfs attempt to move this object too, resulting in the object getting shifted to north/east

				spawn()
					AM.forceMove(new_turf)

				//TODO: Make this compactible with bound_x and bound_y.
			else
				AM.forceMove(new_turf)

			if(rotate)
				AM.shuttle_rotate(rotate)

		//Move landmarks - for moving the arrivals shuttle
		for(var/list/L in moved_landmarks) //moved_landmarks: code/game/area/areas.dm, 527 (above the move_contents_to proc)
			if(old_turf in L)
				L -= old_turf
				L += new_turf

		//Add the new turf to the list of turfs to update
		turfs_to_update += new_turf

		//Delete the old turf
		var/replacing_turf_type = old_turf.get_underlying_turf()
		var/obj/docking_port/destination/D = linked_port.docked_with

		if(D && istype(D))
			replacing_turf_type = D.base_turf_type

		old_turf.ChangeTurf(replacing_turf_type, allow = 1)

		if(D && istype(D))
			if(D.base_turf_icon)
				old_turf.icon = D.base_turf_icon
			if(D.base_turf_icon_state)
				old_turf.icon_state = D.base_turf_icon_state

		if(istype(old_turf,/turf/space))
			old_turf.lighting_clear_overlay() //A horrible band-aid fix for lighting overlays appearing over space

	//Update doors
	if(turfs_to_update.len)
		for(var/turf/simulated/T1 in turfs_to_update)
			for(var/obj/machinery/door/D2 in T1)
				D2.update_nearby_tiles()

	return 1

/proc/setup_shuttles()
	world.log << "Setting up all shuttles..."

	var/all_count = 0
	var/count = 0
	for(var/datum/shuttle/S in shuttles)
		switch(S.initialize())
			if(INIT_NO_AREA)
				if(S.is_special())
					var/msg = S.linked_area ? "- \"[S.linked_area]\" was given as a starting area." : ""
					warning("Invalid or missing starting area for [S.name] ([S.type]) [msg]")
				else
					var/msg = S.linked_area ? "- \"[S.linked_area]\" was given as a starting area." : ""
					world.log << "Invalid or missing starting area for [S.name] ([S.type]) [msg]"
			if(INIT_NO_PORT)
				if(S.is_special())
					warning("Couldn't find a shuttle docking port for [S.name] ([S.type]).")
				else
					world.log << "Couldn't find a shuttle docking port for [S.name] ([S.type])."
			if(INIT_NO_START)
				if(S.is_special())
					warning("[S.name] ([S.type]) couldn't connect to a destination port on init - unless this is intended, there might be problems.")
				else
					world.log << "[S.name] ([S.type]) couldn't connect to a destination port on init - unless this is intended, there might be problems."
			else
				count++
		all_count++

	world.log << "[all_count] shuttles initialized, of them [count] were initialized properly."

	//THE MOST IMPORTANT PIECE OF CODE HERE
	emergency_shuttle.shuttle = escape_shuttle

	if(!emergency_shuttle || !emergency_shuttle.shuttle)
		warning("Emergency shuttle is broken.")
	else
		world.log << "Emergency shuttle has been successfully set up."

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
	for(var/turf/T in linked_area.get_turfs())
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

#undef INIT_SUCCESS
#undef INIT_NO_AREA
#undef INIT_NO_PORT
#undef INIT_NO_START
