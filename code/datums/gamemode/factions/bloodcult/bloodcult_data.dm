var/runetypes_initialized = 0

/datum/runetype //Abstract base class
	var/english		= "word"
	var/rune		= "zek'kon"
	var/icon		= 'icons/effects/uristrunes.dmi'
	var/icon_state	= ""
	var/list/uristrune_cache = list() //Icon cache, so the whole blending process is only done once per rune.
	var/list/words = list()
	var/list/rune_list = list() //List of all runes, used for various purposes.
	var/list/words_english
	var/list/words_rune
	var/list/words_icons

/datum/runetype/blood_cult //Real cultists
	list/words_english = list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")
	list/words_rune = list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri")
	list/words_icons = list("rune-1","rune-2","rune-4","rune-8","rune-16","rune-32","rune-64","rune-128", "rune-256", "rune-512")
	var/color     //Used by path rune markers
	
/datum/runetype/friendly_cult //Friendly cultists, intended for silicons
	list/words_english = list("friend","love","hug")
	list/words_rune = list("mgor","nohlizot","jotkoo")
	list/words_icons = list("rune-1","rune-2","rune-4")
	
/proc/initialize_runetypes()
	if(runetypes_initialized)
		return
	for(var/runetype in subtypesof(/datum/runetype))
		for(var/word_info in subtypesof(runetype))
			var/datum/new_word = new word_info() //Gets all words, makes copies of them, then puts them in the list() words mapped to their english word as key.
			runetype/words[new_word.english] = new_word
	runetypes_initialized = 1

/* //Outdated as of June 2019. Worked with previous system, but was never used anyway.
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
*/ 

/datum/runetype/blood_cult/travel
	english		= "travel"
	rune		= "ire"
	icon_state	= "rune-1"
	color = "yellow"
 
/datum/runetype/blood_cult/blood
	english		= "blood"
	rune		= "ego"
	icon_state	= "rune-2"
	color = "maroon"

/datum/runetype/blood_cult/join
	english		= "join"
	rune		= "nahlizet"
	icon_state	= "rune-4"
	color = "green"

/datum/runetype/blood_cult/hell
	english		= "hell"
	rune		= "certum"
	icon_state	= "rune-8"
	color = "red"

/datum/runetype/blood_cult/destroy
	english		= "destroy"
	rune		= "veri"
	icon_state	= "rune-16"
	color = "purple"

/datum/runetype/blood_cult/technology
	english		= "technology"
	rune		= "jatkaa"
	icon_state	= "rune-32"
	color = "blue"

/datum/runetype/blood_cult/self
	english		= "self"
	rune		= "mgar"
	icon_state	= "rune-64"
	color = null

/datum/runetype/blood_cult/see
	english		= "see"
	rune		= "balaq"
	icon_state	= "rune-128"
	color = "fuchsia"

/datum/runetype/blood_cult/other
	english		= "other"
	rune		= "karazet"
	icon_state	= "rune-256"
	color = "teal"

/datum/runetype/blood_cult/hide
	english		= "hide"
	rune		= "geeri"
	icon_state	= "rune-512"
	color = "silver"
