var/list/cmc_holomap_cache = list(list(), list())

#define CMC_CACHE_CREW 1
#define CMC_CACHE_UI 2

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
	var/holomap_filter //HOLOMAP_FILTER_CREW
	var/holomap_z = STATION_Z
	var/list/holomap_tooltips = list()
	var/freeze = 0

/obj/machinery/computer/crew/New()
	..()
	holomap_filter = !holomap_filter ? HOLOMAP_FILTER_CREW : holomap_filter

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

	for(var/image/I in holomap_images)
		animate(I)

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
		process()
		to_chat(user, "<span class='notice'>You enable the holomap.</span>")
		if(holoMiniMaps[holomap_z] == null) to_chat(user, "yaya")

/obj/machinery/computer/crew/process()
	update_holomap()

/obj/machinery/computer/crew/proc/handle_sanity()
	if((!activator) || (!activator.client) || (get_dist(activator.loc,src.loc) > 1) || (holoMiniMaps[holomap_z] == null) || (stat & (BROKEN|NOPOWER)))
		return FALSE
	return TRUE

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
		//var/area/player_area = get_area(H) for textview later on

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
					addCrewMarker(pos, H, name, assignment, life_status, list(dam1, dam2, dam3, dam4))
				else
					to_chat(activator, "You need to add a Textview, Paul. Someone doesn't have tracking on.")

	for(var/mob/living/carbon/brain/B in mob_list)
		var/obj/item/device/mmi/M = B.loc
		//var/area/parea = get_area(B)

		if(istype(M.loc,/obj/item/weapon/storage/belt/silicon))
			continue

		var/turf/pos = get_turf(B)
		if(pos && pos.z != CENTCOMM_Z && (pos.z == holomap_z) && istype(M) && M.brainmob == B && !isrobot(M.loc))
			addSiliconMarker(pos, B)

//interface with tooltip on mouseover
/obj/abstract/screen/interface/tooltip
	var/title
	var/content
	var/mob/activator

/obj/abstract/screen/interface/tooltip/proc/setInfo(var/T, var/C, var/mob/A)
	title = T
	content = C
	activator = A

/obj/abstract/screen/interface/tooltip/MouseEntered(location,control,params)
	openToolTip(activator, src, params, title = title, content = content)

/obj/abstract/screen/interface/tooltip/MouseExited(location,control,params)
	closeToolTip(activator)

//so we can freeze on mouseover
/obj/abstract/screen/interface/tooltip/CrewIcon
	var/obj/machinery/computer/crew/CMC

/obj/abstract/screen/interface/tooltip/CrewIcon/proc/setCMC(var/obj/machinery/computer/crew/CM)
	CMC = CM

/obj/abstract/screen/interface/tooltip/CrewIcon/MouseEntered(location,control,params)
	if(CMC) CMC.freeze = 1
	..()

/obj/abstract/screen/interface/tooltip/CrewIcon/MouseExited(location,control,params)
	if(CMC) CMC.freeze = 0
	..()

/obj/machinery/computer/crew/proc/addSiliconMarker(var/turf/TU, var/mob/living/carbon/brain/B)
	if(!TU || !B)
		return

	var/uid = "\ref[B]"

	if(!istype(cmc_holomap_cache[CMC_CACHE_CREW][uid], /obj/abstract/screen/interface/tooltip/CrewIcon))
		cmc_holomap_cache[CMC_CACHE_CREW][uid] = new /obj/abstract/screen/interface/tooltip/CrewIcon(null,activator,src,null,'icons/holomap_markers.dmi',"ert1")

	var/obj/abstract/screen/interface/tooltip/CrewIcon/I = cmc_holomap_cache[CMC_CACHE_CREW][uid]

	//modulo magic for position
	var/nomod_x = round(TU.x / 32)
	var/nomod_y = round(TU.y / 32)
	I.screen_loc = "WEST+[nomod_x]:[TU.x%32 - 8],SOUTH+[nomod_y]:[TU.y%32 - 8]" //- 8 cause the icon is 16px wide

	I.setInfo("[B]", "[B.emp_damage]", activator)
	I.setCMC(src)
	I.name = "[B]"

	holomap_tooltips += I

