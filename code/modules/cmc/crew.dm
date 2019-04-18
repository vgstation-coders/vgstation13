var/list/cmc_holomap_cache = list()

///proc/create_progress_bar_on(var/atom/target) from unsorted.dm

/obj/machinery/computer/crew
	name = "Crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_state = "crew"
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 500
	circuit = "/obj/item/weapon/circuitboard/crew"

	light_color = LIGHT_COLOR_BLUE
	light_range_on = 2

	//for the holomap
	var/mob/activator
	var/list/holomap_images = list()
	var/holomap_color = "#5FFF28"
	var/holomap_filter
	var/holomap_z = STATION_Z
	var/list/holomap_tooltips = list()
	var/freeze = 0
	var/list/textview = list()
	var/textview_updatequeued = 0
	var/list/holomap_z_levels_mapped = list(STATION_Z, ASTEROID_Z, DERELICT_Z)
	var/list/holomap_z_levels_unmapped = list(TELECOMM_Z)
	var/list/jobs = list(
		"Captain" = 00,
		"Head of Personnel" = 50,
		"Head of Security" = 10,
		"Warden" = 11,
		"Security Officer" = 12,
		"Detective" = 13,
		"Chief Medical Officer" = 20,
		"Chemist" = 21,
		"Geneticist" = 22,
		"Virologist" = 23,
		"Medical Doctor" = 24,
		"Paramedic" = 25,
		"Research Director" = 30,
		"Scientist" = 31,
		"Roboticist" = 32,
		"Chief Engineer" = 40,
		"Station Engineer" = 41,
		"Atmospheric Technician" = 42,
		"Mechanic" = 43,
		"Quartermaster" = 51,
		"Shaft Miner" = 52,
		"Cargo Technician" = 53,
		"Bartender" = 61,
		"Chef" = 62,
		"Botanist" = 63,
		"Librarian" = 64,
		"Chaplain" = 65,
		"Clown" = 66,
		"Mime" = 67,
		"Janitor" = 68,
		"Internal Affairs Agent" = 69,
		"Admiral" = 200,
		"Centcom Commander" = 210,
		"Emergency Response Team Commander" = 220,
		"Security Response Officer" = 221,
		"Engineer Response Officer" = 222,
		"Medical Response Officer" = 223,
		"Assistant" = 999 //Unknowns/custom jobs should appear after civilians, and before assistants
	)


/obj/machinery/computer/crew/New()
	..()

/obj/machinery/computer/crew/Destroy()
	deactivate_holomap()
	..()

/obj/machinery/computer/crew/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/crew/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(stat & (BROKEN|NOPOWER))
		return
	togglemap(user)

/obj/machinery/computer/crew/update_icon()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]b"
	else
		if(stat & NOPOWER)
			src.icon_state = "c_unpowered"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER

/obj/machinery/computer/crew/interface_act(mob/user, action)
	if(action == "exit")
		deactivate_holomap()
		return

	if(action == "text")
		openTextview()
		return

	if(text2num(action) != null)
		holomap_z = text2num(action)
	update_holomap() //for that nice ui feedback uhhhh

