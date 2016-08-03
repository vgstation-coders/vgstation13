/datum/hud/proc/human_hud(var/ui_style='icons/mob/screen1_White.dmi', var/ui_color = "#ffffff", var/ui_alpha = 255)


	src.adding = list()
	src.other = list()
	src.hotkeybuttons = list() //These can be disabled for hotkey usersx

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = getFromPool(/obj/screen)
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = ui_style
	using.icon_state = "intent_"+mymob.a_intent
	using.screen_loc = ui_acti
	src.adding += using
	action_intent = using

//intent small hud objects
	var/icon/ico

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),1,ico.Height()/2,ico.Width()/2,ico.Height())
	using = getFromPool(/obj/screen,src)
	using.name = "help"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = HUD_ABOVE_ITEM_LAYER
	src.adding += using
	help_intent = using

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),ico.Width()/2,ico.Height()/2,ico.Width(),ico.Height())
	using = getFromPool(/obj/screen,src)
	using.name = "disarm"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = HUD_ABOVE_ITEM_LAYER
	src.adding += using
	disarm_intent = using

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),ico.Width()/2,1,ico.Width(),ico.Height()/2)
	using = getFromPool(/obj/screen,src)
	using.name = "grab"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = HUD_ABOVE_ITEM_LAYER
	src.adding += using
	grab_intent = using

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),1,1,ico.Width()/2,ico.Height()/2)
	using = getFromPool(/obj/screen,src)
	using.name = "harm"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = HUD_ABOVE_ITEM_LAYER
	src.adding += using
	hurt_intent = using

