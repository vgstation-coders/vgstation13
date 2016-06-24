/mob/living/silicon/hivebot/death(gibbed)
	if(mainframe)
		mainframe.return_to(src)
	stat = 2
	canmove = 0

	if(blind)
		blind.layer = 0
	sight |= SEE_TURFS
	sight |= SEE_MOBS
	sight |= SEE_OBJS

	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
	updateicon()

	var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
	store_memory("Time of death: [tod]", 0)

	if (key)
		spawn(50)
			if(key && stat == 2)
				verbs += /client/proc/ghost
	return ..(gibbed)