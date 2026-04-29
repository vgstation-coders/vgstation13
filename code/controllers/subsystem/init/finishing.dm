var/datum/subsystem/finish/SSfinish


/datum/subsystem/finish
	name       = "Finishing Init"
	init_order = SS_INIT_FINISH
	flags      = SS_NO_FIRE


/datum/subsystem/finish/New()
	NEW_SS_GLOBAL(SSfinish)


/datum/subsystem/finish/Initialize(timeofday)
	setup_shuttles()

	setup_loaded_shuttle_transits()

	stat_collection.artifacts_discovered = 0 // Because artifacts during generation get counted otherwise!

	..()
