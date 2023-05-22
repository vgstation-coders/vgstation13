/*

* wristwatch
* black wristwatch
* goldwatch
* pocket watch

*/

////////////////////////////WRIST WATCH/////////////////////////////////////////

/obj/item/clothing/accessory/wristwatch
	name = "wristwatch"
	desc = "A wristwatch with a red leather strap."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing_accessories.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing_accessories.dmi')
	icon = 'icons/obj/watches/wristwatch.dmi'
	icon_state = "wristwatch"
	item_state = "wristwatch"
	_color = "wristwatch"
	accessory_exclusion = WRISTWATCH
	w_class = W_CLASS_TINY
	autoignition_temperature = AUTOIGNITION_PLASTIC
	var/last_hour = 12
	var/last_minute = 12
	var/luminescent = TRUE

/obj/item/clothing/accessory/wristwatch/New()
	..()
	update_icon()
	process()
	processing_objects += src

/obj/item/clothing/accessory/wristwatch/Destroy()
	processing_objects -= src
	..()

/obj/item/clothing/accessory/wristwatch/examine(var/mob/user)
	..()
	check_watch()

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
		last_hour = hours
		last_minute = minutes
		update_icon()

	last_hour = hours
	last_minute = minutes

/obj/item/clothing/accessory/wristwatch/update_icon()
	..()
	overlays.len = 0
	overlays += "minutes_[last_minute]"
	overlays += "hours_[last_hour]"

	if (luminescent)
		var/image/I_hours = image(icon, src, "hours_[last_hour]o")
		I_hours.plane = ABOVE_LIGHTING_PLANE
		overlays += I_hours
		var/image/I_minutes = image(icon, src, "minutes_[last_minute]o")
		I_minutes.plane = ABOVE_LIGHTING_PLANE
		overlays += I_minutes

/obj/item/clothing/accessory/wristwatch/proc/check_watch()
	if (ismob(usr))
		to_chat(usr, "<span class='notice'>The time is [worldtime2text(world.time, TRUE)].</span>")

/obj/item/clothing/accessory/wristwatch/gold
	name = "golden wristwatch"
	desc = "A wristwatch worth a captain's paycheck."
	icon = 'icons/obj/watches/goldwatch.dmi'
	icon_state = "goldwatch"
	item_state = "goldwatch"
	_color = "goldwatch"
	luminescent = FALSE

/obj/item/clothing/accessory/wristwatch/black
	name = "black wristwatch"
	desc = "A sleek black wristwatch with a luminescent dial and hands."
	icon = 'icons/obj/watches/wristwatch_black.dmi'
	icon_state = "wristwatch_black"
	item_state = "wristwatch_black"
	_color = "wristwatch_black"

////////////////////////////POCKET WATCH/////////////////////////////////////////

/obj/item/pocketwatch
	name = "pocket watch"
	desc = "A silvery pocket watch. Despite looking fairly antique, it somehow appears to still be working."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing_accessories.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing_accessories.dmi')
	icon = 'icons/obj/watches/pocketwatch.dmi'
	icon_state = "pocketwatch"
	item_state = "pocketwatch"
	w_class = W_CLASS_TINY
	flags = FPRINT
	var/last_hour = 12
	var/last_minute = 12

/obj/item/pocketwatch/New()
	..()
	update_icon()
	process()
	processing_objects += src

/obj/item/pocketwatch/Destroy()
	processing_objects -= src
	..()

/obj/item/pocketwatch/examine(var/mob/user)
	..()
	check_watch()

/obj/item/pocketwatch/attack_self(var/mob/user)
	check_watch()

/obj/item/pocketwatch/proc/check_watch()
	if (ismob(usr))
		to_chat(usr, "<span class='notice'>The time is [worldtime2text(world.time, TRUE)].</span>")

/obj/item/pocketwatch/process()
	var/hours = (round(world.time / 36000) + 12) % 12
	if (hours == 0)
		hours = 12

	var/minutes = round ((round(world.time / 600) % 60) / 5)
	if (minutes == 0)
		minutes = 12

	if (hours != last_hour || minutes != last_minute)
		last_hour = hours
		last_minute = minutes
		update_icon()

	last_hour = hours
	last_minute = minutes


/obj/item/pocketwatch/update_icon()
	..()
	overlays.len = 0
	overlays += "minutes_[last_minute]"
	overlays += "hours_[last_hour]"

/obj/item/pocketwatch/afterattack(var/atom/attacked, var/mob/user, var/proximity_flag)
	if (proximity_flag && istype(attacked,/obj/item/clothing/under))
		to_chat(user, "<span class='warning'>Pocket watches are meant to be kept in your pocket.</span>")

////////////

/obj/item/pocketwatch/luna_dial
	desc = "A silvery pocket watch. Despite looking fairly antique, it somehow appears to still be working. The words \"Luna Dial\" appear finely printed under the center of the dial."
	var/arming_timestop = FALSE
	var/mob/caster
	var/spell/aoe_turf/fall/fall

/obj/item/pocketwatch/luna_dial/New()
	..()
	caster = new
	caster.invisibility = 101
	caster.setDensity(FALSE)
	caster.anchored = 1
	caster.flags = INVULNERABLE
	fall = new /spell/aoe_turf/fall
	caster.add_spell(fall)
	fall.spell_flags = 0
	fall.invocation_type = SpI_NONE
	fall.the_world_chance = 0
	fall.range = 3
	fall.sleeptime = 5 SECONDS

/obj/item/pocketwatch/luna_dial/Destroy()
	fall = null
	QDEL_NULL(caster)
	..()

/obj/item/pocketwatch/luna_dial/attack_self(var/mob/user)
	check_watch()
	if (!arming_timestop)
		arming_timestop = TRUE
		var/turf/T = get_turf(src)
		playsound(T, 'sound/machines/dial_tick.ogg', 60, 0, -1)
		playsound(T, 'sound/machines/dial_reset.ogg', 10, 0, -4)
		to_chat(user, "<span class='notice'>You click the button on top of the dial and hear the watch's mechanism activating.</span>")
		spawn(2 SECONDS)
			stop_time()
			sleep(5 SECONDS)
			arming_timestop = FALSE


/obj/item/pocketwatch/luna_dial/proc/stop_time()
	caster.forceMove(get_turf(src))
	fall.perform(caster, skipcharge = 1)
	caster.forceMove(null)
