/datum/gamemode/traitor
	name = "Traitor"
	factions_allowed = list(/datum/faction/syndicate/traitor)
	//are all traitors part of one faction?

/datum/gamemode/traitor/da
	name = "Double Agent"
	factions_allowed = list(typesof(/datum/faction/syndicate/traitor) - /datum/faction/syndicate/traitor)