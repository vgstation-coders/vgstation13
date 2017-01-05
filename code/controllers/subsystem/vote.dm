var/datum/subsystem/vote/SSvote


/datum/subsystem/vote
	name = "Vote"
	flags = SS_NO_INIT
	wait = 1 SECONDS


/datum/subsystem/vote/New()
	NEW_SS_GLOBAL(SSvote)


/datum/subsystem/vote/fire(resumed = FALSE)
	vote.process()
