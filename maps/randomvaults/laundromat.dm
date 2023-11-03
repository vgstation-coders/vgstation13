/obj/abstract/map/spawner/laundromat/clothing
	name = "Laundromat clothing spawner"
	amount = 4
	chance = 15
	jiggle = 10

/obj/abstract/map/spawner/laundromat/clothing/New()
	if (!clothing.len)
		clothing = existing_typesof(/obj/item/clothing)
		for (var/clothing_type in clothing_types_blacklist)
			clothing -= typesof(clothing_type)
		for (var/clothing_type in clothing_blacklist)
			clothing -= clothing_type
	to_spawn = clothing
	return ..()

/area/vault/laundromat
	name = "Laundromat"