// -- Abstract
/datum/config_flag
	var/text_name = "Abstract"
	var/value = null

	// Currently only "config" & "game_options"
	// There's no consistency as to what goes in one and what goes into the other.
	// You're on your own
	var/category = "config"

/datum/config_flag/proc/load(var/raw_string)
	value = raw_string

// -- list of string
/datum/config_flag/list_string
	text_name = "Abstract"
	var/delimiter = " "

/datum/config_flag/list_string/load(var/raw_string)
	value = splittext(raw_string, delimiter)

// -- Numbers
/datum/config_flag/numerical
	text_name = "Abstract"

/datum/config_flag/numerical/load(var/raw_string)
	value = text2num(raw_string)

// -- toggle
// The system is set up in a weird way that some things are true by default and putting them in the config just "reinforces" truthness
// This adds in a bit of flexibility
/datum/config_flag/toggle
	text_name = "Abstract"

/datum/config_flag/toggle/load(var/raw_string)
	var/tag = text2num(raw_string)
	switch (tag)
		if (0)
			value = FALSE
		if (1)
			value = TRUE
		// Just reinforcing it
		else
			value = TRUE
