var/datum/subsystem/poll/SSpoll


/datum/subsystem/poll
	name     = "Poll"
	flags    = SS_NO_INIT
	wait     = 1 SECONDS
	priority = SS_PRIORITY_POLL
	flags    = SS_FIRE_IN_LOBBY | SS_KEEP_TIMING

/datum/subsystem/poll/New()
	NEW_SS_GLOBAL(SSpoll)


/datum/subsystem/poll/fire(resumed = FALSE)
	poll.process()
