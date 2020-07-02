//Xeno Overlays Indexes//////////
#define X_L_HAND_LAYER			1
#define X_R_HAND_LAYER			2
#define X_HANDCUFF_LAYER		3
#define X_FIRE_LAYER			4
#define X_TARGETED_LAYER			5
#define X_TOTAL_LAYERS			6
/////////////////////////////////

/mob/living/carbon/alien/humanoid
	var/list/overlays_lying[X_TOTAL_LAYERS]
	var/list/overlays_standing[X_TOTAL_LAYERS]

/mob/living/carbon/alien/humanoid/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this to be here
	overlays.len = 0
	if(stat == DEAD)
		if(fireloss > 125)//If we mostly took damage from fire
			icon_state = "alien[caste]_husked"
		else
			icon_state = "alien[caste]_dead"
		for(var/image/I in overlays_lying)
			overlays += I
	else if(lying)
		if(resting)
			icon_state = "alien[caste]_sleep"
		else if(stat == UNCONSCIOUS)
			icon_state = "alien[caste]_unconscious"
		else
			icon_state = "alien[caste]_l"
		for(var/image/I in overlays_lying)
			overlays += I
	else
		if(m_intent == "run")
			icon_state = "alien[caste]_running"
		else						icon_state = "alien[caste]_s"
		for(var/image/I in overlays_standing)
			overlays += I

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

/mob/living/carbon/alien/humanoid/update_hud()
	//TODO
	if (client)
		update_internals()
		client.screen |= contents

/mob/living/carbon/alien/humanoid/update_inv_pockets(var/update_icons=TRUE)
	if(l_store)
		l_store.screen_loc = ui_storage1
	if(r_store)
		r_store.screen_loc = ui_storage2
	if(update_icons)
		update_icons()

/mob/living/carbon/alien/humanoid/update_inv_hand(index, var/update_icons=TRUE)
	switch(index)
		if(GRASP_LEFT_HAND)
			return update_inv_l_hand(update_icons)
		if(GRASP_RIGHT_HAND)
			return update_inv_r_hand(update_icons)

/mob/living/carbon/alien/humanoid/update_inv_r_hand(var/update_icons=TRUE)
	overlays -= overlays_standing[X_R_HAND_LAYER]
	var/obj/item/I = get_held_item_by_index(GRASP_RIGHT_HAND)

	if(I)
		var/t_state = I.item_state
		var/t_inhand_state = I.inhand_states["right_hand"]
		if(!t_state)
			t_state = I.icon_state
		I.screen_loc = ui_rhand
		overlays_standing[X_R_HAND_LAYER]	= image("icon" = t_inhand_state, "icon_state" = t_state)
		if(handcuffed)
			drop_item(I)
	else
		overlays_standing[X_R_HAND_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/alien/humanoid/update_inv_l_hand(var/update_icons=TRUE)
	overlays -= overlays_standing[X_L_HAND_LAYER]
	var/obj/item/I = get_held_item_by_index(GRASP_LEFT_HAND)

	if(I)
		var/t_state = I.item_state
		var/t_inhand_state = I.inhand_states["left_hand"] //this is a file
		if(!t_state)
			t_state = I.icon_state
		I.screen_loc = ui_lhand
		overlays_standing[X_L_HAND_LAYER]	= image("icon" = t_inhand_state, "icon_state" = t_state)
		if(handcuffed)
			drop_item(I)
	else
		overlays_standing[X_L_HAND_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/alien/humanoid/update_inv_handcuffed(var/update_icons=TRUE)
	if(handcuffed)
		drop_hands()
		stop_pulling()	//TODO: should be handled elsewhere
		overlays_standing[X_HANDCUFF_LAYER]	= image(icon = 'icons/mob/mob.dmi', icon_state = "handcuff1")
	else
		overlays_standing[X_HANDCUFF_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/alien/humanoid/update_inv_mutual_handcuffed(var/update_icons = TRUE)
	if(mutual_handcuffs)
		stop_pulling()
		overlays_standing[X_HANDCUFF_LAYER]	= image(icon = 'icons/mob/mob.dmi', icon_state = "singlecuff1")
	else
		overlays_standing[X_HANDCUFF_LAYER]	= null
	if(update_icons)
		update_icons()

//Call when target overlay should be added/removed
/mob/living/carbon/alien/humanoid/update_targeted(var/update_icons=TRUE)
	if (targeted_by && target_locked)
		overlays_lying[X_TARGETED_LAYER]		= target_locked
		overlays_standing[X_TARGETED_LAYER]	= target_locked
	else if (!targeted_by && target_locked)
		del(target_locked)
	if (!targeted_by)
		overlays_lying[X_TARGETED_LAYER]		= null
		overlays_standing[X_TARGETED_LAYER]	= null
	if(update_icons)
		update_icons()


/mob/living/carbon/alien/humanoid/update_fire()
	overlays -= overlays_lying[X_FIRE_LAYER]
	overlays -= overlays_standing[X_FIRE_LAYER]
	if(on_fire)
		overlays_lying[X_FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Lying", "layer"= -X_FIRE_LAYER)
		overlays_standing[X_FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing", "layer"= -X_FIRE_LAYER)
		if(src.lying)
			overlays += overlays_lying[X_FIRE_LAYER]
		else
			overlays += overlays_standing[X_FIRE_LAYER]
		return
	else
		overlays_lying[X_FIRE_LAYER] = null
		overlays_standing[X_FIRE_LAYER] = null

//Xeno Overlays Indexes//////////
#undef X_L_HAND_LAYER
#undef X_R_HAND_LAYER
#undef X_TARGETED_LAYER
#undef X_FIRE_LAYER
#undef X_TOTAL_LAYERS
