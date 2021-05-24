// TO DO:
/*
epilepsy flash on lights
delay round message
microwave makes robots
dampen radios
reactivate cameras - done
eject engine
core sheild
cable stun
rcd light flash thingy on matter drain
*/

#define MALFUNCTION "Malfunction"
/datum/AI_Module
	var/uses = 0
	var/module_name
	var/mod_pick_name
	var/description = ""
	var/engaged = 0
	var/cost = 5
	var/one_time = 0

	var/spell/power_type = null


/datum/AI_Module/large/
	uses = 1

/datum/AI_Module/small/
	uses = 5

/datum/AI_Module/proc/on_purchase(mob/living/silicon/ai/user) //What happens when a module is purchased, by default gives the AI the spell/adds charges to their existing spell if they have it
	if(power_type)
		for(var/spell/S in user.spell_list)
			if (istype(S,power_type))
				S.charge_counter += uses
				return
		user.add_spell(new power_type, "malf_spell_ready",/obj/abstract/screen/movable/spell_master/malf)

	// statistics collection - malf module purchases
	if(user.mind && istype(user.mind.faction, /datum/faction/malf))
		var/datum/faction/malf/mf = user.mind.faction // can never be too careful, in BYOND land
		if(istype(mf.stat_datum, /datum/stat/faction/malf))
			var/datum/stat/faction/malf/MS = mf.stat_datum
			MS.modules.Add(new /datum/stat/malf_module_purchase(src))

/datum/AI_Module/large/upgrade_defenses
	module_name = "Core Defense Upgrade"
	mod_pick_name = "coredefense"
	description = "Improves the firing speed and health of all AI turrets, and causes them to shoot highly-lethal pulse beams. You core also strengthens its circuitry, making it immune to the burn damage. This effect is permanent and you will no longer be able to shunt."
	cost = 50
	one_time = 1
	power_type = /spell/aoe_turf/fortify_core

/datum/AI_Module/large/upgrade_defenses/on_purchase(mob/living/silicon/ai/user)
	..()
	for(var/obj/machinery/turret/turret in machines)
		turret.health += 120	//200 Totaldw
		turret.shot_delay = 15
		turret.lasertype = /obj/item/projectile/beam/pulse
		turret.fire_twice = 1
	to_chat(user, "<span class='warning'>Core defenses upgraded.</span>")
	user.vis_contents += new /obj/effect/overlay/ai_shield
	user.can_shunt = 0
	to_chat(user, "<span class='warning'>You cannot shunt anymore.</span>")


/spell/aoe_turf/fortify_core
	name = "Fortify Core (Toggle)"
	desc = "Reroutes your internal energy to a built-in blast shield within your core, greatly reducing damage taken. The shield will drain your power while active."
	user_type = USER_TYPE_MALFAI
	panel = MALFUNCTION
	charge_type = Sp_RECHARGE
	charge_max = 1 SECONDS
	hud_state = "fortify"
	override_base = "grey"
	cooldown_min = 1 SECONDS

/obj/effect/overlay/ai_shield
	name = "AI Firewall"
	desc = "You can see the words 'FUCK C4RB0NS' etched on to it."
	layer = LIGHTING_LAYER
	icon = 'icons/mob/ai.dmi'
	icon_state = "lockdown-up"
	vis_flags = VIS_INHERIT_ID

/obj/effect/overlay/ai_shield/proc/lower()
	flick("lockdown-open", src)
	icon_state = "lockdown-up"

/obj/effect/overlay/ai_shield/proc/raise()
	flick("lockdown-close", src)
	icon_state = "lockdown"

/spell/aoe_turf/fortify_core/before_target(mob/user)
	if(!isAI(user))
		to_chat(user, "<span class'warning'>Only AIs can cast this spell. You shouldn't have this ability.</span>")
		return 1

