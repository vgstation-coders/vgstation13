/obj/machinery/computer/mecha
	name = "Exosuit Control"
	icon = 'icons/obj/computer.dmi'
	icon_state = "mecha"
	req_access = list(access_robotics)
	circuit = "/obj/item/weapon/circuitboard/mecha_control"
	var/list/located = list()
	var/screen = 0
	var/stored_data

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/mecha/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/mecha/attack_hand(var/mob/user as mob)
	if(..())
		return
	tgui_interact(user)

/obj/machinery/computer/mecha/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MechaControlConsole")
		ui.open()

/obj/machinery/computer/mecha/ui_data(mob/user)
	var/list/data = list()

	data["mechas"] = list()
	for(var/obj/item/mecha_parts/mecha_tracking/TR in mech_tracking_beacons)
		var/obj/mecha/M = TR.in_mecha()
		var/area/A = get_area(M)
		if(!M)
			continue
		var/list/mecha_data = list(
			name = M.name,
			health = round((M.health/initial(M.health))*100),
			charge = M.cell ? round(M.cell.percent()) : null,
			pilot = M.occupant || "None",
			location = A.name || "Unknown",
			active = M.selected ? M.selected.name : "None",
			status = M.state,
			mechaimage = iconsouth2base64(getFlatIcon(M)),
			log = TR.get_mecha_log(),
			ref = ref(M)
		)
		data["mechas"] += list(mecha_data)

	return data

/obj/machinery/computer/mecha/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("message")
			var/obj/mecha/M = locate(params["ref"])
			var/message = params["mechamessage"]
			var/actualmessage = strip_html_properly(message)
			M.occupant_message(actualmessage)
			to_chat(usr, "<span class='warning'>You send a message to [M].</span>")
		if("lockdown")
			if(allowed(usr))
				var/obj/mecha/M = locate(params["ref"])
				M.state = !M.state
				M.log_message("Emergency maintenance protocols [M.state?"activated":"deactivated"].",1)
				if(M.occupant)
					M.occupant_message("<span class='red'>Exosuit emergency maintenance protocols [M.state?"activated":"deactivated"]. This exosuit has been locked down.</span>")
					M.occupant << sound('sound/mecha/mechlockdown.ogg',wait=0)
				to_chat(usr, "<span class='warning'>You [M.state?"lock down":"remove the lockdown on"] \the [M]</span>")
				log_game("[key_name_admin(usr)] [M.state?"locked down":"unlocked"] [M] using an exosuit control console.")
				message_admins("[key_name_admin(usr)] [formatJumpTo(usr)] [M.state?"locked down":"unlocked"] [M] [formatJumpTo(M)] using an exosuit control console.")
			else
				to_chat(usr, "<span class='warning'>Access Denied.</span>")
		if("shock")
			if(allowed(usr))
				var/obj/mecha/M = locate(params["ref"])
				to_chat(usr, "<span class='warning'>You detonate [M].</span>")
				message_admins("[key_name_admin(usr)] [formatJumpTo(usr)] overloaded [M] [formatJumpTo(M)] using an exosuit control console.")
				log_game("[key_name_admin(usr)] overloaded [M] using an exosuit control console.")
				M.log_message("Exosuit tracking beacon overload activated.",1)
				M.occupant_message("<span class='red'><b>The exosuit tracking beacon short-circuits!</b></span>")
				M.use_power(M.cell.charge)
				if (M.get_charge())
					if (M.cell.charge < 5000 && M)
						M.use_power(M.cell.charge/4)
						M.take_damage(25,"energy")
					if (M.cell.charge > 5000 && M)
						M.take_damage((round(M.cell.charge/5000)*50),"energy")
						M.use_power(round(M.cell.charge/5000)*(rand(4000,5000)))
				M.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
			else
				to_chat(usr, "<span class='warning'>Access Denied.</span>")
	return TRUE

/obj/item/mecha_parts/mecha_tracking
	name = "Exosuit tracking beacon"
	desc = "Device used to transmit exosuit data."
	icon = 'icons/obj/device.dmi'
	icon_state = "motion2"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MAGNETS + "=2"
	var/lockdown = 0

/obj/item/mecha_parts/mecha_tracking/New()
	..()
	mech_tracking_beacons.Add(src)

/obj/item/mecha_parts/mecha_tracking/Destroy()
	mech_tracking_beacons.Remove(src)
	..()

/obj/item/mecha_parts/mecha_tracking/emp_act()
	qdel(src)
	return

/obj/item/mecha_parts/mecha_tracking/ex_act()
	qdel(src)
	return

/obj/item/mecha_parts/mecha_tracking/proc/in_mecha()
	if(istype(src.loc, /obj/mecha))
		return src.loc
	return FALSE

/obj/item/mecha_parts/mecha_tracking/proc/get_mecha_log()
	if(!src.in_mecha())
		return 0
	var/obj/mecha/M = src.loc
	return M.get_log_html()

/obj/item/weapon/storage/box/mechabeacons
	name = "Exosuit Tracking Beacons"
/obj/item/weapon/storage/box/mechabeacons/New()
	..()
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
