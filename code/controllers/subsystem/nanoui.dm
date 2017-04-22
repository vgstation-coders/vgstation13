var/datum/subsystem/nano/SSnano


/datum/subsystem/nano
	name     = "Nano UI"
	flags    = SS_NO_INIT | SS_FIRE_IN_LOBBY
	wait     = 2 SECONDS
	priority = SS_PRIORITY_NANOUI

	var/list/currentrun


/datum/subsystem/nano/New()
	NEW_SS_GLOBAL(SSnano)


/datum/subsystem/nano/stat_entry()
	..("P:[nanomanager.processing_uis.len]")

/datum/subsystem/nano/fire(resumed = FALSE)
	if (!resumed)
		currentrun = nanomanager.processing_uis.Copy()

	while (currentrun.len)
		var/datum/nanoui/UI = currentrun[currentrun.len]
		currentrun.len--

		if (!UI || UI.gcDestroyed || UI.disposed)
			continue

		UI.process()

		if (MC_TICK_CHECK)
			return
