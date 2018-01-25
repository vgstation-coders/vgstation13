/datum/objective/target/sacrifice/IsFulfilled()
	var/datum/rune_controller/R = ticker.rune_controller
	if(!R) //The universe has doomed you from the start
		return FALSE
	if(target in R.sacrificed)
		return TRUE