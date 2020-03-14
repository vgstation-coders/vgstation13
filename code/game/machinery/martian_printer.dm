/obj/machinery/mob_printer
	name = "inset disk"
	desc = "A strange disk set into the ground, doesn't seem to be anything beyond decorative."
	icon = 'icons/mob/martian.dmi'
	icon_state = "m_pad"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 5000
	var/building = 0
	var/cooldown_duration = 10 MINUTES
	var/cooldown_time = 0
	var/cooldown_active = 0
	var/corpse_check = 0 // if set to 1, you can't enter it after ghosting or otherwise being unable to enter corpse (being sharded or deleted)
	var/print_path = /mob/living/carbon/complex/martian

/obj/machinery/mob_printer/attack_ghost(var/mob/dead/observer/O)
	if(!canSpawn())
		return
	if(cooldown_active)
		to_chat(O, "<span class='warning'>Error: printer still recharging. Time left: [round((cooldown_time - world.time + 20)/10)] seconds.</span>")
		return

	if(!corpse_check || O.can_reenter_corpse)
		if(alert(O,"Do you want to enter a corporeal form?","Inset Disk","Yes","No")== "Yes")
			if(building)
				to_chat(O, "<span class='notice'>\The [src] is already processing another. Try again later.</span>")
				return
		else
			return
	else if(!(O.can_reenter_corpse))
		to_chat(O,"<span class='notice'>You have recently ghosted or have no corpse, and cannot use the [src].</span>")
		return

	make_mob(O)

	// Activate the cooldown
	cooldown_active = 1
	cooldown_time = world.time + cooldown_duration

/obj/machinery/mob_printer/process()
	..()
	if(world.time >= cooldown_time)
		if (cooldown_active)
			cooldown_active = 0
			playsound(src, 'sound/machines/ping.ogg', 50, 0)

/obj/machinery/mob_printer/power_change()
	if (powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

/obj/machinery/mob_printer/proc/canSpawn()
	if(!use_power)
		return !building //Can be varedited to not need power.
	return !(stat & NOPOWER) && !building

/obj/machinery/mob_printer/proc/make_mob(var/mob/dead/observer/user)
	building = TRUE
	if(!user || !istype(user) || !user.client)
		// Player has already been made into another mob before this one spawned, so let's reset the spawner
		building = FALSE
		update_icon()
		return FALSE
	if(istype(print_path,/mob/living/carbon/complex/martian))
		flick("m_pad_active", src) //Martians get a special animation
	else
		flick("m_pad_alt", src)
	spawn(24)
		if(!user || !istype(user) || !user.client)
			// Player disappeared between clicking on the spawner and now, so we have no one to turn tentacle!
			building = FALSE
			return FALSE

		var/mob/M = new print_path(get_turf(src))

		M.ckey = user.ckey
		qdel(user)


		building = FALSE
		return TRUE
