var/datum/subsystem/mob/SSmob


/datum/subsystem/mob
	name          = "Mob"
	wait          = 2 SECONDS
	flags         = SS_NO_INIT | SS_KEEP_TIMING
	priority      = SS_PRIORITY_MOB
	display_order = SS_DISPLAY_MOB

	var/list/currentrun


/datum/subsystem/mob/New()
	NEW_SS_GLOBAL(SSmob)


/datum/subsystem/mob/stat_entry()
	..("P:[mob_list.len]")


/datum/subsystem/mob/fire(resumed = FALSE)
	if (!resumed)
		currentrun = mob_list.Copy()

	while (currentrun.len)
		var/mob/M = currentrun[currentrun.len]
		currentrun.len--

		if (!M || M.disposed || M.gcDestroyed || M.timestopped)
			continue

		M.Life()

		if (MC_TICK_CHECK)
			return
