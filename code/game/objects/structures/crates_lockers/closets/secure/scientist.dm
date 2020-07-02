/obj/structure/closet/secure_closet/scientist
	name = "Scientist's Locker"
	req_access = list(access_tox_storage)
	icon_state = "secureres1"
	icon_closed = "secureres"
	icon_locked = "secureres1"
	icon_opened = "secureresopen"
	icon_broken = "secureresbroken"
	icon_off = "secureresoff"

/obj/structure/closet/secure_closet/scientist/atoms_to_spawn()
	return list(
		pick(
			/obj/item/weapon/storage/backpack/satchel_tox,
			/obj/item/weapon/storage/backpack/messenger/tox,
			),
		/obj/item/clothing/under/rank/scientist,
		/obj/item/clothing/suit/storage/labcoat/science,
		/obj/item/clothing/shoes/white,
		/obj/item/device/radio/headset/headset_sci,
		/obj/item/weapon/tank/air,
		/obj/item/clothing/mask/gas,
	)


/obj/structure/closet/secure_closet/RD
	name = "Research Director's Locker"
	req_access = list(access_rd)
	icon_state = "rdsecure1"
	icon_closed = "rdsecure"
	icon_locked = "rdsecure1"
	icon_opened = "rdsecureopen"
	icon_broken = "rdsecurebroken"
	icon_off = "rdsecureoff"

/obj/structure/closet/secure_closet/RD/atoms_to_spawn()
	return list(
		/obj/item/clothing/head/bio_hood/scientist,
		/obj/item/clothing/suit/bio_suit/scientist,
		/obj/item/clothing/under/rank/research_director,
		/obj/item/clothing/under/dress/dress_rd,
		/obj/item/clothing/suit/storage/labcoat/rd,
		/obj/item/weapon/cartridge/rd,
		/obj/item/clothing/shoes/white,
		/obj/item/clothing/gloves/latex,
		/obj/item/device/radio/headset/heads/rd,
		/obj/item/weapon/tank/air,
		/obj/item/clothing/mask/gas,
		/obj/item/device/flash,
		/obj/item/weapon/switchtool/holo,
		/obj/item/weapon/card/debit/preferred/department/science,
	)
