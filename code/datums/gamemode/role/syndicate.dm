/datum/role/traitor
	name = TRAITOR
	id = TRAITOR
	logo_state = "synd-logo"
	wikiroute = ROLE_TRAITOR


/datum/role/traitor/OnPostSetup()
	..()
	if(istype(antag.current, /mob/living/silicon))
		add_law_zero(antag.current)
		antag.current << sound('sound/voice/AISyndiHack.ogg')
	else
		equip_traitor(antag.current, 20)
		antag.current << sound('sound/voice/syndicate_intro.ogg')

/datum/role/traitor/ForgeObjectives()
	if(istype(antag.current, /mob/living/silicon))
		AppendObjective(/datum/objective/target/assassinate)

		AppendObjective(/datum/objective/survive)

		if(prob(10))
			AppendObjective(/datum/objective/block)

	else
		AppendObjective(/datum/objective/target/assassinate)
		AppendObjective(/datum/objective/target/steal)
		switch(rand(1,100))
			if(1 to 30) // Die glorious death
				if(!locate(/datum/objective/die) in objectives.GetObjectives() && !locate(/datum/objective/target/steal) in objectives.GetObjectives())
					AppendObjective(/datum/objective/die)
				else
					if(prob(85))
						if (!(locate(/datum/objective/escape) in objectives.GetObjectives()))
							AppendObjective(/datum/objective/escape)
					else
						if(prob(50))
							if (!(locate(/datum/objective/hijack) in objectives.GetObjectives()))
								AppendObjective(/datum/objective/hijack)
						else
							if (!(locate(/datum/objective/minimize_casualties) in objectives.GetObjectives()))
								AppendObjective(/datum/objective/minimize_casualties)
			if(31 to 90)
				if (!(locate(/datum/objective/escape) in objectives.objectives))
					AppendObjective(/datum/objective/escape)
			else
				if(prob(50))
					if (!(locate(/datum/objective/hijack) in objectives.objectives))
						AppendObjective(/datum/objective/hijack)
				else // Honk
					if (!(locate(/datum/objective/minimize_casualties) in objectives.GetObjectives()))
						AppendObjective(/datum/objective/minimize_casualties)

/datum/role/traitor/extraPanelButtons()
	var/dat = ""
	if(antag.find_syndicate_uplink())
		dat = " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];removeuplink=1;'>(Remove uplink)</a>"
	else
		dat = " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];giveuplink=1;'>(Give uplink)</a>"
	return dat

/datum/role/traitor/RoleTopic(href, href_list, var/datum/mind/M, var/admin_auth)
	.=..()
	if(href_list["giveuplink"] && admin_auth)
		equip_traitor(antag.current, 20)
	if(href_list["removeuplink"] && admin_auth)
		M.take_uplink()
		to_chat(M.current, "<span class='warning'>You have been stripped of your uplink.</span>")

/datum/role/traitor/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_ROUNDSTART)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Syndicate agent, a Traitor.</span>")
		if (GREET_AUTOTATOR)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>Your memory clears up as you remember your identity as a sleeper agent of the Syndicate. It's time to pay your debt to them. You are now a Traitor.</span>")
		if (GREET_LATEJOIN)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>As a Syndicate agent, you are to infiltrate the crew and accomplish your objectives at all cost. You are a Traitor.</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Traitor.</span>")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")


//________________________________________________


/datum/role/traitor/rogue//double agent
	name = ROGUE
	id = ROGUE
	logo_state = "synd-logo"

/datum/role/traitor/rogue/ForgeObjectives()
	var/datum/role/traitor/rogue/rival
	var/list/potential_rivals = list()
	if(faction && faction.members)
		potential_rivals = faction.members-src
	else
		for(var/datum/role/traitor/rogue/R in ticker.mode.orphaned_roles) //It'd be awkward if you ended up with your rival being a vampire.
			if(R != src)
				potential_rivals.Add(R)
	if(potential_rivals.len)
		rival = pick(potential_rivals)
	if(!rival) //Fuck it, you're now a regular traitor
		return ..()

	var/datum/objective/target/assassinate/kill_rival = new(auto_target = FALSE)
	if(kill_rival.set_target(rival.antag))
		AppendObjective(kill_rival)
	else
		qdel(kill_rival)

	if(prob(70)) //Your target knows!
		var/datum/objective/target/assassinate/kill_new_rival = new(auto_target = FALSE)
		if(kill_new_rival.set_target(antag))
			rival.AppendObjective(kill_new_rival)
		else
			qdel(kill_new_rival)

	if(prob(50)) //Spy v Spy
		var/datum/objective/target/assassinate/A = new()
		if(A.target)
			AppendObjective(A)

			var/datum/objective/target/protect/P = new(auto_target = FALSE)
			if(P.set_target(A.target))
				rival.AppendObjective(P)

	if(prob(30))
		AppendObjective(/datum/objective/target/steal)

	switch(rand(1,3))
		if(1)
			if(!locate(/datum/objective/target/steal) in objectives.GetObjectives())
				AppendObjective(/datum/objective/die)
			else
				AppendObjective(/datum/objective/escape)
		if(2)
			AppendObjective(/datum/objective/hijack)
		else
			AppendObjective(/datum/objective/escape)

//________________________________________________

/datum/role/nuclear_operative
	name = NUKE_OP
	id = NUKE_OP
	disallow_job = TRUE
	logo_state = "nuke-logo"