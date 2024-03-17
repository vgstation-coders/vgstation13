/mob/living/silicon/ai/say(var/message)
	if(loc.loc && istype(loc.loc,/obj/item/weapon/storage/belt/silicon)) //loc would be an aicard in this case
		RenderBeltChat(loc.loc,src,message)
		return 1
	if(parent && istype(parent) && parent.stat != 2) //If there is a defined "parent" AI, it is actually an AI, and it is alive, anything the AI tries to say is said by the parent instead.
		parent.say(message)
		return 1
	return ..(message)


/mob/living/silicon/ai/render_speaker_track_start(var/datum/speech/speech)
	//this proc assumes that the message originated from a radio. if the speaker is not a virtual speaker this will probably fuck up hard.
	var/mob/M = speech.speaker.GetSource()

	var/atom/movable/virt_speaker = speech.radio
	if(!virt_speaker || !istype(virt_speaker, /obj/item/device/radio))
		virt_speaker = src
	if(speech.speaker != src && M != src)
		if(M)
			var/track_link = "byond://?src=\ref[src];track=[url_encode(speech.name)]"
			return "<a href='byond://?src=\ref[virt_speaker];open2=\ref[src];open=\ref[M]'>\[OPEN\]</a> <a href='[track_link]'>"
	return ""

/mob/living/silicon/ai/render_speaker_track_end(var/datum/speech/speech)
	//this proc assumes that the message originated from a radio. if the speaker is not a virtual speaker this will probably fuck up hard.
	var/mob/M = speech.speaker.GetSource()

	var/atom/movable/virt_speaker = speech.radio
	if(!virt_speaker || !istype(virt_speaker, /obj/item/device/radio))
		virt_speaker = src
	if(speech.speaker != src && M != src)
		if(M)
			return "</a>"
	return ""


/mob/living/silicon/ai/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, [text]";
	else if (ending == "!")
		return "declares, [text]";

	return "states, [text]";

/mob/living/silicon/ai/IsVocal()
	return !config.silent_ai

/mob/living/silicon/ai/get_message_mode(message)
	. = ..()
	if(!. && istype(current, /obj/machinery/hologram/holopad))
		return MODE_HOLOPAD

/mob/living/silicon/ai/handle_inherent_channels(var/datum/speech/speech, var/message_mode)
	say_testing(src, "[type]/handle_inherent_channels([message_mode])")

	if(..(speech, message_mode))
		return 1

	if(message_mode == MODE_HOLOPAD)
		holopad_talk(speech)
		return 1

//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(var/datum/speech/speech)
	say_testing(src, "[type]/holopad_talk()")
	var/turf/turf = get_turf(src)
	log_say("[key_name(src)] (@[turf.x],[turf.y],[turf.z]) Holopad: [speech.message]")

	speech.message = trim(speech.message)

	if (!speech.message)
		return

	var/obj/machinery/hologram/holopad/T = current
	if(istype(T) && T.holo && T.master == src)//If there is a hologram and its master is the user.
		if(T.advancedholo)	//send the speech from the hologram itself if its an 'advanced' hologram
			speech.name = T.holo.name
			T.holo.send_speech(speech, 7)
		else
			T.send_speech(speech, 7, "R")
		to_chat(src, "<i><span class='[speech.render_wrapper_classes()]'>Holopad transmitted, <span class='name'>[speech.name]</span> [speech.render_message()]</span></i>")//The AI can "hear" its own message.

	else
		to_chat(src, "No holopad connected.")
	return

/*
 * This is effectly the exact same code as ..().
 * The only difference is the source != current check, which also does the same thing.
/mob/living/silicon/ai/send_speech(var/datum/speech/speech, var/message_range, var/bubble_type)
	if(isnull(message_range))
		message_range = 7
	if(source != current)
		return ..()

	var/list/listeners = new/list()

	for (var/mob/living/L in get_hearers_in_view(message_range, speech.speaker))
		listeners.Add(L)

	listeners.Add(observers)

	var/rendered = compose_message(src, speaking, message)

	for (var/atom/movable/listener in listeners)
		if (listener)
			listener.Hear(rendered, src, speaking, message)

	send_speech_bubble(message, bubble_type, listeners)
*/

var/announcing_vox = 0 // Stores the time of the last announcement
var/const/VOX_CHANNEL = 200
var/const/VOX_DELAY = 600
var/VOX_AVAILABLE_VOICES = list(
	"fem" = "Feminine"//,
//	"mas" = "Masculine"
);

