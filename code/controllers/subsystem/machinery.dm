var/datum/subsystem/machinery/SSmachinery

var/list/machines = list()


/datum/subsystem/machinery
	name          = "Machinery"
	wait          = SS_WAIT_MACHINERY
	flags         = SS_NO_INIT | SS_KEEP_TIMING
	priority      = SS_PRIORITY_MACHINERY
	display_order = SS_DISPLAY_MACHINERY

	var/list/currentrun
	var/currentrun_index

	var/obj/machinery/M //Machine currently being processed.

/datum/subsystem/machinery/New()
	NEW_SS_GLOBAL(SSmachinery)


/datum/subsystem/machinery/stat_entry(var/msg)
	if (msg)
		return ..()

	..("M:[global.machines.len]")


// This is to allow the near identical fast machinery process to use it.
/datum/subsystem/machinery/proc/get_currenrun()
	return machines.Copy()


/datum/subsystem/machinery/fire(resumed = FALSE)
	if (!resumed)
		currentrun = get_currenrun()
		currentrun_index = currentrun.len

	while (currentrun_index)
		M = currentrun[currentrun_index]
		currentrun_index--

		if (!M || M.gcDestroyed || M.timestopped)
			continue

		if (M.process() == PROCESS_KILL)
			M.inMachineList = 0
			machines.Remove(M)
			continue

		if (M.use_power)
			M.auto_use_power()

		if (MC_TICK_CHECK)
			return
