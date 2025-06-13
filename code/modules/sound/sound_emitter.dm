/datum/sound_emitter
	var/atom/source
	var/list/sounds = list()
	var/active_key = null
	var/channel = null
	var/list/hearers = list()
	var/range = 7

/datum/sound_emitter/New(atom/s)
	..()
	source = s

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
	. = ..()
	range = world.view / 2

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
		world.log << "Sound emitter play called for key [key] on channel [channel], but sound does not exist."
		return

	if (S.repeat == 1)
		// looping sounds need channel reservation so they can be stopped later
		if (!channel)
			channel = sound_channel_manager.reserve_channel(src)
			if (!channel)
				world.log << "Sound emitter could not reserve channel for sound [S.file]."
				return
		S.channel = channel
		active_key = key
		// dispatch to hearers handled by SSsounds
	else
		// non-looping sounds do not need a channel reservation
		// just send it
		for (var/mob/player in hearers)
			send_sound_norepeat(player, S)


/datum/sound_emitter/proc/send_sound_norepeat(var/mob/player, var/sound/s, var/interrupt = FALSE)
	world.log << "Sound emitter send_sound called for [player] on channel [s.channel] with sound [s.file]"
	if(!player || !player.client)
		return

	if(player.is_deaf())
		// TODO - when a player is deafened, play null sound on all their sound channels to flush anything still looping
		// ask the SOUND CONTROLLER to do this?
		return

	if (interrupt)
		var/sound/nullsound = sound(file = null, repeat = 0, wait = 0, channel = s.channel)
		world.log << "Sound emitter interrupting sound for [player] on channel [s.channel] with null sound."
		player << nullsound

	world.log << "Sound emitter playing sound [s.file] for [player] on channel [s.channel] at volume [s.volume]"
	player << s

/datum/sound_emitter/proc/stop()
	if (!channel)
		return

	for (var/mob/player in hearers)
		var/sound/nullsound = sound(file = null, repeat = 0, wait = 0, channel = channel)
		nullsound.status = SOUND_UPDATE | SOUND_MUTE
		world.log << "Sound emitter stopping sound for [player] on channel [channel]"
		player << nullsound
		//player.client.audible_channels -= channel
	hearers.Cut()
	release_channel()

/datum/sound_emitter/proc/release_channel()
	if (!channel)
		return
	sound_channel_manager.release_channel(channel, src)
	channel = null
	active_key = null

/datum/sound_emitter/proc/update_sound_params(volume = null, pitch = null)
	if (!channel || !active_key)
		return
	var/sound/S = sounds[active_key]
	if (!S)
		world.log << "Sound emitter update_sound_params called for key [active_key] on channel [channel], but sound does not exist."
		return
	if (volume != null)
		S.volume = volume
	if (pitch != null)
		S.pitch = pitch
	S.status |= SOUND_UPDATE
	for (var/mob/player in hearers)
		player << S
		//if (player.client && channel)
			//player.client.audible_channels |= channel

/datum/sound_emitter/proc/update_hearers(list/nearby)
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
			player << S
			//player.client.audible_channels[channel] = src

	for (var/mob/player in lost_hearers)
		var/sound/nullsound = sound(file = null)
		nullsound.channel = channel
		nullsound.status = SOUND_UPDATE | SOUND_MUTE
		player << nullsound
		//player.client.audible_channels -= channel

	hearers = nearby.Copy()