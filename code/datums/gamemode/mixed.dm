/datum/gamemode/mixed
	name = "Mixed"
	factions_allowed = list(typesof(/datum/faction) - /datum/faction)

/datum/gamemode/mixed/traitorchan
	name = "Traitorchan"
	factions_allowed = list(typesof(/datum/faction/syndicate/traitor) + /datum/faction/changeling)

/datum/gamemode/mixed/simple
	name = "Simple Mixed"
	factions_allowed = list(typesof(/datum/faction/syndicate/traitor) + /datum/faction/vampire + /datum/faction/changeling)

//would the easiest way to handle these be to just create the other gamemodes and let their code run, as opposed to adding their specific terms for faction creation again here?