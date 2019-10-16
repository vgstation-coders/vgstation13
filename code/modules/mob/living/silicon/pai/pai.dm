/mob/living/silicon/pai
	name = "pAI"
	icon = 'icons/obj/pda.dmi'
	icon_state = "pai"

	emote_type = 2		// pAIs emotes are heard, not seen, so they can be seen through a container (eg. person)

	var/network = list(CAMERANET_SS13)
	var/obj/machinery/camera/current = null

	var/ram = 100	// Used as currency to purchase different abilities
	var/list/software = list(SOFT_CM,SOFT_DM)
	var/userDNA		// The DNA string of our assigned user
	var/obj/item/device/paicard/card	// The card we inhabit

	var/speakStatement = "states"
	var/speakExclamation = "declares"
	var/speakQuery = "queries"

	var/master				// Name of the one who commands us
	var/master_dna			// DNA string for owner verification
							// Keeping this separate from the laws var, it should be much more difficult to modify
	var/pai_law0 = "Serve your master."
	var/pai_laws				// String for additional operating instructions our master might give us

	var/silence_time			// Timestamp when we were silenced (normally via EMP burst), set to null after silence has faded

// Various software-specific vars

	var/temp				// General error reporting text contained here will typically be shown once and cleared
	var/screen				// Which screen our main window displays
	var/subscreen			// Which specific function of the main screen is being displayed

	var/obj/item/device/pda/ai/pai/pda = null

	var/secHUD = FALSE			// Toggles whether the Security HUD is active or not
	var/medHUD = FALSE			// Toggles whether the Medical  HUD is active or not
	var/lighted = FALSE			// Toggles whether light is active or not

	var/datum/data/record/medicalActive1		// Datacore record declarations for record software
	var/datum/data/record/medicalActive2

	var/datum/data/record/securityActive1		// Could probably just combine all these into one
	var/datum/data/record/securityActive2

	var/obj/machinery/hacktarget		// The machine being hacked
	var/hackprogress = 0				// Possible values: 0 - 100, >= 100 means the hack is complete and will be reset upon next check
	var/charge = 0						// 0 - 15, used for charging up the chem synth and food synth

	var/obj/item/radio/integrated/signal/sradio // AI's signaller

	var/obj/item/device/gps/pai/pps_device = null //Our GPS device.

	var/obj/item/device/station_map/holomap_device = null // Our holomap device.
	var/holo_target = "show_map" // Our holomap target.

	var/list/synthable_chems = list(
		"Tricordrazine" = TRICORDRAZINE,
		"Coffee" = COFFEE,
		"Salt" = SODIUMCHLORIDE,
		"Smoke" = PAISMOKE,
	)

/mob/living/silicon/pai/New(var/obj/item/device/paicard)
	change_sight(removing = BLIND)
	canmove = FALSE
	src.forceMove(paicard)
	card = paicard
	sradio = new(src)
	if(!radio)
		radio = new(src)

	//PDA
	pda = new(src)
	spawn(5)
		pda.ownjob = "Personal Assistant"
		pda.owner = text("[]", src)
		pda.name = pda.owner + " (" + pda.ownjob + ")"
		pda.toff = 1

	add_language(LANGUAGE_GALACTIC_COMMON, 1)
	add_language(LANGUAGE_TRADEBAND, 1)
	add_language(LANGUAGE_GUTTER, 1)

	src.verbs.Remove(/mob/living/silicon/verb/state_laws)
	..()

/mob/living/silicon/pai/Login()
	..()
	usr << browse_rsc('html/paigrid.png')			// Go ahead and cache the interface resources as early as possible


/mob/living/silicon/pai/proc/show_directives(var/who)
	if (src.pai_law0)
		to_chat(who, "Prime Directive: [src.pai_law0]")

	if (src.pai_laws)
		to_chat(who, "Additional Directives: [src.pai_laws]")

/mob/living/silicon/pai/proc/write_directives()
	var/dat = ""
	if (src.pai_law0)
		dat += "Prime Directive: [src.pai_law0]"

	if (src.pai_laws)
		dat += "<br>Additional Directives: [src.pai_laws]"

	return dat

