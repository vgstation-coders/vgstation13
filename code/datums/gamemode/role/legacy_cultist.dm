/datum/role/legacy_cultist
	id = LEGACY_CULTIST
	name = LEGACY_CULTIST
	special_role = ROLE_LEGACY_CULTIST
	disallow_job = FALSE
	restricted_jobs = list("AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain")
	logo_state = "cult-logo"
	greets = list("default","custom","admintoggle")
	required_pref = ROLE_LEGACY_CULTIST

/datum/role/legacy_cultist/Greet(var/greeting, var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if ("custom")
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> [custom]")
		if ("admintoggle")
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>The Geometer of Blood calls your from beyond the veil. You are a Cultist!</span></B>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Cultist!</br></span>")
			to_chat(antag.current, "Your objective is to summon Nar-Sie, the Geometer of blood. To do so, you will have to complete several objectives to thin the veil between this world and his. <br/> \
				Discretion is key to your mission. Do not fail Nar-Sie. \
				Avoid the Chaplain, the chapel, Security and especially Holy Water.")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
	antag.current << sound('sound/effects/vampire_intro.ogg')

/datum/role/legacy_cultist/Drop()
	antag.current.remove_language(LANGUAGE_CULT)
	..()