/*
	Adding Crew
*/
/obj/machinery/computer/crew/proc/addCrewToHolomap()
	//looping though carbons
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.iscorpse)
			continue

		var/name
		var/assignment
		var/life_status
		var/dam1
		var/dam2
		var/dam3
		var/dam4
		var/area/player_area
		var/ijob

		// z == 0 means mob is inside object, check is they are wearing a uniform
		if((H.z == 0 || H.z == holomap_z) && istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = H.w_uniform

			if (U.has_sensor && U.sensor_mode)
				var/turf/pos = H.z == 0 || U.sensor_mode == 3 ? get_turf(H) : null

				// Special case: If the mob is inside an object confirm the z-level on turf level.
				if (H.z == 0 && (!pos || pos.z != z))
					continue

				var/obj/item/weapon/card/id/I = H.wear_id ? H.wear_id.GetID() : null

				if (I)
					name = I.registered_name
					assignment = I.assignment
					ijob = jobs[I.rank]
				else
					name = "Unknown"
					assignment = ""
					ijob = 80

				if (U.sensor_mode >= 1)
					life_status = H.stat //CONSCIOUS, UNCONSCIOUS, DEAD

				if (U.sensor_mode >= 2)
					dam1 = round(H.getOxyLoss(),1)
					dam2 = round(H.getToxLoss(),1)
					dam3 = round(H.getFireLoss(),1)
					dam4 = round(H.getBruteLoss(),1)
				else
					dam1 = null
					dam2 = null
					dam3 = null
					dam4 = null


				if(pos)
					player_area = get_area(H)
					addCrewMarker(pos, H, name, assignment, life_status, list(dam1, dam2, dam3, dam4), player_area)
				addCrewToTextview(pos, H, name, assignment, life_status, list(dam1, dam2, dam3, dam4), player_area, ijob)

	for(var/mob/living/carbon/brain/B in mob_list)
		var/obj/item/device/mmi/M = B.loc
		var/area/parea = get_area(B)

		if(istype(M.loc,/obj/item/weapon/storage/belt/silicon))
			continue

		var/turf/pos = get_turf(B)
		if(pos && pos.z != CENTCOMM_Z && (pos.z == holomap_z) && istype(M) && M.brainmob == B && !isrobot(M.loc))
			addCrewMarker(pos, B, "[B]", "MMI", null, null, parea)
			addCrewToTextview(pos, B, "[B]", "MMI", null, null, parea, 60)

/obj/machinery/computer/crew/proc/addCrewToTextview(var/turf/TU, var/mob/living/carbon/H, var/name = "Unknown", var/job = "No job", var/stat = 0, var/list/damage, var/area/player_area = "Mot Available", var/ijob = 9999)
	var/role
	switch(ijob)
		if(0)	role = "cap" // captain
		if(10 to 19) role = "sec" // security
		if(20 to 29) role = "med" // medical
		if(30 to 39) role = "sci"	 // science
		if(40 to 49) role = "eng" // engineering
		if(50 to 59) role = "car" // cargo
		if(60 to 69) role = "silicon" //silicon
		if(200 to 229) role = "cent"
		else role = "unk"

	var/icon
	if(istype(H, /mob/living/carbon/human))
		if(stat != 2)
			if(damage)
				icon = getLifeIcon(damage)
			else
				icon = "0"
		else
			icon = "6"
	else
		icon = "7"

	var/list/string = list("<span class='name [role]'>[name]</span> ([job])")
	string += "<img src='cmc_[icon].png' height='11' width='11'/>" + (damage ? "(<span class='oxygen'>[damage[1]]</span>/<span class='toxin'>[damage[2]]</span>/<span class='fire'>[damage[3]]</span>/<span class='brute'>[damage[4]]</span>)" : "Not Available")
	string += TU ? "[player_area] ([TU.x],[TU.y])" : "Not Available"
	var/actualstring = "<td>" + string.Join("</td><td>") + "</td>"
	textview += actualstring

/obj/machinery/computer/crew/proc/addCrewMarker(var/turf/TU, var/mob/living/carbon/H, var/name = "Unknown", var/job = "", var/stat = 0, var/list/damage, var/area/player_area = "Not Available")
	if(!TU || !H)
		return

	var/uid = "crewmarker_\ref[H]_\ref[activator]"

	//creating the title with name | job - Dead/Alive
	var/title = "[name]" + ((job != "") ? " ([job])" : "") + ((stat == 2) ? " - DEAD" : " - ALIVE")

	//creating the content with damage and some css coloring
	var/content = "Not Available"
	if(damage.len == 4)
		content = "(<span style='color: #0080ff'>[damage[1]]</span>/<span style='color: #00CD00'>[damage[2]]</span>/<span style='color: #ffa500'>[damage[3]]</span>/<span style='color: #ff0000'>[damage[4]]</span>)"

	content += "<br>[player_area]"

	if(!istype(cmc_holomap_cache[uid], /obj/abstract/screen/interface/tooltip/CrewIcon))
		cmc_holomap_cache[uid] = new /obj/abstract/screen/interface/tooltip/CrewIcon(null,activator,src,null,'icons/cmc/sensor_markers.dmi')
		cmc_holomap_cache[uid].plane = ABOVE_HUD_PLANE

	var/obj/abstract/screen/interface/tooltip/CrewIcon/I = cmc_holomap_cache[uid]

	var/icon
	if(istype(H, /mob/living/carbon/human))
		if(stat != 2)
			icon = getLifeIcon(damage)
		else
			icon = "6"
	else
		icon = "7"
	I.icon_state = "sensor_health[icon]"

	//modulo magic for position
	var/nomod_x = round(TU.x / 32)
	var/nomod_y = round(TU.y / 32)
	I.screen_loc = "WEST+[nomod_x]:[TU.x%32 - 8],SOUTH+[nomod_y]:[TU.y%32 - 8]" //- 8 cause the icon is 16px wide

	I.setInfo(title, content, "Coords: [TU.x]|[TU.y]|[TU.z]")
	I.setCMC(src)
	I.name = name

	holomap_tooltips += I

/obj/machinery/computer/crew/proc/getLifeIcon(var/list/damage)
	var/health = 0
	for(var/dam in damage)
		health += dam
	health = round(100 - health)
	switch (health)
		if(80 to 99)
			return "1"
		if(60 to 79)
			return "2"
		if(40 to 59)
			return "3"
		if(20 to 39)
			return "4"
		else if(health != 100)
			return "5"
		else
			return "0"

/*
	holomap stuff
*/
/obj/machinery/computer/crew/proc/deactivate_holomap()
	closeTextview()
	if(activator && activator.client)
		activator.client.images -= holomap_images
		activator.client.screen -= holomap_tooltips
	activator = null

	var/holomap_bgmap = "cmc_\ref[src]_[holomap_z]"
	if(holomap_bgmap in holomap_cache)
		var/image/bgmap = holomap_cache[holomap_bgmap]
		animate(bgmap , alpha = 0, time = 5, easing = LINEAR_EASING)

	holomap_images.len = 0
	holomap_tooltips.len = 0
	textview.len = 0
	freeze = 0

/obj/machinery/computer/crew/proc/togglemap(mob/user)
	if(user.isUnconscious())
		return

	if(activator)
		if(activator != user)
			to_chat(user, "<span class='notice'>Someone is already using the holomap.</span>")
			return
		deactivate_holomap()
		to_chat(user, "<span class='notice'>You disable the holomap.</span>")
	else
		activator = user
		var/list/all_ui_z_levels = holomap_z_levels_mapped | holomap_z_levels_unmapped
		for(var/z_level in all_ui_z_levels)
			var/holomap_bgmap = "cmc_\ref[src]_[z_level]"
			if(!(holomap_bgmap in holomap_cache))
				var/image/background = image('icons/480x480.dmi', "stationmap_blue")
				if(z_level in holomap_z_levels_mapped)
					if(z_level == STATION_Z || z_level == ASTEROID_Z || z_level == DERELICT_Z)
						var/image/station_outline = image(holoMiniMaps[z_level])
						station_outline.color = "#DEE7FF"
						station_outline.alpha = 200
						var/image/station_areas = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPAREAS+"_[z_level]"])
						station_areas.alpha = 150
						background.overlays += station_areas
						background.overlays += station_outline
				background.alpha = 0
				background.layer = ABOVE_HUD_LAYER
				holomap_cache[holomap_bgmap] = background

		//z2 override if nukeops or voxraider
		if(holomap_filter & (HOLOMAP_FILTER_VOX | HOLOMAP_FILTER_NUKEOPS))
			var/holomap_bgmap = "cmc_\ref[src]_2"
			var/image/background = image('icons/480x480.dmi', "stationmap_blue")
			var/image/station_outline = image(centcommMiniMaps["[holomap_filter]"])
			station_outline.color = "#DEE7FF"
			station_outline.alpha = 200
			background.overlays += station_outline
			background.alpha = 0
			background.layer = ABOVE_HUD_LAYER
			holomap_cache[holomap_bgmap] = background
			holomap_z_levels_unmapped |= CENTCOMM_Z

		process()
		to_chat(user, "<span class='notice'>You enable the holomap.</span>")

