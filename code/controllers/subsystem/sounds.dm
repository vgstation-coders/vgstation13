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
	var/list/done = list()
	for (var/client/client in clients)
		if (!client.listener_context)
			continue
		for (var/datum/sound_emitter/E in client.listener_context.current_channels_by_emitter)
			if (done[E]) // only need to run update_active_sound_param once per emitter
				continue
			spawn()
				// recalc volume and such for when player/emitter isn't raising move events
				E.update_active_sound_param()
				done[E] = TRUE