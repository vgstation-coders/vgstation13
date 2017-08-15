/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/
var/global/obj/abstract/screen/clicker/catcher = new()

/datum/hud
	var/mob/mymob

	var/obj/abstract/screen/grab_intent
	var/obj/abstract/screen/hurt_intent
	var/obj/abstract/screen/disarm_intent
	var/obj/abstract/screen/help_intent

	var/hud_shown = 1			//Used for the HUD toggle (F12)
	var/inventory_shown = 1		//the inventory
	var/show_intent_icons = 0
	var/hotkey_ui_hidden = 0	//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/obj/abstract/screen/lingchemdisplay
	var/obj/abstract/screen/vampire_blood_display // /vg/
	var/list/obj/abstract/screen/hand_hud_objects = list()
	var/obj/abstract/screen/action_intent
	var/obj/abstract/screen/move_intent

	var/obj/abstract/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = 0

	var/list/adding
	var/list/other
	var/obj/abstract/screen/holomap/holomap_obj
	var/list/obj/abstract/screen/hotkeybuttons

/datum/hud/New(mob/owner)
	mymob = owner
	instantiate()
	hide_actions_toggle = new
	hide_actions_toggle.InitialiseIcon(mymob)
	..()

/datum/hud/Destroy()
	..()
	grab_intent = null
	hurt_intent = null
	disarm_intent = null
	help_intent = null
	lingchemdisplay = null
	vampire_blood_display = null
	hand_hud_objects = null
	action_intent = null
	move_intent = null
	adding = null
	other = null
	hide_actions_toggle = null
	hotkeybuttons = null
	mymob = null


/datum/hud/proc/hidden_inventory_update()
	if(!mymob)
		return

	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		if(inventory_shown && hud_shown)
			if(H.shoes)
				H.shoes.screen_loc = ui_shoes
			if(H.gloves)
				H.gloves.screen_loc = ui_gloves
			if(H.ears)
				H.ears.screen_loc = ui_ears
			if(H.glasses)
				H.glasses.screen_loc = ui_glasses
			if(H.w_uniform)
				H.w_uniform.screen_loc = ui_iclothing
			if(H.wear_suit)
				H.wear_suit.screen_loc = ui_oclothing
			if(H.wear_mask)
				H.wear_mask.screen_loc = ui_mask
			if(H.head)
				H.head.screen_loc = ui_head
		else
			if(H.shoes)
				H.shoes.screen_loc = null
			if(H.gloves)
				H.gloves.screen_loc = null
			if(H.ears)
				H.ears.screen_loc = null
			if(H.glasses)
				H.glasses.screen_loc = null
			if(H.w_uniform)
				H.w_uniform.screen_loc = null
			if(H.wear_suit)
				H.wear_suit.screen_loc = null
			if(H.wear_mask)
				H.wear_mask.screen_loc = null
			if(H.head)
				H.head.screen_loc = null


/datum/hud/proc/persistant_inventory_update()
	if(!mymob)
		return

	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		if(hud_shown)
			if(H.s_store)
				H.s_store.screen_loc = ui_sstore1
			if(H.wear_id)
				H.wear_id.screen_loc = ui_id
			if(H.belt)
				H.belt.screen_loc = ui_belt
			if(H.back)
				H.back.screen_loc = ui_back
			if(H.l_store)
				H.l_store.screen_loc = ui_storage1
			if(H.r_store)
				H.r_store.screen_loc = ui_storage2
		else
			if(H.s_store)
				H.s_store.screen_loc = null
			if(H.wear_id)
				H.wear_id.screen_loc = null
			if(H.belt)
				H.belt.screen_loc = null
			if(H.back)
				H.back.screen_loc = null
			if(H.l_store)
				H.l_store.screen_loc = null
			if(H.r_store)
				H.r_store.screen_loc = null

