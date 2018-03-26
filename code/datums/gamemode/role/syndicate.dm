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
				if(!locate(/datum/objective/die) in objectives.objectives && !locate(/datum/objective/target/steal) in objectives.objectives)
					AppendObjective(/datum/objective/die)
				else
					if(prob(85))
						if (!(locate(/datum/objective/escape) in objectives.objectives))
							AppendObjective(/datum/objective/escape)
					else
						if(prob(50))
							if (!(locate(/datum/objective/hijack) in objectives.objectives))
								AppendObjective(/datum/objective/hijack)
						else
							if (!(locate(/datum/objective/minimize_casualties) in objectives.objectives))
								AppendObjective(/datum/objective/minimize_casualties)
			if(31 to 90)
				if (!(locate(/datum/objective/escape) in objectives.objectives))
					AppendObjective(/datum/objective/escape)
			else
				if(prob(50))
					if (!(locate(/datum/objective/hijack) in objectives.objectives))
						AppendObjective(/datum/objective/hijack)
				else // Honk
					if (!(locate(/datum/objective/minimize_casualties) in objectives.objectives))
						AppendObjective(/datum/objective/minimize_casualties)

/datum/role/traitor/extraPanelButtons()
	var/dat = ""
	if(antag.find_syndicate_uplink())
		dat = " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];removeuplink=1;'>(Remove uplink)</a>"
	else
		dat = " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];giveuplink=1;'>(Give uplink)</a>"
	return dat

/datum/role/traitor/RoleTopic(href, href_list, var/datum/mind/M, var/admin_auth)
	..()
	if(href_list["giveuplink"] && admin_auth)
		equip_traitor(antag.current, 20)
	if(href_list["removeuplink"] && admin_auth)
		M.take_uplink()
		to_chat(M.current, "<span class='warning'>You have been stripped of your uplink.</span>")


//________________________________________________


/datum/role/traitor/rogue//double agent
	name = ROGUE
	id = ROGUE
	logo_state = "synd-logo"

//________________________________________________

/datum/role/nuclear_operative
	name = NUKE_OP
	id = NUKE_OP
	logo_state = "nuke-logo"