#ifndef DISABLE_VOX
/mob/living/silicon/ai/verb/make_announcement()
	set name = "Make Announcement"
	set desc = "Display a list of vocal words to announce to the crew."
	set category = "AI Commands"


	var/dat = list("Here, you can type a message that will be played to the entire z-level.<br> \
	<fieldset><legend>Rules</legend><ul>\
	<li>You can only say 32 words for every announcement.</li>\
	<li>Do not use punctuation as you would normally: if you want a pause you can use the full stop and comma characters by separating them with spaces, like so: 'Alpha . Test , Bravo'.</li>\
	<li>Special sound effects are available, and start with a &quot;_&quot; prefix. e.g. _honk</li></ul>\
	<span class='bad'><strong>WARNING:</strong> Misuse of the announcement system <em>will</em> get you job banned.</span>\
	</fieldset>")

	if(cancorruptvox())
		dat += "<fieldset><legend>Corruption</legend><ul>"
		dat += "<li>"
		if(vox_corrupted)
			dat += "<strong>"
		dat += "<a href=;?src=\ref[src];voice_corrupted=[!vox_corrupted]>[vox_corrupted ? "On" : "Off"]</a>"
		if (vox_corrupted)
			dat += "</strong>"
		dat += "</li></ul><p>Your laws are corrupted, this option allows you to speak in a befitting manner.</p></fieldset>"

	dat += "<fieldset><legend>Voice</legend><ul>"
	for(var/voice_id in VOX_AVAILABLE_VOICES)
		dat += "<li>"
		if (voice_id == src.vox_voice)
			dat += "<strong>"
		dat += "<a href=;?src=\ref[src];set_voice=[voice_id]>[VOX_AVAILABLE_VOICES[voice_id]]</a>"
		if (voice_id == src.vox_voice)
			dat += "</strong>"
		dat += "</li>"
	dat += "</ul><p><strong>NOTE:</strong> Each voice has its own unique quirks. Don't expect the same outcomes!</p></fieldset>"
	dat += "<div class='formline'><input type='text' name='words' id='words' placeholder='Words go here' /> <span id='wordcount'>0</span> <button id='reset' type='button'>Clear</button><button id='submit' type='button'>Announce</button></div>"
	dat += "<ul id='errors'></div>"

	//var/index = 0
	var/list/wordlist = list()
	for(var/word in vox_sounds[vox_voice])
		//index++
		wordlist += word
		//dat += "<A href='?src=\ref[src];say_word=[word]'>[capitalize(word)]</A>"
		//if(index != vox_sounds[vox_voice].len)
		//	dat += " / "

	dat += "<script type='text/javascript'>window.airef=\"\ref[src]\";window.availableWords = "
	dat += json_encode(wordlist)
	dat += ";</script>"
	dat = jointext(dat,"")
	var/datum/browser/popup = new(src, "announce", "Make Announcement", 500, 400)
	popup.add_script("jquery", 'code/modules/html_interface/jquery.min.js')
	popup.add_script("jquery.autocomplete", 'code/modules/html_interface/jquery.autocomplete.min.js')
	popup.add_script("aivoice", 'html/aivoice.js')
	popup.add_stylesheet("aivoice", 'html/browser/aivoice.css')
	popup.set_content(dat)
	//text2file(popup.get_content(), "AISAYTEST.htm")
	popup.open()

/mob/living/silicon/ai/proc/cancorruptvox()
	if(ismalf(src))
		return TRUE
	if(!isemptylist(laws.ion))
		return TRUE
	return FALSE

