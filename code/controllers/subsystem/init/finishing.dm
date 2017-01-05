var/datum/subsystem/air/SSair


/datum/subsystem/air
	name = "Finishing Init"
	init_order = INIT_FINISH
	flags = SS_NO_FIRE


/datum/subsystem/air/New()
	NEW_SS_GLOBAL(SSair)


/datum/subsystem/air/Initialize(timeofday)
	setup_species()
	setup_shuttles()

	stat_collection.artifacts_discovered = 0 // Because artifacts during generation get counted otherwise!

	..()