//end intent small hud objects

	using = getFromPool(/obj/screen)
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using
	move_intent = using

	using = getFromPool(/obj/screen)
	using.name = "drop"
	using.icon = ui_style
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	using.layer = HUD_BASE_LAYER
	using.color = ui_color
	using.alpha = ui_alpha
	src.hotkeybuttons += using

	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "i_clothing"
	inv_box.dir = SOUTH
	inv_box.icon = ui_style
	inv_box.slot_id = slot_w_uniform
	inv_box.icon_state = "center"
	inv_box.screen_loc = ui_iclothing
	inv_box.layer = HUD_BASE_LAYER
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "o_clothing"
	inv_box.dir = SOUTH
	inv_box.icon = ui_style
	inv_box.slot_id = slot_wear_suit
	inv_box.icon_state = "equip"
	inv_box.screen_loc = ui_oclothing
	inv_box.layer = HUD_BASE_LAYER
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	init_hand_icons(ui_style, ui_color, ui_alpha)

	using = getFromPool(/obj/screen/inventory)
	using.name = "hand"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "hand1"
	using.screen_loc = ui_swaphand1
	using.layer = HUD_BASE_LAYER
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = getFromPool(/obj/screen/inventory)
	using.name = "hand"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "hand2"
	using.screen_loc = ui_swaphand2
	using.layer = HUD_BASE_LAYER
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "id"
	inv_box.dir = NORTH
	inv_box.icon = ui_style
	inv_box.icon_state = "id"
	inv_box.screen_loc = ui_id
	inv_box.slot_id = slot_wear_id
	inv_box.layer = HUD_BASE_LAYER
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "mask"
	inv_box.dir = NORTH
	inv_box.icon = ui_style
	inv_box.icon_state = "equip"
	inv_box.screen_loc = ui_mask
	inv_box.slot_id = slot_wear_mask
	inv_box.layer = HUD_BASE_LAYER
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "back"
	inv_box.dir = NORTH
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.screen_loc = ui_back
	inv_box.slot_id = slot_back
	inv_box.layer = HUD_BASE_LAYER
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "storage1"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage1
	inv_box.slot_id = slot_l_store
	inv_box.layer = HUD_BASE_LAYER
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "storage2"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage2
	inv_box.slot_id = slot_r_store
	inv_box.layer = HUD_BASE_LAYER
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "suit storage"
	inv_box.icon = ui_style
	inv_box.dir = 8 //The sprite at dir=8 has the background whereas the others don't.
	inv_box.icon_state = "belt"
	inv_box.screen_loc = ui_sstore1
	inv_box.slot_id = slot_s_store
	inv_box.layer = HUD_BASE_LAYER
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	using = getFromPool(/obj/screen)
	using.name = "resist"
	using.icon = ui_style
	using.icon_state = "act_resist"
	using.screen_loc = ui_pull_resist
	using.layer = HUD_BASE_LAYER
	using.color = ui_color
	using.alpha = ui_alpha
	src.hotkeybuttons += using

	using = getFromPool(/obj/screen)
	using.name = "toggle"
	using.icon = ui_style
	using.icon_state = "other"
	using.screen_loc = ui_inventory
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = getFromPool(/obj/screen)
	using.name = "equip"
	using.icon = ui_style
	using.icon_state = "act_equip"
	using.screen_loc = ui_equip
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "gloves"
	inv_box.icon = ui_style
	inv_box.icon_state = "gloves"
	inv_box.screen_loc = ui_gloves
	inv_box.slot_id = slot_gloves
	inv_box.layer = HUD_BASE_LAYER
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "eyes"
	inv_box.icon = ui_style
	inv_box.icon_state = "glasses"
	inv_box.screen_loc = ui_glasses
	inv_box.slot_id = slot_glasses
	inv_box.layer = HUD_BASE_LAYER
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "ears"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
	inv_box.screen_loc = ui_ears
	inv_box.slot_id = slot_ears
	inv_box.layer = HUD_BASE_LAYER
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "hair"
	inv_box.screen_loc = ui_head
	inv_box.slot_id = slot_head
	inv_box.layer = HUD_BASE_LAYER
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "shoes"
	inv_box.icon = ui_style
	inv_box.icon_state = "shoes"
	inv_box.screen_loc = ui_shoes
	inv_box.slot_id = slot_shoes
	inv_box.layer = HUD_BASE_LAYER
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = getFromPool(/obj/screen/inventory)
	inv_box.name = "belt"
	inv_box.icon = ui_style
	inv_box.icon_state = "belt"
	inv_box.screen_loc = ui_belt
	inv_box.slot_id = slot_belt
	inv_box.layer = HUD_BASE_LAYER
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	mymob.throw_icon = getFromPool(/obj/screen)
	mymob.throw_icon.icon = ui_style
	mymob.throw_icon.icon_state = "act_throw_off"
	mymob.throw_icon.name = "throw"
	mymob.throw_icon.screen_loc = ui_drop_throw
	mymob.throw_icon.color = ui_color
	mymob.throw_icon.alpha = ui_alpha
	src.hotkeybuttons += mymob.throw_icon

	mymob.kick_icon = getFromPool(/obj/screen)
	mymob.kick_icon.name = "kick"
	mymob.kick_icon.icon = ui_style
	mymob.kick_icon.icon_state = "act_kick"
	mymob.kick_icon.screen_loc = ui_kick_bite
	mymob.kick_icon.color = ui_color
	mymob.kick_icon.alpha = ui_alpha
	src.hotkeybuttons += mymob.kick_icon

	mymob.bite_icon = getFromPool(/obj/screen)
	mymob.bite_icon.name = "bite"
	mymob.bite_icon.icon = ui_style
	mymob.bite_icon.icon_state = "act_bite"
	mymob.bite_icon.screen_loc = ui_kick_bite
	mymob.bite_icon.color = ui_color
	mymob.bite_icon.alpha = ui_alpha
	src.hotkeybuttons += mymob.bite_icon

	mymob.oxygen = getFromPool(/obj/screen)
	mymob.oxygen.icon = ui_style
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	mymob.pressure = getFromPool(/obj/screen)
	mymob.pressure.icon = ui_style
	mymob.pressure.icon_state = "pressure0"
	mymob.pressure.name = "pressure"
	mymob.pressure.screen_loc = ui_pressure

	mymob.toxin = getFromPool(/obj/screen)
	mymob.toxin.icon = ui_style
	mymob.toxin.icon_state = "tox0"
	mymob.toxin.name = "toxin"
	mymob.toxin.screen_loc = ui_toxin

	mymob.internals = getFromPool(/obj/screen)
	mymob.internals.icon = ui_style
	mymob.internals.icon_state = "internal0"
	mymob.internals.name = "internal"
	mymob.internals.screen_loc = ui_internal

	mymob.fire = getFromPool(/obj/screen)
	mymob.fire.icon = ui_style
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	mymob.bodytemp = getFromPool(/obj/screen)
	mymob.bodytemp.icon = ui_style
	mymob.bodytemp.icon_state = "temp1"
	mymob.bodytemp.name = "body temperature"
	mymob.bodytemp.screen_loc = ui_temp

	mymob.healths = getFromPool(/obj/screen)
	mymob.healths.icon = ui_style
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.nutrition_icon = getFromPool(/obj/screen)
	mymob.nutrition_icon.icon = ui_style
	mymob.nutrition_icon.icon_state = "nutrition0"
	mymob.nutrition_icon.name = "nutrition"
	mymob.nutrition_icon.screen_loc = ui_nutrition

	mymob.pullin = getFromPool(/obj/screen)
	mymob.pullin.icon = ui_style
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_pull_resist
	src.hotkeybuttons += mymob.pullin

	mymob.pain = getFromPool(/obj/screen)

	mymob.zone_sel = getFromPool(/obj/screen/zone_sel)
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.color = ui_color
	mymob.zone_sel.alpha = ui_alpha
	mymob.zone_sel.overlays.len = 0
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	//Handle the gun settings buttons
	mymob.gun_setting_icon = getFromPool(/obj/screen/gun/mode)
	if (mymob.client)
		if (mymob.client.gun_mode) // If in aim mode, correct the sprite
			mymob.gun_setting_icon.dir = 2
	for(var/obj/item/weapon/gun/G in mymob) // If targeting someone, display other buttons
		if (G.target)
			mymob.item_use_icon = getFromPool(/obj/screen/gun/item)
			if (mymob.client.target_can_click)
				mymob.item_use_icon.dir = 1
			src.adding += mymob.item_use_icon
			mymob.gun_move_icon = getFromPool(/obj/screen/gun/move)
			if (mymob.client.target_can_move)
				mymob.gun_move_icon.dir = 1
				mymob.gun_run_icon = getFromPool(/obj/screen/gun/run)
				if (mymob.client.target_can_run)
					mymob.gun_run_icon.dir = 1
				src.adding += mymob.gun_run_icon
			src.adding += mymob.gun_move_icon


	mymob.client.reset_screen()

	mymob.client.screen += list( mymob.throw_icon, mymob.kick_icon, mymob.bite_icon, mymob.zone_sel, mymob.oxygen, mymob.pressure, mymob.toxin, mymob.bodytemp, mymob.internals, mymob.fire, mymob.healths, mymob.nutrition_icon, mymob.pullin, mymob.gun_setting_icon) //, mymob.hands, mymob.rest, mymob.sleep) //, mymob.mach )
	mymob.client.screen += src.adding + src.hotkeybuttons
	inventory_shown = 0

	return