/spell/aoe_turf/fortify_core/cast(var/list/targets, var/mob/user)
	var/mob/living/silicon/ai/A = user
	var/obj/effect/overlay/ai_shield/shield
	shield = locate(/obj/effect/overlay/ai_shield) in A.vis_contents
	if(A.ai_flags & COREFORTIFY)
		if(shield)
			shield.lower()
		A.ai_flags &= ~COREFORTIFY
	else
		if(shield)
			shield.raise()
		A.ai_flags |= COREFORTIFY
	playsound(user, 'sound/machines/poddoor.ogg', 60, 1)
	to_chat(user, "<span class='warning'>[A.ai_flags & COREFORTIFY ? "Firewall Activated" : "Firewall Deactivated"].</span>")

/datum/AI_Module/large/explosive
	module_name = "Explosive Hardware"
	mod_pick_name = "siliconexplode"
	description = "Overrides the thermal safeties on cyborgs bound to you, causing them to violently explode when destroyed. Your own core is also affected, causing it to explode violently when system integrity reaches zero."
	cost = 15
	one_time = 1

/datum/AI_Module/large/explosive/on_purchase(mob/living/silicon/ai/user)
	user.explosive_cyborgs = TRUE
	user.explosive = TRUE
	to_chat(user, "<span class='warning'>You and your cyborgs will now explode on death.</span>")

/datum/AI_Module/small/overload_machine
	module_name = "Machine overload"
	mod_pick_name = "overload"
	description = "Overloads an electrical machine, causing a small explosion after a short delay. 2 uses."
	uses = 2
	cost = 15
	power_type = /spell/targeted/overload_machine

/spell/targeted/overload_machine
	name = "Overload Machine"
	user_type = USER_TYPE_MALFAI
	panel = MALFUNCTION
	spell_flags = WAIT_FOR_CLICK
	range = GLOBALCAST
	charge_type = Sp_CHARGES
	charge_max = 2
	hud_state = "overload"
	override_base = "malf"

/spell/targeted/overload_machine/is_valid_target(var/atom/target)
	if(istype(target, /obj/item/device/radio/intercom))
		return 1
	if (istype(target, /obj/machinery))
		var/obj/machinery/M = target
		return M.can_overload()
	else
		to_chat(holder, "That is not a machine.")

/spell/targeted/overload_machine/cast(var/list/targets, mob/user)
	var/obj/machinery/M = targets[1]
	M.visible_message("<span class='notice'>You hear a loud electrical buzzing sound!</span>")
	spawn(50)
		explosion(get_turf(M), -1, 1, 2, 3) //C4 Radius + 1 Dest for the machine
		qdel(M)

/datum/AI_Module/large/place_cyborg_autoborger
	module_name = "Robotic Factory (Removes Shunting)"
	mod_pick_name = "cyborgtransformer"
	description = "Build a machine anywhere, using expensive nanomachines, that can convert a living human into a loyal cyborg slave when placed inside."
	cost = 100

	power_type = /spell/aoe_turf/conjure/place_autoborger

/spell/aoe_turf/conjure/place_autoborger
	name = "Place Robotic Factory"
	user_type = USER_TYPE_MALFAI
	panel = MALFUNCTION
	charge_type = Sp_CHARGES
	charge_max = 1
	spell_flags = WAIT_FOR_CLICK | NODUPLICATE | IGNORESPACE | IGNOREDENSE
	range = GLOBALCAST
	summon_type = list(/obj/machinery/autoborger/conveyor)
	hud_state = "autoborger"
	override_base = "malf"

/spell/aoe_turf/conjure/place_autoborger/New()
	..()

/spell/aoe_turf/conjure/place_autoborger/before_target(mob/user)
	var/mob/living/silicon/ai/A = user
	if(!istype(A))
		return 1
	if(!isturf(A.loc)) // AI must be in it's core.
		return 1
	return 0

