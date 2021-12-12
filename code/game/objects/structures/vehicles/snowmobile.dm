/obj/item/key/snowmobile
	name = "snowmobile key"
	desc = "An ignition key for use with Nanotrasen's snowmobile brand."
	icon_state = "keys"

/obj/structure/bed/chair/vehicle/snowmobile
	name = "snowmobile"
	desc = "A Nanotrasen motorized vehicle with kelvar tracks designed for use in snowy environments. It's also equipped to handle frozen terrain and road surfaces, but will perform poorly indoors."
	icon_state = "snowmobile"
	keytype = /obj/item/key/snowmobile
	can_have_carts = TRUE
	wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle/snowmobile
	headlights = TRUE
	var/list/approved_terrain = list(/turf/simulated/floor/engine/concrete,/turf/unsimulated/floor/snow,
									 /turf/unsimulated/floor/noblizz_permafrost,
									 /obj/glacier,
									 /turf/simulated/floor/plating/snow)

/obj/structure/bed/chair/vehicle/snowmobile/update_icon()
	for(var/datum/action/vehicle/toggle_headlights/TH in vehicle_actions)
		if(TH.on)
			icon_state = "[initial(icon_state)]-on"
			return
	icon_state = "[initial(icon_state)]"

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

var/list/security_cruisers = list()
/obj/structure/bed/chair/vehicle/snowmobile/security
	name = "security snowmobile"
	desc = "An armored security snowmobile. Take note, it does not use a universal key."
	health = 200
	max_health = 200
	icon_state = "snowcurity"
	headlights = FALSE

/obj/structure/bed/chair/vehicle/snowmobile/security/New()
	..()
	new /datum/action/vehicle/toggle_headlights/siren(src)

/obj/structure/bed/chair/vehicle/snowmobile/security/process()
	..()
	if(light_obj)
		if(light_color == "#FF0000")
			light_color = "#0000FF"
		else
			light_color = "#FF0000"

/obj/structure/bed/chair/vehicle/snowmobile/security/set_keys()
	..()
	name += " (#[vehicle_list.Find(src)])"
	mykey.name = "security snowmobile key (#[vehicle_list.Find(src)])"
	mykey.icon_state = "keysec"
	if(sec_key_lockup)
		mykey.forceMove(sec_key_lockup)

/obj/structure/bed/chair/vehicle/snowmobile/getMovementDelay()
	var/turf/T = loc
	if(is_type_in_list(T, approved_terrain))
		return 1
	else
		var/list/dragsounds = list('sound/misc/metal_drag1.ogg', 'sound/misc/metal_drag2.ogg', 'sound/misc/metal_drag3.ogg')
		playsound(src, pick(dragsounds), 10, 1) //The scratching sound is VERY loud, obnoxious and repeats often, so make sure the volume is low
		return 5 //It's not designed to move this way!
