/obj/machinery/cart/
	name = "cart"
	icon = 'goon/icons/vehicles.dmi' //If you want to sprite a new cart, do it in 'icons/obj/vehicles.dmi'
	icon_state = "flatbed"
	density = 1
	var/obj/machinery/cart/next_cart = null

/obj/machinery/cart/MouseDrop_T(var/atom/movable/C, mob/user)
	if (user.incapacitated() || !in_range(user, src))
		return

	if (!istype(C)|| C.anchored || get_dist(user, src) > 1 || get_dist(src, C) > 1 )
		return

	if (istype(C, /obj/machinery/cart) && in_range(C, src))
		var/obj/machinery/cart/connecting = C
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

/obj/machinery/cart/Move()
	var/oldloc = src.loc
	..()
	if (src.loc == oldloc)
		return
	if (next_cart)
		next_cart.Move(oldloc)
