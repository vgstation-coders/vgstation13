
/datum/organ/internal/liver
	name = "liver"
	parent_organ = LIMB_CHEST
	organ_type = "liver"
	var/process_accuracy = 10
	var/efficiency = 1 // efficiency is a weird variable name. Lower number means chemicals stay more time on the organism.

	var/reagent_efficiencies=list(
		// REAGENT = 2,
	)
	removed_type = /obj/item/organ/internal/liver

/datum/organ/internal/liver/Copy()
	var/datum/organ/internal/liver/I = ..()
	I.process_accuracy = process_accuracy
	return I

/datum/organ/internal/liver/process()
	..()
	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(1))
			owner << "<span class='warning'>Your skin itches.</span>"
	if (germ_level > INFECTION_LEVEL_TWO)
		if(prob(1))
			spawn owner.vomit()

	if(owner.life_tick % process_accuracy == 0)
		if(src.damage < 0)
			src.damage = 0

		handle_toxins()

/datum/organ/internal/liver/proc/handle_toxins()
	//High toxins levels are dangerous
	if(owner.getToxLoss() >= 60 && !owner.reagents.has_any_reagents(ANTI_TOXINS))
		//Healthy liver suffers on its own
		if (damage < min_broken_damage)
			damage += 0.2 * process_accuracy
		//Damaged one shares the fun
		else
			var/datum/organ/internal/O = pick(owner.internal_organs)
			if(O)
				O.damage += 0.2  * process_accuracy

	//Detox can heal small amounts of damage
	if (damage && damage < min_bruised_damage && owner.reagents.has_any_reagents(ANTI_TOXINS))
		damage -= 0.2 * process_accuracy

	// Damaged liver means some chemicals are very dangerous
	if(damage >= min_bruised_damage)
		for(var/datum/reagent/R in owner.reagents.reagent_list)
			// Ethanol and all drinks are bad
			if(istype(R, /datum/reagent/ethanol))
				owner.adjustToxLoss(0.1 * process_accuracy)

		// Can't cope with toxins at all
		for(var/toxin in list(PLASMA, CYANIDE, AMATOXIN, CHLORALHYDRATE, CARPOTOXIN, ZOMBIEPOWDER, MINDBREAKER)+SACIDS+PACIDS+LEXORINS+TOXINS+LEXORINS)
			if(owner.reagents.has_reagent(toxin))
				owner.adjustToxLoss(0.3 * process_accuracy)

/datum/organ/internal/liver/proc/metabolize_reagent(var/reagent_id, var/metabolism)
	var/mob/living/carbon/human/H=owner
	var/reagent_efficiency = 1
	if(reagent_id in reagent_efficiencies)
		reagent_efficiency = reagent_efficiencies[reagent_id]
	H.reagents.remove_reagent(reagent_id, metabolism * efficiency * reagent_efficiency)

/datum/organ/internal/liver/diona
	name = "diona liver"
	removed_type = /obj/item/organ/internal/liver/diona

/datum/organ/internal/liver/diona/metabolize_reagent(reagent_id, metabolism)
	var/mob/living/carbon/human/diona = owner
	if(reagent_id != AMMONIA)
		diona.reagents.remove_reagent(reagent_id, metabolism * efficiency)
		if(diona.reagents.get_reagent_amount(AMMONIA) < 30 && reagent_id != WATER)
			diona.reagents.add_reagent(AMMONIA, max(metabolism * efficiency * 0.1, 0.1))
		return

	if(diona.reagents.get_reagent_amount(AMMONIA) > 30)
		diona.reagents.remove_reagent(AMMONIA, metabolism * efficiency)
