// All this is pre-dynamic mode.
// This is kept mostly for historical reasons, in case you want to redo a secret-like mode.
// File currently unticked
/datum/config_flag/list_string/mode_names
	text_name = "mode_names"
	value = list()

/datum/config_flag/list_string/modes
	text_name = "modes"
	value = list()

/datum/config_flag/list_string/votable_modes
	text_name = "votable_modes"
	value = list()

/datum/config_flag/probabilities
	text_name = "probability"
	value = list()

// They're of the form:
// PROBABILITY NAME VALUE
// As they're not used anymore, there's no need for the server to load them
/datum/config_flag/probabilities/load(var/raw_string)
	return

// What this used to do, for reference :
/*
	if ("probability")
		var/prob_pos = findtext(value, " ")
		var/prob_name = null
		var/prob_value = null

		if (prob_pos)
			prob_name = lowertext(copytext(value, 1, prob_pos))
			prob_value = copytext(value, prob_pos + 1)
			if (prob_name in config.modes)
				config.probabilities[prob_name] = text2num(prob_value)
			else
				diary << "Unknown game mode probability configuration definition: [prob_name]."
		else
			diary << "Incorrect probability configuration definition: [prob_name]  [prob_value]."


*/
