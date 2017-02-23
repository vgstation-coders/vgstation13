#define AB_CHECK_RESTRAINED 1
#define AB_CHECK_STUNNED 2
#define AB_CHECK_LYING 4
#define AB_CHECK_CONSCIOUS 8


/datum/action
	var/name = "Generic Action"
	var/desc = null
	var/obj/target = null
	var/check_flags = 0
	var/processing = 0
	var/obj/screen/movable/action_button/button = null
	var/button_icon = 'icons/mob/actions.dmi'
	var/background_icon_state = "bg_default"
	var/buttontooltipstyle = "" 

	var/icon_icon = 'icons/mob/actions.dmi'
	var/button_icon_state = "default"
	var/mob/owner

/datum/action/New(Target)
	target = Target

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	target = null
	qdel(button)
	button = null
	return ..()

/datum/action/proc/Grant(mob/M)
	if(owner)
		if(owner == M)
			return
		Remove(owner)
	owner = M
	M.actions += src
	button = new
	button.linked_action = src
	button.name = name
	button.actiontooltipstyle = buttontooltipstyle
	if(desc)
		button.desc = desc
	if(M.client)
		M.client.screen += button
	M.update_action_buttons()

/datum/action/proc/Remove(mob/M)
	if(M.client)
		M.client.screen -= button
	button.moved = FALSE //so the button appears in its normal position when given to another owner.
	M.actions -= src
	M.update_action_buttons()
	owner = null

/datum/action/proc/Trigger()
	if(!IsAvailable())
		return 0
	return 1

/datum/action/proc/Process()
	return

/datum/action/proc/IsAvailable()
	if(!owner)
		return 0
	if(check_flags & AB_CHECK_RESTRAINED)
		if(owner.restrained())
			return 0
	if(check_flags & AB_CHECK_STUNNED)
		if(owner.stunned || owner.knockdown)
			return 0
	if(check_flags & AB_CHECK_LYING)
		if(owner.lying)
			return 0
	if(check_flags & AB_CHECK_CONSCIOUS)
		if(owner.stat)
			return 0
	return 1

/datum/action/proc/UpdateButtonIcon()
	if(button)
		button.icon = button_icon
		button.icon_state = background_icon_state

		ApplyIcon(button)

		if(!IsAvailable())
			button.color = rgb(128,0,0,128)
		else
			button.color = rgb(255,255,255,255)
			return 1

/datum/action/proc/ApplyIcon(obj/screen/movable/action_button/current_button)
	current_button.overlays = null
	if(icon_icon && button_icon_state)
		var/image/img
		img = image(icon_icon, current_button, button_icon_state)
		img.pixel_x = 0
		img.pixel_y = 0
		current_button.overlays += img



//Presets for item actions
/datum/action/item_action
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	button_icon_state = null
	// If you want to override the normal icon being the item
	// then change this to an icon state

/datum/action/item_action/New(Target)
	..()
	var/obj/item/I = target
	I.actions += src

/datum/action/item_action/Destroy()
	var/obj/item/I = target
	I.actions -= src
	return ..()

/datum/action/item_action/Trigger()
	if(!..())
		return 0
	if(target)
		var/obj/item/I = target
		I.attack_self(owner)
	return 1

/datum/action/item_action/ApplyIcon(obj/screen/movable/action_button/current_button)
	current_button.overlays = null

	if(button_icon && button_icon_state)
		// If set, use the custom icon that we set instead
		// of the item appearence
		..(current_button)
	else if(target)
		var/obj/item/I = target
		var/old = I.layer
		I.layer = FLOAT_LAYER //AAAH
		current_button.overlays += I
		I.layer = old
		
//Mostly attack self procs renamed
/datum/action/item_action/set_internals
	name = "Set Internals"
	
/datum/action/item_action/instrument
	name = "Play Instrument"
	
/datum/action/item_action/toggle_goggles
	name = "Toggle Goggles"
	
/datum/action/item_action/toggle_helmet
	name = "Toggle Helmet"
	
/datum/action/item_action/toggle_mask
	name = "Toggle Mask"
	
/datum/action/item_action/toggle_magboots
	name = "Toggle Magboots"
	
/datum/action/item_action/toggle_gun
	name = "Toggle Gun"
	
/datum/action/item_action/toggle_light
	name = "Toggle Light"
	
/datum/action/item_action/activate_siren
	name = "Activate Siren"
	
/datum/action/item_action/toggle_helmet_camera
	name = "Toggle Helmet Camera"
	
/datum/action/item_action/toggle_firemode
	name = "Toggle Firemode"
	
/datum/action/item_action/toggle_voicechanger
	name = "Toggle Voice Changer"
	
/datum/action/item_action/toggle_hood
	name = "Toggle Hood"