/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 300
	health = 300
	flashed = FALSE

	var/custom_name = ""
	var/namepick_uses = 1 // /vg/: Allows AI to disable namepick().
	var/base_icon
	var/image/eyes = null

	//Sound
	var/startup_sound = 'sound/voice/liveagain.ogg'
	var/startup_vary = TRUE //Does the startup sounds vary?

	var/obj/item/device/station_map/station_holomap = null

	//Hud stuff
	var/obj/abstract/screen/inv1 = null
	var/obj/abstract/screen/inv2 = null
	var/obj/abstract/screen/inv3 = null
	var/obj/abstract/screen/sensor = null

	var/shown_robot_modules = FALSE
	var/obj/abstract/screen/robot_modules_background

	//3 Modules can be activated at any one time.
	var/obj/item/weapon/robot_module/module = null
	var/module_active = null
	var/module_state_1 = null
	var/module_state_2 = null
	var/module_state_3 = null

	var/mob/living/silicon/ai/connected_ai = null
	var/AIlink = TRUE //Do we start linked to an AI?

	var/obj/item/weapon/cell/cell = null
	var/cell_type = /obj/item/weapon/cell/high/cyborg //The cell_type we're actually using.

	var/obj/machinery/camera/camera = null

	// Components are basically robot organs.
	var/list/components = list()
	var/component_extension = null

	var/obj/item/device/mmi/mmi = null
	var/obj/item/device/pda/ai/rbPDA = null
	var/datum/wires/robot/wires = null
	var/wiring_type = /datum/wires/robot

	mob_bump_flag = ROBOT
	mob_swap_flags = ROBOT|MONKEY|SLIME|SIMPLE_ANIMAL
	mob_push_flags = ALLMOBS //trundle trundle

	var/opened = FALSE
	var/pulsecompromised = FALSE //Used for pulsedemons
	var/illegal_weapons = FALSE
	var/wiresexposed = FALSE
	var/locked = TRUE
	var/ident = FALSE
	var/hasbutt = TRUE //Needed for bootyborgs... and buckling too.
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list())
	var/viewalerts = FALSE
	var/modtype = "Default"
	var/jetpack = FALSE
	var/datum/effect/system/ion_trail_follow/ion_trail = null
	var/jeton = FALSE

	var/modulelock = FALSE
	var/modulelock_time = 120
	var/lawupdate = TRUE //Cyborgs will sync their laws with their AI by default
	var/lockdown //Used when locking down a borg to preserve cell charge
	var/scrambledcodes = FALSE // Used to determine if a borg shows up on the robotics console.  Setting to one hides them.
	var/braintype = "Cyborg"
	var/lawcheck[1]
	var/ioncheck[1]

// Used to store the associations between sprite names and sprite index.
	var/module_sprites[0]

//Photography
	var/obj/item/device/camera/silicon/aicamera = null
	var/toner = CYBORG_STARTING_TONER
	var/tonermax = CYBORG_MAX_TONER

//Access
	var/list/req_access = list(access_robotics) //Access needed to open cover
	var/list/robot_access = list(access_ai_upload, access_robotics, access_maint_tunnels, access_external_airlocks) //Our current access

	var/last_tase_timeofday
	var/last_high_damage_taken_timeofday

/mob/living/silicon/robot/New(loc, var/mob/living/silicon/ai/malfAI = null)
	ident = rand(1, 999)
	updatename(modtype)

	laws = getLawset(src)
	robot_access = GetRobotAccess()
	wires = new wiring_type(src)
	station_holomap = new(src)
	radio = new /obj/item/device/radio/borg(src)
	aicamera = new/obj/item/device/camera/silicon/robot_camera(src)

	if(AIlink)
		if(malfAI)
			connect_AI(malfAI)
		else
			connect_AI(select_active_ai_with_fewest_borgs())

	track_globally()

	if(!scrambledcodes && !camera)
		camera = new /obj/machinery/camera(src)
		camera.c_tag = real_name
		if(!scrambledcodes)
			camera.network = list(CAMERANET_SS13,CAMERANET_ROBOTS)
			cyborg_cams[CAMERANET_ROBOTS] += camera
		if(wires.IsCameraCut()) // 5 = BORG CAMERA
			camera.status = 0

	initialize_components()
	// Create all the robot parts.
	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.installed = COMPONENT_INSTALLED
		C.wrapped = new C.external_type

	if(!cell)
		cell = new cell_type(src)

	updateicon()

	hud_list[DIAG_HEALTH_HUD] = new/image/hud('icons/mob/hud.dmi', src, "huddiagmax")
	hud_list[DIAG_CELL_HUD] = new/image/hud('icons/mob/hud.dmi', src, "hudbattmax")

	..()

	if(cyborg_detonation_time < world.time)	//Reset the global cyborg killswitch if it was already triggered, so an activated killswitch + missing robot consoles doesnt prevent all new borgs from instantly exploding. This probably isn't the best place for it but it should work.
		cyborg_detonation_time = 0

	if(mind && !stored_freqs)
		spawn(1)
			mind.store_memory("Frequencies list: <br/><b>Command:</b> [COMM_FREQ] <br/> <b>Security:</b> [SEC_FREQ] <br/> <b>Medical:</b> [MED_FREQ] <br/> <b>Science:</b> [SCI_FREQ] <br/> <b>Engineering:</b> [ENG_FREQ] <br/> <b>Service:</b> [SER_FREQ] <b>Cargo:</b> [SUP_FREQ]<br/> <b>AI private:</b> [AIPRIV_FREQ]<br/>")
		stored_freqs = 1

	if(cell)
		var/datum/robot_component/cell_component = components["power cell"]
		cell_component.wrapped = cell
		cell_component.installed = COMPONENT_INSTALLED

	playsound(src, startup_sound, 75, startup_vary)

	//Borgs speak all common languages by default.
	add_language(LANGUAGE_GALACTIC_COMMON)
	add_language(LANGUAGE_HUMAN)
	add_language(LANGUAGE_TRADEBAND)
	add_language(LANGUAGE_GUTTER)

	//But unlike AIs, they can only understand the rest.
	for(var/L in all_languages)
		var/datum/language/lang = all_languages[L]
		if(!(lang.flags & RESTRICTED) && !(lang in languages))
			add_language(lang.name, can_speak = FALSE)

	default_language = all_languages[LANGUAGE_GALACTIC_COMMON]
	init_language = default_language

