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
	update_inv_w_uniform(0)
	update_inv_wear_mask(0)
	update_inv_back(0)
	update_inv_glasses(0)
	update_inv_head(0)
	update_inv_hands(0)
	update_inv_handcuffed(0)
	update_inv_mutual_handcuffed(0)
	update_fire()
	update_icons()
	return

/mob/living/carbon/monkey/update_icons()
	update_hud()
	update_transform()

/mob/living/carbon/monkey/update_inv_w_uniform(update_icons = TRUE)
	remove_overlay(UNIFORM_LAYER)
	if(uniform && uniform.is_visible())
		var/t_state = uniform.item_state || uniform.icon_state
		var/mutable_appearance/uniform_overlay = mutable_appearance(((uniform.icon_override) ? uniform.icon_override : 'icons/mob/monkey.dmi'), "[t_state]", -UNIFORM_LAYER)
		if(uniform.dynamic_overlay)
			if(uniform.dynamic_overlay["[UNIFORM_LAYER]"])
				var/mutable_appearance/dyn_overlay = uniform.dynamic_overlay["[UNIFORM_LAYER]"]
				uniform_overlay.overlays += dyn_overlay
		overlays += overlays_standing[UNIFORM_LAYER] = uniform_overlay
		uniform.screen_loc = ui_monkey_uniform
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/update_inv_head(update_icons = TRUE, pixel_y_adjustment = 0)
	remove_overlay(HEAD_LAYER)
	if(hat && hat.is_visible())
		var/t_state = hat.icon_state
		var/mutable_appearance/hat_overlay = mutable_appearance(((hat.icon_override) ? hat.icon_override : 'icons/mob/monkey_head.dmi'), "[t_state]", -HEAD_LAYER)
		hat_overlay.pixel_y = pixel_y_adjustment
		if(hat.dynamic_overlay)
			if(hat.dynamic_overlay["[HEAD_LAYER]"])
				var/mutable_appearance/dyn_overlay = hat.dynamic_overlay["[HEAD_LAYER]"]
				hat_overlay.overlays += dyn_overlay
		var/i = 1
		var/mutable_appearance/aboveimg
		for(var/obj/item/clothing/head/above = hat.on_top; above; above = above.on_top)
			aboveimg = mutable_appearance(((above.icon_override) ? above.icon_override : 'icons/mob/head.dmi'), "[above.icon_state]")

			aboveimg.pixel_y = (2 * i) * PIXEL_MULTIPLIER
			hat_overlay.overlays += aboveimg

			if(above.dynamic_overlay)
				if(above.dynamic_overlay["[HEAD_LAYER]"])
					var/mutable_appearance/dyn_overlay = above.dynamic_overlay["[HEAD_LAYER]"]
					aboveimg.overlays += dyn_overlay
			i++
		overlays += overlays_standing[HEAD_LAYER] = hat_overlay
		hat.screen_loc = ui_monkey_hat
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/diona/update_inv_head()
	..(pixel_y_adjustment = -7 * PIXEL_MULTIPLIER)

/mob/living/carbon/monkey/roach/update_inv_head()
	..(pixel_y_adjustment = -7 * PIXEL_MULTIPLIER)

/mob/living/carbon/monkey/vox/update_inv_head()
	..(pixel_y_adjustment = -12 * PIXEL_MULTIPLIER)

