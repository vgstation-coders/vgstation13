/datum/role/wizard_convert
	id = WIZARD_CONVERT
	name = WIZARD_CONVERT
	logo_state = "apprentice-logo"
	default_admin_voice = "Wizard Federation"
	admin_voice_style = "notice"

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

/datum/role/wizard_convert/Greet(var/greeting,var/custom)
	if(!greeting)
		return
	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if(GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> [custom]")
		if(GREET_DEFAULT)
			var/datum/faction/wizard/civilwar/F = faction
			if(F)
				to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/><B>You are now a follower of [F.name]!</B><BR>You now obey all orders of the wizards that lead it.")

/datum/role/wizard_convert/ForgeObjectives()
	var/datum/objective/survive/S = new
	AppendObjective(S)
