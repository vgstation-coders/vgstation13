/mob/living/carbon/unarmed_attacked(mob/living/carbon/C)
	if(istype(C))
		share_contact_diseases(C)

	return ..()
