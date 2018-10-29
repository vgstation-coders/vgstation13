/obj/item/device/maracas
	name = "maracas"
	desc = "Rather than using beads in a hollow shell, these space maracas use a long-life WATT potassium battery and a sensor to detect when they're shaken. Chick-chicky-boom, chick-chicky boom."
	icon = 'icons/obj/maracas.dmi'
	icon_state = "maracas"
	item_state = "maracas"
	w_class = W_CLASS_TINY
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT

	var/emagged = 0//our maracas are different - Deity Link

/obj/item/device/maracas/cubanpete
	name = "Cuban Pete's maracas"
	emagged = 1

/obj/item/device/maracas/New()
	..()
	src.pixel_x = rand(-5, 5) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-5, 5) * PIXEL_MULTIPLIER

/obj/item/device/maracas/pickup(mob/user)
	user.callOnFace |= "\ref[src]"
	user.callOnFace["\ref[src]"] = "chickchicky"
	chickchicky()

/obj/item/device/maracas/throw_impact(atom/hit_atom)
	if(emagged)
		explosion(get_turf(src), -1 ,1, 3)
		qdel(src)

/obj/item/device/maracas/dropped(mob/user)
	user.callOnFace -= "\ref[src]"
	spawn(3)
		chickchicky()

/obj/item/device/maracas/examine(mob/user)
	..()
	if(emagged)
		to_chat(user, "<span class='warning'>You're not sure why, but you swear that you can hear the maracas ticking.</span>")

/obj/item/device/maracas/emag_act(mob/user)
	emagged = 1

/obj/item/device/maracas/afterattack()
	chickchicky()

/obj/item/device/maracas/attack_self(mob/user as mob)
	chickchicky()

/obj/item/device/maracas/proc/chickchicky()
	var/turf/T = get_turf(src)
	if(T) // if our maracas explode, we won't be able to chickchicky because we'll have no turf
		playsound(T, 'sound/misc/maracas.ogg', 50, 1)
