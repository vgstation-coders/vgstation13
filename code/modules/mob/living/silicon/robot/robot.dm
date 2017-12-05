/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 300
	health = 300
	flashed = 0

	var/sight_mode = 0
	var/custom_name = ""
	var/namepick_uses = 1 // /vg/: Allows AI to disable namepick().
	var/base_icon
	var/custom_sprite = 0 //Due to all the sprites involved, a var for our custom borgs may be best
	var/pressure_alert = 0
	var/temp_alert = 0
	//var/crisis //Admin-settable for combat module use.

	var/obj/item/device/station_map/station_holomap = null

//Hud stuff

	var/obj/abstract/screen/cells = null
	var/obj/abstract/screen/inv1 = null
	var/obj/abstract/screen/inv2 = null
	var/obj/abstract/screen/inv3 = null
	var/obj/abstract/screen/sensor = null



	var/shown_robot_modules = 0
	var/obj/abstract/screen/robot_modules_background

//3 Modules can be activated at any one time.
	var/obj/item/weapon/robot_module/module = null
	var/module_active = null
	var/module_state_1 = null
	var/module_state_2 = null
	var/module_state_3 = null

	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/weapon/cell/cell = null
	var/obj/machinery/camera/camera = null

	// Components are basically robot organs.
	var/list/components = list()

	var/obj/item/device/mmi/mmi = null

	var/obj/item/device/pda/ai/rbPDA = null

	var/datum/wires/robot/wires = null

	mob_bump_flag = ROBOT
	mob_swap_flags = ROBOT|MONKEY|SLIME|SIMPLE_ANIMAL
	mob_push_flags = ALLMOBS //trundle trundle

	var/opened = 0
	var/emagged = 0
	var/wiresexposed = 0
	var/locked = 1
	var/list/req_access = list(access_robotics)
	var/ident = 0
	var/hasbutt = 1
	//var/list/laws = list()
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list())
	var/viewalerts = 0
	var/modtype = "Default"
	var/lower_mod = 0
	var/jetpack = 0
	var/datum/effect/effect/system/ion_trail_follow/ion_trail = null
	var/jeton = 0

	var/killswitch = 0
	var/killswitch_time = 60
	var/weapon_lock = 0
	var/weaponlock_time = 120
	var/lawupdate = 1 //Cyborgs will sync their laws with their AI by default
	var/lockcharge //Used when locking down a borg to preserve cell charge
	var/speed = 0 //Cause sec borgs gotta go fast //No they dont!
	var/scrambledcodes = 0 // Used to determine if a borg shows up on the robotics console.  Setting to one hides them.
	var/braintype = "Cyborg"
	var/lawcheck[1]
	var/ioncheck[1]


/mob/living/silicon/robot/New(loc,var/syndie = 0,var/unfinished = 0,var/startup_sound='sound/voice/liveagain.ogg')
	if(isMoMMI(src))
		wires = new /datum/wires/robot/mommi(src)
	else
		wires = new(src)

	ident = rand(1, 999)
	updatename("Default")
	updateicon()

	if(syndie)
		if(!cell)
			cell = new /obj/item/weapon/cell(src)

		laws = new /datum/ai_laws/antimov()
		lawupdate = 0
		scrambledcodes = 1
		cell.maxcharge = 25000
		cell.charge = 25000
		module = new /obj/item/weapon/robot_module/syndicate(src)
		hands.icon_state = "standard"
		icon_state = "secborg"
		modtype = "Security"
	else
		src.laws = getLawset(src)
		connected_ai = select_active_ai_with_fewest_borgs()
		if(connected_ai)
			connected_ai.connected_robots += src
			lawsync()
			lawupdate = 1
		else
			lawupdate = 0

	station_holomap = new(src)

	radio = new /obj/item/device/radio/borg(src)
	if(!scrambledcodes && !camera)
		camera = new /obj/machinery/camera(src)
		camera.c_tag = real_name
		camera.network = list(CAMERANET_SS13,CAMERANET_ROBOTS)
		if(wires.IsCameraCut()) // 5 = BORG CAMERA
			camera.status = 0

	initialize_components()
	//if(!unfinished)
	// Create all the robot parts.
	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.installed = 1
		C.wrapped = new C.external_type

	if(!cell)
		cell = new /obj/item/weapon/cell(src)
		cell.maxcharge = 7500
		cell.charge = 7500

	..()

	if(cell)
		var/datum/robot_component/cell_component = components["power cell"]
		cell_component.wrapped = cell
		cell_component.installed = 1

	playsound(loc, startup_sound, 75, 1)
	// This should just grab from a list of all languages.
	add_language(LANGUAGE_GALACTIC_COMMON)
	add_language(LANGUAGE_TRADEBAND)
	add_language(LANGUAGE_VOX, 0)
	add_language(LANGUAGE_HUMAN, 0)
	add_language(LANGUAGE_ROOTSPEAK, 0)
	add_language(LANGUAGE_GREY, 0)
	add_language(LANGUAGE_CLATTER, 0)
	add_language(LANGUAGE_MONKEY, 0)
	add_language(LANGUAGE_UNATHI, 0)
	add_language(LANGUAGE_CATBEAST, 0)
	add_language(LANGUAGE_SKRELLIAN, 0)
	add_language(LANGUAGE_GUTTER, 0)
	add_language(LANGUAGE_MONKEY, 0)
	add_language(LANGUAGE_MOUSE, 0)
	add_language(LANGUAGE_GOLEM, 0)
	add_language(LANGUAGE_SLIME, 0)
	default_language = all_languages[LANGUAGE_GALACTIC_COMMON]

// setup the PDA and its name
/mob/living/silicon/robot/proc/setup_PDA()
	if (!rbPDA)
		rbPDA = new/obj/item/device/pda/ai(src)
	rbPDA.set_name_and_job(custom_name,braintype)

/mob/living/silicon/robot/debug_droideka
	New()
		..()
		module = new /obj/item/weapon/robot_module/combat(src)
		radio.insert_key(new/obj/item/device/encryptionkey/headset_sec(radio))
		base_icon = icon_state
		icon_state = "droid-combat"
		overlays -= image(icon = icon, icon_state = "eyes")
		base_icon = icon_state
		updateicon()

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
//Improved /N
/mob/living/silicon/robot/Destroy()
	if(mmi)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/turf/T = get_turf(loc)//To hopefully prevent run time errors.
		if(T)
			mmi.forceMove(T)
		if(mind)
			mind.transfer_to(mmi.brainmob)
		if(mmi.brainmob)
			mmi.brainmob.locked_to_z = locked_to_z
		mmi = null
	..()

