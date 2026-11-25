var/datum/subsystem/pathing/SSpath
var/global/list/pathers = list()

// Movement driver, not a pathfinder: ticks the atoms in `pathers` along paths JPS already found.

/datum/subsystem/pathing
	name = "Pathing"
	wait = 1
	priority = SS_PRIORITY_PATHING
	flags = SS_NO_INIT
	var/list/currentrun

/datum/subsystem/pathing/New()
	NEW_SS_GLOBAL(SSpath)

/datum/subsystem/pathing/stat_entry()
	..("Pathfollowers:[pathers.len]")

/datum/subsystem/pathing/fire(var/resumed = FALSE)
	if(!resumed)
		currentrun = pathers.Copy()

	while(currentrun.len)
		var/atom/A = currentrun[currentrun.len]
		currentrun.len--

		if(!A.process_path_step())
			A.drop_path()

		if (MC_TICK_CHECK)
			return

// Things following a path add themselves to `pathers` and override these.
/atom/proc/process_path_step()
	return FALSE

/atom/proc/drop_path()
	pathers.Remove(src)
