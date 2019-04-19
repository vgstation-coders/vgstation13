/datum/organ/internal/adrenal_gland
	name = "Adrenal gland"
	parent_organ = LIMB_GROIN
	organ_type = "adrenaline_gland"
	removed_type = /obj/item/organ/internal/adrenal
	var/event_key

/datum/organ/internal/adrenal_gland/Insert(var/mob/living/carbon/human/H)
	event_key = H.on_damaged.Add(src, "on_damage")

/datum/organ/internal/adrenal_gland/Remove(var/mob/living/carbon/human/H)
	H.on_damaged.Remove(event_key)

/datum/organ/internal/adrenal_gland/proc/on_damage(var/list/args)
	if(owner.stat != DEAD && !is_broken() && (args["type"] == BRUTE || args["type"] == BURN) && args["amount"] >= owner.maxHealth/4)
		if(!owner.reagents.has_reagent(ADRENALINE))
			to_chat(owner, "<span class = 'notice'>You feel a surge of adrenaline!</span>")
		owner.reagents.add_reagent(ADRENALINE, args["amount"]/10-owner.reagents.get_reagent_amount(ADRENALINE))