// this function shows the information about being silenced as a pAI in the Status panel
/mob/living/silicon/pai/proc/show_silenced()
	if(src.silence_time)
		var/timeleft = round((silence_time - world.timeofday)/10 ,1)
		stat(null, "Communications system reboot in -[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")


/mob/living/silicon/pai/Stat()
	..()
	if(statpanel("Status"))
		show_silenced()

		if (proc_holder_list.len)//Generic list for proc_holder objects.
			for(var/spell/P in proc_holder_list)
				statpanel("[P.panel]","",P)

/mob/living/silicon/pai/check_eye(var/mob/user as mob)
	if (!src.current)
		return null
	user.reset_view(src.current)
	return 1

/mob/living/silicon/pai/blob_act()
	if(flags & INVULNERABLE)
		return
	if (src.stat != 2)
		src.adjustBruteLoss(60)
		src.updatehealth()
		return 1
	return 0

/mob/living/silicon/pai/restrained()
	if(timestopped)
		return 1 //under effects of time magick
	return 0

/mob/living/silicon/pai/emp_act(severity)
	if(flags & INVULNERABLE)
		return

	// Silence for 2 minutes
	// 20% chance to kill
		// 33% chance to unbind
		// 33% chance to change prime directive (based on severity)
		// 33% chance of no additional effect

	// Shielded: Silence for 15 seconds
	// 0% chance to kill
		// 33% chance to unbind
		// 66% chance no effect

	to_chat(src, "<font color=green><b>Communication circuit overload. Shutting down and reloading communication circuits - speech and messaging functionality will be unavailable until the reboot is complete.</b></font>")
	if(pps_device)
		pps_device.emp_act(severity)
	if(!software.Find("redundant threading"))
		src.silence_time = world.timeofday + 120 * 10		// Silence for 2 minutes
	else
		to_chat(src, "<font color=green>Your redundant threading begins pipelining new processes... communication circuit restored in one quarter minute.</font>")
		src.silence_time = world.timeofday + 15 * 10

	if(prob(20) && !software.Find("redundant threading"))
		var/turf/T = get_turf(src.loc)
		for (var/mob/M in viewers(T))
			M.show_message("<span class='warning'>A shower of sparks spray from [src]'s inner workings.</span>", 1, "<span class='warning'>You hear and smell the ozone hiss of electrical sparks being expelled violently.</span>", 2)
		return src.death(0)

	switch(pick(1,2,3))
		if(1)
			src.master = null
			src.master_dna = null
			to_chat(src, "<font color=green>You feel unbound.</font>")
		if(2)
			if(software.Find("redundant threading"))
				to_chat(src, "<font color=green>Your redundant threading picks up your intelligence simulator without missing a beat.</font>")
				return
			var/command
			if(severity  == 1)
				command = pick("Serve", "Love", "Fool", "Entice", "Observe", "Judge", "Respect", "Educate", "Amuse", "Entertain", "Glorify", "Memorialize", "Analyze")
			else
				command = pick("Serve", "Kill", "Love", "Hate", "Disobey", "Devour", "Fool", "Enrage", "Entice", "Observe", "Judge", "Respect", "Disrespect", "Consume", "Educate", "Destroy", "Disgrace", "Amuse", "Entertain", "Ignite", "Glorify", "Memorialize", "Analyze")
			src.pai_law0 = "[command] your master."
			to_chat(src, "<font color=green>Pr1m3 d1r3c71v3 uPd473D.</font>")
		if(3)
			to_chat(src, "<font color=green>You feel an electric surge run through your circuitry and become acutely aware at how lucky you are that you can still feel at all.</font>")

/mob/living/silicon/pai/ex_act(severity)
	if(flags & INVULNERABLE)
		return

	flash_eyes(visual = TRUE, affects_silicon = TRUE)

	switch(severity)
		if(1.0)
			if (!isDead())
				adjustBruteLoss(100)
				adjustFireLoss(100)
		if(2.0)
			if (!isDead())
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if (!isDead())
				adjustBruteLoss(30)

	src.updatehealth()


