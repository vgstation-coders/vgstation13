/obj/item/binoculars/telescope
	name = "telescope"
	icon_state = "telescope"
	item_state = "telescope"

/obj/machinery/suit_storage_unit/pirate
	suit_type = /obj/item/clothing/suit/space
	helmet_type = /obj/item/clothing/head/helmet/space
	mask_type = /obj/item/clothing/mask/breath
	boot_type = /obj/item/clothing/shoes/magboots

/obj/item/weapon/card/id/pirate_captain
	name = "pirate captains ID card"
	desc = "A mis-interpretation of the ID system, where it has been used as a punchcard for some consoles."
	access = list(access_pirate)
	base_access = list(access_pirate)

/obj/machinery/computer/shuttle_control/pirate
	icon_state = "syndishuttle"
	req_access = list(access_pirate)
	machine_flags = 0
	allow_silicons = 0
	light_color = LIGHT_COLOR_RED