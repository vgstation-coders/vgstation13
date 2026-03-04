/obj/item/device/maracas
	name = "maracas"
	desc = "Rather than using beads in a hollow shell, these space maracas use a long-life WATT potassium battery and a sensor to detect when they're shaken. Chick-chicky-boom, chick-chicky boom."
	icon = 'icons/obj/maracas.dmi'
	icon_state = "maracas"
	item_state = "maracas"
	w_class = W_CLASS_TINY
	w_type = RECYK_ELECTRONIC
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	flammable = TRUE

	var/triggered = 0 //Do not make it explode twice

/obj/item/device/maracas/cubanpete
	name = "Cuban Pete's maracas"
	emagged = 1

/obj/item/device/maracas/New()
	..()
	src.pixel_x = rand(-5, 5) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-5, 5) * PIXEL_MULTIPLIER

/obj/item/device/maracas/pickup(mob/user)
	user.register_event(/event/face, src, /obj/item/device/maracas/proc/chickchicky)
	chickchicky()

/obj/item/device/maracas/throw_impact(atom/hit_atom, var/speed, var/mob/user)
	if(!triggered && emagged)
		playsound(src, 'sound/misc/cuban_pete.ogg', 100, 0, falloff = 2)
		triggered = TRUE
		spawn(2.1 SECONDS) //The point in the audio file in which the tune changes
			explosion(get_turf(src), 1, 2, 6, whodunnit = user)
			qdel(src)

/obj/item/device/maracas/dropped(mob/user)
	user.unregister_event(/event/face, src, /obj/item/device/maracas/proc/chickchicky)
	spawn(3)
		chickchicky()

/obj/item/device/maracas/examine(mob/user)
	..()
	if(emagged)
		to_chat(user, "<span class='warning'>You're not sure why, but you swear that you can hear the maracas ticking.</span>")

/obj/item/device/maracas/emag_act(mob/user)
	to_chat(user, "<span class='warning'>How do you even emag a maraca? How do you fit the card into it? Come on now, this is stupid.</span>")

/obj/item/device/maracas/afterattack()
	chickchicky()

/obj/item/device/maracas/attack_self(mob/user as mob)
	chickchicky()

/obj/item/device/maracas/proc/chickchicky()
	var/turf/T = get_turf(src)
	if(T) // if our maracas explode, we won't be able to chickchicky because we'll have no turf
		playsound(T, 'sound/misc/maracas.ogg', 50, 1)
