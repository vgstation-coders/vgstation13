/* Closets for specific jobs
 * Contains:
 *		Bartender
 *		Janitor
 *		Lawyer
 */

/*
 * Bartender
 */
/obj/structure/closet/gmcloset
	name = "formal closet"
	desc = "It's a storage unit for formal clothing."
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/gmcloset/atoms_to_spawn()
	return list(
		/obj/item/clothing/head/that = 2,
		/obj/item/clothing/head/hairflower,
		/obj/item/clothing/under/sl_suit = 2,
		/obj/item/clothing/under/rank/bartender = 2,
		/obj/item/clothing/under/rank/btc_bartender = 2,
		/obj/item/clothing/under/dress/dress_saloon,
		/obj/item/clothing/suit/wcoat = 2,
		/obj/item/clothing/shoes/black = 2,
		/obj/item/clothing/shoes/purplepumps = 2,
		/obj/item/clothing/monkeyclothes = 2,
		/obj/item/weapon/reagent_containers/food/drinks/coloring,
	)

/*
 * Janitor
 */
/obj/structure/closet/jcloset
	name = "custodial closet"
	desc = "It's a storage unit for janitorial clothes and gear."
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/jcloset/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/janitor,
		/obj/item/weapon/cartridge/janitor,
		/obj/item/device/flashlight,
		/obj/item/clothing/shoes/galoshes,
		/obj/item/weapon/caution = 6,
		/obj/item/weapon/storage/bag/trash,
		/obj/item/device/lightreplacer/loaded/mixed,
		/obj/item/clothing/gloves/black,
		/obj/item/clothing/head/soft/purple,
		/obj/item/weapon/storage/box/lights/he = 2,
		/obj/item/weapon/storage/belt/janitor,
	)

/*
 * Lawyer
 */
/obj/structure/closet/lawcloset
	name = "legal closet"
	desc = "It's a storage unit for courtroom apparel and items."
	icon_state = "blue"
	icon_closed = "blue"

/obj/structure/closet/lawcloset/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/cia,
		/obj/item/clothing/under/lawyer/female,
		/obj/item/clothing/under/lawyer/black,
		/obj/item/clothing/under/lawyer/red,
		/obj/item/clothing/under/lawyer/bluesuit,
		/obj/item/clothing/suit/storage/lawyer/bluejacket,
		/obj/item/clothing/under/lawyer/purpsuit,
		/obj/item/clothing/suit/storage/lawyer/purpjacket,
		/obj/item/clothing/shoes/brown,
		/obj/item/clothing/shoes/black,
	)

/obj/structure/closet/paramedic
	name = "Paramedic Wardrobe"
	desc = "It's a storage unit for paramedic equipment."
	icon_state = "blue"
	icon_closed = "blue"


/obj/structure/closet/paramedic/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/medical/paramedic = 2,
		/obj/item/device/radio/headset/headset_med = 2,
		/obj/item/clothing/head/soft/paramedic = 2,
		/obj/item/clothing/gloves/latex = 2,
		/obj/item/clothing/shoes/black = 2,
		/obj/item/clothing/suit/storage/paramedic = 2,
		/obj/item/weapon/storage/box/inflatables = 2,
		/obj/item/weapon/tank/emergency_oxygen/engi = 2,
		/obj/item/device/gps/paramedic = 2,
	)
