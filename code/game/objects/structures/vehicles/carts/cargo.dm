/obj/machinery/cart/cargo
	name = "cargo cart"
	var/atom/movable/load = null

/obj/machinery/cart/cargo/MouseDropTo(var/atom/movable/C, mob/user)
	..()
	if(user.incapacitated() || user.lying)
		return
	if(!Adjacent(user) || !user.Adjacent(src) || !src.Adjacent(C))
		return
	if (load || istype(C, /obj/machinery/cart/))
		return

	load(C)

/obj/machinery/cart/cargo/MouseDropFrom(obj/over_object as obj, src_location, over_location)
	..()
	var/mob/user = usr
	if (user.incapacitated() || !in_range(user, src) || !in_range(src, over_object))
		return
	if (!load)
		return
	unload(over_object)


/obj/machinery/cart/cargo/proc/load(var/atom/movable/C)

	if (istype(C, /obj/abstract/screen) || C.anchored)
		return
	if(!isturf(C.loc)) //To prevent the loading from stuff from someone's inventory, which wouldn't get handled properly.
		return

	if(get_dist(C, src) > 1)
		return

	var/obj/structure/closet/crate/crate = C
	if(istype(crate))
		crate.close()

	C.forceMove(src)
	load = C

	C.pixel_y += 9 * PIXEL_MULTIPLIER
	if(C.layer < layer)
		C.layer = layer + 0.1
	C.plane = plane
	overlays += C

	/*if(ismob(C))
		var/mob/M = C
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src*/

/obj/machinery/cart/cargo/proc/unload(var/dirn = 0)
	if(!load)
		return

	overlays.len = 0

	load.forceMove(src.loc)
	load.pixel_y -= 9 * PIXEL_MULTIPLIER
	load.reset_plane_and_layer()

	if(dirn)
		var/turf/T = src.loc
		T = get_step(T,dirn)
		if(Cross(load,T))
			step(load, dirn)
		else
			load.forceMove(src.loc)

	load = null

	for(var/atom/movable/AM in src)
		AM.forceMove(src.loc)
		AM.reset_plane_and_layer()
		AM.pixel_y = initial(AM.pixel_y)
