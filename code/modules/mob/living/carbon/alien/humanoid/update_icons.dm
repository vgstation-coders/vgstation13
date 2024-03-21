/mob/living/carbon/alien/humanoid/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this to be here
	update_icon_state()

/mob/living/carbon/alien/humanoid/proc/update_icon_state()
	if(stat == DEAD)
		if(fireloss > 125)//If we mostly took damage from fire
			icon_state = "alien[caste]_husked"
		else
			icon_state = "alien[caste]_dead"
	else if(lying)
		if(resting)
			icon_state = "alien[caste]_sleep"
		else if(stat == UNCONSCIOUS)
			icon_state = "alien[caste]_unconscious"
		else
			icon_state = "alien[caste]_l"
	else
		if(m_intent == "run")
			icon_state = "alien[caste]_running"
		else
			icon_state = "alien[caste]_s"

/mob/living/carbon/alien/humanoid/regenerate_icons()
	..()
	if (monkeyizing)
		return
	update_inv_hands(FALSE)
	update_inv_pockets(FALSE)
	update_inv_handcuffed(FALSE)
	update_inv_mutual_handcuffed(FALSE)
	update_hud()
	update_icons()
	update_fire()

/mob/living/carbon/alien/humanoid/update_inv_pockets(update_icons = TRUE)
	if(l_store)
		l_store.screen_loc = ui_storage1
	if(r_store)
		r_store.screen_loc = ui_storage2
	if(update_icons)
		update_icons()

/mob/living/carbon/alien/humanoid/update_inv_handcuffed(update_icons = TRUE)
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed)
		drop_hands()
		stop_pulling()	//TODO: should be handled elsewhere
		overlays += overlays_standing[HANDCUFF_LAYER] = mutable_appearance('icons/obj/cuffs.dmi', "[handcuffed.icon_state]", -HANDCUFF_LAYER)
	if(update_icons)
		update_icons()

/mob/living/carbon/alien/humanoid/update_inv_mutual_handcuffed(update_icons = TRUE)
	remove_overlay(HANDCUFF_LAYER)
	if(mutual_handcuffs)
		stop_pulling()
		overlays += overlays_standing[HANDCUFF_LAYER] = mutable_appearance('icons/obj/cuffs.dmi', "singlecuff1", -HANDCUFF_LAYER) //TODO: procedurally generated single-cuffs
	if(update_icons)
		update_icons()

/mob/living/carbon/alien/humanoid/update_fire(update_icons = TRUE)
	remove_overlay(FIRE_LAYER)
	if(!on_fire)
		return
	var/mutable_appearance/fire_overlay = mutable_appearance('icons/mob/OnFire.dmi', "Standing", -FIRE_LAYER)
	if(lying)
		fire_overlay = image(fire_overlay, dir = SOUTH)
		var/matrix/lying_transform = matrix()
		lying_transform.Turn(90)
		lying_transform.Translate(1, -6)
		fire_overlay.transform = lying_transform
	overlays += overlays_standing[FIRE_LAYER] = fire_overlay
	if(update_icons)
		update_icons()
