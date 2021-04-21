#define WIRINGSECURE 1
#define WIRINGUNSECURE 0
/obj/structure/airshield
	name = "airshield"
	desc = "A shield that allows only non-gasses to pass through."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "emancipation_grill_on"
	opacity = 1
	density = 0
	anchored = 1
	plane = ABOVE_HUMAN_PLANE
	var/construction_step = WIRINGSECURE

/obj/structure/airshield/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover))
		return ..()
	return FALSE

/obj/structure/airshield/attackby(obj/item/weapon/W, mob/user)
	if(W.is_screwdriver(user))
		if(user.loc != loc)
			to_chat(user,"<span class='warning'>You need to be inside \the [src] to do work on it!</span>")
			return
		if(construction_step == WIRINGSECURE)
			visible_message("<span class='warning'>[user] is disassembling the wiring on \the [src]!</span>")
			W.playtoolsound(src, 80)
			if(do_after(user, src, 6 SECONDS))
				W.playtoolsound(src, 80)
				visible_message("<span class='notice'>[user] finished unsecuring the wires on \the [src].</span>")
				construction_step = WIRINGUNSECURE
		else
			visible_message("<span class='notice'>[user] is resecuring the wires on \the [src].</span>")
			W.playtoolsound(src, 80)
			if(do_after(user, src, 1 SECONDS))
				construction_step = WIRINGSECURE
	else if(iswelder(W))
		if(user.loc != loc)
			to_chat(user,"<span class='warning'>You need to be inside \the [src] to do work on it!</span>")
			return
		if(construction_step != WIRINGUNSECURE)
			to_chat(user,"<span class='warning'>The wires are still secure on that!</span>")
			return
		var/obj/item/tool/weldingtool/WT = W
		user.visible_message("<span class='warning'>[user] starts disassembling \the [src].</span>", \
			"<span class='notice'>You start disassembling \the [src].</span>")
		if(WT.do_weld(user, src, 6 SECONDS, 2))
			user.visible_message("<span class='notice'>[user] finished disassembling \the [src].</span>", \
			"<span class='notice'>You finish disassembling \the [src].</span>")
			qdel(src)
	else
		..()