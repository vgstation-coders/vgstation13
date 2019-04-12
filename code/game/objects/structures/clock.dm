/obj/structure/clock
	name = "grandfather clock"
	desc = "Hickory dickory dock, the mouse ran up the clock, the clock struck one, the mouse was gone, hickory dickory dock."
	icon = 'icons/obj/objects.dmi'
	icon_state = "clock"
	density = 1
	anchored = 1

/obj/structure/clock/update_icon()
	if(anchored)
		icon_state = "clock"
	else
		icon_state = "clock-broken"

/obj/structure/clock/examine(mob/user)
	..()
	if(anchored)
		to_chat(user, "<span class='info'>Station Time: [worldtime2text()]")

/obj/structure/clock/attackby(obj/item/weapon/W, mob/user)
	if(iswrench(W))
		if(do_after(user, src, 3 SECONDS))
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = !anchored
			update_icon()
	else
		return ..()

/obj/structure/clock/unanchored
	anchored = 0
	icon_state = "clock-broken"