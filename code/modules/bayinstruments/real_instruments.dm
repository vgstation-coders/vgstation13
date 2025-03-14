/obj/structure/synthesized_instrument
	var/datum/sound_player/player
	var/datum/nano_module/song_editor/song_editor
	var/datum/nano_module/usage_info/usage_info
	var/maximum_lines
	var/maximum_line_length


/obj/structure/synthesized_instrument/New()
	..()
	maximum_lines = global.musical_config.max_lines
	maximum_line_length = global.musical_config.max_line_length


/obj/structure/synthesized_instrument/Destroy()
	qdel(player)
	..()


/obj/structure/synthesized_instrument/attack_hand(mob/user)
	interact(user)


/obj/structure/synthesized_instrument/interact(mob/user) // CONDITIONS ..(user) that shit in subclasses
	ui_interact(user)


/obj/structure/synthesized_instrument/ui_interact(mob/user)
	return 0


/obj/structure/synthesized_instrument/proc/shouldStopPlaying(mob/user)
	return 0


/obj/structure/synthesized_instrument/Topic(href, href_list)
	if (..())
		return 1

	var/target = href_list["target"]
	var/value = text2num(href_list["value"])
	if (href_list["value"] && !isnum(value))
		to_chat(usr, "Non-numeric value was given")
		return 0

	add_fingerprint(usr)

	switch (target)
		if ("tempo") player.song.tempo = player.song.sanitize_tempo(player.song.tempo + value*world.tick_lag)
		if ("play")
			player.song.playing = value
			if (player.song.playing)
				player.song.play_song(usr)
		if ("newsong")
			player.song.lines.Cut()
			player.song.tempo = player.song.sanitize_tempo(5) // default 120 BPM
		if ("import")
			var/t = ""
			do
				t = html_encode(input(usr, "Please paste the entire song, formatted:", text("[]", name), t)  as message)
				if(!in_range(src, usr))
					return

				if(length(t) >= 2*maximum_lines*maximum_line_length)
					var/cont = input(usr, "Your message is too long! Would you like to continue editing it?", "", "yes") in list("yes", "no")
					if(cont == "no")
						break
			while(length(t) > 2*maximum_lines*maximum_line_length)
			if (length(t))
				player.song.lines = splittext(t, "\n")
				if(copytext(player.song.lines[1],1,6) == "BPM: ")
					if(text2num(copytext(player.song.lines[1],6)) != 0)
						player.song.tempo = player.song.sanitize_tempo(600 / text2num(copytext(player.song.lines[1],6)))
						player.song.lines.Cut(1,2)
					else
						player.song.tempo = player.song.sanitize_tempo(5)
				else
					player.song.tempo = player.song.sanitize_tempo(5) // default 120 BPM
				if(player.song.lines.len > maximum_lines)
					to_chat(usr,"Too many lines!")
					player.song.lines.Cut(maximum_lines+1)
				var/linenum = 1
				for(var/l in player.song.lines)
					if(length(l) > maximum_line_length)
						to_chat(usr, "Line [linenum] too long!")
						player.song.lines.Remove(l)
					else
						linenum++
		else
			return 0

	return 1



/obj/item/device/synthesized_instrument
	var/datum/sound_player/player
	var/datum/nano_module/song_editor/song_editor
	var/datum/nano_module/usage_info/usage_info
	var/maximum_lines
	var/maximum_line_length


/obj/item/device/synthesized_instrument/New()
	..()
	maximum_lines = global.musical_config.max_lines
	maximum_line_length = global.musical_config.max_line_length


/obj/item/device/synthesized_instrument/Destroy()
	qdel(player)
	..()


/obj/item/device/synthesized_instrument/attack_hand(mob/user)
	interact(user)


/obj/item/device/synthesized_instrument/interact(mob/user) // CONDITIONS ..(user) that shit in subclasses
	ui_interact(user)

/obj/item/device/synthesized_instrument/ui_interact(mob/user)
	return 0


/obj/item/device/synthesized_instrument/proc/shouldStopPlaying(mob/user)
	return 0


/obj/item/device/synthesized_instrument/Topic(href, href_list)
	if (..())
		return 1

	var/target = href_list["target"]
	var/value = text2num(href_list["value"])
	if (href_list["value"] && !isnum(value))
		to_chat(usr, "Non-numeric value was given")
		return 0

	add_fingerprint(usr)

	switch (target)
		if ("tempo") player.song.tempo = player.song.sanitize_tempo(player.song.tempo + value*world.tick_lag)
		if ("play")
			player.song.playing = value
			if (player.song.playing)
				player.song.play_song(usr)
		if ("newsong")
			player.song.lines.Cut()
			player.song.tempo = player.song.sanitize_tempo(5) // default 120 BPM
		if ("import")
			var/t = ""
			do
				t = html_encode(input(usr, "Please paste the entire song, formatted:", text("[]", name), t)  as message)
				if(!in_range(src, usr))
					return

				if(length(t) >= 2*maximum_lines*maximum_line_length)
					var/cont = input(usr, "Your message is too long! Would you like to continue editing it?", "", "yes") in list("yes", "no")
					if(cont == "no")
						break
			while(length(t) > 2*maximum_lines*maximum_line_length)
			if (length(t))
				player.song.lines = splittext(t, "\n")
				if(copytext(player.song.lines[1],1,6) == "BPM: ")
					if(text2num(copytext(player.song.lines[1],6)) != 0)
						player.song.tempo = player.song.sanitize_tempo(600 / text2num(copytext(player.song.lines[1],6)))
						player.song.lines.Cut(1,2)
					else
						player.song.tempo = player.song.sanitize_tempo(5)
				else
					player.song.tempo = player.song.sanitize_tempo(5) // default 120 BPM
				if(player.song.lines.len > maximum_lines)
					to_chat(usr, "Too many lines!")
					player.song.lines.Cut(maximum_lines+1)
				var/linenum = 1
				for(var/l in player.song.lines)
					if(length(l) > maximum_line_length)
						to_chat(usr, "Line [linenum] too long!")
						player.song.lines.Remove(l)
					else
						linenum++
		else
			return 0

	return 1