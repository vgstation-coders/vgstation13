var/datum/subsystem/engines/SSengines


/datum/subsystem/engines
	name          = "Engines"
	wait          = SS_WAIT_ENGINES
	flags         = SS_NO_INIT | SS_KEEP_TIMING
	priority      = SS_PRIORITY_ENGINES
	display_order = SS_DISPLAY_ENGINES


/datum/subsystem/engines/New()
	NEW_SS_GLOBAL(SSengines)

/datum/subsystem/engines/fire(resumed = FALSE)
	if(flags & SS_NO_FIRE)
		return
	if(map.has_engines)
		if (!ship_has_power)
			return FALSE
		for (var/obj/structure/shuttle/engine/propulsion/horizon/engine in large_engines)
			if (!istype(get_area(engine), /area/maintenance/engine))
				continue
			spawn() // So that they fire all at once.
				engine.shoot_exhaust(3, 0)

	else
		flags |= SS_NO_FIRE
		pause()
		message_admins("Engines subsystem was paused due to lack of engines.")
