/mob/living/carbon/unarmed_attacked(mob/living/carbon/C)
	if(istype(C))
		share_contact_diseases(C)

	return ..()

/mob/living/carbon/hitby(var/obj/item/I, var/speed, var/dir)
	if(istype(I) && isturf(I.loc))
		if(!restrained() && in_throw_mode && !get_active_hand()) //We're an able-bodied person with an empty hand and intent to catch
			if(speed < EMBED_THROWING_SPEED && put_in_hands(I)) //Can't catch things going too fast
				visible_message("<span class='warning'>\The [src] catches \the [I]!</span>")
				throw_mode_off()
				return 1
	..()
