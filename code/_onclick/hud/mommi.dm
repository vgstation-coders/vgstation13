// Process the MoMMI's visual HuD
/datum/hud/proc/mommi_hud()
	// Typecast the mymob to a MoMMI type
	var/mob/living/silicon/robot/mommi/M=mymob
	src.adding = list()
	src.other = list()

	var/obj/abstract/screen/using
	var/obj/abstract/screen/inventory/inv_box

	// Radio
	using = new /obj/abstract/screen
	using.name = "radio"		// Name it
	using.dir = SOUTHWEST		// Set its direction
	using.icon = 'icons/mob/screen1_robot.dmi'	// Pick the base icon
	using.icon_state = "radio"	// Pick the icon state
	using.screen_loc = ui_movi	// Set the location
	src.adding += using			// Place using in our adding list

	// Module select
	using = new /obj/abstract/screen
	using.name = INV_SLOT_TOOL
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv1"
	using.screen_loc = ui_inv2
	src.adding += using			// Place using in our adding list
	M.inv_tool = using			// Save this using as our MoMMI's inv_sight

	using = new /obj/abstract/screen
	using.name = INV_SLOT_SIGHT
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "sight"
	using.screen_loc = ui_mommi_sight
	src.adding += using
	M.sensor = using
	// End of module select

	// Head
	inv_box = new /obj/abstract/screen/inventory
	inv_box.name = "head"
	inv_box.dir = NORTH
	inv_box.icon_state = "hair"
	inv_box.screen_loc = ui_mommi_hats
	inv_box.slot_id = slot_head
	inv_box.layer = HUD_BASE_LAYER
	src.adding += inv_box

	// Intent
	using = new /obj/abstract/screen
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = (mymob.a_intent == I_HURT ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	src.adding += using
	action_intent = using

	// Health
	mymob.healths = new /obj/abstract/screen
	mymob.healths.icon = 'icons/mob/screen1_robot.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_borg_health

	// Installed Module
	mymob.hands = new /obj/abstract/screen
	mymob.hands.icon = 'icons/mob/screen1_robot.dmi'
	mymob.hands.icon_state = "nomod"
	mymob.hands.name = "module"
	mymob.hands.screen_loc = ui_mommi_module

	// Module Panel
	using = new /obj/abstract/screen
	using.name = "panel"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "panel"
	using.screen_loc = ui_borg_panel
	using.layer = HUD_BASE_LAYER
	src.adding += using

	//Robot Module Hud
	using = new /obj/abstract/screen
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1.dmi'
	using.icon_state = "block"
	using.layer = HUD_BASE_LAYER
	src.adding += using
	M.robot_modules_background = using

	// Store
	mymob.throw_icon = new /obj/abstract/screen
	mymob.throw_icon.icon = 'icons/mob/screen1_robot.dmi'
	mymob.throw_icon.icon_state = "store"
	mymob.throw_icon.name = "store"
	mymob.throw_icon.screen_loc = ui_mommi_store

	// Pulling
	mymob.pullin = new /obj/abstract/screen
	mymob.pullin.icon = 'icons/mob/screen1_robot.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_borg_pull

	// Zone
	mymob.zone_sel = new /obj/abstract/screen/zone_sel
	mymob.zone_sel.icon = 'icons/mob/screen1_robot.dmi'
	mymob.zone_sel.overlays.len = 0
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	// Reset the client's screen
	mymob.client.reset_screen()
	// Add everything to their screen
	mymob.client.screen += list(mymob.throw_icon, mymob.zone_sel, mymob.hands, mymob.healths, mymob.pullin)
	mymob.client.screen += src.adding + src.other
