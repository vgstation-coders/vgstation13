/obj/structure/closet/secure_closet/cargotech
	name = "Cargo Technician's Locker"
	req_access = list(access_cargo)
	icon_state = "securecargo1"
	icon_closed = "securecargo"
	icon_locked = "securecargo1"
	icon_opened = "securecargoopen"
	icon_broken = "securecargobroken"
	icon_off = "securecargooff"

/obj/structure/closet/secure_closet/cargotech/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/cargotech,
		/obj/item/clothing/shoes/black,
		/obj/item/device/radio/headset/headset_cargo,
		/obj/item/clothing/gloves/black,
		/obj/item/clothing/head/soft,
	)

/obj/structure/closet/secure_closet/quartermaster
	name = "Quartermaster's Locker"
	req_access = list(access_qm)
	icon_state = "secureqm1"
	icon_closed = "secureqm"
	icon_locked = "secureqm1"
	icon_opened = "secureqmopen"
	icon_broken = "secureqmbroken"
	icon_off = "secureqmoff"

/obj/structure/closet/secure_closet/quartermaster/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/cargo,
		/obj/item/clothing/shoes/brown,
		/obj/item/device/radio/headset/headset_cargo,
		/obj/item/clothing/gloves/black,
		/obj/item/clothing/suit/fire/firefighter,
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/glasses/scanner/meson,
		/obj/item/clothing/head/soft,
		/obj/item/weapon/card/debit/preferred/department/cargo,
	)
