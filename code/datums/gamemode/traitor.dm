/datum/gamemode/traitor
	name = "Traitor"
	factions_allowed = list(/datum/faction/syndicate/traitor)
	//are all traitors part of one faction?

/datum/gamemode/traitor/da
	name = "Double Agent"


/datum/gamemode/traitor/da/SetupFactions()
	factions_allowed = subtypesof(/datum/faction/syndicate/traitor)

/* autotators are just tators ffs!
/datum/gamemode/autotraitor
	name = "Autotraitor"
	factions_allowed=  list(/datum/faction/syndicate/traitor/auto)
*/