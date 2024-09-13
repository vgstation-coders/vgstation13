var/datum/subsystem/mapping/SSMapping

/datum/subsystem/mapping
	name          = "Mapping"
	init_order    = SS_INIT_MAPPING
	display_order = SS_DISPLAY_MAPPING
	priority      = SS_PRIORITY_MAPPING
	wait          = SS_WAIT_MAPPING
	flags 		  = SS_NO_FIRE
	var/list/currentrun
	var/datum/procedural_generator/PG

/datum/subsystem/mapping/New()
	NEW_SS_GLOBAL(SSMapping)

/datum/subsystem/mapping/Initialize()
	var/datum/procedural_generator/genpath = pick(typesof(/datum/procedural_generator) - /datum/procedural_generator)
	PG = new genpath
	..()

/datum/subsystem/mapping/stat_entry()
	..("P:[PG.turfs_remaining]")

/datum/subsystem/mapping/fire(resumed = FALSE)
	if(!resumed)
		currentrun = block(locate(1,PG.current_row,PG.procgen_z),locate(PG.map_size,PG.current_row+(PG.rows_per_tick-1),PG.procgen_z))

	while(currentrun.len)
		var/turf/T = currentrun[currentrun.len]
		currentrun.len--

		if(!T || T.gcDestroyed)
			continue

		PG.process(T)

		if(MC_TICK_CHECK)
			return

	PG.current_row += PG.rows_per_tick
