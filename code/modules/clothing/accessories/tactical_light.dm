/obj/item/clothing/accessory/taclight
	name = "tactical light"
	desc = "This is attached to something."
	icon_state = "taclight"
	inv_overlay
	var/obj/item/device/flashlight/tactical/source_light

/obj/item/clothing/accessory/taclight/can_attach_to(obj/item/clothing/C)
	return (istype(C, /obj/item/clothing/head) || istype(C, /obj/item/clothing/suit/armor))

/obj/item/clothing/accessory/taclight/on_attached(obj/item/clothing/C)
	if(!istype(C))
		return
	attached_to = C
	attached_to.actions_types += list(/datum/action/item_action/toggle_light)
	if(istype(attached_to, /obj/item/clothing/head))
		icon_state = "[initial(icon_state)]_helmet"
	else
		icon_state = "[initial(icon_state)]_armor"
	update_icon()
	if(ismob(attached_to.loc))
		var/mob/M = attached_to.loc
		M.update_action_buttons_icon()
		M.regenerate_icons()
		update_brightness(attached_to)
		var/datum/action/makelight = new /datum/action/item_action/toggle_light(attached_to)
		if(ismob(attached_to.loc))
			var/mob/user = attached_to.loc
			makelight.Grant(user)
	
	if(attached_to)
		attached_to.overlays -= inv_overlay
	inv_overlay = image("icon" = 'icons/obj/clothing/accessory_overlays.dmi', "icon_state" = "[icon_state]")
	if(attached_to)
		attached_to.overlays += inv_overlay
		if(ishuman(attached_to.loc))
			var/mob/living/carbon/human/H = attached_to.loc
			H.update_inv_by_slot(attached_to.slot_flags)
			
			
/obj/item/clothing/accessory/taclight/attack_self(mob/user)
	to_chat(world, "<span class='boldannounce'>Calling attack_self on [src]</span>")
	if(source_light)
		source_light.on = !source_light.on
		if(get_turf(src))
			if(source_light.on)
				playsound(src, source_light.sound_on, 50, 1)
			else
				playsound(src, source_light.sound_off, 50, 1)
	if(attached_to)
		update_brightness(attached_to)
			
/obj/item/clothing/accessory/taclight/update_icon()
	/*if (source_light)
		icon_state = "[initial(icon_state)]_[flashlight.on]"*/
	/*if(attached_to)
		var/image/vestoverlay = image('icons/mob/suit.dmi', src, icon_state)
		attached_to.dynamic_overlay["[UNIFORM_LAYER]"] = vestoverlay
		if(ismob(attached_to.loc))
			var/mob/M = attached_to.loc
			M.regenerate_icons()*/
	..()	
	
	
/obj/item/clothing/accessory/taclight/on_removed(mob/user)
	if(!attached_to)
		return
	//attached_to.dynamic_overlay["[UNIFORM_LAYER]"] = null
	attached_to.overlays -= inv_overlay
	if(ismob(attached_to.loc))
		var/mob/M = attached_to.loc
		M.regenerate_icons()
		for(var/datum/action/A in attached_to.actions)
			if(istype(A, /datum/action/item_action/toggle_light))
				qdel(A)
				attached_to.actions_types -= list(/datum/action/item_action/toggle_light)
	if(source_light)
		source_light.forceMove(get_turf(src))
		if(user)
			user.put_in_hands(source_light)
		add_fingerprint(user)
		transfer_fingerprints(src,source_light)
		source_light = null
	update_brightness(attached_to)
	attached_to = null
	qdel(src)

/obj/item/clothing/accessory/taclight/proc/update_brightness(obj/item/clothing/C)
	if(src.source_light && src.source_light.on)
		C.set_light(src.source_light.brightness_on)
	else
		C.set_light(0)
	update_icon()