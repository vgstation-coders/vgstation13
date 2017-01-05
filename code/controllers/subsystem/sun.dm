var/datum/subsystem/sun/SSsun


/datum/subsystem/sun
	name = "Sun"
	init_order = INIT_SUN
	wait = 30 SECONDS


/datum/subsystem/sun/New()
	NEW_SS_GLOBAL(SSsun)


/datum/subsystem/sun/Initialize(timeofday)
	sun = new

	..()


/datum/subsystem/sun/fire(resumed = FALSE)
	sun.calc_position()
