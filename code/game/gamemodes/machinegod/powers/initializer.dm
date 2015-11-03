// Initialize the global powers list.

/datum/initializer/clockcult/powers/initialize()
	global.clockcult_powers = list()
	for(var/path in typesof(/datum/clockcult_power) - /datum/clockcult_power)
		global.clockcult_powers += new path
