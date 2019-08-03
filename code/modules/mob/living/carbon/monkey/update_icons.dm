//Monkey Overlays Indexes////////
#define M_UNIFORM_LAYER			1
#define M_MASK_LAYER			2
#define M_BACK_LAYER			3
#define M_GLASSES_LAYER			4
#define M_HAT_LAYER				5
#define M_HANDCUFF_LAYER		6
#define M_L_HAND_LAYER			7
#define M_R_HAND_LAYER			8
#define M_FIRE_LAYER			9
#define M_TARGETED_LAYER		10
#define M_TOTAL_LAYERS			10
/////////////////////////////////

/mob/living/carbon/monkey
	var/list/overlays_lying[M_TOTAL_LAYERS]
	var/list/overlays_standing[M_TOTAL_LAYERS]

/mob/living/carbon/monkey/regenerate_icons()
	..()
	var/icon/opacity_icon = new(icon)
	if(body_alphas.len)
		opacity_icon.ChangeOpacity(ARBITRARILY_LARGE_NUMBER)
		var/lowest_alpha = get_lowest_body_alpha()
		if(lowest_alpha == 0)
			lowest_alpha = 1
		opacity_icon.ChangeOpacity(min(0.004, lowest_alpha/255))
	else
		opacity_icon.ChangeOpacity(ARBITRARILY_LARGE_NUMBER)
	icon = opacity_icon

	update_inv_uniform(0)
	update_inv_wear_mask(0)
	update_inv_back(0)
	update_inv_glasses(0)
	update_inv_hat(0)
	update_inv_hands(0)
	update_inv_handcuffed(0)
	update_inv_mutual_handcuffed(0)
	update_fire()
	update_icons()
	//Hud Stuff
	update_hud()
	return

/mob/living/carbon/monkey/update_icons()
	update_hud()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	overlays.len = 0
	for(var/image/I in overlays_standing)
		overlays += I

	if(lying)
		var/matrix/M = matrix()
		M.Turn(90)
		M.Translate(1,-6)
		src.transform = M
	else
		var/matrix/M = matrix()
		src.transform = M


////////
/mob/living/carbon/monkey/proc/update_inv_uniform(var/update_icons=1)
	if(uniform && uniform.is_visible())
		var/t_state = uniform.item_state
		if(!t_state)
			t_state = uniform.icon_state

		var/image/I = image(icon = 'icons/mob/monkey.dmi', icon_state = t_state)
		if(uniform.dynamic_overlay)
			if(uniform.dynamic_overlay["[UNIFORM_LAYER]"])
				var/image/dyn_overlay = uniform.dynamic_overlay["[UNIFORM_LAYER]"]
				I.overlays += dyn_overlay
		overlays_standing[M_UNIFORM_LAYER]	= I
		uniform.screen_loc = ui_monkey_uniform
	else
		overlays_standing[M_UNIFORM_LAYER]	= null
	if(update_icons)
		update_icons()


