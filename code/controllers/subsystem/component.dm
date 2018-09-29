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
	..("P:[active_component_containers.len]")


/datum/subsystem/component/fire(resumed = FALSE)
	if (!resumed)
		currentrun = active_component_containers.Copy()

	while (currentrun.len)
		var/datum/component_container/C = currentrun[currentrun.len]
		currentrun.len--

		if(!C || C.gcDestroyed || !C.holder || !C.components.len)
			continue

		if(isliving(C.holder))
			var/mob/living/M = C.holder
			if (!M || M.disposed || M.gcDestroyed || M.timestopped || M.monkeyizing || M.stat == DEAD)
				continue


		C.SendSignal(COMSIG_LIFE, list())

		if(MC_TICK_CHECK)
			return
