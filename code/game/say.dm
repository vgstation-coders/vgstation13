var/global/nextDecTalkDelay = 5 //seconds
var/global/lastDecTalkUse = 0

/proc/dectalk(msg)
	if(!msg)
		return 0
	if (world.timeofday > (lastDecTalkUse + (nextDecTalkDelay * 10)))
		lastDecTalkUse = world.timeofday
		msg = copytext(msg, 1, 2000)
		var/res[] = world.Export("[config.tts_server]?tts=[url_encode(msg)]")
		//var/res[] = world.Export("http://localhost:1203/?tts=[url_encode(msg)]") //change server
		if(!res || !res["CONTENT"])
			return 0

		var/audio = file2text(res["CONTENT"])
		return list("audio" = audio, "message" = msg)
	else
		return list("cooldown" = 1)

/*
 	Miauw's big Say() rewrite.
	This file has the basic atom/movable level speech procs.
	And the base of the send_speech() proc, which is the core of saycode.
*/

/atom/movable/proc/say(message, var/datum/language/speaking, var/atom/movable/radio=src, var/class) //so we can force nonmobs to speak a certain language
	if(!can_speak())
		return
	if(message == "" || !message)
		return
	var/datum/speech/speech = create_speech(message, null, radio)
	speech.language=speaking
	if(class)
		speech.message_classes.Add(class)
	send_speech(speech, world.view)
	qdel(speech)

/atom/movable/proc/Hear(var/datum/speech/speech, var/rendered_speech="")
	return

/atom/movable/proc/can_speak()
	return 1

/atom/movable/proc/send_speech(var/datum/speech/speech, var/range=7, var/bubble_type)
	say_testing(src, "/atom/movable/proc/send_speech() start, msg = [speech.message]; message_range = [range]; language = [speech.language ? speech.language.name : "None"];")
	if(isnull(range))
		range = 7
	range = atmospheric_speech(speech,range)
	var/rendered = render_speech(speech)
	var/list/listeners = get_hearers_in_view(range, src)
	if(speech.speaker.GhostsAlwaysHear())
		listeners |= observers
	for(var/atom/movable/AM in listeners)
		AM.Hear(speech, rendered)
	send_speech_bubble(speech.message, bubble_type, listeners)

/atom/movable/proc/atmospheric_speech(var/datum/speech/speech, var/range=7)
	var/turf/T = get_turf(speech.speaker)
	if(T && !T.c_airblock(T)) //we are on an airflowing tile
		var/atmos = 0
		var/datum/gas_mixture/current_air = T.return_air()
		if(current_air)
			atmos = round(current_air.return_pressure()/ONE_ATMOSPHERE, 0.1)
		else
			atmos = 0 //no air

		range = min(round(range * sqrt(atmos)), range) //Range technically falls off with the root of pressure (see Newtonian sound)
		range = max(range, 1) //If you get right next to someone you can read their lips, or something.
		/*Rough range breakpoints for default 7-range speech
		10kpa: 0 (round 0.09 down to 0 for atmos value)
		11kpa: 2
		21kpa: 3
		51kpa: 4
		61kpa: 5
		81kpa: 6
		101kpa: 7 (normal)
		*/

	return range

/atom/movable/proc/GhostsAlwaysHear()
	return FALSE

/atom/movable/proc/create_speech(var/message, var/frequency=0, var/atom/movable/transmitter=null)
	if(!transmitter)
		transmitter=GetDefaultRadio()
	var/datum/speech/speech = new /datum/speech
	speech.message = message
	speech.frequency = frequency
	speech.job = get_job(speech)
	speech.radio = transmitter
	speech.speaker = src

	speech.name = GetVoice()
	speech.as_name = get_alt_name()
	return speech

/atom/movable/proc/render_speech_name(var/datum/speech/speech)
	// old getVoice-based shit
	//return "[speech.speaker.GetVoice()][speech.speaker.get_alt_name()]"
	return "[speech.name][speech.render_as_name()]"

/atom/movable/proc/render_speech(var/datum/speech/speech)
	say_testing(src, "render_speech() - Freq: [speech.frequency], radio=\ref[speech.radio]")
	var/freqpart = ""
	var/colorpart
	if(speech.frequency)
		freqpart = " \[[get_radio_name(speech.frequency)]\]"
		speech.wrapper_classes.Add(get_radio_span(speech.frequency))
		colorpart = get_radio_color(speech.frequency)
	var/pooled=0
	var/datum/speech/filtered_speech
	if(speech.language)
		filtered_speech = speech.language.filter_speech(speech.clone())
	else
		filtered_speech = speech

	var/atom/movable/source = speech.speaker.GetSource()
	say_testing(speech.speaker, "Checking if [src]([type]) understands [source]([source.type])")
	if(!say_understands(source, speech.language))
		say_testing(speech.speaker," We don't understand this fuck, adding stars().")
		filtered_speech=filtered_speech.scramble()
		pooled=1
	else
		say_testing(speech.speaker," We <i>do</i> understand this gentle\[wo\]man.")