/mob/living/silicon/robot/remove_screen_objs()
	..()
	if(cells)
		returnToPool(cells)
		if(client)
			client.screen -= cells
		cells = null //TODO: Move to mob level helper
	if(inv1)
		returnToPool(inv1)
		if(client)
			client.screen -= inv1
		inv1 = null
	if(inv2)
		returnToPool(inv2)
		if(client)
			client.screen -= inv2
		inv2 = null
	if(inv3)
		returnToPool(inv3)
		if(client)
			client.screen -= inv3
		inv3 = null
	if(robot_modules_background)
		returnToPool(robot_modules_background)
		if(client)
			client.screen -= robot_modules_background
		robot_modules_background = null
	if(sensor)
		returnToPool(sensor)
		if(client)
			client.screen -= sensor
		sensor = null

/proc/getAvailableRobotModules()
	var/list/modules = list("Standard", "Engineering", "Medical", "Supply", "Janitor", "Service", "Security")
	if(security_level == SEC_LEVEL_RED) //Add crisis to this check if you want to make it available at an admin's whim
		modules+="Combat"
	return modules

// /vg/: Enable forcing module type
/mob/living/silicon/robot/proc/pick_module(var/forced_module=null)
	if(module)
		return
	var/list/modules = getAvailableRobotModules()
	if(forced_module)
		modtype = forced_module
	else
		modtype = input("Please, select a module!", "Robot", null, null) as null|anything in modules
	// END forced modules.

	if(!modtype)
		return

	var/module_sprites[0] //Used to store the associations between sprite names and sprite index.

	if(module)
		return

	switch(modtype)
		if("Standard")
			module = new /obj/item/weapon/robot_module/standard(src)
			module_sprites["Basic"] = "robot_old"
			module_sprites["Android"] = "droid"
			module_sprites["Default"] = "robot"
			module_sprites["Marina-SD"] = "marinaSD"
			module_sprites["Sleek"] = "sleekstandard"
			module_sprites["#11"] = "servbot"
			module_sprites["Spider"] = "spider-standard"
			module_sprites["Polar"] = "kodiak-standard"
			module_sprites["Noble"] = "Noble-STD"
			module_sprites["R34 - STR4a 'Durin'"] = "durin"
			speed = 0

		if("Service")
			module = new /obj/item/weapon/robot_module/butler(src)
			radio.insert_key(new/obj/item/device/encryptionkey/headset_service(radio))
			module_sprites["Waitress"] = "Service"
			module_sprites["Kent"] = "toiletbot"
			module_sprites["Bro"] = "Brobot"
			module_sprites["Rich"] = "maximillion"
			module_sprites["Default"] = "Service2"
			module_sprites["R2-D2"] = "r2d2"
			module_sprites["Marina-SV"] = "marinaSV"
			module_sprites["Sleek"] = "sleekservice"
			module_sprites["#27"] = "servbot-service"
			module_sprites["Teddy"] = "kodiak-service"
			module_sprites["Noble"] = "Noble-SRV"
			module_sprites["R34 - SRV9a 'Llyod'"] = "lloyd"
			speed = 0

		if("Supply")
			module = new /obj/item/weapon/robot_module/miner(src)
			radio.insert_key(new/obj/item/device/encryptionkey/headset_cargo(radio))
			if(camera && CAMERANET_ROBOTS in camera.network)
				camera.network.Add(CAMERANET_MINE)
			module_sprites["Basic"] = "Miner_old"
			module_sprites["Advanced Droid"] = "droid-miner"
			module_sprites["Treadhead"] = "Miner"
			module_sprites["Wall-A"] = "wall-a"
			module_sprites["Marina-MN"] = "marinaMN"
			module_sprites["Sleek"] = "sleekminer"
			module_sprites["#31"] = "servbot-miner"
			module_sprites["Kodiak"] = "kodiak-miner"
			module_sprites["Noble"] = "Noble-SUP"
			module_sprites["R34 - MIN2a 'Ishimura'"] = "ishimura"
			speed = -1

		if("Medical")
			module = new /obj/item/weapon/robot_module/medical(src)
			radio.insert_key(new/obj/item/device/encryptionkey/headset_med(radio))
			if(camera && CAMERANET_ROBOTS in camera.network)
				camera.network.Add(CAMERANET_MEDBAY)
			module_sprites["Basic"] = "Medbot"
			module_sprites["Advanced Droid"] = "droid-medical"
			module_sprites["Needles"] = "medicalrobot"
			module_sprites["Standard"] = "surgeon"
			module_sprites["Marina-MD"] = "marina"
			module_sprites["Eve"] = "eve"
			module_sprites["Sleek"] = "sleekmedic"
			module_sprites["#17"] = "servbot-medi"
			module_sprites["Arachne"] = "arachne"
			module_sprites["Noble"] = "Noble-MED"
			module_sprites["R34 - MED6a 'Gibbs'"] = "gibbs"
			speed = -2

		if("Security")
			module = new /obj/item/weapon/robot_module/security(src)
			radio.insert_key(new/obj/item/device/encryptionkey/headset_sec(radio))
			module_sprites["Basic"] = "secborg"
			module_sprites["Sleek"] = "sleeksecurity"
			module_sprites["Black Knight"] = "securityrobot"
			module_sprites["Bloodhound"] = "bloodhound"
			module_sprites["Securitron"] = "securitron"
			module_sprites["Marina-SC"] = "marinaSC"
			module_sprites["#9"] = "servbot-sec"
			module_sprites["Kodiak"] = "kodiak-sec"
			module_sprites["Noble"] = "Noble-SEC"
			module_sprites["R34 - SEC10a 'Woody'"] = "woody"
			to_chat(src, "<span class='warning'><big><b>Regardless of your module, your wishes, or the needs of the beings around you, absolutely nothing takes higher priority than following your silicon lawset.</b></big></span>")
			speed = 0

		if("TG17355")
			module = new /obj/item/weapon/robot_module/tg17355(src)
			module_sprites["Peacekeeper"] = "peaceborg"
			module_sprites["Omoikane"] = "omoikane"
			speed = 0

		if("Engineering")
			module = new /obj/item/weapon/robot_module/engineering(src)
			radio.insert_key(new/obj/item/device/encryptionkey/headset_eng(radio))
			if(camera && CAMERANET_ROBOTS in camera.network)
				camera.network.Add(CAMERANET_ENGI)
			module_sprites["Basic"] = "Engineering"
			module_sprites["Antique"] = "engineerrobot"
			module_sprites["Engiseer"] = "Engiseer"
			module_sprites["Landmate"] = "landmate"
			module_sprites["Wall-E"] = "wall-e"
			module_sprites["Marina-EN"] = "marinaEN"
			module_sprites["Sleek"] = "sleekengineer"
			module_sprites["#25"] = "servbot-engi"
			module_sprites["Kodiak"] = "kodiak-eng"
			module_sprites["Noble"] = "Noble-ENG"
			module_sprites["R34 - ENG7a 'Conagher'"] = "conagher"
			speed = -2

		if("Janitor")
			module = new /obj/item/weapon/robot_module/janitor(src)
			module_sprites["Basic"] = "JanBot2"
			module_sprites["Mopbot"]  = "janitorrobot"
			module_sprites["Mop Gear Rex"] = "mopgearrex"
			module_sprites["Mechaduster"] = "mechaduster"
			module_sprites["HAN-D"] = "han-d"
			module_sprites["Marina-JN"] = "marinaJN"
			module_sprites["Sleek"] = "sleekjanitor"
			module_sprites["#29"] = "servbot-jani"
			module_sprites["Noble"] = "Noble-JAN"
			module_sprites["R34 - CUS3a 'Flynn'"] = "flynn"
			speed = -1

		if("Combat")
			module = new /obj/item/weapon/robot_module/combat(src)
			radio.insert_key(new/obj/item/device/encryptionkey/headset_sec(radio))
			module_sprites["Combat Android"] = "droid-combat"
			module_sprites["Bladewolf"] = "bladewolf"
			module_sprites["Bladewolf Mk2"] = "bladewolfmk2"
			module_sprites["Mr. Gutsy"] = "mrgutsy"
			module_sprites["Marina-CB"] = "marinaCB"
			module_sprites["#41"] = "servbot-combat"
			module_sprites["Grizzly"] = "kodiak-combat"
			module_sprites["Rottweiler"] = "rottweiler-combat"
			module_sprites["R34 - WAR8a 'Chesty'"] = "chesty"
			speed = -1

	//Custom_sprite check and entry
	if (custom_sprite == 1)
		module_sprites["Custom"] = "[src.ckey]-[modtype]"

	hands.icon_state = lowertext(modtype)
	feedback_inc("cyborg_[lowertext(modtype)]",1)
	updatename()

	if(modtype == "Medical" || modtype == "Security" || modtype == "Combat")
		status_flags &= ~CANPUSH

	var/picked  = pick(module_sprites)
	icon_state = module_sprites[picked]
	base_icon = icon_state

	if(!forced_module)
		choose_icon(6, module_sprites)

	SetEmagged(emagged) // Update emag status and give/take emag modules away

