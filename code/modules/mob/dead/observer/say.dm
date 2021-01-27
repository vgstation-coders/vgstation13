/mob/dead/observer/say(var/message)
	message = trim(copytext(message, 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	if (src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			to_chat(src, "<span class='warning'>You cannot talk in deadchat (muted).</span>")
			return

		if (src.client.handle_spam_prevention(message,MUTE_DEADCHAT))
			return

	. = src.say_dead(message)

/mob/dead/observer/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "[pick("moans", "gripes", "grumps", "murmurs", "mumbles", "bleats")], [text]";
	else if (ending == "!")
		return "[pick("screams", "screeches", "howls")], [text]";

	return "[pick("whines", "cries", "spooks", "complains", "drones", "mutters")], [text]";

/mob/dead/observer/Hear(var/datum/speech/speech, var/rendered_speech="")
	if (isnull(client) || !speech.speaker)
		return

	var/source = speech.speaker.GetSource()
	var/source_turf = get_turf(source)

	// Don't hear simple mobs without a client.
	if (istype(source, /mob/living/simple_animal) && (get_dist(source_turf, src) > get_view_range()))
		var/mob/living/simple_animal/animal = source
		if (!animal.client)
			return

	say_testing(src, "/mob/dead/observer/Hear(): source=[source], frequency=[speech.frequency], source_turf=[formatJumpTo(source_turf)]")

	if (get_dist(source_turf, src) <= get_view_range())
		rendered_speech = "<B>[rendered_speech]</B>"
		if (client?.prefs.mob_chat_on_map && (client.prefs.obj_chat_on_map || ismob(speech.speaker)))
			create_chat_message(speech.speaker, speech.language, speech.message, speech.mode, speech.wrapper_classes)
	else
		if(client && client.prefs)
			if (!speech.frequency)
				if ((client.prefs.toggles & CHAT_GHOSTEARS) != CHAT_GHOSTEARS)
					say_testing(src, "/mob/dead/observer/Hear(): CHAT_GHOSTEARS is disabled, blocking. ([client.prefs.toggles] & [CHAT_GHOSTEARS]) = [client.prefs.toggles & CHAT_GHOSTEARS]")
					return
			else
				if ((client.prefs.toggles & CHAT_GHOSTRADIO) != CHAT_GHOSTRADIO)
					say_testing(src, "/mob/dead/observer/Hear(): CHAT_GHOSTRADIO is disabled, blocking. ([client.prefs.toggles] & [CHAT_GHOSTRADIO]) = [client.prefs.toggles & CHAT_GHOSTRADIO]")
					return

	to_chat(src, "<a href='?src=\ref[src];follow=\ref[source]'>(Follow)</a> [rendered_speech]")
