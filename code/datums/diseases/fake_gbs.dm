/datum/disease/fake_gbs
	name = "GBS"
	max_stages = 5
	spread = "On contact"
	spread_type = CONTACT_GENERAL
	cure = "Synaptizine & Sulfur"
	cure_list = list(SYNAPTIZINE,SULFUR)
	agent = "Gravitokinetic Bipotential SADS-"
	affected_species = list("Human", "Monkey")
	desc = "If left untreated death will occur."
	severity = "Major"

/datum/disease/fake_gbs/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(1))
				affected_mob.emote("sneeze")
		if(3)
			if(prob(5))
				affected_mob.audible_cough()
			else if(prob(5))
				affected_mob.emote("gasp")
			if(prob(10))
				to_chat(affected_mob, "<span class='warning'>You're starting to feel very weak...</span>")
		if(4)
			if(prob(10))
				affected_mob.audible_cough()

		if(5)
			if(prob(10))
				affected_mob.audible_cough()
