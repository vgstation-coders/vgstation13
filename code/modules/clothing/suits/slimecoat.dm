	//i swear this isn't just a reference item

/obj/item/clothing/suit/storage/wintercoat/slimecoat
	name = "slime coat"
	desc = "This doesn't look like it protects against water very well."
	icon_state = "slimecoat"
	item_state = "slimecoat"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	allowed = list(/obj/item/weapon/gun/energy/temperature,/obj/item/device/flashlight/lamp/slime)
	autoignition_temperature = AUTOIGNITION_ORGANIC
