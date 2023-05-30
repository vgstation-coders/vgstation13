/datum/event/nuclear_war
	endWhen = 300

/datum/event/nuclear_war/can_start()
	return 0

/datum/event/nuclear_war/start()
	command_alert(/datum/command_alert/command_link_lost)
	unlink_from_centcomm()

/datum/event/nuclear_war/end()
	command_alert(/datum/command_alert/command_link_restored)
	link_to_centcomm()
