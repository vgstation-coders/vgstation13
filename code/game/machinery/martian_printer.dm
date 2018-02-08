/obj/machinery/martian_printer
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

/obj/machinery/martian_printer/attack_ghost(var/mob/dead/observer/O)
	if(!canSpawn())
		return

	if(O.can_reenter_corpse)
		if(alert(O,"Do you want to get your squid on?","Time for some emergency probing","Yes","No")== "Yes")
			if(building)
				to_chat(O, "<span class='notice'>\The [src] is already processing another alien. Try again later.</span>")
				return
		else
			return
	else if(!(O.can_reenter_corpse))
		to_chat(O,"<span class='notice'>You have recently ghosted and can not enter as a martian right now. Try again later.</span>")
		return

	make_martian(O)

/obj/machinery/martian_printer/power_change()
	if (powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

/obj/machinery/martian_printer/proc/canSpawn()
	return !(stat & NOPOWER) && !building

/obj/machinery/martian_printer/proc/make_martian(var/mob/dead/observer/user)
	building = TRUE
	if(!user || !istype(user) || !user.client)
		// Player has already been made into another mob before this one spawned, so let's reset the spawner
		building = FALSE
		update_icon()
		return FALSE
	flick("m_pad_active", src)
	spawn(24)
		if(!user || !istype(user) || !user.client)
			// Player disappeared between clicking on the spawner and now, so we have no one to turn tentacle!
			building = FALSE
			return FALSE

		var/mob/living/carbon/martian/M = new(get_turf(src))

		M.ckey = user.ckey
		qdel(user)


		building = FALSE
		return TRUE