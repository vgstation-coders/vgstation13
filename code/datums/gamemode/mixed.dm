var/list/mixed_factions_allowed = list(
	typesof(/datum/faction/wizard,
	/datum/faction/syndicate/traitor),
	)
var/list/mixed_roles_allowed = list(
	/datum/role/vampire = 1,
	/datum/role/changeling = 2,
	)

/datum/gamemode/mixed
	name = "Mixed"


/datum/gamemode/mixed/SetupFactions()
	factions_allowed = mixed_factions_allowed
	roles_allowed = mixed_roles_allowed


/datum/gamemode/mixed/traitorchan
	name = "Traitorchan"


/datum/gamemode/mixed/traitorchan/SetupFactions()
	factions_allowed = list(typesof(/datum/faction/syndicate/traitor))
	roles_allowed = list(/datum/role/changeling)


/datum/gamemode/mixed/simple
	name = "Simple Mixed"

/datum/gamemode/mixed/simple/SetupFactions()
	factions_allowed = list(typesof(/datum/faction/syndicate/traitor))
	roles_allowed = list(/datum/role/changeling, /datum/faction/vampire)
//would the easiest way to handle these be to just create the other gamemodes and let their code run, as opposed to adding their specific terms for faction creation again here?
