/obj/item/clothing/head/helmet/tactical
	action_button_name = "Toggle Helmet Light"
	light_power = 1.5
	var/brightness_on = 4 //Luminosity when on.
	var/on = 0
	var/obj/item/device/flashlight/flashlight = null

/obj/item/clothing/head/helmet/tactical/New()
	..()
	update_brightness()

/obj/item/clothing/head/helmet/tactical/examine(mob/user)
	..()
	if(src.flashlight)
		to_chat(user, "The helmet is mounted with a flashlight attachment, it is [on ? "":"un"]lit.")

/obj/item/clothing/head/helmet/tactical/attackby(var/obj/item/I, mob/user, params)
	if( !src.flashlight && I.type == /obj/item/device/flashlight ) //have to directly check for type because flashlights are the base type and not a child
		user.drop_item(I)
		I.forceMove(src)
		flashlight = I

		update_brightness()
		user.update_action_buttons()
		user.update_inv_head()
		return
	if(isscrewdriver(I) && src.flashlight)
		flashlight.forceMove(get_turf(src))
		flashlight = null

		update_brightness()
		user.update_action_buttons()
		user.update_inv_head()
		return
	return ..()

obj/item/clothing/head/helmet/tactical/attack_self(mob/user)
	if(src.flashlight)
		on = !on
	else
		on = FALSE
	update_brightness()
	user.update_inv_head()

/obj/item/clothing/head/helmet/tactical/proc/update_brightness()
	if(on)
		set_light(brightness_on)
	else
		set_light(0)
	update_icon()

/obj/item/clothing/head/helmet/tactical/update_icon()
	if(flashlight)
		icon_state = "[initial(icon_state)]_[on]"
		item_state = "[initial(item_state)]_[on]"
		action_button_name = "Toggle Helmet Light"
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		action_button_name = null

/obj/item/clothing/head/helmet/tactical/sec
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmet_sec"
	//we don't actually have anything special here because our parent is already the default sec helmet...

/obj/item/clothing/head/helmet/tactical/sec/preattached/New()
	..()
	flashlight = new(src)
	update_brightness()