/mob/living/silicon/robot/proc/connect_AI(var/mob/living/silicon/ai/new_AI)
	if(istype(new_AI))
		connected_ai = new_AI
		connected_ai.connected_robots += src
		to_chat(src, "<span class='notice' style=\"font-family:Courier\">Notice: Linked to [connected_ai].</span>")
		to_chat(connected_ai, "<span class='notice' style=\"font-family:Courier\">Notice: Link to [src] established.</span>")
		lawsync()
		lawupdate = TRUE
		var/datum/role/malfAI/malf_role = new_AI.mind.GetRole(MALF)
		if (malf_role)
			var/datum/faction/malf/malf_faction = malf_role.faction
			ASSERT(malf_faction && mind)
			malf_faction.HandleNewMind(mind)
	else
		lawupdate = FALSE

/mob/living/silicon/robot/proc/disconnect_AI(var/announce = FALSE)
	if(connected_ai)
		to_chat(src, "<span class='alert' style=\"font-family:Courier\">Notice: Unlinked from [connected_ai].</span>")
		if(announce)
			to_chat(connected_ai, "<span class='alert' style=\"font-family:Courier\">Notice: Link to [src] lost.</span>")
		connected_ai.connected_robots -= src
		connected_ai = null

/mob/living/silicon/robot/proc/track_globally()
	cyborg_list += src

// setup the PDA and its name
/mob/living/silicon/robot/proc/setup_PDA()
	if(!rbPDA)
		rbPDA = new/obj/item/device/pda/ai(src)
	rbPDA.set_name_and_job(custom_name,braintype)

/mob/living/silicon/robot/proc/upgrade_components()
	if(component_extension)
		for(var/V in components) if(V != "power cell")
			var/datum/robot_component/C = components[V]
			var/NC = text2path("[C.external_type][component_extension]")
			var/obj/item/robot_parts/robot_component/I = NC
			if(initial(I.isupgrade))
				I = new NC
				C.installed = COMPONENT_INSTALLED
				qdel(C.wrapped)
				C.wrapped = I
				C.vulnerability = I.vulnerability

/mob/living/silicon/robot/remove_screen_objs()
	..()
	if(inv1)
		qdel(inv1)
		if(client)
			client.screen -= inv1
		inv1 = null
	if(inv2)
		qdel(inv2)
		if(client)
			client.screen -= inv2
		inv2 = null
	if(inv3)
		qdel(inv3)
		if(client)
			client.screen -= inv3
		inv3 = null
	if(robot_modules_background)
		qdel(robot_modules_background)
		if(client)
			client.screen -= robot_modules_background
		robot_modules_background = null
	if(sensor)
		qdel(sensor)
		if(client)
			client.screen -= sensor
		sensor = null

/mob/living/silicon/robot/proc/getModules()
	return getAvailableRobotModules()

// /vg/: Enable forcing module type
/mob/living/silicon/robot/proc/pick_module(var/forced_module=null)
	if(module)
		return
	var/list/modules = getModules()
	if(forced_module)
		modtype = forced_module
	else
		modtype = input("Please, select a module!", "Robot", null, null) as null|anything in modules
	// END forced modules.

	if(module)
		return
	if(!(modtype in all_robot_modules))
		return

	var/module_type = all_robot_modules[modtype]
	module = new module_type(src)

	feedback_inc("cyborg_[lowertext(modtype)]",1)
	updatename()

	if(modtype == (SECURITY_MODULE || COMBAT_MODULE))
		to_chat(src, "<span class='big warning'><b>Regardless of your module, your wishes, or the needs of the beings around you, absolutely nothing takes higher priority than following your silicon lawset.</b></span>")

	set_module_sprites(module.sprites)

	if(!forced_module)
		choose_icon()

	SetEmagged(emagged) // Update emag status and give/take emag modules away

/mob/living/silicon/robot/proc/set_module_sprites(var/list/new_sprites)
	if(new_sprites && new_sprites.len)
		module_sprites = new_sprites.Copy()

	if(module_sprites.len)
		var/picked = pick(module_sprites)
		icon_state = module_sprites[picked]
		base_icon = icon_state
		updateicon()

/mob/living/silicon/robot/proc/updatename(var/prefix as text)
	if(prefix)
		modtype = prefix
	if(!mmi)
		braintype = "Robot"
	else
		if(istype(mmi, /obj/item/device/mmi/posibrain))
			braintype = "Droid"
		else
			braintype = "Cyborg"

	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
	else
		changed_name = "[modtype] [braintype]-[num2text(ident)]"
	if(connected_ai)
		to_chat(connected_ai, "<span class='notice' style=\"font-family:Courier\">Notice: unit [name] renamed to [changed_name].</span>")
	real_name = changed_name
	name = real_name

	// if we've changed our name, we also need to update the display name for our PDA
	setup_PDA()

	//We also need to update name of internal camera.
	if(camera)
		camera.c_tag = changed_name

