/**
	How te start pirate raiders
	Start the faction, let it sort itself out (Creating the ship, making its objectives, etc.)
	Then populate it.
**/


/datum/faction/pirate_raiders
	name = "Pirate raiders"
	desc = "A galavanting crew of malcontents. Dead set on acquiring wealth through illicit, and usually violent, means."
	ID = PIRATES
	required_pref = ROLE_PIRATE
	initroletype = /datum/role/pirate/captain
	roletype = /datum/role/pirate
	var/datum/shuttle/assoc_shuttle

/datum/faction/pirate_raiders/can_setup()
	.=..()
	if(.)
		var/list/L = load_dungeon(/datum/map_element/dungeon/pirateship)
		var/obj/docking_port/shuttle/SH = locate(/obj/docking_port/shuttle) in L
		var/area/A = get_area(SH)

		if(A.get_shuttle())
			message_admins("Something's wrong with the pirates - There's a shuttle there for whatever reason.")
			return FALSE

		var/datum/shuttle/custom/S = new(starting_area = A)
		S.initialize()
		S.name = "The Pirates Bounty"

		assoc_shuttle = S

/datum/faction/pirate_raiders/forgeObjectives()
	AppendObjective(/datum/objective/pirate_loot)