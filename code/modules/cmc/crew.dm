var/list/obj/abstract/screen/interface/tooltip/CrewIcon/cmc_holomap_cache = list()
#define ENTRY_SEE_X 1
#define ENTRY_SEE_Y 2
#define ENTRY_MOB 3
#define ENTRY_NAME 4
#define ENTRY_ASSIGNMENT 5
#define ENTRY_STAT 6
#define ENTRY_DAMAGE 7
#define ENTRY_AREA 8
#define ENTRY_IJOB 9
#define ENTRY_POS 10
#define ENTRY_SEE_Z 11

#define DAMAGE_OXYGEN 1
#define DAMAGE_TOXIN 2
#define DAMAGE_FIRE 3
#define DAMAGE_BRUTE 4

/*
Crew Monitor by Paul, based on the holomaps by Deity
*/
/obj/machinery/computer/crew
	name = "Crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_state = "crew"
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 250
	active_power_usage = 500
	circuit = "/obj/item/weapon/circuitboard/crew"

	light_color = LIGHT_COLOR_BLUE
	light_range_on = 2
	_using = new()

	/*
	Holomap stuff
	*/
	//DONT touch, integral to the inner workings
	var/list/list/holomap_images = list() //list of lists of images for the people using the console
	var/list/holomap_z = list() //list of _using selected z_levels
	var/list/list/holomap_tooltips = list() //list of lists of markers for the people using the console
	var/list/freeze = list() //list of _using set freeze
	var/list/list/entries = list() //list of all crew, which has sensors >= 1
	var/list/textview_updatequeued = list() //list of _using set textviewupdate setting
	var/list/holomap = list() //list of _using set holomap-enable setting
	var/list/jobs = list( //needed for formatting, stolen from the old cmc
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
		"Orderly" = 26,
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

	//DO touch, for mappers to varedit
	var/holomap_filter //can make the cmc display syndie/vox hideout

/obj/machinery/computer/crew/Destroy()
	deactivateAll()
	..()

/obj/machinery/computer/crew/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		return
	initializeUser(user)

/*
GENERAL PROCS
*/
//initializes all important vars for a new user
/obj/machinery/computer/crew/proc/initializeUser(var/mob/user)
	var/uid = "\ref[user]"
	_using += user
	holomap_images[uid] = list()
	holomap_tooltips[uid] = list()
	freeze[uid] = 0
	holomap_z[uid] = 0 // 0 means show all z-levels
	textview_updatequeued[uid] = 1
	holomap[uid] = 0
	scanCrew() //else the first user has to wait for process to fire
	tgui_interact(user)

//ticks to update holomap/textview
/obj/machinery/computer/crew/process()
	if((!_using) || (_using.len == 0) || (stat & (BROKEN|NOPOWER|FORCEDISABLE))) //sanity
		deactivateAll()
		return

	scanCrew()

	for(var/mob/user in _using)
		processUser(user)

/obj/machinery/computer/crew/proc/processUser(var/mob/user)
	var/uid = "\ref[user]"
	var/datum/tgui/ui = SStgui.get_open_ui(user, src)
	if(!ui)
		deactivate(user)
		return

	// Build list of valid vLevel IDs (those with gps_allowed)
	var/list/valid_vlevels = list()
	for(var/datum/virtual_z/V in map.vLevels)
		if(V.gps_allowed)
			valid_vlevels += V.id

	// 0 means "ALL" vLevels, which is always valid
	if(holomap_z[uid] != 0 && !(holomap_z[uid] in valid_vlevels)) //catching some more unwanted behaviours
		if(valid_vlevels.len > 0)
			holomap_z[uid] = valid_vlevels[1]
		else
			deactivate(user)

	if(textview_updatequeued[uid])
		SStgui.update_uis(src)

	if(!freeze[uid])
		updateVisuals(user)

//kicks out all users
/obj/machinery/computer/crew/proc/deactivateAll()
	for(var/mob/user in _using)
		deactivate(user)

//disables both the textview and the holomap
/obj/machinery/computer/crew/proc/deactivate(var/mob/user)
	var/uid = "\ref[user]"
	closeHolomap(user)
	closeTextview(user)
	_using -= user
	holomap_images[uid] = null
	holomap_tooltips[uid] = null
	freeze[uid] = null
	holomap_z[uid] = null
	textview_updatequeued[uid] = null
	holomap[uid] = null

//scans every crewmember/mmi and puts them into their respective entrylist
/obj/machinery/computer/crew/proc/scanCrew()
	//clearing all vLevel entries
	entries = list()
	for(var/datum/virtual_z/V in map.vLevels)
		if(V.gps_allowed)
			entries["[V.id]"] = list()

	//looping though carbons
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.iscorpse)
			continue

		var/name
		var/assignment
		var/life_status
		var/list/damage
		var/player_area
		var/ijob
		var/see_x
		var/see_y
		var/see_z

		// z == 0 means mob is inside object, check if they are wearing a uniform
		if(istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = H.w_uniform

			if (U.has_sensor && U.sensor_mode)
				// Always get the turf to check gps_allowed
				var/turf/entry_turf = get_turf(H)
				if(!entry_turf)
					continue

				// Special case: If the mob is inside an object confirm the z-level on turf level.
				if (H.z == 0 && entry_turf.z != z)
					continue

				// Get virtual z-level and check gps_allowed
				var/datum/virtual_z/entry_vz = entry_turf.get_virtual_z()
				if(!entry_vz || !entry_vz.gps_allowed)
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
					damage = list(round(H.getOxyLoss(),1), round(H.getToxLoss(),1), round(H.getFireLoss(),1), round(H.getBruteLoss(),1))

				// Only show location data if sensor_mode == 3 and not on a planet
				if(U.sensor_mode == 3 && !entry_vz.planet)
					player_area = format_text(get_area(H).name)
					see_x = H.vx() - get_world_x_offset(entry_vz.id)
					see_y = H.vy() - get_world_y_offset(entry_vz.id)
					see_z = entry_vz.id

				var/vz_key = "[entry_vz.id]"
				if(vz_key in entries)
					entries[vz_key][++entries[vz_key].len] = list(see_x, see_y, H, name, assignment, life_status, damage, player_area, ijob, entry_turf, see_z)

	for(var/mob/living/carbon/brain/B in mob_list)
		var/obj/item/device/mmi/M = B.loc
		var/parea = "ERROR"
		// area can be null in the case of nullspacing
		var/area/A = get_area(B)
		if(!isnull(A))
			parea = format_text(A.name)

		if(istype(M.loc,/obj/item/weapon/storage/belt/silicon))
			continue

		var/turf/pos = get_turf(B)
		var/datum/virtual_z/vz = pos?.get_virtual_z()
		if(!isnull(pos) && vz && vz.gps_allowed && istype(M) && M.brainmob == B && !isrobot(M.loc))
			var/see_x = pos.x - get_world_x_offset(vz.id)
			var/see_y = pos.y - get_world_y_offset(vz.id)
			var/see_z = vz.id
			var/vz_key = "[vz.id]"
			if(vz_key in entries)
				entries[vz_key][++entries[vz_key].len] = list(see_x, see_y, B, "[B]", "MMI", null, null, parea, 60, pos, see_z)

//helper to get healthstate, used in both holomap and textview
/obj/machinery/computer/crew/proc/getLifeIcon(var/list/damage)
	var/health = 0
	for(var/dam in damage)
		health += dam
	health = round(100 - health)
	switch (health)
		if(100)
			return "0"
		if(80 to 99)
			return "1"
		if(60 to 79)
			return "2"
		if(40 to 59)
			return "3"
		if(20 to 39)
			return "4"
		else
			return "5"

/*
HOLOMAP PROCS
*/
//initializes the holomap
/obj/machinery/computer/crew/proc/openHolomap(var/mob/user)
	// Create holomap images for each vLevel with gps_allowed
	for(var/datum/virtual_z/V in map.vLevels)
		if(!V.gps_allowed)
			continue
		var/holomap_bgmap = "cmc_\ref[src]_\ref[user]_[V.id]"
		if(!(holomap_bgmap in holomap_cache))
			var/image/background = image('icons/480x480.dmi', "stationmap_blue")
			var/real_z = V.parent_z.z
			// Check if we have a holomap for the real z-level
			if((holoMiniMaps.len >= real_z) && (holoMiniMaps[real_z] != null))
				if(real_z == map.zMainStation || real_z == map.zAsteroid || real_z == map.zDerelict)
					var/image/station_outline = image(holoMiniMaps[real_z])
					station_outline.color = "#DEE7FF"
					station_outline.alpha = 200
					var/image/station_areas = image(extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPAREAS+"_[real_z]"])
					station_areas.alpha = 150
					background.overlays += station_areas
					background.overlays += station_outline
			background.alpha = 0
			background.plane = HUD_PLANE
			background.layer = HUD_BASE_LAYER
			holomap_cache[holomap_bgmap] = background

	//nukeops or voxraider override for centcomm vLevels
	if(holomap_filter & (HOLOMAP_FILTER_VOX | HOLOMAP_FILTER_NUKEOPS))
		// Find the centcomm vLevel
		for(var/datum/virtual_z/V in map.getAllVLevels())
			if(V.parent_z.z == map.zCentcomm && V.gps_allowed)
				var/holomap_bgmap = "cmc_\ref[src]_\ref[user]_[V.id]"
				var/image/background = image('icons/480x480.dmi', "stationmap_blue")
				var/image/station_outline = image(centcommMiniMaps["[holomap_filter]"])
				station_outline.color = "#DEE7FF"
				station_outline.alpha = 200
				background.overlays += station_outline
				background.alpha = 0
				background.plane = HUD_PLANE
				background.layer = HUD_BASE_LAYER
				holomap_cache[holomap_bgmap] = background
				break

	holomap["\ref[user]"] = 1