#ifdef SAY_DEBUG
	var/enc_wrapclass=jointext(filtered_speech.wrapper_classes, ", ")
	say_testing(src, "render_speech() - wrapper_classes = \[[enc_wrapclass]\]")
#endif
	// Below, but formatted nicely, and with the optional color override.
	/*
	return {"
		<span class='[filtered_speech.render_wrapper_classes()]'>
			<span class='name'>
				[render_speaker_track_start(filtered_speech)][render_speech_name(filtered_speech)][render_speaker_track_end(filtered_speech)]
				[freqpart]
				[render_job(filtered_speech)]
			</span>
			[filtered_speech.render_message()]
		</span>"}
	*/
	// All this font_color spam is annoying but it's the only way to work it right.
	. = "<span class='[filtered_speech.render_wrapper_classes()]'><span class='name'>"
	if(colorpart)
		. += "<font color = [colorpart]>"
		say_testing(src, "render_speech() - colorpart = \[[colorpart]\]")
	. += "[render_speaker_track_start(filtered_speech)][render_speech_name(filtered_speech)][render_speaker_track_end(filtered_speech)][freqpart][render_job(filtered_speech)]"
	if(colorpart)
		. += "</font color>"
	. += "</span>"
	if(colorpart)
		. += "<font color = [colorpart]>"
	. += " [filtered_speech.render_message()]"
	if(colorpart)
		. += "</font color>"
	. += "</span>"
	say_testing(src, html_encode(.))
	if(pooled)
		qdel(filtered_speech)


/atom/movable/proc/render_speaker_track_start(var/datum/speech/speech)
	return ""

/atom/movable/proc/render_speaker_track_end(var/datum/speech/speech)
	return ""

/atom/movable/proc/get_job(var/datum/speech/speech)
	return ""

/atom/movable/proc/render_job(var/datum/speech/speech)
	if(speech.job)
		return " ([speech.job])"
	return ""

// This is obsolete for any atom movable which actually uses a language whilst speaking.
// The verb for those atoms will be given in /datum/language/get_spoken_verb()
// An override depending on the status of the mob is possible with the proc /mob/proc/get_spoken_verb()
/atom/movable/proc/say_quote(var/text)
	if(!text)
		return "says, \"...\""	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return "asks, [text]"
	if (ending == "!")
		return "exclaims, [text]"

	return "says, [text]"


var/global/image/ghostimg = image("icon"='icons/mob/mob.dmi',"icon_state"="ghost")
/atom/movable/proc/render_lang(var/datum/speech/speech)
	var/raw_message=speech.message
	if(speech.language)
		//var/overRadio = (istype(speech.speaker, /obj/item/device/radio) || istype(speech.speaker.GetSource(), /obj/item/device/radio))
		var/atom/movable/AM = speech.speaker.GetSource()
		if(say_understands((istype(AM) ? AM : speech.speaker),speech.language))
			return render_speech(speech)
			//if(overRadio)
			//	return speech.language.format_message_radio(speech.speaker, raw_message)
			//return speech.language.format_message(speech.speaker, raw_message)
		else
			return render_speech(speech.scramble())
			//if(overRadio)
			//	return speech.language.format_message_radio(speech.speaker, speech.language.scramble(raw_message))
			//return speech.language.format_message(speech.speaker, speech.language.scramble(raw_message))

	else
		var/atom/movable/AM = speech.speaker.GetSource()
		var/atom/movable/source = istype(AM) ? AM : speech.speaker

		var/rendered = raw_message

		say_testing(speech.speaker, "Checking if [src]([type]) understands [source]([source.type])")
		if(!say_understands(source))
			say_testing(speech.speaker," We don't understand this fuck, adding stars().")
			rendered = stars(rendered)
		else
			say_testing(speech.speaker," We <i>do</i> understand this gentle\[wo\]man.")

		rendered="[speech.lquote][html_encode(rendered)][speech.rquote]"

		if(AM)
			return AM.say_quote(rendered)
		else
			return speech.speaker.say_quote(rendered)
	/*else if(message_langs & SPOOKY)
		return "[bicon(ghostimg)] <span class='sinister'>Too spooky...</span> [bicon(ghostimg)]"
	else if(message_langs & MONKEY)
		return "chimpers."
	else if(message_langs & ALIEN)
		return "hisses."
	else if(message_langs & ROBOT)
		return "beeps rapidly."
	else if(message_langs & SIMPLE_ANIMAL)
		var/mob/living/simple_animal/SA = speaker.GetSource()
		if(!SA || !istype(SA))
			SA = speaker
		if(istype(SA))
			return "[pick(SA.speak_emote)]."
		else
			return "makes a strange sound."
	else
		return "makes a strange sound."*/