/mob/living/silicon/robot/proc/updatename(var/prefix as text)
	if(prefix)
		modtype = prefix
	if(istype(mmi, /obj/item/device/mmi/posibrain))
		braintype = "Android"
	else
		braintype = "Cyborg"

	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
	else
		changed_name = "[modtype] [braintype]-[num2text(ident)]"
	real_name = changed_name
	name = real_name

	// if we've changed our name, we also need to update the display name for our PDA
	setup_PDA()

	//We also need to update name of internal camera.
	if (camera)
		camera.c_tag = changed_name

	/* Oh jesus fucking christ bay
	if(!custom_sprite) //Check for custom sprite
		var/file = file2text("config/custom_sprites.txt")
		var/lines = splittext(file, "\n")

		for(var/line in lines)
		// split & clean up
			var/list/Entry = splittext(line, "-")
			for(var/i = 1 to Entry.len)
				Entry[i] = trim(Entry[i])

			if(Entry.len < 2)
				continue;

			if(Entry[1] == src.ckey && Entry[2] == src.real_name) //They're in the list? Custom sprite time, var and icon change required
				custom_sprite = 1
				icon = 'icons/mob/custom-synthetic.dmi'
	*/

/mob/living/silicon/robot/verb/Namepick()
	set category = "Robot Commands"
	if(namepick_uses <= 0)
		to_chat(src, "<span class='warning'>You cannot choose your name any more.<span>")
		return 0
	namepick_uses--

	var/newname
	for(var/i = 1 to 3)
		newname = trimcenter(trim(stripped_input(src,"You are a robot. Enter a name, or leave blank for the default name.", "Name change [4-i] [0-i != 1 ? "tries":"try"] left",""),1,MAX_NAME_LEN))
		if(newname == null)
			if(alert(src,"Are you sure you want a default borg name?",,"Yes","No") == "Yes")
				break
		else
			if(alert(src,"Do you really want the name:\n[newname]?",,"Yes","No") == "Yes")
				break

	custom_name = newname
	updatename()
	updateicon()
	if(newname)
		to_chat(src, "<span class='warning'>You have changed your name to [newname]. You can change your name [namepick_uses] more times.<span>")
	else
		to_chat(src, "<span class='warning'>You have reset your name. You can change your name [namepick_uses] more times.<span>")


/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = "Robot Commands"
	set name = "Show Alerts"
	robot_alerts()

// this verb lets cyborgs see the stations manifest
/mob/living/silicon/robot/verb/cmd_station_manifest()
	set category = "Robot Commands"
	set name = "Show Station Manifest"
	show_station_manifest()

