
/obj/item/clothing/accessory/wristwatch
	name = "wristwatch"
	desc = "A wristwatch with a red leather strap."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing_accessories.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing_accessories.dmi')
	icon = 'icons/obj/watches.dmi'
	icon_state = "wristwatch"
	item_state = "wristwatch"
	_color = "wristwatch"
	accessory_exclusion = WRISTWATCH
	w_class = W_CLASS_TINY
	var/last_hour = 12
	var/last_minute = 12

/obj/item/clothing/accessory/wristwatch/New()
	..()
	update_icon()
	processing_objects += src

/obj/item/clothing/accessory/wristwatch/Destroy()
	processing_objects -= src
	..()

/obj/item/clothing/accessory/wristwatch/can_attach_to(obj/item/clothing/C)
	return (istype(C, /obj/item/clothing/under) && !(/datum/action/item_action/target_appearance/check_watch in C.actions))

/obj/item/clothing/accessory/wristwatch/on_attached(obj/item/clothing/C)
	..()
	var/datum/action/A = new /datum/action/item_action/target_appearance/check_watch(src)
	if(ismob(C.loc))
		var/mob/user = C.loc
		A.Grant(user)

/obj/item/clothing/accessory/wristwatch/on_removed(mob/user as mob)
	for(var/datum/action/A in actions)
		if(istype(A, /datum/action/item_action/target_appearance/check_watch))
			qdel(A)
	..()
	if(user)
		user.update_action_buttons_icon()

/obj/item/clothing/accessory/wristwatch/attack_self(var/mob/user)
	check_watch()

/obj/item/clothing/accessory/wristwatch/process()
	var/hours = (round(world.time / 36000) + 12) % 12
	if (hours == 0)
		hours = 12

	var/minutes = round ((round(world.time / 600) % 60) / 5)
	if (minutes == 0)
		minutes = 12

	if (hours != last_hour || minutes != last_minute)
		update_icon()

	last_hour = hours
	last_minute = minutes

/obj/item/clothing/accessory/wristwatch/update_icon()
	..()
	overlays.len = 0

	var/hours = (round(world.time / 36000) + 12) % 12
	if (hours == 0)
		hours = 12

	var/minutes = round ((round(world.time / 600) % 60) / 5)
	if (minutes == 0)
		minutes = 12

	overlays += "minutes_[minutes]"
	overlays += "hours_[hours]"

	var/image/I_hours = image(icon, src, "hours_[hours]o")
	I_hours.plane = ABOVE_LIGHTING_PLANE
	overlays += I_hours
	var/image/I_minutes = image(icon, src, "minutes_[minutes]o")
	I_minutes.plane = ABOVE_LIGHTING_PLANE
	overlays += I_minutes

/obj/item/clothing/accessory/wristwatch/proc/check_watch()
	if (ismob(usr))
		to_chat(usr, "<span class='notice'>The time is [worldtime2text(world.time, TRUE)].</span>")
