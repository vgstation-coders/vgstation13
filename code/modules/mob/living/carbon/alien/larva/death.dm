/mob/living/carbon/alien/larva/death(gibbed)
	if(stat == DEAD)
		return
	if(healths)
		healths.icon_state = "health6"
	if(!gibbed)
		emote("deathgasp", message = TRUE)
	stat = DEAD
	icon_state = "larva_dead"

	if(!gibbed)
		update_canmove()

	tod = worldtime2text() //weasellos time of death patch
	if(mind)
		mind.store_memory("Time of death: [tod]", 0)
	living_mob_list -= src

	return ..(gibbed)
