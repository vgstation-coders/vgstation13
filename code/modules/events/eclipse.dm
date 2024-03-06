/datum/event/eclipse
	oneShot			= 1

/datum/event/eclipse/can_start()
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (istype(cult))
		return 0//don't want the random event to trigger when the cult of Nar-Sie is doing its thing
	if (sun.eclipse == ECLIPSE_NOT_YET)
		return 10
	return 0

/datum/event/eclipse/start()
	eclipse_trigger_random()