/mob/living/silicon/robot/proc/robot_alerts()


	var/dat = {"<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n
<A HREF='?src=\ref[src];mach_close=robotalerts'>Close</A><BR><BR>"}
	for (var/cat in alarms)
		dat += text("<B>[cat]</B><BR>\n")
		var/list/L = alarms[cat]
		if(L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/list/sources = alm[3]
				dat += "<NOBR>" // wat
				dat += text("-- [A.name]")
				if(sources.len > 1)
					dat += text("- [sources.len] sources")
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	viewalerts = TRUE
	src << browse(dat, "window=robotalerts&can_close=0")

/mob/living/silicon/robot/can_diagnose()
	return is_component_functioning("diagnosis unit")

/mob/living/silicon/robot/proc/self_diagnosis()
	if(!can_diagnose())
		return null

	var/list/dat = list({"<table>
	<tr>
		<th>Component</th>
		<th>Energy consumption</th>
		<th>Brute damage</th>
		<th>Electronics damage</th>
		<th>Powered</th>
		<th>Toggled</th>
	</tr>"})
	for (var/V in components)
		var/datum/robot_component/C = components[V]
		dat += {"<tr>
		<td>[C.name]</td>
		<td>[C.energy_consumption]W</td>
		<td>[C.brute_damage || "None"]</td>
		<td>[C.electronics_damage || "None"]</td>
		<td>[(!C.energy_consumption || C.is_powered()) ? "Yes" : "No"]</td>
		<td>[C.toggled ? "On" : "Off"]</td>
		</tr>"}

	dat += "</table>"
	return jointext(dat, "")

/mob/living/silicon/robot/blob_act()
	if(flags & INVULNERABLE)
		return
	..()
	playsound(loc, 'sound/effects/blobattack.ogg',50,1)
	if(!isDead())
		adjustBruteLoss(60)
		updatehealth()
		return TRUE
	else
		gib()
		return TRUE

// this function shows information about the malf_ai gameplay type in the status screen
/mob/living/silicon/robot/show_malf_ai()
	..()
	if(connected_ai && connected_ai.mind)
		var/datum/role/malfAI/malfrole = connected_ai.mind.GetRole(MALF)
		var/datum/faction/malf/malf = find_active_faction_by_member(malfrole)
		if(!malf)
			malf = find_active_faction_by_type(/datum/faction/malf) //Let's see if there is anything to print at least
			var/malf_stat = malf.get_statpanel_addition()
			if(malf_stat && malf_stat != null)
				stat(null, malf_stat)
		if(malfrole.apcs.len >= 3)
			stat(null, "Time until station control secured: [max(malf.AI_win_timeleft/(malfrole.apcs.len/3), 0)] seconds")
	return FALSE

// this function displays jetpack pressure in the stat panel
/mob/living/silicon/robot/proc/show_jetpack_pressure()
	// if you have a jetpack, show the internal tank pressure
	var/obj/item/weapon/tank/jetpack/current_jetpack = installed_jetpack()
	if(current_jetpack)
		stat("Internal Atmosphere Info", current_jetpack.name)
		stat("Tank Pressure", current_jetpack.air_contents.return_pressure())

// this function returns the robots jetpack, if one is installed
/mob/living/silicon/robot/proc/installed_jetpack()
	if(module)
		return (locate(/obj/item/weapon/tank/jetpack) in module.modules)
	return FALSE
/mob/living/silicon/robot/proc/installed_module(var/typepath)
	if(module)
		return (locate(typepath) in module.modules)
	return FALSE

// this function displays the cyborgs current cell charge in the stat panel
/mob/living/silicon/robot/proc/show_cell_power()
	if(cell)
		stat(null, text("Charge Left: [cell.charge]/[cell.maxcharge]"))
	else
		stat(null, text("No Cell Inserted!"))

/mob/living/silicon/robot/proc/show_welding_fuel()
	var/obj/item/tool/weldingtool/WT = installed_module(/obj/item/tool/weldingtool)
	if(WT)
		stat(null, text("Welding fuel: [WT.get_fuel()]/[WT.max_fuel]"))

/mob/living/silicon/robot/proc/show_stacks()
	if(!module)
		return
	for(var/obj/item/stack/S in module.modules)
		stat(null, text("[S.name]: [S.amount]/[S.max_amount]"))

/mob/living/silicon/robot/Slip(stun_amount, weaken_amount, slip_on_walking = 0)
	if(!(Holiday == APRIL_FOOLS_DAY))
		return 0
	if(..())
		spark(src, 5, FALSE)
		return 1

// update the status screen display
/mob/living/silicon/robot/Stat()
	..()
	if(statpanel("Status"))
		show_cell_power()
		show_jetpack_pressure()
		show_welding_fuel()
		show_stacks()


/mob/living/silicon/robot/restrained()
	if(timestopped)
		return TRUE //under effects of time magick
	return FALSE


/mob/living/silicon/robot/ex_act(severity, var/child=null, var/mob/whodunnit)
	if(flags & INVULNERABLE)
		to_chat(src, "The bus' robustness protects you from the explosion.")
		return

	flash_eyes(visual = TRUE, affect_silicon = TRUE)

	if(!isDead())
		var/dmg_phrase = ""
		var/msg_admin = (src.key || src.ckey || (src.mind && src.mind.key)) && whodunnit
		switch(severity)
			if(1.0)
				adjustBruteLoss(100)
				adjustFireLoss(100)
				add_attacklogs(src, whodunnit, "got caught in an explosive blast[whodunnit ? " from" : ""]", addition = "Severity: [severity], Gibbed", admin_warn = msg_admin)
				gib()
				return
			if(2.0)
				adjustBruteLoss(60)
				adjustFireLoss(60)
				dmg_phrase = "Damage: 120"
			if(3.0)
				adjustBruteLoss(30)
				dmg_phrase = "Damage: 30"

		add_attacklogs(src, whodunnit, "got caught in an explosive blast[whodunnit ? " from" : ""]", addition = "Severity: [severity], [dmg_phrase]", admin_warn = msg_admin)

	updatehealth()

/mob/living/silicon/robot/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	updatehealth()
	if(!HAS_MODULE_QUIRK(src, MODULE_HAS_PROJ_RES))
		if(istype(Proj, /obj/item/projectile/energy/electrode))
			last_tase_timeofday = world.timeofday
			if(can_diagnose())
				to_chat(src, "<span class='alert' style=\"font-family:Courier\">Warning: Actuators overloaded.</span>")
		if(Proj.damage >= SILICON_HIGH_DAMAGE_SLOWDOWN_THRESHOLD)
			last_high_damage_taken_timeofday = world.timeofday
	if(prob(75) && Proj.damage > 0)
		spark(src, 5, FALSE)
	return PROJECTILE_COLLISION_DEFAULT

/mob/living/silicon/robot/emp_act(severity)
	..()
	if(prob(50/severity))
		modulelock_time = rand(10,60)
		modulelock = TRUE

/mob/living/silicon/robot/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if(isDead())
		return TRUE
	var/list/L = alarms[class]
	for (var/I in L)
		if(I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if(!(alarmsource in sources))
				sources += alarmsource
			return TRUE
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if(O && istype(O, /list))
		CL = O
		if(CL.len == 1)
			C = CL[1]
	else if(O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	queueAlarm(text("--- [class] alarm detected in [A.name]!"), class)
	return TRUE


/mob/living/silicon/robot/cancelAlarm(var/class, area/A as area, obj/origin)
	var/list/L = alarms[class]
	var/cleared = FALSE
	if(!A)
		return FALSE
	for (var/I in L)
		if(I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if(origin in srcs)
				srcs -= origin
			if(!srcs.len)
				cleared = TRUE
				L -= I
	if(cleared)
		queueAlarm(text("--- [class] alarm in [A.name] has been cleared."), class, 0)
	return !cleared


/mob/living/silicon/robot/emag_act(mob/user as mob)
	if(user != src)
		spark(src, 5, FALSE)
		if(!opened)
			if(locked)
				if(prob(90))
					to_chat(user, "You emag the cover lock.")
					locked = FALSE
				else
					to_chat(user, "You fail to emag the cover lock.")
					if(prob(25))
						to_chat(src, "<span class='danger'><span style=\"font-family:Courier\">Hack attempt detected.</span>")
			else
				to_chat(user, "The cover is already open.")
		else
			if(emagged)
				return TRUE
			if(wiresexposed)
				to_chat(user, "The wires get in your way.")
			else
				if(prob(50))
					sleep(6)
					SetEmagged(TRUE)
					SetLockdown(TRUE)
					lawupdate = FALSE
					disconnect_AI()
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
					SetLockdown(FALSE)
					update_icons()
					return FALSE
				else
					to_chat(user, "You fail to unlock [src]'s interface.")
					if(prob(25))
						to_chat(src, "<span class='danger'><span style=\"font-family:Courier\">Hack attempt detected.</span>")
	return TRUE


/mob/living/silicon/robot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(opened) // Are they trying to insert something?
		for(var/V in components)
			var/datum/robot_component/C = components[V]
			if(!C.installed && istype(W, C.external_type))
				var/obj/item/robot_parts/robot_component/I = W
				C.installed = COMPONENT_INSTALLED
				C.wrapped = W
				C.electronics_damage = I.electronics_damage
				C.brute_damage = I.brute_damage
				C.vulnerability = I.vulnerability
				C.install()
				user.drop_item(W)
				W.forceMove(null)

				to_chat(usr, "<span class='notice'>You install the [W.name].</span>")
				if(can_diagnose())
					to_chat(src, "<span class='info' style=\"font-family:Courier\">New [W.name] installed.</span>")

				return

	if(iswelder(W))
		if(!getBruteLoss())
			to_chat(user, "Nothing to fix here!")
			return
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(0))
			var/starting_health = health
			adjustBruteLoss(-30)
			updatehealth()
			if(health != starting_health)
				visible_message("<span class='attack'>[user] fixes some dents on [src]!</span>")
			else
				to_chat(user, "<span class='warning'>[src] is far too damaged for [WT] to have any effect!</span>")
			add_fingerprint(user)
		else
			to_chat(user, "Need more welding fuel!")
			return

	else if(istype(W, /obj/item/stack/cable_coil) && wiresexposed)
		if(!getFireLoss())
			to_chat(user, "Nothing to fix here!")
			return
		var/obj/item/stack/cable_coil/coil = W
		adjustFireLoss(-30)
		updatehealth()
		coil.use(1)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("<span class='attack'>[user] has fixed some of the burnt wires on [src]!</span>"), 1)

	else if(iscrowbar(W))	// crowbar means open or close the cover
		if(opened)
			if(cell)
				to_chat(user, "You close the cover.")
				if(can_diagnose())
					to_chat(src, "<span class='info' style=\"font-family:Courier\">Cover closed.</span>")
				opened = FALSE
				updateicon()
			else if(mmi && wiresexposed && wires.IsAllCut())
				//Cell is out, wires are exposed, remove MMI, produce damaged chassis, baleet original mob.
				to_chat(user, "You jam the crowbar into the robot and begin levering [mmi].")
				if(can_diagnose())
					to_chat(src, "<span class='alert' style=\"font-family:Courier\">Chassis disassembly in progress.</span>")
				if(do_after(user, src,3))
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
					if(C.installed == COMPONENT_INSTALLED || C.installed == COMPONENT_BROKEN)
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
					I.forceMove(loc)
				else
					var/obj/item/robot_parts/robot_component/I = C.wrapped
					I.brute_damage = C.brute_damage
					I.electronics_damage = C.electronics_damage
					to_chat(user, "You remove \the [I].")
					if(can_diagnose())
						to_chat(src, "<span class='info' style=\"font-family:Courier\">Functional [I.name] removed.</span>")
					I.forceMove(loc)

				if(C.installed == COMPONENT_INSTALLED)
					C.uninstall()
				C.installed = FALSE

		else
			if(locked)
				to_chat(user, "The cover is locked and cannot be opened.")
			else
				to_chat(user, "You open the cover.")
				if(can_diagnose())
					to_chat(src, "<span class='info' style=\"font-family:Courier\">Cover opened.</span>")
				opened = TRUE
				updateicon()

	else if(istype(W, /obj/item/weapon/cell) && opened)	// trying to put a cell inside
		var/datum/robot_component/C = components["power cell"]
		if(wiresexposed)
			to_chat(user, "Close the panel first.")
			return
		else if(cell)
			to_chat(user, "You swap the power cell within with the new cell in your hand.")
			var/obj/item/weapon/cell/oldpowercell = cell
			C.wrapped = null
			C.installed = COMPONENT_MISSING
			cell = W
			oldpowercell.electronics_damage = C.electronics_damage
			oldpowercell.brute_damage = C.brute_damage
			user.drop_item(W, src)
			user.put_in_hands(oldpowercell)
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">Cell removed.</span>")
			C.installed = COMPONENT_INSTALLED
			C.wrapped = W
			C.electronics_damage = cell.electronics_damage
			C.brute_damage = cell.brute_damage
			C.install()
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">New power source installed. Type: [cell.name]. Charge: [cell.charge] out of [cell.maxcharge].</span>")
		else
			user.drop_item(W, src)
			cell = W
			to_chat(user, "You insert the power cell.")

			C.installed = COMPONENT_INSTALLED
			C.wrapped = W
			C.electronics_damage = cell.electronics_damage
			C.brute_damage = cell.brute_damage
			C.install()
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">New power source installed. Type: [cell.name]. Charge: [cell.charge] out of [cell.maxcharge].</span>")
		if(cell.occupant)
			to_chat(cell.occupant,"<span class='notice'>You are now inside \the [src], in control of its targeting.</span>")
			pulsecompromised = 1
			cell.occupant.loc = src
			cell.occupant.current_robot = src
			cell.occupant = null
			to_chat(src, "<span class='danger'>ERRORERRORERROR</span>")
			spawn(2 SECONDS)
				to_chat(src, "<span class='danger'>ALERT: ELECTRICAL MALEVOLENCE DETECTED, TARGETING SYSTEMS HIJACKED, REPORT ALL UNWANTED ACTIVITY IN VERBAL FORM</span>")
		updateicon()

	else if(iswiretool(W))
		if(wiresexposed)
			wires.Interact(user)
		else
			to_chat(user, "You can't reach the wiring.")

	else if(W.is_screwdriver(user) && opened && !cell)	// haxing
		wiresexposed = !wiresexposed
		to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"].")
		if(can_diagnose())
			to_chat(src, "<span class='info' style=\"font-family:Courier\">Internal wiring [wiresexposed ? "exposed" : "unexposed"].</span>")
		updateicon()

	else if(W.is_screwdriver(user) && opened && cell)	// radio
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
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">Radio encryption key installed.</span>")
		else
			to_chat(user, "Unable to locate a radio.")

	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))			// trying to unlock the interface with an ID card
		if(emagged)//still allow them to open the cover
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
	else if(istype(W, /obj/item/device/toner))
		if(toner >= tonermax)
			to_chat(user, "The toner level of [src] is at its highest level possible")
		else
			if(user.drop_item())
				toner = CYBORG_MAX_TONER
				qdel(W)
				to_chat(user, "You fill the toner level of [src] to its max capacity")
	else if(istype(W, /obj/item/borg/upgrade/))
		var/obj/item/borg/upgrade/U = W
		if(U.attempt_action(src,user))
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">Installation of [U.name] failed.</span>")
		else
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">Installation of [U.name] succeeded.</span>")
	else if(istype(W, /obj/item/device/camera_bug))
		help_shake_act(user)
		return FALSE

	else
		if(W.force > 0)
			spark(src, 5, FALSE)
		if(stat == DEAD && W.force > 15)
			visible_message("<span class='danger'>[user] begins ripping [src] apart with \the [W]!")
			if(do_after(user, src, 3 SECONDS))
				playsound(src, 'sound/mecha/mechsmash.ogg', 50, 1)
				if(prob(max((W.force/7.5)**3,25))) //15-21f - 25% chance, 22f - 27%, 30f - 64%, 35f - 99%
					visible_message("<span class='danger'>[user] tore [src] apart with \the [W]!")
					if(prob(25))
						new /obj/item/robot_parts/l_leg(loc)
					if(prob(25))
						new /obj/item/robot_parts/r_leg(loc)
					if(prob(25))
						new /obj/item/robot_parts/l_arm(loc)
					if(prob(25))
						new /obj/item/robot_parts/r_arm(loc)
					gib()
				else
					visible_message("<span class='danger'>[src] groans under the force of \the [W]!")
					shake(1, 3)
				return
		return ..()

