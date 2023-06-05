/datum/event/spacevine

/datum/event/spacevine/can_start(var/list/active_with_role)
	if(active_with_role.len > 6)
		return 20
	return 0

/datum/event/spacevine/start()
	spacevine_infestation()

/datum/event/biomass

/datum/event/biomass/can_start(var/list/active_with_role)
	if(active_with_role.len > 6)
		return 15
	return 0

/datum/event/biomass/start()
	biomass_infestation()
