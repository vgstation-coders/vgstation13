/mob/dead/observer/say(var/message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	var/turf/T = get_turf(src)
	log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) Ghost: [message]")

	if (src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			src << "<span class='warning'>You cannot talk in deadchat (muted).</span>"
			return

		if (src.client.handle_spam_prevention(message,MUTE_DEADCHAT))
			return

	. = src.say_dead(message)

/mob/dead/observer/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "[pick("moans", "gripes", "grumps", "murmurs", "mumbles", "bleats")], \"[text]\"";
	else if (ending == "!")
		return "[pick("screams", "screeches", "howls")], \"[text]\"";

	return "[pick("whines", "cries", "spooks", "complains", "drones", "mutters")], \"[text]\"";

/mob/dead/observer/Hear(message, atom/movable/speaker, var/datum/language/speaking, raw_message, radio_freq)
	if (isnull(client))
		return

	var/source = speaker.GetSource()

	var/source_turf = get_turf(source)

	if (get_dist(source_turf, src) <= world.view) // If this isn't true, we can't be in view, so no need for costlier proc.
		if (source_turf in view(src))
			message = "<B>[message]</B>"
	else
		if(client && client.prefs)
			if (isnull(radio_freq))
				if (!(client.prefs.toggles & CHAT_GHOSTEARS))
					return
			else
				if (!(client.prefs.toggles & CHAT_GHOSTRADIO))
					return

	src << "<a href='?src=\ref[src];follow=\ref[source]'>(Follow)</a> [message]"
