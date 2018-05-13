/datum/faction/syndicate
	name = "The Syndicate"
	ID = SYNDICATE
	required_pref = ROLE_TRAITOR
	desc = "A coalition of companies that actively work against Nanotrasen's intentions. Seen as Freedom fighters by some, Rebels and Malcontents by others."
	logo_state = "synd-logo"

//________________________________________________

/datum/faction/syndicate/traitor
	name = "Syndicate agents"
	ID = SYNDITRAITORS
	initial_role = TRAITOR
	late_role = TRAITOR
	desc = "Operatives of the syndicate, implanted into the crew in one way or another."
	logo_state = "synd-logo"
	roletype = /datum/role/traitor
	initroletype = /datum/role/traitor

/datum/faction/syndicate/traitor/auto
	accept_latejoiners = TRUE

/datum/faction/syndicate/traitor/dagent
	roletype = /datum/role/traitor/rogue
	initroletype = /datum/role/traitor/rogue