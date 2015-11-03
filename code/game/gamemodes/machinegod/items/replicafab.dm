#define CLOCK_AIRLOCK_CONVERT_COST	4
#define CLOCK_FLOOR_CONVERT_COST	1
#define CLOCK_WALL_CONVERT_COST		3

/obj/item/device/rcd/replicafab
	name = "\improper Replicant Fabricator"
	desc = "A weird clockwork device that looks similar to an RCD."

	icon = 'icons/obj/clockwork/items.dmi'
	icon_state = "replicafab"

	var/metal_amt = 0
	var/max_metal = 50

	schematics = list(
		/datum/rcd_schematic/clock_door,
		/datum/rcd_schematic/clock_convert,
		/datum/rcd_schematic/con_floors/clockwork,
		/datum/rcd_schematic/con_walls/clockwork
	)

/obj/item/device/rcd/replicafab/attack_self(var/mob/user)
	if(!isclockcult(user))
		if(iscult(user))
			user << "<span class='clockwork'>Hands off, dog.</span>" // Fuck you bloodcult.
			if(isliving(user))
				var/mob/living/M = user
				M.apply_damage(10, BURN)
			return

		user << "You have no idea what this thing is!"
		return

	return ..()

/obj/item/device/rcd/replicafab/attackby(var/obj/item/W, var/mob/user)
	if(istype(W, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = W
		var/amount = min(max_metal - metal_amt, M.amount)
		metal_amt += amount
		M.use(amount)

		user << "<span class='notice'>You insert [amount] sheets of metal into \the [src].</span>"
		return 1

	. = ..()

/obj/item/device/rcd/replicafab/get_energy(var/mob/user)
	return metal_amt

/obj/item/device/rcd/replicafab/use_energy(var/amount, var/mob/user)
	metal_amt -= amount

// SCHEMATICS

/datum/rcd_schematic/clock_door
	name = "Door"
	category = "Clockwork"

/datum/rcd_schematic/clock_door/attack(var/atom/A, var/mob/user)
	if(!istype(A, /turf))
		return 1

	if(locate(/obj/machinery/door/clockcult) in A)
		return "there is already a door on this spot!"

	user << "Building door..."

	if(!do_after(user, A, 50))
		return 1

	if(master.get_energy(user) < energy_cost)
		return 1

	if(locate(/obj/machinery/door/clockcult) in A)
		return "there is already a door on this spot!"

	playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)

	new/obj/machinery/door/clockcult(A)

/datum/rcd_schematic/clock_convert
	name = "Convert"
	category = "clockwork"

	flags = RCD_SELF_COST
	
/datum/rcd_schematic/clock_convert/attack(var/atom/A, var/mob/user)
	if(istype(A, /obj/machinery/door/airlock)) // Convert an airlock.
		if(master.get_energy(user) < CLOCK_AIRLOCK_CONVERT_COST)
			return 1

		user << "Converting door..."

		if(!do_after(user, A, 50))
			return 1

		if(master.get_energy(user) < CLOCK_AIRLOCK_CONVERT_COST)
			return 1

		playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)
			
		new/obj/machinery/door/clockcult(A.loc)
		qdel(A) // Make a new door.
			
		master.use_energy(CLOCK_AIRLOCK_CONVERT_COST, user)
		return 0

	else if(istype(A, /turf/simulated/floor) && !istype(A, /turf/simulated/floor/clockcult)) // Convert the floor, instant.
		if(master.get_energy(user) < CLOCK_FLOOR_CONVERT_COST)
			return 1

		var/turf/simulated/floor/T = A

		user << "Converting floor..."

		playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)

		T.ChangeTurf(/turf/simulated/floor/clockcult)

		master.use_energy(CLOCK_FLOOR_CONVERT_COST, user)
		return 0

	else if(istype(A, /turf/simulated/wall) && !istype(A, /turf/simulated/wall/clockcult)) // Convert the obvious thing.
		if(master.get_energy(user) < CLOCK_WALL_CONVERT_COST)
			return 1
			
		var/turf/simulated/wall/T = A

		user << "Converting wall..."

		if(!do_after(user, A, 50))
			return 1

		if(master.get_energy(user) < CLOCK_WALL_CONVERT_COST)
			return 1

		T.ChangeTurf(/turf/simulated/wall/clockcult)
		master.use_energy(CLOCK_WALL_CONVERT_COST, user)
		return 0

	return 1

/datum/rcd_schematic/con_floors/clockwork
	category = "clockwork"
	floor_type = /turf/simulated/floor/clockcult/airless

/datum/rcd_schematic/con_walls/clockwork
	category = "clockwork"
	wall_type = /turf/simulated/wall/clockcult