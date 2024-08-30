var/datum/subsystem/procgen/SSprocgen

/datum/subsystem/procgen
	name          = "Procedural Generation"
	wait          = SS_WAIT_PROCGEN
	flags         = SS_KEEP_TIMING
	priority      = SS_PRIORITY_PROCGEN
	display_order = SS_DISPLAY_PROCGEN

	can_fire = FALSE //inactive until required

	var/rows_remaining = 0
	var/datum/procedural_generator/PG

/datum/subsystem/procgen/New()
	NEW_SS_GLOBAL(SSprocgen)

/datum/subsystem/procgen/stat_entry()
	..("P:[rows_remaining]")

/datum/subsystem/procgen/fire(var/resumed = FALSE)
	if(!PG)
		can_fire = FALSE
		pause()
	switch(procgen_state)
		if(PG_INACTIVE)
			can_fire = FALSE
		if(PG_INIT)
			rows_remaining = 1
			PG.construct_space_obj()
		if(PG_MAPPING)
			if(!resumed)
				rows_remaining = PG.map_size - PG.rows_completed
			while(rows_remaining)
				if(!rows_remaining || PG.gcDestroyed)
					continue

				PG.generate_map()

				if (MC_TICK_CHECK)
					break
		if(PG_DECORATION)
			can_fire = FALSE
		if(PG_POPULATION)
			can_fire = FALSE
		if(PG_LOOT)
			can_fire = FALSE

