/obj/item/key/snowmobile
	name = "\improper Snowmobile key"
	desc = "Someone has to do it."
	icon_state = "keys"

/obj/structure/bed/chair/vehicle/snowmobile
	name = "snowmobile"
	desc = "A vehicle designed for outdoor use in snowy environments. It's also equipped to handle frozen terrain and road surfaces - but not indoor plating."
	icon_state = "snowmobile"
	keytype = /obj/item/key/snowmobile
	can_have_carts = FALSE
	wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle/snowmobile
	var/list/approved_terrain = list(/turf/simulated/floor/engine/concrete,/turf/unsimulated/floor/snow,
									/turf/unsimulated/floor/noblizz_permafrost,/obj/glacier,
									/turf/simulated/floor/plating/snow)

/obj/effect/decal/mecha_wreckage/vehicle/snowmobile
	// TODO: SPRITE PLS
	//icon = 'icons/obj/vehicles.dmi'
	//icon_state = "gokart_wreck"
	name = "snowmobile wreckage"
	desc = "Avalanche!"

//Universal key snowmobiles
/obj/item/key/snowmobile/universal
	name = "universal snowmobile key"
	desc = "Someone has to do it. This key has a universal bitting."

/obj/item/key/snowmobile/universal/initialize()
	return

/obj/structure/bed/chair/vehicle/snowmobile/universal
	desc = "There's something out there, and now you can catch it. This snowmobile uses a universal key."
	keytype = /obj/item/key/snowmobile/universal

/obj/structure/bed/chair/vehicle/snowmobile/universal/set_keys()
	if(keytype && !vin)
		heldkey = new keytype(src)

/obj/structure/bed/chair/vehicle/snowmobile/getMovementDelay()
	var/turf/T = loc
	if(is_type_in_list(T,approved_terrain))
		return 1
	else
		var/list/dragsounds = list('sound/misc/metal_drag1.ogg','sound/misc/metal_drag2.ogg','sound/misc/metal_drag3.ogg')
		playsound(src, pick(dragsounds), 50, 1)
		return 5 //It's not designed to move this way!