/obj/machinery/computer/crew/process()
	update_holomap()

/obj/machinery/computer/crew/proc/handle_sanity()
	if((!activator) || (!activator.client) || (get_dist(activator.loc,src.loc) > 1) || (holoMiniMaps[holomap_z] == null) || (stat & (BROKEN|NOPOWER)))
		return FALSE
	return TRUE

/obj/machinery/computer/crew/proc/update_holomap()
	if(!handle_sanity())
		deactivate_holomap()
		return

	if(freeze)
		return

	activator.client.images -= holomap_images
	activator.client.screen -= holomap_tooltips

	holomap_images.len = 0
	holomap_tooltips.len = 0
	textview.len = 0

	var/image/bgmap
	var/holomap_bgmap = "cmc_\ref[src]_[holomap_z]"

	bgmap = holomap_cache[holomap_bgmap]
	//bgmap.color = holomap_color
	bgmap.plane = HUD_PLANE
	bgmap.layer = HUD_BASE_LAYER
	bgmap.loc = activator.hud_used.holomap_obj

	animate(bgmap, alpha = 255, time = 5, easing = LINEAR_EASING)

	holomap_images += bgmap

	addCrewToHolomap()

	if(textview_updatequeued)
		updateTextView()

	updateUI()

	activator.client.images |= holomap_images
	activator.client.screen |= holomap_tooltips

