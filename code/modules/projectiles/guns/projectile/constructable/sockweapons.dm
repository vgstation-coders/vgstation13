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
	var/obj/item/weapon/soap_sock/base_soap = null
	var/obj/item/weapon/soap_sock/base_sock = null

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
	var/obj/item/weapon/brick_sock/base_sock = null

/obj/item/weapon/soap_sock/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You remove the soap from \the [src].</span>")
	user.drop_item(src, force_drop = 1)
	user.put_in_hands(src.base_sock)
	user.put_in_hands(src.base_soap)
	qdel(src)

/obj/item/weapon/brick_sock/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You remove the brick from \the [src].</span>")
	user.drop_item(src, force_drop = 1)
	user.put_in_hands(new /obj/item/stack/sheet/mineral/brick(user))
	user.put_in_hands(src.base_sock)
	qdel(src)
