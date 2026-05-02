/obj/machinery/door/unpowered
	autoclose = 0
	var/locked = 0


/obj/machinery/door/unpowered/Bumped(atom/AM)
	if(locked)
		return

	..(AM)
	return

/obj/machinery/door/unpowered/attackby(obj/item/I as obj, mob/user as mob)
	// TODO: is energy blade only attack circuity like emag?
	if (!locked)
		..()

/obj/machinery/door/unpowered/emag_check(obj/item/weapon/card/emag/E, mob/user)
	return FALSE

/obj/machinery/door/unpowered/attack_hand(mob/user as mob)
	if(istype(user,/mob/dead/observer))
		return

	if(locked)
		return

	..()

/obj/machinery/door/unpowered/shuttle
	icon = 'icons/obj/doors/shuttle.dmi'
	icon_state = "door_closed"
	animation_delay = 7

	explosion_block = 1

	makes_noise = 1

/obj/machinery/door/unpowered/shuttle/cultify()
	new /obj/machinery/door/mineral/wood(loc)
	..()