//closes the holomap
/obj/machinery/computer/crew/proc/closeHolomap(var/mob/user)
	var/uid = "\ref[user]"
	var/z = holomap_z["\ref[user]"]
	var/holomap_bgmap = "cmc_\ref[src]_\ref[user]_[z]"
	if(holomap_bgmap in holomap_cache)
		var/image/bgmap = holomap_cache[holomap_bgmap]
		animate(bgmap , alpha = 0, time = 5, easing = LINEAR_EASING)

	if(user && user.client)
		user.client.images -= holomap_images[uid]
		user.client.screen -= holomap_tooltips[uid]

	if(holomap_images[uid])
		holomap_images[uid].len = 0
	if(holomap_tooltips[uid])
		holomap_tooltips[uid].len = 0
	freeze[uid] = 0
	holomap[uid] = 0

//sanity for the holomap
/obj/machinery/computer/crew/proc/handle_sanity(var/mob/user)
	if((!user) || (!user.client) || (user.isUnconscious() && !isobserver(user)) || (!(isobserver(user) || issilicon(user)) && (get_dist(user.loc,src.loc) > 1)) || config.skip_minimap_generation || (holoMiniMaps.len < loc.z) || (holoMiniMaps[loc.z] == null) )
		return FALSE
	return TRUE