/mob/living/silicon/ai/proc/announcement_checks()
	//I am kill but here
	if(isUnconscious())
		to_chat(usr, "Not while you're incapacitated.")
		return FALSE

	if(istype(usr,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = usr
		if(AI.control_disabled)
			to_chat(usr, "Wireless control is disabled!")
			return FALSE

	if(announcing_vox > world.time)
		to_chat(src, "<span class='notice'>Please wait [round((announcing_vox - world.time) / 10)] seconds.</span>")
		return FALSE

	return TRUE

/mob/living/silicon/ai/proc/play_announcement(var/message)
	set waitfor = FALSE
	last_announcement = message
	if(!message || announcing_vox > world.time)
		return

	var/exception = FALSE
	if (message == "voxtest5")// Not sure how many words exactly it's counting in that one but more than 32 for sure and the decimal might also hinder the count
		exception = TRUE

	var/list/words = splittext(trim(message), " ")
	var/list/incorrect_words = list()

	if(words.len > 32)
		words.len = 32

	var/total_word_len=0
	for(var/word in words)
		word = lowertext(trim(word))
		if(!word)
			words -= word
			continue
		if(!vox_sounds[vox_voice][word])
			incorrect_words += word
		// Thank Rippetoe for this!
		var/wordlen = 1
		if(word in vox_wordlen)
			wordlen=vox_wordlen[word]
		if(!exception && (total_word_len+wordlen>50))
			to_chat(src, "<span class='notice'>There are too many words in this announcement.</span>")
			return
		total_word_len+=wordlen

	if(incorrect_words.len)
		to_chat(src, "<span class='notice'>These words are not available on the announcement system: [english_list(incorrect_words)].</span>")
		return

	announcing_vox = world.time + VOX_DELAY


	log_game("[key_name_admin(src)] made a vocal announcement with the following message: [message].")

	// Same logic as play_vox_sound, so everyone that can hear the sound sees this.
	/* Widely disliked. Uncomment if you want it back.
	for(var/mob/M in player_list)
		if(M.client)
			var/turf/T = get_turf(M)
			if(T.z == src.z)
				to_chat(M, "<span class='notice'>[src] announces: <span class='big'>\"[message]\"</span>.</span>")
	*/
	if(!cancorruptvox())
		vox_corrupted = FALSE // this is to stop a sudden malf/ion making the announcement corrupt if it was on previously.
	var/freq = 1

	var/turf/T = get_turf(src)

	for(var/word in words)
		if(vox_corrupted && cancorruptvox())

			freq = rand(11000,21000) // mas/fem VOX standard bit rate is 16000.
			if(freq>20450)
				for(var/i=0,i<rand(2,4),i++) //repeat hig pitched words and then say it in low pitch like shodan
					freq = freq + (freq/5)
					play_vox_word(word, vox_voice, T.z, null, TRUE, freq)
				freq = rand(11000,14000)
			play_vox_word(word, vox_voice, T.z, null, TRUE, freq)
		else
			//play it normally
			play_vox_word(word, vox_voice, T.z, null, TRUE, freq)



#endif // DISABLE_VOX

var/list/vox_digits=list(
	'sound/AI/one.ogg',
	'sound/AI/two.ogg',
	'sound/AI/three.ogg',
	'sound/AI/four.ogg',
	'sound/AI/five.ogg',
	'sound/AI/six.ogg',
	'sound/AI/seven.ogg',
	'sound/AI/eight.ogg',
	'sound/AI/nine.ogg',
	'sound/AI/ten.ogg',
	'sound/AI/eleven.ogg',
	'sound/AI/twelve.ogg',
	'sound/AI/thirteen.ogg',
	'sound/AI/fourteen.ogg',
	'sound/AI/fifteen.ogg',
	'sound/AI/sixteen.ogg',
	'sound/AI/seventeen.ogg',
	'sound/AI/eighteen.ogg',
	'sound/AI/nineteen.ogg'
)

var/list/vox_tens=list(
	null,
	null,
	'sound/AI/twenty.ogg',
	'sound/AI/thirty.ogg',
	'sound/AI/fourty.ogg',
	'sound/AI/fifty.ogg',
	'sound/AI/sixty.ogg',
	'sound/AI/seventy.ogg',
	'sound/AI/eighty.ogg',
	'sound/AI/ninety.ogg'
)

var/list/vox_units=list(
	null, // Don't yell units
	'sound/AI/thousand.ogg',
	'sound/AI/million.ogg',
	'sound/AI/billion.ogg' // Yell at N3X15 if you somehow get to the point where you suddenly need "trillion"
)

/proc/vox_num2list(var/number)
	return num2words(number, zero='sound/AI/zero.ogg', minus='sound/AI/minus.ogg', hundred='sound/AI/hundred.ogg', digits=vox_digits, tens=vox_tens, units=vox_units)

/proc/play_vox_word(var/word, var/voice, var/z_level, var/mob/only_listener, var/do_sleep=FALSE, var/frequency=1)
	. = TRUE

	word = lowertext(word)
	var/soundFile = vox_sounds[voice][word]
	if(soundFile)
		. = play_vox_sound(soundFile,z_level,only_listener, frequency)
		if (do_sleep)
			//sleep(vox_sound_lengths[soundFile] SECONDS)
			sleep(vox_sound_lengths[soundFile])

/proc/play_vox_sound(var/sound_file, var/z_level, var/mob/only_listener, var/frequency=1)
	var/sound/voice = sound(sound_file, wait = 1, channel = VOX_CHANNEL)
	voice.status = SOUND_STREAM
	voice.frequency = frequency
	// If there is no single listener, broadcast to everyone in the same z level
	if(!only_listener)
		// Play voice for all mobs in the z level
		for(var/mob/M in player_list)
			if(M.client)
				var/turf/T = get_turf(M)
				if(T.z == z_level)
					M << voice
	else
		only_listener << voice

	return TRUE