/obj/machinery/computer/crew/proc/updateUI()
	var/uid = "ui_btns_\ref[activator]_\ref[src]"
	if(!cmc_holomap_cache[uid])
		var/list/all_ui_z_levels = sortList(holomap_z_levels_mapped | holomap_z_levels_unmapped, cmp=/proc/cmp_numeric_asc)
		var/ui_offset = 12-all_ui_z_levels.len
		var/list/ui_btns = list(new /obj/abstract/screen/interface(null,activator,src,"text",'icons/cmc/buttons.dmi',"button_text","WEST+[ui_offset],SOUTH+13"))
		for (var/z_level in all_ui_z_levels)
			ui_offset += 1
			ui_btns += new /obj/abstract/screen/interface(null,activator,src,"[z_level]",'icons/cmc/buttons.dmi',"button_[z_level]","WEST+[ui_offset],SOUTH+13")
		ui_btns += new /obj/abstract/screen/interface(null,activator,src,"exit",'icons/cmc/buttons.dmi',"button_cross","WEST+13,SOUTH+13")
		cmc_holomap_cache[uid] = ui_btns

	holomap_tooltips += cmc_holomap_cache[uid]

/*
	Tooltip interface
*/
/obj/abstract/screen/interface/tooltip
	var/title
	var/content
	var/parseAdd //Additional stuff to parse to chat

/obj/abstract/screen/interface/tooltip/proc/setInfo(var/T, var/C, var/A = "")
	title = T
	content = C
	parseAdd = A

/obj/abstract/screen/interface/tooltip/MouseEntered(location,control,params)
	openToolTip(user, src, params, title = title, content = content)

/obj/abstract/screen/interface/tooltip/MouseExited(location,control,params)
	closeToolTip(user)

/obj/abstract/screen/interface/tooltip/Click(location,control,params)
	..()
	parseToChat()

/obj/abstract/screen/interface/tooltip/proc/parseToChat()
	to_chat(user, parseAdd)

/obj/abstract/screen/interface/tooltip/CrewIcon
	var/obj/machinery/computer/crew/CMC

/obj/abstract/screen/interface/tooltip/CrewIcon/proc/setCMC(var/obj/machinery/computer/crew/CM)
	CMC = CM

/obj/abstract/screen/interface/tooltip/CrewIcon/Click(location,control,params)
	parseToChat()

/obj/abstract/screen/interface/tooltip/CrewIcon/MouseEntered(location,control,params)
	if(CMC) CMC.freeze = 1
	..()

/obj/abstract/screen/interface/tooltip/CrewIcon/MouseExited(location,control,params)
	if(CMC) CMC.freeze = 0
	..()

/*
	Textview procs
*/
/obj/machinery/computer/crew/Topic(href, href_list)
	if(href_list["close"])
		closeTextview()
		return
	if(href_list["toggle"])
		textview_updatequeued = textview_updatequeued ? 0 : 1
		updateTextView()
		return

/obj/machinery/computer/crew/proc/openTextview()
	textview_updatequeued = 1
	if(activator.client)
		var/datum/asset/simple/C = new/datum/asset/simple/cmc_css_icons()
		send_asset_list(activator.client, C.assets)
	updateTextView()

/obj/machinery/computer/crew/proc/updateTextView()
	//styles
	var/t = "<html><head><title>Crew Monitor</title><link rel='stylesheet' type='text/css' href='cmc.css'/></head><body>"

	t += "<kbd><b class='fuckbyond'>Crew Monitoring</b><a class='fuckbyond' href='?src=\ref[src];toggle=1'>" + (textview_updatequeued ? "Disable Updating" : "Enable Updating") + "</a><a class='fuckbyond' href='?src=\ref[src];close=1'>Close</a><hr><br><table align='center'><tr><th><u>Name</u></th><th><u>Vitals</u></th><th><u>Position</u></th></tr>"

	//adding table rows
	for(var/i=1, i<=textview.len, i++)
		t += "<tr>" + textview[i] + "</tr>"

	t += "</table></kbd></body></html>"

	activator << browse(t, "window=crewcomp;size=900x600")

/obj/machinery/computer/crew/proc/closeTextview()
	textview_updatequeued = 0
	activator << browse(null, "window=crewcomp")
