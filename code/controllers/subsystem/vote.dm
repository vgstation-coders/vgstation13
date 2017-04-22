var/datum/subsystem/vote/SSvote


/datum/subsystem/vote
	name     = "Vote"
	flags    = SS_NO_INIT
	wait     = 1 SECONDS
	priority = SS_PRIORITY_VOTE
	flags    = SS_FIRE_IN_LOBBY | SS_KEEP_TIMING

/datum/subsystem/vote/New()
	NEW_SS_GLOBAL(SSvote)


/datum/subsystem/vote/fire(resumed = FALSE)
	vote.process()