//updates crewmarkers and map
/obj/machinery/computer/crew/proc/updateVisuals(var/mob/user)
	var/uid = "\ref[user]"
	if(!handle_sanity(user))
		closeHolomap(user)
		return

	//updating holomap
	if(holomap[uid]) // we only repopulate user.client.images if holomap is enabled
		user.client.images -= holomap_images[uid]
		user.client.screen -= holomap_tooltips[uid]
		holomap_images[uid] = new()
		holomap_tooltips[uid] = new()

		var/image/bgmap
		var/vz_id = holomap_z[uid]
		var/holomap_bgmap = "cmc_\ref[src]_\ref[user]_[vz_id]"

		if(z != 0)
			bgmap = holomap_cache[holomap_bgmap]
			if(bgmap)
				bgmap.loc = user.hud_used.holomap_obj

				animate(bgmap, alpha = 255, time = 5, easing = LINEAR_EASING)

				holomap_images[uid] |= bgmap

		var/vz_key = "[vz_id]"
		if(vz_key in entries)
			for(var/entry in entries[vz_key])
				//can only be our vz, so i'm not checking that, only if we have a pos
				if(entry[ENTRY_POS])
					addCrewMarker(user, entry[ENTRY_SEE_X], entry[ENTRY_SEE_Y], entry[ENTRY_MOB], entry[ENTRY_NAME], entry[ENTRY_ASSIGNMENT], entry[ENTRY_STAT], entry[ENTRY_DAMAGE], entry[ENTRY_AREA], entry[ENTRY_POS])

		user.client.images |= holomap_images[uid]
		user.client.screen |= holomap_tooltips[uid]
	else
		user.client.images -= holomap_images[uid]
		user.client.screen -= holomap_tooltips[uid]
		holomap_images[uid] = new()
		holomap_tooltips[uid] = new()

