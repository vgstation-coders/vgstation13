#define STOP_PLAY_LINES \
	autorepeat = 0 ;\
	playing = 0 ;\
	current_line = 0 ;\
	return
	

/datum/synthesized_song
	var/list/lines = list()
	var/tempo = 5

	var/playing = 0
	var/autorepeat = 0
	var/current_line = 0

	var/datum/sound_player/player // Not a physical thing
	var/datum/instrument/instrument_data

	var/list/free_channels = list()

	var/linear_decay = 1
	var/sustain_timer = 11
	var/soft_coeff = 2.0
	var/transposition = 0

	var/octave_range_min
	var/octave_range_max


/datum/synthesized_song/New(datum/sound_player/playing_object, datum/instrument/instrument)
	player = playing_object
	instrument_data = instrument
	octave_range_min = global.musical_config.lowest_octave
	octave_range_max = global.musical_config.highest_octave

	instrument.create_full_sample_deviation_map()
	occupy_channels()


/datum/synthesized_song/proc/sanitize_tempo(new_tempo) // Identical to datum/song
	new_tempo = abs(new_tempo)
	return max(round(new_tempo, world.tick_lag), world.tick_lag)


/datum/synthesized_song/proc/occupy_channels()
	if (!global.musical_config.free_channels_populated)
		for (var/i=1 to 1024) // Currently only 1024 channels are allowed
			global.musical_config.free_channels += i
		global.musical_config.free_channels_populated = 1 // Only once

	for (var/i=1 to global.musical_config.channels_per_instrument)
		if (global.musical_config.free_channels.len)
			free_channel(pick_n_take(global.musical_config.free_channels))


/datum/synthesized_song/proc/take_any_channel()
	return pick_n_take(free_channels)


/datum/synthesized_song/proc/free_channel(channel)
	if (channel in free_channels) return
	free_channels += channel


/datum/synthesized_song/proc/return_all_channels()
	global.musical_config.free_channels |= free_channels
	free_channels.Cut()


/datum/synthesized_song/proc/play_synthesized_note(note, acc, oct, duration, where, which_one)
	if (oct < global.musical_config.lowest_octave || oct > global.musical_config.highest_octave)	return
	if (oct < octave_range_min || oct > octave_range_max)	return

	var/delta1 = acc == "b" ? -1 : acc == "#" ? 1 : acc == "s" ? 1 : acc == "n" ? 0 : 0
	var/delta2 = 12 * oct

	var/note_num = delta1+delta2+global.musical_config.nn2no[note]
	if (note_num < 0 || note_num > 127)
		CRASH("play_synthesized note failed because of 0..127 condition, [note], [acc], [oct]")

	var/datum/sample_pair/pair = instrument_data.sample_map[global.musical_config.n2t(note_num)]
	#define Q 0.083 // 1/12
	var/freq = 2**(Q*pair.deviation)
	var/chan = take_any_channel()
	if (!chan)
		if (!player.channel_overload())
			playing = 0
			autorepeat = 0
			return
	#undef Q
	var/list/mob/to_play_for = player.who_to_play_for()

	if (!to_play_for.len)
		free_channel(chan) // I'm an idiot, fuck
		return

	for (var/mob/hearer in to_play_for)
		play_for(hearer, pair.sample, duration, freq, chan, note_num, where, which_one)


/datum/synthesized_song/proc/play_for(mob/who, what, duration, frequency, channel, which, where, which_one)
	var/sound/sound_copy = sound(what)
	sound_copy.wait = 0
	sound_copy.repeat = 0
	sound_copy.frequency = frequency
	sound_copy.channel = channel
	player.apply_modifications_for(who, sound_copy, which, where, which_one)

	who << sound_copy
	#if DM_VERSION < 511
	sound_copy.frequency = 1
	#endif

	var/delta_volume = player.volume / sustain_timer
	var/current_volume = max(round(sound_copy.volume), 0)
	var/tick = duration
	while (current_volume > 0)
		var/new_volume = current_volume
		tick += world.tick_lag
		if (delta_volume <= 0)
			CRASH("Delta Volume somehow was non-positive: [delta_volume]")
		if (soft_coeff <= 1)
			CRASH("Soft Coeff somehow was <=1: [soft_coeff]")

		if (linear_decay)
			new_volume = new_volume - delta_volume
		else
			new_volume = new_volume / soft_coeff

		var/sanitized_volume = max(round(new_volume), 0)
		if (sanitized_volume == current_volume)
			current_volume = new_volume
			continue
		current_volume = sanitized_volume
		SSmusic.push_event(player, who, sound_copy, tick, current_volume)
		if (current_volume <= 0)
			break


#define CP(L, S) copytext(L, S, S+1)
#define IS_DIGIT(L) (L >= "0" && L <= "9" ? 1 : 0)

/datum/synthesized_song/proc/play_song(mob/user)
	// This code is really fucking horrible.
	player.cache_unseen_tiles()
	var/list/allowed_suff = list("b", "n", "#", "s")
	var/list/note_off_delta = list("a"=91, "b"=91, "c"=98, "d"=98, "e"=98, "f"=98, "g"=98)
	var/list/lines_copy = lines.Copy()
	spawn()
		if (!lines.len)
			STOP_PLAY_LINES
		var/list/cur_accidentals = list("n", "n", "n", "n", "n", "n", "n")
		var/list/cur_octaves = list(3, 3, 3, 3, 3, 3, 3)
		current_line = 1
		for (var/line in lines_copy)
			var/cur_note = 1
			for (var/notes in splittext(lowertext(line), ","))
				var/list/components = splittext(notes, "/")
				var/duration = sanitize_tempo(tempo)
				if (components.len)
					var/delta = components.len==2 && text2num(components[2]) ? text2num(components[2]) : 1
					var/note_str = splittext(components[1], "-")

					duration = sanitize_tempo(tempo / delta)
					for (var/note in note_str)
						if (!note)	continue // wtf, empty note
						var/note_sym = CP(note, 1)
						var/note_off = 0
						if (note_sym in note_off_delta)
							note_off = text2ascii(note_sym) - note_off_delta[note_sym]
						else
							continue // Shitty note, move along and avoid runtimes

						var/octave = cur_octaves[note_off]
						var/accidental = cur_accidentals[note_off]

						switch (length(note))
							if (3)
								accidental = CP(note, 2)
								octave = CP(note, 3)
								if (!(accidental in allowed_suff) || !IS_DIGIT(octave))
									continue
								else
									octave = text2num(octave)
							if (2)
								if (IS_DIGIT(CP(note, 2)))
									octave = text2num(CP(note, 2))
								else
									accidental = CP(note, 2)
									if (!(accidental in allowed_suff))
										continue
						cur_octaves[note_off] = octave
						cur_accidentals[note_off] = accidental
						play_synthesized_note(note_off, accidental, octave+transposition, duration, current_line, cur_note)
						if (SSmusic.is_overloaded())
							STOP_PLAY_LINES
				cur_note++
				if (!playing || player.shouldStopPlaying(user))
					STOP_PLAY_LINES
				sleep(duration)
			current_line++
		if (autorepeat)
			.()
		else
			STOP_PLAY_LINES


#undef CP
#undef IS_DIGIT
#undef STOP_PLAY_LINES