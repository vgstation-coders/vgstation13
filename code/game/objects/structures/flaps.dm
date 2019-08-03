/obj/structure/plasticflaps //HOW DO YOU CALL THOSE THINGS ANYWAY
	name = "\improper Plastic flaps"
	desc = "I definitely can't get past those. No way."
	icon = 'icons/obj/stationobjs.dmi' //Change this.
	icon_state = "plasticflaps"
	density = 0
	anchored = 1
	plane = ABOVE_HUMAN_PLANE
	explosion_resistance = 5
	var/airtight = 0

/obj/structure/plasticflaps/attackby(obj/item/I as obj, mob/user as mob)
	if(iscrowbar(I) && anchored == 1)
		if(airtight == 0)
			playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
		else
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		user.visible_message("[user] [airtight? "loosen the [src] from" : "tighten the [src] into"] an airtight position.", "You [airtight? "loosen the [src] from" : "tighten the [src] into"] an airtight position.")
		airtight = !airtight
		name = "\improper [airtight? "Airtight p" : "P"]lastic flaps"
		desc = "[airtight? "Heavy duty, airtight, plastic flaps." : "I definitely can't get past those. No way."]"
		return 1
	if(iswrench(I) && airtight != 1)
		if(anchored == 0)
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		else
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		user.visible_message("[user] [anchored? "loosens" : "tightens"] the flap from its anchoring.", "You [anchored? "loosen" : "tighten"] the flap from its anchoring.")
		anchored = !anchored
		return 1
	else if (iswelder(I) && anchored == 0)
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.remove_fuel(0, user))
			new /obj/item/stack/sheet/mineral/plastic (src.loc,10)
			qdel(src)
			return
	return ..()

/obj/structure/plasticflaps/examine(mob/user as mob)
	..()
	to_chat(user, "It appears to be [anchored? "anchored to" : "unachored from"] the floor, [airtight? "and it seems to be airtight as well." : "but it does not seem to be airtight."]")

/obj/structure/plasticflaps/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return prob(60)

	var/obj/structure/bed/B = mover
	if (istype(mover, /obj/structure/bed) && B.is_locking(B.mob_lock_type))//if it's a bed/chair and someone is buckled, it will not pass
		return 0

	else if(isliving(mover)) // You Shall Not Pass!
		var/mob/living/M = mover
		if(!M.lying && !istype(M, /mob/living/carbon/monkey) && !istype(M, /mob/living/carbon/slime) && !istype(M, /mob/living/simple_animal/mouse))  //If your not laying down, or a small creature, no pass.
			return 0
	if(!istype(mover)) // Aircheck!
		return !airtight
	return 1

/obj/structure/plasticflaps/ex_act(severity)
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(50))
				qdel(src)
		if (3)
			if (prob(5))
				qdel(src)

/obj/structure/plasticflaps/mining
	name = "\improper Airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."
	airtight = 1

/obj/structure/plasticflaps/cultify()
	new /obj/structure/grille/cult(get_turf(src))
	..()