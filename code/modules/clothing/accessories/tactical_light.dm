/obj/item/clothing/accessory/taclight
	name = "tactical light"
	desc = "This is attached to something."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "taclight"
	accessory_exclusion = ACCESSORY_LIGHT
	var/obj/item/device/flashlight/tactical/source_light
	ignoreinteract = TRUE

/obj/item/clothing/accessory/taclight/New()
	..()
	if (!source_light)
		source_light = new /obj/item/device/flashlight/tactical/
		source_light.forceMove(src)

/obj/item/clothing/accessory/taclight/Destroy()
	source_light = null
	..()

/obj/item/clothing/accessory/taclight/proc/generate_icon_state()
	if(!attached_to || !icon_state)
		return
	icon_state = initial(icon_state)
	if(istype(attached_to, /obj/item/clothing/head))
		icon_state = "[initial(icon_state)]_helmet"
	if(istype(attached_to, /obj/item/clothing/suit/armor))
		icon_state = "[initial(icon_state)]_armor"
	if(source_light && source_light.on)
		icon_state = "[icon_state]-on"


/obj/item/clothing/accessory/taclight/can_attach_to(obj/item/clothing/C)
	return (istype(C, /obj/item/clothing/head) || istype(C, /obj/item/clothing/suit/armor))

/obj/item/clothing/accessory/taclight/on_attached(obj/item/clothing/C)
	if(!istype(C))
		return
	attached_to = C
	generate_icon_state()
	update_brightness(attached_to)
	var/datum/action/item_action/toggle_taclight/makelight = new /datum/action/item_action/toggle_taclight(attached_to)
	makelight.ownerlight = src
	if(ismob(attached_to.loc))
		var/mob/M = attached_to.loc
		M.update_action_buttons_icon()
		M.regenerate_icons()
		makelight.Grant(M)
	else
		attached_to.actions_types += list(/datum/action/item_action/toggle_taclight)
		//attached_to.actions += makelight
	if(ishuman(attached_to.loc))
		var/mob/living/carbon/human/H = attached_to.loc
		H.update_inv_by_slot(attached_to.slot_flags)

/obj/item/clothing/accessory/taclight/update_icon()
	if(!attached_to)
		return
	generate_icon_state()
	if(attached_to.overlays.len)
		attached_to.overlays -= inv_overlay
	if(icon_state)
		inv_overlay = image("icon" = 'icons/obj/clothing/accessory_overlays.dmi', "icon_state" = "[icon_state]")
		if (attached_to.overlays.len)
			attached_to.overlays -= inv_overlay
		attached_to.overlays += inv_overlay
	if(ishuman(attached_to.loc))
		var/mob/living/carbon/human/H = attached_to.loc
		H.update_inv_by_slot(attached_to.slot_flags)

	attached_to.update_icon()

/obj/item/clothing/accessory/taclight/on_removed(mob/user)
	if(!attached_to)
		return
	icon_state = null
	if(ismob(attached_to.loc))
		var/mob/M = attached_to.loc
		M.regenerate_icons()
	for(var/datum/action/A in attached_to.actions)
		if(istype(A, /datum/action/item_action/toggle_taclight))
			qdel(A)
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

/obj/item/clothing/accessory/taclight/attack_self(mob/user)
	if(user.isUnconscious() || user.restrained())
		return
	if(source_light)
		source_light.on = !source_light.on
		source_light.update_brightness(user)
	if(attached_to)
		update_brightness(attached_to)
		update_icon()
		attached_to.update_icon()

/obj/item/clothing/accessory/taclight/attackby(var/obj/item/I, var/mob/user)
	if(I.is_screwdriver(user) && attached_to)
		to_chat(user, "<span class='notice'>You remove [src] from [attached_to].</span>")
		attached_to.remove_accessory(user, src)

/obj/item/clothing/accessory/taclight/on_accessory_interact()
	return -1 //override priority check since you can't pull it off anyway

/datum/action/item_action/toggle_taclight
	name = "Toggle Tactical Light"
	var/obj/item/clothing/accessory/taclight/ownerlight

/datum/action/item_action/toggle_taclight/Trigger()
	ownerlight.attack_self(owner)
	ownerlight.update_brightness(ownerlight.attached_to)

/obj/item/clothing/accessory/taclight/proc/update_brightness(obj/item/clothing/C)
	if(src.source_light && src.source_light.on)
		C.set_light(src.source_light.light_range, source_light.light_power, source_light.light_color, source_light.light_type)
	else
		C.kill_light()
	update_icon()
