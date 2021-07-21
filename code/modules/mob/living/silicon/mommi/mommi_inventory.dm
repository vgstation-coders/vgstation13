//These procs handle putting stuff in your hand. It's probably best to use these rather than setting stuff manually
//as they handle all relevant stuff like adding it to the player's screen and such

/mob/living/silicon/robot/mommi/is_holding_item(item)
	return get_active_hand() == item

/mob/living/silicon/robot/mommi/get_all_slots()
	return list(tool_state, head_state)

/mob/living/silicon/robot/mommi/put_in_hands(var/obj/item/W)
	// Fixing NPEs caused by PDAs giving me NULLs to hold :V - N3X
	// And before you ask, this is how /mob handles NULLs, too.
	if(!W)
		return FALSE
	if(cell && cell.charge <= ROBOT_LOW_POWER)
		drop_item(W)
		return FALSE
	if(istype(W, /obj/item/device/material_synth) && !is_in_modules(W)) //Crab no
		drop_item(W)
		return FALSE

	if(tool_state)
		var/obj/item/TS = tool_state
		if(!is_in_modules(tool_state))
			drop_item(TS)
		else
			TS.forceMove(module)
		contents -= tool_state
		if(client)
			client.screen -= tool_state
	tool_state = W
	W.hud_layerise()
	W.forceMove(src)
	W.equipped(src)

	// Make crap we pick up active so there's less clicking and carpal. - N3X
	module_active = tool_state
	inv_tool.icon_state = "inv1 +a"
	//inv_sight.icon_state = "sight"

	update_items()
	return TRUE

/mob/living/silicon/robot/mommi/u_equip(W as obj)
	if(W == tool_state)
		if(module_active == tool_state)
			module_active = null
		tool_state = null
		if(inv_tool)
			inv_tool.icon_state="inv1"
	else if(W == head_state)
		// Delete the hat's reference
		head_state = null
		// Update the MoMMI's head inventory icons
		update_inv_head()
	lazy_invoke_event(/lazy_event/on_unequipped, list(W))

// Override the default /mob version since we only have one hand slot.
/mob/living/silicon/robot/mommi/put_in_active_hand(var/obj/item/W)
	// If we have anything active, deactivate it.
	if(!W)
		return 0
	if(get_active_hand())
		uneq_active()
	return put_in_hands(W)

/mob/living/silicon/robot/mommi/get_multitool(var/active_only = FALSE)
	if(istype(get_active_hand(), /obj/item/device/multitool))
		return get_active_hand()
	if(active_only && istype(tool_state,/obj/item/device/multitool))
		return tool_state
	return null

/mob/living/silicon/robot/mommi/drop_item(var/obj/item/to_drop, var/atom/target, force_drop = FALSE, dontsay = null)
	if(!target)
		target = loc
	if(!istype(to_drop))
		to_drop = tool_state
	if(to_drop)
		if(is_in_modules(to_drop))
			to_chat(src, "<span class='warning'>This item cannot be dropped.</span>")
			return FALSE

		remove_from_mob(to_drop) //clean out any refs
		to_drop.dropped(src)
		to_drop.forceMove(target)
		update_items()
		return TRUE
	return FALSE


/*-------TODOOOOOOOOOO--------*/
// Called by store button
/mob/living/silicon/robot/mommi/uneq_active()
	var/obj/item/TS
	if(isnull(module_active))
		return
	if(stat != CONSCIOUS || !isturf(loc))
		return

	if((module_active in src.contents) && !(module_active in src.module.modules) && (module_active != src.module.emag) && candrop)
		TS = tool_state
		drop_item(TS)
	if(tool_state == module_active)
		//var/obj/item/found = locate(tool_state) in src.module.modules
		TS = tool_state
		if(!is_in_modules(TS))
			drop_item()
		if (client)
			client.screen -= tool_state
		contents -= tool_state
		module_active = null
		tool_state = null
		inv_tool.icon_state = "inv1"
	if(is_in_modules(TS))
		TS.forceMove(src.module)
	hud_used.update_robot_modules_display()

/mob/living/silicon/robot/mommi/uneq_all()
	module_active = null

	unequip_sight()
	unequip_tool()
	unequip_head()