//create actual marker for crew
/obj/machinery/computer/crew/proc/addCrewMarker(var/mob/user, var/see_x, var/see_y, var/mob/living/carbon/H, var/name = "Unknown", var/job = "", var/stat = 0, var/list/damage, var/player_area = "Not Available", var/turf/TU)
	if(!TU || !H || !see_x || !see_y)
		return

	var/uid = "crewmarker_\ref[H]_\ref[user]"
	var/user_uid = "\ref[user]"

	//creating the title with name | job - Dead/Alive
	var/title = "[name]" + ((job != "") ? " ([job])" : "") + ((stat == DEAD) ? " - DEAD" : " - ALIVE")

	//creating the content with damage and some css coloring
	var/content = "Not Available"
	if(damage)
		content = "(<span style='color: #0080ff'>[damage[DAMAGE_OXYGEN]]</span>/<span style='color: #00CD00'>[damage[DAMAGE_TOXIN]]</span>/<span style='color: #ffa500'>[damage[DAMAGE_FIRE]]</span>/<span style='color: #ff0000'>[damage[DAMAGE_BRUTE]]</span>)"

	content += "<br>[player_area]"

	if(!istype(cmc_holomap_cache[uid], /obj/abstract/screen/interface/tooltip/CrewIcon))
		cmc_holomap_cache[uid] = new /obj/abstract/screen/interface/tooltip/CrewIcon(null,user,src,null,'icons/cmc/sensor_markers.dmi')
		cmc_holomap_cache[uid].plane = ABOVE_HUD_PLANE

	var/obj/abstract/screen/interface/tooltip/CrewIcon/I = cmc_holomap_cache[uid]

	var/icon
	if(istype(H, /mob/living/carbon/human))
		if(stat != DEAD)
			icon = getLifeIcon(damage)
		else
			icon = "6"
	else
		icon = "7"
	I.icon_state = "sensor_health[icon]"

	var/posx = TU.x
	var/posy = TU.y
	if(map.holomap_offset_x.len >= TU.z) // eg. z3 is centered on derelict
		posx = min(posx+map.holomap_offset_x[TU.z],((2 * world.view + 1)*WORLD_ICON_SIZE))
		posy = min(posy+map.holomap_offset_y[TU.z],((2 * world.view + 1)*WORLD_ICON_SIZE))

	//modulo magic for position
	var/nomod_x = round(posx / 32)
	var/nomod_y = round(posy / 32)
	I.screen_loc = "WEST+[nomod_x]:[posx%32 - 8],SOUTH+[nomod_y]:[posy%32 - 8]" //- 8 cause the icon is 16px wide

	I.setInfo(title, content, "Coords: [see_x]|[see_y]")
	I.setCMC(src)
	I.name = name

	holomap_tooltips[user_uid] |= I