/spell/aoe_turf/conjure/place_autoborger/is_valid_target(var/atom/target)
	// Make sure there is enough room.
	if(!isturf(target))
		return 0
	var/turf/middle = target
	var/list/turfs = list(middle, locate(middle.x - 1, middle.y, middle.z), locate(middle.x + 1, middle.y, middle.z))
	var/alert_msg = "There isn't enough room. Make sure you are placing the machine in a clear area and on a floor."
	for(var/T in turfs)
		// Make sure the turfs are clear and the correct type.
		if(!istype(T, /turf/simulated/floor))
			alert(src, alert_msg)
			return
		var/turf/simulated/floor/F = T
		for(var/atom/movable/AM in F.contents)
			if(AM.density)
				alert(src, alert_msg)
				return
	var/datum/camerachunk/C = cameranet.getCameraChunk(middle.x, middle.y, middle.z)
	if(!C.visibleTurfs[middle])
		alert(holder, "We cannot get camera vision of this location.")
		return 0
	newVars = list("belongstomalf" = holder)
	return 1

/spell/aoe_turf/conjure/place_autoborger/cast(var/list/targets,mob/user)
	// All clear, place the autoborger
	..()
	playsound(targets[1], 'sound/effects/phasein.ogg', 100, 1)
	var/mob/living/silicon/ai/A = user
	A.can_shunt = 0
	to_chat(user, "You cannot shunt anymore.")

/datum/AI_Module/large/highrescams
	module_name = "High Resolution Cameras"
	mod_pick_name = "High Res Cameras"
	description = "Allows the AI to better interpret the actions of the crew! Read papers and their lips from his cameras!"
	cost = 10
	one_time = 1

/datum/AI_Module/large/highrescams/on_purchase(mob/living/silicon/ai/user)
	user.ai_flags |= HIGHRESCAMS
	user.eyeobj.high_res = 1
	to_chat(user, "Cameras upgraded.")

/datum/AI_Module/small/blackout
	module_name = "Blackout"
	mod_pick_name = "blackout"
	description = "Sends out a high-frequency electromagnetic pulse that disables some basic circuitry on the station. Renders any pre-existing radios and Rapid-Construction-Devices useless in addition to breaking lights."
	uses = 1
	cost = 15

	power_type = /spell/aoe_turf/blackout

/spell/aoe_turf/blackout
	name = "Blackout"
	user_type = USER_TYPE_MALFAI
	panel = MALFUNCTION
	charge_type = Sp_CHARGES
	charge_max = 1
	hud_state = "blackout"
	override_base = "malf"

/spell/aoe_turf/blackout/cast(var/list/targets, mob/user)
	if(!isAI(user))
		return

	var/mob/living/silicon/ai/A = user
	A.blackout_active = TRUE

	for(var/obj/machinery/power/apc/apc in power_machines)
		apc.overload_lighting()

	malf_radio_blackout = TRUE
	malf_rcd_disable = TRUE

	to_chat(user, "<span class='warning'>Electromagnetic pulse sent.</span>")


/datum/AI_Module/small/interhack
	module_name = "Fake Centcom Announcement"
	mod_pick_name = "interhack"
	description = "Gain control of the station's automated announcement system, allowing you to create up to 3 fake Centcom announcements - completely undistinguishable from real ones."
	cost = 15
	uses = 3
	power_type = /spell/aoe_turf/interhack

/spell/aoe_turf/interhack
	name = "Fake Announcement"
	user_type = USER_TYPE_MALFAI
	panel = MALFUNCTION
	charge_type = Sp_CHARGES
	charge_max = 3
	hud_state = "fakemessage"
	override_base = "malf"

