// Kidney upgrade
/datum/organ/internal/kidney/filter
	name = "toxin filters"
	removed_type = /obj/item/organ/kidneys/filter

	min_bruised_damage = 15
	min_broken_damage = 30


/datum/organ/internal/kidney/filter/process()

	if(owner.life_tick % 10 == 0)
		owner.adjustToxLoss(-0.5)