//bitflag #defines for radio returns.
#define ITALICS 1
#define REDUCE_RANGE 2
#define NOPASS 4


#define SAY_MINIMUM_PRESSURE 10

/proc/message_mode_to_name(mode)
	switch(mode)
		if(MODE_WHISPER)
			return "whisper"
		if(MODE_SECURE_HEADSET)
			return "secure_headset"
		if(MODE_DEPARTMENT)
			return "department"
		if(MODE_ALIEN)
			return "alientalk"
		if(MODE_HOLOPAD)
			return "holopad"
		if(MODE_CHANGELING)
			return "changeling"
		if(MODE_CULTCHAT)
			return "cultchat"
		if(MODE_ANCIENT)
			return "ancientchat"
		if(MODE_MUSHROOM)
			return "sporechat"
		if(MODE_BORER)
			return "borerchat"
		else
			return "Unknown"
var/list/department_radio_keys = list(
	  ":0" = "Deathsquad",	 "#0" = "Deathsquad",	".0" = "Deathsquad",
	  //1 Used by LANGUAGE_GALACTIC_COMMON
	  //2 Used by LANGUAGE_TRADEBAND
	  //3 Used by LANGUAGE_GUTTER
	  //4 Used by LANGUAGE_XENO
	  //5 Used by LANGUAGE_CULT
	  //6 Used by LANGUAGE_MONKEY
	  //7 Used by LANGUAGE_HUMAN
	  //8 Used by LANGUAGE_GOLEM
	  //9 Used by LANGUAGE_MOUSE
	  ":-" = "Response Team","#-" = "Response Team",".-" = "Response Team",
	  ":a" = "alientalk",	"#a" = "alientalk",		".a" = "alientalk",
	  ":b" = "binary",		"#b" = "binary",		".b" = "binary",
	  ":c" = "Command",		"#c" = "Command",		".c" = "Command",
	  ":d" = "Service",     "#d" = "Service",       ".d" = "Service",
	  ":e" = "Engineering", "#e" = "Engineering",	".e" = "Engineering",
	  //f Used by LANGUAGE_SLIME
	  ":g" = "changeling",	"#g" = "changeling",	".g" = "changeling",
	  ":h" = "department",	"#h" = "department",	".h" = "department",
	  ":i" = "intercom",	"#i" = "intercom",		".i" = "intercom",
	  //j Used by LANGUAGE_TAJARAN
	  //k Used by LANGUAGE_SKRELLIAN and LANGUAGE_GREY
	  ":l" = "left hand",	"#l" = "left hand",		".l" = "left hand",  "!l" = "fake left hand",
	  ":m" = "Medical",		"#m" = "Medical",		".m" = "Medical",
	  ":n" = "Science",		"#n" = "Science",		".n" = "Science",
	  //o Used by LANGUAGE_UNATHI
	  ":p" = "AI Private",	"#p" = "AI Private",	".p" = "AI Private",
	  //q Used by LANGUAGE_ROOTSPEAK
	  ":r" = "right hand",	"#r" = "right hand",	".r" = "right hand", "!r" = "fake right hand",
	  ":s" = "Security",	"#s" = "Security",		".s" = "Security",
	  ":t" = "Syndicate",	"#t" = "Syndicate",		".t" = "Syndicate",
	  ":u" = "Supply",		"#u" = "Supply",		".u" = "Supply",
	  //v Used by LANGUAGE_VOX
	  ":w" = "whisper",		"#w" = "whisper",		".w" = "whisper",
	  ":x" = "cultchat",	"#x" = "cultchat",		".x" = "cultchat",
	  ":y" = "ancientchat",	"#y" = "ancientchat",	".y" = "ancientchat",
	  //z Used by LANGUAGE_CLATTER
	  //@ Used by LANGUAGE_MARTIAN
	  ":~" = "sporechat",	"#~" = "sporechat",	    ".~" = "sporechat",
	  //borers
	  ":&" = "borerchat", "#&" = "borerchat", ".&" = "borerchat",
)

/mob/living/proc/get_default_language()
	if(!default_language)
		if(languages && languages.len)
			default_language = languages[1]
	return default_language

