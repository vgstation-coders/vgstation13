/obj/item/clothing/head/helmet/tactical
	var/preattached = FALSE
	species_fit = list()

/obj/item/clothing/head/helmet/tactical/New()
	..()
	if(preattached)
		attach_accessory(new/obj/item/clothing/accessory/taclight(src))

/obj/item/clothing/head/helmet/tactical/sec
	name = "tactical helmet"
	desc = "Standard Security gear. Protects the head from impacts. Can be attached with a flashlight."
	icon_state = "helmet_sec"

/obj/item/clothing/head/helmet/tactical/sec/preattached
	preattached = 1

/obj/item/clothing/head/helmet/tactical/HoS
	name = "Head of Security Hat"
	desc = "The hat of the Head of Security. For showing the officers who's in charge."
	icon_state = "hoscap"
	flags = FPRINT
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	body_parts_covered = HEAD
	species_fit = list()
	siemens_coefficient = 0.8

/obj/item/clothing/head/helmet/tactical/HoS/dermal
	name = "Dermal Armour Patch"
	desc = "You're not quite sure how you manage to take it on and off, but it implants nicely in your head."
	icon_state = "dermal"
	item_state = "dermal"
	siemens_coefficient = 0.6

/obj/item/clothing/head/helmet/tactical/warden
	name = "warden's hat"
	desc = "It's a special helmet issued to the Warden of a security force. Protects the head from impacts."
	icon_state = "policehelm"
	body_parts_covered = HEAD

/obj/item/clothing/head/helmet/tactical/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	flags = FPRINT
	armor = list(melee = 82, bullet = 15, laser = 5,energy = 5, bomb = 5, bio = 2, rad = 0)
	siemens_coefficient = 0.7
	body_parts_covered = FULL_HEAD
	eyeprot = 1

/obj/item/clothing/head/helmet/tactical/swat
	name = "\improper SWAT helmet"
	desc = "They're often used by highly trained Swat Members."
	icon_state = "swat"
	flags = FPRINT
	item_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	heat_conductivity = INS_HELMET_HEAT_CONDUCTIVITY
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	pressure_resistance = 200 * ONE_ATMOSPHERE
	siemens_coefficient = 0.5
	eyeprot = 1