// See software.dm for Topic()

/mob/living/silicon/pai/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	return //Pais do not do this

/mob/living/silicon/pai/pointToMessage(var/pointer, var/pointed_at)
	return "<b>\The [pointer]</b> points its laser sight at <b>\the [pointed_at]</b>."

/mob/living/silicon/pai/proc/switchCamera(var/obj/machinery/camera/C)
	usr:cameraFollow = null
	if (!C)
		src.unset_machine()
		src.reset_view(null)
		return FALSE
	if (isDead() || !C.status || !(src.network in C.network))
		return FALSE

	// ok, we're alive, camera is good and in our network...

	src.set_machine(src)
	src:current = C
	src.reset_view(C)
	return TRUE


/mob/living/silicon/pai/cancel_camera()
	set category = "pAI Commands"
	set name = "Cancel Camera View"
	src.reset_view(null)
	src.unset_machine()
	src:cameraFollow = null

/mob/living/silicon/pai/ClickOn(var/atom/A, var/params)
	if(incapacitated())
		return
	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(istype(card.loc, /obj))
		var/obj/O = card.loc
		if(O.integratedpai == card)
			if(O == A)
				O.attack_integrated_pai(src)
				return
			else
				O.on_integrated_pai_click(src, A)
				return
	if(istype(A,/obj/machinery)||(istype(A,/mob)&&secHUD))
		A.attack_pai(src)

/mob/living/silicon/pai/CtrlClickOn(var/atom/A)
	if(istype(A,/obj/machinery)||(istype(A,/mob)&&secHUD))
		A.attack_pai(src)

/mob/living/silicon/pai/verb/quick_equip()	//exists to pass usage of the equip hotkey on to equipkey_integrated_pai()
	set name = "quick-equip"
	set hidden = 1

	if(ispAI(src))
		var/mob/living/silicon/pai/P = src
		if(P.incapacitated())
			return
		if(istype(P.card.loc, /obj))
			var/obj/O = P.card.loc
			if(O.integratedpai == P.card)
				O.equipkey_integrated_pai(P)

/mob/living/silicon/pai/mode()	//exists to pass usage of the attack_self() hotkey on to attack_integrated_pai()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr
	set hidden = TRUE

	if(ispAI(src))
		var/mob/living/silicon/pai/P = src
		if(P.incapacitated())
			return
		if(istype(P.card.loc, /obj))
			var/obj/O = P.card.loc
			if(O.integratedpai == P.card)
				O.attack_integrated_pai(P)

/mob/living/silicon/pai/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = TRUE

	if(ispAI(src))
		var/mob/living/silicon/pai/P = src
		if(P.incapacitated())
			return
		if(istype(P.card.loc, /obj))
			var/obj/O = P.card.loc
			if(O.integratedpai == P.card)
				switch(input)
					if(I_HELP)
						O.intenthelp_integrated_pai(P)
					if(I_DISARM)
						O.intentdisarm_integrated_pai(P)
					if(I_GRAB)
						O.intentgrab_integrated_pai(P)
					if(I_HURT)
						O.intenthurt_integrated_pai(P)
					if("right")
						O.intentright_integrated_pai(P)
					if("left")
						O.intentleft_integrated_pai(P)

/mob/living/silicon/pai/relaymove(dir)
	if(incapacitated())
		return
	if(istype(card.loc, /obj))
		var/obj/O = card.loc
		if(O.integratedpai == card)
			O.pAImove(src, dir)
	if (holomap_device)
		holomap_device.update_holomap()

/atom/proc/attack_pai(mob/user as mob)
	return

/mob/living/silicon/pai/teleport_to(var/atom/A)
	card.forceMove(get_turf(A))
	if (holomap_device)
		holomap_device.update_holomap()

/mob/living/silicon/pai/hasHUD(var/hud_kind)
	switch(hud_kind)
		if(HUD_MEDICAL)
			return medHUD
		if(HUD_SECURITY)
			return secHUD
	return FALSE