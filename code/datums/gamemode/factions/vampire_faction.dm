/datum/faction/vampire
	name = "Vampire Lords"
	desc = "Hailing from Space Transylvania."
	ID = VAMPIRELORDS
	required_pref = VAMPIRE
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

/datum/faction/vampire/proc/name_clan(var/datum/role/vampire/V)
	set waitfor = FALSE
	var/newname = copytext(sanitize(input(V.antag.current,"You are the Master Vampire of this new clan. Please choose a name for your clan.", "Name change","")),1,MAX_NAME_LEN)
	if(newname)
		if (newname == "Unknown" || newname == "floor" || newname == "wall" || newname == "rwall" || newname == "_")
			to_chat(V.antag.current, "That name is reserved.")
		name = "The [newname] Vampire Clan."


/datum/faction/vampire/OnPostSetup()
	leader.OnPostSetup()

/datum/faction/vampire/can_setup()
	// TODO : check if the number of players > 10, if we have at least 2 players with vamp enabled.
	return TRUE