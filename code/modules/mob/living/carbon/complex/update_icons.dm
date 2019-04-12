/mob/living/carbon/complex/update_icons()
	update_hud()

	lying_prev = lying

	if(isDead())
		icon_state = icon_state_dead
	else if(lying)
		icon_state = icon_state_lying
	else
		icon_state = icon_state_standing

/mob/living/carbon/complex/regenerate_icons()
	..()

	for(var/i = 1 to held_items.len)
		update_inv_hand(i)

	update_fire()
	update_icons()