/datum/organ/internal/kidney
	name = "kidneys"
	parent_organ = LIMB_GROIN
	organ_type = "kidneys"
	removed_type = /obj/item/organ/internal/kidneys


/datum/organ/internal/kidney/process()

	if((owner.life_tick % 10 == 0) && (owner.getToxLoss(TRUE) <= 15) && (damage < min_broken_damage))
		owner.adjustToxLoss(-0.5)

// Kidney upgrade
/datum/organ/internal/kidney/filter
	name = "toxin filters"
	removed_type = /obj/item/organ/internal/kidneys/filter
	robotic = 2

	min_bruised_damage = 15
	min_broken_damage = 30


/datum/organ/internal/kidney/filter/process()

	if((owner.life_tick % 5 == 0) && (damage < min_broken_damage))
		owner.adjustToxLoss(-0.5)
	if(owner.reagents.has_any_reagents(list(TOXIN, PLANTBGONE, INSECTICIDE, SOLANINE)))
		owner.reagents.remove_reagents(list(TOXIN, PLANTBGONE, INSECTICIDE, SOLANINE), REM)
	if(owner.reagents.has_any_reagents(STOXINS))
		owner.reagents.remove_reagents(STOXINS, 2 * REM)
	if(owner.reagents.has_any_reagents(SACIDS))
		owner.reagents.remove_reagents(SACIDS, 0.5 * REM)
	if(owner.reagents.has_any_reagents(list(PLASMA, SUX, CARPOTOXIN)))
		owner.reagents.remove_reagents(list(PLASMA, SUX, CARPOTOXIN), 0.5 * REM)
	if(owner.reagents.has_any_reagents(list(POTASSIUM_HYDROXIDE, CYANIDE, AMATOXIN, MINDBREAKER, CHEESYGLOOP)))
		owner.reagents.remove_reagents(list(POTASSIUM_HYDROXIDE, CYANIDE, AMATOXIN, MINDBREAKER, CHEESYGLOOP), REM)
	if(owner.reagents.has_reagent(CHLORALHYDRATE))
		owner.reagents.remove_reagent(CHLORALHYDRATE, 2 * REM)