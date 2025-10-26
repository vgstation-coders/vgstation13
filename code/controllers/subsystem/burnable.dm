var/datum/subsystem/burnable/SSburnable
var/list/zone/burnable_zones_processing = list()

/datum/subsystem/burnable
	name          = "Burnable"
	wait          = SS_WAIT_BURNABLE
	flags         = SS_KEEP_TIMING
	priority      = SS_PRIORITY_BURNABLE
	display_order = SS_DISPLAY_BURNABLE

	var/list/atom/currentrun = list()

/datum/subsystem/burnable/New()
	NEW_SS_GLOBAL(SSburnable)

/datum/subsystem/burnable/stat_entry()
	..("P:[burnable_zones_processing.len]")

/datum/subsystem/burnable/fire(var/resumed = FALSE)
	if(!resumed)
		currentrun = burnable_zones_processing.Copy()

	while(currentrun.len)
		var/zone/Z = currentrun[currentrun.len]
		currentrun.len--

		if(!Z || Z.gcDestroyed)
			continue

		Z.checkzoneburn()

		if (MC_TICK_CHECK)
			break
