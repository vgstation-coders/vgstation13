var/datum/subsystem/sounds/SSsounds

// This system's only job is to go over every active sound emitter every time it fires and push volume updates

/datum/subsystem/sounds
	name = "Sounds"
	wait = 0.5 SECONDS
	flags = SS_NO_INIT
	priority = SS_PRIORITY_SOUNDS


/datum/subsystem/sounds/New()
	NEW_SS_GLOBAL(SSsounds)

/datum/subsystem/sounds/fire(resumed = FALSE)
	sound_zone_manager.update_audible_emitters()