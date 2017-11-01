
//NASA Voidsuit
/obj/item/clothing/head/helmet/space/nasavoid
	name = "NASA Void Helmet"
	desc = "A high tech, NASA Centcom branch designed, dark red space suit helmet. Used for AI satellite maintenance."
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	icon_state = "void"
	item_state = "void"

/obj/item/clothing/suit/space/nasavoid
	name = "NASA Voidsuit"
	icon_state = "void"
	item_state = "void"
	species_restricted = list("exclude",VOX_SHAPED)
	desc = "A high tech, NASA Centcom branch designed, dark red space suit. Used for AI satellite maintenance."
	slowdown = HARDSUIT_SLOWDOWN_LOW

/obj/item/clothing/shoes/magboots/nasavoid
	name = "NASA Voidboots"
	desc = "A high tech, NASA Centcom branch designed, dark red pair of magboots. Used for AI satellite maintenance."
	icon_state = "syndiemag0"
	base_state = "syndiemag"