
/*
	A special SLC just for AI players!

	Rather than stuff all the special rules for AI into the vanilla SLC that 98% of players will use,
	  this one contains overloads for relevant procs to apply more context-aware dispatch.

*/

/datum/sound_listener_context/ai
	var/mob/living/silicon/ai/core_mob = null

/datum/sound_listener_context/ai/New(client/C, mob/EyeMob, mob/CoreMob, hearing_range)
	client = C
	proxy = EyeMob // this is CoreMob on creation but gets reset to eyeobj when the AI makes one
	current_channels_by_emitter = list()
	free_channels = list()
	for (var/i = CHANNEL_RESERVABLE_MIN, i <= CHANNEL_RESERVABLE_MAX, i++)
		free_channels += i
	range = hearing_range
	core_mob = CoreMob
	sound_zone_manager.register_listener(src)

/datum/sound_listener_context/ai/Destroy()
	..()

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

/datum/sound_listener_context/ai/hear_once(sound/S)
	// TODO add emitter to args, check if audible
	. = ..()

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
		world.log << "is_emitter_audible: no proxy, returning FALSE"
		return FALSE
	if (proxy == core_mob)
		world.log << "is_emitter_audible: proxy is core mob, returning TRUE"
		return TRUE //let it hear whats in its core

	// else we check if the emitter is within a camerachunk that has a mic upgrade

	var/mob/camera/aiEye/eye = proxy
	if (!istype(eye))
		world.log << "is_emitter_audible: proxy is not an aiEye, returning FALSE"
		return FALSE

	// TODO just cache the cameras that have a mic upgrade directly
	for (var/datum/camerachunk/chunk in eye.visibleCameraChunks) // 9 of these on Box
		for (var/obj/machinery/camera/cam in chunk.cameras) // each one has < ~20 cameras in
			if (cam.isHearing() && cam.can_use()) // implying anyone ever upgrades this
				// AI can hear it if emitter is close enough to camera and close enough to eye
				if ((E.source in range(range, cam)) && (E.source in range(range, eye)))
					world.log << "is_emitter_audible: found micd camera at [cam.x] [cam.y] [cam.z] returning TRUE"
					return TRUE
