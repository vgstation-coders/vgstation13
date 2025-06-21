/atom
	var/datum/sound_emitter/sound_emitter

/mob
	var/list/current_sound_emitters = list()

/datum/sound_emitter
	var/atom/source = null
	var/list/sounds = list()
	var/active_key = null
	var/channel = null
	var/list/mob/hearers = list()
	var/range
	var/last_hash = null

	var/debug = FALSE
	var/datum/sound_zone_manager/szm

/datum/sound_emitter/New(atom/A)
	..()
	source = A
	range = world.view
	if (sound_zone_manager)
		szm = sound_zone_manager

/datum/sound_emitter/Destroy()
	source = null
	active_key = null
	if (sounds)
		sounds.Cut()
		sounds = null
	. = ..()

/*
		CALLED FROM ATOM
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
	world.log << "[source] called play([key]) at [source.loc.x] [source.loc.y] [source.loc.z]"
	var/sound/S = sounds[key]
	if (!S)
		CRASH("Sound emitter play called for key [key] on channel [channel], but sound does not exist.")

	if (S.repeat == 1)
		active_key = key
		activate()
	else
		send_nearby_norepeat(S) //mimic legacy behaviour
		//send_global(S) // implement if send_nearby_norepeat is slow

/datum/sound_emitter/proc/update_active_sound_param(volume = null, frequency = null)
	if (!active_key)
		return
	var/sound/S = sounds[active_key]

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

/*
		CALLED BY SOUND_ZONE_MANAGER
*/

/datum/sound_emitter/proc/on_enter_range(mob/player)
	if (player in hearers)
		return
	hearers |= player
	player.current_sound_emitters |= src
	if (channel && active_key)
		var/sound/S = sounds[active_key]
		if (!S)
			CRASH("Sound emitter update_hearers called for key [active_key] on channel [channel], but sound does not exist.")
		S.status &= ~SOUND_UPDATE // clear update status for new hearers, else they cant hear it lmao
		S.channel = channel
		if (debug)
			world.log << "Sending sound to [player]: [S.file] V: [S.volume] C: [S.channel]"
		S = apply_player_effects(copy_sound(S), player)
		player << S

/datum/sound_emitter/proc/on_exit_range(mob/player)
	hearers -= player
	player.current_sound_emitters -= src
	if (!channel)
		return
	var/sound/nullsound = sound(file = null)
	nullsound.channel = channel
	nullsound.status = SOUND_UPDATE | SOUND_MUTE
	if (debug)
		world.log << "Stopping sound for [player] on channel [channel]"
	player << nullsound

/datum/sound_emitter/proc/contains(turf/T)
	if (!T)
		return FALSE
	var/turf/S = source.loc
	if (!isturf(S))
		S = get_turf(source)
	if (!S)
		CRASH("Failed to get source turf in in_range")
	var/minX = S.x - range //TODO cache these, update on movement
	var/maxX = S.x + range
	var/minY = S.y - range
	var/maxY = S.y + range
	return (minX <= T.x && T.x <= maxX && minY <= T.y && T.y <= maxY)

/*
		INTERNAL
*/

/datum/sound_emitter/proc/activate()
	// expect active_key to be already set and validated
	if (!channel)
		channel = sound_channel_manager.reserve_channel(src)
		if (!channel)
			CRASH("Sound emitter was unable to reserve a channel for sound [sounds[active_key].file]")
		sound_zone_manager.register_emitter(src)
		init_hearers()
	update_hearers()

/datum/sound_emitter/proc/deactivate()
	if (!channel)
		CRASH("Tried to deactivate a SOUND_EMITTER with no channel")
	sound_zone_manager.unregister_emitter(src)
	active_key = null
	update_hearers()
	release_channel()
	hearers.Cut()

/datum/sound_emitter/proc/release_channel()
	if (!channel)
		return
	sound_channel_manager.release_channel(channel, src)
	channel = null

/datum/sound_emitter/proc/send_nearby_norepeat(var/sound/s, var/interrupt = FALSE)
	if (debug)
		world.log << "Sound emitter send_nearby_norepeat called with sound [s.file]"

	var/sound/S = copy_sound(s)
	S.atom = source
	//apply_env_effects(S)

	for (var/mob/player in players_in_range())
		send_norepeat(player, S, interrupt)

