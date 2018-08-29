/mob/living/silicon/robot/gib()
	//robots don't die when gibbed. instead they drop their MMI'd brain
	monkeyizing = TRUE
	canmove = FALSE
	icon = null
	invisibility = 101

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "gibbed-r", sleeptime = 15)
	robogibs(loc, viruses)

	if(mind) //To make sure we're gibbing a player, who knows
		if(!suiciding) //I don't know how that could happen, but you can't be too sure
			score["deadsilicon"] += 1

	living_mob_list -= src
	dead_mob_list -= src
	qdel(src)

/mob/living/silicon/robot/dust()
	death(1)
	monkeyizing = TRUE
	canmove = FALSE
	icon = null
	invisibility = 101

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-r", sleeptime = 15)
	new /obj/effect/decal/remains/robot(loc)
	if(mmi)
		qdel(mmi)	//Delete the MMI first so that it won't go popping out.
		mmi = null

	dead_mob_list -= src
	qdel(src)


/mob/living/silicon/robot/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		emote("deathgasp")
	stat = DEAD
	update_canmove()
	if(!gibbed)
		updateicon() //Don't call updateicon if you're already null.
		locked = FALSE //Cover unlocks.
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
		if(!suiciding)
			score["deadsilicon"] += 1

	sql_report_cyborg_death(src)

	return ..(gibbed)
