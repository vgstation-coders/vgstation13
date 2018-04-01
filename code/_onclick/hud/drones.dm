/datum/hud/dextrous/drone/New(mob/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	..()
	var/obj/screen/inventory/inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "internal storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "suit_storage"
//	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_drone_storage
	inv_box.slot_id = slot_generic_dextrous_storage
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "head/mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
//	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_drone_head
	inv_box.slot_id = slot_head
	static_inventory += inv_box

	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()


/datum/hud/dextrous/drone/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/simple_animal/drone/D = mymob

	if(hud_shown)
		if(D.internal_storage)
			D.internal_storage.screen_loc = ui_drone_storage
			D.client.screen += D.internal_storage
		if(D.head)
			D.head.screen_loc = ui_drone_head
			D.client.screen += D.head
	else
		if(D.internal_storage)
			D.internal_storage.screen_loc = null
		if(D.head)
			D.head.screen_loc = null

	..()