/*
TGUI PROCS
*/
/obj/machinery/computer/crew/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CrewMonitor")
		ui.open()
	var/uid = "\ref[user]"
	ui.set_autoupdate(textview_updatequeued[uid])

/obj/machinery/computer/crew/ui_data(mob/user)
	var/uid = "\ref[user]"
	var/list/data = list()

	// Get current vLevel setting (0 = ALL)
	var/current_z = holomap_z[uid]
	if(isnull(current_z))
		current_z = 0
		holomap_z[uid] = 0

	data["currentZLevel"] = current_z

	// Build list of vLevels with gps_allowed and their holomap availability
	var/list/vlevel_data = list()
	for(var/datum/virtual_z/V in map.vLevels)
		if(V.gps_allowed)
			var/real_z = V.parent_z.z
			var/has_holomap = (holoMiniMaps.len >= real_z) && (holoMiniMaps[real_z] != null)
			vlevel_data += list(list(
				"id" = V.id,
				"name" = V.name,
				"hasHolomap" = has_holomap
			))

	data["zLevels"] = vlevel_data
	data["holomapEnabled"] = holomap[uid]
	data["holomapAvailable"] = handle_sanity(user)
	data["autoUpdate"] = textview_updatequeued[uid]

	// Build crew list - if current_z is 0, show all vLevels
	var/list/crew_data = list()
	var/count = 0
	var/list/vlevels_to_scan = list()
	if(current_z == 0)
		for(var/datum/virtual_z/V in map.vLevels)
			if(V.gps_allowed)
				vlevels_to_scan += "[V.id]"
	else
		vlevels_to_scan += "[current_z]"

	for(var/vz_key in vlevels_to_scan)
		if(!(vz_key in entries))
			continue
		for(var/entry in entries[vz_key])
			count++
			var/list/crew_entry = list()

			crew_entry["name"] = entry[ENTRY_NAME]
			crew_entry["job"] = entry[ENTRY_ASSIGNMENT]
			crew_entry["vitals"] = entry[ENTRY_STAT]
			crew_entry["area"] = entry[ENTRY_AREA]

			if(entry[ENTRY_SEE_X] && entry[ENTRY_SEE_Y])
				crew_entry["see_x"] = entry[ENTRY_SEE_X]
				crew_entry["see_y"] = entry[ENTRY_SEE_Y]
				crew_entry["see_z"] = entry[ENTRY_SEE_Z]
			else
				crew_entry["see_x"] = null
				crew_entry["see_y"] = null
				crew_entry["see_z"] = null

			if(entry[ENTRY_DAMAGE])
				crew_entry["damage"] = list(
					"oxygen" = entry[ENTRY_DAMAGE][DAMAGE_OXYGEN],
					"toxin" = entry[ENTRY_DAMAGE][DAMAGE_TOXIN],
					"fire" = entry[ENTRY_DAMAGE][DAMAGE_FIRE],
					"brute" = entry[ENTRY_DAMAGE][DAMAGE_BRUTE]
				)
			else
				crew_entry["damage"] = null

			// Determine role category
			var/ijob = entry[ENTRY_IJOB]
			var/role
			switch(ijob)
				if(0) role = "cap"
				if(10 to 19) role = "sec"
				if(20 to 29) role = "med"
				if(30 to 39) role = "sci"
				if(40 to 49) role = "eng"
				if(50 to 59) role = "car"
				if(60 to 69) role = "silicon"
				if(200 to 229) role = "cent"
				else role = "unk"
			crew_entry["role"] = role

			// Determine icon
			var/mob/living/carbon/H = entry[ENTRY_MOB]
			var/stat = entry[ENTRY_STAT]
			var/icon
			if(istype(H, /mob/living/carbon/human))
				if(stat != DEAD)
					if(entry[ENTRY_DAMAGE])
						icon = getLifeIcon(entry[ENTRY_DAMAGE])
					else
						icon = "0"
				else
					icon = "6"
			else
				icon = "7"
			crew_entry["icon"] = icon
			crew_entry["count"] = count

			crew_data += list(crew_entry)

	data["detectedCrew"] = crew_data
	data["detected"] = crew_data.len > 0

	return data

