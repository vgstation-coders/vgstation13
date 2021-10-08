
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
	var/offset_x	= 0
	var/offset_y	= 0

/proc/initialize_rune_words()
	if (rune_words_initialized)
		return
	for(var/subtype in subtypesof(/datum/rune_word))
		var/datum/rune_word/new_word = new subtype()
		rune_words[new_word.english] = new_word
	rune_words_initialized = 1

/datum/rune_word/travel
	english		= "travel"
	rune		= "ire"
	icon_state	= "rune-1"
	color 		= "yellow"
	offset_x	= 6
	offset_y	= -5

/datum/rune_word/blood
	english		= "blood"
	rune		= "ego"
	icon_state	= "rune-2"
	color 		= "maroon"
	offset_x	= 0
	offset_y	= 5

/datum/rune_word/join
	english		= "join"
	rune		= "nahlizet"
	icon_state	= "rune-4"
	color 		= "green"
	offset_x	= 2
	offset_y	= 1

/datum/rune_word/hell
	english		= "hell"
	rune		= "certum"
	icon_state	= "rune-8"
	color 		= "red"
	offset_x	= 0
	offset_y	= 10

/datum/rune_word/destroy
	english		= "destroy"
	rune		= "veri"
	icon_state	= "rune-16"
	color 		= "purple"
	offset_x	= 10
	offset_y	= 3

/datum/rune_word/technology
	english		= "technology"
	rune		= "jatkaa"
	icon_state	= "rune-32"
	color 		= "blue"
	offset_x	= -10
	offset_y	= 1

/datum/rune_word/self
	english		= "self"
	rune		= "mgar"
	icon_state	= "rune-64"
	color 		= null
	offset_x	= -6
	offset_y	= -9

/datum/rune_word/see
	english		= "see"
	rune		= "balaq"
	icon_state	= "rune-128"
	color 		= "fuchsia"
	offset_x	= 10
	offset_y	= -11

/datum/rune_word/other
	english		= "other"
	rune		= "karazet"
	icon_state	= "rune-256"
	color 		= "teal"
	offset_x	= -8
	offset_y	= 8

/datum/rune_word/hide
	english		= "hide"
	rune		= "geeri"
	icon_state	= "rune-512"
	color 		= "silver"
	offset_x	= -2
	offset_y	= -1
