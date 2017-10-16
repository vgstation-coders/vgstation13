/mob/living/silicon/pai/death(gibbed)
	if(stat == DEAD)
		return
	stat = DEAD
	canmove = 0
	change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO

	//var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
	//mind.store_memory("Time of death: [tod]", 0)

	//New pAI's get a brand new mind to prevent meta stuff from their previous life. This new mind causes problems down the line if it's not deleted here.
	//Read as: I have no idea what I'm doing but asking for help got me nowhere so this is what you get. - Nodrak
	if(mind)
		qdel(mind)
	mind = null
	living_mob_list -= src
	if(pPS) // Removes it from the GPS List.
		GPS_list.Remove(src)
	if(holomap_device)
		holomap_device.stopWatching()
		qdel(holomap_device)
		holomap_device = null
	ghostize()
	qdel(src)
