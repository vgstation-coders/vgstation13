/datum/faction/vampire
	name = "Vampire Lords"
	desc = "Hailing from Space Transylvania."
	ID = VAMPIRELORDS
	required_pref = "vampire" // TO BE CHANGED TO A DEFINE
	initial_role = VAMPIRE
	late_role = VAMPIRE // Vampires do not change their role.
	roletype = /datum/role/vampire
	logo_state = "vampire-logo"

/datum/faction/vampire/New(var/datum/role/vampire/V)
	..()
	if (istype(V)) // Late creation
		addMaster(V)

/datum/faction/vampire/proc/addMaster(var/datum/role/vampire/V)
	if (!leader)
		leader = V
		members += V
		V.faction = src

/datum/faction/vampire/can_setup()
	// TODO : check if the number of players > 10, if we have at least 2 players with vamp enabled.
	return TRUE