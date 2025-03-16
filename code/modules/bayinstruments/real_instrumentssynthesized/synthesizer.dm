/datum/sound_player/synthesizer
	forced_sound_in = 0
	var/list/datum/music_code/code = list()


/datum/sound_player/synthesizer/apply_modifications_for(mob/who, sound/what, which, where, which_one)
	..(who, what, which)
	for (var/datum/music_code/cond in code)
		if (cond.test(which, where, which_one))
			var/datum/sample_pair/pair = cond.instrument.sample_map[global.musical_config.n2t(which)]
			what.file = pair.sample


#define LESSER 1
#define EQUAL 2
#define GREATER_MUSIC 3
#define COMPARE(alpha, beta) ((alpha)<(beta) ? LESSER : (alpha)==(beta) ? EQUAL : GREATER_MUSIC)

/datum/music_code
	var/octave = null
	var/octave_condition = null
	var/line_num = null
	var/line_condition = null
	var/line_note_num = null
	var/line_note_condition = null
	var/datum/instrument/instrument = null


/datum/music_code/proc/test(note_num, line_num, line_note_num)
	var/result = 1
	if (octave!=null && octave_condition)
		var/cur_octave = round(note_num * 0.083)
		if (COMPARE(cur_octave, octave) != octave_condition)
			result = 0
	if (line_num && line_condition)
		if (COMPARE(line_num, line_num) != line_condition)
			result = 0
	if (line_note_num && line_note_condition)
		if (COMPARE(line_num, line_note_num) != line_note_condition)
			result = 0
	return result


/datum/music_code/proc/octave_code()
	if (octave!=null)
		var/sym = ""
		switch(octave_condition)
			if(LESSER)
				sym = "<"
			if(EQUAL)
				sym = "="
			if(GREATER_MUSIC)
				sym = ">"
			else
				sym = null
		return "O[sym][octave]"
	return ""


/datum/music_code/proc/line_num_code()
	if (line_num)
		var/sym = ""
		switch(line_condition)
			if(LESSER)
				sym = "<"
			if(EQUAL)
				sym = "="
			if(GREATER_MUSIC)
				sym = ">"
			else
				sym = null
		return "L[sym][line_num]"
	return ""


/datum/music_code/proc/line_note_num_code()
	if (line_note_num)
		var/sym = ""
		switch(line_note_condition)
			if(LESSER)
				sym = "<"
			if(EQUAL)
				sym = "="
			if(GREATER_MUSIC)
				sym = ">"
			else
				sym = null
		return "N[sym][line_note_num]"
	return ""



#undef LESSER
#undef EQUAL
#undef GREATER_MUSIC
#undef COMPARE

/obj/structure/synthesized_instrument/synthesizer
	name = "The Synthesizer 3.0"
	desc = "This is the hottest new synth around! With new sounds!"
	icon = 'icons/obj/musician.dmi'
	icon_state = "nusynth"
	anchored = 0
	density = 1
	var/list/instruments = list()

/obj/structure/synthesized_instrument/synthesizer/New()
	..()
	for (var/type in typesof(/datum/instrument))
		var/datum/instrument/new_instrument = new type
		if (!new_instrument.id) continue
		new_instrument.create_full_sample_deviation_map()
		instruments[new_instrument.name] = new_instrument
	player = new /datum/sound_player/synthesizer(src, instruments[pick(instruments)])
	icon_state = pick("nusynth","nusynth2","nusynth3")


/obj/structure/synthesized_instrument/synthesizer/attackby(obj/item/O, mob/user, params)
	if (iswrench(O))
		if (!anchored )//&& !isinspace())
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			to_chat(usr, "<span class='notice'> You begin to tighten \the [src] to the floor...</span>")
			user.visible_message( \
				"[user] tightens \the [src]'s casters.", \
				"<span class='notice'> You tighten \the [src]'s casters. Now it can be played again.</span>", \
				"<span class='italics'>You hear ratchet.</span>")
			anchored = 1
		else if(anchored)
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			to_chat(usr, "<span class='notice'> You begin to loosen \the [src]'s casters...</span>")
			user.visible_message( \
				"[user] loosens \the [src]'s casters.", \
				"<span class='notice'> You loosen \the [src]. Now it can be pulled somewhere else.</span>", \
				"<span class='italics'>You hear ratchet.</span>")
			anchored = 0
	else
		..()


