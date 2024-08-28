var/datum/subsystem/procgen/SSprocgen

/datum/subsystem/procgen
	name          = "Procedural Generation"
	wait          = SS_WAIT_PROCGEN
	flags         = SS_KEEP_TIMING
	priority      = SS_PRIORITY_PROCGEN
	display_order = SS_DISPLAY_PROCGEN

	var/rows_remaining = 0
	var/datum/procgen/generation/PG

/datum/subsystem/procgen/New()
	NEW_SS_GLOBAL(SSprocgen)

/datum/subsystem/procgen/stat_entry()
	..("P:[rows_remaining]")

/datum/subsystem/procgen/fire(var/resumed = FALSE)
	if(!PG)
		flags |= SS_NO_FIRE
		pause()
	else if(!resumed)
		rows_remaining = PG.gen_state == PG_INIT ? 1 : PG.map_size - PG.rows_completed
	while(rows_remaining)
		if(!rows_remaining || PG.gcDestroyed)
			continue

		PG.process()

		if (MC_TICK_CHECK)
			break