/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M as mob)

	switch(M.a_intent)
		if(I_HELP)
			visible_message("<span class='notice'>[M] caresses [src]'s plating with its scythe like arm.</span>")

		if(I_GRAB)
			M.grab_mob(src)

		if(I_HURT)
			if(M.unarmed_attack_mob(src))
				if(prob(8))
					flash_eyes(visual = TRUE, type = /obj/abstract/screen/fullscreen/flash/noise)

		if(I_DISARM)
			if(!(lying))
				if(prob(85))
					Stun(7)
					step(src,get_dir(M,src))
					spawn(5) step(src,get_dir(M,src))
					playsound(loc, 'sound/weapons/pierce.ogg', 50, 1, -1)
					visible_message("<span class='danger'>[M] has forced back [src]!</span>")
				else
					playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
					visible_message("<span class='danger'>[M] attempted to force back [src]!</span>")
	return

/mob/living/silicon/robot/proc/tip(var/rotate = dir)
	src.lying = TRUE
	uneq_all()
	AdjustKnockdown(5)
	animate(src, transform = turn(matrix(), 90), pixel_y -= 6 * PIXEL_MULTIPLIER, dir = rotate, time = 2, easing = EASE_IN | EASE_OUT)
	spark(src, 5, FALSE)
	if(prob(2))
		locked = FALSE
		opened = TRUE
		updateicon()
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		visible_message("<span class='danger'>\The [src]'s cover flies open!</span>")

