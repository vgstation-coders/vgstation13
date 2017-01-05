var/datum/subsystem/air/SSair

var/air_processing_killed = FALSE


/datum/subsystem/air
	name = "Air"
	init_order = INIT_AIR
	wait = 3.1 SECONDS


/datum/subsystem/air/New()
	NEW_SS_GLOBAL(SSair)


/datum/subsystem/air/Initialize(timeofday)
	if (!air_master)
		air_master = new
		air_master.Setup()

	..()


/datum/subsystem/air/fire(resumed = FALSE)
	// No point doing MC_TICK_CHECK.
	if (!air_processing_killed)
		air_master.Tick()
