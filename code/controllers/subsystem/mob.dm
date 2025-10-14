var/datum/subsystem/mob/SSmob


/datum/subsystem/mob
	name          = "Mob"
	wait          = 2 SECONDS
	flags         = SS_NO_INIT | SS_KEEP_TIMING
	priority      = SS_PRIORITY_MOB
	display_order = SS_DISPLAY_MOB

	var/list/currentrun
	var/paused = 0 // Count of mobs skipped due to planet optimization


/datum/subsystem/mob/New()
	NEW_SS_GLOBAL(SSmob)


/datum/subsystem/mob/stat_entry()
	..("P:[mob_list.len] | Paused:[paused]")


/datum/subsystem/mob/fire(resumed = FALSE)
	if (!resumed)
		currentrun = mob_list.Copy()
		paused = 0

	while (currentrun.len)
		var/mob/M = currentrun[currentrun.len]
		currentrun.len--

		if (!M || M.gcDestroyed || M.timestopped)
			continue

		// Skip processing non-player mobs on planets without players
		if (M.planet && !M.client)
			if (!M.planet.process_mobs)
				paused++
				continue

		M.Life()

		if (MC_TICK_CHECK)
			return
