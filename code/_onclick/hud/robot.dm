/datum/hud/proc/robot_hud()
	src.adding = list()
	src.other = list()

	var/obj/abstract/screen/using
	var/mob/living/silicon/robot/R = mymob

//Radio
	using = new /obj/abstract/screen
	using.name = "radio"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "radio"
	using.screen_loc = ui_movi
	src.adding += using

	using.pointer_to_list = &adding

//Module select

	using = new /obj/abstract/screen
	using.name = INV_SLOT_SIGHT
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "sight"
	using.screen_loc = ui_borg_sight
	src.adding += using
	R.sensor = using

	using.pointer_to_var = &R.sensor
	using.pointer_to_list = &adding


	using = new /obj/abstract/screen
	using.name = "module1"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv1"
	using.screen_loc = ui_inv1
	src.adding += using
	R.inv1 = using

	using.pointer_to_var = &R.inv1
	using.pointer_to_list = &adding

	using = new /obj/abstract/screen
	using.name = "module2"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv2"
	using.screen_loc = ui_inv2
	src.adding += using
	R.inv2 = using

	using.pointer_to_var = &R.inv2
	using.pointer_to_list = &adding

	using = new /obj/abstract/screen
	using.name = "module3"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv3"
	using.screen_loc = ui_inv3
	src.adding += using
	R.inv3 = using

	using.pointer_to_var = &R.inv3
	using.pointer_to_list = &adding

	using = new /obj/abstract/screen
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1.dmi'
	using.icon_state = "block"
	using.layer = HUD_BASE_LAYER
	src.adding += using
	R.robot_modules_background = using

	using.pointer_to_var = &R.robot_modules_background
	using.pointer_to_list = &adding

//End of module select

//Intent
	using = new /obj/abstract/screen
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = (mymob.a_intent == I_HURT ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	src.adding += using
	action_intent = using

	using.pointer_to_var = &action_intent
	using.pointer_to_list = &adding

	//Module Panel
	using = new /obj/abstract/screen
	using.name = "panel"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "panel"
	using.screen_loc = ui_borg_panel
	using.layer = HUD_BASE_LAYER
	src.adding += using

	using.pointer_to_list = &adding

//Health
	using = new /obj/abstract/screen
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "health0"
	using.name = "health"
	using.screen_loc = ui_borg_health

	mymob.healths = using
	using.pointer_to_var = &mymob.healths

//Installed Module
	using = new /obj/abstract/screen
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "nomod"
	using.name = "module"
	using.screen_loc = ui_borg_module

	mymob.hands = using
	mymob.hands.pointer_to_var = &mymob.hands

//Store
	using = new /obj/abstract/screen
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "store"
	using.name = "store"
	using.screen_loc = ui_borg_store

	mymob.throw_icon = using
	using.pointer_to_var = &mymob.throw_icon

//Photography stuff
	using = new /obj/abstract/screen
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "camera"
	using.name = "Take Image"
	using.screen_loc = ui_borg_camera
	mymob.camera_icon = using

	using.pointer_to_var = &mymob.camera_icon

	using = new /obj/abstract/screen
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "album"
	using.name = "View Images"
	using.screen_loc = ui_borg_album
	mymob.album_icon = using

	using.pointer_to_var  = &mymob.album_icon

	using = new /obj/abstract/screen
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "pull0"
	using.name = "pull"
	using.screen_loc = ui_borg_pull
	mymob.pullin = using

	using.pointer_to_var  = &mymob.pullin

	var/obj/abstract/screen/zone_sel/ZS = new /obj/abstract/screen/zone_sel
	ZS.icon = 'icons/mob/screen1_robot.dmi'
	ZS.overlays.len = 0
	ZS.overlays += image('icons/mob/zone_sel.dmi', "[ZS.selecting]")
	mymob.zone_sel = ZS

	//Handle the gun settings buttons
	mymob.gun_setting_icon = new /obj/abstract/screen/gun/mode
	mymob.healths.pointer_to_var = &mymob.gun_setting_icon

	if (mymob.client)
		if (mymob.client.gun_mode) // If in aim mode, correct the sprite
			mymob.gun_setting_icon.dir = 2
	for(var/obj/item/weapon/gun/G in mymob) // If targeting someone, display other buttons
		if (G.target)
			mymob.item_use_icon = new /obj/abstract/screen/gun/item
			if (mymob.client.target_can_click)
				mymob.item_use_icon.dir = 1
			src.adding += mymob.item_use_icon

			mymob.item_use_icon.pointer_to_list = &src.adding

			mymob.gun_move_icon = new /obj/abstract/screen/gun/move
			if (mymob.client.target_can_move)
				mymob.gun_move_icon.dir = 1
				mymob.gun_run_icon = new /obj/abstract/screen/gun/run
				if (mymob.client.target_can_run)
					mymob.gun_run_icon.dir = 1
				src.adding += mymob.gun_run_icon
				mymob.gun_run_icon.pointer_to_list = &src.adding

			src.adding += mymob.gun_move_icon
			mymob.gun_move_icon.pointer_to_list = &src.adding

	mymob.client.reset_screen()

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.hands, mymob.healths, mymob.pullin, mymob.gun_setting_icon, mymob.camera_icon, mymob.album_icon)
	mymob.client.screen += src.adding + src.other

	return

/datum/hud/proc/toggle_show_robot_modules()
	if(!isrobot(mymob))
		return

	var/mob/living/silicon/robot/r = mymob

	r.shown_robot_modules = !r.shown_robot_modules
	update_robot_modules_display()

/datum/hud/proc/update_robot_modules_display()
	if(!isrobot(mymob) || !mymob.client)
		return

	var/mob/living/silicon/robot/r = mymob

	if(r.shown_robot_modules)
		//Modules display is shown

		if(!r.module)
			to_chat(usr, "<span class='danger'>No module selected</span>")
			return

		if(!r.module.modules)
			to_chat(usr, "<span class='danger'>Selected module has no modules to select</span>")
			return

		if(!r.robot_modules_background)
			return

		var/display_rows = round((r.module.modules.len) / 8) +1 //+1 because round() returns floor of number
		r.robot_modules_background.screen_loc = "CENTER-4:[WORLD_ICON_SIZE/2],SOUTH+1:[7*PIXEL_MULTIPLIER] to CENTER+3:[WORLD_ICON_SIZE/2],SOUTH+[display_rows]:[7*PIXEL_MULTIPLIER]"
		r.client.screen += r.robot_modules_background

		var/x = -4	//Start at CENTER-4,SOUTH+1
		var/y = 1

		for(var/atom/movable/A in r.module.modules)
			if( (A != r.module_state_1) && (A != r.module_state_2) && (A != r.module_state_3) )
				//Module is not currently active
				r.client.screen += A
				if(x < 0)
					A.screen_loc = "CENTER[x]:[WORLD_ICON_SIZE/2],SOUTH+[y]:[7*PIXEL_MULTIPLIER]"
				else
					A.screen_loc = "CENTER+[x]:[WORLD_ICON_SIZE/2],SOUTH+[y]:[7*PIXEL_MULTIPLIER]"
				A.layer = HUD_ITEM_LAYER
				A.plane = HUD_PLANE

				x++
				if(x == 4)
					x = -4
					y++

	else
		//Modules display is hidden
		if(r.module)
			for(var/atom/A in r.module.modules)
				if( (A != r.module_state_1) && (A != r.module_state_2) && (A != r.module_state_3) )
					//Module is not currently active
					r.client.screen -= A
			r.shown_robot_modules = 0
			r.client.screen -= r.robot_modules_background
