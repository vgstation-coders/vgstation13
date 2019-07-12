/obj/structure/bed/chair/vehicle/cart/
	name = "cart"
	icon = 'goon/icons/vehicles.dmi' //If you want to sprite a new cart, do it in 'icons/obj/vehicles.dmi'
	icon_state = "flatbed"
	density = 0
	var/obj/structure/bed/chair/vehicle/cart/previous_cart = null
	var/datum/train/train_net = null

/obj/structure/bed/chair/vehicle/cart/MouseDropTo(var/atom/movable/C, mob/user)
	if (user.incapacitated() || !in_range(user, src))
		return 0

	if (!istype(C) || get_dist(user, src) > 1 || get_dist(src, C) > 1 )
		return 0

	if (istype(C, /obj/structure/bed/chair/vehicle/cart) && in_range(C, src))
		var/obj/structure/bed/chair/vehicle/cart/connecting = C
		if (src == connecting)
			return 1
		else if (next_cart == connecting)
			next_cart.previous_cart = null
			next_cart = null
			disconnected()
			connecting.disconnected()
			user.visible_message("[user] disconnects [connecting] from [src].", "You disconnect [connecting] from [src].")
			playsound(src, 'sound/misc/buckle_unclick.ogg', 50, 1)
			return 1
		if (connecting.previous_cart)
			to_chat(user, "\The [connecting] already has a cart connected to it!", "red")
			return 0
		else if (!next_cart)
			if (!train_net)
				train_net = new
				train_net.members += src
			if (train_net.connect_train(src, connecting, user))
				return 1
			next_cart = connecting
			next_cart.previous_cart = src
			user.visible_message("[user] connects [connecting] to [src].", "You connect [connecting] to [src].")
			playsound(src, 'sound/misc/buckle_click.ogg', 50, 1)
			return 1
		else
			to_chat(user, "\The [src] already has a cart connected to it!", "red")
			return 0

	return ..()

/obj/structure/bed/chair/vehicle/cart/proc/connected_carts()
	return list(previous_cart, next_cart)

/obj/structure/bed/chair/vehicle/cart/disconnected()
	train_net = new
	train_net.members += src
	train_net.train_rebuild(src)

/obj/structure/bed/chair/vehicle/cart/relaymove(var/mob/living/user, direction)
	if(user.incapacitated())
		return

	unlock_atom(user)