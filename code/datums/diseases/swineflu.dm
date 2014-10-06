/datum/disease/swineflu
	name = "Swine Flu"
	max_stages = 3
	spread = "Airborne"
	cure = "Leporazine"
	cure_id = "leporazine"
	cure_chance = 15
	affected_species = list("Human")
	permeability_mod = 0.75
	desc = "If left untreated the subject will feel quite unwell."
	severity = "Medium"
	agent = "SwineFlu"
/datum/disease/swineflu/stage_act()
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
					affected_mob.bruteloss += (1)
					affected_mob.updatehealth()
			if(prob(1))
				affected_mob << "\red Your feel tired."
				if(prob(20))
					affected_mob.toxloss += (1)
					affected_mob.bodytemperature += (1)
					affected_mob.updatehealth()
				if(prob(10))
					affected_mob.paralysis = rand(3,5)
			if(prob(1))
				affected_mob << "\red Your stomach hurts."
				if(prob(20))
					affected_mob.toxloss += (1)
					affected_mob.bodytemperature += (1)
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
					affected_mob.bruteloss += (1)
					affected_mob.updatehealth()
			if(prob(1))
				affected_mob << "\red Your head hurts."
				if(prob(20))
					affected_mob.toxloss += (1)
					affected_mob.updatehealth()
			if (prob(3))
				affected_mob.emote("vomit")
			if(prob(1))
				affected_mob << "\red Your stomach hurts."
				if(prob(20))
					affected_mob.toxloss += (1)
					affected_mob.updatehealth()
			if(prob(1))
				affected_mob << "\red Your feel tired."
				if(prob(20))
					affected_mob.toxloss += (1)
					affected_mob.bodytemperature += (1)
					affected_mob.updatehealth()
				if(prob(10))
					affected_mob.paralysis = rand(3,5)
			if(prob(1))
				if(prob(3))
					//playsound(affected_mob.loc, 'poo2.ogg', 50, 1)
					for(var/mob/O in viewers(affected_mob, null))
						O.show_message(text("\red [] has an uncontrollable diarrhea!", affected_mob), 1)
//					new /obj/item/weapon/reagent_containers/food/snacks/poo(affected_mob.loc)
//					new /obj/decal/cleanable/poo(affected_mob.loc)
	return