/mob/living/carbon/monkey/proc/update_inv_hat(var/update_icons=1)
	if(hat && hat.is_visible())
		var/t_state = hat.icon_state

		var/image/I = image(icon = 'icons/mob/monkey_head.dmi', icon_state = t_state)
		if(hat.dynamic_overlay)
			if(hat.dynamic_overlay["[HEAD_LAYER]"])
				var/image/dyn_overlay = hat.dynamic_overlay["[HEAD_LAYER]"]
				I.overlays += dyn_overlay
		overlays_standing[M_HAT_LAYER]	= I
		hat.screen_loc = ui_monkey_hat
	else
		overlays_standing[M_HAT_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/diona/update_inv_hat(var/update_icons=1)//needed for pixel_y adjustment
	if(hat && hat.is_visible())
		var/t_state = hat.icon_state

		var/image/I = image(icon = 'icons/mob/monkey_head.dmi', icon_state = t_state, pixel_y = -7 * PIXEL_MULTIPLIER)
		if(hat.dynamic_overlay)
			if(hat.dynamic_overlay["[HEAD_LAYER]"])
				var/image/dyn_overlay = hat.dynamic_overlay["[HEAD_LAYER]"]
				I.overlays += dyn_overlay
		overlays_standing[M_HAT_LAYER]	= I
		hat.screen_loc = ui_monkey_hat
	else
		overlays_standing[M_HAT_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/vox/update_inv_hat(var/update_icons=1)//Sorry for the copypaste
	if(hat && hat.is_visible())
		var/t_state = hat.icon_state

		var/image/I = image(icon = 'icons/mob/monkey_head.dmi', icon_state = t_state, pixel_y = -12 * PIXEL_MULTIPLIER)
		if(hat.dynamic_overlay)
			if(hat.dynamic_overlay["[HEAD_LAYER]"])
				var/image/dyn_overlay = hat.dynamic_overlay["[HEAD_LAYER]"]
				I.overlays += dyn_overlay
		overlays_standing[M_HAT_LAYER]	= I
		hat.screen_loc = ui_monkey_hat
	else
		overlays_standing[M_HAT_LAYER]	= null
	if(update_icons)
		update_icons()



/mob/living/carbon/monkey/update_inv_glasses(var/update_icons=1)
	if(glasses && glasses.is_visible())
		var/t_state = glasses.icon_state

		var/image/I = image("icon" = 'icons/mob/monkey_eyes.dmi', "icon_state" = t_state)
		if(glasses.dynamic_overlay)
			if(glasses.dynamic_overlay["[GLASSES_LAYER]"])
				var/image/dyn_overlay = glasses.dynamic_overlay["[GLASSES_LAYER]"]
				I.overlays += dyn_overlay
		overlays_standing[M_GLASSES_LAYER]	= I
		glasses.screen_loc = ui_monkey_glasses
	else
		overlays_standing[M_GLASSES_LAYER]	= null
	if(update_icons)
		update_icons()


/mob/living/carbon/monkey/update_inv_wear_mask(var/update_icons=1)
	if( wear_mask && istype(wear_mask, /obj/item/clothing/mask) && wear_mask.is_visible())

		var/image/I = image("icon" = 'icons/mob/monkey.dmi', "icon_state" = "[wear_mask.icon_state]")
		if(wear_mask.dynamic_overlay)
			if(wear_mask.dynamic_overlay["[FACEMASK_LAYER]"])
				var/image/dyn_overlay = wear_mask.dynamic_overlay["[FACEMASK_LAYER]"]
				I.overlays += dyn_overlay
		overlays_standing[M_MASK_LAYER]	= I
		wear_mask.screen_loc = ui_monkey_mask
	else
		overlays_standing[M_MASK_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/diona/update_inv_wear_mask(var/update_icons=1)//needed for pixel_y adjustment
	if( wear_mask && istype(wear_mask, /obj/item/clothing/mask) && wear_mask.is_visible())

		var/image/I = image(icon = 'icons/mob/monkey.dmi', icon_state = "[wear_mask.icon_state]", pixel_y = -7 * PIXEL_MULTIPLIER)
		if(wear_mask.dynamic_overlay)
			if(wear_mask.dynamic_overlay["[FACEMASK_LAYER]"])
				var/image/dyn_overlay = wear_mask.dynamic_overlay["[FACEMASK_LAYER]"]
				I.overlays += dyn_overlay
		overlays_standing[M_MASK_LAYER]	= I
		wear_mask.screen_loc = ui_monkey_mask
	else
		overlays_standing[M_MASK_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/vox/update_inv_wear_mask(var/update_icons=1)//Sorry for the copypaste
	if( wear_mask && istype(wear_mask, /obj/item/clothing/mask) && wear_mask.is_visible())

		var/image/I = image(icon = 'icons/mob/monkey.dmi', icon_state = "[wear_mask.icon_state]", pixel_y = -12 * PIXEL_MULTIPLIER)
		if(wear_mask.dynamic_overlay)
			if(wear_mask.dynamic_overlay["[FACEMASK_LAYER]"])
				var/image/dyn_overlay = wear_mask.dynamic_overlay["[FACEMASK_LAYER]"]
				I.overlays += dyn_overlay
		overlays_standing[M_MASK_LAYER]	= I
		wear_mask.screen_loc = ui_monkey_mask
	else
		overlays_standing[M_MASK_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/update_inv_hand(index, var/update_icons = 1)
	switch(index)
		if(GRASP_LEFT_HAND)
			return update_inv_l_hand(update_icons)
		if(GRASP_RIGHT_HAND)
			return update_inv_r_hand(update_icons)

/mob/living/carbon/monkey/update_inv_r_hand(var/update_icons=1)
	var/obj/item/I = get_held_item_by_index(GRASP_RIGHT_HAND)
	if(I && I.is_visible())
		var/t_state = I.item_state
		var/t_inhand_states = I.inhand_states["right_hand"]
		if(!t_state)
			t_state = I.icon_state
		var/image/IM = image("icon" = t_inhand_states, "icon_state" = t_state)
		if(I.dynamic_overlay && I.dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"])
			var/image/dyn_overlay = I.dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"]
			IM.overlays.Add(dyn_overlay)
		overlays_standing[M_R_HAND_LAYER]	= IM
		I.screen_loc = ui_rhand
		if (handcuffed)
			drop_item(I)
	else
		overlays_standing[M_R_HAND_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/update_inv_l_hand(var/update_icons=1)
	var/obj/item/I = get_held_item_by_index(GRASP_LEFT_HAND)
	if(I && I.is_visible())
		var/t_state = I.item_state
		var/t_inhand_states = I.inhand_states["left_hand"]
		if(!t_state)
			t_state = I.icon_state
		var/image/IM = image("icon" = t_inhand_states, "icon_state" = t_state)
		if(I.dynamic_overlay && I.dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"])
			var/image/dyn_overlay = I.dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"]
			IM.overlays.Add(dyn_overlay)
		overlays_standing[M_L_HAND_LAYER]	= IM
		I.screen_loc = ui_lhand
		if (handcuffed)
			drop_item(I)
	else
		overlays_standing[M_L_HAND_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/update_inv_back(var/update_icons=1)
	if(back && back.is_visible())
		var/image/I = image("icon" = 'icons/mob/back.dmi', "icon_state" = "[back.icon_state]")
		if(back.dynamic_overlay)
			if(back.dynamic_overlay["[BACK_LAYER]"])
				var/image/dyn_overlay = back.dynamic_overlay["[BACK_LAYER]"]
				I.overlays += dyn_overlay
		overlays_standing[M_BACK_LAYER]	= I
		back.screen_loc = ui_monkey_back
	else
		overlays_standing[M_BACK_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/diona/update_inv_back(var/update_icons=1)//needed for pixel_y adjustment
	if(back && back.is_visible())
		var/image/I = image(icon = 'icons/mob/back.dmi', icon_state = "[back.icon_state]", pixel_y = -5 * PIXEL_MULTIPLIER)
		if(back.dynamic_overlay)
			if(back.dynamic_overlay["[BACK_LAYER]"])
				var/image/dyn_overlay = back.dynamic_overlay["[BACK_LAYER]"]
				I.overlays += dyn_overlay
		overlays_standing[M_BACK_LAYER]	= I
		back.screen_loc = ui_monkey_back
	else
		overlays_standing[M_BACK_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/vox/update_inv_back(var/update_icons=1)//Sorry for the copypaste
	if(back && back.is_visible())
		var/image/I = image(icon = 'icons/mob/back.dmi', icon_state = "[back.icon_state]", pixel_y = -5 * PIXEL_MULTIPLIER)
		if(back.dynamic_overlay)
			if(back.dynamic_overlay["[BACK_LAYER]"])
				var/image/dyn_overlay = back.dynamic_overlay["[BACK_LAYER]"]
				I.overlays += dyn_overlay
		overlays_standing[M_BACK_LAYER]	= I
		back.screen_loc = ui_monkey_back
	else
		overlays_standing[M_BACK_LAYER]	= null
	if(update_icons)
		update_icons()


/mob/living/carbon/monkey/update_inv_handcuffed(var/update_icons=1)
	if(handcuffed && handcuffed.is_visible())
		drop_hands()
		stop_pulling()
		overlays_standing[M_HANDCUFF_LAYER]	= image(icon = 'icons/mob/monkey.dmi', icon_state = "handcuff1")
	else
		overlays_standing[M_HANDCUFF_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/update_inv_mutual_handcuffed(var/update_icons = TRUE)
	if(mutual_handcuffs)
		stop_pulling()
		overlays_standing[M_HANDCUFF_LAYER]	= image(icon = 'icons/mob/monkey.dmi', icon_state = "singlecuff1")
	else
		overlays_standing[M_HANDCUFF_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/update_hud()
	if(client)
		update_internals()
		client.screen |= contents

//Call when target overlay should be added/removed
/mob/living/carbon/monkey/update_targeted(var/update_icons=1)
	if (targeted_by && target_locked)
		overlays_standing[M_TARGETED_LAYER]	= target_locked
	else if (!targeted_by && target_locked)
		del(target_locked)
	if (!targeted_by)
		overlays_standing[M_TARGETED_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/update_fire()
	overlays -= overlays_standing[M_FIRE_LAYER]
	if(on_fire)
		overlays_standing[M_FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing", "layer"= -M_FIRE_LAYER)
		overlays += overlays_standing[M_FIRE_LAYER]
	else
		overlays_standing[M_FIRE_LAYER] = null

//Monkey Overlays Indexes////////
#undef M_HAT_LAYER
#undef M_GLASSES_LAYER
#undef M_UNIFORM_LAYER
#undef M_FIRE_LAYER
#undef M_MASK_LAYER
#undef M_BACK_LAYER
#undef M_HANDCUFF_LAYER
#undef M_L_HAND_LAYER
#undef M_R_HAND_LAYER
#undef M_TARGETED_LAYER
#undef M_TOTAL_LAYERS
