/datum/objective/protect_master
	var/datum/role/master
	explanation_text = "Protect and serve your master at all costs."
	name = "Protect your master"

/datum/objective/protect_master/New(var/list/arguments)
	var/datum/role/master = arguments["master"]
	if (istype(master))
		src.master = master

/datum/objective/protect_master/IsFulfilled()
	..()
	if (master.antag.current.isDead())
		return FALSE
	return TRUE