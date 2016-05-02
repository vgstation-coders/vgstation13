/mob/living/silicon/robot/mommi/gib()
	//robots don't die when gibbed. instead they drop their MMI'd brain
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "gibbed-r", sleeptime = 15)
	robogibs(loc, viruses)

	living_mob_list -= src
	dead_mob_list -= src
	if(src.module && istype(src.module))
		var/obj/item/found = locate(tool_state) in src.module.modules
		if(!found && tool_state != src.module.emag)
			var/obj/item/TS = tool_state
			drop_item(TS)
	qdel(src)

/mob/living/silicon/robot/mommi/dust()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-r", sleeptime = 15)
	new /obj/effect/decal/remains/robot(loc)
	if(mmi)
		qdel(mmi)	//Delete the MMI first so that it won't go popping out.

	dead_mob_list -= src
	qdel(src)

/mob/living/silicon/robot/mommi/death(gibbed)
	if(stat == DEAD)	return
	if(!gibbed)
		emote("deathgasp")
	stat = DEAD
	update_canmove()
	if(camera)
		camera.status = 0

	if(in_contents_of(/obj/machinery/recharge_station))//exit the recharge station
		var/obj/machinery/recharge_station/RC = loc
		if(RC.upgrading)
			RC.upgrading = 0
			RC.upgrade_finished = -1
		RC.go_out()

	if(blind)	blind.layer = 0
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
	updateicon()

	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)

	sql_report_cyborg_death(src)
	return ..(gibbed)
