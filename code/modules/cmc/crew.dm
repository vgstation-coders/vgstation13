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
	var/list/holomap_z_levels_mapped = list(STATION_Z, ASTEROID_Z, DERELICT_Z)
	var/list/holomap_z_levels_unmapped = list(TELECOMM_Z)

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

/obj/machinery/computer/crew/proc/deactivate_holomap()
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
	freeze = 0

//modified version of /obj/item/clothing/accessory/holomap_chip/proc/togglemap()
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
					if(z_level == CENTCOMM_Z && holomap_filter)
						var/image/station_outline = image(centcommMiniMaps["[holomap_filter]"]
						station_outline.color = "#DEE7FF"
						station_outline.alpha = 200
						background.overlays += station_outline
					//add cases for other z-levels?
				background.alpha = 0
				holomap_cache[holomap_bgmap] = background
		process()
		to_chat(user, "<span class='notice'>You enable the holomap.</span>")

/obj/machinery/computer/crew/process()
	update_holomap()

/obj/machinery/computer/crew/proc/handle_sanity()
	if((!activator) || (!activator.client) || (get_dist(activator.loc,src.loc) > 1) || (holoMiniMaps[holomap_z] == null) || (stat & (BROKEN|NOPOWER)))
		return FALSE
	return TRUE

/obj/machinery/computer/crew/proc/addCrewToTextview(var/turf/TU, var/mob/living/carbon/human/H, var/name = "Unknown", var/job = "No job", var/stat = 0, var/list/damage = list(0,0,0,0), var/area/player_area = "Area not available")
	var/list/string = list("[name] | [job]"+ ((stat == 2) ? " - DEAD" : " - ALIVE"))
	string += damage ? "<span style='color: #0080ff'>[damage[1]]</span> | <span style='color: #00CD00'>[damage[2]]</span> | <span style='color: #ffa500'>[damage[3]]</span> | <span style='color: #ff0000'>[damage[4]]</span>" : "Damage not available"
	string += TU ? "[TU.x]|[TU.y]|[TU.z] | [player_area]" : "Position not available"
	textview += string.Join(" <=> ")

/obj/machinery/computer/crew/proc/addSiliconToTextview(var/turf/TU, var/mob/living/carbon/brain/B, var/area/player_area, var/emp_damage)
	var/list/string = list("[B]")
	string += emp_damage ? "[emp_damage]" : "Damage not available"
	string += TU ? "[TU.x]|[TU.y]|[TU.z] | [player_area]" : "Position not available"

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
				else
					name = "Unknown"
					assignment = ""

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
				addCrewToTextview(pos, H, name, assignment, life_status, list(dam1, dam2, dam3, dam4), player_area)

	for(var/mob/living/carbon/brain/B in mob_list)
		var/obj/item/device/mmi/M = B.loc
		var/area/parea = get_area(B)

		if(istype(M.loc,/obj/item/weapon/storage/belt/silicon))
			continue

		var/turf/pos = get_turf(B)
		if(pos && pos.z != CENTCOMM_Z && (pos.z == holomap_z) && istype(M) && M.brainmob == B && !isrobot(M.loc))
			addSiliconMarker(pos, B, parea, B.emp_damage)
			addSiliconToTextview(pos, B, parea, B.emp_damage)

//interface with tooltip on mouseover
/obj/abstract/screen/interface/tooltip
	var/title
	var/content
	var/parseAdd //Additional stuff to parse to chat

/obj/abstract/screen/interface/tooltip/proc/setInfo(var/T, var/C, var/A)
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
	to_chat(user, title)
	to_chat(user, content)
	to_chat(user, parseAdd)

//so we can freeze on mouseover
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

/obj/machinery/computer/crew/proc/addSiliconMarker(var/turf/TU, var/mob/living/carbon/brain/B, var/area/player_area, var/emp_damage)
	if(!TU || !B)
		return

	var/uid = "crewmarker_\ref[B]_\ref[activator]"

	if(!istype(cmc_holomap_cache[uid], /obj/abstract/screen/interface/tooltip/CrewIcon))
		cmc_holomap_cache[uid] = new /obj/abstract/screen/interface/tooltip/CrewIcon(null,activator,src,null,'icons/holomap_markers.dmi',"ert1")
		cmc_holomap_cache[uid].layer = ABOVE_HUD_LAYER

	var/obj/abstract/screen/interface/tooltip/CrewIcon/I = cmc_holomap_cache[uid]

	//modulo magic for position
	var/nomod_x = round(TU.x / 32)
	var/nomod_y = round(TU.y / 32)
	I.screen_loc = "WEST+[nomod_x]:[TU.x%32 - 8],SOUTH+[nomod_y]:[TU.y%32 - 8]" //- 8 cause the icon is 16px wide

	I.setInfo("[B]", "[emp_damage]<br>[player_area]", "Coords: [TU.x]|[TU.y]|[TU.z]")
	I.setCMC(src)
	I.name = "[B]"

	holomap_tooltips += I

/obj/machinery/computer/crew/proc/addCrewMarker(var/turf/TU, var/mob/living/carbon/human/H, var/name = "Unknown", var/job = "", var/stat = 0, var/list/damage = list(0,0,0,0), var/area/player_area = "Area not available")
	if(!TU || !H)
		return

	var/uid = "crewmarker_\ref[H]_\ref[activator]"

	//creating the title with name | job - Dead/Alive
	var/title = "[name]" + ((job != "") ? " | [job]" : "") + ((stat == 2) ? " - DEAD" : " - ALIVE")

	//creating the content with damage and some css coloring
	var/content = "Damage not available"
	if(damage.len == 4)
		content = "<span style='color: #0080ff'>[damage[1]]</span> | <span style='color: #00CD00'>[damage[2]]</span> | <span style='color: #ffa500'>[damage[3]]</span> | <span style='color: #ff0000'>[damage[4]]</span>"

	content += "<br>[player_area]"

	if(!istype(cmc_holomap_cache[uid], /obj/abstract/screen/interface/tooltip/CrewIcon))
		cmc_holomap_cache[uid] = new /obj/abstract/screen/interface/tooltip/CrewIcon(null,activator,src,null,'icons/cmc/sensor_markers.dmi')
		cmc_holomap_cache[uid].layer = ABOVE_HUD_LAYER

	var/obj/abstract/screen/interface/tooltip/CrewIcon/I = cmc_holomap_cache[uid]

	var/icon = "0"
	if(stat != 2)
		var/health = 0
		for(var/dam in damage)
			health += dam
		health = round(100 - health)
		switch (health)
			if(80 to 99)
				icon = "1"
			if(60 to 79)
				icon = "2"
			if(40 to 59)
				icon = "3"
			if(20 to 39)
				icon = "4"
			else if(health != 100)
				icon = "5"
	else
		icon = "6"
	I.icon_state = "sensor_health[icon]"

	//modulo magic for position
	var/nomod_x = round(TU.x / 32)
	var/nomod_y = round(TU.y / 32)
	I.screen_loc = "WEST+[nomod_x]:[TU.x%32 - 8],SOUTH+[nomod_y]:[TU.y%32 - 8]" //- 8 cause the icon is 16px wide

	I.setInfo(title, content, "Coords: [TU.x]|[TU.y]|[TU.z]")
	I.setCMC(src)
	I.name = name

	holomap_tooltips += I

//modified version of /obj/item/clothing/accessory/holomap_chip/proc/update_holomap()
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

/obj/machinery/computer/crew/interface_act(mob/user, action)
	if(action == "exit")
		deactivate_holomap()
		return

	if(action == "text")
		to_chat(activator, "add the textview already")
		return

	if(text2num(action) != null)
		holomap_z = text2num(action)
	update_holomap() //for that nice ui feedback uhhhh
