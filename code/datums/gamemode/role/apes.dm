/datum/role/apes
	name = "Apes"
	id = THE_APES
	special_role = THE_APES
	logo_state = "monkey-logo"
	greets = list(GREET_DEFAULT)
	default_admin_voice = "Ape King"
	admin_voice_style = "rough"

/datum/role/apes/OnPostSetup(var/laterole = TRUE)
	src.Greet(GREET_DEFAULT) /* Handling it here since this role is special and doesn't ever get chosen by dynamic. */
	if(faction)
		return
	var/datum/faction/F = find_active_faction_by_type(/datum/faction/apes)
	if(!F)
		F = ticker.mode.CreateFaction(/datum/faction/apes, null, 1)
	F.HandleRecruitedRole(src)

/datum/role/apes/Greet(greeting, custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if(GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>[custom]</span>")
		else
			to_chat(antag.current, "<span class='bold'>You have been transformed into an ape!<br>You are not an antagonist. In fact, you're just an ordinary ape. Ook!</span>")