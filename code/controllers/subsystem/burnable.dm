var/datum/subsystem/burnable/SSburnable
var/list/atom/burnableatoms = list()

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
	..("P:[burnableatoms.len]")

/datum/subsystem/burnable/fire(var/resumed = FALSE)
	if(!resumed)
		currentrun = burnableatoms.Copy()

	while(currentrun.len)
		var/atom/A = currentrun[currentrun.len]
		currentrun.len--

		if(!A || A.gcDestroyed || A.timestopped)
			continue

		A.checkburn()

		if (MC_TICK_CHECK)
			break
