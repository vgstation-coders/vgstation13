var/datum/subsystem/pathing/SSpath
var/global/list/pathfinders = list()

/datum/subsystem/pathing
	name = "Pathing"
	wait = 1
	priority = SS_PRIORITY_PATHING
	flags = SS_NO_INIT
	var/list/currentrun

/datum/subsystem/pathing/New()
	NEW_SS_GLOBAL(SSpath)

/datum/subsystem/pathing/stat_entry()
	..("Pathfinders:[pathfinders.len]")

/datum/subsystem/pathing/fire(var/resumed = FALSE)
	if(!resumed)
		currentrun = pathfinders.Copy()

	while(currentrun.len)
		var/atom/A = currentrun[currentrun.len]
		currentrun.len--

		if(!A.process_astar_path())
			A.drop_astar_path()