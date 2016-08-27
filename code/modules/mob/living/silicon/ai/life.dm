/mob/living/silicon/ai/Life()
	if(timestopped)
		return 0 //under effects of time magick

	if (src.stat == DEAD)
		return
	else
		var/turf/T = get_turf(src)

		if (src.stat!=CONSCIOUS)
			src.cameraFollow = null
			src.reset_view(null)
			src.unset_machine()

		src.updatehealth()

		if (src.malfhack)
			if (src.malfhack.aidisabled)
				to_chat(src, "<span class='warning'>ERROR: APC access disabled, hack attempt canceled.</span>")
				src.malfhacking = 0
				src.malfhack = null


		if (src.health <= config.health_threshold_dead)
			death()
			return

		if(client)
			if (src.machine)
				if (!( src.machine.check_eye(src) ))
					src.reset_view(null)
			else
				if(!isTeleViewing(client.eye))
					reset_view(null)

		// Handle power damage (oxy)
		if(src.aiRestorePowerRoutine != 0)
			// Lost power
			adjustOxyLoss(1)
		else
			// Gain Power
			adjustOxyLoss(-1)

		var/unpowered_core = 0
		var/area/loc = null
		if (istype(T, /turf))
			loc = T.loc
			if (istype(loc, /area))
				if (!loc.power_equip && !istype(src.loc,/obj/item))
					unpowered_core = 1
		if (!unpowered_core)
			var/unblindme = 0
			if(client && client.eye == eyeobj) // We are viewing the world through our "eye" mob.
				change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
				src.see_in_dark = 8
				src.see_invisible = SEE_INVISIBLE_LEVEL_TWO

			var/area/home = get_area(src)
			if(home && home.powered(EQUIP))
				home.use_power(1000, EQUIP)

			if (src.aiRestorePowerRoutine==2)
				to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
				src.aiRestorePowerRoutine = 0
				unblindme = 1
			else if (src.aiRestorePowerRoutine==3)
				to_chat(src, "Alert cancelled. Power has been restored.")
				src.aiRestorePowerRoutine = 0
				unblindme = 1
			else if (src.aiRestorePowerRoutine == -1)
				to_chat(src, "Alert cancelled. External power source detected.")
				src.aiRestorePowerRoutine = 0
				unblindme = 1
			if(unblindme)
				clear_fullscreen("blind")
			return

		else // We are in an AI core and are unpowered.
			var/unblindme = 0

			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
			if(client)
				change_sight(removing = SEE_TURFS|SEE_MOBS|SEE_OBJS)
				src.see_in_dark = 0
			src.see_invisible = SEE_INVISIBLE_LIVING

			if (((!loc.power_equip) || istype(T, /turf/space)) && !istype(src.loc,/obj/item))
				if (src.aiRestorePowerRoutine==0)
					src.aiRestorePowerRoutine = 1

					to_chat(src, "You've lost power!")
					spawn(20)
						if(!src.aiRestorePowerRoutine)
							return // Checking for premature changes.
						to_chat(src, "Backup battery online. Scanners, camera, and radio interface offline. Beginning fault-detection.")
						sleep(50)
						if(!src.aiRestorePowerRoutine)
							return // Checking for premature changes.
						if (loc.power_equip)
							if (!istype(T, /turf/space))
								to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
								src.aiRestorePowerRoutine = 0
								unblindme = 1
								return
						to_chat(src, "Fault confirmed: missing external power. Shutting down main control system to save power.")
						sleep(20)
						if(!src.aiRestorePowerRoutine)
							return // Checking for premature changes.
						to_chat(src, "Emergency control system online. Verifying connection to power network.")
						sleep(50)
						if(!src.aiRestorePowerRoutine)
							return // Checking for premature changes.
						if (istype(T, /turf/space))
							to_chat(src, "Unable to verify! No power connection detected!")
							src.aiRestorePowerRoutine = 2
							return
						to_chat(src, "Connection verified. Searching for APC in power network.")
						sleep(50)
						if(!src.aiRestorePowerRoutine)
							return // Checking for premature changes.
						var/obj/machinery/power/apc/theAPC = null

						var/PRP //like ERP with the code, at least this stuff is no more 4x sametext
						for (PRP=1, PRP<=4, PRP++)
							if(!src.aiRestorePowerRoutine)
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
								src.aiRestorePowerRoutine = 2
								return
							if (loc.power_equip)
								if (!istype(T, /turf/space))
									to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
									src.aiRestorePowerRoutine = 0
									unblindme = 1
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
									sleep(50)
									if(!src.aiRestorePowerRoutine)
										theAPC = null
										return // Checking for premature changes.
									to_chat(src, "Receiving control information from APC.")
									sleep(2)
									if(!src.aiRestorePowerRoutine)
										theAPC = null
										return // Checking for premature changes.
									//bring up APC dialog
									theAPC.attack_ai(src)
									src.aiRestorePowerRoutine = 3
									to_chat(src, "Here are your current laws:")
									src.show_laws()
							sleep(50)
							theAPC = null
			if(unblindme)
				clear_fullscreen("blind")

/mob/living/silicon/ai/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else
		if(ai_flags & COREFIRERESIST)
			health = maxHealth - getOxyLoss() - getToxLoss() - getBruteLoss()
		else
			health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
