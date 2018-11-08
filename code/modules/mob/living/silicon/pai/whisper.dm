/mob/living/silicon/pai/whisper(message as text)
	if(silence_time)
		to_chat(src, "<font color=green>Communication circuits remain unitialized.</font>")
#ifdef SAY_DEBUG
	var/oldmsg = message
#endif
	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(isDead())
		return
	
	var/datum/speech/speech = create_speech(message)
	speech.language = parse_language(speech.message)
	speech.mode = SPEECH_MODE_WHISPER
	speech.message_classes.Add("whisper")

	if(istype(speech.language))
		speech.message = copytext(speech.message,2+length(speech.language.key))
	else
		if(!isnull(speech.language))
			//var/oldmsg = message
			var/n = speech.language
			speech.message = copytext(speech.message,1+length(n))
			say_testing(src, "We tried to speak a language we don't have length = [length(n)], oldmsg = [oldmsg] parsed message = [speech.message]")
			speech.language = null
		
		speech.language = get_default_language()

	speech.message = trim(speech.message)

	if(!can_speak(message))
		return

	speech.message = "[message]"

	if (src.client)
		if (src.client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>You cannot whisper (muted).</span>")
			return

	//var/alt_name = get_alt_name()

	var/whispers = "whispers"
	var/listeners = get_hearers_in_view(1, src) | observers
	var/eavesdroppers = get_hearers_in_view(2, src) - listeners
	var/watchers = hearers(6, src) - listeners - eavesdroppers

	speech.message_classes.Add("siliconsay")
	var/rendered = render_speech(speech)

	for (var/atom/movable/listener in listeners)
		listener.Hear(speech, rendered)

	listeners = null

	speech.message = stars(speech.message)

	rendered = render_speech(speech)

	for (var/atom/movable/eavesdropper in eavesdroppers)
		eavesdropper.Hear(speech, rendered)

	eavesdroppers = null

	rendered = "<span class='game say'><span class='name'>[src.name]</span> [whispers] something.</span>"

	for (var/mob/watcher in watchers)
		watcher.show_message(rendered, 2)

	watchers = null

	returnToPool(speech)