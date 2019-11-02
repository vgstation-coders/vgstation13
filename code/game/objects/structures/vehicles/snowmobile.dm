/obj/item/key/snowmobile
	name = "\improper snowmobile key"
	desc = "An ignition key for use with Nanotrasen's snowmobile brand."
	icon_state = "keys"

/obj/structure/bed/chair/vehicle/snowmobile
	name = "snowmobile"
	desc = "A Nanotrasen motorized vehicle with kelvar tracks designed for use in snowy environments. It's also equipped to handle frozen terrain and road surfaces, but will perform poorly indoors."
	icon_state = "snowmobile"
	keytype = /obj/item/key/snowmobile
	can_have_carts = FALSE
	wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle/snowmobile
	var/list/approved_terrain = list(/turf/simulated/floor/engine/concrete,/turf/unsimulated/floor/snow,
									 /turf/unsimulated/floor/noblizz_permafrost,
									 /obj/glacier,
									 /turf/simulated/floor/plating/snow)
	var/on = 0
	var/brightness_on = 6 //luminosity when on
	var/has_sound = 1 //The CLICK sound when turning on/off
	var/sound_on = 'sound/items/flashlight_on.ogg'
	var/sound_off = 'sound/items/flashlight_off.ogg'

/obj/structure/bed/chair/vehicle/snowmobile/initialize()
	..()
	if(on)
		icon_state = "[initial(icon_state)]-on"
		set_light(brightness_on)
	else
		icon_state = initial(icon_state)
		set_light(0)

/obj/structure/bed/chair/vehicle/snowmobile/proc/update_brightness(var/mob/user = null, var/playsound = 1)
	if(on)
		icon_state = "[initial(icon_state)]-on"
		set_light(brightness_on)
		if(playsound && has_sound)
			if(get_turf(src))
				playsound(src, sound_on, 50, 1)
	else
		icon_state = initial(icon_state)
		set_light(0)
		if(playsound && has_sound)
			playsound(src, sound_off, 50, 1)

/obj/structure/bed/chair/vehicle/snowmobile/verb/toggle_light()
	set name = "Toggle headlights"
	set category = "Object"
	set src in view(1)

	if(!usr.incapacitated())
		if(!isturf(usr.loc))
			to_chat(usr, "You cannot turn the light on while in \the [usr.loc].")//To prevent some lighting anomalities.

			return 0
		on = !on
		update_brightness(usr)
		return 1

/obj/effect/decal/mecha_wreckage/vehicle/snowmobile
	// TODO: SPRITE PLS
	//icon = 'icons/obj/vehicles.dmi'
	//icon_state = "gokart_wreck"
	name = "snowmobile wreckage"
	desc = "Avalanche!"

//Universal key snowmobiles
/obj/item/key/snowmobile/universal
	name = "universal snowmobile key"
	desc = "An universal ignition key for use with Nanotrasen's snowmobile brand, NT patented cheap ignition lock systems means that any snowmobile can be driven with it. Useful to have when everything goes to hell."

/obj/item/key/snowmobile/universal/initialize()
	return

/obj/structure/bed/chair/vehicle/snowmobile/universal
	desc = "A Nanotrasen motorized vehicle with kelvar tracks designed for use in snowy environments. It's also equipped to handle frozen terrain and road surfaces, but will perform poorly indoors. This one has NT patented universal ignition for easier vehicle 'borrowing'."
	keytype = /obj/item/key/snowmobile/universal

/obj/structure/bed/chair/vehicle/snowmobile/universal/set_keys()
	if(keytype && !vin)
		heldkey = new keytype(src)

/obj/structure/bed/chair/vehicle/snowmobile/getMovementDelay()
	var/turf/T = loc
	if(is_type_in_list(T, approved_terrain))
		return 1
	else
		var/list/dragsounds = list('sound/misc/metal_drag1.ogg', 'sound/misc/metal_drag2.ogg', 'sound/misc/metal_drag3.ogg')
		playsound(src, pick(dragsounds), 10, 1) //The scratching sound is VERY loud, obnoxious and repeats often, so make sure the volume is low
		return 7 //It's not designed to move this way!
