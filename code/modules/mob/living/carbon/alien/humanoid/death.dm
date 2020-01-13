/mob/living/carbon/alien/humanoid/death(gibbed)
	if(stat == DEAD)
		return
	if(healths)
		healths.icon_state = "health6"
	if(!gibbed)
		emote("deathgasp", message = TRUE)
	stat = DEAD

	if(!gibbed)
		update_canmove()
		update_icons()

	tod = worldtime2text() //weasellos time of death patch
	if(mind)
		mind.store_memory("Time of death: [tod]", 0)

	return ..(gibbed)
