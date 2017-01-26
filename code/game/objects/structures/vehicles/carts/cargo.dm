/obj/machinery/cart/cargo
	name = "cargo cart"
	var/atom/movable/load = null

/obj/machinery/cart/cargo/MouseDrop(obj/over_object as obj, src_location, over_location)
	..()
	var/mob/user = usr
	if (user.incapacitated() || !in_range(user, src))
		return
	if (!load)
		return
	unload(over_object)


/obj/machinery/cart/cargo/proc/load(var/atom/movable/C)

	if (istype(C, /obj/screen) || C.anchored)
		return
	if(!isturf(C.loc)) //To prevent the loading from stuff from someone's inventory, which wouldn't get handled properly.
		return

	if(get_dist(C, src) > 1 || load)
		return

	var/obj/structure/closet/crate/crate = C
	if(istype(crate))
		crate.close()

	if(C.loc != loc)
		return
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
		if(Cross(load,T))//Can't get off onto anything that wouldn't let you pass normally
			step(load, dirn)
		else
			load.forceMove(src.loc)//Drops you right there, so you shouldn't be able to get yourself stuck

	load = null

	// in case non-load items end up in contents, dump every else too
	// this seems to happen sometimes due to race conditions
	// with items dropping as mobs are loaded

	for(var/atom/movable/AM in src)
		AM.forceMove(src.loc)
		AM.reset_plane_and_layer()
		AM.pixel_y = initial(AM.pixel_y)

/*/obj/cart/MouseDrop(obj/over_object as obj, src_location, over_location)
		..()
		var/mob/user = usr
		if (!user || !(in_range(user, src) || user.loc == src) || !in_range(src, over_object) || user.restrained() || user.paralysis || user.sleeping || user.stat || user.lying)
			return
		if (!load)
			return
		src.visible_message("<b>[user]</b> unloads [load] from [src].")
		unload(over_object)

/obj/cart/proc/load(var/atom/movable/C)

		if (istype(C, /obj/screen) || C.anchored)
			return

		if (get_dist(C, src) > 1 || load)
			return

		// if a create, close before loading
		var/obj/storage/crate/crate = C
		if (istype(crate))
			crate.close()
		C.set_loc(src.loc)
		spawn(2)
			if (C && C.loc == src.loc)
				C.set_loc(src)
				load = C
				C.pixel_y += 6
				if (C.layer < layer)
					C.layer = layer + 0.1
				src.UpdateOverlays(C, "load")

/obj/cart/proc/unload(var/turf/T)//var/dirn = 0)
		if (!load)
			return
		if (!isturf(T))
			T = get_turf(T)

		load.pixel_y -= 6
		load.layer = initial(load.layer)
		load.set_loc(src.loc)
		if (T)
			spawn(2)
				if (load)
					load.set_loc(T)
					load = null
		src.UpdateOverlays(null, "load")

		// in case non-load items end up in contents, dump every else too
		// this seems to happen sometimes due to race conditions
		// with items dropping as mobs are loaded

		for (var/atom/movable/AM in src)
			AM.set_loc(src.loc)
			AM.layer = initial(AM.layer)
			AM.pixel_y = initial(AM.pixel_y)

	Move()
		var/oldloc = src.loc
		..()
		if (src.loc == oldloc)
			return
		if (next_cart)
			next_cart.Move(oldloc)*/
