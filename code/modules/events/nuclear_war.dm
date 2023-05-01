/datum/event/nuclear_war
	endWhen = 600

/datum/event/nuclear_war/can_start()
	return 0

/datum/event/nuclear_war/start()
	command_alert(/datum/command_alert/shuttle_jamming)
	ticker.StartThematic("nukesquad")
	unlink_from_centcomm()

/datum/event/nuclear_war/end()
	command_alert(/datum/command_alert/shuttle_jamming_end)
	link_to_centcomm()
