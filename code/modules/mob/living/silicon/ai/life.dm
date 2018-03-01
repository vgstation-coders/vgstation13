// returns TRUE if Life() needs to abort
/mob/living/silicon/ai/proc/life_handle_health()
	updatehealth()
	if(health <= config.health_threshold_dead)
		death()
		return TRUE

/mob/living/silicon/ai/proc/life_handle_camera()
	if(stat != CONSCIOUS)
		cameraFollow = null
		reset_view(null)
		unset_machine()
	if(client)
		if(machine)
			if(!machine.check_eye(src))
				reset_view(null)
		else
			if(!isTeleViewing(client.eye))
				reset_view(null)

/mob/living/silicon/ai/proc/life_handle_malf()
	if(!malfhack || !malfhack.aidisabled)
		return
	to_chat(src, "<span class='warning'>ERROR: APC access disabled, hack attempt canceled.</span>")
	malfhacking = 0
	malfhack = null

/mob/living/silicon/ai/proc/life_handle_power_damage()
	if(aiRestorePowerRoutine != 0)
		// Lost power
		adjustOxyLoss(1)
	else
		// Gain Power
		adjustOxyLoss(-1)

/mob/living/silicon/ai/proc/life_handle_powered_core()
	var/unblindme = FALSE
	if(client && client.eye == eyeobj) // We are viewing the world through our "eye" mob.
		change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO

	var/area/home = get_area(src)
	if(home && home.powered(EQUIP))
		home.use_power(1000, EQUIP)

	if (aiRestorePowerRoutine==2)
		to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
		aiRestorePowerRoutine = 0
		unblindme = TRUE
	else if (aiRestorePowerRoutine==3)
		to_chat(src, "Alert cancelled. Power has been restored.")
		aiRestorePowerRoutine = 0
		unblindme = TRUE
	else if (aiRestorePowerRoutine == -1)
		to_chat(src, "Alert cancelled. External power source detected.")
		aiRestorePowerRoutine = 0
		unblindme = TRUE
	if(unblindme)
		clear_fullscreen("blind")
	return TRUE

/mob/living/silicon/ai/proc/power_restored()
	to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
	aiRestorePowerRoutine = 0
	clear_fullscreen("blind")

/mob/living/silicon/ai/proc/life_handle_unpowered_core()
	overlay_fullscreen("blind", /obj/abstract/screen/fullscreen/blind)
	if(client)
		change_sight(removing = SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 0
	see_invisible = SEE_INVISIBLE_LIVING

	if (aiRestorePowerRoutine != 0)
		return
	aiRestorePowerRoutine = 1
	to_chat(src, "You've lost power!")
	spawn(2 SECONDS)
		if(!aiRestorePowerRoutine)
			return // Checking for premature changes.
		to_chat(src, "Backup battery online. Scanners, camera, and radio interface offline. Beginning fault-detection.")
		sleep(5 SECONDS)
		if(!aiRestorePowerRoutine)
			return // Checking for premature changes.
		if(is_ai_powered())
			power_restored()
			return
		to_chat(src, "Fault confirmed: missing external power. Shutting down main control system to save power.")
		sleep(2 SECONDS)
		if(!aiRestorePowerRoutine)
			return // Checking for premature changes.
		to_chat(src, "Emergency control system online. Verifying connection to power network.")
		sleep(5 SECONDS)
		if(!aiRestorePowerRoutine)
			return // Checking for premature changes.
		if (istype(get_turf(src), /turf/space))
			to_chat(src, "Unable to verify! No power connection detected!")
			aiRestorePowerRoutine = 2
			return
		to_chat(src, "Connection verified. Searching for APC in power network.")
		sleep(5 SECONDS)
		if(!aiRestorePowerRoutine)
			return // Checking for premature changes.
		var/obj/machinery/power/apc/theAPC = null

		var/PRP //like ERP with the code, at least this stuff is no more 4x sametext
		for (PRP=1, PRP<=4, PRP++)
			if(!aiRestorePowerRoutine)
				return // Checking for premature changes.
			var/area/AIarea = get_area(src)
			for (var/obj/machinery/power/apc/APC in AIarea)
				if (!(APC.stat & BROKEN))
					theAPC = APC
					break
			if (!theAPC)
				switch(PRP)
					if (1)
						to_chat(src, "Unable to locate APC!")
					else
						to_chat(src, "Lost connection with the APC!")
				aiRestorePowerRoutine = 2
				return
			if (is_ai_powered())
				power_restored()
				return
			switch(PRP)
				if (1)
					to_chat(src, "APC located. Optimizing route to APC to avoid needless power waste.")
				if (2)
					to_chat(src, "Best route identified. Hacking offline APC power port.")
				if (3)
					to_chat(src, "Power port upload access confirmed. Loading control program into APC power port software.")
				if (4)
					to_chat(src, "Transfer complete. Forcing APC to execute program.")
					sleep(5 SECONDS)
					if(!aiRestorePowerRoutine)
						theAPC = null
						return // Checking for premature changes.
					to_chat(src, "Receiving control information from APC.")
					sleep(0.2 SECONDS)
					if(!aiRestorePowerRoutine)
						theAPC = null
						return // Checking for premature changes.
					//bring up APC dialog
					theAPC.attack_ai(src)
					aiRestorePowerRoutine = 3
					to_chat(src, "Here are your current laws:")
					show_laws()
			theAPC = null

/mob/living/silicon/ai/Life()
	if(timestopped)
		return 0 //under effects of time magick

	if (stat == DEAD)
		return

	if(life_handle_health())
		return

	life_handle_camera()
	life_handle_malf()
	life_handle_power_damage()

	is_ai_powered() ? life_handle_powered_core() : life_handle_unpowered_core()

/mob/living/silicon/ai/proc/is_ai_powered()
	if(isitem(loc))
		return TRUE
	var/turf/my_turf = get_turf(src)
	if(!my_turf || istype(my_turf, /turf/space))
		return FALSE
	var/area/my_area = get_area(my_turf)
	if(!my_area)
		return FALSE
	return my_area.powered(EQUIP)

/mob/living/silicon/ai/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else
		if(ai_flags & COREFIRERESIST)
			health = maxHealth - getOxyLoss() - getToxLoss() - getBruteLoss()
		else
			health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()

/mob/living/silicon/ai/update_canmove() //If the AI dies, mobs won't go through it anymore
	return FALSE
