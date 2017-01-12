var/datum/subsystem/sun/SSsun


/datum/subsystem/sun
	name          = "Sun"
	init_order    = SS_INIT_SUN
	display_order = SS_DISPLAY_SUN
	priority      = SS_PRIORITY_SUN
	wait          = 30 SECONDS
	flags         = SS_NO_TICK_CHECK


/datum/subsystem/sun/New()
	NEW_SS_GLOBAL(SSsun)


/datum/subsystem/sun/Initialize(timeofday)
	sun = new

	..()


/datum/subsystem/sun/fire(resumed = FALSE)
	sun.calc_position()
