/mob/living/silicon/ai/say(var/message)
	if(loc.loc && istype(loc.loc,/obj/item/weapon/storage/belt/silicon)) //loc would be an aicard in this case
		RenderBeltChat(loc.loc,src,message)
		return
	if(parent && istype(parent) && parent.stat != 2) //If there is a defined "parent" AI, it is actually an AI, and it is alive, anything the AI tries to say is said by the parent instead.
		parent.say(message)
		return
	..(message)


/mob/living/silicon/ai/render_speaker_track_start(var/datum/speech/speech)
	//this proc assumes that the message originated from a radio. if the speaker is not a virtual speaker this will probably fuck up hard.
	var/mob/M = speech.speaker.GetSource()

	var/atom/movable/virt_speaker = speech.radio
	if(!virt_speaker || !istype(virt_speaker, /obj/item/device/radio))
		virt_speaker = src
	if(speech.speaker != src && M != src)
		if(M)
			var/faketrack = "byond://?src=\ref[virt_speaker];track2=\ref[src];track=\ref[M]"
			if(speech.speaker.GetTrack())
				faketrack = "byond://?src=\ref[virt_speaker];track2=\ref[src];faketrack=\ref[M]"

			return "<a href='byond://?src=\ref[virt_speaker];open2=\ref[src];open=\ref[M]'>\[OPEN\]</a> <a href='[faketrack]'>"
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
		T.send_speech(speech, 7, "R")
		to_chat(src, "<i><span class='[speech.render_wrapper_classes()]'>Holopad transmitted, <span class='name'>[real_name]</span> [speech.render_message()]</span></i>")//The AI can "hear" its own message.

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
	"fem" = "Feminine",
	"mas" = "Masculine"
);

// N3X TODO: Make a JS clientside validation and autosuggest thing.
/mob/living/silicon/ai/verb/make_announcement()
	set name = "Make Announcement"
	set desc = "Display a list of vocal words to announce to the crew."
	set category = "AI Commands"


	var/dat = list("Here is a list of words you can type into the 'Announcement' button to create sentences to vocally announce to everyone on the same level at you.<BR> \
	<UL><LI>You can also click on the word to preview it.</LI>\
	<LI>You can only say 30 words for every announcement.</LI>\
	<LI>Do not use punctuation as you would normally: if you want a pause you can use the full stop and comma characters by separating them with spaces, like so: 'Alpha . Test , Bravo'.</LI>\
	<LI>Special sound effects are available, and start with a &quot;_&quot; prefix. e.g. _honk</LI></UL>\
	<font class='bad'>WARNING:</font><BR>Misuse of the announcement system will get you job banned.<HR>")

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

/mob/living/silicon/ai/proc/announcement_checks()
	//I am kill but here
	if(isUnconscious())
		return FALSE

	// If we're in an APC, and APC is ded, ABORT
	if(parent && istype(parent) && parent.stat)
		to_chat(usr, "You're in a dead APC, no")
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
	last_announcement = message

	if(!message || announcing_vox > world.time)
		return

	var/list/words = splittext(trim(message), " ")
	var/list/incorrect_words = list()

	if(words.len > 30)
		words.len = 30

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
		if(total_word_len+wordlen>50)
			to_chat(src, "<span class='notice'>There are too many words in this announcement.</span>")
			return
		total_word_len+=wordlen

	if(incorrect_words.len)
		to_chat(src, "<span class='notice'>These words are not available on the announcement system: [english_list(incorrect_words)].</span>")
		return

	announcing_vox = world.time + VOX_DELAY

	log_game("[key_name_admin(src)] made a vocal announcement with the following message: [message].")

	for(var/word in words)
		play_vox_word(word, vox_voice, src.z, null)
/*
/mob/living/silicon/ai/verb/announcement()
	set name = "Announcement"
	set desc = "Send an announcement to the crew"
	set category = "AI Commands"

	if(!announcement_checks())
		return

	var/message = input(src, "WARNING: Misuse of this verb can result in you being job banned. More help is available in 'Announcement Help'", "Announcement", src.last_announcement) as text

	play_announcement(message)
*/

var/list/vox_digits=list(
	'sound/vox_fem/one.ogg',
	'sound/vox_fem/two.ogg',
	'sound/vox_fem/three.ogg',
	'sound/vox_fem/four.ogg',
	'sound/vox_fem/five.ogg',
	'sound/vox_fem/six.ogg',
	'sound/vox_fem/seven.ogg',
	'sound/vox_fem/eight.ogg',
	'sound/vox_fem/nine.ogg',
	'sound/vox_fem/ten.ogg',
	'sound/vox_fem/eleven.ogg',
	'sound/vox_fem/twelve.ogg',
	'sound/vox_fem/thirteen.ogg',
	'sound/vox_fem/fourteen.ogg',
	'sound/vox_fem/fifteen.ogg',
	'sound/vox_fem/sixteen.ogg',
	'sound/vox_fem/seventeen.ogg',
	'sound/vox_fem/eighteen.ogg',
	'sound/vox_fem/nineteen.ogg'
)

var/list/vox_tens=list(
	null,
	null,
	'sound/vox_fem/twenty.ogg',
	'sound/vox_fem/thirty.ogg',
	'sound/vox_fem/fourty.ogg',
	'sound/vox_fem/fifty.ogg',
	'sound/vox_fem/sixty.ogg',
	'sound/vox_fem/seventy.ogg',
	'sound/vox_fem/eighty.ogg',
	'sound/vox_fem/ninety.ogg'
)

var/list/vox_units=list(
	null, // Don't yell units
	'sound/vox_fem/thousand.ogg',
	'sound/vox_fem/million.ogg',
	'sound/vox_fem/billion.ogg' // Yell at N3X15 if you somehow get to the point where you suddenly need "trillion"
)

/proc/vox_num2list(var/number)
	return num2words(number, zero='sound/vox_fem/zero.ogg', minus='sound/vox_fem/minus.ogg', hundred='sound/vox_fem/hundred.ogg', digits=vox_digits, tens=vox_tens, units=vox_units)

/proc/play_vox_word(var/word, var/voice, var/z_level, var/mob/only_listener)
	word = lowertext(word)
	if(vox_sounds[voice][word])
		return play_vox_sound(vox_sounds[voice][word],z_level,only_listener)
	return 0


/proc/play_vox_sound(var/sound_file, var/z_level, var/mob/only_listener)
	var/sound/voice = sound(sound_file, wait = 1, channel = VOX_CHANNEL)
	voice.status = SOUND_STREAM

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
	return 1
