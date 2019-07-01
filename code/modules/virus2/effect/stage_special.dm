////////////////////////SPECIAL/////////////////////////////////


/*/datum/disease2/effect/alien
	name = "Unidentified Foreign Body"
	stage = 4
	activate(var/mob/living/carbon/mob)
		to_chat(mob, "<span class='warning'>You feel something tearing its way out of your stomach...</span>")
		mob.adjustToxLoss(10)
		mob.updatehealth()
		if(prob(40))
			if(mob.client)
				mob.client.mob = new/mob/living/carbon/alien/larva(mob.loc)
			else
				new/mob/living/carbon/alien/larva(mob.loc)
			var/datum/disease2/disease/D = mob:virus2
			mob:gib()
			del D*/


/datum/disease2/effect/spaceadapt
	name = "Space Adaptation Effect"
	desc = "Heals the infected from the effects of space exposure, should they remain in a vacuum."
	stage = 4
	badness = 0
	chance = 10
	max_chance = 25

/datum/disease2/effect/spaceadapt/activate(var/mob/living/carbon/mob)
	var/datum/gas_mixture/environment = mob.loc.return_air()
	var/pressure = environment.return_pressure()
	var/adjusted_pressure = mob.calculate_affecting_pressure(pressure)
	if (istype(mob.loc, /turf/space) || adjusted_pressure < HAZARD_LOW_PRESSURE)
		if (mob.reagents.get_reagent_amount(DEXALINP) < 10)
			mob.reagents.add_reagent(DEXALINP, 4)
		if (mob.reagents.get_reagent_amount(LEPORAZINE) < 10)
			mob.reagents.add_reagent(LEPORAZINE, 4)
		if (mob.reagents.get_reagent_amount(BICARIDINE) < 10)
			mob.reagents.add_reagent(BICARIDINE, 4)
		if (prob(20))
			mob.emote("me",1,"exhales slowly.")

		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			var/datum/organ/internal/lungs/L = H.internal_organs_by_name["lungs"]
			if (L)
				L.damage = 0
