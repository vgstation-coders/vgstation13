/datum/malfhack_ability
	var/name = "HACK"						//ability name (must be unique)
	var/desc = "This does something."	//ability description
	var/icon = "radial_off"				//icon to display in the radial

	var/cost = 0

	var/obj/machinery/machine

/datum/malfhack_ability/New(var/obj/machinery/M)
	machine = M

/datum/malfhack_ability/proc/activate(var/mob/living/silicon/A)
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M))
		return FALSE
	if(M.processing_power >= cost)
		M.add_power(-cost)
		return TRUE
	return FALSE

/datum/malfhack_ability/proc/check_cost(var/mob/living/silicon/A)
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M))
		return FALSE
	if(M.processing_power >= cost)
		return TRUE
	return FALSE

/datum/malfhack_ability/proc/before_radial(var/mob/living/silicon/A)
	return

/datum/malfhack_ability/proc/check_available(var/mob/living/silicon/A)
	//include some check for an ability
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M))
		return FALSE
	return TRUE

/datum/malfhack_ability/oneuse/activate(var/mob/living/silicon/A)
	if(!..())
		return FALSE
	machine.hack_abilities -= src
	return TRUE


/datum/malfhack_ability/toggle
	var/toggled = FALSE
	var/icon_toggled = "radial_on"
	var/freedisable = FALSE

	var/original_cost

/datum/malfhack_ability/toggle/New()
	..()
	original_cost = cost

/datum/malfhack_ability/toggle/activate(var/mob/living/silicon/A)
	if(!..())
		return FALSE
	toggled = !toggled
	return TRUE

/datum/malfhack_ability/toggle/check_cost(var/mob/living/silicon/A)
	if(toggled && freedisable)
		cost = 0
	else
		cost = original_cost
	return ..()

/datum/malfhack_ability/core/activate(var/mob/living/silicon/A)
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!M)
		return FALSE
	if(M.processing_power < cost)
		return FALSE
	M.add_power(-cost)
	M.core_upgrades -= src
	return TRUE


//---------------------------------------

/datum/malfhack_ability/toggle/disable
	name = "Toggle On/Off"
	desc = "Disable/Enable this machine."
	icon = "radial_off"
	icon_toggled = "radial_on"

/datum/malfhack_ability/toggle/disable/activate(var/mob/living/silicon/A)
	if(!..())
		return
	toggled ? (machine.stat |= FORCEDISABLE) : (machine.stat &= ~FORCEDISABLE)
	machine.power_change()  //update any lighting effects
	machine.update_icon()

//---------------------------------------


/datum/malfhack_ability/toggle/apclock
	name = "Toggle Exclusive Control"
	desc = "Enable/Disable Exclusive Control"
	icon = "radial_lock"
	icon_toggled = "radial_unlock_alt"

/datum/malfhack_ability/toggle/apclock/activate(var/mob/living/silicon/A)
	if(!..())
		return
	var/obj/machinery/power/apc/P = machine
	if(!istype(P))
		return
	toggled ? (P.malflocked = TRUE) : (P.malflocked = FALSE)

//---------------------------------------

/datum/malfhack_ability/shunt
	name = "Shunt Core Processes"
	desc = "Upload your software to this APC and leave your core. You can return to your core as long as it is still intact."
	icon = "radial_shunt"

/datum/malfhack_ability/shunt/activate(var/mob/living/silicon/ai/A)
	if(!..())
		return
	var/obj/machinery/power/apc/P = machine
	if(!istype(P))
		return
	var/obj/machinery/hologram/holopad/H  = A.current
	if(istype(H))
		H.clear_holo()

	var/mob/living/silicon/ai/S = new(get_turf(A),A.laws, null, 1)
	S.parent = A
	S.adjustOxyLoss(A.getOxyLoss())
	S.name = "[A.name] APC Copy"
	S.add_spell(new /spell/aoe_turf/corereturn, "malf_spell_ready",/obj/abstract/screen/movable/spell_master/malf)

	var/datum/faction/malf/malf_faction = find_active_faction_by_member(A.mind.GetRole(MALF), A.mind)
	if(malf_faction && malf_faction.stage >= FACTION_ENDGAME) /* If the shunting, malfunctioning AI is currently taking over the station... */
		for(var/obj/item/weapon/pinpointer/point in pinpointer_list)
			point.target = machine /* ...then override all pinpointer targets to point at the APC in which the AI is shunted. */
	S.update_perception()
	A.mind.transfer_to(S)
	S.cancel_camera()

	new /obj/effect/malf_jaunt(S.loc, S, P)

