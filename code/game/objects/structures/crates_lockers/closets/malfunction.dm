
/obj/structure/closet/malf/suits
	desc = "It's a storage unit for operational gear."
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"

/obj/structure/closet/malf/suits/atoms_to_spawn()
	return list(
		/obj/item/weapon/tank/jetpack/void,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/head/helmet/space/nasavoid,
		/obj/item/clothing/suit/space/nasavoid,
		/obj/item/clothing/shoes/magboots/nasavoid,
		/obj/item/weapon/crowbar,
		/obj/item/weapon/cell,
		/obj/item/device/multitool,
	)
