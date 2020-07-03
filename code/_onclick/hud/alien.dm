/datum/hud/proc/alien_hud()

	src.adding = list()
	src.other = list()

	var/obj/abstract/screen/using
	var/obj/abstract/screen/inventory/inv_box

	using = new /obj/abstract/screen
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = (mymob.a_intent == I_HURT ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	src.adding += using
	action_intent = using

//intent small hud objects
	var/icon/ico

	ico = new('icons/mob/screen1_alien.dmi', "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),1,ico.Height()/2,ico.Width()/2,ico.Height())
	using = new /obj/abstract/screen(src)
	using.name = "help"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = HUD_ABOVE_ITEM_LAYER
	src.adding += using
	help_intent = using

	ico = new('icons/mob/screen1_alien.dmi', "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),ico.Width()/2,ico.Height()/2,ico.Width(),ico.Height())
	using = new /obj/abstract/screen(src)
	using.name = "disarm"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = HUD_ABOVE_ITEM_LAYER
	src.adding += using
	disarm_intent = using

	ico = new('icons/mob/screen1_alien.dmi', "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),ico.Width()/2,1,ico.Width(),ico.Height()/2)
	using = new /obj/abstract/screen(src)
	using.name = "grab"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = HUD_ABOVE_ITEM_LAYER
	src.adding += using
	grab_intent = using

	ico = new('icons/mob/screen1_alien.dmi', "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),1,1,ico.Width()/2,ico.Height()/2)
	using = new /obj/abstract/screen(src)
	using.name = "harm"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = HUD_ABOVE_ITEM_LAYER
	src.adding += using
	hurt_intent = using

//end intent small hud objects

	using = new /obj/abstract/screen
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	src.adding += using
	move_intent = using

	using = new /obj/abstract/screen
	using.name = "drop"
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	using.layer = HUD_BASE_LAYER
	src.adding += using

//equippable shit
	init_hand_icons('icons/mob/screen1_alien.dmi')

	using = new /obj/abstract/screen/inventory
	using.name = "hand"
	using.dir = SOUTH
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "hand1"
	using.screen_loc = ui_swaphand1
	using.layer = HUD_BASE_LAYER
	src.adding += using

	using = new /obj/abstract/screen/inventory
	using.name = "hand"
	using.dir = SOUTH
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "hand2"
	using.screen_loc = ui_swaphand2
	using.layer = HUD_BASE_LAYER
	src.adding += using

	//pocket 1
	inv_box = new /obj/abstract/screen/inventory
	inv_box.name = "storage1"
	inv_box.icon = 'icons/mob/screen1_alien.dmi'
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage1
	inv_box.slot_id = slot_l_store
	inv_box.layer = HUD_BASE_LAYER
	src.adding += inv_box

	//pocket 2
	inv_box = new /obj/abstract/screen/inventory
	inv_box.name = "storage2"
	inv_box.icon = 'icons/mob/screen1_alien.dmi'
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage2
	inv_box.slot_id = slot_r_store
	inv_box.layer = HUD_BASE_LAYER
	src.adding += inv_box

	mymob.throw_icon = new /obj/abstract/screen
	mymob.throw_icon.icon = 'icons/mob/screen1_alien.dmi'
	mymob.throw_icon.icon_state = "act_throw_off"
	mymob.throw_icon.name = "throw"
	mymob.throw_icon.screen_loc = ui_drop_throw

	mymob.healths = new /obj/abstract/screen
	mymob.healths.icon = 'icons/mob/screen1_alien.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_alien_health

	mymob.pullin = new /obj/abstract/screen
	mymob.pullin.icon = 'icons/mob/screen1_alien.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_pull_resist

	mymob.zone_sel = new /obj/abstract/screen/zone_sel
	mymob.zone_sel.icon = 'icons/mob/screen1_alien.dmi'
	mymob.zone_sel.overlays.len = 0
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	plasma_hud()

	mymob.client.reset_screen()

	mymob.client.screen += list(mymob.throw_icon, mymob.zone_sel, mymob.healths, mymob.pullin, vampire_blood_display)
	mymob.client.screen += src.adding + src.other

/datum/hud/proc/plasma_hud()
	// Displaying plasma levels
	vampire_blood_display = new /obj/abstract/screen
	vampire_blood_display.name = "Alien Plasma"
	vampire_blood_display.icon_state = "dark128"
	vampire_blood_display.screen_loc = ui_under_health
