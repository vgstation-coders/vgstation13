/atom
	var/datum/sound_emitter/sound_emitter

/atom/proc/setup_sound()
	return

/mob
	var/list/current_sound_emitters = list()
	var/last_sound_zone_hash = null

/datum/sound_emitter
	var/atom/source = null
	var/list/sounds = list()
	var/active_key = null
	var/datum/sound_channel/channel = null
	var/list/mob/hearers = list()
	var/range
	var/last_hash = null
	var/use_unique_pool = TRUE

	// update driven by subsystem via update_active_sound_param
	var/env_volume_coeff = 1

	var/datum/sound_zone_manager/szm // not strictly necessary but its here for easy debugging in this early stage
	var/datum/sound_channel_manager/scm // also not strictly necessary

// for static things (e.g. machines that must be bolted to work) pass is_static = TRUE
//  this causes the reserved channel to be taken from a shared pool, as static objects won't move close
//  to eachother and won't contend. There is no overlap between the shared and unique pools, so no contention
//  for example if someone carrying something noisy (mobile -> unique pool) walks close to something in the shared pool.
// Dimensional Push is the exception to this (probably), the sound messing up is part of the !!! fun !!!
/datum/sound_emitter/New(atom/A, is_static = FALSE)
	..()
	source = A
	range = world.view
	sound_emitter_collection.add(src)
	use_unique_pool = !is_static
	if (sound_zone_manager)
		szm = sound_zone_manager
	if (sound_channel_manager)
		scm = sound_channel_manager

/datum/sound_emitter/Destroy()
	sound_emitter_collection.remove(src)
	deactivate();
	if (sounds)
		sounds.Cut()
		sounds = null
	. = ..()

/*
		GENERAL USE INTERFACE - SETUP, PLAY/STOP CONTROL
*/

/datum/sound_emitter/proc/add(sound/s, key)
	if (!s || !istype(s, /sound))
		return
	if (key && (key in sounds))
		return
	s.atom = source
	s.environment = -1 // byond bug(?) if you set this to anything else, it will permanently set the channel environment to it
	s.transform = matrix(1, 0, 0, 0, 1, 0) //dont think theres a good reason for this to be anything else
	sounds[key] = s

/datum/sound_emitter/proc/play(key)
	var/sound/S = sounds[key]
	if (!S)
		CRASH("Sound emitter play called for key [key] on channel [channel.value], but sound does not exist.")

	if (S.repeat == 1)
		active_key = key
		activate()
	else
		play_once(S)

/datum/sound_emitter/proc/play_once(sound/s, interrupt = FALSE)
	var/sound/S = copy_sound(s)
	S.atom = source
	S.repeat = 0 //no repeat - no need for channel reservation
	S.wait = 0
	if (interrupt)
		stop()
	// reduce volume if emitter is in low pressure
	S.volume *= turf_volume_coeff(source)
	if (!S.volume)
		return
	var/vicinity = players_in_range()
	for (var/mob/player in vicinity)
		var/sound/PS = apply_player_effects(copy_sound(S), player)
		if (PS.volume)
			player << PS

/datum/sound_emitter/proc/is_currently_playing()
	return ((active_key != null) && (channel != null))

/datum/sound_emitter/proc/update_active_sound_param(volume = null, frequency = null)
	if (!active_key)
		return
	var/sound/S = sounds[active_key]
	env_volume_coeff = turf_volume_coeff(source)
	S = apply_env_effects(copy_sound(S))
	S.atom = source

	if (volume)
		S.volume = volume
	if (frequency)
		S.frequency = frequency
	S.status |= SOUND_UPDATE
	for (var/mob/player in hearers)
		S = apply_player_effects(copy_sound(S), player)
		player << S

/datum/sound_emitter/proc/stop()
	if (!channel)
		return
	deactivate()

/datum/sound_emitter/proc/update_source(atom/new_source)
	sound_emitter_collection.remove(src)
	if (channel)
		sound_zone_manager.unregister_emitter(src)
	//old source should no longer fire move events
	source.unregister_event(/event/moved, src, nameof(src::on_source_moved()))

	source = new_source
	for (var/key in sounds)
		var/sound/S = sounds[key]
		S.atom = source
	update_active_sound_param()

	sound_emitter_collection.add(src)
	if (channel)
		sound_zone_manager.register_emitter(src)
	//new source
	source.register_event(/event/moved, src, nameof(src::on_source_moved()))

/*
		SYSTEMS-FACING INTERFACE
*/

/datum/sound_emitter/proc/on_source_moved(atom/mover)
	if (mover != source)
		CRASH("Called on_source_moved while mover ([mover]) != source ([source])")
	var/turf/T = source.loc
	if (!isturf(T))
		T = get_turf(source)
	if (!T)
		CRASH("Failed to get source turf")
	sound_zone_manager.update_emitter(src, T.x, T.y, T.z)

