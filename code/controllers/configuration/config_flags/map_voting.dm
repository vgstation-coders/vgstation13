
/datum/config_flag/toggle/allow_vote_restart
	text_name = "allow_vote_restart"
	value = 0

// Allow players to vote for a new mode
/datum/config_flag/toggle/allow_vote_mode
	text_name = "allow_vote_mode"
	value = 0

// Change from votable maps = 0 to all compiled maps = 1
/datum/config_flag/toggle/toggle_maps
	text_name = "toggle_maps"
	value = 0

//#define WEIGHTED 1
//#define MAJORITY 2
//#define PERSISTENT 3
//#define RANDOM 4
// in [html_interface/voting/voting.dm]
/datum/config_flag/numerical/toggle_vote_method
	text_name = "toggle_vote_method"
	value = 1 // Weighted voting as the fault

/datum/config_flag/numerical/vote_delay
	text_name = "vote_delay"
	value = 6000

/datum/config_flag/numerical/vote_period
	text_name = "vote_period"
	value = 600

/datum/config_flag/toggle/vote_no_default
	text_name = "default_no_vote"
	value = 0

/datum/config_flag/toggle/vote_no_dead
	text_name = "no_dead_vote"
	value = 0
