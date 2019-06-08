
var/cultwords_initialized = 0
var/list/cultwords = list()//datums go in here
var/list/cultwords_english = list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")
var/list/cultwords_rune = list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri")
var/list/cultwords_icons = list("rune-1","rune-2","rune-4","rune-8","rune-16","rune-32","rune-64","rune-128", "rune-256", "rune-512")

/datum/cultword
	var/english		= "word"//don't change those
	var/rune		= "zek'kon"
	var/icon		= 'icons/effects/uristrunes.dmi'
	var/icon_state	= ""
	var/color//used by path rune markers

/proc/initialize_cultwords()
	if (cultwords_initialized)
		return
	for(var/subtype in subtypesof(/datum/cultword))
		var/datum/cultword/new_word = new subtype()
		cultwords[new_word.english] = new_word
	cultwords_initialized = 1

//for now we're not calling it anywhere, but should we want to randomize words again later, that's what that proc is for.
/proc/randomize_cultwords()
	var/list/available_rnwords = cultwords_rune
	var/list/available_icons = cultwords_icons
	for(var/datum/cultword/cultword in cultwords)
		var/picked_rnword = pick(available_rnwords)
		var/picked_icon = pick(available_icons)
		cultword.rune = picked_rnword
		cultword.icon_state = picked_icon
		available_rnwords.Remove(picked_rnword)
		available_icons.Remove(picked_icon)

	for (var/obj/effect/rune/rune in rune_list)
		rune.update_icon()

/datum/cultword/travel
	english		= "travel"
	rune		= "ire"
	icon_state	= "rune-1"
	color = "yellow"

/datum/cultword/blood
	english		= "blood"
	rune		= "ego"
	icon_state	= "rune-2"
	color = "maroon"

/datum/cultword/join
	english		= "join"
	rune		= "nahlizet"
	icon_state	= "rune-4"
	color = "green"

/datum/cultword/hell
	english		= "hell"
	rune		= "certum"
	icon_state	= "rune-8"
	color = "red"

/datum/cultword/destroy
	english		= "destroy"
	rune		= "veri"
	icon_state	= "rune-16"
	color = "purple"

/datum/cultword/technology
	english		= "technology"
	rune		= "jatkaa"
	icon_state	= "rune-32"
	color = "blue"

/datum/cultword/self
	english		= "self"
	rune		= "mgar"
	icon_state	= "rune-64"
	color = null

/datum/cultword/see
	english		= "see"
	rune		= "balaq"
	icon_state	= "rune-128"
	color = "fuchsia"

/datum/cultword/other
	english		= "other"
	rune		= "karazet"
	icon_state	= "rune-256"
	color = "teal"

/datum/cultword/hide
	english		= "hide"
	rune		= "geeri"
	icon_state	= "rune-512"
	color = "silver"
