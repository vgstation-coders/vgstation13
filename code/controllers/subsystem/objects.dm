var/datum/subsystem/obj/SSobj

var/list/processing_objects = list()


/datum/subsystem/obj
	name          = "Objects"
	display_order = SS_DISPLAY_OBJECTS
	priority      = SS_PRIORITY_OBJECTS
	wait          = 2 SECONDS
	flags         = SS_NO_INIT
	var/list/currentrun


/datum/subsystem/obj/New()
	NEW_SS_GLOBAL(SSobj)

/datum/subsystem/obj/stat_entry()
	..("P:[processing_objects.len]")


/datum/subsystem/obj/fire(resumed = FALSE)
	if (!resumed)
		currentrun = global.processing_objects.Copy()

	while (currentrun.len)
		var/atom/o = currentrun[currentrun.len]
		currentrun.len--

		if (!o || o.gcDestroyed || o.disposed || o.timestopped)
			continue

		// > this fucking proc isn't defined on a global level.
		// > Which means I can't fucking set waitfor on all of them.
		o:process()
		if (MC_TICK_CHECK)
			return
