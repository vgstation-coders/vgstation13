/obj/item/weapon/soap_sock
	name = "soap in a sock"
	desc = "Cleans the spirit."
	icon = 'icons/obj/soapsock.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/sockweapon_left.dmi', "right_hand" = 'icons/mob/in-hand/right/sockweapon_right.dmi')
	hitsound = "sound/effects/bodyfall.ogg"
	force = 5
	throwforce = 0
	throw_speed = 1
	throw_range = 7
	attack_verb = list("socks")
	w_class = W_CLASS_TINY

/obj/item/weapon/brick_sock
	name = "brick in a sock"
	desc = "Rebuilds the body."
	icon = 'icons/obj/bricksock.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/sockweapon_left.dmi', "right_hand" = 'icons/mob/in-hand/right/sockweapon_right.dmi')
	hitsound = "sound/effects/woodhit.ogg"
	force = 15
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	attack_verb = list("socks")
	w_class = W_CLASS_MEDIUM

/obj/item/clothing/shoes/kneesocks/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/soap))
		to_chat(user, "<span class='notice'>You place a bar of soap into \the [src].</span>")
		if(do_after(user, src, 1 SECONDS))
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/soap_sock/I = new (get_turf(user))
			user.put_in_hands(I)
			qdel(src)
			qdel(W)
	else if(istype(W, /obj/item/stack/sheet/mineral/brick))
		var/obj/item/stack/sheet/mineral/brick/S = W
		to_chat(user, "<span class='notice'>You place a brick into \the [src].</span>")
		if(do_after(user, src, 10))
			S.use(1)
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/brick_sock/I = new (get_turf(user))
			user.put_in_hands(I)
			qdel(src)

/obj/item/weapon/soap_sock/attack_self(mob/user)
	if(user.a_intent == I_GRAB)
		to_chat(user, "<span class='notice'>You remove the soap from \the [src].</span>")
		user.drop_item(src, force_drop = 1)
		user.put_in_hands(new /obj/item/weapon/soap(user))
		user.put_in_hands(new /obj/item/clothing/shoes/kneesocks(user))
		qdel(src)

/obj/item/weapon/brick_sock/attack_self(mob/user as mob)
	if(user.a_intent == I_GRAB)
		to_chat(user, "You remove the brick from \the [src].")
		user.drop_item(src, force_drop = 1)
		user.put_in_hands(new /obj/item/stack/sheet/mineral/brick(user))
		user.put_in_hands(new /obj/item/clothing/shoes/kneesocks(user))
		qdel(src)