/datum/malfhack_ability/shunt/check_available(var/mob/living/silicon/ai/A)
	if(!..())
		return FALSE
	if(istype(A.loc, /obj/machinery/power/apc)) // Already in an APC
		return FALSE
	if(istype(A))
		return TRUE
	return FALSE


//---------------------------------------

/datum/malfhack_ability/oneuse/turret_pulse
	name = "Upgrade Turret Laser"
	desc = "Upgrade this turret's laser to a pulse laser."
	icon = "radial_pulse"
	cost = 10

/datum/malfhack_ability/oneuse/turret_pulse/activate(var/mob/living/silicon/A)
	if(!..())
		return
	var/obj/machinery/turret/T = machine
	if(!istype(T))
		return
	T.installed = new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(T)
	T.icon_state = "blue_target_prism"
	to_chat(A, "<span class='warning'>You set the turret to fire pulse lasers.</span>")

/datum/malfhack_ability/oneuse/turret_upgrade
	name = "Upgrade Turret Power"
	desc = "Upgrade this turret's firerate and health."
	icon = "radial_upgrade"
	cost = 10

/datum/malfhack_ability/oneuse/turret_upgrade/activate(var/mob/living/silicon/A)
	if(!..())
		return
	var/obj/machinery/turret/T = machine
	if(!istype(T))
		return
	T.health += 120	//200 Total HP
	T.shot_delay = 15
	T.fire_twice = TRUE
	to_chat(A, "<span class='warning'>You upgrade the turret.</span>")


//--------------------------------------------------------
/*
/datum/malfhack_ability/dump_dispenser_energy
	name = "Drain Energy"
	desc = "Drain the energy stored in this dispenser."
	icon = "radial_drain"
	cost = 5

/datum/malfhack_ability/dump_dispenser_energy/activate(var/mob/living/silicon/A)
	if(!..())
		return
	var/obj/machinery/chem_dispenser/C = machine
	if(!istype(C))
		return
	C.energy = 0

*/
//--------------------------------------------------------

/datum/malfhack_ability/create_lifelike_hologram
	name = "Create Lifelike Hologram"
	desc = "Project a realistic looking hologram from this holopad."
	icon = "radial_holo"
	cost = 0

/datum/malfhack_ability/create_lifelike_hologram/activate(var/mob/living/silicon/A)
	var/obj/machinery/hologram/holopad/C = machine
	if(!istype(C))
		return
	if(C.create_advanced_holo(A))
		..()


//--------------------------------------------------------

/datum/malfhack_ability/oneuse/overload_loud
	name = "Detonate Machine"
	desc = "Massively overload the circuits in this machine, causing a large explosion. The machine will visually shake and spark before exploding."
	icon = "radial_overload"
	cost = 20

/datum/malfhack_ability/oneuse/overload_loud/activate(var/mob/living/silicon/A)
	if(!..())
		return
	machine.visible_message("<span class='warning'>[machine] makes a [pick("loud", "violent", "unsettling")], [pick("electrical","mechanical")] [pick("buzzing","rumbling","shaking")] sound!</span>") //highlight this, motherfucker
	if(istype(machine, /obj/machinery/turret))
		var/obj/machinery/turret/T = machine
		if(T.cover)
			T.cover.shake_animation(4, 4, 0.2 SECONDS, 20)
	else
		machine.shake_animation(4, 4, 0.2 SECONDS, 20)
	spark(machine)
	spawn(4 SECONDS)
		if(machine)
			explosion(get_turf(machine), -1, 2, 3, 4) // Welding tank sized explosion
			qdel(machine)

/datum/malfhack_ability/oneuse/overload_quiet
	name = "Overload Machine"
	desc = "Overload the circuits in this machine, causing an explosion after a few seconds."
	icon = "radial_alertboom"
	cost = 15

/datum/malfhack_ability/oneuse/overload_quiet/activate(var/mob/living/silicon/A)
	if(!..())
		return
	machine.visible_message("<span class='warning'>[machine] makes a [pick("loud", "violent", "unsettling")], [pick("electrical","mechanical")] [pick("buzzing","rumbling","shaking")] sound!</span>")
	playsound(machine, 'sound/effects/electricity_short_disruption.ogg', 80)
	spawn(4 SECONDS)
		if(machine)
			explosion(get_turf(machine), -1, 1, 2, 3) // smaller explosion
			qdel(machine)