/spell/aoe_turf/interhack/cast(var/list/targets,mob/user)

	//Create a list which looks like this
	//list( "Alert 1" = /datum/command_alert_1, "Alert 5" = /datum/command_alert_5, ...)
	//Then ask the AI to pick one announcement from the list

	if(alert("Would you like to create your own announcement or use a pre-existing one?","Confirm","Custom","Pre-Existing") == "Custom")

		var/input = input(user, "Please enter anything you want. Anything.", "What?", "") as message|null
		var/customname = input(user, "Pick a title for the report.", "Title") as text|null
		if(!input)
			to_chat(user, "Announcement Cancelled.")
			return 1
		if(!customname)
			customname = "Nanotrasen Update"
		for (var/obj/machinery/computer/communications/C in machines)
			if(! (C.stat & (BROKEN|NOPOWER) ) )
				var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
				P.name = "'[command_name()] Update.'"
				P.info = input
				P.update_icon()
				C.messagetitle.Add("[command_name()] Update")
				C.messagetext.Add(P.info)

		switch(alert("Should this be announced to the general population?",,"Yes","No"))
			if("Yes")
				command_alert(input, customname,1);
			if("No")
				to_chat(world, "<span class='warning'>New Nanotrasen Update available at all communication consoles.</span>")

		world << sound('sound/AI/commandreport.ogg', volume = 60)
		log_admin("Malfunctioning AI: [key_name(user)] has created a custom command report: [input]")
		message_admins("Malfunctioning AI: [key_name_admin(user)] has created a custom command report", 1)

	else
		var/list/possible_announcements = typesof(/datum/command_alert)
		var/list/choices = list()
		for(var/A in possible_announcements)
			var/datum/command_alert/CA = A
			choices[initial(CA.name)] = A

		var/chosen_announcement = input(user, "Select a fake announcement to send out.", "Interhack") as null|anything in choices
		if(!chosen_announcement)
			to_chat(user, "Selection cancelled.")
			return 1
		if(!charge_counter)
			to_chat(user, "No more charges.")
			return 1
		var/datum/command_alert/C = choices[chosen_announcement]
		var/datum/command_alert/announcement = new C
		command_alert(announcement)
		var/datum/faction/malf/M = find_active_faction_by_member(user.mind.GetRole(MALF))
		if(M)
			if(M.stage < FACTION_ENDGAME)
				if(announcement.theme && !announcement.stoptheme)
					ticker.StartThematic(initial(announcement.theme))
				if(announcement.alertlevel)
					set_security_level(announcement.alertlevel)
				if(announcement.stoptheme)
					ticker.StopThematic()
		log_game("Malfunctioning AI: [key_name(user)] faked a centcom announcement: [choices[chosen_announcement]]!")
		message_admins("Malfunctioning AI: [key_name(user)] faked a centcom announcement: [choices[chosen_announcement]]!")

/datum/AI_Module/small/reactivate_camera
	module_name = "Reactivate camera"
	mod_pick_name = "recam"
	description = "Reactivates a currently disabled camera. 10 uses."
	uses = 10
	cost = 15

	power_type = /spell/targeted/reactivate_camera

/spell/targeted/reactivate_camera
	name = "Reactivate Camera"
	panel = MALFUNCTION
	charge_type = Sp_CHARGES
	charge_max = 10
	range = GLOBALCAST
	spell_flags = WAIT_FOR_CLICK
	hud_state = "camera_reactivate"
	override_base = "malf"
	var/list/camera_images = list()

/spell/targeted/reactivate_camera/before_channel(mob/user)
	for(var/obj/machinery/camera/C in cameranet.cameras)
		if(C.status)
			continue
		var/image/I = image(C.icon, C.icon_state)
		I.appearance = C.appearance
		I.plane = STATIC_PLANE
		I.layer = REACTIVATE_CAMERA_LAYER
		I.alpha = 128
		I.loc = C
		camera_images += I
	user.client.images += camera_images

/spell/targeted/reactivate_camera/channel_spell(mob/user = usr, skipcharge = 0, force_remove = 0)
	if(!..())
		return 0
	if(!force_remove && !currently_channeled)
		if(user.client)
			user.client.images -= camera_images
			camera_images.len = 0
	return 1

/spell/targeted/reactivate_camera/is_valid_target(var/atom/target)
	if(!istype (target, /obj/machinery/camera))
		to_chat(holder, "That's not a camera.")
		return 0
	else
		var/obj/machinery/camera/C = target
		if(C.status)
			to_chat(holder, "This camera is either active, or not repairable.")
			return 0
	return 1

/spell/targeted/reactivate_camera/cast(var/list/targets,mob/user)
	var/obj/machinery/camera/C = targets[1]
	C.deactivate(user)
	if(user.client)
		user.client.images -= camera_images
	camera_images.len = 0

/datum/AI_Module/small/upgrade_camera
	module_name = "Upgrade Camera"
	mod_pick_name = "upgradecam"
	description = "Upgrades a camera to have X-Ray vision, Motion and be EMP-Proof. 10 uses."
	uses = 10
	cost = 15
	power_type = /spell/targeted/upgrade_camera

