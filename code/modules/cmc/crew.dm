var/list/cmc_holomap_cache = list()
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
	use_power = 1
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
	var/list/holomap_images = list() //list of lists of images for the people using the console
	var/list/holomap_z = list() //list of _using selected z_levels
	var/list/holomap_tooltips = list() //list of lists of markers for the people using the console
	var/list/freeze = list() //list of _using set freeze
	var/list/entries = list() //list of all crew, which has sensors >= 1
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
	var/list/holomap_z_levels_mapped = list(STATION_Z, ASTEROID_Z, DERELICT_Z) //all z-level which should be mapped
	var/list/holomap_z_levels_unmapped = list(TELECOMM_Z, SPACEPIRATE_Z) //all z-levels which should not be mapped but should still be scanned for people
	var/defaultZ = STATION_Z //the z_level which everyone looks at when opening the console for the first time

/obj/machinery/computer/crew/Destroy()
	deactivateAll()
	..()

/obj/machinery/computer/crew/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/crew/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(stat & (BROKEN|NOPOWER))
		return
	initializeUser(user)

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
	holomap_z[uid] = defaultZ
	textview_updatequeued[uid] = 1
	holomap[uid] = 0
	scanCrew() //else the first user has to wait for process to fire
	updateTextView(user)

//ticks to update holomap/textview
/obj/machinery/computer/crew/process()
	if((!_using) || (_using.len == 0) || (stat & (BROKEN|NOPOWER))) //sanity
		deactivateAll()
		return

	scanCrew()

	for(var/mob/user in _using)
		processUser(user)

/obj/machinery/computer/crew/proc/processUser(var/mob/user)
	var/uid = "\ref[user]"
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "textview")
	if(!ui)
		deactivate(user)
		return

	if(!(holomap_z[uid] in (holomap_z_levels_mapped | holomap_z_levels_unmapped))) //catching some more unwanted behaviours
		if((holomap_z_levels_mapped | holomap_z_levels_unmapped).len > 0)
			holomap_z[uid] = (holomap_z_levels_mapped | holomap_z_levels_unmapped)[1]
		else
			deactivate(user)

	//apparently STATUS_INTERACTIVE is undefined, so we are gonna use 2
	if(ui.status < 2) //we are not updating YOUR window
		return

	if(textview_updatequeued[uid])
		updateTextView(user)

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
	//clearing all z-level entries
	var/list/all_tracked_z_levels = sortList(holomap_z_levels_mapped | holomap_z_levels_unmapped, cmp=/proc/cmp_numeric_dsc) //z-levels sorted by num
	entries.len = all_tracked_z_levels[1]
	for(var/level in all_tracked_z_levels)
		entries[level] = list()

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

		// z == 0 means mob is inside object, check is they are wearing a uniform
		if(istype(H.w_uniform, /obj/item/clothing/under))
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
					damage = list(round(H.getOxyLoss(),1), round(H.getToxLoss(),1), round(H.getFireLoss(),1), round(H.getBruteLoss(),1))

				if(pos)
					player_area = format_text(get_area(H).name)
					see_x = pos.x - WORLD_X_OFFSET[pos.z]
					see_y = pos.y - WORLD_Y_OFFSET[pos.z]

				//incase we dont get a pos
				var/turf/entry_z = get_turf(H)
				if(entry_z.z in all_tracked_z_levels)
					entries[entry_z.z][++entries[entry_z.z].len] = list(see_x, see_y, H, name, assignment, life_status, damage, player_area, ijob, pos)

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
		if(!isnull(pos) && (pos.z in all_tracked_z_levels) && istype(M) && M.brainmob == B && !isrobot(M.loc))
			var/see_x = pos.x - WORLD_X_OFFSET[pos.z]
			var/see_y = pos.y - WORLD_Y_OFFSET[pos.z]
			entries[pos.z][++entries[pos.z].len] = list(see_x, see_y, B, "[B]", "MMI", null, null, parea, 60, pos)