/datum/hud/proc/init_hand_icons(var/new_icon, var/new_color, var/new_alpha)
	for(var/i = 1 to mymob.held_items.len) //Hands
		var/obj/abstract/screen/inventory/inv_box = getFromPool(/obj/abstract/screen/inventory)
		inv_box.name = "[mymob.get_index_limb_name(i)]"

		if(mymob.get_direction_by_index(i) == "right_hand")
			inv_box.dir = WEST
		else
			inv_box.dir = EAST

		inv_box.icon = new_icon ? new_icon : 'icons/mob/screen1_White.dmi'
		inv_box.icon_state = "hand_inactive"
		if(mymob && mymob.active_hand == i)
			inv_box.icon_state = "hand_active"
		inv_box.screen_loc = mymob.get_held_item_ui_location(i)
		inv_box.slot_id = null
		inv_box.hand_index = i
		inv_box.layer = HUD_BASE_LAYER
		inv_box.color = new_color ? new_color : inv_box.color
		inv_box.alpha = new_alpha ? new_alpha : inv_box.alpha
		src.hand_hud_objects += inv_box
		src.adding += inv_box

/datum/hud/proc/update_hand_icons()
	var/obj/abstract/screen/inventory/example = locate(/obj/abstract/screen/inventory) in hand_hud_objects

	var/new_icon = 'icons/mob/screen1_White.dmi'
	var/new_color = null
	var/new_alpha = 255

	if(example)
		new_icon = example.icon
		new_color = example.color
		new_alpha = example.alpha

	for(var/obj/abstract/screen/inventory/IN in hand_hud_objects)
		if(mymob.client)
			adding -= IN
			mymob.client.screen -= IN

		returnToPool(IN)

	if(mymob.client)
		adding = list()
		init_hand_icons(new_icon, new_color, new_alpha)
		mymob.client.screen += adding

/datum/hud/proc/instantiate()
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0


	var/ui_style
	var/ui_color
	var/ui_alpha
	if(!mymob.client.prefs)
		ui_style = ui_style2icon("Midnight")
		ui_color = null
		ui_alpha = 255
	else
		ui_style = ui_style2icon(mymob.client.prefs.UI_style)
		ui_color = mymob.client.prefs.UI_style_color
		ui_alpha = mymob.client.prefs.UI_style_alpha

	if(ishuman(mymob))
		human_hud(ui_style, ui_color, ui_alpha) // Pass the player the UI style chosen in preferences
	else if(ismonkey(mymob))
		monkey_hud(ui_style)
	else if(iscorgi(mymob))
		corgi_hud()
	else if(isbrain(mymob))
		brain_hud(ui_style)
	else if(islarva(mymob))
		larva_hud()
	else if(isalien(mymob))
		alien_hud()
	else if(isAI(mymob))
		ai_hud()
	else if(isMoMMI(mymob))
		mommi_hud()
	else if(isrobot(mymob))
		robot_hud()
	else if(isobserver(mymob))
		ghost_hud()
	else if(isshade(mymob))
		shade_hud()
	else if(isslime(mymob))
		slime_hud()
	else if(isborer(mymob))
		borer_hud()
	else if(isconstruct(mymob))
		construct_hud()
	else if(ispAI(mymob))
		pai_hud()
	else if(ismartian(mymob))
		martian_hud()

	if(isliving(mymob))
		var/obj/abstract/screen/using
		using = getFromPool(/obj/abstract/screen)
		using.dir = SOUTHWEST
		using.icon = 'icons/mob/screen1.dmi'
		using.icon_state = "block"
		src.adding += using
		mymob:schematics_background = using

	holomap_obj = getFromPool(/obj/abstract/screen/holomap)
	holomap_obj.name = "holomap"
	holomap_obj.icon = null
	holomap_obj.icon_state = ""
	holomap_obj.screen_loc = "SOUTH,WEST"
	holomap_obj.mouse_opacity = 0
	holomap_obj.alpha = 255

	mymob.client.screen += src.holomap_obj

	reload_fullscreen()
	mymob.update_action_buttons(1)
	update_parallax_existence()

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = 1

	if(hud_used && client)
		if(ishuman(src))
			if(!src.client)
				return

			if(hud_used.hud_shown)
				hud_used.hud_shown = 0
				if(src.hud_used.adding)
					src.client.screen -= src.hud_used.adding
				if(src.hud_used.other)
					src.client.screen -= src.hud_used.other
				if(src.hud_used.hotkeybuttons)
					src.client.screen -= src.hud_used.hotkeybuttons

				//Due to some poor coding some things need special treatment:
				//These ones are a part of 'adding', 'other' or 'hotkeybuttons' but we want them to stay
				src.client.screen += src.hud_used.hand_hud_objects
				src.client.screen += src.hud_used.action_intent		//we want the intent swticher visible
				src.hud_used.action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.

				//These ones are not a part of 'adding', 'other' or 'hotkeybuttons' but we want them gone.
				src.client.screen -= src.zone_sel	//zone_sel is a mob variable for some reason.

			else
				hud_used.hud_shown = 1
				if(src.hud_used.adding)
					src.client.screen += src.hud_used.adding
				if(src.hud_used.other && src.hud_used.inventory_shown)
					src.client.screen += src.hud_used.other
				if(src.hud_used.hotkeybuttons && !src.hud_used.hotkey_ui_hidden)
					src.client.screen += src.hud_used.hotkeybuttons


				src.hud_used.action_intent.screen_loc = ui_acti //Restore intent selection to the original position
				src.client.screen += src.zone_sel				//This one is a special snowflake

			hud_used.hidden_inventory_update()
			hud_used.persistant_inventory_update()
			update_action_buttons(1)
		else
			to_chat(usr, "<span class='warning'>Inventory hiding is currently only supported for human mobs, sorry.</span>")
	else
		to_chat(usr, "<span class='warning'>This mob type does not use a HUD.</span>")

