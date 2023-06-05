/mob/living/silicon/robot/gib(animation = FALSE, meat = TRUE)
	if(status_flags & BUDDHAMODE)
		adjustBruteLoss(200)
		return
	//robots don't die when gibbed. instead they drop their MMI'd brain
	if(!isUnconscious())
		forcesay("-")
	disconnect_AI()
	monkeyizing = TRUE
	canmove = FALSE
	icon = null
	invisibility = 101

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "gibbed-r", sleeptime = 15)
	robogibs(loc, virus2)

	if(mind) //To make sure we're gibbing a player, who knows
		if(!mind.suiciding) //I don't know how that could happen, but you can't be too sure
			score.deadsilicon += 1

	living_mob_list -= src
	dead_mob_list -= src
	qdel(src)

/mob/living/silicon/robot/dust()
	disconnect_AI()
	death(1)
	monkeyizing = TRUE
	canmove = FALSE
	icon = null
	invisibility = 101

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-r", sleeptime = 15)
	new /obj/effect/decal/remains/robot(loc)
	if(mmi)
		QDEL_NULL(mmi)	//Delete the MMI first so that it won't go popping out.

	dead_mob_list -= src
	qdel(src)


/mob/living/silicon/robot/death(gibbed)
	if((status_flags & BUDDHAMODE) || stat == DEAD)
		return
	if(connected_ai)
		if(connected_ai.explosive_cyborgs)
			visible_message("<span class='warning'>You hear a soft beep.</span>")
			playsound(src, "sound/effects/kirakrik.ogg", 60)
			spawn(10)
				explosion(src.loc, 1, 4, 5, 6, whodunnit = src)
				gib()
				return
	if(!gibbed)
		emote("deathgasp", message = TRUE)
	stat = DEAD
	update_canmove()
	if(!gibbed)
		updateicon() //Don't call updateicon if you're already null.
		if (locked)
			locked = FALSE //Cover unlocks.
			visible_message("A click sounds from <span class='name'>[src]</span>, indicating the automatic cover release failsafe.")
	if(camera)
		camera.status = FALSE
	if(station_holomap)
		station_holomap.stopWatching()

	if(in_contents_of(/obj/machinery/recharge_station))//exit the recharge station
		var/obj/machinery/recharge_station/RC = loc
		if(RC.upgrading)
			RC.upgrading = FALSE
			RC.upgrade_finished = -1 //WHY
		RC.go_out()

	handle_sensor_modes()

	tod = worldtime2text() //weasellos time of death patch
	if(mind)
		mind.store_memory("Time of death: [tod]", 0)
		if(!mind.suiciding)
			score.deadsilicon += 1

	sql_report_cyborg_death(src)

	return ..(gibbed)

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
/mob/living/silicon/robot/Destroy()
	cyborg_list -= src
	if(mmi)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/turf/T = get_turf(loc)//To hopefully prevent run time errors.
		if(T)
			mmi.forceMove(T)
		if(mmi.brainmob)
			if(mind)
				var/datum/role/malfbot/MB = mind.GetRole(MALFBOT)
				if(MB)
					MB.Drop()
				mind.transfer_to(mmi.brainmob)
			mmi.brainmob.locked_to_z = locked_to_z
		else
			ghostize() //Somehow their MMI has no brainmob or something even worse happened. Let's just save their soul from this hell.
		mmi = null
	..()
