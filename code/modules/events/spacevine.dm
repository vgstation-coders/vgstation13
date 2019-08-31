/var/global/spacevines_spawned = 0

/datum/event/spacevine

/datum/event/spacevine/can_start()
	if(spacevines_spawned)
		return 15
	return 0

/datum/event/spacevine/start()
	//biomass is basically just a resprited version of space vines
	if(prob(50))
		spacevine_infestation()
	else
		biomass_infestation()
	spacevines_spawned = 1