/datum/hud/proc/toggle_show_schematics_display(var/list/override = null,clear = 0, var/obj/item/device/rcd/R)
	if(!isliving(mymob))
		return

	var/mob/living/L = mymob

	L.shown_schematics_background = (!clear ? !L.shown_schematics_background : 0)
	update_schematics_display(override, clear, R)

/datum/hud/proc/update_schematics_display(var/list/override = null, clear,var/obj/item/device/rcd/R)
	if(!isliving(mymob))
		return

	var/mob/living/L = mymob

	if(L.shown_schematics_background && !clear)

		if(!istype(R))
			R = L.get_active_hand()
			if(!istype(R))
				return

		if((!R.schematics || !R.schematics.len) && !override)
			to_chat(usr, "<span class='danger'>This [R] has no schematics to choose from.</span>")
			return

		if(!L.schematics_background)
			return
		if(!override)
			override = R.schematics
		if(!R.closer)
			R.closer = getFromPool(/obj/abstract/screen/close)
			R.closer.icon_state = "x"
			R.closer.master = R
			R.closer.transform *= 0.8
		var/display_rows = round((override.len) / 8) +1 //+1 because round() returns floor of number
		L.schematics_background.screen_loc = "CENTER-4:[WORLD_ICON_SIZE/2],SOUTH+1:[7*PIXEL_MULTIPLIER] to CENTER+3:[WORLD_ICON_SIZE/2],SOUTH+[display_rows]:[7*PIXEL_MULTIPLIER]"
		L.client.screen += L.schematics_background

		var/x = -4	//Start at CENTER-4,SOUTH+1
		var/y = 1

		for(var/datum/schematic in override)
			var/datum/rcd_schematic/RS = schematic
			if(!istype(RS))
				if(!istype(RS, /datum/selection_schematic))
					to_chat(usr, "<span class='danger'>Unexpected type in schematics list. [RS][RS ? "/[RS.type]" : "null"]")
					continue
			if(!RS.ourobj)
				RS.ourobj = getFromPool(/obj/abstract/screen/schematics, null, RS)
			var/obj/abstract/screen/A = RS.ourobj
			//Module is not currently active
			L.client.screen += A
			if(x < 0)
				A.screen_loc = "CENTER[x]:[WORLD_ICON_SIZE/2],SOUTH+[y]:[7*PIXEL_MULTIPLIER]"
			else
				A.screen_loc = "CENTER+[x]:[WORLD_ICON_SIZE/2],SOUTH+[y]:[7*PIXEL_MULTIPLIER]"
			A.layer = HUD_ITEM_LAYER

			x++
			if(x == 4)
				x = -4
				y++
		R.closer.screen_loc = "CENTER[x < 0 ? "" : "+"][x]:[WORLD_ICON_SIZE/2],SOUTH+[y]:[7*PIXEL_MULTIPLIER]"
		L.client.screen += R.closer

	else
		for(var/obj/abstract/screen/schematics/A in L.client.screen)
			L.client.screen -= A
		L.client.screen -= L.schematics_background
		L.client.screen -= R.closer
		if(clear && override && override.len)
			L.shown_schematics_background = 1
			.(override, 0, R)