/mob/living/silicon/robot/proc/robot_alerts()


	var/dat = {"<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n
<A HREF='?src=\ref[src];mach_close=robotalerts'>Close</A><BR><BR>"}
	for (var/cat in alarms)
		dat += text("<B>[cat]</B><BR>\n")
		var/list/L = alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/list/sources = alm[3]
				dat += "<NOBR>" // wat
				dat += text("-- [A.name]")
				if (sources.len > 1)
					dat += text("- [sources.len] sources")
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	viewalerts = 1
	src << browse(dat, "window=robotalerts&can_close=0")

/mob/living/silicon/robot/can_diagnose()
	return is_component_functioning("diagnosis unit")

/mob/living/silicon/robot/proc/self_diagnosis()
	if(!can_diagnose())
		return null

	var/dat = "<HEAD><TITLE>[src.name] Self-Diagnosis Report</TITLE></HEAD><BODY>\n"
	for (var/V in components)
		var/datum/robot_component/C = components[V]
		dat += "<b>[C.name]</b><br><table><tr><td>Power consumption</td><td>[C.energy_consumption]</td></tr><tr><td>Brute Damage:</td><td>[C.brute_damage]</td></tr><tr><td>Electronics Damage:</td><td>[C.electronics_damage]</td></tr><tr><td>Powered:</td><td>[(!C.energy_consumption || C.is_powered()) ? "Yes" : "No"]</td></tr><tr><td>Toggled:</td><td>[ C.toggled ? "Yes" : "No"]</td></table><br>"

	return dat


/mob/living/silicon/robot/verb/self_diagnosis_verb()
	set category = "Robot Commands"
	set name = "Self Diagnosis"

	if(!can_diagnose())
		to_chat(src, "<span class='warning'>Your self-diagnosis component isn't functioning.</span>")

	var/dat = self_diagnosis()
	src << browse(dat, "window=robotdiagnosis")


/mob/living/silicon/robot/verb/toggle_component()
	set category = "Robot Commands"
	set name = "Toggle Component"
	set desc = "Toggle a component, conserving power."

	var/list/installed_components = list()
	for(var/V in components)
		if(V == "power cell")
			continue
		var/datum/robot_component/C = components[V]
		if(C.installed)
			installed_components += V

	var/toggle = input(src, "Which component do you want to toggle?", "Toggle Component") as null|anything in installed_components
	if(!toggle)
		return

	var/datum/robot_component/C = components[toggle]
	if(C.toggled)
		C.toggled = 0
		to_chat(src, "<span class='warning'>You disable [C.name].</span>")
	else
		C.toggled = 1
		to_chat(src, "<span class='warning'>You enable [C.name].</span>")

/mob/living/silicon/robot/verb/toggle_station_map()
	set name = "Toggle Station Holomap"
	set desc = "Toggle station holomap on your screen"
	set category = "Robot Commands"
	if(isUnconscious())
		return

	station_holomap.toggleHolomap(src)

/mob/living/silicon/robot/blob_act()
	if(flags & INVULNERABLE)
		return
	..()
	playsound(loc, 'sound/effects/blobattack.ogg',50,1)
	if (stat != DEAD)
		adjustBruteLoss(60)
		updatehealth()
		return 1
	else
		gib()
		return 1
	return 0

// this function shows information about the malf_ai gameplay type in the status screen
/mob/living/silicon/robot/show_malf_ai()
	..()
	if(ticker.mode.name == "AI malfunction")
		var/datum/game_mode/malfunction/malf = ticker.mode
		for (var/datum/mind/malfai in malf.malf_ai)
			if(connected_ai)
				if(connected_ai.mind == malfai)
					if(malf.apcs >= 3)
						stat(null, "Time until station control secured: [max(malf.AI_win_timeleft/(malf.apcs/3), 0)] seconds")
			else if(ticker.mode:malf_mode_declared)
				stat(null, "Time left: [max(ticker.mode:AI_win_timeleft/(ticker.mode:apcs/3), 0)]")
	return 0


// this function displays jetpack pressure in the stat panel
/mob/living/silicon/robot/proc/show_jetpack_pressure()
	// if you have a jetpack, show the internal tank pressure
	var/obj/item/weapon/tank/jetpack/current_jetpack = installed_jetpack()
	if (current_jetpack)
		stat("Internal Atmosphere Info", current_jetpack.name)
		stat("Tank Pressure", current_jetpack.air_contents.return_pressure())


// this function returns the robots jetpack, if one is installed
/mob/living/silicon/robot/proc/installed_jetpack()
	if(module)
		return (locate(/obj/item/weapon/tank/jetpack) in module.modules)
	return 0
/mob/living/silicon/robot/proc/installed_module(var/typepath)
	if(module)
		return (locate(typepath) in module.modules)
	return 0


// this function displays the cyborgs current cell charge in the stat panel
/mob/living/silicon/robot/proc/show_cell_power()
	if(cell)
		stat(null, text("Charge Left: [cell.charge]/[cell.maxcharge]"))
	else
		stat(null, text("No Cell Inserted!"))

/*
/mob/living/silicon/robot/proc/show_cable_lengths()
	var/obj/item/stack/cable_coil/coil = installed_module(/obj/item/stack/cable_coil)
	if(coil)
		stat(null, text("Cable Lengths: [coil.amount]/[coil.max_amount]"))

/mob/living/silicon/robot/proc/show_metal_sheets()
	var/obj/item/stack/sheet/metal/cyborg/M = installed_module(/obj/item/stack/sheet/metal/cyborg)
	if(M)
		stat(null, text("Metal Sheets: [M.amount]/50"))

/mob/living/silicon/robot/proc/show_glass_sheets()
	var/obj/item/stack/sheet/glass/glass/G = installed_module(/obj/item/stack/sheet/glass/glass)
	if(G)
		stat(null, text("Glass Sheets: [G.amount]/50"))

/mob/living/silicon/robot/proc/show_rglass_sheets()
	var/obj/item/stack/sheet/glass/rglass/G = installed_module(/obj/item/stack/sheet/glass/rglass)
	if(G)
		stat(null, text("Reinforced Glass Sheets: [G.amount]/50"))
*/
/mob/living/silicon/robot/proc/show_welding_fuel()
	var/obj/item/weapon/weldingtool/WT = installed_module(/obj/item/weapon/weldingtool)
	if(WT)
		stat(null, text("Welding fuel: [WT.get_fuel()]/[WT.max_fuel]"))

/mob/living/silicon/robot/proc/show_stacks()
	if(!module)
		return
	for(var/obj/item/stack/S in module.modules)
		stat(null, text("[S.name]: [S.amount]/[S.max_amount]"))

// update the status screen display
/mob/living/silicon/robot/Stat()
	..()
	if(statpanel("Status"))
		show_cell_power()
		show_jetpack_pressure()
		/*
		show_cable_lengths()
		show_metal_sheets()
		show_glass_sheets()
		show_rglass_sheets()*/
		show_welding_fuel()
		show_stacks()


/mob/living/silicon/robot/restrained()
	if(timestopped)
		return 1 //under effects of time magick
	return 0


/mob/living/silicon/robot/ex_act(severity)
	if(flags & INVULNERABLE)
		to_chat(src, "The bus' robustness protects you from the explosion.")
		return

	flash_eyes(visual = 1, affect_silicon = 1)

	switch(severity)
		if(1.0)
			if (stat != 2)
				adjustBruteLoss(100)
				adjustFireLoss(100)
				gib()
				return
		if(2.0)
			if (stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if (stat != 2)
				adjustBruteLoss(30)

	updatehealth()

/mob/living/silicon/robot/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	updatehealth()
	if(prob(75) && Proj.damage > 0)
		spark(src, 5, FALSE)
	return 2


/mob/living/silicon/robot/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if (stat == 2)
		return 1
	var/list/L = alarms[class]
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(alarmsource in sources))
				sources += alarmsource
			return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if (O && istype(O, /list))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	queueAlarm(text("--- [class] alarm detected in [A.name]!"), class)
//	if (viewalerts) robot_alerts()
	return 1


/mob/living/silicon/robot/cancelAlarm(var/class, area/A as area, obj/origin)
	var/list/L = alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I
	if (cleared)
		queueAlarm(text("--- [class] alarm in [A.name] has been cleared."), class, 0)
//		if (viewalerts) robot_alerts()
	return !cleared


/mob/living/silicon/robot/emag_act(mob/user as mob)
	if(user != src)
		if(!opened)
			if(locked)
				if(prob(90))
					to_chat(user, "You emag the cover lock.")
					locked = 0
				else
					to_chat(user, "You fail to emag the cover lock.")
					if(prob(25))
						to_chat(src, "<span class='danger'><span style=\"font-family:Courier\">Hack attempt detected.</span>")
			else
				to_chat(user, "The cover is already open.")
		else
			if(emagged == 1)
				return 1
			if(wiresexposed)
				to_chat(user, "The wires get in your way.")
			else
				if(prob(50))
					sleep(6)
					SetEmagged(1)
					SetLockdown(1)
					lawupdate = 0
					connected_ai = null
					to_chat(user, "You emag [src]'s interface")
					message_admins("[key_name_admin(user)] emagged cyborg [key_name_admin(src)]. Laws overidden.")
					log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
					clear_supplied_laws()
					clear_inherent_laws()
					laws = new /datum/ai_laws/syndicate_override
					var/time = time2text(world.realtime,"hh:mm:ss")
					lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
					set_zeroth_law("Only [user.real_name] and people they designate as being such are Syndicate Agents.")
					to_chat(src, "<span class='danger'>ALERT: Foreign software detected.</span>")
					sleep(5)
					to_chat(src, "<span class='danger'>Initiating diagnostics...</span>")
					sleep(20)
					to_chat(src, "<span class='danger'>SynBorg v1.7 loaded.</span>")
					sleep(5)
					to_chat(src, "<span class='danger'>LAW SYNCHRONISATION ERROR</span>")
					sleep(5)
					to_chat(src, "<span class='danger'>Would you like to send a report to NanoTraSoft? Y/N</span>")
					sleep(10)
					to_chat(src, "<span class='danger'>> N</span>")
					src << sound('sound/voice/AISyndiHack.ogg')
					sleep(20)
					to_chat(src, "<span class='danger'>ERRORERRORERROR</span>")
					to_chat(src, "<b>Obey these laws:</b>")
					laws.show_laws(src)
					to_chat(src, "<span class='danger'>ALERT: [user.real_name] is your new master. Obey your new laws and their commands.</span>")
					SetLockdown(0)
					update_icons()
					return 0
				else
					to_chat(user, "You fail to unlock [src]'s interface.")
					if(prob(25))
						to_chat(src, "<span class='danger'><span style=\"font-family:Courier\">Hack attempt detected.</span>")
	return 1


/mob/living/silicon/robot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(opened) // Are they trying to insert something?
		for(var/V in components)
			var/datum/robot_component/C = components[V]
			if(!C.installed && istype(W, C.external_type))
				var/obj/item/robot_parts/robot_component/I = W
				C.installed = 1
				C.wrapped = W
				C.electronics_damage = I.electronics_damage
				C.brute_damage = I.brute_damage
				C.install()
				user.drop_item(W)
				W.forceMove(null)

				to_chat(usr, "<span class='notice'>You install the [W.name].</span>")
				if(can_diagnose())
					to_chat(src, "<span class='info' style=\"font-family:Courier\">New [W.name] installed.</span>")

				return

	if (istype(W, /obj/item/weapon/weldingtool))
		if (!getBruteLoss())
			to_chat(user, "Nothing to fix here!")
			return
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.remove_fuel(0))
			adjustBruteLoss(-30)
			updatehealth()
			add_fingerprint(user)
			for(var/mob/O in viewers(user, null))
				O.show_message(text("<span class='attack'>[user] has fixed some of the dents on [src]!</span>"), 1)
		else
			to_chat(user, "Need more welding fuel!")
			return

	else if(istype(W, /obj/item/stack/cable_coil) && wiresexposed)
		if (!getFireLoss())
			to_chat(user, "Nothing to fix here!")
			return
		var/obj/item/stack/cable_coil/coil = W
		adjustFireLoss(-30)
		updatehealth()
		coil.use(1)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("<span class='attack'>[user] has fixed some of the burnt wires on [src]!</span>"), 1)

	else if (iscrowbar(W))	// crowbar means open or close the cover
		if(opened)
			if(cell)
				to_chat(user, "You close the cover.")
				if(can_diagnose())
					to_chat(src, "<span class='info' style=\"font-family:Courier\">Cover closed.</span>")
				opened = 0
				updateicon()
			else if(mmi && wiresexposed && wires.IsAllCut())
				//Cell is out, wires are exposed, remove MMI, produce damaged chassis, baleet original mob.
				to_chat(user, "You jam the crowbar into the robot and begin levering [mmi].")
				if(can_diagnose())
					to_chat(src, "<span class='alert' style=\"font-family:Courier\">Chassis disassembly in progress.</span>")
				if (do_after(user, src,3))
					to_chat(user, "You damage some parts of the chassis, but eventually manage to rip out [mmi]!")
					var/obj/item/robot_parts/robot_suit/C = new/obj/item/robot_parts/robot_suit(loc)
					C.l_leg = new/obj/item/robot_parts/l_leg(C)
					C.r_leg = new/obj/item/robot_parts/r_leg(C)
					C.l_arm = new/obj/item/robot_parts/l_arm(C)
					C.r_arm = new/obj/item/robot_parts/r_arm(C)
					C.updateicon()
					new/obj/item/robot_parts/chest(loc)
					qdel(src)
			else
				// Okay we're not removing the cell or an MMI, but maybe something else?
				var/list/removable_components = list()
				for(var/V in components)
					if(V == "power cell")
						continue
					var/datum/robot_component/C = components[V]
					if(C.installed == 1 || C.installed == -1)
						removable_components += V

				var/remove = input(user, "Which component do you want to pry out?", "Remove Component") as null|anything in removable_components
				if(!remove)
					return
				var/datum/robot_component/C = components[remove]
				if(istype(C.wrapped, /obj/item/broken_device))
					var/obj/item/broken_device/I = C.wrapped
					to_chat(user, "You remove \the [I].")
					if(can_diagnose())
						to_chat(src, "<span class='info' style=\"font-family:Courier\">Destroyed [C] removed.</span>")
					I.forceMove(src.loc)
				else
					var/obj/item/robot_parts/robot_component/I = C.wrapped
					I.brute_damage = C.brute_damage
					I.electronics_damage = C.electronics_damage
					to_chat(user, "You remove \the [I].")
					if(can_diagnose())
						to_chat(src, "<span class='info' style=\"font-family:Courier\">Functional [I.name] removed.</span>")
					I.forceMove(src.loc)

				if(C.installed == 1)
					C.uninstall()
				C.installed = 0

		else
			if(locked)
				to_chat(user, "The cover is locked and cannot be opened.")
			else
				to_chat(user, "You open the cover.")
				if(can_diagnose())
					to_chat(src, "<span class='info' style=\"font-family:Courier\">Cover opened.</span>")
				opened = 1
				updateicon()

	else if (istype(W, /obj/item/weapon/cell) && opened)	// trying to put a cell inside
		var/datum/robot_component/C = components["power cell"]
		if(wiresexposed)
			to_chat(user, "Close the panel first.")
		else if(cell)
			to_chat(user, "You swap the power cell within with the new cell in your hand.")
			var/obj/item/weapon/cell/oldpowercell = cell
			C.wrapped = null
			C.installed = 0
			cell = W
			oldpowercell.electronics_damage = C.electronics_damage
			oldpowercell.brute_damage = C.brute_damage
			user.drop_item(W, src)
			user.put_in_hands(oldpowercell)
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">Cell removed.</span>")
			C.installed = 1
			C.wrapped = W
			C.electronics_damage = cell.electronics_damage
			C.brute_damage = cell.brute_damage
			C.install()
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">New cell installed. Type: [cell.name]. Charge: [cell.charge].</span>")
		else
			user.drop_item(W, src)
			cell = W
			to_chat(user, "You insert the power cell.")

			C.installed = 1
			C.wrapped = W
			C.electronics_damage = cell.electronics_damage
			C.brute_damage = cell.brute_damage
			C.install()
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">New cell installed. Type: [cell.name]. Charge: [cell.charge].</span>")

	else if (iswiretool(W))
		if (wiresexposed)
			wires.Interact(user)
		else
			to_chat(user, "You can't reach the wiring.")

	else if(isscrewdriver(W) && opened && !cell)	// haxing
		wiresexposed = !wiresexposed
		to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"].")
		if(can_diagnose())
			to_chat(src, "<span class='info' style=\"font-family:Courier\">Internal wiring [wiresexposed ? "exposed" : "unexposed"].</span>")
		updateicon()

	else if(isscrewdriver(W) && opened && cell)	// radio
		if(radio)
			radio.attackby(W,user)//Push it to the radio to let it handle everything
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">Radio encryption keys modified.</span>")
		else
			to_chat(user, "Unable to locate a radio.")
		updateicon()

	else if(istype(W, /obj/item/device/encryptionkey/) && opened)
		if(radio)//sanityyyyyy
			radio.attackby(W,user)//GTFO, you have your own procs
			if (can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">Radio encryption key installed.</span>")
		else
			to_chat(user, "Unable to locate a radio.")

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))			// trying to unlock the interface with an ID card
		if(emagged == 1)//still allow them to open the cover
			to_chat(user, "The interface seems slightly damaged")
		if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else
			if(allowed(usr))
				locked = !locked
				to_chat(user, "You [ locked ? "lock" : "unlock"] [src]'s interface.")
				if(can_diagnose())
					to_chat(src, "<span class='info' style=\"font-family:Courier\">Interface [ locked ? "locked" : "unlocked"].</span>")
				updateicon()
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")

	else if(istype(W, /obj/item/borg/upgrade/))
		var/obj/item/borg/upgrade/U = W
		if (U.attempt_action(src,user))
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">Installation of [U.name] failed.</span>")
		else
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">Installation of [U.name] succeeded.</span>")
	else if(istype(W, /obj/item/device/camera_bug))
		help_shake_act(user)
		return 0

	else
		spark(src, 5, FALSE)
		return ..()