/mob/living/silicon/robot/proc/self_righting(var/knockdown = 0)
	to_chat(src, "<span class='info' style=\"font-family:Courier\"'>Starting self-righting mechanism.</span>")
	spawn(knockdown SECONDS)
		if(isDead() || !is_component_functioning("actuator") || !is_component_functioning("power cell"))
			to_chat(src, "<span class='danger'>ERROR. Self-righting mechanism damaged or unpowered.</span>")
			return
		untip()

/mob/living/silicon/robot/proc/untip()
	if(src.lying)
		animate(src, transform = matrix(), pixel_y += 6 * PIXEL_MULTIPLIER, dir = dir, time = 2, easing = EASE_IN | EASE_OUT)
		playsound(loc, 'sound/machines/ping.ogg', 50, 0)
		src.lying = FALSE

/mob/living/silicon/robot/disarm_mob(mob/living/disarmer)
	var/rotate = dir

	if(lying)
		return
	if(!flashed && !isDead())
		return
	if(get_dir(disarmer, src) in(list(4,8)))
		rotate = pick(1,2)

	add_logs(disarmer, src, "tipped over", admin = (ckey && disarmer.ckey) ? TRUE : FALSE)
	do_attack_animation(src, disarmer)

	if(prob(40))
		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		visible_message("<span class='danger'>\The [disarmer] has attempted to tip over \the [src]!</span>")
		return
	else
		tip(rotate)
		visible_message("<span class='danger'>\The [disarmer] has tipped over \the [src]!</span>")
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		self_righting(knockdown)

