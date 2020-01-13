/obj/machinery/ai_slipper
	name = "foam dispenser" //Doesn't have to be the AI's
	icon = 'icons/obj/device.dmi'
	icon_state = "motion3"
	anchored = 1.0
	var/uses = 20
	var/disabled = 1
	var/lethal = 0
	var/locked = 1
	var/cooldown_time = 0
	var/cooldown_timeleft = 0
	var/cooldown_on = 0
	req_access = list(access_ai_upload)

/obj/machinery/ai_slipper/power_change()
	if(stat & BROKEN)
		return
	else
		if(powered())
			stat &= ~NOPOWER
		else
			icon_state = "motion0"
			stat |= NOPOWER

/obj/machinery/ai_slipper/proc/setState(var/enabled, var/uses)
	src.disabled = disabled
	src.uses = uses
	src.power_change()

/obj/machinery/ai_slipper/attackby(obj/item/weapon/W, mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	if(istype(user, /mob/living/silicon) || isAdminGhost(user))
		src.add_hiddenprint(user)
		return src.attack_hand(user)
	else // trying to unlock the interface
		if(src.allowed(user))
			locked = !locked
			to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the device.</span>")
			if (locked)
				if (user.machine == src)
					user.unset_machine()
					user << browse(null, "window=ai_slipper")
			else
				if (user.machine == src)
					src.attack_hand(usr)
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
			return
	return

/obj/machinery/ai_slipper/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	if(stat & (NOPOWER|BROKEN))
		return

	user.set_machine(src)
	var/area/this_area = get_area(src)
	var/t = "<TT><B>Foam Dispenser</B> ([this_area.name])<HR>"

	if(src.locked && !istype(user, /mob/living/silicon) && !isAdminGhost(user))
		t += "<I>(Swipe ID card to unlock control panel.)</I><BR>"
	else
		t += text("Dispenser [src.disabled ? "unactive":"active"] - <A href='?src=\ref[src];toggleOn=1'>[src.disabled?"Enable":"Disable"]?</a><br>\n")
		t += text("Uses Left: [uses]. <A href='?src=\ref[src];toggleUse=1'>Activate the dispenser?</A><br>\n")

	user << browse(t, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/ai_slipper/Topic(href, href_list)
	if(..())
		return 1
	if(src.locked)
		if(!istype(usr, /mob/living/silicon) && !isAdminGhost(usr))
			to_chat(usr, "<span class='warning'>Control panel is locked!</span>")
			return
	if(href_list["toggleOn"])
		src.disabled = !src.disabled
		icon_state = src.disabled? "motion0":"motion3"
	if(href_list["toggleUse"])
		if(cooldown_on || disabled)
			return
		else
			new /obj/effect/effect/foam(src.loc)
			src.uses--
			cooldown_on = 1
			cooldown_time = world.timeofday + 100
			slip_process()
			return

	src.attack_hand(usr)
	return

/obj/machinery/ai_slipper/proc/slip_process()
	while(cooldown_time - world.timeofday > 0)
		var/ticksleft = cooldown_time - world.timeofday

		if(ticksleft > 1e5)
			cooldown_time = world.timeofday + 10	// midnight rollover


		cooldown_timeleft = (ticksleft / 10)
		sleep(5)
	if(uses <= 0)
		return
	if(uses >= 0)
		cooldown_on = 0
	src.power_change()
	return
