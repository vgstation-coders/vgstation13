/datum/sound_emitter
	var/atom/source = null
	var/list/sounds = list()
	var/active_key = null
	var/channel = null
	var/list/hearers = list()
	var/range = 7

	var/debug = FALSE

/datum/sound_emitter/New(atom/s)
	..()
	source = s
	range = world.view
	SSsounds.register(src)

/datum/sound_emitter/Destroy()
	if (sounds)
		sounds.Cut()
		sounds = null
	if (channel && channel != null)
		stop()
		release_channel()
	hearers.Cut()
	source = null
	active_key = null
	SSsounds.unregister(src)
	. = ..()

/datum/sound_emitter/proc/add(sound/s, var/key)
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
		CRASH("Sound emitter play called for key [key] on channel [channel], but sound does not exist.")

	if (S.repeat == 1)
		// looping sounds need channel reservation so they can be stopped later
		if (!channel)
			channel = sound_channel_manager.reserve_channel(src)
			if (!channel)
				CRASH("Sound emitter could not reserve channel for sound [S.file].")
		SSsounds.register_repeating_emitter(src)
		S.channel = channel
		active_key = key
		// dispatch to hearers handled by SSsounds
	else
		// non-looping sounds do not need a channel reservation
		// just send it
		send_nearby_norepeat(S)

/datum/sound_emitter/proc/apply_env_effects(sound/s)

	// if an emitter is behind glass in a spaced area, listener shouldnt magically hear it in non-spaced nearby area
	var/p_effect = turf_volume_coeff(s.atom)
	s.volume *= p_effect

	return s

/datum/sound_emitter/proc/apply_player_effects(sound/s, var/mob/player)

	if (player.ear_deaf > 0)
		s.volume = s.volume / (1 + player.ear_deaf)

	// loosely simulate some obstruction muffling the sound
	if (!(source in view(range, player))) // TODO cache this
		s.volume /= 5 // TODO this needs tuning

	// similarly if player is in spaced area and emitter is in non-spaced nearby, shouldn't hear it
	var/p_effect = turf_volume_coeff(s.atom)
	s.volume *= p_effect

	return s

/datum/sound_emitter/proc/turf_volume_coeff(atom/a)
	if (!a)
		return 1 // ?:D?
	var/turf/t = get_turf(a)
	if (!t)
		return 0 // no sound for the damned
	var/datum/gas_mixture/environment = t.return_air()
	var/atm = 0
	if (environment)
		atm = environment.return_pressure()
	if (atm < MIN_SOUND_PRESSURE)
		return 0 // also damned
	return min(atm / ONE_ATMOSPHERE, 1)

/datum/sound_emitter/proc/send_nearby_norepeat(var/sound/s, var/interrupt = FALSE)
	if (debug)
		world.log << "Sound emitter send_nearby_norepeat called with sound [s.file]"

	var/sound/S = copy_sound(s)
	S.atom = source
	apply_env_effects(S)

	for (var/mob/player in players_in_range())
		send_norepeat(player, S, interrupt)

/datum/sound_emitter/proc/send_norepeat(var/mob/player, var/sound/s, var/interrupt = FALSE)
	if(!player || !player.client)
		return

	if(player.is_deaf())
		// TODO - when a player is deafened, play null sound on all their sound channels to flush anything still looping
		// ask the SOUND CONTROLLER to do this?
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

/datum/sound_emitter/proc/stop()
	if (!channel)
		return

	for (var/mob/player in hearers)
		var/sound/nullsound = sound(file = null, repeat = 0, wait = 0, channel = channel)
		nullsound.status = SOUND_UPDATE | SOUND_MUTE
		if (debug)
			world.log << "Sound emitter stopping sound for [player] on channel [channel]"
		player << nullsound
		//player.client.audible_channels -= channel
	hearers.Cut()
	release_channel()
	SSsounds.unregister_repeating_emitter(src)

/datum/sound_emitter/proc/release_channel()
	if (!channel)
		return
	sound_channel_manager.release_channel(channel, src)
	channel = null
	active_key = null

/datum/sound_emitter/proc/update_sound_params()
	if (!channel || !active_key)
		return
	var/sound/S = copy_sound(sounds[active_key])
	if (!S)
		CRASH("Sound emitter update_sound_params called for key [active_key] on channel [channel], but sound does not exist.")

	apply_env_effects(S)
	S.status |= SOUND_UPDATE
	for (var/mob/player in hearers)
		var/sound/Stwo = apply_player_effects(copy_sound(S), player)
		player << Stwo
		//if (player.client && channel)
			//player.client.audible_channels |= channel

/datum/sound_emitter/proc/add_hearer(mob/player)
	hearers |= player
	if (channel && active_key)
			var/sound/S = sounds[active_key]
			if (!S)
				world.log << "Sound emitter update_hearers called for key [active_key] on channel [channel], but sound does not exist."
				continue
			S.status &= ~SOUND_UPDATE // clear update status for new hearers, else they cant hear it lmao
			S.channel = channel
			if (debug)
				world.log << "Sending sound to [player]: [S.file] V: [S.volume] C: [S.channel]"
			player << S
			//player.client.audible_channels[channel] = src

/datum/sound_emitter/proc/remove_hearer(mob/player)
	hearers -= player
	var/sound/nullsound = sound(file = null)
		nullsound.channel = channel
		nullsound.status = SOUND_UPDATE | SOUND_MUTE
		if (debug)
			world.log << "Stopping sound for [player] on channel [channel]"
		player << nullsound
		//player.client.audible_channels -= channel

/datum/sound_emitter/proc/update_hearers()
	var/list/nearby = players_in_range()

	var/list/new_hearers = nearby - hearers
	var/list/lost_hearers = hearers - nearby

	for (var/mob/player in new_hearers)
		if (channel && active_key)
			var/sound/S = sounds[active_key]
			if (!S)
				world.log << "Sound emitter update_hearers called for key [active_key] on channel [channel], but sound does not exist."
				continue
			S.status &= ~SOUND_UPDATE // clear update status for new hearers, else they cant hear it lmao
			S.channel = channel
			if (debug)
				world.log << "Sending sound to [player]: [S.file] V: [S.volume] C: [S.channel]"
			player << S
			//player.client.audible_channels[channel] = src

	for (var/mob/player in lost_hearers)
		var/sound/nullsound = sound(file = null)
		nullsound.channel = channel
		nullsound.status = SOUND_UPDATE | SOUND_MUTE
		if (debug)
			world.log << "Stopping sound for [player] on channel [channel]"
		player << nullsound
		//player.client.audible_channels -= channel

	hearers = nearby.Copy()

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
		// lovingly stolen from sound.dm
		if (debug)
			var/list/oczl = GetOpenConnectedZlevels(t_source)
			world.log << "[oczl.len] open z levels from emitter"
		for(var/z0 in GetOpenConnectedZlevels(t_source))
			if (receiver && t_source && receiver.z == z0)
				var/turf/portal/P1 = locate(/turf/portal) in receiver.vis_locs
				var/turf/portal/P2 = locate(/turf/portal) in t_source.vis_locs
				if (debug)
					var/zdist = get_z_dist(receiver, t_source)
					world.log << "zdist between player and emitter is [zdist]"
				if((get_z_dist(receiver, t_source) <= range) || (P1 && get_z_dist(P1, t_source) <= range) || (P2 && get_z_dist(receiver, P2) <= range) || (P1 && P2 && get_z_dist(P1, P2) <= range))
					in_range += player
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