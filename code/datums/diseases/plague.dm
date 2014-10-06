/datum/disease/plague
	name = "Plague"
	max_stages = 5
	spread = "On contact"
	spread_type = CONTACT_GENERAL
	cure = "Kill him. NOW."
	cure_chance = 0
	affected_species = list("Human", "Monkey")
	curable = 0
	desc = "Very bad pathogen. You are already dead, but you don't senset it."
	severity = "High"
/datum/disease/plague/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(45))
				affected_mob.toxloss += (5)
				affected_mob.updatehealth()
			if(prob(10))
				affected_mob << "\red You feel swollen..."
		if(3)
			if(prob(5))
				affected_mob.emote("cough")
			else if(prob(5))
				affected_mob.emote("gasp")
			if(prob(3))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob << "\red You feel very sick..."
		if(4)
			if(prob(2))
				affected_mob.emote("cough")
			else if(prob(5))
				affected_mob.emote("gasp")
			if(prob(3))
				affected_mob.emote("sneeze")
			if(prob(4))
				affected_mob.emote("cough")
				affected_mob.toxloss += (5)
				affected_mob.bruteloss += (5)
				affected_mob.updatehealth()
		if(5)
			if(prob(5))
				affected_mob.emote("cough")
				new /obj/effect/decal/cleanable/blood(affected_mob.loc)
				affected_mob.bruteloss += (5)
			else if(prob(5))
				affected_mob.emote("gasp")
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(5))
				affected_mob.emote("sneeze")
			if(prob(5))
				affected_mob.bruteloss += (30)
				affected_mob.toxloss += (30)
				affected_mob.stunned += rand(2,4)
				affected_mob.weakened += rand(2,4)
				affected_mob.updatehealth()
		else
			return