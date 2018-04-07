/datum/faction/vampire
	name = "Vampire Lords"
	desc = "Hailing from Space Transylvania."
	ID = VAMPIRELORDS
	required_pref = ROLE_VAMPIRE
	initial_role = VAMPIRE
	late_role = VAMPIRE // Vampires do not change their role.
	roletype = /datum/role/vampire
	logo_state = "vampire-logo"

	var/datum/role/vampire/master // The master of this faction.

/datum/faction/vampire/New(var/datum/role/vampire/V)
	..()
	master = V
	members += V
	V.faction = src
	V.antag.faction = src
	name = "Lord [V.antag.current]'s vampiric servants.'"

/datum/faction/vampire/can_setup()
	// TODO : check if the number of players > 10, if we have at least 2 players with vamp enabled.
	return TRUE