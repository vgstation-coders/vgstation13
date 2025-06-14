/datum/organ/internal/kidney
	name = "kidneys"
	parent_organ = LIMB_GROIN
	organ_type = "kidneys"
	removed_type = /obj/item/organ/internal/kidneys


/datum/organ/internal/kidney/process()

	if((owner.life_tick % 10 == 0) && (owner.getToxLoss(TRUE) <= 30) && (damage < min_broken_damage))
		owner.adjustToxLoss(-0.5)

// Kidney upgrade
/datum/organ/internal/kidney/filter
	name = "toxin filters"
	removed_type = /obj/item/organ/internal/kidneys/filter
	robotic = 2

	min_bruised_damage = 15
	min_broken_damage = 30


/datum/organ/internal/kidney/filter/process()

	if(owner.life_tick % 5 == 0)
		owner.adjustToxLoss(-0.5)
	if(owner.reagents.has_any_reagents(list(TOXIN, PLANTBGONE, INSECTICIDE, SOLANINE)))
		owner.reagents.remove_reagents(list(TOXIN, PLANTBGONE, INSECTICIDE, SOLANINE), REM)
	if(owner.reagents.has_any_reagents(STOXINS))
		owner.reagents.remove_reagents(STOXINS, 1)
	if(owner.reagents.has_reagent(PLASMA))
		owner.reagents.remove_reagent(PLASMA, 0.5 * REM)
	if(owner.reagents.has_any_reagents(SACIDS))
		owner.reagents.remove_reagents(SACIDS, 0.5 * REM)
	if(owner.reagents.has_reagent(POTASSIUM_HYDROXIDE))
		owner.reagents.remove_reagent(POTASSIUM_HYDROXIDE, REM)
	if(owner.reagents.has_reagent(CYANIDE))
		owner.reagents.remove_reagent(CYANIDE, REM)
	if(owner.reagents.has_reagent(AMATOXIN))
		owner.reagents.remove_reagent(AMATOXIN, REM)
	if(owner.reagents.has_reagent(CHLORALHYDRATE))
		owner.reagents.remove_reagent(CHLORALHYDRATE, 2 * REM)
	if(owner.reagents.has_reagent(SUX))
		owner.reagents.remove_reagent(SUX, 0.5 * REM)
	if(owner.reagents.has_reagent(CARPOTOXIN))
		owner.reagents.remove_reagent(CARPOTOXIN, 0.5 * REM)
	if(owner.reagents.has_reagent(MINDBREAKER))
		owner.reagents.remove_reagent(MINDBREAKER, REM)