/mob/living/hivecheck()
	if (isalien(src))
		return 1
	if (!ishuman(src))
		return 0
	var/mob/living/carbon/human/H = src
	if (H.ears)
		var/obj/item/device/radio/headset/dongle
		if(istype(H.ears,/obj/item/device/radio/headset))
			dongle = H.ears
		if(!istype(dongle))
			return
		if(dongle.translate_hive)
			return 1


// /vg/edit: Added forced_by for handling braindamage messages and meme stuff
/mob/living/say(var/message, bubble_type)
	say_testing(src, "/mob/living/say(\"[message]\", [bubble_type]")
	if(timestopped)
		return //under the effects of time magick
	message = trim(copytext(message, 1, MAX_MESSAGE_LEN))
	message = capitalize(message)

	say_testing(src, "Say start, message=[message]")
	if(!message)
		return

	var/message_mode = get_message_mode(message)
	if(silent)
		to_chat(src, "<span class='warning'>You can't speak while silenced.</span>")
		return
	if((status_flags & FAKEDEATH) && !stat && message_mode != MODE_CHANGELING)
		to_chat(src, "<span class='danger'>Talking right now would give us away!</span>")
		return

	//var/message_mode_name = message_mode_to_name(message_mode)
	if (stat == DEAD) // Dead.
		say_testing(src, "ur ded kid")
		say_dead(message)
		return
	if(check_emote(message))
		say_testing(src, "Emoted")
		return
	if (stat) // Unconcious.
		if(message_mode == MODE_WHISPER) //Lets us say our last words.
			say_testing(src, "message mode was whisper.")
			whisper(copytext(message, 3))
		return
	if(!can_speak_basic(message))
		say_testing(src, "we aren't able to talk")
		return

	if(message_mode == MODE_HEADSET || message_mode == MODE_ROBOT)
		say_testing(src, "Message mode was [message_mode == MODE_HEADSET ? "headset" : "robot"]")
		message = copytext(message, 2)
	else if(message_mode)
		say_testing(src, "Message mode is [message_mode]")
		if(message_mode != MODE_HOLOPAD)
			message = copytext(message, 3)

	// SAYCODE 90.0!
	// We construct our speech object here.
	var/datum/speech/speech = create_speech(message)

	if(!speech.language)
		speech.language = parse_language(speech.message)
		say_testing(src, "Getting speaking language, got [istype(speech.language) ? speech.language.name : "null"]")
	if(istype(speech.language))
#ifdef SAY_DEBUG
		var/oldmsg = message
#endif
		speech.message = copytext(speech.message,2+length(speech.language.key))
		say_testing(src, "Have a language, oldmsg = [oldmsg], newmsg = [message]")
	else
		if(!isnull(speech.language))
#ifdef SAY_DEBUG
			var/oldmsg = message
#endif
			var/n = speech.language
			message = copytext(message,1+length(n))
			say_testing(src, "We tried to speak a language we don't have; length = [length(n)], oldmsg = [oldmsg] parsed message = [message]")
			speech.language = null
		speech.language = get_default_language()
		say_testing(src, "Didnt have a language, get_default_language() gave us [speech.language ? speech.language.name : "null"]")
	speech.message = trim_left(speech.message)
	if(handle_inherent_channels(speech, message_mode))
		say_testing(src, "Handled by inherent channel")
		returnToPool(speech)
		return
	if(!can_speak_vocal(speech.message))
		returnToPool(speech)
		return

	//parse the language code and consume it


	var/message_range = 7
	treat_speech(speech)

	var/radio_return = get_speech_flags(message_mode)
	if(radio_return & NOPASS) //There's a whisper() message_mode, no need to continue the proc if that is called
		whisper(speech.message, speech.language)
		returnToPool(speech)
		return

	if(radio_return & REDUCE_RANGE)
		message_range = 1
	if(copytext(text, length(text)) == "!")
		message_range++

	if(radio_return & ITALICS)
		speech.message_classes.Add("italics")
		send_speech(speech, message_range, bubble_type)
		speech.message_classes.Remove("italics") //Wow, this is really hacky, but not as bad as creating a separate speech object with one differing var.
	else
		send_speech(speech, message_range, bubble_type)
	radio(speech, message_mode) //Sends the radio signal
	var/turf/T = get_turf(src)
	log_say("[name]/[key] [T?"(@[T.x],[T.y],[T.z])":"(@[x],[y],[z])"] [speech.language ? "As [speech.language.name] ":""]: [message]")
	returnToPool(speech)
	return 1

