var/datum/subsystem/obj/SSfast_obj

var/list/fast_objects = list()

/datum/subsystem/fast_obj
	name          = "Fast objects"
	display_order = SS_DISPLAY_FAST_OBJECTS
	priority      = SS_PRIORITY_FAST_OBJECTS
	wait          = SS_WAIT_FAST_OBJECTS
	flags         = SS_NO_INIT
	var/list/currentrun

/datum/subsystem/fast_obj/New()
	NEW_SS_GLOBAL(SSfast_obj)

/datum/subsystem/fast_obj/stat_entry()
	..("P:[fast_objects.len]")

/datum/subsystem/fast_obj/fire(var/resumed = FALSE)
	if (!resumed)
		currentrun = global.fast_objects.Copy()

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
