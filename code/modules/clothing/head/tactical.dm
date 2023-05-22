/obj/item/clothing/head/helmet/tactical
	var/preattached = FALSE
	body_parts_covered = HEAD|EARS|EYES|MASKHEADHAIR
	species_fit = list()
	autoignition_temperature = AUTOIGNITION_PROTECTIVE
	on_armory_manifest = TRUE

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

/obj/item/clothing/head/helmet/tactical/riot/offenseTackleBonus()
	return 10

/obj/item/clothing/head/helmet/tactical/riot/defenseTackleBonus()
	return 10


/obj/item/clothing/head/helmet/tactical/laserproof
	name = "ablative helmet"
	desc = "A helmet that excels in protecting the wearer against energy projectiles."
	icon_state = "laserproof"
	item_state = "laserproof"

	armor = list(melee = 10, bullet = 10, laser = 80,energy = 50, bomb = 0, bio = 0, rad = 0)
	eyeprot = 0
	body_parts_covered = FULL_HEAD|BEARD|MASKHEADHAIR
	siemens_coefficient = 0
	// no reflect chance because i don't want to touch the ablative reflect code


/obj/item/clothing/head/helmet/tactical/bulletproof
	name = "bulletproof helmet"
	desc = "A helmet that excels in protecting the wearer against high-velocity solid projectiles."
	icon_state = "bulletproof"
	item_state = "bulletproof"

	armor = list(melee = 10, bullet = 80, laser = 10,energy = 10, bomb = 0, bio = 0, rad = 0)
	eyeprot = 0
	body_parts_covered = FULL_HEAD|BEARD|MASKHEADHAIR


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


/obj/item/clothing/head/helmet/tactical/antichrist
	name = "blue helmet"
	desc = "It has some markings at the front."
	item_state = "antichrist"
	icon_state = "antichrist"
	body_parts_covered = HEAD|EARS|MASKHEADHAIR
	species_fit = list(VOX_SHAPED)
