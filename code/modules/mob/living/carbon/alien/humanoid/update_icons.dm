//Xeno Overlays Indexes//////////
#define X_HEAD_LAYER			1
#define X_SUIT_LAYER			2
#define X_L_HAND_LAYER			3
#define X_R_HAND_LAYER			4
#define X_FIRE_LAYER			5
#define TARGETED_LAYER			6
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
		//If we mostly took damage from fire
		if(fireloss > 125)
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
		if(m_intent == "run")		icon_state = "alien[caste]_running"
		else						icon_state = "alien[caste]_s"
		for(var/image/I in overlays_standing)
			overlays += I

/mob/living/carbon/alien/humanoid/regenerate_icons()
	..()
	if (monkeyizing)	return

	update_inv_head(0)
	update_inv_wear_suit(0)
	update_inv_hands(0)
	update_inv_pockets(0)
	update_hud()
	update_icons()
	update_fire()

/mob/living/carbon/alien/humanoid/update_hud()
	//TODO
	if (client)
//		if(other)	client.screen |= hud_used.other		//Not used
//		else		client.screen -= hud_used.other		//Not used
		client.screen |= contents

//These update icons are essentially derelict and unused
/mob/living/carbon/alien/humanoid/update_inv_wear_suit(var/update_icons=1)
	if(wear_suit)
		var/t_state = wear_suit.item_state
		if(!t_state)	t_state = wear_suit.icon_state
		//var/image/lying		= image("icon" = ((wear_suit.icon_override) ? wear_suit.icon_override : 'icons/mob/suit.dmi'), "icon_state" = "[t_state]")
		var/image/standing	= image("icon" = ((wear_suit.icon_override) ? wear_suit.icon_override : 'icons/mob/suit.dmi'), "icon_state" = "[t_state]")

		if(wear_suit.blood_DNA && wear_suit.blood_DNA.len)
			//lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "[t_suit]blood")
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "[wear_suit.blood_overlay_type]blood")
			bloodsies.color = wear_suit.blood_color
			standing.overlays += bloodsies

		//TODO
		wear_suit.screen_loc = ui_alien_oclothing
		if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			drop_from_inventory(handcuffed)
			drop_hands()

		//overlays_lying[X_SUIT_LAYER]	= lying
		overlays_standing[X_SUIT_LAYER]	= standing
	else
		//overlays_lying[X_SUIT_LAYER]	= null
		overlays_standing[X_SUIT_LAYER]	= null
	if(update_icons)	update_icons()


/mob/living/carbon/alien/humanoid/update_inv_head(var/update_icons=1)
	if (head)
		var/t_state = head.item_state
		if(!t_state)	t_state = head.icon_state
		var/image/lying		= image(((head.icon_override) ? head.icon_override : 'icons/mob/head.dmi'), "icon_state" = "[t_state]")
		var/image/standing	= image(((head.icon_override) ? head.icon_override : 'icons/mob/head.dmi'), "icon_state" = "[t_state]")
		if(head.blood_DNA && head.blood_DNA.len)
			lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood")
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood")
		head.screen_loc = ui_alien_head
		overlays_lying[X_HEAD_LAYER]	= lying
		overlays_standing[X_HEAD_LAYER]	= standing
	else
		overlays_lying[X_HEAD_LAYER]	= null
		overlays_standing[X_HEAD_LAYER]	= null
	if(update_icons)	update_icons()


/mob/living/carbon/alien/humanoid/update_inv_pockets(var/update_icons=1)
	if(l_store)		l_store.screen_loc = ui_storage1
	if(r_store)		r_store.screen_loc = ui_storage2
	if(update_icons)	update_icons()

/mob/living/carbon/alien/humanoid/update_inv_hand(index, var/update_icons = 1)
	switch(index)
		if(GRASP_LEFT_HAND)
			return update_inv_l_hand(update_icons)
		if(GRASP_RIGHT_HAND)
			return update_inv_r_hand(update_icons)

/mob/living/carbon/alien/humanoid/update_inv_r_hand(var/update_icons=1)
	overlays -= overlays_standing[X_R_HAND_LAYER]
	var/obj/item/I = get_held_item_by_index(GRASP_RIGHT_HAND)

	if(I)
		var/t_state = I.item_state
		var/t_inhand_state = I.inhand_states["right_hand"]
		if(!t_state)	t_state = I.icon_state
		I.screen_loc = ui_rhand
		overlays_standing[X_R_HAND_LAYER]	= image("icon" = t_inhand_state, "icon_state" = t_state)
	else
		overlays_standing[X_R_HAND_LAYER]	= null
	if(update_icons)	update_icons()

/mob/living/carbon/alien/humanoid/update_inv_l_hand(var/update_icons=1)
	overlays -= overlays_standing[X_L_HAND_LAYER]
	var/obj/item/I = get_held_item_by_index(GRASP_LEFT_HAND)

	if(I)
		var/t_state = I.item_state
		var/t_inhand_state = I.inhand_states["left_hand"] //this is a file
		if(!t_state)	t_state = I.icon_state
		I.screen_loc = ui_lhand
		overlays_standing[X_L_HAND_LAYER]	= image("icon" = t_inhand_state, "icon_state" = t_state)
	else
		overlays_standing[X_L_HAND_LAYER]	= null
	if(update_icons)	update_icons()

//Call when target overlay should be added/removed
/mob/living/carbon/alien/humanoid/update_targeted(var/update_icons=1)
	if (targeted_by && target_locked)
		overlays_lying[TARGETED_LAYER]		= target_locked
		overlays_standing[TARGETED_LAYER]	= target_locked
	else if (!targeted_by && target_locked)
		del(target_locked)
	if (!targeted_by)
		overlays_lying[TARGETED_LAYER]		= null
		overlays_standing[TARGETED_LAYER]	= null
	if(update_icons)		update_icons()


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
#undef X_HEAD_LAYER
#undef X_SUIT_LAYER
#undef X_L_HAND_LAYER
#undef X_R_HAND_LAYER
#undef TARGETED_LAYER
#undef X_FIRE_LAYER
#undef X_TOTAL_LAYERS
