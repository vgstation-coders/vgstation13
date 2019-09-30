//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting stuff manually
//as they handle all relevant stuff like adding it to the player's screen and such

//Returns the thing in our active hand (whatever is in our active module-slot, in this case)
/mob/living/silicon/robot/get_active_hand()
	return module_active

/mob/living/silicon/robot/get_inactive_hand()
	return

/mob/living/silicon/robot/is_holding_item(item)
	return get_all_slots().Find(item)

/mob/living/silicon/robot/get_all_slots()
	return list(module_state_1, module_state_2, module_state_3)

//overridden from parent since they technically have no 'hands'
/mob/living/silicon/robot/get_equipped_items()
	return get_all_slots()

//May need work
/mob/living/silicon/robot/is_in_modules(var/obj/item/W)
	return (W in module.modules)

/mob/living/silicon/robot/proc/uneq_module(const/obj/item/module)
	if(!istype(module))
		return FALSE
	module.mouse_opacity = 2
	if(client)
		client.screen -= module

	contents -= module
	if(module)
		module.forceMove(src.module)
		module.dropped(src)
		if(isgripper(module))
			var/obj/item/weapon/gripper/G = module
			G.drop_item(force_drop = TRUE)
	if(hud_used)
		hud_used.update_robot_modules_display()
	return TRUE

/mob/living/silicon/robot/proc/uneq_active()
	if(!module_active)
		return
	var/obj/item/MA = module_active
	if(MA.loc != src)
		to_chat(src, "<span class='warning'>Can't store something you're not holding!</span>")
		return

	if(isgripper(MA))
		var/obj/item/weapon/gripper/G = MA
		if(G.wrapped)
			G.drop_item(force_drop = TRUE)
			return

	if(module_state_1 == module_active)
		uneq_module(module_state_1)
		module_state_1 = null
		inv1.icon_state = "inv1"
	else if(module_state_2 == module_active)
		uneq_module(module_state_2)
		module_state_2 = null
		inv2.icon_state = "inv2"
	else if(module_state_3 == module_active)
		uneq_module(module_state_3)
		module_state_3 = null
		inv3.icon_state = "inv3"

	module_active = null
	updateicon()
	hud_used.update_robot_modules_display()

/mob/living/silicon/robot/proc/activate_module(var/obj/item/I)
	if(modulelock)
		to_chat(src, "<span class='alert' style=\"font-family:Courier\">Module lock active! Time remaining: [modulelock_time] seconds.</span>")
		return
	if(!(locate(I) in module.modules))
		return
	if(activated(I))
		to_chat(src, "<span class='notice'>Already activated</span>")
		return
	I.equipped(src)
	if(!module_state_1)
		I.mouse_opacity = initial(I.mouse_opacity)
		module_state_1 = I
		I.hud_layerise()
		I.screen_loc = inv1.screen_loc
		I.forceMove(src)
	else if(!module_state_2)
		I.mouse_opacity = initial(I.mouse_opacity)
		module_state_2 = I
		I.hud_layerise()
		I.screen_loc = inv2.screen_loc
		I.forceMove(src)
	else if(!module_state_3)
		I.mouse_opacity = initial(I.mouse_opacity)
		module_state_3 = I
		I.hud_layerise()
		I.screen_loc = inv3.screen_loc
		I.forceMove(src)
	else
		to_chat(src, "<span class='notice'>You need to disable a module first!</span>")

/mob/living/silicon/robot/proc/uneq_all()
	module_active = null
	var/modulesdisabled = 0

	if(module_state_1)
		uneq_module(module_state_1)
		module_state_1 = null
		if(inv1)
			inv1.icon_state = "inv1"
		modulesdisabled += 1

	if(module_state_2)
		uneq_module(module_state_2)
		module_state_2 = null
		if(inv2)
			inv2.icon_state = "inv2"
		modulesdisabled += 1

	if(module_state_3)
		uneq_module(module_state_3)
		module_state_3 = null
		if(inv3)
			inv3.icon_state = "inv3"
		modulesdisabled += 1

	unequip_sight()
	updateicon()
	return modulesdisabled

/mob/living/silicon/robot/proc/activated(obj/item/O)
	if(module_state_1 == O)
		return TRUE
	else if(module_state_2 == O)
		return TRUE
	else if(module_state_3 == O)
		return TRUE
	else
		return FALSE
	updateicon()

//Helper procs for cyborg modules on the UI.
//These are hackish but they help clean up code elsewhere.

//module_selected(module) - Checks whether the module slot specified by "module" is currently selected.
/mob/living/silicon/robot/proc/module_selected(var/module) //Module is 1-3
	return module == get_selected_module()

//module_active(module) - Checks whether there is a module active in the slot specified by "module".
/mob/living/silicon/robot/proc/module_active(var/module) //Module is 1-3
	if(module < 1 || module > 3)
		return FALSE
	switch(module)
		if(1)
			if(module_state_1)
				return TRUE
		if(2)
			if(module_state_2)
				return TRUE
		if(3)
			if(module_state_3)
				return TRUE
	return FALSE

