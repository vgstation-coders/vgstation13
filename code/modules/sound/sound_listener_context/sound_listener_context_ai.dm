
/*
	A special SLC just for AI players!

	Rather than stuff all the special rules for AI into the vanilla SLC that 98% of players will use,
	  this one contains overloads for relevant procs to apply more context-aware dispatch.

*/

/datum/sound_listener_context/ai
	var/mob/living/silicon/ai/core_mob = null

/datum/sound_listener_context/ai/New(client/C, mob/EyeMob, mob/CoreMob, hearing_range)
	core_mob = CoreMob
	return ..(C, EyeMob, hearing_range)

/datum/sound_listener_context/ai/Destroy()
	return ..()

/datum/sound_listener_context/ai/apply_proxymob_effects(sound/S)
	// AI can't be deaf - skip deaf check
	// AI eye being in space shouldn't affect if sound "can be heard through camera"
	// but still allow muffling from occluded things
	if (!(S.atom in view(range, proxy)))
		S.volume /= 5
	return S

/datum/sound_listener_context/ai/start_hearing(datum/sound_emitter/emitter)
	if (!emitter.is_currently_playing())
		return
	if (!is_emitter_audible(emitter))
		return
	. = ..()

/datum/sound_listener_context/ai/hear_once(sound/S, datum/sound_emitter/emitter)
	// special handling because fuck AIs
	// prioritise aiEye if it exists
	if ((emitter.source in range(range, proxy)) && is_emitter_audible(emitter))
		return ..()
	// otherwise fall back to something like legacy behaviour for the core
	if (emitter.source in range(range, core_mob))
		var/turf/T = get_turf(emitter.source)
		S.atom = null
		core_mob.playsound_local(T, S, S.volume, 0, 0, 0, 1, 0, 0) //yep



/datum/sound_listener_context/ai/on_sound_update(datum/sound_emitter/emitter)
	// check is copypasted from ..() but delays the `is_emitter_audible` call
	var/chan = current_channels_by_emitter[emitter]
	if (!chan)
		return // we aren't hearing this emitter anyway
	if (!emitter.active_sound)
		return // emitter isn't playing anything, get out of here

	if (!is_emitter_audible(emitter))
		return
	. = ..()

/datum/sound_listener_context/ai/proc/is_emitter_audible(datum/sound_emitter/E)
	if (!proxy)
		return FALSE
	if (proxy == core_mob)
		return TRUE //let it hear whats in its core

	// else we check if the emitter is within a camerachunk that has a mic upgrade

	var/mob/camera/aiEye/eye = proxy
	if (!istype(eye))
		return FALSE

	for (var/obj/machinery/camera/cam in micd_cameras)
		if (cam.isHearing() && cam.can_use()) // implying anyone ever upgrades this
			// AI can hear it if emitter is close enough to camera and close enough to eye
			if ((E.source in range(range, cam)) && (E.source in range(range, eye)))
				return TRUE
