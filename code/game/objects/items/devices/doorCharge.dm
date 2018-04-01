/obj/item/device/doorCharge
	name = "airlock charge"
	desc = null //Different examine for traitors
	item_state = "electronic"
	icon_state = "doorCharge"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	throw_range = 4
	throw_speed = 1
	flags_1 = NOBLUDGEON_1
	force = 3
	attack_verb = list("blown up", "exploded", "detonated")
	materials = list(MAT_METAL=50, MAT_GLASS=30)

/obj/item/device/doorCharge/ex_act(severity, target)
	switch(severity)
		if(1)
			visible_message("<span class='warning'>[src] detonates!</span>")
			explosion(src.loc,0,2,1,flame_range = 4)
			qdel(src)
		if(2)
			if(prob(50))
				ex_act(EXPLODE_DEVASTATE)
		if(3)
			if(prob(25))
				ex_act(EXPLODE_DEVASTATE)

/obj/item/device/doorCharge/Destroy()
	if(istype(loc, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = loc
		if(A.charge == src)
			A.charge = null
	return ..()

/obj/item/device/doorCharge/examine(mob/user)
	..()
	if(user.mind && user.mind.has_antag_datum(/datum/antagonist/traitor)) //No nuke ops because the device is excluded from nuclear
		to_chat(user, "A small explosive device that can be used to sabotage airlocks to cause an explosion upon opening. To apply, remove the airlock's maintenance panel and place it within.")
	else
		to_chat(user, "A small, suspicious object that feels lukewarm when held.")
