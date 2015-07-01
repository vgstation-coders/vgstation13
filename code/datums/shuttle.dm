#define NO_TRANSIT 0 //Don't use transit areas
#define TRANSIT_ACROSS_Z_LEVELS 1 //Only use transit areas if moving to another z-level
#define TRANSIT_ALWAYS 2 //Always use transit areas

#define LINK_FREE 0
#define LINK_PASSWORD_ONLY 1
#define LINK_FORBIDDEN 2

#define COLLISION_DESTROY 0
#define COLLISION_DISPLACE_IF_CAN 1 //this is same as COLLISION_DISPLACE as for now
#define COLLISION_DISPLACE 2

/datum/shuttle
	var/name = "shuttle"

	var/list/areas = list() //List of ALL areas the shuttle can move to

	var/area/current_area

	var/area/transit_area

	var/area/moving_to

	var/use_transit = TRANSIT_ACROSS_Z_LEVELS

	var/dir = NORTH //Direction of the shuttle

	var/movement_delay = 100//If there's no transit area, this is the time it takes for the shuttle to depart
							//If there is a transit area, this is the time the shuttle spends in it
							//To-do - separate time spent in transit and time it takes for the shuttle to depart

	var/moving = 0 //If the shuttle is currently moving

	var/list/cant_leave_zlevel = list(
		/obj/item/weapon/disk/nuclear = "The nuclear authentication disk can't be transported on a shuttle.",
		)

	var/last_moved = 0
	var/cooldown = 100

	var/password = 101
	var/can_link_to_computer = LINK_FORBIDDEN

	var/collision_type = COLLISION_DESTROY //Whether the shuttle gibs or displaces stuff
/*
	var/propulsions = 0
	var/heaters = 0
*/

	var/obj/machinery/computer/shuttle_core/core_computer
	var/list/control_consoles = list()

	var/lockdown = 0

/datum/shuttle/proc/get_movement_delay()
	return movement_delay

/datum/shuttle/proc/get_cooldown()
	return cooldown

/datum/shuttle/proc/has_defined_areas()
	return 0

/datum/shuttle/proc/can_move()
	if(lockdown)
		return 0
	if(last_moved + cooldown < world.time)
		return 1

/datum/shuttle/proc/setup_everything(var/starting_area, var/list/all_areas, var/transit_area, var/name = "shuttle", var/dir, var/cooldown = 0, var/delay = 100)
	src.current_area = locate(starting_area)
	if(!src.current_area)
		message_admins("<span class='notice'>Unable to find [starting_area] for a shuttle ([src.type]).</span>")
		qdel(src)
		return

	if(transit_area)
		src.transit_area = locate(transit_area)
		if(!src.transit_area)
			message_admins("<span class='notice'>Unable to locate [transit_area] for a shuttle ([src.type]).</span>")
			src.use_transit = NO_TRANSIT

	for(var/T in all_areas)
		var/area/A = locate(T)
		if(A)
			src.areas |= A
		else
			message_admins("<span class='notice'>Unable to locate [T] for a shuttle ([src.type]).</span>")

	src.name = name
	src.dir = dir
	src.cooldown = cooldown
	src.movement_delay = delay

	src.initialize()

/datum/shuttle/New()
	..()
	shuttles |= src

/datum/shuttle/Destroy()
	shuttles -= src
	..()

/datum/shuttle/proc/initialize()
	return

//Checks the shuttle for offending atoms
/datum/shuttle/proc/forbid_movement()
	var/atom/A = current_area.contains_atom_from_list(cant_leave_zlevel) //code/game/atoms.dm, 243
	if(A)
		return A
	return 0

//Used in computers. The vox skipjack uses this proc to check if the target area is the starting one (as moving to it ends the round) and asks the user for confirmation
/datum/shuttle/proc/travel_to(var/area/target_area, var/move_delay = null, var/mob/user)
	return start_movement(target_area, move_delay)

//Transit and delay before moving the shuttle, as well as some basic checks
/datum/shuttle/proc/start_movement(var/area/target_area, var/move_delay = null)
	if(!target_area) //If we're not provided an area, select a random one from the list of our areas
		target_area = pick(areas - current_area)

	if(!target_area in areas)
		return "Unknown area."

	if(target_area == current_area)
		return "The shuttle is already there."

	if(moving)
		return "The shuttle is currently moving."

	if(!move_delay)
		move_delay = get_movement_delay()

	if(last_moved + get_cooldown() > world.time)
		return "The shuttle isn't ready yet."

	if(target_area.z != current_area.z) //If moving to another zlevel, check for items which can't leave the zlevel (nuke disk)
		var/atom/A = forbid_movement()
		if( A )
			if(cant_leave_zlevel[A.type])
				return cant_leave_zlevel[A.type]
			else
				return "[A.name] is preventing the shuttle from departing."

	if(transit_area)
		switch(use_transit)
			if(TRANSIT_ACROSS_Z_LEVELS)
				if(target_area.z != current_area.z)
					complete_movement(transit_area)
			if(TRANSIT_ALWAYS)
				complete_movement(transit_area)
	moving = 1
	moving_to = target_area

	sleep(move_delay)

	complete_movement(target_area)

//Closes doors
/datum/shuttle/proc/close_all_doors()
	for(var/obj/machinery/door/unpowered/shuttle/D in current_area)
		spawn(0)
			D.close()
//Opens doors
/datum/shuttle/proc/open_all_doors()
	for(var/obj/machinery/door/unpowered/shuttle/D in current_area)
		spawn(0)
			D.open()

