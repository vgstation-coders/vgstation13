/datum/locking_category/cargocart
	flags = LOCKED_CAN_LIE_AND_STAND

/obj/machinery/cart/cargo
	name = "cargo cart"
	desc = "A cart for transporting crates. Designed to attach to a tractor."

/obj/machinery/cart/cargo/toboggan
	name = "toboggan"
	desc = "A toboggan designed to transport crates and injured crewmen through the snow. Designed to attach to a snowmobile."
	icon_state = "toboggan"

/obj/machinery/cart/cargo/relaymove(mob/user)
	unload()
	user.visible_message("<span class='warning'>[user] stumbles while trying to get off \the [src]</span>", \
						 "<span class='warning'>You stumble while trying to get off \the [src]. Be more careful next time.</span>")
	user.Knockdown(4)
	playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

/obj/machinery/cart/cargo/MouseDropTo(var/atom/movable/C, mob/user)
	..()
	if(user.incapacitated() || user.lying)
		return
	if(!Adjacent(user) || !user.Adjacent(src) || !src.Adjacent(C))
		return
	if (is_locking(/datum/locking_category/cargocart) || istype(C, /obj/machinery/cart/))
		return

	load(C)

/obj/machinery/cart/cargo/MouseDropFrom(obj/over_object as obj, src_location, over_location)
	..()
	var/mob/user = usr
	if (user.incapacitated() || !in_range(user, src) || !in_range(src, over_object))
		return
	if (!is_locking(/datum/locking_category/cargocart))
		return
	unload(over_object)


/obj/machinery/cart/cargo/proc/load(var/atom/movable/C)

	if (istype(C, /obj/abstract/screen))
		return FALSE
	if(!isturf(C.loc)) //To prevent the loading from stuff from someone's inventory, which wouldn't get handled properly.
		return FALSE

	if(C.locked_to || C.is_locking() || C.anchored)
		return FALSE

	if(get_dist(C, src) > 1 || is_locking(/datum/locking_category/cargocart))
		return FALSE


	if(istype(C,/obj/structure/closet/crate))
		var/obj/structure/closet/crate/crate = C
		crate.close()

	lock_atom(C, /datum/locking_category/cargocart)
	return TRUE

/obj/machinery/cart/cargo/proc/unload(var/dirn = 0)
	if(!is_locking(/datum/locking_category/cargocart))
		return

	var/atom/movable/load = get_locked(/datum/locking_category/cargocart)[1]
	unlock_atom(load)

	if(dirn)
		var/turf/T = src.loc
		T = get_step(T,dirn)
		if(Cross(load,T))
			step(load, dirn)
		else
			load.forceMove(src.loc)

	for(var/atom/movable/AM in src)
		AM.forceMove(src.loc)

/obj/machinery/cart/cargo/lock_atom(var/atom/movable/AM, var/datum/locking_category/category)
	. = ..()
	if(!.)
		return

	AM.layer = layer + 0.1
	AM.plane = plane
	AM.pixel_y += 9 * PIXEL_MULTIPLIER

/obj/machinery/cart/cargo/unlock_atom(var/atom/movable/AM, var/datum/locking_category/category)
	. = ..()
	if(!.)
		return

	AM.reset_plane_and_layer()
	AM.pixel_y = initial(AM.pixel_y)
