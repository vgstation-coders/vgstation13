/obj/item/weapon/soap_sock
	name = "soap in a sock"
	desc = "Cleans the spirit."
	icon = 'icons/obj/sockweapon.dmi'
	hitsound = "sound/weapons/punch1.ogg"
	force = 5
	throwforce = 0
	throw_speed = 1
	throw_range = 7
	attack_verb = list("socks")
	w_class = W_CLASS_TINY

/obj/item/weapon/brick_sock
	name = "brick in a sock"
	desc = "Rebuilds the body."
	icon = 'icons/obj/sockweapon.dmi'
	hitsound = "sound/effects/woodhit.ogg"
	force = 15
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	attack_verb = list("socks")
	w_class = W_CLASS_TINY

/obj/item/clothing/shoes/kneesocks/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/soap))
		to_chat(user, "You place a bar of soap into \the [src].")
		if(do_after(user, src, 10))
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/soap_sock/I = new (get_turf(user))
			user.put_in_hands(I)
			qdel(src)
			qdel(W)
	else if(istype(W, /obj/item/stack/sheet/mineral/brick))
		var/obj/item/stack/sheet/mineral/brick/S = W
		to_chat(user, "You place a brick into \the [src].")
		if(do_after(user, src, 10))
			S.use(1)
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/brick_sock/I = new (get_turf(user))
			user.put_in_hands(I)
			qdel(src)