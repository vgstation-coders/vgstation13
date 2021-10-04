/datum
	var/list/datum_components
	var/list/active_timers

/datum/proc/initialize()
	return TRUE

//Called when a variable is edited by admin powers
//Return 1 to block the varedit!
/datum/proc/variable_edited(variable_name, old_value, new_value)
	return
