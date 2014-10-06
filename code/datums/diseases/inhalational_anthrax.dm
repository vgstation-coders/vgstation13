/datum/disease/inhalational_anthrax
	name = "Anthrax"
	max_stages = 4
	spread = "Airborne"
	cure = "Synaptizine and Spaceacillin"
	cure_id = list("synaptizine","spaceacillin")
	cure_chance = 10
	affected_species = list("Human", "Monkey")
	desc = "If left untreated the subject will die."
	severity = "High"
/datum/disease/inhalational_anthrax/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your body aches."
			if(prob(5))
				affected_mob.bruteloss += (2)
				affected_mob.bodytemperature += (3)
				affected_mob.fireloss += (1)
				affected_mob.updatehealth()
			if(prob(1))
				affected_mob << "\red Your stomach hurts."
				if(prob(10))
					affected_mob.toxloss += (5)
					affected_mob.updatehealth()

		if(3)
			if(prob(1))
				affected_mob.emote("sneeze")
				new /obj/effect/decal/cleanable/blood(affected_mob.loc)
			if(prob(1))
				affected_mob.emote("cough")
				new /obj/effect/decal/cleanable/blood(affected_mob.loc)
			if(prob(1))
				affected_mob << "\red Your muscles ache."
			if(prob(10))
				affected_mob.bruteloss += (20)
				affected_mob.updatehealth()
			if(prob(5))
				affected_mob.stunned += rand(2,5)
				affected_mob.weakened += rand(2,5)
				affected_mob.bodytemperature += (20)
				affected_mob.fireloss += (1)
			if(prob(1))
				affected_mob << "\red Your stomach hurts."
				if(prob(20))
					affected_mob.toxloss += (10)
					affected_mob.updatehealth()
		if(4)
			if(prob(10))
				affected_mob.bruteloss += (3)
				affected_mob.toxloss += (2)
				affected_mob.bodytemperature += (5)
				affected_mob.fireloss += (3)
				affected_mob.updatehealth()
	return