/mob/living/carbon/human/verb/toggle_hotkey_verbs()
	set category = "OOC"
	set name = "Toggle hotkey buttons"
	set desc = "This disables or enables the user interface buttons which can be used with hotkeys."

	if(hud_used.hotkey_ui_hidden)
		client.screen += hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = 0
	else
		client.screen -= hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = 1


/mob/living/carbon/human/update_action_buttons()
	var/num = 1
	if(!hud_used) return
	if(!client) return
	var/list/used = list()

	if(hud_used.hud_shown != 1)	//Hud toggled to minimal
		return

	for(var/obj/screen/item_action/actionitem in hud_used.item_action_list)
		if(actionitem.owner && actionitem.owner.loc == src)
			actionitem.overlay.appearance = actionitem.owner.appearance
			actionitem.overlay.dir = SOUTH
			switch(num)
				if(1)
					actionitem.screen_loc = ui_action_slot1
				if(2)
					actionitem.screen_loc = ui_action_slot2
				if(3)
					actionitem.screen_loc = ui_action_slot3
				if(4)
					actionitem.screen_loc = ui_action_slot4
				if(5)
					actionitem.screen_loc = ui_action_slot5
			used += actionitem.owner
			num++
		else
			client.screen -= actionitem
			client.images -= actionitem.overlay
			hud_used.item_action_list -= actionitem
			returnToPool(actionitem)

	for(var/obj/item/I in (src.contents-used))
		if(I.action_button_name && (num < 6))
			var/obj/screen/item_action/newactionitem = getFromPool(/obj/screen/item_action,null,I)
			newactionitem.icon = ui_style2icon(client.prefs.UI_style)
			hud_used.item_action_list += newactionitem
			client.screen += newactionitem
			client.images += newactionitem.overlay
			switch(num)
				if(1)
					newactionitem.screen_loc = ui_action_slot1
				if(2)
					newactionitem.screen_loc = ui_action_slot2
				if(3)
					newactionitem.screen_loc = ui_action_slot3
				if(4)
					newactionitem.screen_loc = ui_action_slot4
				if(5)
					newactionitem.screen_loc = ui_action_slot5
			num++