// Unequips an object from the MoMMI's head
/mob/living/silicon/robot/mommi/proc/unequip_head()
	if(head_state) // If there is a hat on the MoMMI's head
		drop_item(head_state)

/mob/living/silicon/robot/mommi/proc/unequip_tool()
	if(tool_state)
		var/obj/item/TS=tool_state
		if(!is_in_modules(TS))
			drop_item()
		if(client)
			client.screen -= tool_state
		contents -= tool_state
		tool_state = null
		if(inv_tool)
			inv_tool.icon_state = "inv1"
		if(is_in_modules(TS))
			TS.forceMove(src.module)
		hud_used.update_robot_modules_display()

/mob/living/silicon/robot/mommi/activated(obj/item/O)
	if(tool_state == O)
		return TRUE
	return FALSE

//JUST FUCK MY WHOLE PARENT INVENTORY CODE BRO

/mob/living/silicon/robot/mommi/module_selected(var/module)
	return

/mob/living/silicon/robot/mommi/module_active(var/module)
	return

/mob/living/silicon/robot/mommi/get_selected_module()
	return FALSE

/mob/living/silicon/robot/mommi/select_module(var/module)
	return

/mob/living/silicon/robot/mommi/deselect_module(var/module)
	return

/mob/living/silicon/robot/mommi/toggle_module(var/module)
	return

/mob/living/silicon/robot/mommi/cycle_modules()
	return

/mob/living/silicon/robot/mommi/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_head)
			return head_state
	return

// Equip an item to the MoMMI. Currently the only thing you can equip is hats
// Returns a FALSE or TRUE based on whether or not the equipping worked
/mob/living/silicon/robot/mommi/equip_to_slot(obj/item/W as obj, slot, redraw_mob = TRUE)
	// If the parameters were given incorrectly, return an error
	if(!slot)
		return FALSE
	if(!istype(W))
		return FALSE

	// If this item does not equip to this slot type, return
	if(!(W.slot_flags & SLOT_HEAD))
		return FALSE

	// If the item is in the MoMMI's claw, handle removing the item from the MoMMI's claw
	if(W == tool_state)
		// Don't allow the MoMMI to equip tools to their head. I mean, they cant anyways, but stop them here
		if(is_in_modules(tool_state))
			to_chat(src, "<span class='warning'>You cannot equip a module to your head.</span>")
			return FALSE
		// Remove the item in the MoMMI's claw
		drop_item(W,src)

	// For each equipment slot that the MoMMI can equip to
	switch(slot)
		// If equipping to the head
		if(slot_head)
			// Grab whatever the MoMMI might already be wearing and cast it
			var/obj/item/wearing = head_state
			// If the MoMMI is already wearing a hat, put the active hat back in their claw
			if(wearing)
				// Put it in their hand
				put_in_active_hand(wearing)
				tool_state = wearing

			// Put the item on the MoMMI's head
			head_state = W
			W.equipped(src, slot)
			// Add the item to the MoMMI's hud
			if(client)
				client.screen += head_state
		else
			to_chat(src, "<span class='warning'>You are trying to equip this item to an unsupported inventory slot. How the heck did you manage that? Stop it...</span>")
			return FALSE
	// Set the item layer and update the MoMMI's icons
	W.hud_layerise()
	update_inv_head()
	return TRUE

/mob/living/silicon/robot/mommi/attack_ui(slot)
	var/obj/item/W = tool_state
	if(istype(W))
		if(equip_to_slot_if_possible(W, slot))
			update_items()

// Quickly equip a hat by pressing "e"
/mob/living/silicon/robot/mommi/verb/quick_equip()
	set name = "quick-equip"
	set hidden = TRUE

	// Check to see if we are holding something
	var/obj/item/I = tool_state
	if(!I)
		to_chat(src, "<span class='notice'>You are not holding anything to equip.</span>")
		return
	// Attempt to equip it and, if it succedes, update our icon
	if(equip_to_slot(I, slot_head))
		update_items()
	else
		to_chat(src, "<span class='warning'>You are unable to equip that.</span>")

// MoMMIs only have one hand.
/mob/living/silicon/robot/mommi/update_items()
	..()
	if(tool_state)
		tool_state:screen_loc = ui_inv2
	if(head_state)
		head_state:screen_loc = ui_monkey_mask
	updateicon()
