var/image/contamination_overlay = image('icons/effects/contamination.dmi')

/obj/item
	var/contaminated = 0

/obj/item/proc/can_contaminate()
	return FALSE

/obj/item/clothing/can_contaminate()
	return !(clothing_flags & PLASMAGUARD)

/obj/item/proc/contaminate()
	// do a contamination overlay?
	// temporary measure to keep contamination less deadly than it was.
	if(!contaminated)
		contaminated = 1
		overlays.Add(contamination_overlay)

/obj/item/proc/decontaminate()
	contaminated = 0
	overlays.Remove(contamination_overlay)

/mob/proc/contaminate()

/mob/living/carbon/human/contaminate()
	//See if anything can be contaminated.

	if(!pl_suit_protected())
		suit_contamination()

	if(!pl_head_protected())
		if(prob(1))
			suit_contamination() //Plasma can sometimes get through such an open suit.

//Cannot wash backpacks currently.
//	if(istype(back,/obj/item/weapon/storage/backpack))
//		back.contaminate()

/mob/proc/pl_effects()

/mob/living/carbon/human/pl_effects()
	//Handles all the bad things plasma can do.

	if(flags & INVULNERABLE)
		return

	//Contamination
	if(zas_settings.Get(/datum/ZAS_Setting/CLOTH_CONTAMINATION))
		contaminate()

	//Anything else requires them to not be dead.
	if(stat >= 2)
		return

	if(species.breath_type != GAS_PLASMA)

		//Burn skin if exposed.
		if(zas_settings.Get(/datum/ZAS_Setting/SKIN_BURNS))
			if(!pl_head_protected() || !pl_suit_protected())
				burn_skin(0.75)
				if(prob(20))
					to_chat(src, "<span class='warning'>Your skin burns!</span>")
				updatehealth()

		//Burn eyes if exposed.
		if(zas_settings.Get(/datum/ZAS_Setting/EYE_BURNS))
			var/eye_protection = get_body_part_coverage(EYES)
			if(!eye_protection)
				burn_eyes()

		//Genetic Corruption
		if(zas_settings.Get(/datum/ZAS_Setting/GENETIC_CORRUPTION))
			if(rand(1,10000) < zas_settings.Get(/datum/ZAS_Setting/GENETIC_CORRUPTION))
				randmutb(src)
				to_chat(src, "<span class='warning'>High levels of toxins cause you to spontaneously mutate.</span>")
				domutcheck(src,null)


/mob/living/carbon/human/proc/burn_eyes()
	//The proc that handles eye burning.
	if(!species.has_organ["eyes"])
		return
	var/datum/organ/internal/eyes/E = internal_organs_by_name["eyes"]
	if(E)
		if(prob(20))
			to_chat(src, "<span class='warning'>Your eyes burn!</span>")
		E.damage += 2.5
		eye_blurry = min(eye_blurry+1.5,50)
		if (prob(max(0,E.damage - 15) + 1) && !eye_blind)
			to_chat(src, "<span class='warning'>You are blinded!</span>")
			eye_blind += 20

/mob/living/carbon/human/proc/pl_head_protected()
	//Checks if the head is adequately sealed.
	if(head)
		if(zas_settings.Get(/datum/ZAS_Setting/PLASMAGUARD_ONLY))
			if(head.clothing_flags & PLASMAGUARD)
				return 1
			else if(check_body_part_coverage(EYES))
				head.contaminate()
				return 1
		else if(check_body_part_coverage(EYES))
			return 1
	return 0

/mob/living/carbon/human/proc/pl_suit_protected()
	//Checks if the suit is adequately sealed.
	if(wear_suit)
		if(zas_settings.Get(/datum/ZAS_Setting/PLASMAGUARD_ONLY))
			if(wear_suit.clothing_flags & PLASMAGUARD)
				return 1
			else if(is_slot_hidden(wear_suit.body_parts_covered,HIDEJUMPSUIT))
				wear_suit.contaminate()
				return 1
		else
			if(is_slot_hidden(wear_suit.body_parts_covered,HIDEJUMPSUIT))
				return 1
	return 0

/mob/living/carbon/human/proc/suit_contamination()
	//Runs over the things that can be contaminated and does so.
	if(w_uniform)
		w_uniform.contaminate()
	if(shoes)
		shoes.contaminate()
	if(gloves)
		gloves.contaminate()
