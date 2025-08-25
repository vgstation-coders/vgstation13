//Its a door. Doors are too machiney, lets make it a structure instead! -Oldcoders
//That was a bad idea, lets make it a machine instead!

/obj/machinery/door/table
	name = "table door"
	pass_flags_self = PASSTABLE
	layer = TABLE_LAYER
	throwpass = 1	//You can throw objects over this, despite its density.
	use_power = MACHINE_POWER_USE_NONE
	machine_flags = 0
	icon = 'icons/obj/doors/tabledoor.dmi'
	icon_state = "metal"
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