//--------------------------------------------------------

/datum/malfhack_ability/toggle/radio_blackout
	name = "Communications Blackout"
	desc = "Force all radio traffic through this receiver and scramble it, making it much harder to communicate."
	icon = "radial_jam"
	icon_toggled = "radial_unjam"
	cost = 10
	freedisable = TRUE

/datum/malfhack_ability/toggle/radio_blackout/activate(var/mob/living/silicon/ai/A)
	if(!..())
		return
	var/obj/machinery/telecomms/receiver/R = machine
	if(!istype(R))
		return
	malf_radio_blackout = !malf_radio_blackout
	A.blackout_active = malf_radio_blackout
	toggled = malf_radio_blackout
	R.blackout_active = malf_radio_blackout

// Since there are multiple machines all toggling a global variable, set toggled to whatever the global variable is set at.
/datum/malfhack_ability/toggle/radio_blackout/before_radial()
	toggled = malf_radio_blackout


// Can already be done through a telecomms script but this should make it easier
/datum/malfhack_ability/fake_message
	name = "Synthesize Message"
	desc = "Synthesize a fake message to be broadcasted over the radio."
	cost = 0
	icon = "radial_talk"

/datum/malfhack_ability/fake_message/activate(mob/living/silicon/A)
	if(!machine.hack_overlay) // shouldn't happen
		return
	var/fakename = copytext(sanitize(input(A, "Please enter a name for the message.", "Name?", "") as text|null, 1), MAX_NAME_LEN)
	if(!fakename)
		to_chat(A, "<span class='warning'>Message cancelled.</span>")
		return
	var/fakeid = copytext(sanitize(input(A, "Please enter an ID for the message.", "Occupation?", "Assistant") as text|null), 1, MAX_NAME_LEN)
	if(!fakeid)
		to_chat(A, "<span class='warning'>Message cancelled.</span>")
		return
	var/freq = input(usr, "Set a new frequency (MHz, 90.0, 200.0).", "Frequency?", COMMON_FREQ ) as null|num
	if(freq)
		if(findtext(num2text(freq), "."))
			freq *= 10 // shift the decimal one place
		if(!(freq > 900 && freq < 2000)) // Between (90.0 and 100.0)
			to_chat(A, "<span class='warning'>Invalid frequency.</span>")
			return
	else
		to_chat(A, "<span class='warning'>Message cancelled.</span>")
		return
	var/message = copytext(sanitize(input(usr, "Please enter a message.", "Message?", "") as text|null,1), MAX_BROADCAST_LEN)
	if(!message)
		to_chat(A, "<span class='warning'>Message cancelled.</span>")
		return

	var/turf/T = get_turf(machine)
	var/datum/speech/speech = new /datum/speech
	speech.message = message
	speech.frequency = freq
	speech.job = fakeid
	speech.name = fakename
	speech.speaker = machine.hack_overlay	// This is dumb, but a speaker object is needed. Passing the machine itself would cause it to "beep" instead of "say".
	Broadcast_Message(speech, 0, 0, 0 , list(T.z))

//--------------------------------------------------------

/datum/malfhack_ability/fake_announcement
	name = "Falsify Nanotrasen Announcement"
	desc = "Forge an official Nanotrasen announcement. You can write your own or use a pre-existing announcement. Beware that some pre-existing announcements may trigger other alerts."
	cost = 5
	icon = "radial_send"

