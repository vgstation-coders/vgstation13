/datum/event/eclipse
	oneShot			= 1
	announceWhen	= 3
	endWhen			= 300

/datum/event/eclipse/can_start()
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (istype(cult))
		return 0//don't want the random event to trigger when the cult of Nar-Sie is doing its thing
	if (sun.eclipse == ECLIPSE_NOT_YET)
		return 10
	return 0

/datum/event/eclipse/announce()
	command_alert(/datum/command_alert/eclipse_start)

/datum/event/eclipse/start()
	world << sound('sound/effects/wind/wind_5_1.ogg')
	endWhen	= rand(240,360)
	sun.eclipse = ECLIPSE_ONGOING

	for (var/datum/light_source/LS in all_light_sources)
		if (LS.top_atom.z == map.zMainStation)
			LS.force_update()
			CHECK_TICK

/datum/event/eclipse/tick()
	if(activeFor == (endWhen - 5))
		sun.eclipse = ECLIPSE_OVER

/datum/event/eclipse/end()
	command_alert(/datum/command_alert/eclipse_end)
