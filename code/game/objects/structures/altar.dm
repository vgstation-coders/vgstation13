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

/obj/structure/altar/attack_hand(mob/M as mob)

	on = !on
	set_light(on*light_range) //Sets the lightrange multiplied by a true (1) false (0)
	update_icon()


/obj/structure/altar/update_icon()
	icon_state = "altar2_[on ? "on" : "off"]"


//Altars are holy relics, invulnerable to the actions of those around them.
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
	light_range = 2 //small candles
	density = 0 //Density zero so people can walk on the same tile and preach.
	plane = ABOVE_HUMAN_PLANE //Said person is BEHIND this object.

/obj/structure/altar/podium/update_icon()
	icon_state = "podium_[on ? "on" : "off"]"


//podiums however, are not.
/obj/structure/altar/podium/cultify()
	if(prob(66))
		qdel(src)

/obj/structure/altar/podium/blob_act()
	if(prob(66))
		qdel(src)

obj/structure/altar/podium/ex_act(severity)
	if(prob(10*severity))
		qdel(src)


/obj/structure/altar/wood
	name = "altar"
	desc = "Some sort of spooky altar used by the chaplain for, something. Best not to fiddle with it."
	icon_state = "altar1_on"

/obj/structure/altar/wood/update_icon()
	icon_state = "altar1_[on ? "on" : "off"]"

