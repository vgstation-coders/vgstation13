var/datum/subsystem/component/SScomp
var/list/active_component_owners = list()


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
	..("P:[active_component_owners.len]")


/datum/subsystem/component/fire(resumed = FALSE)
	if (!resumed)
		currentrun = active_component_owners.Copy()

	while (currentrun.len)
		var/atom/current_owner = currentrun[currentrun.len]
		currentrun.len--

		if(!current_owner || current_owner.gcDestroyed|| !current_owner._components?.len)
			active_component_owners.Remove(current_owner)
			continue

		if(isliving(current_owner))
			var/mob/living/M = current_owner
			if (!istype(M) || M.disposed || M.gcDestroyed || M.timestopped || M.monkeyizing || M.stat == DEAD)
				continue


		current_owner.SignalComponents(COMSIG_LIFE, list())

		if(MC_TICK_CHECK)
			return
