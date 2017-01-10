var/datum/subsystem/air/SSair

var/air_processing_killed = FALSE


/datum/subsystem/air
	name          = "Air"
	init_order    = SS_INIT_AIR
	priority      = SS_PRIORITY_AIR
	wait          = 2 SECONDS
	flags         = SS_NO_TICK_CHECK
	display_order = SS_DISPLAY_AIR

/datum/subsystem/air/New()
	NEW_SS_GLOBAL(SSair)


/datum/subsystem/air/stat_entry()
	if (air_master)
		..("Z:[air_master.zones.len]|ZU:[air_master.zones_to_update.len]|ZA:[air_master.active_zones]|TU:[air_master.tiles_to_update.len]|E:[air_master.edges.len]|F:[air_master.active_hotspots.len]")
	else
		..("AIR MASTER DOES NOT EXIST.")

/datum/subsystem/air/Initialize(timeofday)
	if (!air_master)
		air_master = new
		air_master.Setup()

	..()


/datum/subsystem/air/fire(resumed = FALSE)
	// No point doing MC_TICK_CHECK.
	if (!air_processing_killed)
		air_master.Tick()
