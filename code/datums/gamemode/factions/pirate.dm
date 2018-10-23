/**
	How te start pirate raiders
	Start the faction, let it sort itself out (Creating the ship, making its objectives, etc.)
	Then populate it.
**/


/datum/faction/pirate_raiders
	name = "Pirate raiders"
	desc = "A galavanting crew of malcontents. Dead set on acquiring wealth through illicit, and usually violent, means."
	ID = PIRATES
	required_pref = ROLE_PIRATE
	initroletype = /datum/role/pirate/captain
	roletype = /datum/role/pirate
	var/datum/shuttle/assoc_shuttle

/datum/faction/pirate_raiders/forgeObjectives()
	AppendObjective(/datum/objective/pirate_loot)