#define AB_CHECK_RESTRAINED 1
#define AB_CHECK_STUNNED 2
#define AB_CHECK_LYING 4
#define AB_CHECK_CONSCIOUS 8


/datum/action
	var/name = "Generic Action"
	var/desc = null
	var/obj/target = null
	var/check_flags = 0
	var/processing = FALSE
	var/obj/abstract/screen/movable/action_button/button = null
	var/button_icon = 'icons/mob/actions.dmi'
	var/background_icon_state = "bg_default"
	var/buttontooltipstyle = ""

	var/icon_icon = 'icons/mob/actions.dmi'
	var/button_icon_state = "default"
	var/mob/owner

/datum/action/New(Target)
	link_to(Target)
	button = new
	button.linked_action = src
	button.name = name
	button.actiontooltipstyle = buttontooltipstyle
	if(desc)
		button.desc = desc

/datum/action/proc/link_to(Target)
	target = Target

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	target = null
	qdel(button)
	button = null
	return ..()

/datum/action/proc/Grant(mob/M)
	if(M)
		if(owner)
			if(owner == M)
				return
			Remove(owner)
		owner = M
		M.actions += src
		if(M.client)
			M.client.screen += button
		M.update_action_buttons()
	else
		Remove(owner)

/datum/action/proc/Remove(mob/M)
	if(M)
		if(M.client)
			M.client.screen -= button
		M.actions -= src
		M.update_action_buttons()
	button.moved = FALSE //so the button appears in its normal position when given to another owner.
	owner = null

/datum/action/proc/Trigger()
	if(!IsAvailable())
		return FALSE
	return TRUE

/datum/action/proc/Process()
	return

/datum/action/proc/IsAvailable()
	if(!owner)
		return FALSE
	if(check_flags & AB_CHECK_RESTRAINED)
		if(owner.restrained())
			return FALSE
	if(check_flags & AB_CHECK_STUNNED)
		if(owner.stunned || owner.knockdown)
			return FALSE
	if(check_flags & AB_CHECK_LYING)
		if(owner.lying)
			return FALSE
	if(check_flags & AB_CHECK_CONSCIOUS)
		if(owner.stat)
			return FALSE
	return TRUE

/datum/action/proc/UpdateButtonIcon()
	if(button)
		button.icon = button_icon
		button.icon_state = background_icon_state

		ApplyIcon(button)

		if(!IsAvailable())
			button.color = rgb(128,0,0,128)
		else
			button.color = rgb(255,255,255,255)
			return TRUE

/datum/action/proc/ApplyIcon(obj/abstract/screen/movable/action_button/current_button)
	current_button.overlays = null
	if(icon_icon && button_icon_state)
		var/image/img
		img = image(icon_icon, current_button, button_icon_state)
		img.pixel_x = 0
		img.pixel_y = 0
		current_button.overlays += img

/datum/action/item_action/target_appearance/ApplyIcon(obj/abstract/screen/movable/action_button/current_button) // useful when you want to preserve the target's overlays on the button
	current_button.overlays = null
	if(target)
		var/mutable_appearance/mut = new(target.appearance)
		mut.plane = FLOAT_PLANE
		mut.layer = FLOAT_LAYER
		current_button.overlays += mut

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
		return FALSE
	if(target)
		var/obj/item/I = target
		I.attack_self(owner)
		owner.delayNextAttack(1)
	return TRUE

/datum/action/item_action/ApplyIcon(obj/abstract/screen/movable/action_button/current_button)
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

/datum/action/item_action/toggle_anon
	name = "Toggle Anonymity"

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

/datum/action/item_action/toggle_belt
	name = "Toggle Belt"

//toggle_helmet_mask has to have its own functions as to not conflict with plasmamen lights
/datum/action/item_action/toggle_helmet_mask
	name = "Toggle Helmet Mask"
	var/up = TRUE

/datum/action/item_action/toggle_helmet_mask/Trigger()
	if(IsAvailable() && owner && target)
		var/obj/item/clothing/I = target
		to_chat(owner, "You toggle the built-in welding mask [src.up ? "on" : "off"].")
		src.up = !src.up
		if(src.up)
			I.eyeprot = 0
			I.body_parts_covered &= ~EYES
		else
			I.eyeprot = 3
			I.body_parts_covered |= EYES
		return TRUE

	return FALSE

/datum/action/item_action/generic_toggle/New()
	..()
	name = "Toggle [target]"

/datum/action/item_action/toggle_rig_suit
	name = "Toggle rig suit"

/datum/action/item_action/toggle_rig_suit/Trigger()
	if(IsAvailable() && owner && target && isrig(target))
		var/obj/item/clothing/suit/space/rig/R = target
		R.toggle_suit()
		return TRUE
	return FALSE

/datum/action/item_action/toggle_rig_light
	name = "Toggle rig light"

/datum/action/item_action/toggle_rig_light/Trigger()
	if(IsAvailable() && target && isrighelmet(target))
		var/obj/item/clothing/head/helmet/space/rig/R = target
		R.toggle_light(owner)
		return TRUE
	return FALSE
