var/datum/subsystem/humans/SShumans

/datum/subsystem/humans
	name       = "Human Init"
	init_order = SS_INIT_HUMANS
	flags      = SS_NO_FIRE


/datum/subsystem/humans/New()
	NEW_SS_GLOBAL(SShumans)

/datum/subsystem/humans/Initialize(timeofday)
	setupgenetics()
	buildHairLists()
	buildSpeciesLists()
	setup_species()
	..()