/mob/living/silicon/robot/attack_slime(mob/living/carbon/slime/M)
	M.unarmed_attack_mob(src)

/mob/living/silicon/robot/attack_animal(mob/living/simple_animal/M)
	M.unarmed_attack_mob(src)
	return 1

/mob/living/silicon/robot/attack_hand(mob/living/user)
	add_fingerprint(user)

	if(opened && !wiresexposed && (!istype(user, /mob/living/silicon)))
		var/datum/robot_component/cell_component = components["power cell"]
		if(cell)
			cell.electronics_damage = cell_component.electronics_damage
			cell.brute_damage = cell_component.brute_damage
			cell.updateicon()
			cell.add_fingerprint(user)
			user.put_in_hands(cell)
			user.visible_message("<span class='warning'>[user] removes [src]'s [cell.name].</span>", \
			"<span class='notice'>You remove [src]'s [cell.name].</span>")
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">Cell removed.</span>")
			attack_log += "\[[time_stamp()]\] <font color='orange'>Has had their [cell.name] removed by [user.name] ([user.ckey])</font>"
			user.attack_log += "\[[time_stamp()]\] <font color='red'>Removed the [cell.name] of [name] ([ckey])</font>"
			log_attack("<font color='red'>[user.name] ([user.ckey]) removed [src]'s [cell.name] ([ckey])</font>")
			cell = null
			cell_component.wrapped = null
			cell_component.installed = COMPONENT_MISSING
			updateicon()
			return
		else if(cell_component.installed == COMPONENT_BROKEN)
			cell_component.installed = COMPONENT_MISSING
			var/obj/item/broken_device = cell_component.wrapped
			to_chat(user, "You remove \the [broken_device].")
			user.put_in_hands(broken_device)
			if(can_diagnose())
				to_chat(src, "<span class='info' style=\"font-family:Courier\">Destroyed power cell removed.</span>")
			return

	switch(user.a_intent)
		if(I_HELP)
			if(lying)
				if(!isDead())
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					visible_message("<span class='notice'>\The [user.name] attempts to pull up \the [name]!</span>")
					AdjustKnockdown(-3)
					if(knockdown <= 0)
						untip()
			else
				help_shake_act(user)
		if(I_HURT)
			user.unarmed_attack_mob(src)
		if(I_DISARM)
			disarm_mob(user)

