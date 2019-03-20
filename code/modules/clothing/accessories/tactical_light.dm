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
	attached_to.overlays += inv_overlay
	attached_to.actions_types += list(/datum/action/item_action/toggle_light)
	//user.update_action_buttons_icon()
	/*if istype(C, /obj/item/clothing/head)
		user.update_inv_head()
	else
		user.update_inv_wear_suit()*/
	update_icon()
	if(ismob(attached_to.loc))
		var/mob/M = attached_to.loc
		M.regenerate_icons()
		update_brightness()
	..()
		
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
	//attached_to.overlays -= inv_overlay
	if(ismob(attached_to.loc))
		var/mob/M = attached_to.loc
		M.regenerate_icons()
		update_brightness()
	attached_to = null
	if(source_light)
		source_light.forceMove(get_turf(src))
		if(user)
			user.put_in_hands(source_light)
		add_fingerprint(user)
		transfer_fingerprints(src,source_light)
		source_light = null
	qdel(src)

/obj/item/clothing/accessory/taclight/proc/update_brightness()
	if(source_light && source_light.on)
		set_light(source_light.brightness_on)
	else
		set_light(0)
	update_icon()