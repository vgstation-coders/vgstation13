/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"

	if(say_disabled)
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return
	usr.say(message)
	remove_typing_indicator()

/mob/verb/whisper(message as text)
	set name = "Whisper"
	set category = "IC"
	return
/*
/mob/proc/whisper(var/message, var/unheard=" whispers something", var/heard="whispers,", var/apply_filters=1, var/allow_lastwords=1)
	return
*/

/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		remove_typing_indicator()
		return

	if(!usr.stat && (usr.status_flags & FAKEDEATH))
		to_chat(usr, "<span class='danger'>Doing this will give us away!</span>")
		remove_typing_indicator()
		return

	message = html_encode(sanitize_speech(message))

	if(usr.stat == DEAD)
		usr.emote_dead(message)
	else if(message)
		usr.emote("me",usr.emote_type,message)
	remove_typing_indicator()

/datum/deadchat_listener //This datum allows you to read the currently funky deadchat. Simply make a child, instantiate an instance, and add functions to add/remove it from the global_deadchat_listeners.
	var/name = "default"

/datum/deadchat_listener/proc/deadchat_event(var/ckey, var/message)
	return

var/list/global_deadchat_listeners = list()

/mob/proc/say_dead(var/message)
	var/name = src.real_name
	var/alt_name = ""

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(client && !(client.prefs.toggles & CHAT_DEAD))
		to_chat(usr, "<span class='danger'>You have deadchat muted.</span>")
		return

	if(mind && mind.name)
		name = "[mind.name]"
	else
		name = real_name
	if(name != real_name)
		alt_name = " (died as [real_name])"

	var/ckey = "[key_name(src)]"
	for(var/datum/deadchat_listener/listener in global_deadchat_listeners)
		listener.deadchat_event(ckey,message)
	message = src.say_quote("\"[html_encode(message)]\"")
	var/location_text = get_coordinates_string(src)
	log_say("[name]/[key_name(src)] (@[location_text]) Deadsay: [message]")

	var/list/hearers = get_deadchat_hearers()
	if(hearers)
		for(var/mob/M in hearers)
			var/rendered = "<span class='game deadsay'><a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>(Follow)</a>"
			rendered += "<span class='name'> [name]</span>[alt_name] <span class='message'>[message]</span></span>"
			to_chat(M, rendered)

/mob/proc/get_ear()
	// returns an atom representing a location on the map from which this
	// mob can hear things

	// should be overloaded for all mobs whose "ear" is separate from their "mob"

	return get_turf(src)

/mob/proc/lingcheck()
	return 0

/mob/proc/cult_chat_check(var/setting)
	return 0

/mob/proc/hivecheck()
	return 0

/mob/proc/binarycheck()
	return 0

//parses the language code (e.g. :j) from text, such as that supplied to say.
//returns the language object only if the code corresponds to a language that src can speak, otherwise null.
/mob/proc/parse_language(var/message)
	if(length(message) >= 2)
		var/language_prefix = lowertext(copytext(message, 1 ,3))
		if(language_prefix in language_keys)
			var/datum/language/L = language_keys[language_prefix]
			if (can_speak_lang(L))
				return L
			else
				if(istype(L))
					say_testing(src, "Tried to speak [L.name] but don't know it, prefix length is [length(language_prefix)] before [message] after [copytext(message, 1+length(language_prefix))]")
					return language_prefix

	return null

/mob/say_understands(var/mob/other,var/datum/language/speaking = null)
	if (src.stat == 2)		//Dead
		return 1

	//Universal speak makes everything understandable, for obvious reasons.
	if(src.universal_speak || src.universal_understand)
		return 1

	//Languages are handled after.
	if (!speaking)
		if(other)
			other = other.GetSource()
		if(!other || !ismob(other))
			return 1
		if(other.universal_speak)
			return 1
		if(isAI(src) && ispAI(other))
			return 1
		if (istype(other, src.type) || istype(src, other.type))
			return 1
		return 0

	//Language check.
	for(var/datum/language/L in src.languages)
		if(speaking.name == L.name)
			return 1
	return 0

/mob/proc/can_read()
	if(stat == DEAD || universal_understand)
		return TRUE
	return FALSE

/mob/proc/forcesay(list/append)
	if(stat == CONSCIOUS)
		if(client)
			var/virgin = 1	//has the text been modified yet?
			var/temp = winget(client, "input", "text")
			if(findtext(temp, "Say \"", 1, 7) && length(temp) > 5) //NOT case sensitive, because both "say" and "Say" can happen

				temp = replacetext(temp, ";", "")	//general radio

				if(findtext(trim_left(temp), ":", 6, 7))	//dept radio
					temp = copytext(trim_left(temp), 8)
					virgin = 0

				if(virgin)
					temp = copytext(trim_left(temp), 6)	//normal speech
					virgin = 0

				while(findtext(trim_left(temp), ":", 1, 2))	//dept radio again (necessary)
					temp = copytext(trim_left(temp), 3)

				if(findtext(temp, "*", 1, 2))	//emotes
					return

				var/trimmed = trim_left(temp)
				if(length(trimmed))
					if(append)
						temp += pick(append)

					say(temp)
				winset(client, "input", "text=[null]")