/*
 *Altars and Podiums
 *Altars should later have other functions but I am not coder enough to do them yet.
 *
 */

/obj/structure/altar
	name = "altar"
	desc = "Some sort of spooky altar used by the chaplain for, something. Best not to fiddle with it."
	icon = 'icons/obj/DeusSpritus.dmi'
	icon_state = "altar2_on"
	density = 1
	anchored = 1
	var/on = 1
	light_range = 4
	light_color = LIGHT_COLOR_ORANGE
	var/last_check = 0

/obj/structure/altar/New()
	..()
	processing_objects.Add(src)

/obj/structure/altar/Destroy()
	processing_objects.Remove(src)
	..()


/obj/structure/altar/attack_hand(mob/M as mob)

	if(on == 0)
		on = 1
		update_icon()
		set_light(4)

	else
		on = 0
		update_icon()
		set_light(0)

/obj/structure/altar/update_icon()
	if (on)
		icon_state = "altar2_on"
	else
		icon_state = "altar2_off"

/obj/structure/altar/cultify()
	return

obj/structure/altar/blob_act()
	return

obj/structure/altar/ex_act(severity)
	return


/obj/structure/altar/podium
	name = "preachers podium"
	desc = "For whatever reason, you feel obliged to listen to whoever speaks at this, no matter how ridiculous."
	icon_state = "podium_on"
	light_range = 2
	density = 0
	plane = ABOVE_HUMAN_PLANE

/obj/structure/altar/podium/update_icon()
	if (on)
		icon_state = "podium_on"
	else
		icon_state = "podium_off"

/obj/structure/altar/wood
	name = "altar"
	desc = "Some sort of spooky altar used by the chaplain for, something. Best not to fiddle with it."
	icon_state = "altar1_on"

/obj/structure/altar/wood/update_icon()
	if (on)
		icon_state = "altar1_on"
	else
		icon_state = "altar1_off"

