var/datum/subsystem/emergency_shuttle/SSemergency_shuttle


/datum/subsystem/emergency_shuttle
	name = "Emergency Shuttle"
	init_order = INIT_EMERGENCY_SHUTTLE
	wait = 2 SECONDS


/datum/subsystem/emergency_shuttle/New()
	NEW_SS_GLOBAL(SSemergency_shuttle)


/datum/subsystem/emergency_shuttle/Initialize(timeofday)
	if (!emergency_shuttle)
		emergency_shuttle = new

	..()


/datum/subsystem/emergency_shuttle/fire(resumed = FALSE)
	emergency_shuttle.process()