/obj/machinery/computer/crew/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	var/uid = "\ref[usr]"

	switch(action)
		if("toggle_update")
			textview_updatequeued[uid] = !textview_updatequeued[uid]
			ui.set_autoupdate(textview_updatequeued[uid])
			return TRUE

		if("toggle_holomap")
			if(holomap[uid])
				closeHolomap(usr)
			else
				if(handle_sanity(usr))
					openHolomap(usr)
					processUser(usr)
			return TRUE

		if("set_zlevel")
			var/num = params["zlevel"]
			if(!isnum(num))
				num = text2num(num)
			if(isnull(num))
				return FALSE

			// 0 means "ALL" z-levels, otherwise must be a valid z-level
			holomap_z[uid] = num
			processUser(usr)
			return TRUE

	return FALSE

//makes sure everything is set for us to have a closed window and keep it that way
/obj/machinery/computer/crew/proc/closeTextview(var/mob/user)
	textview_updatequeued["\ref[user]"] = 0
	var/datum/tgui/ui = SStgui.get_open_ui(user, src)
	if(ui)
		ui.close()

/*
Tooltip interface
*/
//BASE TOOLTIP
/obj/abstract/screen/interface/tooltip
	var/title //tooltip title
	var/content //tooltip content
	var/parseAdd //Additional stuff to parse to chat

/obj/abstract/screen/interface/tooltip/proc/setInfo(var/T, var/C, var/A = "")
	title = T
	content = C
	parseAdd = A

/obj/abstract/screen/interface/tooltip/MouseEntered(location,control,params)
	//openToolTip(user, src, params, title = title, content = content)
	usr.client?.tooltips.show(src, mouse=params, title=title, content=content)

/obj/abstract/screen/interface/tooltip/MouseExited(location,control,params)
	usr.client?.tooltips.hide()

/obj/abstract/screen/interface/tooltip/Click(location,control,params)
	..()
	parseToChat()

/obj/abstract/screen/interface/tooltip/proc/parseToChat()
	to_chat(user, parseAdd)

//CMC TOOLTIP
//subclass to do some cmc-specific stuff like setting freeze and parsing to chat without supercall
/obj/abstract/screen/interface/tooltip/CrewIcon
	var/obj/machinery/computer/crew/CMC

/obj/abstract/screen/interface/tooltip/CrewIcon/proc/setCMC(var/obj/machinery/computer/crew/CM)
	CMC = CM

/obj/abstract/screen/interface/tooltip/CrewIcon/Click(location,control,params)
	parseToChat() //no supercall so we don't trigger interface_act (we don't want that)

/obj/abstract/screen/interface/tooltip/CrewIcon/MouseEntered(location,control,params)
	if(CMC)
		var/uid = "\ref[user]"
		CMC.freeze[uid] = 1
	..()

/obj/abstract/screen/interface/tooltip/CrewIcon/MouseExited(location,control,params)
	if(CMC)
		var/uid = "\ref[user]"
		CMC.freeze[uid] = 0
	..()


#undef ENTRY_SEE_X
#undef ENTRY_SEE_Y
#undef ENTRY_MOB
#undef ENTRY_NAME
#undef ENTRY_ASSIGNMENT
#undef ENTRY_STAT
#undef ENTRY_DAMAGE
#undef ENTRY_AREA
#undef ENTRY_IJOB
#undef ENTRY_POS
#undef ENTRY_SEE_Z
#undef DAMAGE_OXYGEN
#undef DAMAGE_TOXIN
#undef DAMAGE_FIRE
#undef DAMAGE_BRUTE
