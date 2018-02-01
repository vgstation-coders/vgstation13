#define CLOCK_AIRLOCK_CONVERT_COST 4
#define CLOCK_FLOOR_CONVERT_COST   1
#define CLOCK_WALL_CONVERT_COST    3

/datum/rcd_schematic/clock_door
	name = "Door"
	category = "Clockwork"

/datum/rcd_schematic/clock_door/attack(var/atom/A, var/mob/user)
	if(!istype(A, /turf))
		return TRUE
	if(locate(/obj/machinery/door/airlock/clockwork) in A)
		return "there is already a door on this spot!"
	to_chat(user, "Building door...")
	if(!do_after(user, A, 50))
		return TRUE
	if(master.get_energy(user) < energy_cost)
		return TRUE
	if(locate(/obj/machinery/door/airlock/clockwork) in A)
		return "there is already a door on this spot!"
	playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)
	new/obj/machinery/door/airlock/clockwork(A)

/datum/rcd_schematic/clock_convert
	name = "Convert"
	category = "Clockwork"

	flags = RCD_SELF_COST

/datum/rcd_schematic/clock_convert/attack(var/atom/A, var/mob/user)

	if(istype(A, /obj/machinery/door/airlock)) // Convert an airlock.
		if(master.get_energy(user) < CLOCK_AIRLOCK_CONVERT_COST)
			return TRUE
		var/obj/machinery/door/D = A
		to_chat(user, "Converting [D.name]...")
		if(!do_after(user, D, 50))
			return TRUE
		if(master.get_energy(user) < CLOCK_AIRLOCK_CONVERT_COST)
			return TRUE
		playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)
		D.clockify()
		master.use_energy(CLOCK_AIRLOCK_CONVERT_COST, user)
		return FALSE

	else if(istype(A, /turf/simulated/floor) && !istype(A, /turf/simulated/floor/engine/clockwork)) // Convert the floor, instant.
		if(master.get_energy(user) < CLOCK_FLOOR_CONVERT_COST)
			return TRUE
		var/turf/simulated/floor/T = A
		to_chat(user, "Converting [T.name]...")
		playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)
		T.clockify()
		master.use_energy(CLOCK_FLOOR_CONVERT_COST, user)
		return FALSE

	else if(istype(A, /turf/simulated/wall) && !istype(A, /turf/simulated/wall/clockwork)) // Convert the obvious thing.
		if(master.get_energy(user) < CLOCK_WALL_CONVERT_COST)
			return TRUE
		var/turf/simulated/wall/W = A
		to_chat(user, "Converting [W.name]...")
		if(!do_after(user, W, 50))
			return TRUE
		if(master.get_energy(user) < CLOCK_WALL_CONVERT_COST)
			return TRUE
		W.clockify()
		master.use_energy(CLOCK_WALL_CONVERT_COST, user)
		return FALSE

	return TRUE

/datum/rcd_schematic/con_floors/clockwork
	category = "Clockwork"
	floor_type = /turf/simulated/floor/engine/clockwork

/datum/rcd_schematic/con_walls/clockwork
	category = "Clockwork"
	wall_type = /turf/simulated/wall/clockwork