/datum/sound_emitter/proc/send_norepeat(var/mob/player, var/sound/s, var/interrupt = FALSE)
	if(!player || !player.client)
		return

	if(player.is_deaf())
		// TODO - when a player is deafened, play null sound on all their sound channels to flush anything still looping
		return

	apply_player_effects(s, player)

	if (interrupt)
		var/sound/nullsound = sound(file = null, repeat = 0, wait = 0, channel = s.channel)
		if (debug)
			world.log << "Sound emitter send_norepeat interrupting sound for [player] on channel [s.channel] with null sound."
		player << nullsound

	if (debug)
		world.log << "Sound emitter send_norepeat playing sound [s.file] for [player] on channel [s.channel] at volume [s.volume]"
	player << s

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
	S.channel = channel
	for (var/mob/player in hearers)
		player << S

/datum/sound_emitter/proc/apply_player_effects(sound/s, var/mob/player)

	if (player.ear_deaf > 0)
		s.volume = s.volume / (1 + player.ear_deaf)

	// loosely simulate some obstruction muffling the sound
	if (!(source in view(range, player))) // TODO cache this
		s.volume /= 5 // TODO this needs tuning

	// similarly if player is in spaced area and emitter is in non-spaced nearby, shouldn't hear it
	var/p_effect = turf_volume_coeff(player)
	s.volume *= p_effect

	return s

/datum/sound_emitter/proc/turf_volume_coeff(atom/a)
	if (!a)
		return 1 // ?:D?
	var/turf/t = get_turf(a)
	if (!t || !t.air)
		return 0 // no sound for the damned
	var/pressure = t.air.return_pressure()
	if (pressure < MIN_SOUND_PRESSURE)
		return 0 // also damned
	return min(pressure / ONE_ATMOSPHERE, 1)

/datum/sound_emitter/proc/update_params_for_player(mob/player)
	if (!channel || !active_key)
		return
	if (!(player in hearers))
		return
	var/sound/S = copy_sound(sounds[active_key])
	if (!S)
		CRASH("active_key not found in sounds")
	apply_player_effects(S, player)
	S.status |= SOUND_UPDATE
	player << S

/datum/sound_emitter/proc/players_in_range()
	var/list/in_range = list()
	var/turf/t_source = get_turf(source)
	if (debug)
		if (!t_source)
			world.log << "get_turf([source]) returned null"
		var/source_loc = source.loc
		if (!source_loc)
			world.log << "[source].loc returned null"
		else
			world.log << "[source].loc = [source_loc]"
	for (var/mob/player in player_list)
		if (!player || !player.client)
			continue
		var/turf/receiver = get_turf(player)
		if (!receiver)
			continue
		// lovingly stolen from sound.dm
		if (debug)
			var/list/oczl = GetOpenConnectedZlevels(t_source)
			world.log << "[oczl.len] open z levels from emitter"
		if((get_z_dist(receiver, t_source) <= range))
			in_range += player
		//for(var/z0 in GetOpenConnectedZlevels(t_source))
		//	if (receiver && t_source && receiver.z == z0)
		//		var/turf/portal/P1 = locate(/turf/portal) in receiver.vis_locs
		//		var/turf/portal/P2 = locate(/turf/portal) in t_source.vis_locs
		//		if (debug)
		//			var/zdist = get_z_dist(receiver, t_source)
		//			world.log << "zdist between player and emitter is [zdist]"
		//		if((get_z_dist(receiver, t_source) <= range) || (P1 && get_z_dist(P1, t_source) <= range) || (P2 && get_z_dist(receiver, P2) <= range) || (P1 && P2 && get_z_dist(P1, P2) <= range))
		//			in_range += player
	return in_range

// put this somewhere better than here
/proc/copy_sound(sound/s)
	if (!s)
		return
	var/sound/S = sound(s.file)
	S.atom = s.atom
	S.channel = s.channel
	S.frequency = s.frequency
	S.repeat = s.repeat
	S.status = s.status
	S.transform = s.transform
	S.volume = s.volume
	return S