/obj/structure/synthesized_instrument/synthesizer/proc/compose_code(var/html=0)
	var/code = ""
	var/line_number = 1
	if (player:code:len)
		// Find instruments involved and create a list of statements
		var/list/list/datum/music_code/statements = list() // Instruments involved
		for (var/datum/music_code/this_code in player:code)
			if (statements[this_code.instrument.id])
				statements[this_code.instrument.id] += this_code
			else
				statements[this_code.instrument.id] = list(this_code)

		// Each instrument statement is split by ;\n or ;<br> in this case
		// Each statement is in parenthesises and separated by |
		// Statements have up to 3 conditions separated by &

		for (var/instrument_id in statements)
			var/conditions = ""
			for (var/datum/music_code/cond in statements[instrument_id])
				var/sub_code = "("
				var/octave_code = cond.octave_code()
				var/line_code = cond.line_num_code()
				var/line_note_code = cond.line_note_num_code()
				sub_code += octave_code ? octave_code+"|" : ""
				sub_code += line_code ? line_code + "|" : ""
				sub_code += line_note_code
				sub_code = copytext(sub_code, 1, -1)
				sub_code += ")"
				conditions = sub_code + " & "
			conditions = copytext(conditions, 1, -3)
			code = code + (html ? "[line_number]: " : "") + conditions + " -> " + (instrument_id + (html ? "<br>" : "\n"))
			line_number++
	return code


/obj/structure/synthesized_instrument/synthesizer/proc/decompose_code(code, mob/blame)
	if (length(code) > 10000)
		to_chat(blame, "This code is WAAAAY too long.")
		return
	code = replacetext(code, " ", "")
	code = replacetext(code, "(", "")
	code = replacetext(code, ")", "")

	var/list/instruments_ids = list()
	var/list/datum/instrument/instruments_by_id = list()
	for (var/ins in instruments)
		var/datum/instrument/instr = instruments[ins]
		instruments_by_id[instr.id] = instr
		instruments_ids += instr.id

	var/line = 1
	var/list/datum/music_code/conditions = list()
	for (var/super_statement in splittext(code, "\n"))
		var/list/delta = splittext(super_statement, "->")
		if (delta.len==0)
			to_chat(blame, "Line [line]: Empty super statement")
			return
		if (delta.len==1)
			to_chat(blame, "Line [line]: Not enough parameters in super statement")
			return
		if (delta.len>2)
			to_chat(blame, "Line [line]: Too many parameters in super statement")
			return
		var/id = delta[2]
		if (!(id in instruments_ids))
			to_chat(blame, "Line [line]: Unknown ID. [id]")
			return

		for (var/statements in splittext(delta[1], "|"))
			var/datum/music_code/new_condition = new

			for (var/property in splittext(statements, "&"))
				if (length(property) < 3)
					to_chat(blame, "Line [line]: Invalid property [property]")
					return
				var/variable = copytext(property, 1, 2)
				if (variable != "O" && variable != "N" && variable != "L")
					to_chat(blame, "Line [line]: Unknown variable [variable] in [property]")
					return
				var/operator = copytext(property, 2, 3)
				if (operator != "<" && operator != ">" && operator != "=")
					to_chat(blame, "Line [line]: Unknown operator [operator] in [property]")
					return
				var/list/que = splittext(property, operator)
				var/value = que[2]
				operator = operator=="<" ? 1 : operator=="=" ? 2 : 3
				if (num2text(text2num(value)) != value)
					to_chat(blame, "Line [line]: Invalid value [value] in [property]")
					return
				value = text2num(value)
				switch(variable)
					if ("O")
						new_condition.octave = value
						new_condition.octave_condition = operator
					if ("N")
						new_condition.line_note_num = value
						new_condition.line_note_condition = operator
					if ("L")
						new_condition.line_num = value
						new_condition.line_condition = operator
			new_condition.instrument = instruments_by_id[id]
			conditions += new_condition
		line++
	player:code = conditions


