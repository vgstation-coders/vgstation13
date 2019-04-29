//heart upgrades

/datum/organ/internal/heart //This is not set to vital because death immediately occurs in blood.dm if it is removed.
	name = "heart"
	parent_organ = LIMB_CHEST
	organ_type = "heart"
	removed_type = /obj/item/organ/internal/heart

/datum/organ/internal/heart/cell
	name = "bio-cell"
	removed_type = /obj/item/organ/internal/heart/cell
	min_bruised_damage = 15
	min_broken_damage = 30
	var/obj/item/weapon/cell/cell

/datum/organ/internal/heart/cell/New()
	..()
	if(!cell)
		cell = new /obj/item/weapon/cell/empty()

/datum/organ/internal/heart/cell/Life()
	if(owner && owner.nutrition > 5)
		if(cell.charge < cell.maxcharge)
			cell.give(15)
			owner.nutrition -= 5
