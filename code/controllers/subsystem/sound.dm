var/datum/subsystem/sounds/SSsounds

/*
    Responsible for updating list of hearers on each sound_emitter within global.sound_controller.
*/

/datum/subsystem/sounds
	name = "Sounds"
	wait = 1
	priority = SS_PRIORITY_SOUNDS
	flags = SS_NO_INIT | SS_KEEP_TIMING | SS_NO_FIRE

	var/list/repeating_sound_emitters = list()
	var/list/all_sound_emitters = list()

/datum/subsystem/sounds/New()
	NEW_SS_GLOBAL(SSsounds)

/datum/subsystem/sounds/proc/register_repeating_emitter(datum/sound_emitter/E)
	repeating_sound_emitters |= E

/datum/subsystem/sounds/proc/unregister_repeating_emitter(datum/sound_emitter/E)
	repeating_sound_emitters -= E

/datum/subsystem/sounds/proc/register(datum/sound_emitter/E)
	all_sound_emitters |= E

/datum/subsystem/sounds/proc/unregister(datum/sound_emitter/E)
	all_sound_emitters -= E

/datum/subsystem/sounds/fire(resumed = FALSE)
	//for (var/datum/sound_emitter/E in repeating_sound_emitters)
	//	if (!E.channel)
	//		continue
	//	E.update_hearers() // send sounds to new hearers, stop sounds on lost hearers
	//	E.update_sound_params() // apply any environmental/deafness/whatever related attenuation to active sound

// eg. SSsounds.play_global_sound_on_type(/obj/machinery/firealarm, sound(file='bikehorn.ogg'))
//  makes all firealarms play bikehorn.ogg. requires a sound_emitter var on the type
/datum/subsystem/sounds/proc/play_global_sound_on_type(atom/target_type, sound/s)
	var/list/use_emitters = list()
	for (var/datum/sound_emitter/E in all_sound_emitters)
		if (istype(E.source, target_type))
			use_emitters |= E

	for (var/datum/sound_emitter/E in use_emitters)
		E.send_nearby_norepeat(s)