/spell/targeted/upgrade_camera
	name = "Upgrade Camera"
	user_type = USER_TYPE_MALFAI
	panel = MALFUNCTION
	charge_type = Sp_CHARGES
	charge_max = 10
	spell_flags = WAIT_FOR_CLICK
	range = GLOBALCAST
	hud_state = "camera_upgrade"
	override_base = "malf"

/spell/targeted/upgrade_camera/is_valid_target(var/atom/target)
	if(!istype(target, /obj/machinery/camera))
		to_chat(holder, "That is not a camera.")
		return 0
	var/obj/machinery/camera/C = target
	if(!C.assembly)
		return 0
	if(C.isXRay() && C.isEmpProof() && C.isMotion())
		to_chat(holder, "This camera is already upgraded!")
		return 0
	return 1

/spell/targeted/upgrade_camera/cast(var/list/targets,mob/user)
	var/obj/machinery/camera/C = targets[1]
	if(!C.isXRay())
		C.upgradeXRay()
		//Update what it can see.
		cameranet.updateVisibility(C, 0)

	if(!C.isEmpProof())
		C.upgradeEmpProof()

	if(!C.isMotion())
		C.upgradeMotion()
		// Add it to machines that process
		machines |= C

	C.visible_message("<span class='notice'>[bicon(C)] *beep*</span>")
	to_chat(user, "Camera successully upgraded!")

/spell/aoe_turf/module_picker
	name = "Select Module"
	user_type = USER_TYPE_MALFAI
	panel = MALFUNCTION
	var/datum/module_picker/MP
	charge_max = 10
	hud_state = "choose_module"
	override_base = "malf"

/spell/aoe_turf/module_picker/New()
	..()
	MP = new /datum/module_picker

/spell/aoe_turf/module_picker/Destroy()
	qdel(MP)
	MP = null
	..()

/spell/aoe_turf/module_picker/cast(var/list/targets, mob/user)
	MP.use(user)

/datum/module_picker
	var/temp = null
	var/processing_time = 100
	var/list/possible_modules = list()

/datum/module_picker/New()
	for(var/type in typesof(/datum/AI_Module))
		var/datum/AI_Module/AM = new type
		if(AM.power_type || AM.one_time)
			src.possible_modules += AM

