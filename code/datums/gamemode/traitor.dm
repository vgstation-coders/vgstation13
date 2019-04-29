/datum/gamemode/traitor
	name = "Traitor"
	factions_allowed = list(/datum/faction/syndicate/traitor)
	//are all traitors part of one faction?

/datum/gamemode/traitor/da
	name = "Double Agent"
	factions_allowed = list(/datum/faction/syndicate/traitor/dagent)

// autotators are just tators ffs! //No, it spawns a faction that has midround recruit enabled ye grot
/datum/gamemode/autotraitor
	name = "Autotraitor"
	factions_allowed=  list(/datum/faction/syndicate/traitor/auto)