/obj/structure/synthesized_instrument/synthesizer/ui_interact(mob/user, ui_key = "instrument", var/datum/nanoui/ui = null, var/force_open = 0)
	var/list/data
	data = list(
		"playback" = list(
			"playing" = player.song.playing,
			"autorepeat" = player.song.autorepeat,
			"three_dimensional_sound" = player.three_dimensional_sound
		),
		"basic_options" = list(
			"cur_instrument" = player.song.instrument_data.name,
			"volume" = player.volume,
			"BPM" = round(600 / player.song.tempo),
			"transposition" = player.song.transposition,
			"octave_range" = list(
				"min" = player.song.octave_range_min,
				"max" = player.song.octave_range_max
			)
		),
		/*"advanced_options" = list(
			"all_environments" = global.musical_config.all_environments,
			"selected_environment" = global.musical_config.id_to_environment(player.virtual_environment_selected),
			"apply_echo" = player.apply_echo
		),*/
		"sustain" = list(
			"linear_decay_active" = player.song.linear_decay,
			"sustain_timer" = player.song.sustain_timer,
			"soft_coeff" = player.song.soft_coeff
		),
		/*
		"code" = list(
			"code" = compose_code(html=1),
		),*/
		"show" = list(
			"playback" = player.song.lines.len > 0
		)
		/*	"custom_env_options" = global.musical_config.is_custom_env(player.virtual_environment_selected) && player.three_dimensional_sound,
			"debug_button" = global.musical_config.debug_active,
			"env_settings" = global.musical_config.env_settings_available
		),

		"status" = list(
			"channels" = player.song.free_channels.len,
			"events" = player.event_manager.events.len,
			"max_channels" = global.musical_config.channels_per_instrument,
			"max_events" = global.musical_config.max_events,
		)*/
	)
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "synthesizer.tmpl", name, 600, 500)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/structure/synthesized_instrument/synthesizer/Topic(href, href_list)
	if (..())
		return 1

	var/target = href_list["target"]
	var/value = text2num(href_list["value"])
	if (href_list["value"] && !isnum(value))
		to_chat(usr, "Non-numeric value was supplied")
		return 0

	switch (target)
		if ("volume")
			player.volume = max(min(player.volume+text2num(value), 100), 0)
		if ("transposition")
			player.song.transposition = max(min(player.song.transposition+value, global.musical_config.highest_transposition), global.musical_config.lowest_transposition)
		if ("min_octave")
			player.song.octave_range_min = max(min(player.song.octave_range_min+value, global.musical_config.highest_octave), global.musical_config.lowest_octave)
			player.song.octave_range_max = max(player.song.octave_range_max, player.song.octave_range_min)
		if ("max_octave")
			player.song.octave_range_max = max(min(player.song.octave_range_max+value, global.musical_config.highest_octave), global.musical_config.lowest_octave)
			player.song.octave_range_min = min(player.song.octave_range_max, player.song.octave_range_min)
		if ("sustain_timer")
			player.song.sustain_timer = max(min(player.song.sustain_timer+value, global.musical_config.longest_sustain_timer), 1)
		if ("soft_coeff")
			var/new_coeff = input(usr, "from [global.musical_config.gentlest_drop] to [global.musical_config.steepest_drop]") as num
			new_coeff = round(min(max(new_coeff, global.musical_config.gentlest_drop), global.musical_config.steepest_drop), 0.001)
			player.song.soft_coeff = new_coeff
		if ("instrument")
			var/list/categories = list()
			for (var/key in instruments)
				var/datum/instrument/instrument = instruments[key]
				categories |= instrument.category

			var/category = input(usr, "Choose a category") in categories 
			var/list/instruments_available = list()
			for (var/key in instruments)
				var/datum/instrument/instrument = instruments[key]
				if (instrument.category == category)
					instruments_available += key

			var/new_instrument = input(usr, "Choose an instrument") in instruments_available
			if (new_instrument)
				player.song.instrument_data = instruments[new_instrument]
		if ("3d_sound") player.three_dimensional_sound = value
		if ("autorepeat") player.song.autorepeat = value
		if ("decay") player.song.linear_decay = value
		if ("echo") player.apply_echo = value
		if ("select_env")
			if (value in -1 to 26)
				player.virtual_environment_selected = round(value)
		/*
		if ("show_code_editor") coding = value
		if ("show_ids") showing_ids = value
		if ("show_code_help") coding_help = value
		if ("edit_code")
			var/new_code = input(usr, "Program code", "Coding", compose_code()) as message
			decompose_code(new_code, usr)
		*/

	return 1


/obj/structure/synthesized_instrument/synthesizer/shouldStopPlaying(mob/user)
	return !((src && in_range(src, user) && anchored) || player.song.autorepeat)
