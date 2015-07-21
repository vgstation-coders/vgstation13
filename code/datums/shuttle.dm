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

	var/list/docking_ports = list() //List of ALL docking ports the shuttle can move to

	var/area/linked_area //the area which contains the docking port and which is moved

	var/obj/structure/docking_port/shuttle/linked_port

	var/obj/structure/docking_port/destination/current_port //where we are at now

	var/obj/structure/docking_port/destination/transit_port //transit port

	var/obj/structure/docking_port/destination/destination_port //where we are moving

	var/use_transit = TRANSIT_ACROSS_Z_LEVELS

	var/dir = NORTH //Direction of the shuttle

	var/movement_delay = 100//If there's no transit port, this is the time it takes for the shuttle to depart
							//If there is a transit port, this is the time the shuttle spends in it
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

/datum/shuttle/proc/can_move()
	if(lockdown)
		return 0
	if(last_moved + cooldown < world.time)
		return 1

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
	return 0

//Used in computers. The vox skipjack uses this proc to check if the target area is the starting one (as moving to it ends the round) and asks the user for confirmation
//Closes doors
/datum/shuttle/proc/close_all_doors()
	for(var/obj/machinery/door/unpowered/shuttle/D in linked_area)
		spawn(0)
			D.close()
//Opens doors
/datum/shuttle/proc/open_all_doors()
	for(var/obj/machinery/door/unpowered/shuttle/D in linked_area)
		spawn(0)
			D.open()

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