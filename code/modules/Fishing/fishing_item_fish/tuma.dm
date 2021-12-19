/obj/item/weapon/reagent_containers/food/snacks/tuma
	name = "tuma"
	desc = ""
	icon = ''
	icon_state = ""
	food_flags = FOOD_MEAT | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/tuma/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(ONCOTECAN, 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tuma/angler_effect(obj/item/weapon/bait/baitUsed)
	var/tumoryness = min(20, baitUsed.catchPower/15 + baitUsed.catchSizeAdd)
	reagents.add_reagent(ONCOTECAN, rand(1, tumoryness))


/datum/reagent/oncotecan
	name = "Oncotecan"
	id = ONCOTECAN
	description = "Promotes rapid, uncontrolled division of cells. This process can cause miraculous healing of internal organs. It can also cause horrible mutations, both genetic and otherwise."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#770bb642"
	overdose_am = 15	//You don't need, or want, much in you for the healing
	density = 1.5
	var/list/valid_species = (all_species - list("Krampus", "Horror"))	//Stolen from frankensteins


/datum/reagent/oncotecan/on_mob_life(var/mob/living/M)
	var/tCount = 10
	var/tMod = 0
	for(var/datum/organ/internal/I in H.organs)	//Each tick has 10 tcount. If you have equal or great than 10 organ damage that tick, nothing bad can happen.
		if(!tCount)
			break
		if(I.damage)
			tMod = min(tCount, I.damage)
			I.damage -= tMod
			tCount -= tMod
	if(tCount)		//If we have tcount remaining after subtracting it from our existing organ damage, things get weird
		if(prob(M.CloneLoss))
			if(is_overdosing() && prob(50))
				var/datum/organ/external/E = pick(M.organs)	//organs is a list of external organs, internal_organs is what you'd expect a sane person to name something.
					E.species = all_species[pick(valid_species)]
			else
				var/datum/organ/internal/I = pick(M.internal_organs)
					I.species = all_species[pick(valid_species)]
		else
			M.adjustCloneLoss(tCount)	//So each tick without organ damage makes the organ swapping effect more likely. This also effectively makes it impossible to die from this clone damage alone.

/datum/reagent/oncotecan/on_overdose(var/mob/living/M)
	if(!M.dna)
		return
	if(prob(volume))
		randmutg(M)
	else
		randmutb(M)
	M.remove_reagent(ONCOTECAN, 1)
