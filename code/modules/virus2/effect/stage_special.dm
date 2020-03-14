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
	desc = "Causes the infected to be resistant to the effects of space exposure."
	stage = 5

/datum/disease2/effect/spaceadapt/activate(var/mob/living/carbon/mob)
	var/mob/living/carbon/human/H = mob
	if (mob.reagents.get_reagent_amount(DEXALINP) < 10)
		mob.reagents.add_reagent(DEXALINP, 4)
	if (mob.reagents.get_reagent_amount(LEPORAZINE) < 10)
		mob.reagents.add_reagent(LEPORAZINE, 4)
	if (mob.reagents.get_reagent_amount(BICARIDINE) < 10)
		mob.reagents.add_reagent(BICARIDINE, 4)
	if (mob.reagents.get_reagent_amount(DERMALINE) < 10)
		mob.reagents.add_reagent(DERMALINE, 4)
	mob.emote("me",1,"exhales slowly.")

	if(ishuman(H))
		var/datum/organ/external/chest/chest = H.get_organ(LIMB_CHEST)
		for(var/datum/organ/internal/I in chest.internal_organs)
			I.damage = 0
