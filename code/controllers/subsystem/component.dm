var/datum/subsystem/component/SScomp

/datum/subsystem/component
	name          = "Component"
	wait          = 0.5 SECONDS
	flags         = SS_NO_INIT | SS_KEEP_TIMING
	priority      = SS_PRIORITY_COMPONENT
	display_order = SS_DISPLAY_COMPONENT

	var/list/currentrun


/datum/subsystem/component/New()
	NEW_SS_GLOBAL(SScomp)


/datum/subsystem/component/stat_entry()
	..("P:[active_components.len]")


/datum/subsystem/component/fire(resumed = FALSE)
	if (!resumed)
		currentrun = active_components.Copy()

	while (currentrun.len)
		var/datum/component/C = currentrun[currentrun.len]
		currentrun.len--

		if(!C || C.gcDestroyed)
			continue

		C.process()

		if(MC_TICK_CHECK)
			return
