/datum/gamemode/traitor
	name = "Traitor"
	factions_allowed = list(/datum/faction/traitor)
	//are all traitors part of one faction?

/datum/gamemode/traitor/da
	name = "Double Agent"
	factions_allowed = typesof(/datum/faction/traitor) - /datum/faction/traitor