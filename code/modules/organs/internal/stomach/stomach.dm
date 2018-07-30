/**
	Stomach organ

	Literally just a pseudo-organ used for handling the mass removal of reagents from a person.
**/

/datum/organ/internal/stomach
	name = "stomach"
	parent_organ = LIMB_CHEST
	organ_type = "stomach"
	var/reagent_size = 1000
	removed_type = /obj/item/organ/internal/stomach

/datum/organ/internal/stomach/Copy()
	var/datum/organ/internal/stomach/S = ..()
	S.reagent_size = reagent_size
	return S

/datum/organ/internal/stomach/remove(var/mob/user, var/quiet=0)
	var/obj/item/organ/internal/stomach/S = ..()
	owner.reagents.trans_to(S, owner.reagents.total_volume)
	owner.reagents.maximum_volume = 25
	return S

/datum/organ/internal/stomach/Insert(var/mob/living/carbon/human/H, var/mob/surgeon=null, var/quiet=0)
	.=..()
	if(H.reagents)
		H.reagents.clear_reagents()
		H.reagents.maximum_volume = reagent_size