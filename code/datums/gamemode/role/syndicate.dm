/datum/role/traitor
	name = TRAITOR
	id = TRAITOR
	logo_state = "synd-logo"

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
//________________________________________________


/datum/role/rogue//double agent
	name = ROGUE
	id = ROGUE
	logo_state = "synd-logo"

//________________________________________________

/datum/role/nuclear_operative
	name = NUKE_OP
	id = NUKE_OP
	logo_state = "nuke-logo"