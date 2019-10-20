/obj/item/key/snowmobile
	name = "\improper Snowmobile key"
	desc = "Someone has to do it."
	icon_state = "keys"

/obj/structure/bed/chair/vehicle/snowmobile
	name = "snowmobile"
	desc = "There's something out there, and now you can catch it."
	icon_state = "snowmobile"
	keytype = /obj/item/key/snowmobile
	can_have_carts = FALSE
	wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle/snowmobile

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
		new keytype(loc)
