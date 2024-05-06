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
	var/obj/item/clothing/shoes/kneesocks/base_sock = null

/obj/item/weapon/brick_sock/New(var/turf/location, var/obj/item/weapon/brick_sock/basesock)
	..()
	if(basesock)
		base_sock = basesock
	else
		base_sock = new(src)

/obj/item/weapon/brick_sock/attack_self(mob/user)
	user.put_in_hands(new /obj/item/stack/sheet/mineral/brick(user))
	user.create_in_hands(src, base_sock, msg = "<span class='notice'>You remove the brick from \the [src].</span>")

/obj/item/weapon/brick_sock/soap
	name = "soap in a sock"
	desc = "Cleans the spirit."
	icon = 'icons/obj/soapsock.dmi'
	hitsound = "sound/effects/bodyfall.ogg"
	force = 5
	throwforce = 0
	w_class = W_CLASS_TINY
	var/obj/item/weapon/soap/base_soap = null

/obj/item/weapon/brick_sock/soap/New(var/turf/location, var/obj/item/weapon/brick_sock/basesock, var/obj/item/weapon/brick_sock/basesoap)
	..()
	if(basesoap)
		base_soap = basesoap
	else
		base_soap = new(src)
		
/obj/item/weapon/brick_sock/soap/attack_self(mob/user)
	user.put_in_hands(base_soap)
	user.create_in_hands(src, base_sock, msg = "<span class='notice'>You remove the soap from \the [src].</span>")