var/datum/subsystem/obj/SSobj

var/list/processing_objects = list()


/datum/subsystem/obj
	name          = "Objects"
	init_order    = SS_INIT_OBJECT
	display_order = SS_DISPLAY_OBJECTS
	priority      = SS_PRIORITY_OBJECTS
	wait          = 2 SECONDS

	var/list/currentrun
	var/list/bad_inits = list()


/datum/subsystem/obj/New()
	NEW_SS_GLOBAL(SSobj)


/datum/subsystem/obj/Initialize()
	for(var/atom/object in world)
		if(!(object.flags & ATOM_INITIALIZED))
			var/time_start = world.timeofday
			object.initialize()
			var/time = (world.timeofday - time_start)
			if(time > 1) // At this point very few items (such as corpse landmarks) take longer than a tick to init, with the main bulk of items taking around 1 tick being things that use relativewall()
				var/turf/T = get_turf(object)
				log_debug("Slow object initialize. [object] ([object.type]) at [T?.x],[T?.y],[T?.z] took [time/10] seconds to initialize.")
		else
			bad_inits[object.type] = bad_inits[object.type]+1
		CHECK_TICK
	for(var/area/place in areas)
		var/obj/machinery/power/apc/place_apc = place.areaapc
		if(place_apc)
			place_apc.update()
	..()


/datum/subsystem/obj/stat_entry()
	..("P:[processing_objects.len]")


/datum/subsystem/obj/fire(resumed = FALSE)
	if (!resumed)
		currentrun = global.processing_objects.Copy()

	while (currentrun.len)
		var/atom/o = currentrun[currentrun.len]
		currentrun.len--

		if (!o || o.gcDestroyed || o.timestopped)
			continue

		// > this fucking proc isn't defined on a global level.
		// > Which means I can't fucking set waitfor on all of them.
		o:process()
		if (MC_TICK_CHECK)
			return