//helper to get healthstate, used in both holomap and textview
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
HOLOMAP PROCS
*/
//initializes the holomap
/obj/machinery/computer/crew/proc/openHolomap(var/mob/user)
	var/list/all_ui_z_levels = holomap_z_levels_mapped | holomap_z_levels_unmapped
	for(var/z_level in all_ui_z_levels)
		var/holomap_bgmap = "cmc_\ref[src]_\ref[user]_[z_level]"
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
			background.plane = HUD_PLANE
			background.layer = HUD_BASE_LAYER
			holomap_cache[holomap_bgmap] = background

	//z2 override if nukeops or voxraider
	if(holomap_filter & (HOLOMAP_FILTER_VOX | HOLOMAP_FILTER_NUKEOPS))
		var/holomap_bgmap = "cmc_\ref[src]_\ref[user]_2"
		var/image/background = image('icons/480x480.dmi', "stationmap_blue")
		var/image/station_outline = image(centcommMiniMaps["[holomap_filter]"])
		station_outline.color = "#DEE7FF"
		station_outline.alpha = 200
		background.overlays += station_outline
		background.alpha = 0
		background.plane = HUD_PLANE
		background.layer = HUD_BASE_LAYER
		holomap_cache[holomap_bgmap] = background
		holomap_z_levels_unmapped |= CENTCOMM_Z
	
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
	var/uid = "\ref[user]"
	if((!user) || (!user.client) || (user.isUnconscious() && !isobserver(user)) || (!(isobserver(user) || issilicon(user)) && (get_dist(user.loc,src.loc) > 1)) || (holoMiniMaps[holomap_z[uid]] == null))
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
		holomap_images[uid].len = 0
		holomap_tooltips[uid].len = 0

		var/image/bgmap
		var/z = holomap_z[uid]
		var/holomap_bgmap = "cmc_\ref[src]_\ref[user]_[z]"

		bgmap = holomap_cache[holomap_bgmap]
		bgmap.loc = user.hud_used.holomap_obj

		animate(bgmap, alpha = 255, time = 5, easing = LINEAR_EASING)

		holomap_images[uid] |= bgmap

		for(var/entry in entries[holomap_z[uid]])
			//can only be our z, so i'm not checking that, only if we have a pos
			if(entry[ENTRY_POS])
				addCrewMarker(user, entry[ENTRY_SEE_X], entry[ENTRY_SEE_Y], entry[ENTRY_MOB], entry[ENTRY_NAME], entry[ENTRY_ASSIGNMENT], entry[ENTRY_STAT], entry[ENTRY_DAMAGE], entry[ENTRY_AREA], entry[ENTRY_POS])
        
		user.client.images |= holomap_images[uid]
		user.client.screen |= holomap_tooltips[uid]
	else
		user.client.images -= holomap_images[uid]
		user.client.screen -= holomap_tooltips[uid]
		holomap_images[uid].len = 0
		holomap_tooltips[uid].len = 0

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
TEXTVIEW PROCS
*/
/obj/machinery/computer/crew/Topic(href, href_list)
	var/uid = "\ref[usr]"
	if(href_list["close"])
		deactivate(usr)
	else if(href_list["toggle"])
		textview_updatequeued[uid] = !textview_updatequeued[uid]
		var/datum/nanoui/ui = nanomanager.get_open_ui(usr, src, "textview")
		if(ui)
			ui.send_message("toggleUpdatebtn", list2params(list(json_encode(textview_updatequeued[uid])))) //using the actual setting sorts out any btn icon sync issues
		updateTextView(usr)
	else if(href_list["holo"])
		if(holomap[uid])
			closeHolomap(usr)
		else
			openHolomap(usr)
			processUser(usr)
	else if(href_list["setZ"])
		var/num = href_list["setZ"]
		if(!isnum(num))
			num = text2num(num)
			if(!num)
				return 1//something fucked up
		
		holomap_z[uid] = num
		var/datum/nanoui/ui = nanomanager.get_open_ui(usr, src, "textview")
		if(ui)
			ui.send_message("levelSet", list2params(list(num))) //feedback
		processUser(usr) //we need to update both the holomap AND the textview
	var/datum/nanoui/ui = nanomanager.get_open_ui(usr, src, "textview")
	if(ui)
		ui.send_message("messageReceived") //to stop that loading button shit
	return 1

//updates/opens the textview
/obj/machinery/computer/crew/proc/updateTextView(var/mob/user)
	var/uid = "\ref[user]"

	//adding table rows
	var/list/all_data = list()
	for(var/entry in entries[holomap_z[uid]])
		var/list/data = list()
		if(entry[ENTRY_SEE_X] && entry[ENTRY_SEE_Y])
			data["see"] = list()
			data["see"]["x"] = entry[ENTRY_SEE_X]
			data["see"]["y"] = entry[ENTRY_SEE_Y]
		data["name"] = entry[ENTRY_NAME]
		data["job"] = entry[ENTRY_ASSIGNMENT]
		if(entry[ENTRY_DAMAGE])
			data["damage"] = list()
			data["damage"]["oxygen"] = entry[ENTRY_DAMAGE][DAMAGE_OXYGEN]
			data["damage"]["toxin"] = entry[ENTRY_DAMAGE][DAMAGE_TOXIN]
			data["damage"]["fire"] = entry[ENTRY_DAMAGE][DAMAGE_FIRE]
			data["damage"]["brute"] = entry[ENTRY_DAMAGE][DAMAGE_BRUTE]
		data["area"] = entry[ENTRY_AREA]

		var/ijob = entry[ENTRY_IJOB]
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
		data["role"] = role

		var/mob/living/carbon/H = entry[ENTRY_MOB]
		var/stat = entry[ENTRY_STAT]
		var/icon
		if(istype(H, /mob/living/carbon/human))
			if(stat != 2)
				if(entry[ENTRY_DAMAGE])
					icon = getLifeIcon(entry[ENTRY_DAMAGE])
				else
					icon = "0"
			else
				icon = "6"
		else
			icon = "7"
		data["icon"] = icon

		all_data["[all_data.len+1]"] = data

	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "textview")
	if (!ui)
		if(user.client)
			var/datum/asset/simple/C = new/datum/asset/simple/cmc_css_icons()
			send_asset_list(user.client, C.assets)
		
		ui = new(user, src, "textview", "cmc.tmpl", "Crew Monitoring", 900, 600)
		ui.add_stylesheet("cmc.css")
		var/list/i_data = list()
		i_data["update"] = textview_updatequeued[uid]
		i_data["levels"] = sortList(holomap_z_levels_mapped | holomap_z_levels_unmapped, cmp=/proc/cmp_numeric_asc)
		ui.set_initial_data(i_data)
		ui.open()

	if(all_data.len) //sending an empty list seems to create some fuckery
		ui.send_message("populateTable", list2params(list(json_encode(all_data))))
	else
		ui.send_message("noData")

//makes sure everything is set for us to have a closed window and keep it that way
/obj/machinery/computer/crew/proc/closeTextview(var/mob/user)
	textview_updatequeued["\ref[user]"] = 0
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "textview")
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
	openToolTip(user, src, params, title = title, content = content)

/obj/abstract/screen/interface/tooltip/MouseExited(location,control,params)
	closeToolTip(user)

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
#undef DAMAGE_OXYGEN
#undef DAMAGE_TOXIN
#undef DAMAGE_FIRE
#undef DAMAGE_BRUTE