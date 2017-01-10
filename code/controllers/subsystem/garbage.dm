var/datum/subsystem/garbage/SSgarbage


/datum/subsystem/garbage
	name          = "Garbage"
	init_order    = SS_INIT_GARBAGE
	wait          = 5 SECONDS
	display_order = SS_DISPLAY_GARBAGE
	priority      = SS_DISPLAY_GARBAGE
	flags         = SS_BACKGROUND | SS_NO_TICK_CHECK | SS_FIRE_IN_LOBBY


/datum/subsystem/garbage/New()
	NEW_SS_GLOBAL(SSgarbage)


/datum/subsystem/garbage/stat_entry()
	if (!garbageCollector)
		return ..("GC DOESN'T EXIST CALL IT.")

	var/msg = ""
	msg += "Q:[garbageCollector.queue.len]|TD:[garbageCollector.dels_count]|SD:[global.soft_dels]|HD:[garbageCollector.hard_dels]"
	if (garbageCollector.del_everything)
		msg += "|QDEL OFF"

	..(msg)


/datum/subsystem/garbage/Initialize(timeofday)
	if (!garbageCollector)
		garbageCollector = new

	..()


/datum/subsystem/garbage/fire(resumed = FALSE)
	if (garbageCollector)
		garbageCollector.process()
