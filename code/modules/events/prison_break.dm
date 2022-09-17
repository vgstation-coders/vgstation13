/datum/event/prison_break
	announceWhen	= 30
	oneShot			= 1

	var/releaseWhen = 25
	var/list/area/prisonAreas = list()

/datum/event/prison_break/can_start()
	var/foundSomeone = FALSE
	var/foundBasic = FALSE
	for(var/area/A in areas)
		if(istype(A, /area/security/prison) || istype(A, /area/security/brig))
			prisonAreas += A
			var/list/areaMobs = mobs_in_area(A,1)
			if(areaMobs && areaMobs.len)
				foundBasic = TRUE
			for(var/mob/living/carbon/human/H in areaMobs)
				if(H.stat)
					continue
				var/list/access = H.GetAccess()
				if(!(access_brig in access))
					foundSomeone = TRUE
					break
		if(foundSomeone)
			break
	if(!prisonAreas || !prisonAreas.len)
		world.log << "ERROR: Could not initate grey-tide. Unable find prison or brig area."
	else if(!foundBasic)
		world.log << "ERROR: Could not initate grey-tide. Unable find person in prison or brig areas."
	else if(!foundSomeone)
		world.log << "ERROR: Could not initate grey-tide. Unable find person in prison or brig areas without access."
	return 50 * foundSomeone

/datum/event/prison_break/setup()
	announceWhen = rand(50, 60)
	releaseWhen = rand(20, 30)
	src.startWhen = src.releaseWhen-1
	src.endWhen = src.releaseWhen+1

/datum/event/prison_break/announce()
	command_alert(/datum/command_alert/graytide)

/datum/event/prison_break/start()
	if(!prisonAreas || !prisonAreas.len)
		for(var/area/A in areas)
			if(istype(A, /area/security/prison) || istype(A, /area/security/brig))
				prisonAreas += A

	if(prisonAreas && prisonAreas.len > 0)
		for(var/area/A in prisonAreas)
			for(var/obj/machinery/light/L in A)
				L.flicker(10)
	else
		world.log << "ERROR: Could not initate grey-tide. Unable find prison or brig area."
		kill()

/datum/event/prison_break/tick()
	if(activeFor == releaseWhen)
		if(prisonAreas && prisonAreas.len > 0)
			for(var/area/A in prisonAreas)
				for(var/obj/machinery/power/apc/temp_apc in A)
					temp_apc.overload_lighting()

				for(var/obj/structure/closet/secure_closet/brig/temp_closet in A)
					temp_closet.locked = 0
					temp_closet.icon_state = temp_closet.icon_closed

				for(var/obj/machinery/door/airlock/security/temp_airlock in A)
					temp_airlock.prison_open()

				for(var/obj/machinery/door/airlock/glass_security/temp_glassairlock in A)
					temp_glassairlock.prison_open()

				for(var/obj/machinery/door_timer/temp_timer in A)
					temp_timer.timeleft = 0
