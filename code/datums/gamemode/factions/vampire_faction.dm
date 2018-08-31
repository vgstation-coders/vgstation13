/datum/faction/vampire
	name = "Vampire Lords"
	desc = "Hailing from Space Transylvania."
	ID = VAMPIRELORDS
	required_pref = ROLE_VAMPIRE
	initial_role = VAMPIRE
	late_role = VAMPIRE // Vampires do not change their role.
	roletype = /datum/role/vampire
	initroletype = /datum/role/vampire
	logo_state = "vampire-logo"
	hud_icons = list("vampire-logo", "thrall-logo")

/datum/faction/vampire/proc/addMaster(var/datum/role/vampire/V)
	if (!leader)
		leader = V
		V.faction = src

/datum/faction/vampire/can_setup()
	// TODO : check if the number of players > 10, if we have at least 2 players with vamp enabled.
	return TRUE