/mob/living/proc/resist_memes(var/datum/speech/speech)
	if(stat || ear_deaf || speech.frequency || speech.speaker == src || !isliving(speech.speaker))
		return TRUE
	return FALSE

/mob/living/Hear(var/datum/speech/speech, var/rendered_message = null)
	if(!rendered_message)
		rendered_message = speech.message

	//Meme disease code. Needs to come before client so that NPCs/catatonic can be infected.
	//We don't concern ourselves with: radio chatter, our own speech, or if we're deaf.
	if(!resist_memes(speech))
		var/mob/living/L = speech.speaker
		var/list/diseases = L.virus2
		if(istype(diseases) && diseases.len)
			for(var/ID in diseases)
				var/datum/disease2/disease/V = diseases[ID]
				if(V.spread & SPREAD_MEMETIC)
					infect_disease2(V, notes="(Memed, from [L])")

	if(!client)
		return
	say_testing(src, "[src] ([src.type]) has heard a message (lang=[speech.language ? speech.language.name : "null"])")
	var/deaf_message
	var/deaf_type
	var/type = 2
	if(speech.speaker != src)
		if(!speech.frequency) //These checks have to be seperate, else people talking on the radio will make "You can't hear yourself!" appear when hearing people over the radio while deaf.
			deaf_message = "<span class='name'>[speech.speaker]</span> talks but you cannot hear them."
			deaf_type = 1
		else
			if(hear_radio_only())
				type = null //This kills the deaf check for radio only.
	else
		deaf_message = "<span class='notice'>You can't hear yourself!</span>"
		deaf_type = 2 // Since you should be able to hear yourself without looking
	var/atom/movable/AM = speech.speaker.GetSource()
	if(!say_understands((istype(AM) ? AM : speech.speaker),speech.language)|| force_compose) //force_compose is so AIs don't end up without their hrefs.
		rendered_message = render_speech(speech)

	//checking for syndie codephrases if person is a tator
	if(src.mind.GetRole(TRAITOR) || src.mind.GetRole(NUKE_OP))
		//is tator
		for(var/T in syndicate_code_phrase)
			rendered_message = replacetext(rendered_message, T, "<b style='color: red;'>[T]</b>")

		for(var/T in syndicate_code_response)
			rendered_message = replacetext(rendered_message, T, "<i style='color: red;'>[T]</i>")

	show_message(rendered_message, type, deaf_message, deaf_type, src)
	return rendered_message

/mob/living/proc/hear_radio_only()
	return 0

/mob/living/send_speech(var/datum/speech/speech, var/message_range=7, var/bubble_type) // what is bubble type?
	say_testing(src, "/mob/living/send_speech() start, msg = [speech.message]; message_range = [message_range]; language = [speech.language ? speech.language.name : "None"]; speaker = [speech.speaker];")
	if(isnull(message_range))
		message_range = 7

	var/list/listeners = get_hearers_in_view(message_range, speech.speaker) | observers

	var/rendered = render_speech(speech)

	var/list/listening_nonmobs = listeners.Copy()
	for(var/mob/M in listeners)
		listening_nonmobs -= M
		M.Hear(speech, rendered)

	send_speech_bubble(speech.message, bubble_type, listeners)

	for (var/atom/movable/listener in listening_nonmobs)
		listener.Hear(speech, rendered)

/mob/living/carbon/human/send_speech(var/datum/speech/speech, var/message_range=7, var/bubble_type)
	talkcount++
	. = ..()

/mob/living/proc/say_test(var/text)
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return "1"
	else if (ending == "!")
		return "2"
	return "0"