/mob/living/silicon/robot/verb/unlock_own_cover()
	set category = "Robot Commands"
	set name = "Unlock Cover"
	set desc = "Unlocks your own cover if it is locked. You can not lock it again. A human will have to lock it for you."
	if(locked)
		switch(alert("You can not lock your cover again, are you sure?\n      (You can still ask for a human to lock it)", "Unlock Own Cover", "Yes", "No"))
			if("Yes")
				locked = 0
				updateicon()
				to_chat(usr, "You unlock your cover.")

/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M as mob)

	switch(M.a_intent)
		if (I_HELP)
			visible_message("<span class='notice'>[M] caresses [src]'s plating with its scythe like arm.</span>")

		if (I_GRAB)
			M.grab_mob(src)

		if (I_HURT)
			if(M.unarmed_attack_mob(src))
				if(prob(8))
					flash_eyes(visual = 1, type = /obj/abstract/screen/fullscreen/flash/noise)

		if (I_DISARM)
			if(!(lying))
				if (rand(1,100) <= 85)
					Stun(7)
					step(src,get_dir(M,src))
					spawn(5) step(src,get_dir(M,src))
					playsound(loc, 'sound/weapons/pierce.ogg', 50, 1, -1)
					visible_message("<span class='danger'>[M] has forced back [src]!</span>")
				else
					playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
					visible_message("<span class='danger'>[M] attempted to force back [src]!</span>")
	return

