/mob/proc/pl_effects()

/mob/living/carbon/human/pl_effects()
	//Handles all the bad things plasma can do.

	if(flags & INVULNERABLE)
		return

	//Anything else requires them to not be dead.
	if(stat >= 2)
		return

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