/mob/living/can_speak(message) //For use outside of Say()
	if(can_speak_basic(message) && can_speak_vocal(message))
		return 1

/mob/living/proc/can_speak_basic(message) //Check BEFORE handling of xeno and ling channels
	if(!message || message == "")
		return

	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>You cannot speak in IC (muted).</span>")
			return
		if(client.handle_spam_prevention(message,MUTE_IC))
			return

	return 1


/mob/living/proc/can_speak_vocal(message) //Check AFTER handling of xeno and ling channels
	if(!message)
		return

	if(is_mute())
		return

	if(is_muzzled())
		return

	if(!IsVocal())
		return

	return 1

/mob/living/proc/check_emote(message)
	if(copytext(message, 1, 2) == "*" && is_letter(text2ascii(message, 2)))
		emote(copytext(message, 2))
		return 1


/mob/living/proc/get_message_mode(message)
	if(copytext(message, 1, 2) == ";")
		return MODE_HEADSET
	else if(length(message) > 2)
		return department_radio_keys[lowertext(copytext(message, 1, 3))]

/mob/living/proc/handle_inherent_channels(var/datum/speech/speech, var/message_mode)
	switch(message_mode)
		if(MODE_CHANGELING)
			if(lingcheck())
				var/turf/T = get_turf(src)
				var/datum/role/changeling/C = mind.GetRole(CHANGELING)
				if(!C)
					return 0
				log_say("[C.changelingID]/[key_name(src)] (@[T.x],[T.y],[T.z]) Changeling Hivemind: [html_encode(speech.message)]")
				var/themessage = text("<i><font color=#800080><b>[]:</b> []</font></i>",C.changelingID,html_encode(speech.message))
				for(var/mob/M in player_list)
					if(M.lingcheck() || ((M in dead_mob_list) && !istype(M, /mob/new_player)))
						handle_render(M,themessage,src)
				return 1
		if(MODE_CULTCHAT)
			if(construct_chat_check(1)) /*sending check for humins*/
				var/turf/T = get_turf(src)
				log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) Cult channel: [html_encode(speech.message)]")
				var/themessage = text("<span class='sinister'><b>[]:</b> []</span>",src.name,html_encode(speech.message))
				for(var/mob/M in player_list)
					if(M.construct_chat_check(2) /*receiving check*/ || ((M in dead_mob_list) && !istype(M, /mob/new_player)))
						handle_render(M,themessage,src)
				return 1
		if(MODE_ANCIENT)
			if(isMoMMI(src))
				return 0 //Noice try, I really do appreciate the effort
			var/list/stone = search_contents_for(/obj/item/commstone)
			if(stone.len)
				var/obj/item/commstone/commstone = stone[1]
				if(commstone.commdevice)
					var/list/stones = commstone.commdevice.get_active_stones()
					var/themessage = text("<span class='ancient'>Ancient communication, <b>[]:</b> []</span>",src.name,html_encode(speech.message))
					var/turf/T = get_turf(src)
					log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) Ancient chat: [html_encode(speech.message)]")
					for(var/thestone in stones)
						var/mob/M = get_holder_of_type(thestone,/mob)
						if(M)
							handle_render(M,themessage,src)
					for(var/M in dead_mob_list)
						if(!istype(M,/mob/new_player))
							handle_render(M,themessage,src)
					return 1
		if(MODE_MUSHROOM)
			var/message = text("<span class='mushroom'>Sporemind, <b>[]:</b> []</span>", src.real_name, html_encode(speech.message))
			var/turf/T = get_turf(src)
			log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) Spore chat: [html_encode(speech.message)]")
			for(var/mob/M in player_list)
				if(iscarbon(M))
					var/mob/living/carbon/human/H = M
					if(ismushroom(H))
						handle_render(M, message,src)
				if((M in dead_mob_list) && !istype(M, /mob/new_player))
					handle_render(M, message,src)
		if(MODE_BORER)
			//this is sent to and usable by borers and mobs controlled by borers
			var/mob/living/simple_animal/borer/head = src.has_brain_worms(LIMB_HEAD)
			if(isborer(src) || head && head.controlling)
				var/mob/living/simple_animal/borer/B = head && head.controlling ? head : src
				var/message = text("<span class='cortical'>Cortical link, <b>[]</b>: []</span>",B.truename, html_encode(speech.message))
				var/turf/T = get_turf(src)
				log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) Borer chat: [html_encode(speech.message)]")

				for(var/mob/M in mob_list)
					if(isborer(M) || ((M in dead_mob_list) && !istype(M, /mob/new_player)))
						if(isborer (M)) //for borers that are IN CONTROL
							B = M //why it no typecast
							if(B.controlling)
								M = B.host
						handle_render(M, message, src)
				return 1
	return 0