/datum/module_picker/proc/use(mob/user)
	var/dat
	dat += {"<B>Select use of processing time: (currently #[src.processing_time] left.)</B><BR>
			<HR>
			<B>Install Module:</B><BR>
			<I>The number afterwards is the amount of processing time it consumes.</I><BR>"}
	for(var/datum/AI_Module/module in src.possible_modules)
		dat += "<A href='byond://?src=\ref[src];buy=1;module=\ref[module]'>[module.module_name]</A> <A href='byond://?src=\ref[src];desc=1;module=\ref[module]'>?</A>([module.cost])<BR>"
	dat += "<HR>"
	if (src.temp)
		dat += "[src.temp]"
	var/datum/browser/popup = new(user, "modpicker", "Malf Module Menu")
	popup.set_content(dat)
	popup.open()

/datum/module_picker/Topic(href, href_list)
	..()

	if(!isAI(usr))
		return
	var/mob/living/silicon/ai/A = usr

	if(href_list["buy"])
		var/datum/AI_Module/AM = locate(href_list["module"])
		if(AM.cost > src.processing_time)
			temp = "You cannot afford this module."
			return

			// Give the power and take away the money.
		AM.on_purchase(A)
		temp = AM.description
		src.processing_time -= AM.cost
		if(AM.one_time)
			possible_modules -= AM

	if(href_list["desc"])
		var/datum/AI_Module/AM = locate(href_list["module"])
		temp = AM.description

	src.use(usr)


/spell/aoe_turf/takeover
	name = "System Override"
	panel = MALFUNCTION
	desc = "Start the victory timer."
	charge_type = Sp_CHARGES
	charge_max = 1
	hud_state = "systemtakeover"
	override_base = "malf"

/spell/aoe_turf/takeover/before_target(mob/user)
	var/datum/faction/malf/M = find_active_faction_by_member(user.mind.GetRole(MALF))
	if(!M)
		to_chat(user, "<span class='warning'>How did you get to this point without actually being a malfunctioning AI?</span>")
		return 1
	if (M.stage > FACTION_ENDGAME)
		to_chat(usr, "<span class='warning'>You've already begun your takeover.</span>")
		return 1
	if (M.apcs < 3)
		to_chat(usr, "<span class='notice'>You don't have enough hacked APCs to take over the station yet. You need to hack at least 3, however hacking more will make the takeover faster. You have hacked [M.apcs] APCs so far.</span>")
		return 1

	if (alert(usr, "Are you sure you wish to initiate the takeover? The station hostile runtime detection software is bound to alert everyone. You have hacked [M.apcs] APCs.", "Takeover:", "Yes", "No") != "Yes")
		return 1

/spell/aoe_turf/takeover/cast(var/list/targets, mob/user)
	var/datum/faction/malf/M = find_active_faction_by_member(user.mind.GetRole(MALF))
	if(!M)
		to_chat(user, "<span class='warning'>How did you get to this point without actually being a malfunctioning AI?</span>")
		return 0
	M.stage(FACTION_ENDGAME)
	for(var/datum/role/R in M.members)
		var/datum/mind/AI_mind = R.antag
		for(var/spell/S in AI_mind.current.spell_list)
			if(istype(S,type))
				AI_mind.current.remove_spell(S)

/spell/targeted/ai_win
	name = "Explode"
	desc = "Station goes boom."
	panel = MALFUNCTION
	spell_flags = INCLUDEUSER

	charge_type = Sp_CHARGES
	charge_max = 1
	max_targets = 1

	hud_state = "radiation"
	override_base = "malf"

/spell/targeted/ai_win/before_target(mob/user)
	var/datum/faction/malf/M = find_active_faction_by_member(user.mind.GetRole(MALF))
	if(!M)
		to_chat(user, "<span class='warning'>How did you get to this point without actually being a malfunctioning AI?</span>")
		return 1
	if(M.stage<MALF_CHOOSING_NUKE)
		to_chat(usr, "<span class='warning'>You are unable to access the self-destruct system as you don't control the station yet.</span>")
		return 1

	if(ticker.explosion_in_progress || ticker.station_was_nuked)
		to_chat(usr, "<span class='notice'>The self-destruct countdown was already triggered!</span>")
		return 1

	if(!M.stage>=FACTION_VICTORY) //Takeover IS completed, but 60s timer passed.
		to_chat(usr, "<span class='warning'>Cannot interface, it seems a neutralization signal was sent!</span>")
		return 1


/spell/targeted/ai_win/cast(var/list/targets, mob/user)
	to_chat(user, "<span class='danger'>Detonation signal sent!</span>")
	var/datum/faction/malf/M = find_active_faction_by_member(user.mind.GetRole(MALF))
	if(!M)
		to_chat(user, "<span class='warning'>How did you get to this point without actually being a malfunctioning AI?</span>")
		return 0
	for(var/datum/role/AI in M.members)
		for(var/spell/S in AI.antag.current.spell_list)
			if(istype(S, /spell/targeted/ai_win))
				AI.antag.current.remove_spell(S)
	ticker.explosion_in_progress = 1
	for(var/mob/MM in player_list)
		if(MM.client)
			MM << 'sound/machines/Alarm.ogg'
	to_chat(world, "<span class='danger'>Self-destruction signal received. Self-destructing in 10...</span>")
	for (var/i=9 to 1 step -1)
		sleep(10)
		to_chat(world, "<span class='danger'>[i]...</span>")
	sleep(10)
	enter_allowed = 0
	if(ticker)
		ticker.station_explosion_cinematic(0,null)
		ticker.station_was_nuked = 1
		ticker.explosion_in_progress = 0
		SSpersistence_map.setSavingFilth(FALSE)
	M.stage(FACTION_VICTORY)

