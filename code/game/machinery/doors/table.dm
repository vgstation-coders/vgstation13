//Its a door. Doors are too machiney, lets make it a structure instead! -Oldcoders
//That was a bad idea, lets make it a machine instead!

/obj/machinery/door/table
	name = "table door"
	pass_flags_self = PASSTABLE
	layer = TABLE_LAYER
	open_layer = TABLE_LAYER
	throwpass = 1	//You can throw objects over this, despite its density.
	use_power = MACHINE_POWER_USE_NONE
	machine_flags = 0
	icon = 'icons/obj/doors/tabledoor.dmi'
	icon_state = "metaldoor_closed"
	prefix = "metal" //Corresponds to the mineral type

	soundeffect = 'sound/effects/wood_door_slam.ogg'

/obj/machinery/door/table/Bumped(atom/user)
	if(operating)
		return

	if(istype(user, /obj/mecha))
		open()
	else if (istype(user, /obj/machinery/bot) && SpecialAccess(user))
		open()
	else if(ismob(user))
		var/mob/M = user
		if(M.last_airflow > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_delay)) //This is what we call blind trust
			return
		TryToSwitchState(user)
	return

/obj/machinery/door/table/door_animate(animation) // no spritework for it
	return

/obj/machinery/door/table/attack_ai(mob/user as mob) //those aren't really machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return
	else if(isrobot(user) && get_dist(user,src) <= 1) //but robots can, not remotely though
		return TryToSwitchState(user) //also >nesting if statements

/obj/machinery/door/table/attack_paw(mob/user as mob)
	return TryToSwitchState(user)

/obj/machinery/door/table/attack_hand(mob/user as mob)
	return TryToSwitchState(user)

/obj/machinery/door/table/proc/TryToSwitchState(mob/user as mob)
	if(operating)
		return

	if(!user.restrained() && (user.size > SIZE_TINY))
		add_fingerprint(user)
		SwitchState()
	return

/obj/machinery/door/table/proc/SwitchState()
	if(!density)
		return close()
	else
		return open()

/obj/machinery/door/table/open()
	playsound(src, soundeffect, 100, 1)
	return ..()

/obj/machinery/door/table/close()
	playsound(src, soundeffect, 100, 1)
	return ..()

/obj/machinery/door/table/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.destroy)
		qdel(src)
	return ..()

/obj/structure/table/blob_act()
	if(prob(75))
		qdel(src)

/obj/machinery/door/table/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				qdel(src)
		if(3.0)
			if (prob(25))
				destroy()

/obj/machinery/door/table/reinforced
	name = "reinforced table door"
	icon_state = "rmetaldoor_closed"
	prefix = "rmetal"

/obj/machinery/door/table/wood
	name = "wooden table door"
	icon_state = "wooddoor_closed"
	prefix = "wood"

/obj/machinery/door/table/glass
	name = "glass table door"
	icon_state = "glassdoor_closed"
	prefix = "glass"

/obj/machinery/door/table/glass/plasma
	name = "plasma glass table door"
	icon_state = "pglassdoor_closed"
	prefix = "pglass"
