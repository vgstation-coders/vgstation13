var/datum/subsystem/genetics/SSgenetics


/datum/subsystem/genetics
	name       = "Genetics"
	init_order = SS_INIT_GENETICS
	flags      = SS_NO_FIRE


/datum/subsystem/genetics/New()
	NEW_SS_GLOBAL(SSgenetics)


/datum/subsystem/genetics/Initialize(timeofday)
	setupgenetics()
	..()