/mob/living/carbon/monkey/update_inv_glasses(update_icons = TRUE)
	remove_overlay(GLASSES_LAYER)
	if(glasses && glasses.is_visible())
		var/t_state = glasses.icon_state
		var/mutable_appearance/glasses_overlay = mutable_appearance(((glasses.icon_override) ? glasses.icon_override : 'icons/mob/monkey_eyes.dmi'), "[t_state]", -GLASSES_LAYER)
		if(glasses.dynamic_overlay)
			if(glasses.dynamic_overlay["[GLASSES_LAYER]"])
				var/mutable_appearance/dyn_overlay = glasses.dynamic_overlay["[GLASSES_LAYER]"]
				glasses_overlay.overlays += dyn_overlay
		overlays += overlays_standing[GLASSES_LAYER] = glasses_overlay
		glasses.screen_loc = ui_monkey_glasses
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/update_inv_wear_mask(update_icons = TRUE, pixel_y_adjustment = 0)
	remove_overlay(FACEMASK_LAYER)
	if(isitem(wear_mask) && wear_mask.is_visible())
		var/mutable_appearance/mask_overlay	= mutable_appearance(((wear_mask.icon_override) ? wear_mask.icon_override : 'icons/mob/monkey.dmi'), "[wear_mask.icon_state]", -FACEMASK_LAYER)
		mask_overlay.pixel_y = pixel_y_adjustment
		if(wear_mask.dynamic_overlay)
			if(wear_mask.dynamic_overlay["[FACEMASK_LAYER]"])
				var/mutable_appearance/dyn_overlay = wear_mask.dynamic_overlay["[FACEMASK_LAYER]"]
				mask_overlay.overlays += dyn_overlay
		overlays += overlays_standing[FACEMASK_LAYER] = mask_overlay
		wear_mask.screen_loc = ui_monkey_mask
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/diona/update_inv_wear_mask()
	..(pixel_y_adjustment = -7 * PIXEL_MULTIPLIER)

/mob/living/carbon/monkey/roach/update_inv_wear_mask()
	..(pixel_y_adjustment = -9 * PIXEL_MULTIPLIER)

/mob/living/carbon/monkey/vox/update_inv_wear_mask()
	..(pixel_y_adjustment = -12 * PIXEL_MULTIPLIER)

/mob/living/carbon/monkey/update_inv_back(update_icons = TRUE, pixel_y_adjustment = 0)
	remove_overlay(BACK_LAYER)
	if(back && back.is_visible())
		var/mutable_appearance/back_overlay = mutable_appearance('icons/mob/back.dmi', "[back.icon_state]", -BACK_LAYER)
		back_overlay.pixel_y = pixel_y_adjustment
		if(back.dynamic_overlay)
			if(back.dynamic_overlay["[BACK_LAYER]"])
				var/mutable_appearance/dyn_overlay = back.dynamic_overlay["[BACK_LAYER]"]
				back_overlay.overlays += dyn_overlay
		overlays += overlays_standing[BACK_LAYER] = back_overlay
		back.screen_loc = ui_monkey_back
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/diona/update_inv_back()//needed for pixel_y adjustment
	..(pixel_y_adjustment = -5 * PIXEL_MULTIPLIER)

/mob/living/carbon/monkey/roach/update_inv_back()
	..(pixel_y_adjustment = -2 * PIXEL_MULTIPLIER)

/mob/living/carbon/monkey/vox/update_inv_back()//Sorry for the copypaste
	..(pixel_y_adjustment = -5 * PIXEL_MULTIPLIER)

/mob/living/carbon/monkey/update_inv_handcuffed(update_icons = TRUE)
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed && handcuffed.is_visible())
		drop_hands()
		stop_pulling()
		overlays += overlays_standing[HANDCUFF_LAYER] = mutable_appearance('icons/obj/cuffs_monkey.dmi', "[handcuffed.icon_state]", -HANDCUFF_LAYER)
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/update_inv_mutual_handcuffed(update_icons = TRUE)
	remove_overlay(HANDCUFF_LAYER)
	if(mutual_handcuffs)
		stop_pulling()
		overlays += overlays_standing[HANDCUFF_LAYER] = mutable_appearance('icons/obj/cuffs_monkey.dmi', "singlecuff1", -HANDCUFF_LAYER)//TODO: procedurally generated single-cuffs
	if(update_icons)
		update_icons()

/mob/living/carbon/monkey/update_fire()
	remove_overlay(FIRE_LAYER)
	if(!on_fire)
		return
	var/mutable_appearance/fire_overlay = mutable_appearance('icons/mob/OnFire.dmi', "Standing", -FIRE_LAYER)
	overlays += overlays_standing[FIRE_LAYER] = fire_overlay
