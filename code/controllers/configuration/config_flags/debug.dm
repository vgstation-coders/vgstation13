//The "cooldown" time for each occurrence of a unique error
/datum/config_flag/numerical/error_cooldown
	text_name = "error_cooldown"
	value = 600

//How many occurrences before the next will silence them
/datum/config_flag/numerical/error_limit
	text_name = "error_limit"
	value = 9

//How long a unique error will be silenced for
/datum/config_flag/numerical/error_silence_time
	text_name = "error_silence_time"
	value = 6000

//How long to wait between messaging admins about occurrences of a unique error
/datum/config_flag/numerical/error_msg_delay
	text_name = "error_msg_delay"
	value = 50
