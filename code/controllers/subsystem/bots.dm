var/datum/subsystem/bots/SSBots

/datum/subsystem/bots
	name          = "Bots"
	wait          = SS_WAIT_BOTS
	flags         = SS_NO_INIT | SS_KEEP_TIMING
	priority      = SS_PRIORITY_BOTS
	display_order = SS_DISPLAY_BOTS

	var/list/currentrun


/datum/subsystem/bots/New()
	NEW_SS_GLOBAL(SSBots)


/datum/subsystem/bots/stat_entry(var/msg)
	if (msg)
		return ..()

	..("B:[global.bots_list.len]")

// This is to allow the near identical fast machinery process to use it.
/datum/subsystem/bots/proc/get_currenrun()
	return bots_list.Copy()


/datum/subsystem/bots/fire(resumed = FALSE)
	if (!resumed)
		currentrun = get_currenrun()

	while (currentrun.len)
		var/obj/machinery/bot/M = currentrun[currentrun.len]
		currentrun.len--

		if (!M || M.gcDestroyed || M.timestopped)
			continue

		if (M.process() == PROCESS_KILL)
			bots_list.Remove(M)
			continue

		if (M.use_power)
			M.auto_use_power()

		if (MC_TICK_CHECK)
			return