/datum/malfhack_ability/fake_announcement/activate(var/mob/living/silicon/A)
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M))
		return FALSE
	if(M.processing_power < cost)
		return

	if(alert(A, "Would you like to create your own announcement or use a pre-existing one?","Confirm","Custom","Pre-Existing") == "Custom")

		var/input = copytext(sanitize(input(A, "Please enter anything you want. Anything.", "What?", "") as message|null),1,MAX_BROADCAST_LEN)
		var/customname = copytext(sanitize(input(A, "Pick a title for the report.", "Title") as text|null),1,MAX_NAME_LEN)
		if(!input)
			to_chat(A, "<span class='warning'>Announcement cancelled.</span>")
			return
		if(M.processing_power < cost)
			return
		else
			M.add_power(-cost)
		if(!customname)
			customname = "Nanotrasen Update"
		for (var/obj/machinery/computer/communications/C in machines)
			if(! (C.stat & (BROKEN|NOPOWER|FORCEDISABLE) ) )
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
		log_admin("Malfunctioning AI: [key_name(A)] has created a custom command report: [input]")
		message_admins("Malfunctioning AI: [key_name_admin(A)] has created a custom command report", 1)

	else
		var/list/possible_announcements = typesof(/datum/command_alert)
		var/list/choices = list()
		for(var/AN in possible_announcements)
			var/datum/command_alert/CA = AN
			choices[initial(CA.name)] = AN

		var/chosen_announcement = input(A, "Select a fake announcement to send out.", "Interhack") as null|anything in choices
		if(!chosen_announcement)
			to_chat(A, "<span class='warning'>Selection cancelled.</span>")
			return
		if(M.processing_power < cost)
			return
		else
			M.add_power(-cost)
		var/datum/command_alert/C = choices[chosen_announcement]
		var/datum/command_alert/announcement = new C
		command_alert(announcement)
		var/datum/faction/malf/MF = find_active_faction_by_member(M)
		if(MF)
			if(MF.stage < FACTION_ENDGAME)
				if(announcement.theme && !announcement.stoptheme)
					ticker.StartThematic(initial(announcement.theme))
				if(announcement.alertlevel)
					set_security_level(announcement.alertlevel)
				if(announcement.stoptheme)
					ticker.StopThematic()
		log_game("Malfunctioning AI: [key_name(A)] faked a centcom announcement: [choices[chosen_announcement]]!")
		message_admins("Malfunctioning AI: [key_name(A)] faked a centcom announcement: [choices[chosen_announcement]]!")

//--------------------------------------------------------

/datum/malfhack_ability/oneuse/apcfaker
	name = "Fake APC Images"
	desc = "Reprogram the image processing software within this camera console. Anyone viewing a hacked APC from it will see a normal APC instead."
	cost = 5
	icon = "radial_apcfake"

/datum/malfhack_ability/oneuse/apcfaker/activate(var/mob/living/silicon/A)
	if(!..())
		return
	var/obj/machinery/computer/security/S = machine
	if(!istype(S))
		return
	var/obj/abstract/screen/plane_master/fakecamera_planemaster/F = locate(/obj/abstract/screen/plane_master/fakecamera_planemaster) in S.cam_plane_masters
	if(F)
		F.alpha = 255  // make the fake image visible
		to_chat(A, "<span class='warning'>You reprogram the image processing software on \the [machine]</span>")

//--------------------------------------------------------

/datum/malfhack_ability/oneuse/explosive_borgs
	name = "Rig Cyborgs"
	desc = "Disable the hardware safeties on cyborgs slaved to you, causing them to explode violently on shutdown."
	cost = 15
	icon = "radial_boomborgs"

/datum/malfhack_ability/oneuse/explosive_borgs/activate(var/mob/living/silicon/ai/A)
	if(!..())
		return
	A.explosive_cyborgs = TRUE
	to_chat(A, "<span class='warning'>You rig your cyborgs to explode violently on death.</span>")

//--------------------------------------------------------

/*
/datum/malfhack_ability/core/firewall
	name = "Firewall"
	desc = "Deploy a firewall to reduce damage to your core and make it immune to lasers."
	icon = "radial_firewall"
	cost = 10

/datum/malfhack_ability/core/firewall/activate(var/mob/living/silicon/ai/A)
	if(!..())
		return
	A.ai_flags |= COREFORTIFY
	to_chat(A, "<span class='warning'>Firewall activated.</span>")
*/

//--------------------------------------------------------


/datum/malfhack_ability/core/takeover
	name = "System Override"
	desc = "Initiate your takeover."
	icon = "radial_takeover"

