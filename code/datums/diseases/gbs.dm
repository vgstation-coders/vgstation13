/datum/disease/gbs
	name = "GBS"
	max_stages = 5
	spread = "On contact"
	spread_type = CONTACT_GENERAL
	cure = "Synaptizine & Sulfur"
	cure_id = list(SYNAPTIZINE,SULFUR)
	cure_chance = 15//higher chance to cure, since two reagents are required
	agent = "Gravitokinetic Bipotential SADS+"
	affected_species = list("Human")
	curable = 0
	permeability_mod = 1

/datum/disease/gbs/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(45))
				affected_mob.adjustToxLoss(5)
				affected_mob.updatehealth()
			if(prob(1))
				affected_mob.emote("sneeze")
		if(3)
			if(prob(5))
				audible_cough(affected_mob)
			else if(prob(5))
				affected_mob.emote("gasp")
			if(prob(10))
				to_chat(affected_mob, "<span class='warning'>You're starting to feel very weak...</span>")
		if(4)
			if(prob(10))
				audible_cough(affected_mob)
			affected_mob.adjustToxLoss(5)
			affected_mob.updatehealth()
		if(5)
			to_chat(affected_mob, "<span class='warning'>Your body feels as if it's trying to rip itself open...</span>")
			if(prob(50))
				affected_mob.gib()
		else
			return