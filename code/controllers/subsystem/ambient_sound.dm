var/datum/subsystem/ambientsound/SSambience
//ambient sound subsystem. made by Pacmandevil. Code is GPL.
//can't be worse than the fucking switch, can it? can it?


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
