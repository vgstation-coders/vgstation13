var/datum/subsystem/garbage/SSgarbage


/datum/subsystem/garbage
	name = "Garbage"
	init_order = INIT_GARBAGE
	wait = 6.1 SECONDS


/datum/subsystem/garbage/New()
	NEW_SS_GLOBAL(SSgarbage)


/datum/subsystem/garbage/Initialize(timeofday)
	if (!garbageCollector)
		garbageCollector = new

	..()


/datum/subsystem/garbage/fire(resumed = FALSE)
	garbageCollector.process()