//get_selected_module() - Returns the slot number of the currently selected module.  Returns 0 if no modules are selected.
/mob/living/silicon/robot/proc/get_selected_module()
	if(module_state_1 && module_active == module_state_1)
		return 1
	else if(module_state_2 && module_active == module_state_2)
		return 2
	else if(module_state_3 && module_active == module_state_3)
		return 3

	return 0

//select_module(module) - Selects the module slot specified by "module"
/mob/living/silicon/robot/proc/select_module(var/module) //Module is 1-3
	if(module < 1 || module > 3)
		return

	if(!module_active(module))
		return

	switch(module)
		if(1)
			if(module_active != module_state_1)
				inv1.icon_state = "inv1 +a"
				inv2.icon_state = "inv2"
				inv3.icon_state = "inv3"
				module_active = module_state_1
				return
		if(2)
			if(module_active != module_state_2)
				inv1.icon_state = "inv1"
				inv2.icon_state = "inv2 +a"
				inv3.icon_state = "inv3"
				module_active = module_state_2
				return
		if(3)
			if(module_active != module_state_3)
				inv1.icon_state = "inv1"
				inv2.icon_state = "inv2"
				inv3.icon_state = "inv3 +a"
				module_active = module_state_3
				return
	return

//deselect_module(module) - Deselects the module slot specified by "module"
/mob/living/silicon/robot/proc/deselect_module(var/module) //Module is 1-3
	if(module < 1 || module > 3)
		return
	switch(module)
		if(1)
			if(module_active == module_state_1)
				inv1.icon_state = "inv1"
				module_active = null
				return
		if(2)
			if(module_active == module_state_2)
				inv2.icon_state = "inv2"
				module_active = null
				return
		if(3)
			if(module_active == module_state_3)
				inv3.icon_state = "inv3"
				module_active = null
				return
	return

//toggle_module(module) - Toggles the selection of the module slot specified by "module".
/mob/living/silicon/robot/proc/toggle_module(var/module) //Module is 1-3
	if(module < 1 || module > 3)
		return

	if(module_selected(module))
		deselect_module(module)
	else
		if(module_active(module))
			select_module(module)
		else
			deselect_module(get_selected_module()) //If we can't do select anything, at least deselect the current module.
	return

//cycle_modules() - Cycles through the list of selected modules.
/mob/living/silicon/robot/proc/cycle_modules()
	var/slot_start = get_selected_module()
	if(slot_start)
		deselect_module(slot_start) //Only deselect if we have a selected slot.

	var/slot_num
	if(slot_start == 0)
		slot_num = 1
		slot_start = 2
	else
		slot_num = slot_start + 1

	while(slot_start != slot_num) //If we wrap around without finding any free slots, just give up.
		if(module_active(slot_num))
			select_module(slot_num)
			return
		slot_num++
		if(slot_num > 3)
			slot_num = 1 //Wrap around.

	return

/mob/living/silicon/robot/before_take_item(var/obj/item/W)
	..()
	if(W.loc == module)
		module.modules -= W //maybe fix the cable issues.

//Grippershit

/mob/living/silicon/robot/drop_item_v()//this is still dumb.
	if(!incapacitated() && isturf(loc))
		return drop_item(force_drop = TRUE)
	return FALSE

/mob/living/silicon/robot/drop_item(var/obj/item/to_drop, var/atom/target, force_drop = FALSE, dontsay = null)
	if(isgripper(module_active))
		var/obj/item/weapon/gripper/G = module_active
		return G.drop_item(to_drop, target, force_drop, dontsay)
	else
		return FALSE

/mob/living/silicon/robot/drop_from_inventory(var/obj/item/W) //needed for pills, thanks oldcoders.
	if(isgripper(W.loc))
		drop_item(force_drop = TRUE, dontsay = TRUE)
	else
		..()

#define ROBOT_LOW_POWER 100

/mob/living/silicon/robot/put_in_hands(var/obj/item/W)
	var/obj/item/weapon/gripper/G = null
	if(!W)
		return FALSE
	if(cell && cell.charge <= ROBOT_LOW_POWER)
		drop_from_inventory(W)
		return FALSE
	if(isgripper(module_state_1))
		G = module_state_1
		if(!G.wrapped && G.grip_item(W, src, 1))
			return TRUE
	if(isgripper(module_state_2))
		G = module_state_2
		if(!G.wrapped && G.grip_item(W, src, 1))
			return TRUE
	if(isgripper(module_state_3))
		G = module_state_3
		if(!G.wrapped && G.grip_item(W, src, 1))
			return TRUE
	W.forceMove(get_turf(src))
	return FALSE

/mob/living/silicon/robot/put_in_active_hand(var/obj/item/W)
	return put_in_hands(W)

/mob/living/silicon/robot/put_in_inactive_hand(var/obj/item/W)
	return FALSE

/mob/living/silicon/robot/get_inactive_hand(var/obj/item/W)
	return FALSE