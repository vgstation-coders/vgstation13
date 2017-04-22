var/datum/subsystem/inactivity/SSinactivity


/datum/subsystem/inactivity
	name = "Inactivity"
	wait = INACTIVITY_KICK
	flags = SS_NO_INIT | SS_BACKGROUND | SS_FIRE_IN_LOBBY
	priority = SS_PRIORITY_INACTIVITY


/datum/subsystem/inactivity/New()
	NEW_SS_GLOBAL(SSinactivity)


/datum/subsystem/inactivity/fire(resumed = FALSE)
	if (config.kick_inactive)
		for (var/client/C in clients)
			if (C.is_afk(INACTIVITY_KICK))
				if (!istype(C.mob, /mob/dead))
					log_access("AFK: [key_name(C)]")
					to_chat(C, "<SPAN CLASS='warning'>You have been inactive for more than 10 minutes and have been disconnected.</SPAN>")
					del(C)
