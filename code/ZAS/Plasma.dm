var/image/contamination_overlay = image('icons/effects/contamination.dmi')

	if(species.breath_type != "plasma")

		//Burn skin if exposed.
		if(zas_settings.Get(/datum/ZAS_Setting/SKIN_BURNS))
			if(!pl_head_protected() || !pl_suit_protected())
				burn_skin(0.75)
				if(prob(20)) to_chat(src, "<span class='warning'>Your skin burns!</span>")
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
		if(prob(20)) to_chat(src, "<span class='warning'>Your eyes burn!</span>")
		E.damage += 2.5
		eye_blurry = min(eye_blurry+1.5,50)
		if (prob(max(0,E.damage - 15) + 1) && !eye_blind)
			to_chat(src, "<span class='warning'>You are blinded!</span>")
			eye_blind += 20

/*
/turf/Entered(atom/movable/Obj, atom/OldLoc)
	..(Obj, OldLoc)

	var/obj/item/I = Obj

	// items that are in plasma, but not on a mob, can still be contaminated.
	if(istype(I) && zas_settings.Get(/datum/ZAS_Setting/CLOTH_CONTAMINATION))
		var/datum/gas_mixture/environment = return_air()

		if(environment.toxins > MOLES_PLASMA_VISIBLE + 1)
			if(I.can_contaminate())
				I.contaminate()
*/