/obj/machinery/computer/crew/proc/addCrewMarker(var/turf/TU, var/mob/living/carbon/human/H, var/name = "Unknown", var/job = "", var/stat = 0, var/list/damage = list(0,0,0,0))
	if(!TU || !H)
		return

	var/uid = "\ref[H]"

	//creating the title with name | job - Dead/Alive
	var/title = "[name]" + ((job != "") ? " | [job]" : "") + ((stat == 2) ? " - DEAD" : " - ALIVE")

	//creating the content with damage and some css coloring
	var/content = "Damage not available"
	if(damage.len == 4)
		content = "<span style='color: #0000FF'>[damage[1]]</span> | <span style='color: #00CD00'>[damage[2]]</span> | <span style='color: #ffa500'>[damage[3]]</span> | <span style='color: #ff0000'>[damage[4]]</span>"

	if(!istype(cmc_holomap_cache[CMC_CACHE_CREW][uid], /obj/abstract/screen/interface/tooltip/CrewIcon))
		cmc_holomap_cache[CMC_CACHE_CREW][uid] = new /obj/abstract/screen/interface/tooltip/CrewIcon(null,activator,src,null,'icons/cmc/sensor_markers.dmi')
		cmc_holomap_cache[CMC_CACHE_CREW][uid].transform *= 1.2

	var/obj/abstract/screen/interface/tooltip/CrewIcon/I = cmc_holomap_cache[CMC_CACHE_CREW][uid]

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

	I.setInfo(title, content, activator)
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
	var/holomap_bgmap


	holomap_bgmap = "background_\ref[src]_[holomap_z]"

	if(!(holomap_bgmap in holomap_cache))
		/*if(holomap_z == STATION_Z)
			holomap_cache[holomap_bgmap] = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAP+"_[holomap_z]"])
		else*/
		holomap_cache[holomap_bgmap] = image(holoMiniMaps[holomap_z])

	bgmap = holomap_cache[holomap_bgmap]
	bgmap.plane = HUD_PLANE
	bgmap.layer = HUD_BASE_LAYER
	if(holomap_z != STATION_Z)
		bgmap.color = holomap_color
	bgmap.loc = activator.hud_used.holomap_obj
	bgmap.overlays.len = 0

	//don't have markers, yet?
	/*for(var/marker in holomap_markers)
		var/datum/holomap_marker/holomarker = holomap_markers[marker]
		if(holomarker.z == holomap_z && holomarker.filter & holomap_filter)
			var/image/markerImage = image(holomarker.icon,holomarker.id)
			markerImage.plane = FLOAT_PLANE
			markerImage.layer = FLOAT_LAYER
			if(map.holomap_offset_x.len >= holomap_z)
				markerImage.pixel_x = holomarker.x+holomarker.offset_x+map.holomap_offset_x[holomap_z]
				markerImage.pixel_y = holomarker.y+holomarker.offset_y+map.holomap_offset_y[holomap_z]
			else
				markerImage.pixel_x = holomarker.x+holomarker.offset_x
				markerImage.pixel_y = holomarker.y+holomarker.offset_y
			markerImage.appearance_flags = RESET_COLOR
			bgmap.overlays += markerImage*/

	animate(bgmap, alpha = 200, time = 5, easing = LINEAR_EASING)
	holomap_images += bgmap

	addCrewToHolomap()

	updateUI()

	activator.client.images |= holomap_images
	activator.client.screen |= holomap_tooltips

/obj/machinery/computer/crew/proc/updateUI()
	if(cmc_holomap_cache[CMC_CACHE_UI].len == 0)
		cmc_holomap_cache[CMC_CACHE_UI] |= list(new /obj/abstract/screen/interface(null,activator,src,"text",'icons/cmc/buttons.dmi',"button_text","WEST+8,SOUTH+13"), new /obj/abstract/screen/interface(null,activator,src,"1",'icons/cmc/buttons.dmi',"button_1","WEST+9,SOUTH+13"), new /obj/abstract/screen/interface(null,activator,src,"3",'icons/cmc/buttons.dmi',"button_3","WEST+10,SOUTH+13"), new /obj/abstract/screen/interface(null,activator,src,"4",'icons/cmc/buttons.dmi',"button_4","WEST+11,SOUTH+13"), new /obj/abstract/screen/interface(null,activator,src,"5",'icons/cmc/buttons.dmi',"button_5","WEST+12,SOUTH+13"), new /obj/abstract/screen/interface(null,activator,src,"exit",'icons/cmc/buttons.dmi',"button_cross","WEST+13,SOUTH+13"))

	holomap_tooltips += cmc_holomap_cache[CMC_CACHE_UI]

/obj/machinery/computer/crew/interface_act(mob/user, action)
	if(action == "exit")
		deactivate_holomap()
		return

	if(action == "text")
		to_chat(activator, "add the textview already")
		return

	holomap_z = text2num(action)
	update_holomap() //for that nice ui feedback uhhhh
