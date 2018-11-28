var/datum/subsystem/ambientsound/SSambience
//ambient sound subsystem.
//at the very least it's not a switch right


/datum/subsystem/ambientsound
	name = "Ambient Sound"
	wait = 5 SECONDS
	flags = SS_NO_INIT | SS_BACKGROUND | SS_NO_TICK_CHECK
	priority = SS_PRIORITY_AMBIENCE


/datum/subsystem/ambientsound/New()
	NEW_SS_GLOBAL(SSambience)


/datum/subsystem/ambientsound/fire(resumed = FALSE)
	for (var/client/C in clients)
		if(C && (C.prefs.toggles & SOUND_AMBIENCE))
			C.handle_ambience()
