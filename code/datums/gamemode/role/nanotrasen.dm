

/datum/role/emergency_responder
	name = RESPONDER
	id = RESPONDER
	special_role = RESPONDER
	logo_state = "ERT_empty-logo"
	is_antag = FALSE

//________________________________________________

/datum/role/death_commando
	name = DEATHSQUADIE
	id = DEATHSQUADIE
	special_role = DEATHSQUADIE
	logo_state = "death-logo"
//________________________________________________


/datum/role/nanotrasen_official
	name = NANOTRASENOFFICIAL
	id = NANOTRASENOFFICIAL
	special_role = NANOTRASENOFFICIAL
	logo_state = "nano-logo"
	is_antag = FALSE


/datum/role/nanotrasen_official/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_ROUNDSTART)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are the [name]. You've uncovered a terrible truth: this space station is a dummy created by the Syndicate to lure Nanotrasen officials, and nearly everyone aboard is likely a Syndicate Agent...at best. Trust only fellow heads of staff and the IAA, and survive until Nanotrasen manages to scramble an ERT to your rescue.</span>")
			to_chat(antag.current, "<span class='danger'>You may expect one in about 20 minutes.</span>")
		if (GREET_LATEJOIN)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are the [name]. You might want to run away from arrivals and hide right now. This station is a trap laid out by the Syndicate to trap Nanotrasen officials, and anyone other than fellow heads of staff or IAA are most likely compromised. Protect yourself until you can regroup with an ERT.</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are the [name].</span>")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")

/datum/role/nanotrasen_official/ForgeObjectives()
	AppendObjective(/datum/objective/survive)