/mob/living/proc/treat_speech(var/datum/speech/speech, genesay = 0)
	if(getBrainLoss() >= 60)
		speech.message = derpspeech(speech.message, stuttering)

	if(stuttering || (undergoing_hypothermia() == MODERATE_HYPOTHERMIA && prob(25)) )
		speech.message = stutter(speech.message)

/mob/living/proc/get_speech_flags(var/message_mode)
	switch(message_mode)
		if(MODE_WHISPER, SPEECH_MODE_FINAL)
			return NOPASS
		if(MODE_HEADSET, MODE_SECURE_HEADSET, MODE_R_HAND, MODE_L_HAND, MODE_INTERCOM, MODE_BINARY)
			return ITALICS | REDUCE_RANGE //most cases
		if("robot")
			return REDUCE_RANGE
	if(message_mode in radiochannels)
		return ITALICS | REDUCE_RANGE //for borgs and polly

	return 0

/mob/living/proc/radio(var/datum/speech/speech, var/message_mode)
	switch(message_mode)
		if(MODE_R_HAND)
			say_testing(src, "/mob/living/radio() - MODE_R_HAND")
			var/obj/item/I = get_held_item_by_index(GRASP_RIGHT_HAND)
			if(I)
				I.talk_into(speech)
			return ITALICS | REDUCE_RANGE
		if(MODE_L_HAND)
			say_testing(src, "/mob/living/radio() - MODE_L_HAND")
			var/obj/item/I = get_held_item_by_index(GRASP_LEFT_HAND)
			if(I)
				I.talk_into(speech)
			return ITALICS | REDUCE_RANGE
		if(MODE_INTERCOM)
			say_testing(src, "/mob/living/radio() - MODE_INTERCOM")
			for (var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(speech)
			return ITALICS | REDUCE_RANGE
		if(MODE_BINARY)
			say_testing(src, "/mob/living/radio() - MODE_BINARY")
			if(binarycheck())
				robot_talk(speech.message)
			return ITALICS | REDUCE_RANGE //Does not return 0 since this is only reached by humans, not borgs or AIs.
		if(MODE_WHISPER)
			say_testing(src, "/mob/living/radio() - MODE_WHISPER")
			whisper(speech.message, speech.language)
			return NOPASS
	return 0

/mob/living/lingcheck()
	if(ischangeling(src) && !issilicon(src))
		return 1
	return 0

/mob/living/construct_chat_check(var/setting = 0) //setting: 0 is to speak over general into cultchat, 1 is to speak over channel into cultchat, 2 is to hear cultchat
	if(!mind)
		return
	if(setting == 0) //overridden for constructs
		return

	if (iscultist(src))
		if(setting == 1)
			if (checkTattoo(TATTOO_CHAT))
				return 1
		if(setting == 2)
			return 1

	var/datum/faction/cult = find_active_faction_by_member(mind.GetRole(LEGACY_CULT))
	if(cult)
		if(setting == 1)
			if(universal_cult_chat == 1)
				return 1
		if(setting == 2)
			return 1

/mob/living/say_quote()
	if (stuttering)
		return "stammers, [text]"
	if (getBrainLoss() >= 60)
		return "gibbers, [text]"
	return ..()

/mob/living/proc/send_speech_bubble(var/message,var/bubble_type, var/list/hearers)
	//speech bubble
	var/list/tracking_speech_bubble_recipients = list()
	var/list/static_speech_bubble_recipients = list()
	for(var/mob/M in hearers)
		M.heard(src)
		if(M.client)
			if(src.invisibility > M.see_invisible) //You cannot see who's talking, so you only get a vague sense of where the sound originated from. This is mostly for Jaunt invocation.
				static_speech_bubble_recipients.Add(M.client)
			else
				tracking_speech_bubble_recipients.Add(M.client)
	spawn(0)
		if(static_speech_bubble_recipients.len)
			display_bubble_to_clientlist(image('icons/mob/talk.dmi', get_turf(src), "h[bubble_type][say_test(message)]",MOB_LAYER+1), static_speech_bubble_recipients)
		if(tracking_speech_bubble_recipients.len)
			display_bubble_to_clientlist(image('icons/mob/talk.dmi', get_holder_at_turf_level(src), "h[bubble_type][say_test(message)]",MOB_LAYER+1), tracking_speech_bubble_recipients)

/proc/display_bubble_to_clientlist(var/image/speech_bubble, var/clientlist)
	speech_bubble.plane = ABOVE_LIGHTING_PLANE
	speech_bubble.appearance_flags = RESET_COLOR
	flick_overlay(speech_bubble, clientlist, 30)

/mob/proc/addSpeechBubble(image/speech_bubble)
	if(client)
		client.images += speech_bubble
		spawn(30)
			if(client)
				client.images -= speech_bubble

/mob/living/whisper(message as text)
	if(!IsVocal())
		to_chat(src, "<span class='warning'>You can't speak while silenced.</span>")
		return

#ifdef SAY_DEBUG
	var/oldmsg = message
#endif

	if (isDead() || (stat == UNCONSCIOUS && health > 0))
		return

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	var/datum/speech/speech = create_speech(message)
	speech.language = parse_language(speech.message)
	speech.mode = SPEECH_MODE_WHISPER
	speech.message_classes.Add("whisper")

	if(istype(speech.language))
		speech.message = copytext(speech.message,2+length(speech.language.key))
	else
		if(!isnull(speech.language))
			var/n = speech.language
			speech.message = copytext(speech.message,1+length(n))
			say_testing(src, "We tried to speak a language we don't have length = [length(n)], oldmsg = [oldmsg] parsed message = [speech.message]")
			speech.language = null
		speech.language = get_default_language()

	speech.message = trim(speech.message)

	if(!can_speak(message))
		return

	speech.message = "[message]"

	if (client && client.prefs.muted & MUTE_IC)
		to_chat(src, "<span class='danger'>You cannot whisper (muted).</span>")
		return


	var/whispers = "whispers"
	var/critical = InCritical()

	log_whisper("[key_name(src)] ([formatLocation(src)]): [message]")
	treat_speech(speech)

	// If whispering your last words, limit the whisper based on how close you are to death.
	if(critical && !said_last_words)
		var/health_diff = round(-config.health_threshold_dead + health)
		// If we cut our message short, abruptly end it with a-..
		var/message_len = length(speech.message)
		speech.message = copytext(speech.message, 1, health_diff) + "[message_len > health_diff ? "-.." : "..."]"
		speech.message = Ellipsis(speech.message, 10, 1)
		speech.mode= SPEECH_MODE_FINAL
		whispers = "whispers with their final breath"
		said_last_words = src.stat
	treat_speech(speech)

	var/listeners = get_hearers_in_view(1, src) | observers
	var/eavesdroppers = get_hearers_in_view(2, src) - listeners
	var/watchers = hearers(5, src) - listeners - eavesdroppers
	var/rendered = render_speech(speech)
	for (var/atom/movable/listener in listeners)
		listener.Hear(speech, rendered)

	speech.message = stars(speech.message)
	rendered = render_speech(speech)

	for (var/atom/movable/eavesdropper in eavesdroppers)
		eavesdropper.Hear(speech, rendered)

	rendered = "<span class='game say'><span class='name'>[src.name]</span> [whispers] something.</span>"

	for (var/mob/watcher in watchers)
		watcher.show_message(rendered, 2)

	if (said_last_words) // dying words
		succumb_proc(0)

	returnToPool(speech)

/obj/effect/speech_bubble
	var/mob/parent
