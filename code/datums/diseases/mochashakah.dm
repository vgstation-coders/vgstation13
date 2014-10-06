/datum/disease/mochashakah
	name = "Mocha Shakah"
	max_stages = 4
	spread = "Airborne"
	cure = "milk"
	cure_id = "milk"
	cure_chance = 15
	affected_species = list("Human")
	permeability_mod = 0.75
	desc = "Effects are unknown."
	severity = "Medium"
/datum/disease/mochashakah/stage_act()
	..()
	switch(stage)
		if(2)
			if(affected_mob.sleeping && prob(20))
				affected_mob << "\blue You feel better."
				stage--
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob.emote("gasp")
			if(prob(1))
				affected_mob << "\red Your muscles ache."
				if(prob(20))
					affected_mob.bruteloss += 1
					affected_mob.updatehealth()
			if(prob(1))
				affected_mob << "\red Your feel tired."
				if(prob(20))
					affected_mob.toxloss += 1
					affected_mob.bodytemperature += 1
					affected_mob.updatehealth()
				if(prob(10))
					affected_mob.paralysis = rand(3,5)
			if(prob(1))
				affected_mob << "\red Your stomach hurts."
				if(prob(20))
					affected_mob.toxloss += 1
					affected_mob.bodytemperature += 1
					affected_mob.updatehealth()

		if(3)
			if(affected_mob.sleeping && prob(15))
				affected_mob << "\blue You feel better."
				stage--
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob.emote("gasp")
			if(prob(1))
				affected_mob << "\red Your muscles ache."
				if(prob(20))
					affected_mob.bruteloss += 1
					affected_mob.updatehealth()
			if(prob(1))
				affected_mob << "\red Your head hurts."
				if(prob(20))
					affected_mob.toxloss += 1
					affected_mob.updatehealth()
			if(prob(1))
				affected_mob << "\red Your stomach hurts."
				if(prob(20))
					affected_mob.toxloss += 1
					affected_mob.updatehealth()
			if(prob(1))
				affected_mob << "\red You feel tired."
				if(prob(20))
					affected_mob.toxloss += 1
					affected_mob.bodytemperature += 1
					affected_mob.updatehealth()
				if(prob(10))
					affected_mob.paralysis = rand(3,5)
			if(prob(1))
				affected_mob << "\red You feel like rapping."
			if(prob(1))
				affected_mob << "\red You feel like playing basketball."
			if(prob(1))
				affected_mob << "\red You feel like listening to rap music."
			if(prob(1))
				affected_mob << "\red You have an unusual craving for Kool-Aid."
			if(prob(1))
				affected_mob << "\red You have an unusual craving for fried chicken."
			if(prob(1))
				affected_mob << "\red You have an unusual craving for watermelon."
			if(prob(50))
				affected_mob:s_tone--
				affected_mob:update_body()
		if(4)
			if(prob(20))
				affected_mob:s_tone = -200
				affected_mob:update_body()
			if(prob(1))
				if(prob(20))
					affected_mob.say(pick("thug life!", "i'm black y'all", "that's racist, fool", "sup bitches", "what up yo", "mofo", "sup dawg", "them hoes yo"))
	return