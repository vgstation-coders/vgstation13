/datum/event/grid_check	//NOTE: Times are measured in master controller ticks!
	announceWhen		= 5

/datum/event/grid_check/setup()
	endWhen = rand(30,120)

/datum/event/grid_check/start()
	power_failure(0)

/datum/event/grid_check/announce()
	command_alert(/datum/command_alert/power_disabled)

/datum/event/grid_check/end()
	if(universe.name != "Normal")
		message_admins("Universe isn't normal, aborting power_restore().")//we don't want the power to come back up during Nar-Sie or a Supermatter Cascade, do we?
		return
	power_restore()
