/*/obj/item/clothing/accessory/shoe

/obj/item/clothing/accessory/can_attach_to(obj/item/clothing/shoes/C)
	return istype(C)

/obj/item/clothing/accessory/shoe/snowshoe/prevent_snow_slow()
	return 1

/obj/item/clothing/accessory/shoe/ski

/obj/item/clothing/accessory/shoe/ski/allow_ski()
	return 1

/obj/item/clothing/accessory/shoe/ski/prevent_snow_slip()
	return 1

/obj/item/clothing/accessory/shoe/spikes

/obj/item/clothing/accessory/shoe/spikes/prevent_snow_slip()
	return 1
*/