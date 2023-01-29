/datum/role/wizard_convert
	id = WIZARD_CONVERT
	name = WIZARD_CONVERT
	logo_state = "apprentice-logo"
	default_admin_voice = "Wizard Federation"
	admin_voice_style = "notice"

/datum/role/wizard_convert/OnPreSetup()
	. = ..()
	if(antag)
		var/datum/role/wizard_convert/previous = antag.GetRole(WIZARD_CONVERT)
		if(previous)
			previous.RemoveFromRole(antag)

/datum/role/wizard_convert/OnPostSetup(laterole)
	. = ..()
	if(antag?.current)
		var/factioncolor = istype(faction,/datum/faction/wizard/civilwar/wpf) ? "#f00" : "#00f"
		for(var/image/I in antag.current.overlays)
			I.color = factioncolor

/datum/role/wizard_convert/RemoveFromRole(datum/mind/M, msg_admins)
	..()
	if(antag?.current)
		for(var/image/I in antag.current.overlays)
			I.color = initial(I.color)

/datum/role/wizard_convert/Greet()
	var/datum/faction/wizard/civilwar/F = faction
	if(F)
		to_chat(antag.current, "<B>You are now a follower of [F.name]!</B><BR>You now obey all orders of the wizards that lead it.")

/datum/role/wizard_convert/ForgeObjectives()
	var/datum/objective/survive/S = new
	AppendObjective(S)
	var/datum/faction/wizard/civilwar/F = faction
	if(istype(F))
		var/datum/faction/target = find_active_faction_by_type(F.enemy_faction)
		if(target)
			var/datum/objective/destroyfaction/O = new
			O.targetfaction = target
			AppendObjective(O)
