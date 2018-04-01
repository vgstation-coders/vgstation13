
//Soul counter is stored with the humans, it does weird when you place it here apparently...


/datum/hud/devil/New(mob/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	..()
	var/obj/screen/using

	using = new /obj/screen/drop()
	using.icon = ui_style
	using.screen_loc = ui_drone_drop
	static_inventory += using

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_icon(mymob)
	pull_icon.screen_loc = ui_drone_pull
	static_inventory += pull_icon

	build_hand_slots(ui_style)

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_1_m"
	using.screen_loc = ui_swaphand_position(owner,1)
	using.layer = HUD_LAYER
	using.plane = HUD_PLANE
	static_inventory += using

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand_position(owner,2)
	using.layer = HUD_LAYER
	using.plane = HUD_PLANE
	static_inventory += using

	zone_select = new /obj/screen/zone_sel()
	zone_select.icon = ui_style
	zone_select.update_icon(mymob)

	lingchemdisplay = new /obj/screen/ling/chems()
	devilsouldisplay = new /obj/screen/devil/soul_counter
	infodisplay += devilsouldisplay


/datum/hud/devil/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/true_devil/D = mymob

	if(hud_version != HUD_STYLE_NOHUD)
		for(var/obj/item/I in D.held_items)
			I.screen_loc = ui_hand_position(D.get_held_index_of_item(I))
			D.client.screen += I
	else
		for(var/obj/item/I in D.held_items)
			I.screen_loc = null
			D.client.screen -= I

/mob/living/carbon/true_devil/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/devil(src, ui_style2icon(client.prefs.UI_style))
