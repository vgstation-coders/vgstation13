var/datum/subsystem/sounds/SSsounds

/*
    Responsible for updating list of hearers on each sound_emitter within global.sound_controller.
*/

/datum/subsystem/sounds
	name = "Sounds"
	wait = 1
	priority = SS_PRIORITY_SOUNDS
	flags = SS_NO_INIT | SS_KEEP_TIMING

	var/list/sound_emitters = list()

/datum/subsystem/sounds/New()
	NEW_SS_GLOBAL(SSsounds)

/datum/subsystem/sounds/proc/register(datum/sound_emitter/E)
	sound_emitters += E

/datum/subsystem/sounds/proc/unregister(datum/sound_emitter/E)
	sound_emitters -= E

/datum/subsystem/sounds/fire(resumed = FALSE)
	//world.log << "Sound subsystem processing [sound_emitters.len] sound emitters."
	for (var/datum/sound_emitter/E in sound_emitters)
		if (!E.channel)
			//world.log << "Sound emitter [E] has no channel, skipping."
			continue
		//world.log << "Sound emitter [E] has [in_range.len] hearers in range."
		E.update_hearers() // send sounds to new hearers, stop sounds on lost hearers
		E.update_sound_params() // apply any environmental/deafness/whatever related attenuation to active sound
