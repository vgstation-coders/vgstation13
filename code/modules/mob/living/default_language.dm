/mob/living
	var/datum/language/default_language
	var/datum/language/init_language = null

// get_spoken_languages() instead of languages: universal speak lets the mob
// speak languages that are not in the languages list.
/mob/living/verb/set_default_language(language as null|anything in get_spoken_languages())
	set name = "Set Default Language"
	set category = "IC"

	if (!language)
		to_chat(src, "<span class='notice'>You will now speak whatever your standard default language is if you do not specify one when speaking.</span>")
		default_language = init_language
		return

	if(!(language in get_spoken_languages()))
		to_chat(src, "<span class='warning'>You try mouthing a few words to yourself before realizing you have no idea how to speak [language]. Idiot.</span>")
		return

	if(language)
		to_chat(src, "<span class='notice'>You will now speak [language] if you do not specify a language when speaking.</span>")
	default_language = language

/mob/living/verb/check_default_language()
	set name = "Check Default Language"
	set category = "IC"

	if(default_language)
		to_chat(src, "<span class='notice'>You are currently speaking [default_language] by default.</span>")
	else
		to_chat(src, "<span class='notice'>Your current default language is your species or mob type default.</span>")
