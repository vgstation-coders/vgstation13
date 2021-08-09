
var/rune_words_initialized = 0
var/list/rune_words = list()//datums go in here
var/list/rune_words_english = list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")
var/list/rune_words_rune = list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri")
var/list/rune_words_icons = list("rune-1","rune-2","rune-4","rune-8","rune-16","rune-32","rune-64","rune-128", "rune-256", "rune-512")

/datum/rune_word
	var/english		= "word"//don't change those
	var/rune		= "zek'kon"
	var/icon		= 'icons/effects/uristrunes.dmi'
	var/icon_state	= ""
	var/color//used by path rune markers

/proc/initialize_rune_words()
	if (rune_words_initialized)
		return
	for(var/subtype in subtypesof(/datum/rune_word))
		var/datum/rune_word/new_word = new subtype()
		rune_words[new_word.english] = new_word
	rune_words_initialized = 1

//for now we're not calling it anywhere, but should we want to randomize words again later, that's what that proc is for.
/proc/randomize_rune_words()
	var/list/available_rnwords = rune_words_rune
	var/list/available_icons = rune_words_icons
	for(var/datum/rune_word/rune_word in rune_words)
		var/picked_rnword = pick(available_rnwords)
		var/picked_icon = pick(available_icons)
		rune_word.rune = picked_rnword
		rune_word.icon_state = picked_icon
		available_rnwords.Remove(picked_rnword)
		available_icons.Remove(picked_icon)

	for (var/obj/effect/rune/rune in rune_list)
		rune.update_icon()

/datum/rune_word/travel
	english		= "travel"
	rune		= "ire"
	icon_state	= "rune-1"
	color = "yellow"

/datum/rune_word/blood
	english		= "blood"
	rune		= "ego"
	icon_state	= "rune-2"
	color = "maroon"

/datum/rune_word/join
	english		= "join"
	rune		= "nahlizet"
	icon_state	= "rune-4"
	color = "green"

/datum/rune_word/hell
	english		= "hell"
	rune		= "certum"
	icon_state	= "rune-8"
	color = "red"

/datum/rune_word/destroy
	english		= "destroy"
	rune		= "veri"
	icon_state	= "rune-16"
	color = "purple"

/datum/rune_word/technology
	english		= "technology"
	rune		= "jatkaa"
	icon_state	= "rune-32"
	color = "blue"

/datum/rune_word/self
	english		= "self"
	rune		= "mgar"
	icon_state	= "rune-64"
	color = null

/datum/rune_word/see
	english		= "see"
	rune		= "balaq"
	icon_state	= "rune-128"
	color = "fuchsia"

/datum/rune_word/other
	english		= "other"
	rune		= "karazet"
	icon_state	= "rune-256"
	color = "teal"

/datum/rune_word/hide
	english		= "hide"
	rune		= "geeri"
	icon_state	= "rune-512"
	color = "silver"
