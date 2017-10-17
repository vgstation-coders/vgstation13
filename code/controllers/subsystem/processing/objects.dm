var/datum/subsystem/processing/obj/SSobj

/datum/subsystem/processing/obj
	name = "Objects"
	wait = 2 SECONDS
	stat_tag = "O"
	flags = SS_BACKGROUND | SS_POST_FIRE_TIMING

/datum/subsystem/processing/obj/New()
	NEW_SS_GLOBAL(SSobj)

// This is out of place
// TODO The initialize proc needs to be reworked
/datum/subsystem/processing/obj/Initialize()
	for(var/atom/movable/object in world)
		object.initialize()

	..()

// Slightly different behavior than the parent
/datum/subsystem/processing/obj/fire(resumed = FALSE)
	if(!resumed)
		currentrun = processing.Copy()

	var/list/current_run = currentrun

	while(current_run.len)
		var/atom/thing = current_run[current_run.len]
		current_run.len--
		if(thing.timestopped)
			continue
		if(!thing || thing.gcDestroyed || thing.disposed)
			processing -= thing
		else
			thing.process(wait)
		if(MC_TICK_CHECK)
			return

/datum/subsystem/processing/obj/Recover()
	processing = SSobj.processing