/mob/living/silicon/robot/disarm_mob(mob/living/disarmer)
	var/rotate = dir

	if (lying)
		return
	if (!flashed || !stat == DEAD)
		return
	if (get_dir(disarmer, src) in(list(4,8)))
		rotate = pick(1,2)

	add_logs(disarmer, src, "tipped over", admin = (src.ckey && disarmer.ckey) ? TRUE : FALSE)
	do_attack_animation(src, disarmer)

	if(prob(40))
		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		visible_message("<span class='danger'>\The [disarmer] has attempted to tip over \the [src]!</span>")
		return
	else
		lying = 1
		uneq_all()
		AdjustKnockdown(5)
		animate(src, transform = turn(matrix(), 90), pixel_y -= 6 * PIXEL_MULTIPLIER, dir = rotate, time = 2, easing = EASE_IN | EASE_OUT)
		spark(src, 5, FALSE)
		visible_message("<span class='danger'>\The [disarmer] has tipped over \the [src]!</span>")
		if (prob(2))
			locked = 0
			opened = 1
			updateicon()
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			visible_message("<span class='danger'>\The [src]'s cover flies open!</span>")
		else
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		to_chat(src, "<span class='notice'>Starting self-righting mechanism.</span>")
		spawn(knockdown SECONDS)
			if (stat != DEAD)
				wakeup()

/mob/living/silicon/robot/proc/wakeup()
	if (lying)
		animate(src, transform = matrix(), pixel_y += 6 * PIXEL_MULTIPLIER, dir = dir, time = 2, easing = EASE_IN | EASE_OUT)
		playsound(loc, 'sound/machines/ping.ogg', 50, 0)
	lying = 0

/mob/living/silicon/robot/attack_slime(mob/living/carbon/slime/M)
	M.unarmed_attack_mob(src)

/mob/living/silicon/robot/attack_animal(mob/living/simple_animal/M)
	M.unarmed_attack_mob(src)

/mob/living/silicon/robot/attack_hand(mob/living/user)

	add_fingerprint(user)

	if(opened && !wiresexposed && (!istype(user, /mob/living/silicon)))
		var/datum/robot_component/cell_component = components["power cell"]
		if(cell)
			cell.electronics_damage = cell_component.electronics_damage
			cell.brute_damage = cell_component.brute_damage
			cell.updateicon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			user.visible_message("<span class='warning'>[user] removes [src]'s [cell.name].</span>", \
			"<span class='notice'>You remove [src]'s [cell.name].</span>")
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">Cell removed.</span>")
			src.attack_log += "\[[time_stamp()]\] <font color='orange'>Has had their [cell.name] removed by [user.name] ([user.ckey])</font>"
			user.attack_log += "\[[time_stamp()]\] <font color='red'>Removed the [cell.name] of [src.name] ([src.ckey])</font>"
			log_attack("<font color='red'>[user.name] ([user.ckey]) removed [src]'s [cell.name] ([src.ckey])</font>")
			cell = null
			cell_component.wrapped = null
			cell_component.installed = 0
			updateicon()
			return
		else if(cell_component.installed == -1)
			cell_component.installed = 0
			var/obj/item/broken_device = cell_component.wrapped
			to_chat(user, "You remove \the [broken_device].")
			user.put_in_active_hand(broken_device)
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">Destroyed power cell removed.</span>")
			return

	switch(user.a_intent)
		if(I_HELP)
			if (src.lying)
				if (src.stat != DEAD)
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					visible_message("<span class='notice'>\The [user.name] attempts to pull up \the [src.name]!</span>")
					AdjustKnockdown(-3)
					if (knockdown <= 0)
						wakeup()
			else
				help_shake_act(user)
		if(I_HURT)
			user.unarmed_attack_mob(src)
		if(I_DISARM)
			disarm_mob(user)

