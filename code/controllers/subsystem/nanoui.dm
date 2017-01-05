var/datum/subsystem/nano/SSnano


/datum/subsystem/nano
	name = "Nano UI"
	flags = SS_NO_INIT
	wait = 4.1 SECONDS

	var/list/currentrun


/datum/subsystem/nano/New()
	NEW_SS_GLOBAL(SSnano)


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
