// Process the MoMMI's visual HuD
/datum/hud/proc/mommi_hud()
	// Typecast the mymob to a MoMMI type
	var/mob/living/silicon/robot/mommi/M=mymob
	src.adding = list()
	src.other = list()

	var/obj/abstract/screen/using
	var/obj/abstract/screen/inventory/inv_box

	// Radio
	using = getFromPool(/obj/abstract/screen)	// Set using to a new object
	using.name = "radio"		// Name it
	using.dir = SOUTHWEST		// Set its direction
	using.icon = 'icons/mob/screen1_robot.dmi'	// Pick the base icon
	using.icon_state = "radio"	// Pick the icon state
	using.screen_loc = ui_movi	// Set the location
	src.adding += using			// Place using in our adding list

	// Module select
	using = getFromPool(/obj/abstract/screen)	// Set using to a new object
	using.name = INV_SLOT_TOOL
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv1"
	using.screen_loc = ui_inv2
	src.adding += using			// Place using in our adding list
	M.inv_tool = using			// Save this using as our MoMMI's inv_sight

	using = getFromPool(/obj/abstract/screen)
	using.name = INV_SLOT_SIGHT
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "sight"
	using.screen_loc = ui_mommi_sight
	src.adding += using
	M.sensor = using
	// End of module select

	// Head
	inv_box = getFromPool(/obj/abstract/screen/inventory)
	inv_box.name = "head"
	inv_box.dir = NORTH
	inv_box.icon_state = "hair"
	inv_box.screen_loc = ui_mommi_hats
	inv_box.slot_id = slot_head
	inv_box.layer = HUD_BASE_LAYER
	src.adding += inv_box


	// Intent
	using = getFromPool(/obj/abstract/screen)
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = (mymob.a_intent == I_HURT ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	src.adding += using
	action_intent = using

	// Cell
	M.cells = getFromPool(/obj/abstract/screen)
	M.cells.icon = 'icons/mob/screen1_robot.dmi'
	M.cells.icon_state = "charge-empty"
	M.cells.name = "cell"
	M.cells.screen_loc = ui_toxin

	// Health
	mymob.healths = getFromPool(/obj/abstract/screen)
	mymob.healths.icon = 'icons/mob/screen1_robot.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_borg_health

	// Installed Module
	mymob.hands = getFromPool(/obj/abstract/screen)
	mymob.hands.icon = 'icons/mob/screen1_robot.dmi'
	mymob.hands.icon_state = "nomod"
	mymob.hands.name = "module"
	mymob.hands.screen_loc = ui_mommi_module

	// Module Panel
	using = getFromPool(/obj/abstract/screen)
	using.name = "panel"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "panel"
	using.screen_loc = ui_borg_panel
	using.layer = HUD_BASE_LAYER
	src.adding += using

	//Robot Module Hud
	using = getFromPool(/obj/abstract/screen)
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1.dmi'
	using.icon_state = "block"
	using.layer = HUD_BASE_LAYER
	src.adding += using
	M.robot_modules_background = using

	// Store
	mymob.throw_icon = getFromPool(/obj/abstract/screen)
	mymob.throw_icon.icon = 'icons/mob/screen1_robot.dmi'
	mymob.throw_icon.icon_state = "store"
	mymob.throw_icon.name = "store"
	mymob.throw_icon.screen_loc = ui_mommi_store

	//Temp
	mymob.bodytemp = getFromPool(/obj/abstract/screen)
	mymob.bodytemp.icon = 'icons/mob/screen1_robot.dmi'
	mymob.bodytemp.icon_state = "temp0"
	mymob.bodytemp.name = "environment temperature"
	mymob.bodytemp.screen_loc = ui_borg_temp
	
	//Pressure
	mymob.pressure = getFromPool(/obj/abstract/screen)
	mymob.pressure.icon = 'icons/mob/screen1_robot.dmi'
	mymob.pressure.icon_state = "pressure0"
	mymob.pressure.name = "environment pressure"
	mymob.pressure.screen_loc = ui_borg_pressure

	// Oxygen
	mymob.oxygen = getFromPool(/obj/abstract/screen)
	mymob.oxygen.icon = 'icons/mob/screen1_robot.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	// Fire
	mymob.fire = getFromPool(/obj/abstract/screen)
	mymob.fire.icon = 'icons/mob/screen1_robot.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	// Pulling
	mymob.pullin = getFromPool(/obj/abstract/screen)
	mymob.pullin.icon = 'icons/mob/screen1_robot.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_borg_pull

	// Zone
	mymob.zone_sel = getFromPool(/obj/abstract/screen/zone_sel)
	mymob.zone_sel.icon = 'icons/mob/screen1_robot.dmi'
	mymob.zone_sel.overlays.len = 0
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	// Reset the client's screen
	mymob.client.reset_screen()
	// Add everything to their screen
	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.pressure, mymob.bodytemp, mymob.fire, mymob.hands, mymob.healths, mymob:cells, mymob.pullin) //, mymob.rest, mymob.sleep, mymob.mach, mymob.oxygen )
	mymob.client.screen += src.adding + src.other