/datum/malfhack_ability/core/takeover/activate(var/mob/living/silicon/ai/A)
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	var/datum/faction/malf/MF = find_active_faction_by_member(M)

	if(!M || !MF)
		to_chat(A, "<span class='warning'>How did you get to this point without actually being a malfunctioning AI?</span>")
		return
	if (MF.stage > FACTION_ENDGAME)
		to_chat(A, "<span class='warning'>You've already begun your takeover.</span>")
		return
	if (M.apcs.len < 3)
		to_chat(A, "<span class='notice'>You don't have enough hacked APCs to take over the station yet. You need to hack at least 3, however hacking more will make the takeover faster. You have hacked [M.apcs.len] APCs so far.</span>")
		return
	if (alert(A, "Are you sure you wish to initiate the takeover? The station hostile runtime detection software is bound to alert everyone. You have hacked [M.apcs.len] APCs, and it will take [round(MF.AI_win_timeleft / (M.apcs.len / 6), 1)] seconds to complete.", "Takeover:", "Yes", "No") != "Yes")
		return

	MF.stage(FACTION_ENDGAME)
	switch(A.chosen_core_icon_state)
		if("ai-malf-shodan")
			command_alert(/datum/command_alert/malf_announce/shodan)
		if("ai-xerxes")
			command_alert(/datum/command_alert/malf_announce/xerxes)
		else
			command_alert(/datum/command_alert/malf_announce)
	M.core_upgrades -= src

//--------------------------------------------------------

/datum/malfhack_ability/core/highres
	name = "High Resolution Cameras"
	desc = "Upgrade your camera resolution and download the latest lip reading software."
	cost = 10
	icon = "radial_eye"

/datum/malfhack_ability/core/highres/activate(mob/living/silicon/ai/A)
	if(!..())
		return
	A.ai_flags |= HIGHRESCAMS
	A.eyeobj.high_res = 1
	to_chat(A, "<span class='warning'>High Resolution camera software installed.</span>")
	A.update_perception()

//--------------------------------------------------------

/datum/malfhack_ability/core/explode
	name = "Explosive Core"
	desc = "Rigs your core to explode upon your untimely deactivation."
	icon = "radial_alertboom"
	cost = 20

/datum/malfhack_ability/core/explode/activate(mob/living/silicon/ai/A)
	if(!..())
		return
	A.explosive = TRUE
	to_chat(A, "<span class='warning'>Your core will now detonate if it gets destroyed.</span>")

//--------------------------------------------------------

/datum/malfhack_ability/oneuse/emag
	name = "Scramble"
	desc = "Scramble the software on this machine, making it behave as if emagged."
	icon = "radial_emag"
	cost = 5

/datum/malfhack_ability/oneuse/emag/activate(mob/living/silicon/ai/A)
	if(!..())
		return
	machine.emag_ai(A)

// Emag behavior varies from machine to machine
// Simply calling emag_act
// isn't enough for a lot of things, so this can be overridden
/obj/machinery/proc/emag_ai(mob/living/silicon/ai/A)
	emag_act(A)


//--------------------------------------------------------

/datum/malfhack_ability/camera_reactivate
	name = "Reactivate Camera"
	desc = "Turn this camera on again."
	icon = "radial_on"
	cost = 5

/datum/malfhack_ability/camera_reactivate/activate(mob/living/silicon/A)
	if(!..())
		return
	var/obj/machinery/camera/C = machine
	C.deactivate(A) // why this proc is called deactivate is beyond me

/datum/malfhack_ability/camera_reactivate/check_available(var/mob/living/silicon/A)
	var/obj/machinery/camera/C = machine
	if(!istype(C))
		return FALSE
	if(C.status)
		return FALSE
	return TRUE

/datum/malfhack_ability/oneuse/camera_upgrade
	name = "Upgrade Camera"
	desc = "Update this camera to the latest software. This makes it immune to EMPs, installs a motion detector, and gives it X-Ray vision."
	icon = "radial_cams"
	cost = 5

/datum/malfhack_ability/oneuse/camera_upgrade/activate(mob/living/silicon/A)
	if(!..())
		return
	var/obj/machinery/camera/C = machine
	if(!C.isXRay())
		C.upgradeXRay()
		cameranet.updateVisibility(C, 0)

	if(!C.isEmpProof())
		C.upgradeEmpProof()

	if(!C.isMotion())
		C.upgradeMotion()
		machines |= C

	C.visible_message("<span class='notice'>[bicon(C)] *beep*</span>")
	to_chat(A, "Camera successully upgraded!")

//--------------------------------------------------------

/datum/malfhack_ability/oneuse/make_autoborger
	name = "Enable Autoborging"
	desc = "Reprogram this charging station to convert living humans into cyborgs. Only one charger can be converted into an autoborger."
	cost = 100
	icon = "radial_autoborg"