/datum/sound_emitter/proc/on_enter_range(mob/player)
	if (player in hearers)
		return
	hearers |= player
	player.current_sound_emitters |= src
	if (channel && active_key)
		var/sound/S = sounds[active_key]
		if (!S)
			CRASH("Sound emitter update_hearers called for key [active_key] on channel [channel.value], but sound does not exist.")
		// important note - clearing SOUND_UPDATE means that the sound will play FROM THE BEGINNING.
		// this system was originally built with short repeating sounds in mind (machine hum, etc) however
		// if you try to do something longer and more varied like music then this is very noticeable and unwanted.
		// such support goes beyond scope for v1 but may be solvable using sound.len, tracking playback progress and modifying
		// S.offset to start at the correct point
		S.status &= ~SOUND_UPDATE // clear update status for new hearers, else they cant hear it lmao
		S.channel = channel.value
		S = apply_env_effects(copy_sound(S))
		S = apply_player_effects(S, player)
		player << S

/datum/sound_emitter/proc/on_exit_range(mob/player)
	hearers -= player
	player.current_sound_emitters -= src
	if (!channel)
		return
	var/sound/nullsound = sound(file = null)
	nullsound.channel = channel.value
	nullsound.status = SOUND_UPDATE | SOUND_MUTE
	player << nullsound

/datum/sound_emitter/proc/contains(turf/T)
	if (!T)
		return FALSE
	var/turf/S = source.loc
	if (!isturf(S))
		S = get_turf(source)
	if (!S)
		CRASH("Failed to get source turf in in_range")
	var/minX = S.x - range
	var/maxX = S.x + range
	var/minY = S.y - range
	var/maxY = S.y + range
	return (minX <= T.x && T.x <= maxX && minY <= T.y && T.y <= maxY)

/*
		INTERNAL, DON'T CALL THESE DIRECTLY YOU
*/

/datum/sound_emitter/proc/activate()
	// expect active_key to be already set and validated
	if (!channel)
		channel = sound_channel_manager.reserve_channel(src, use_unique_pool)
		if (!channel)
			var/sound/S = sounds[active_key]
			CRASH("Sound emitter was unable to reserve a channel for sound [S.file]")
		sound_zone_manager.register_emitter(src)
		init_hearers()
	update_hearers()

/datum/sound_emitter/proc/deactivate()
	active_key = null
	update_hearers()
	hearers.Cut()
	if (channel)
		sound_zone_manager.unregister_emitter(src)
		release_channel()

/datum/sound_emitter/proc/release_channel()
	if (!channel)
		return
	sound_channel_manager.release_channel(channel, src)
	channel = null

/datum/sound_emitter/proc/init_hearers()
	hearers = players_in_range()

/datum/sound_emitter/proc/update_hearers()
	var/sound/S = null
	if (active_key)
		S = sounds[active_key]
		S.status &= ~SOUND_UPDATE
	else
		S = sound()
		S.file = null
		S.status = SOUND_UPDATE | SOUND_MUTE
	S.channel = channel.value
	for (var/mob/player in hearers)
		player << S

/datum/sound_emitter/proc/apply_player_effects(sound/s, var/mob/player)
	if (player.is_deaf())
		s.volume = 0
		return s

	// loosely simulate some obstruction muffling the sound
	if (!(source in view(range, player)))
		s.volume /= 5

	// similarly if player is in spaced area and emitter is in non-spaced nearby, shouldn't hear it
	var/p_effect = turf_volume_coeff(player)
	s.volume *= p_effect

	return s

/datum/sound_emitter/proc/apply_env_effects(sound/s)
	s.volume *= env_volume_coeff
	return s

/datum/sound_emitter/proc/turf_volume_coeff(atom/a)
	if (!a)
		return 1 // ?:D?
	var/turf/t = get_turf(a)
	if (!t)
		return 0 // no sound for the damned
	if (istype(t, /turf/simulated))
		var/turf/simulated/sim = t
		if (sim.zone?.air?.sound_coeff)
			return sim.zone.air.sound_coeff
	if (istype(t, /turf/unsimulated))
		return 1
	return 0 //damned

/datum/sound_emitter/proc/update_params_for_player(mob/player)
	if (!channel || !active_key)
		return
	if (!(player in hearers))
		return
	var/sound/S = copy_sound(sounds[active_key])
	if (!S)
		CRASH("active_key not found in sounds")
	apply_env_effects(S)
	apply_player_effects(S, player)
	S.status |= SOUND_UPDATE
	player << S

/datum/sound_emitter/proc/players_in_range()
	var/list/in_range = list()
	var/turf/t_source = get_turf(source)
	for (var/mob/player in player_list)
		if (!player || !player.client)
			continue
		var/turf/receiver = get_turf(player)
		if (!receiver)
			continue

		if((get_z_dist(receiver, t_source) <= range))
			in_range += player
	return in_range

// put this somewhere better than here
/proc/copy_sound(sound/copy_from)
	if (!copy_from)
		return
	var/sound/new_sound = sound(copy_from.file)
	new_sound.atom = copy_from.atom
	new_sound.channel = copy_from.channel
	new_sound.frequency = copy_from.frequency
	new_sound.repeat = copy_from.repeat
	new_sound.status = copy_from.status
	new_sound.transform = copy_from.transform
	new_sound.volume = copy_from.volume
	return new_sound
