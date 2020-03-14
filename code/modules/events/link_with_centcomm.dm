/datum/event/unlink_from_centcomm
	endWhen = 300

/datum/event/unlink_from_centcomm/can_start()
	return 10

/datum/event/unlink_from_centcomm/start()
	unlink_from_centcomm()

/datum/event/unlink_from_centcomm/end()
	link_to_centcomm()

proc/link_to_centcomm()
	if(!map.linked_to_centcomm)
		map.linked_to_centcomm = 1
		command_alert(/datum/command_alert/command_link_restored)

proc/unlink_from_centcomm()
	if(map.linked_to_centcomm)
		command_alert(/datum/command_alert/command_link_lost)
		map.linked_to_centcomm = 0