/datum/malfhack_ability/oneuse/make_autoborger/activate(mob/living/silicon/A)
	if(!..())
		return
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	var/obj/machinery/recharge_station/R = machine
	if(!istype(R))
		return
	R.autoborger = TRUE
	R.aiowner = A
	M.has_autoborger = TRUE

/datum/malfhack_ability/oneuse/make_autoborger/check_available(mob/living/silicon/A)
	if(!..())
		return FALSE
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(M.has_autoborger)
		return FALSE
	return TRUE


//--------------------------------------------------------

/datum/malfhack_ability/manual_control
	name = "Manual Control"
	desc = "Take manual control of this turret."
	cost = 0
	icon = "radial_fire"

/datum/malfhack_ability/manual_control/activate(mob/living/silicon/ai/A)
	if(!..())
		return
	var/obj/machinery/turret/T = machine
	if(!istype(T))
		return
	T.malf_take_control(A)



//--------------------------------------------------------

/datum/malfhack_ability/destroy_lights
	name = "Overload Network"
	desc = "Overload the power network, destroying all connected lights."
	cost = 10
	icon = "radial_break"

/datum/malfhack_ability/destroy_lights/activate(mob/living/silicon/A)
	if(!..())
		return
	var/obj/machinery/power/battery/smes/S = machine
	if(!istype(S))
		return

	// Overload all APCs on both sides of the SMES (two powernets)
	var/obj/machinery/power/terminal/T = S.get_terminal()
	var/datum/powernet/P1 = S.get_powernet()
	var/datum/powernet/P2 = T.get_powernet()
	if(P1)
		for(var/obj/machinery/power/terminal/TE in P1.nodes)
			if(istype(TE.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/APC = TE.master
				APC.overload_lighting()
	if(P2)
		for(var/obj/machinery/power/terminal/TE in P2.nodes)
			if(istype(TE.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/APC = TE.master
				APC.overload_lighting()


//--------------------------------------------------------

/datum/malfhack_ability/toggle/mute_sps
	name = "Mute Alerts"
	desc = "Hide any alerts sent to this computer."
	cost = 0
	icon = "radial_mute"
	icon_toggled = "radial_unjam"

/datum/malfhack_ability/toggle/mute_sps/activate(mob/living/silicon/A)
	if(!..())
		return
	var/obj/machinery/computer/security_alerts/S = machine
	if(!istype(S))
		return
	toggled ? (S.muted = TRUE) : (S.muted = FALSE)

/datum/malfhack_ability/trigger_sps
	name = "Trigger SPS Alert"
	desc = "Trigger an alert from an active SPS unit."
	cost = 5
	icon = "radial_alert"

/datum/malfhack_ability/trigger_sps/activate(mob/living/silicon/A)
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M))
		return FALSE
	if(M.processing_power < cost)
		return

	var/list/choices = list()
	for(var/obj/item/device/gps/secure/S in all_GPS_list)
		if(S.transmitting)
			choices[S.gpstag] = S

	var/chosen_sps = input(A, "Select a secure positioning system to trigger.", "SPS Alert") as null|anything in choices
	if(!chosen_sps)
		to_chat(A, "<span class='warning'>Selection cancelled.</span>")
		return

	var/list/codes = list("Red", "Yellow")
	var/chosen_code = input(A, "Select an alert code.", "SPS Alert") as null|anything in codes
	if(!chosen_code)
		to_chat(A, "<span class='warning'>Selection cancelled.</span>")
		return

	if(M.processing_power < cost)
		return
	else
		M.add_power(-cost)

	var/obj/item/device/gps/secure/S  = choices[chosen_sps]
	var/code = chosen_code
	S.send_signal(SPS = S, code = "SPS [S.gpstag]: Code [code]", stfu = TRUE)



//--------------------------------------------------------


/datum/malfhack_ability/oneuse/nuke_bolt
	name = "Enable Bolts"
	desc = "Bolt the device to the ground."
	cost = 0
	icon = "radial_bolt"

/datum/malfhack_ability/oneuse/nuke_bolt/activate(mob/living/silicon/A)
	if(!..())
		return
	var/obj/machinery/nuclearbomb/N = machine
	if(!istype(N))
		return
	if(N.extended) // was already bolted
		return
	if(N.removal_stage < 5)
		N.anchored = 1
		N.visible_message("<span class='notice'>With a steely snap, bolts slide out of [N] and anchor it to the flooring!</span>")
	else
		N.visible_message("<span class='notice'>\The [N] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
	flick("nuclearbombc", N)
	N.icon_state = "nuclearbomb1"
	N.extended = 1


/*

/datum/malfhack_ability/oneuse/nuke_detonate
	name = "Detonate"
	desc = "Destroy the station."
	cost = 0
	icon = "radial_nuke"

/datum/malfhack_ability/oneuse/nuke_detonate/activate(mob/living/silicon/A)
	if(!..())
		return
	var/obj/machinery/nuclearbomb/N = machine
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	var/datum/faction/malf/MF = find_active_faction_by_member(M)
	if(!istype(N))
		to_chat(A, "<span class='warning'>That's not a nuclear bomb!</span>")
		return
	if(!M || !MF)
		to_chat(A, "<span class='warning'>How did you get to this point without actually being a malfunctioning AI?</span>")
		return
	if(MF.stage < MALF_CHOOSING_NUKE)
		to_chat(A, "<span class='warning'>You are unable to access the self-destruct system as you don't control the station yet.</span>")
		return
	if(ticker.explosion_in_progress || ticker.station_was_nuked)
		to_chat(A, "<span class='notice'>The self-destruct countdown was already triggered!</span>")
		return
	if(MF.stage >= FACTION_VICTORY) //Takeover IS completed, but 60s timer passed.
		to_chat(A, "<span class='warning'>Cannot interface, it seems a neutralization signal was sent!</span>")
		return


	to_chat(A, "<span class='danger'>Detonation signal sent!</span>")
	ticker.explosion_in_progress = 1

	for(var/mob/MM in player_list)
		if(MM.client)
			MM << 'sound/machines/Alarm.ogg'

	to_chat(world, "<span class='danger'>Self-destruction signal received. Self-destructing in 10...</span>")

	spawn()
		N.safety = 0
		N.explode()
		MF.stage(FACTION_VICTORY)

	for (var/i=9 to 1 step -1)
		sleep(10)
		to_chat(world, "<span class='danger'>[i]...</span>")
	sleep(50)

/datum/malfhack_ability/oneuse/nuke_detonate/check_available(mob/living/silicon/A)
	var/obj/machinery/nuclearbomb/N = machine
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	var/datum/faction/malf/MF = find_active_faction_by_member(M)
	if(!M || !MF || !istype(N))
		return FALSE
	if(!M.takeover)
		return FALSE
	return TRUE

*/


//--------------------------------------------------------

/datum/malfhack_ability/kill_plant
	name = "Kill Plant"
	desc = "Shut off toxin control in this hydroponics tray, killing the plant."
	cost = 0
	icon = "radial_kill"

/datum/malfhack_ability/kill_plant/activate(mob/living/silicon/A)
	if(!..())
		return
	var/obj/machinery/portable_atmospherics/hydroponics/H = machine
	if(!istype(H))
		return
	H.die()

//--------------------------------------------------------

/datum/malfhack_ability/account_hijack
	name = "Account Override"
	desc = "Make purchases under another debit account."
	cost = 0
	icon = "radial_pay"

/datum/malfhack_ability/account_hijack/activate(mob/living/silicon/ai/A)
	if(!..())
		return
	var/obj/machinery/computer/supplycomp/S = machine
	var/obj/machinery/computer/ordercomp/O = machine
	if(!istype(S) && !istype(O))
		return
	var/list/acc_info = list()


	var/list/ids = list()
	for(var/obj/item/weapon/card/id/I in id_cards)
		if(!get_card_account(I))
			continue
		ids[I.registered_name] = I

	if(ids.len == 0)
		to_chat(A, "<span class='warning'>No IDs found.</span>")
		return

	var/choice = input(A, "Select an ID to use.", "ID?") as null|anything in ids
	if(!choice)
		to_chat(A, "<span class='warning'>Selection cancelled.</span>")
		return
	var/obj/item/weapon/card/id/ID = ids[choice]
	var/datum/money_account/acct = get_card_account(ID)
	if(!acct)
		to_chat(A, "<span class='warning'>No account found for that ID.</span>")
		return


	acc_info["authorized_name"] = ""
	acc_info["check"] = FALSE
	acc_info["idname"] = ID.registered_name
	acc_info["idrank"] = ID.assignment
	acc_info["account"] = acct

	if(S)
		S.current_acct_override = acc_info
		S.attack_ai(A)
	else if(O)
		O.current_acct_override = acc_info
		O.attack_ai(A)