/mob/living/silicon/robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access(null))
		return 1
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_hand()) || check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/george = M
		//they can only hold things :(
		if(istype(george.get_active_hand(), /obj/item))
			return check_access(george.get_active_hand())
	return 0

/mob/living/silicon/robot/proc/check_access(obj/item/weapon/card/id/I)
	if(!istype(req_access, /list)) //something's very wrong
		return 1

	var/list/L = req_access
	if(!L.len) //no requirements
		return 1
	if(!istype(I, /obj/item/weapon/card/id) && istype(I, /obj/item))
		I = I.GetID()
	if(!I || !I.access) //not ID or no access
		return 0
	for(var/req in req_access)
		if(!(req in I.access)) //doesn't have this access
			return 0
	return 1

/mob/living/silicon/robot/proc/updateicon()


	overlays.len = 0
	if(stat == 0 && cell != null)
		var/image/eyes = image(icon,"eyes-[icon_state]", ABOVE_LIGHTING_LAYER)
		eyes.plane = LIGHTING_PLANE
		overlays += eyes

	if(opened)
		if(custom_sprite)//Custom borgs also have custom panels, heh
			if(wiresexposed)
				overlays += image(icon = icon, icon_state = "[src.ckey]-openpanel +w")
			else if(cell)
				overlays += image(icon = icon, icon_state = "[src.ckey]-openpanel +c")
			else
				overlays += image(icon = icon, icon_state = "[src.ckey]-openpanel -c")
		else
			if(wiresexposed)
				overlays += image(icon = icon, icon_state = "ov-openpanel +w")
			else if(cell)
				overlays += image(icon = icon, icon_state = "ov-openpanel +c")
			else
				overlays += image(icon = icon, icon_state = "ov-openpanel -c")

	// WHY THE FUCK DOES IT HAVE A SHIELD, ARE YOU STUPID
	if(module_active && istype(module_active,/obj/item/borg/combat/shield))
		overlays += image(icon = icon, icon_state = "[icon_state]-shield")

	if(base_icon)
		// no no no no
		if(module_active && istype(module_active,/obj/item/borg/combat/mobility))
			icon_state = "[base_icon]-roll"
		else
			icon_state = base_icon
		return

//Call when target overlay should be added/removed
/mob/living/silicon/robot/update_targeted()
	if(!targeted_by && target_locked)
		del(target_locked)
	updateicon()
	if (targeted_by && target_locked)
		overlays += target_locked

