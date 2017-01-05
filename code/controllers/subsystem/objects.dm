var/datum/subsystem/obj/SSobj

var/list/processing_objects = list()


/datum/subsystem/obj
	name = "Objects"
	init_order = INIT_OBJECT
	wait = 2 SECONDS

	var/list/currentrun


/datum/subsystem/obj/New()
	NEW_SS_GLOBAL(SSobj)


/datum/subsystem/obj/Initialize()
	for(var/atom/movable/object in world)
		object.initialize()

	..()


/datum/subsystem/obj/fire(resumed = FALSE)
	if (!resumed)
		currentrun = global.processing_objects.Copy()

	while (currentrun.len)
		var/atom/o = currentrun[currentrun.len]
		currentrun.len--

		if (!o || o.gcDestroyed || o.disposed || o.timestopped)
			continue

		// > this fucking proc isn't defined on a global level.
		o:process()
		if (MC_TICK_CHECK)
			return