/proc/get_radio_span(freq)
	var/returntext = freqtospan["[freq]"]
	if(returntext)
		return returntext
	return "radio"

/proc/get_radio_color(freq)
	var/returntext = freqtocolor["[freq]"]
	if(returntext)
		return returntext

/proc/get_radio_name(freq)
	var/returntext = radiochannelsreverse["[freq]"]
	if(returntext)
		return returntext
	return "[copytext("[freq]", 1, 4)].[copytext("[freq]", 4, 5)]"

/* NO YOU FOOL
/proc/attach_spans(input, list/spans)
	return "[message_spans(spans)][input]</span>"

/proc/message_spans(list/spans)
	var/output = "<SPAN CLASS='"

	for(var/span in spans)
		output = "[output][span] "

	output = "[output]'>"
	return output
*/


/**
 * The "voice" of the thing that's speaking.  Shows up as name.
 */
/atom/movable/proc/GetVoice()
	return name

/atom/movable/proc/IsVocal()
	return 1

/**
 * The "voice" of the thing that's speaking.  Shows up as name.
 */
/atom/movable/proc/get_alt_name()
	return

//these exist mostly to deal with the AIs hrefs and job stuff.
/atom/movable/proc/GetJob()
	return

/**
 * What is speaking for us?  Usually src.
 */
/atom/movable/proc/GetSource()
	return src

// GetRadio() removed because which radio is used can be different per message. (such as when using :L :R :I macros)
//  - N3X
/atom/movable/proc/GetDefaultRadio()
	return null

/atom/movable/virtualspeaker
	var/job
	var/atom/movable/source
	var/obj/item/device/radio/radio

/atom/movable/virtualspeaker/GetJob()
	return job


/atom/movable/virtualspeaker/GetSource()
	return source

/atom/movable/virtualspeaker/GetDefaultRadio()
	return radio

/proc/handle_render(var/mob,var/message,var/speaker)
	if(istype(mob, /mob/new_player))
		return //One extra layer of sanity
	if(istype(mob,/mob/dead/observer))
		var/reference = "<a href='?src=\ref[mob];follow=\ref[speaker]'>(Follow)</a> "
		message = reference+message
		to_chat(mob, message)
	else
		to_chat(mob, message)

var/global/resethearers = 0

/proc/sethearing()
	for(var/mob/virtualhearer/VH in movable_hearers)
		VH.loc = get_turf(VH.attached)
	resethearers = world.time + 2

// Returns a list of hearers in range of R from source. Used in saycode.
/proc/get_hearers_in_view(var/R, var/atom/source)
	if(world.time>resethearers)
		sethearing()

	var/turf/T = get_turf(source)
	. = new/list()

	if(!T)
		return

	for(var/z0 in GetOpenConnectedZlevels(T))
		if(abs(z0 - T.z) <= R)
			for(var/mob/virtualhearer/VH in hearers(R, locate(T.x,T.y,z0)))
				var/can_hear = 1
				if(istype(VH.attached, /mob))			//The virtualhearer is attached to a mob.
					var/mob/M = VH.attached
					if(M.client)						//The mob has a client.
						var/client/C = M.client
						if(C.ObscuredTurfs.len)			//The client is in range of something that is artificially obscuring its view.
							if(T in C.ObscuredTurfs)	//The source's turf is one that is being artificially obscured.
								can_hear = 0
				if(can_hear)
					. += VH.attached

/**
 * Returns a list of mobs who can hear any of the radios given in @radios.
 */
/proc/get_mobs_in_radio_ranges(list/obj/item/device/radio/radios)
	if(world.time>resethearers)
		sethearing()

	. = new/list()
	for(var/obj/item/device/radio/radio in radios)
		if(radio)
			var/turf/turf = get_turf(radio)

			if(turf)
				for(var/mob/virtualhearer/VH in hearers(radio.canhear_range, turf))
					. |= VH.attached