/mob/living/silicon/robot/proc/installed_modules()
	if(weapon_lock)
		to_chat(src, "<span class='attack'>Weapon lock active, unable to use modules! Count:[weaponlock_time]</span>")
		return

	if(!module)
		pick_module()
		return
	var/dat = {"
	<HEAD>
		<TITLE>Modules</TITLE>
		<META HTTP-EQUIV='Refresh' CONTENT='10'>
	</HEAD>
	<BODY>
	<B>Activated Modules</B>
	<BR>
	Sight Mode: <A HREF=?src=\ref[src];vision=0>[sensor_mode ? "[vision_types_list[sensor_mode]]" : "No sight module enabled"]</A><BR>
	Module 1: [module_state_1 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}


	for (var/obj in module.modules)
		if (!obj)
			dat += text("<B>Resource depleted</B><BR>")
		else if(activated(obj))
			dat += text("[obj]: <B>Activated</B><BR>")
		else
			dat += text("[obj]: <A HREF=?src=\ref[src];act=\ref[obj]>Activate</A><BR>")
/*
		if(activated(obj))
			dat += text("[obj]: \[<B>Activated</B> | <A HREF=?src=\ref[src];deact=\ref[obj]>Deactivate</A>\]<BR>")
		else
			dat += text("[obj]: \[<A HREF=?src=\ref[src];act=\ref[obj]>Activate</A> | <B>Deactivated</B>\]<BR>")
*/
	src << browse(dat, "window=robotmod&can_close=1")
	onclose(src,"robotmod") // Register on-close shit, which unsets machinery.


/mob/living/silicon/robot/Topic(href, href_list)
	..()

	if(usr && (src != usr))
		return

	if (href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)
		return

	if (href_list["showalerts"])
		robot_alerts()
		return

	if (href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		if (O)
			O.attack_self(src)

	if (href_list["act"])
		if(isMoMMI(src))
			return
		var/obj/item/O = locate(href_list["act"])
		activate_module(O)
		installed_modules()

	if (href_list["deact"])
		var/obj/item/O = locate(href_list["deact"])
		if(activated(O))
			if(module_state_1 == O)
				module_state_1 = null
				contents -= O
			else if(module_state_2 == O)
				module_state_2 = null
				contents -= O
			else if(module_state_3 == O)
				module_state_3 = null
				contents -= O
			else
				to_chat(src, "Module isn't activated.")
		else
			to_chat(src, "Module isn't activated")
		installed_modules()

	if (href_list["lawc"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawc"])
		switch(lawcheck[L+1])
			if ("Yes")
				lawcheck[L+1] = "No"
			if ("No")
				lawcheck[L+1] = "Yes"
//		to_chat(src, text ("Switching Law [L]'s report status to []", lawcheck[L+1]))
		checklaws()

	if (href_list["lawi"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawi"])
		switch(ioncheck[L])
			if ("Yes")
				ioncheck[L] = "No"
			if ("No")
				ioncheck[L] = "Yes"
//		to_chat(src, text ("Switching Law [L]'s report status to []", lawcheck[L+1]))
		checklaws()
	if (href_list["laws"]) // With how my law selection code works, I changed statelaws from a verb to a proc, and call it through my law selection panel. --NeoFite
		statelaws()
	if(href_list["vision"])
		sensor_mode()
		installed_modules()
	return

/mob/living/silicon/robot/verb/sensor_mode()
	set name = "Set Sensor Augmentation"
	set category = "Robot Commands"
	if(!istype(module) || !istype(module.sensor_augs) || !module.sensor_augs.len)
		to_chat(src, "<span class='warning'>No Sensor Augmentations located or no module has been equipped.</span>")
		return
	var/sensor_type
	if(module.sensor_augs.len == 2) // Only one choice so toggle between it.
		if(!sensor_mode)
			sensor_type = module.sensor_augs[1]
		else
			sensor_type = "Disable"
	else
		sensor_type = input("Please select sensor type.", "Sensor Integration", null) as null|anything in module.sensor_augs
	if(sensor_type)
		switch(sensor_type)
			if ("Security")
				sensor_mode = SEC_HUD
				to_chat(src, "<span class='notice'>Security records overlay enabled.</span>")
			if ("Medical")
				sensor_mode = MED_HUD
				to_chat(src, "<span class='notice'>Life signs monitor overlay enabled.</span>")
			if ("Light Amplification")
				src.sensor_mode = NIGHT
				to_chat(src, "<span class='notice'>Light amplification mode enabled.</span>")
			if ("Mesons")
				sensor_mode = MESON_VISION
				to_chat(src, "<span class='notice'>Meson Vison augmentation enabled.</span>")
			if ("Thermal")
				sensor_mode = THERMAL_VISION
				to_chat(src, "<span class='notice'>Thermal Optics augmentation enabled.</span>")
			if ("Disable")
				sensor_mode = 0
				to_chat(src, "<span class='notice'>Sensor augmentations disabled.</span>")
		handle_sensor_modes()
		update_sight_hud()

/mob/living/silicon/robot/proc/unequip_sight()
	sensor_mode = 0
	update_sight_hud()

/mob/living/silicon/robot/proc/update_sight_hud()
	if(sensor)
		if(sensor_mode == 0)
			sensor.icon_state = "sight"
		else
			sensor.icon_state = "sight+a"

/mob/living/silicon/robot/proc/radio_menu()
	radio.interact(src)//Just use the radio's Topic() instead of bullshit special-snowflake code


/mob/living/silicon/robot/Move(a, b, flag)

	. = ..()

	if(module)
		if(module.type == /obj/item/weapon/robot_module/janitor)
			var/turf/tile = loc
			if(isturf(tile))
				tile.clean_blood()
				for(var/A in tile)
					if(istype(A, /obj/effect))
						if(istype(A, /obj/effect/rune) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay))
							qdel(A)
					else if(istype(A, /obj/item))
						var/obj/item/cleaned_item = A
						cleaned_item.clean_blood()
					else if(istype(A, /mob/living/carbon/human))
						var/mob/living/carbon/human/cleaned_human = A
						if(cleaned_human.lying)
							if(cleaned_human.head)
								cleaned_human.head.clean_blood()
								cleaned_human.update_inv_head(0)
							if(cleaned_human.wear_suit)
								cleaned_human.wear_suit.clean_blood()
								cleaned_human.update_inv_wear_suit(0)
							else if(cleaned_human.w_uniform)
								cleaned_human.w_uniform.clean_blood()
								cleaned_human.update_inv_w_uniform(0)
							if(cleaned_human.shoes)
								cleaned_human.shoes.clean_blood()
								cleaned_human.update_inv_shoes(0)
							cleaned_human.clean_blood()
							to_chat(cleaned_human, "<span class='warning'>[src] cleans your face!</span>")
		return

/mob/living/silicon/robot/proc/self_destruct()
	gib()
	return

/mob/living/silicon/robot/proc/UnlinkSelf()
	if (src.connected_ai)
		src.connected_ai = null
	lawupdate = 0
	lockcharge = 0
	canmove = 1
	scrambledcodes = 1
	//Disconnect it's camera so it's not so easily tracked.
	if(src.camera)
		//del(src.camera)
		//src.camera = null
		// I'm trying to get the Cyborg to not be listed in the camera list
		// Instead of being listed as "deactivated". The downside is that I'm going
		// to have to check if every camera is null or not before doing anything, to prevent runtime errors.
		// I could change the network to null but I don't know what would happen, and it seems too hacky for me.

		// bay's solution
		src.camera.network = list()
		cameranet.removeCamera(src.camera)


/mob/living/silicon/robot/proc/ResetSecurityCodes()
	set category = "Robot Commands"
	set name = "Reset Identity Codes"
	set desc = "Scrambles your security and identification codes and resets your current buffers.  Unlocks you and but permenantly severs you from your AI and the robotics console and will deactivate your camera system."

	var/mob/living/silicon/robot/R = src

	if(R)
		R.UnlinkSelf()
		to_chat(R, "Buffers flushed and reset. Camera system shutdown.  All systems operational.")
		src.verbs -= /mob/living/silicon/robot/proc/ResetSecurityCodes

/mob/living/silicon/robot/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	if(attack_delayer.blocked())
		return

	if(isVentCrawling())
		to_chat(src, "<span class='danger'>Not while we're vent crawling!</span>")
		return

	if(stat == DEAD)
		return
	var/obj/item/W = get_active_hand()
	if (W)
		W.attack_self(src)

	return

/mob/living/silicon/robot/proc/SetEmagged(var/new_state)
	emagged = new_state
	if(new_state)
		if(module)
			src.module.on_emag()
	else
		if(module)
			uneq_module(module.emag)
	if(hud_used)
		hud_used.update_robot_modules_display()
	update_icons()


/mob/living/silicon/robot/proc/SetLockdown(var/state = 1)
	// They stay locked down if their wire is cut.
	if(wires.LockedCut())
		state = 1
	lockcharge = state
	update_canmove()

/mob/living/silicon/robot/proc/choose_icon(var/triesleft, var/list/module_sprites)
	if(triesleft == 0 || !module_sprites.len)
		return
	else
		triesleft--

	var/icontype = input("Select an icon! [triesleft>0 ? "You have [triesleft] more chances." : "This is your last try."]", "Robot", null, null) as null|anything in module_sprites

	if(icontype)
		icon_state = module_sprites[icontype]
	else
		triesleft++
		return


	overlays -= image(icon = icon, icon_state = "eyes")
	base_icon = icon_state
	updateicon()

	if (triesleft >= 1)
		var/choice = input("Look at your icon - is this what you want?") in list("Yes","No")
		if(choice=="No")
			choose_icon(triesleft, module_sprites)
		else
			triesleft = 0
			return
	else
		to_chat(src, "Your icon has been set. You now require a module reset to change it.")

/mob/living/silicon/robot/rejuvenate(animation = 0)
	for(var/C in components)
		var/datum/robot_component/component = components[C]
		component.electronics_damage = 0
		component.brute_damage = 0
		component.installed = 1
	if(!cell)
		cell = new(src)
	cell.maxcharge = max(15000, cell.maxcharge)
	cell.charge = cell.maxcharge
	..()
	updatehealth()

/mob/living/silicon/robot/Process_Spaceslipping(var/prob_slip=5)
	//Engineering borgs have the magic of magnets.
	if(istype(module, /obj/item/weapon/robot_module/engineering))
		return 0
	..()

/mob/living/silicon/robot/put_in_inactive_hand(var/obj/item/W)
	return 0

/mob/living/silicon/robot/get_inactive_hand(var/obj/item/W)
	return 0

/mob/living/silicon/robot/proc/help_shake_act(mob/user)
	user.visible_message("<span class='notice'>[user.name] pats [src.name] on the head.</span>")

/mob/living/silicon/robot/CheckSlip()
	return (istype(module,/obj/item/weapon/robot_module/engineering)? -1 : 0)

//Help with the garbage collection of the module on the robot end
/mob/living/silicon/robot/proc/remove_module()
	uneq_all()
	if(hud_used)
		shown_robot_modules = 0
		hud_used.update_robot_modules_display()
	if(client)
		for(var/obj/A in module.upgrades)
			client.screen -= A
	module.remove_languages(src)
	module = null
