/datum/objective/protect_master
	var/datum/role/master
	explanation_text = "Protect and serve your master at all costs."

/datum/objective/protect_master/New(var/datum/role/master)
	src.master = master

/datum/objective/protect_master/IsFulfilled()
	..()
	if (master.antag.current.isDead())
		return FALSE
	return TRUE