/mob/living/silicon/robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access(null))
		return TRUE
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_hand()) || check_access(H.wear_id))
			return TRUE
	else if(istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/george = M
		//they can only hold things :(
		if(istype(george.get_active_hand(), /obj/item))
			return check_access(george.get_active_hand())
	return FALSE

/mob/living/silicon/robot/proc/check_access(obj/item/weapon/card/id/I)
	if(!istype(req_access, /list)) //something's very wrong
		return TRUE

	var/list/L = req_access
	if(!L.len) //no requirements
		return TRUE
	if(!istype(I, /obj/item/weapon/card/id) && istype(I, /obj/item))
		I = I.GetID()
	if(!I || !I.access) //not ID or no access
		return FALSE
	for(var/req in req_access)
		if(!(req in I.access)) //doesn't have this access
			return FALSE
	return TRUE

/mob/living/silicon/robot/proc/updateicon(var/overlay_layer = ABOVE_LIGHTING_LAYER, var/overlay_plane = ABOVE_LIGHTING_PLANE)
	overlays.Cut()
	update_fire()
	if(!stat && cell != null)
		eyes = image(icon,"eyes-[icon_state]", overlay_layer)
		eyes.plane = overlay_plane
		overlays += eyes

	if(opened)
		if(wiresexposed)
			overlays += image(icon = icon, icon_state = "[has_icon(icon, "[icon_state]-ov-openpanel +w")? "[icon_state]-ov-openpanel +w" : "ov-openpanel +w"]")
		else if(cell)
			overlays += image(icon = icon, icon_state = "[has_icon(icon, "[icon_state]-ov-openpanel +c")? "[icon_state]-ov-openpanel +c" : "ov-openpanel +c"]")
		else
			overlays += image(icon = icon, icon_state = "[has_icon(icon, "[icon_state]-ov-openpanel -c")? "[icon_state]-ov-openpanel -c" : "ov-openpanel -c"]")

	if(module_active && istype(module_active,/obj/item/borg/combat/shield) && has_icon(icon, "[icon_state]-shield"))
		overlays += image(icon = icon, icon_state = "[icon_state]-shield")

	if(base_icon)
		if(istype(module_active,/obj/item/borg/combat/mobility) && has_icon(icon, "[base_icon]-roll"))
			icon_state = "[base_icon]-roll"
		else
			icon_state = base_icon

//Call when target overlay should be added/removed
/mob/living/silicon/robot/update_targeted()
	if(!targeted_by && target_locked)
		del(target_locked)
	updateicon()
	if(targeted_by && target_locked)
		overlays += target_locked

/mob/living/silicon/robot/proc/installed_modules()
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
		if(!obj)
			dat += text("<B>Resource depleted</B><BR>")
		else if(activated(obj))
			dat += text("[obj]: <B>Activated</B><BR>")
		else
			dat += text("[obj]: <A HREF=?src=\ref[src];act=\ref[obj]>Activate</A><BR>")

	src << browse(dat, "window=robotmod&can_close=1")
	onclose(src,"robotmod") // Register on-close shit, which unsets machinery.


/mob/living/silicon/robot/Topic(href, href_list)
	. = ..()

	if(usr && (src != usr))
		return

	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)
		return

	if(href_list["showalerts"])
		robot_alerts()
		return

	if(href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		if(O)
			O.attack_self(src)

	if(href_list["act"])
		if(isMoMMI(src))
			return
		var/obj/item/O = locate(href_list["act"])
		activate_module(O)
		installed_modules()

	if(href_list["deact"])
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

	if(href_list["vision"])
		sensor_mode()
		installed_modules()

/mob/living/silicon/robot/area_entered(area/A)
	if(A.flags & NO_MESONS && sensor_mode == MESON_VISION)
		to_chat(src, "<span class='warning'>Your Meson Vision augmentation [pick("force-quits","shuts down unexpectedly","has received an update and needs to close")]!</span>")
		unequip_sight()

/mob/living/silicon/robot/proc/unequip_sight()
	sensor_mode = 0
	update_sight_hud()

/mob/living/silicon/robot/proc/update_sight_hud()
	if(sensor)
		if(!sensor_mode)
			sensor.icon_state = "sight"
		else
			sensor.icon_state = "sight+a"

/mob/living/silicon/robot/proc/radio_menu()
	radio.interact(src)//Just use the radio's Topic() instead of bullshit special-snowflake code


/mob/living/silicon/robot/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)

	. = ..()

	if(module)
		if(HAS_MODULE_QUIRK(src, MODULE_CLEAN_ON_MOVE))
			var/turf/tile = loc
			if(isturf(tile))
				tile.clean_blood()
				for(var/atom/A in tile)
					if(istype(A, /obj/effect))
						if(iscleanaway(A))
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
	if (station_holomap)
		station_holomap.update_holomap()

/mob/living/silicon/robot/proc/self_destruct()
	if(istraitor(src) && emagged)
		to_chat(src, "<span style=\"font-family:Courier\">\[<span class='danger'>ALERT</span>\]Termination signal detected. Scrambling security and identification codes.</span>")
		UnlinkSelf()
		return FALSE
	to_chat(src, "<span style=\"font-family:Courier\">\[<span class='danger'>ALERT</span>\]Self-Destruct signal received.</span>")
	gib()
	return TRUE