//Actually moves the shuttle, calls collide proc with things the shuttle collides with, etc.
/datum/shuttle/proc/complete_movement(var/area/target_area)
	if(!target_area || !target_area in areas)
		return

	for(var/turf/T in target_area)
		if(istype(T, /turf/simulated))
			qdel(T)

	if(collision_type != COLLISION_DESTROY)
		if(locate(/mob/living/) in target_area)
			sleep(50) //wait 5 seconds
			target_area.displace_contents()

	for(var/atom/movable/AM in target_area)
		collide(AM)

	current_area.move_contents_to(target_area, direction = src.dir)
	current_area = target_area

	for(var/atom/movable/AM in current_area)
		after_movement(AM)

	last_moved = world.time
	moving = 0
	moving_to = null

//Shakes cameras for mobs, will possibly throw stuff back in the future
/datum/shuttle/proc/after_movement(var/atom/movable/AM as mob|obj)
	if(istype(AM,/mob/living))
		var/mob/living/M = AM

		if(!M.buckled)
			shake_camera(M, 10, 1) // unbuckled, HOLY SHIT SHAKE THE ROOM
		else
			shake_camera(M, 3, 1) // buckled, not a lot of shaking
			if(istype(M, /mob/living/carbon))
				M.Weaken(3)

//Gibs or moves mobs and stuff
/datum/shuttle/proc/collide(var/atom/movable/AM as mob|obj)
	if(istype(AM,/mob/living))
		var/mob/living/M = AM

		M.gib()

	else
		qdel(AM)

//Fun proc ahead
//This creates an area of the same shape as the shuttle's current_area.
//Location is defined by new_area_center and my_area_center
//If 'force' variable is set to 1, the area can be created on top of other areas
//Returns a list of areas destroyed (if 'force' is 1)
/datum/shuttle/proc/add_area(var/turf/new_area_center, var/turf/shuttle_area_center, var/force = 0)
	var/list/destroyed_areas = list()
	//If shuttle's center of the area isn't provided, use its core location
	if(!shuttle_area_center)
		for(var/obj/machinery/computer/shuttle_core/C in current_area)
			if(C.shuttle == src)
				shuttle_area_center = get_turf(C)
	//If the shuttle's core isn't on the shuttle, get the control computer
	if(!shuttle_area_center)
		for(var/obj/machinery/computer/shuttle_control/C in current_area)
			if(C.shuttle == src)
				shuttle_area_center = get_turf(C)

	if(!shuttle_area_center)
		usr << "[capitalize(name)] must have either a connected control console, or a shuttle core computer aboard."
		return

	var/area/A = get_area(new_area_center)

	if(A.type != /area/ && !force) //not space
		usr << "This command can only be used in space, without any areas defined on the turf."
		return

	var/list/turfs_to_change = list()

	for(var/turf/T in current_area)
		var/newX = new_area_center.x + (T.x - shuttle_area_center.x)
		var/newY = new_area_center.y + (T.y - shuttle_area_center.y)
		var/turf/newT = locate(newX, newY, new_area_center.z)
		A = get_area(newT)
		if(A.type != /area/)
			if(!force)
				usr << "The resulting area would overlap with [A.name]. Ensure that there are no areas nearby, other than space."
				return
			else
				destroyed_areas |= A
		turfs_to_change |= newT

	var/new_name = input(usr, "Everything is going well! Input a name for the new area.","Admin abuse","[name] area [rand(100,999)]") as text

	var/area/shuttle/newarea = new
	var/area/oldarea = get_area(new_area_center)
	newarea.name = new_name
	newarea.tag = "[newarea.type]/[md5(new_name)]"
	newarea.lighting_use_dynamic = 0
	newarea.contents.Add(turfs_to_change)

	for(var/turf/T in turfs_to_change)
		if(force)
			oldarea = get_area(T)
		T.change_area(oldarea,newarea)
		for(var/atom/allthings in T.contents)
			allthings.change_area(oldarea,newarea)

	newarea.addSorted()

	src.areas |= newarea
	return destroyed_areas

//Returns a shuttle
/proc/select_shuttle_from_all(var/mob/user, var/message = "Select a shuttle", var/title = "Shuttle selection", var/list/omit_shuttles = null, var/show_lockdown = 0, var/show_cooldown = 0, var/show_core = 0)
	if(!user) return

	var/list/shuttle_list = list()
	for(var/datum/shuttle/S in shuttles)
		if(omit_shuttles)
			if(S.type in omit_shuttles) continue
			if(S in omit_shuttles) continue
			if(S.name in omit_shuttles) continue
		var/name = S.name
		if(show_core && !S.core_computer)
			name = "[name] (NO CORE)"
		if(show_lockdown && S.lockdown)
			name = "[name] (LOCKDOWN)"
		else
			if(show_cooldown && !S.can_move())
				name = "[name] (ON COOLDOWN)"
		shuttle_list += name
		shuttle_list[name]=S

	var/my_shuttle = input(usr, message, title) in shuttle_list as text|null

	if( my_shuttle && shuttle_list[my_shuttle] && istype(shuttle_list[my_shuttle], /datum/shuttle) )
		return shuttle_list[my_shuttle]

/datum/shuttle/custom
	name = "custom shuttle"

/datum/shuttle/custom/New()
	.=..()

#undef NO_TRANSIT
#undef TRANSIT_ACROSS_Z_LEVELS
#undef TRANSIT_ALWAYS
