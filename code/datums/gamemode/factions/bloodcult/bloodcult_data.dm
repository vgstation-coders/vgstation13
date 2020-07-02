var/runesets_initialized = 0
var/list/global_runesets = list()

/datum/runeset //Abstract base class
	var/identifier  //Key mapped to this runeset in runesets. Also used to sync runewords and runesets
	var/list/rune_list = list() //List of all runes, used for various purposes.
	var/list/words = list()
	var/list/words_english = list()
	var/list/words_rune = list()
	var/list/words_icons = list()
	
/proc/initialize_runesets()
	if(runesets_initialized)
		return
	for(var/runeset_cast in subtypesof(/datum/runeset))
		var/datum/runeset/rune_set = new runeset_cast()
		for(var/wordset_cast in subtypesof(/datum/runeword))
			var/datum/runeword/word_set = new wordset_cast()
			if(rune_set.identifier == word_set.identifier)
				global_runesets[rune_set.identifier] = rune_set
				for(var/word_info in subtypesof(word_set))
					var/datum/runeword/new_word = new word_info()
					if(new_word.english)
						rune_set.words[new_word.english] = new_word	
				global_runesets[rune_set.identifier] = rune_set
	runesets_initialized = 1

/datum/runeset/blood_cult //Real cultists
	identifier = "blood_cult"
	//Hard-coded lists, used by various things for ease of access. Should probably code the initialize_runesets to automatically make these, but whatever.
	words_english = list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")
	words_rune = list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri")
	words_icons = list("rune-1","rune-2","rune-4","rune-8","rune-16","rune-32","rune-64","rune-128", "rune-256", "rune-512")
	
	
	
	
/datum/runeword
	var/identifier
	var/english
	var/rune
	var/icon		= 'icons/effects/uristrunes.dmi'
	var/icon_state	= ""

/datum/runeword/blood_cult
	identifier = "blood_cult"
	icon = 'icons/effects/uristrunes.dmi'
	icon_state = ""
	var/color    //Used by path rune markers
	
/datum/runeword/blood_cult/travel
	english		= "travel"
	rune		= "ire"
	icon_state	= "rune-1"
	color = "yellow"
 
/datum/runeword/blood_cult/blood
	english		= "blood"
	rune		= "ego"
	icon_state	= "rune-2"
	color = "maroon"

/datum/runeword/blood_cult/join
	english		= "join"
	rune		= "nahlizet"
	icon_state	= "rune-4"
	color = "green"

/datum/runeword/blood_cult/hell
	english		= "hell"
	rune		= "certum"
	icon_state	= "rune-8"
	color = "red"

/datum/runeword/blood_cult/destroy
	english		= "destroy"
	rune		= "veri"
	icon_state	= "rune-16"
	color = "purple"

/datum/runeword/blood_cult/technology
	english		= "technology"
	rune		= "jatkaa"
	icon_state	= "rune-32"
	color = "blue"

/datum/runeword/blood_cult/self
	english		= "self"
	rune		= "mgar"
	icon_state	= "rune-64"
	color = null

/datum/runeword/blood_cult/see
	english		= "see"
	rune		= "balaq"
	icon_state	= "rune-128"
	color = "fuchsia"

/datum/runeword/blood_cult/other
	english		= "other"
	rune		= "karazet"
	icon_state	= "rune-256"
	color = "teal"

/datum/runeword/blood_cult/hide
	english		= "hide"
	rune		= "geeri"
	icon_state	= "rune-512"
	color = "silver"
