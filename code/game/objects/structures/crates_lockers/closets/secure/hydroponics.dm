/obj/structure/closet/secure_closet/hydroponics
	name = "Botanist's locker"
	req_access = list(access_hydroponics)
	icon_state = "hydrosecure1"
	icon_closed = "hydrosecure"
	icon_locked = "hydrosecure1"
	icon_opened = "hydrosecureopen"
	icon_broken = "hydrosecurebroken"
	icon_off = "hydrosecureoff"


/obj/structure/closet/secure_closet/hydroponics/atoms_to_spawn()
	return list(
		pick(
			/obj/item/clothing/suit/apron,
			/obj/item/clothing/suit/apron/overalls),
		/obj/item/weapon/storage/bag/plants,
		pick(
			/obj/item/weapon/storage/backpack/satchel_hyd,
			/obj/item/weapon/storage/backpack/messenger/hyd,
			),
		pick(
			/obj/item/clothing/under/rank/hydroponics,
			/obj/item/clothing/under/rank/botany,
		),
		/obj/item/device/analyzer/plant_analyzer,
		/obj/item/clothing/head/greenbandana,
		/obj/item/weapon/minihoe,
		/obj/item/weapon/hatchet,
		/obj/item/weapon/bee_net,
	)
