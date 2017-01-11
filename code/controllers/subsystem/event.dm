var/datum/subsystem/event/SSevent

var/list/events = list()


/datum/subsystem/event
	name     = "Event"
	wait     = 2 SECONDS
	flags    = SS_NO_INIT | SS_KEEP_TIMING
	priority = SS_PRIORITY_EVENT

	var/list/currentrun


/datum/subsystem/event/New()
	NEW_SS_GLOBAL(SSevent)


/datum/subsystem/event/stat_entry()
	..("E:[events.len]")


/datum/subsystem/event/fire(resumed = FALSE)
	if (!resumed)
		currentrun = events.Copy()

	while (currentrun.len)
		var/datum/event/E = currentrun[currentrun.len]
		currentrun.len--

		if (!E || E.gcDestroyed || E.disposed)
			continue

		E.process()

		if (MC_TICK_CHECK)
			return

	checkEvent()
