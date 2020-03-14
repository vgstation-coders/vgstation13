/obj/machinery/cart/
	name = "cart"
	icon = 'goon/icons/vehicles.dmi' //If you want to sprite a new cart, do it in 'icons/obj/vehicles.dmi'
	icon_state = "flatbed"
	density = 0
	var/obj/machinery/cart/next_cart = null
	var/obj/machinery/cart/previous_cart = null
	var/datum/train/train_net = null

/obj/machinery/cart/MouseDropTo(var/atom/movable/C, mob/user)
	if (user.incapacitated() || !in_range(user, src))
		return

	if (!istype(C) || get_dist(user, src) > 1 || get_dist(src, C) > 1 )
		return

	if (istype(C, /obj/machinery/cart) && in_range(C, src))
		var/obj/machinery/cart/connecting = C
		if (src == connecting)
			return
		else if (next_cart == connecting)
			next_cart.previous_cart = null
			next_cart = null
			disconnected()
			connecting.disconnected()
			user.visible_message("[user] disconnects [connecting] from [src].", "You disconnect [connecting] from [src].")
			playsound(src, 'sound/misc/buckle_unclick.ogg', 50, 1)
			return
		if (connecting.previous_cart)
			to_chat(user, "\The [connecting] already has a cart connected to it!", "red")
			return
		else if (!next_cart)
			if (!train_net)
				train_net = new
				train_net.members += src
			if (train_net.connect_train(src, connecting, user))
				return
			next_cart = connecting
			next_cart.previous_cart = src
			user.visible_message("[user] connects [connecting] to [src].", "You connect [connecting] to [src].")
			playsound(src, 'sound/misc/buckle_click.ogg', 50, 1)
			return
		else
			to_chat(user, "\The [src] already has a cart connected to it!", "red")
			return

/obj/machinery/cart/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	var/oldloc = src.loc
	..()
	if (src.loc == oldloc)
		return

	if (next_cart)
		next_cart.Move(oldloc, glide_size_override = src.glide_size)

	if (next_cart) //This one is really unlikely to happen
		if (get_dist(next_cart, src) > 1.99) //This is a nasty nasty hack but IT WORKS SO DON'T TOUCH IT
			var/obj/machinery/cart/C = next_cart
			next_cart.previous_cart = null
			next_cart = null
			disconnected()
			C.disconnected()
			playsound(src, 'sound/misc/buckle_unclick.ogg', 50, 1)

	if (previous_cart)
		if (get_dist(previous_cart, src) > 1.99)
			var/obj/machinery/cart/C = previous_cart
			previous_cart.next_cart = null
			previous_cart = null
			disconnected()
			C.disconnected()
			playsound(src, 'sound/misc/buckle_unclick.ogg', 50, 1)

/obj/machinery/cart/proc/connected_carts()
	return list(previous_cart, next_cart)

/obj/machinery/cart/proc/disconnected()
	train_net = new
	train_net.members += src
	train_net.train_rebuild(src)
