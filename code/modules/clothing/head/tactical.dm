/obj/item/clothing/head/helmet/tactical
	var/preattached = FALSE
	body_parts_covered = HEAD|EARS|EYES|MASKHEADHAIR
	species_fit = list()

/obj/item/clothing/head/helmet/tactical/New()
	..()
	if(preattached)
		attach_accessory(new/obj/item/clothing/accessory/taclight(src))

/obj/item/clothing/head/helmet/tactical/sec
	name = "tactical helmet"
	desc = "Standard Security gear. Protects the head from impacts. Can be attached with a flashlight."
	icon_state = "helmet_sec"
	species_fit = list(VOX_SHAPED,INSECT_SHAPED)


/obj/item/clothing/head/helmet/tactical/sec/preattached
	preattached = 1

/obj/item/clothing/head/helmet/tactical/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

	flags = FPRINT
	armor = list(melee = 82, bullet = 15, laser = 5,energy = 5, bomb = 5, bio = 2, rad = 0)
	siemens_coefficient = 0.7
	body_parts_covered = FULL_HEAD|MASKHEADHAIR
	eyeprot = 1

/obj/item/clothing/head/helmet/tactical/swat
	name = "\improper SWAT helmet"
	desc = "They're often used by highly trained Swat Members."
	icon_state = "swat"
	flags = FPRINT
	item_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	heat_conductivity = INS_HELMET_HEAT_CONDUCTIVITY
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	pressure_resistance = 200 * ONE_ATMOSPHERE
	siemens_coefficient = 0.5
	eyeprot = 1
	body_parts_visible_override = FACE
