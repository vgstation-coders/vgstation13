/obj/machinery/computer/crew
	name = "Crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_state = "crew"
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 500
	circuit = "/obj/item/weapon/circuitboard/crew"
	var/list/tracked = list(  )
	var/track_special_role

	light_color = LIGHT_COLOR_BLUE
	light_range_on = 2


/obj/machinery/computer/crew/New()
	tracked = list()
	..()


/obj/machinery/computer/crew/attack_ai(mob/user)
	attack_hand(user)
	ui_interact(user)


/obj/machinery/computer/crew/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)


/obj/machinery/computer/crew/update_icon()

	if(stat & BROKEN)
		icon_state = "crewb"
	else
		if(stat & NOPOWER)
			src.icon_state = "c_unpowered"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER


/obj/machinery/computer/crew/Topic(href, href_list)
	if(..()) return
	if (src.z > 6)
		usr << "<span class='danger'>Unable to establish a connection: </span>You're too far away from the station!"
		return 0
	if( href_list["close"] )
		if(usr.machine == src) usr.unset_machine()
		return 0
	if(href_list["update"])
		src.updateDialog()
		return 1

/obj/machinery/computer/crew/interact(mob/user)
	ui_interact(user)

/obj/machinery/computer/crew/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(stat & (BROKEN|NOPOWER))
		return
	user.set_machine(src)
	src.scan()

	var/data[0]
	var/list/crewmembers = list()

	for(var/mob/living/carbon/brain/B in mob_list)
		var/turf/pos = get_turf(B)
		if(!pos) continue
		var/obj/item/device/mmi/M = B.loc
		if(istype(M) && M.brainmob == B)
			if(isrobot(M.loc) || M.z == CENTCOMM_Z)
				continue
			var/list/crewmemberData = list()
			crewmemberData["sensor_type"] = 3
			crewmemberData["dead"] = 0
			crewmemberData["oxy"] = 0
			crewmemberData["tox"] = 0
			crewmemberData["fire"] = 0
			crewmemberData["brute"] = 0
			crewmemberData["name"] = M.name
			crewmemberData["rank"] = "Unknown"
			crewmemberData["area"] = get_area(M)
			crewmemberData["x"] = pos.x
			crewmemberData["y"] = pos.y
			crewmemberData["z"] = pos.z
			crewmemberData["xoffset"] = pos.x-WORLD_X_OFFSET[pos.z]
			crewmemberData["yoffset"] = pos.y-WORLD_Y_OFFSET[pos.z]
			crewmembers += list(crewmemberData)


	for(var/obj/item/clothing/under/C in src.tracked)

		var/turf/pos = get_turf(C)

		if((C) && (C.has_sensor) && (pos) && (pos.z != CENTCOMM_Z) && C.sensor_mode)
			if(istype(C.loc, /mob/living/carbon/human))

				var/mob/living/carbon/human/H = C.loc

				var/list/crewmemberData = list()

				crewmemberData["sensor_type"] = C.sensor_mode
				crewmemberData["dead"] = H.stat > 1
				crewmemberData["oxy"] = round(H.getOxyLoss(), 1)
				crewmemberData["tox"] = round(H.getToxLoss(), 1)
				crewmemberData["fire"] = round(H.getFireLoss(), 1)
				crewmemberData["brute"] = round(H.getBruteLoss(), 1)

				crewmemberData["name"] = "Unknown"
				crewmemberData["rank"] = "Unknown"
				if(H.wear_id && istype(H.wear_id, /obj/item/weapon/card/id) )
					var/obj/item/weapon/card/id/I = H.wear_id
					crewmemberData["name"] = I.registered_name
					crewmemberData["rank"] = I.rank
				else if(H.wear_id && istype(H.wear_id, /obj/item/device/pda) )
					var/obj/item/device/pda/P = H.wear_id
					crewmemberData["name"] = (P.id ? P.id.registered_name : "Unknown")
					crewmemberData["rank"] = (P.id ? P.id.rank : "Unknown")

				crewmemberData["area"] = get_area(H)
				crewmemberData["x"] = pos.x
				crewmemberData["y"] = pos.y
				crewmemberData["z"] = pos.z
				crewmemberData["xoffset"] = pos.x-WORLD_X_OFFSET[pos.z]
				crewmemberData["yoffset"] = pos.y-WORLD_Y_OFFSET[pos.z]

				crewmembers += list(crewmemberData)
				// Works around list += list2 merging lists; it's not pretty but it works
				//crewmembers += "temporary item"
				//crewmembers[crewmembers.len] = crewmemberData

	crewmembers = sortList(crewmembers)

	data["crewmembers"] = crewmembers

	//ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui) // no ui has been passed, so we'll search for one
		ui = nanomanager.get_open_ui(user, src, ui_key)
	if(!ui)
		ui = new(user, src, ui_key, "crew_monitor.tmpl", "Crew Monitoring Computer", 1000, 1000)

		// adding a template with the key "mapContent" enables the map ui functionality
		ui.add_template("mapContent", "crew_monitor_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
		ui.add_template("mapHeader", "crew_monitor_map_header.tmpl")

		// we want to show the map by default
		ui.set_show_map(1)

		ui.set_initial_data(data)
		ui.open()

		// should make the UI auto-update; doesn't seem to?
		ui.set_auto_update(1)
	else
		// The UI is already open so push the new data to it
		ui.push_data(data)
		return

/obj/machinery/computer/crew/proc/is_scannable(const/obj/item/clothing/under/C, const/mob/living/carbon/human/H)
	if(!istype(H) || H.iscorpse)
		return 0

	if(isnull(track_special_role))
		return C.has_sensor

	return (H.mind ? H.mind.special_role == track_special_role : 1)

/obj/machinery/computer/crew/proc/scan()
	for(var/mob/living/carbon/human/H in mob_list)
		if(istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/C = H.w_uniform
			if (C.has_sensor)
				if(is_scannable(C, H))
					tracked |= C
	return 1
