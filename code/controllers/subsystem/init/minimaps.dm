var/datum/subsystem/minimap/SSminimap


/datum/subsystem/minimap
	name       = "Minimap"
	init_order = SS_INIT_MINIMAP
	flags      = SS_NO_FIRE


/datum/subsystem/minimap/New()
	NEW_SS_GLOBAL(SSminimap)


/datum/subsystem/minimap/Initialize(timeofday)
	if (!config.skip_minimap_generation)
		generateMiniMaps()
	else
		log_startup_progress("Not generating minimaps - SKIP_MINIMAP_GENERATION found in config/config.txt")
	..()
