/obj/cart/
	name = "cart"
	icon = 'goon/icons/vehicles.dmi' //If you want to sprite a new cart, do it in 'icons/obj/vehicles.dmi'
	icon_state = "flatbed"
	density = 1
	var/atom/movable/load = null
	var/obj/cart/next_cart = null

/obj/cart/MouseDrop_T(var/atom/movable/C, mob/user)
	if (user.incapacitated() || !in_range(user, src))
		return

	if (!istype(C)|| C.anchored || get_dist(user, src) > 1 || get_dist(src, C) > 1 )
		return

	if (istype(C, /obj/cart) && in_range(C, src))
		var/obj/cart/connecting = C
		if (src == connecting)
			return
		else if (!next_cart && !connecting.next_cart)
			next_cart = connecting
			user.visible_message("[user] connects [connecting] to [src].", "You connect [connecting] to [src].")
			return
		else if (next_cart == connecting)
			src.next_cart = null
			user.visible_message("[user] disconnects [connecting] from [src].", "You disconnect [connecting] from [src].")
			return
		else
			to_chat(user, "\The [src] already has a cart connected to it!", "red")
			return

/obj/cart/Move()
	var/oldloc = src.loc
	..()
	if (src.loc == oldloc)
		return
	if (next_cart)
		next_cart.Move(oldloc)

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