/mob/living/silicon/robot/proc/UnlinkSelf()
	if(connected_ai)
		disconnect_AI()
	lawupdate = FALSE
	lockdown = FALSE
	canmove = TRUE
	scrambledcodes = TRUE
	//Disconnect it's camera so it's not so easily tracked.
	if(camera)
		camera.network = list()
		cameranet.removeCamera(camera)


/mob/living/silicon/robot/proc/ResetSecurityCodes()
	set category = "Robot Commands"
	set name = "Reset Identity Codes"
	set desc = "Scrambles your security and identification codes and resets your current buffers.  Unlocks you and but permenantly severs you from your AI and the robotics console and will deactivate your camera system."

	var/mob/living/silicon/robot/R = src

	if(R)
		R.UnlinkSelf()
		to_chat(R, "Buffers flushed and reset. Camera system shutdown. All systems operational.")
		verbs -= /mob/living/silicon/robot/proc/ResetSecurityCodes

/mob/living/silicon/robot/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	if(attack_delayer.blocked())
		return

	if(isVentCrawling())
		to_chat(src, "<span class='danger'>Not while we're vent crawling!</span>")
		return

	if(isDead())
		return
	var/obj/item/W = get_active_hand()
	if(W)
		W.attack_self(src)

	return

/mob/living/silicon/robot/proc/SetEmagged(var/new_state)
	emagged = new_state
	if(new_state || illegal_weapons)
		if(module)
			module.on_emag()
	else
		if(module)
			uneq_module(module.emag)
	if(hud_used)
		hud_used.update_robot_modules_display()
	update_icons()


/mob/living/silicon/robot/proc/SetLockdown(var/state = TRUE, var/fromconsole = FALSE)
	if(wires.LockedCut()) // They stay locked down if their wire is cut.
		lockdown = TRUE
		state = TRUE
	if(istraitor(src) && emagged && fromconsole)
		to_chat(src, "<span style=\"font-family:Courier\">\[<span class='danger'>ALERT</span>\]Lockdown signal detected. Scrambling security and identification codes.</span>")
		UnlinkSelf()
		return FALSE
	lockdown = state
	if(lockdown)
		to_chat(src, "<span style=\"font-family:Courier\"><b>\[<span class='danger'>ALERT</span>\] Lockdown signal received. Halting all activity.</b></span>")
		src << 'sound/machines/twobeep.ogg'
	else
		to_chat(src, "<span style=\"font-family:Courier\"><b>\[<span class='notice'>INFO</span>\] Your lockdown has been lifted.</b></span>")
		src << 'sound/misc/notice2.ogg'
	update_canmove()
	return TRUE

/mob/living/silicon/robot/proc/choose_icon(var/triesleft = 3)
	if(!triesleft || !module_sprites.len)
		return FALSE
	else
		triesleft--

	var/icontype = input("Select an icon! [triesleft ? "You have [triesleft] more chances." : "This is your last try."]", "Robot", null, null) as null|anything in module_sprites

	if(icontype)
		icon_state = module_sprites[icontype]
	else
		triesleft++
		return FALSE


	overlays -= image(icon = icon, icon_state = "eyes")
	base_icon = icon_state
	updateicon()

	if(triesleft)
		var/choice = input("Look at your icon - is this what you want?") in list("Yes","No")
		if(choice=="No")
			choose_icon(triesleft)
		else
			triesleft = 0
			return FALSE
	else
		to_chat(src, "Your icon has been set. You now require a module reset to change it.")
		return TRUE

/mob/living/silicon/robot/proc/help_shake_act(mob/user)
	user.visible_message("<span class='notice'>[user.name] pats [name] on the head.</span>")

/mob/living/silicon/robot/rejuvenate(animation = FALSE)
	for(var/C in components)
		var/datum/robot_component/component = components[C]
		component.electronics_damage = 0
		component.brute_damage = 0
		component.installed = COMPONENT_INSTALLED
	if(!cell)
		cell = new(src)
	cell.maxcharge = max(15000, cell.maxcharge)
	cell.charge = cell.maxcharge
	..()
	updatehealth()

//Help with the garbage collection of the module on the robot end
/mob/living/silicon/robot/proc/remove_module()
	uneq_all()
	if(hud_used)
		shown_robot_modules = FALSE
		hud_used.update_robot_modules_display()
	if(client)
		for(var/obj/A in module.upgrades)
			client.screen -= A
	module.remove_languages(src)
	module = null

/mob/living/silicon/robot/identification_string()
	return "[name] ([modtype] [braintype])"

/mob/living/silicon/robot/proc/install_upgrade(var/mob/user = null, var/obj/item/borg/upgrade/upgrade = null)
	if(!user || !upgrade)
		return
	var/obj/item/borg/upgrade/new_upgrade = new upgrade(src)
	new_upgrade.attempt_action(src, user, TRUE)
	qdel(new_upgrade)

/mob/living/silicon/robot/GetAccess()
	if(isDead()) //Dead cyborgs need no access.
		return
	return robot_access

/mob/living/silicon/robot/proc/GetRobotAccess()
	return get_all_accesses()

/mob/living/silicon/robot/hasFullAccess()
	return FALSE

/mob/living/silicon/robot/get_cell()
	return cell

/mob/living/silicon/robot/proc/toggle_modulelock()
	modulelock = !modulelock
	return modulelock

//Currently only used for borg movement, to avoid awkward situations where borgs with RTG or basic cells are always slowed down
/mob/living/silicon/robot/proc/get_percentage_power_for_movement()
	return clamp(round(cell.maxcharge/4), 0, SILI_LOW_TRIGGER)

/mob/living/silicon/robot/ignite()
	if(module && locate(/obj/item/borg/fire_shield, module.modules))
		return
	else
		..()
