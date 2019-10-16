/obj/structure/closet/secure_closet/captains
	name = "Captain's Locker"
	req_access = list(access_captain)
	icon_state = "capsecure1"
	icon_closed = "capsecure"
	icon_locked = "capsecure1"
	icon_opened = "capsecureopen"
	icon_broken = "capsecurebroken"
	icon_off = "capsecureoff"

/obj/structure/closet/secure_closet/captains/atoms_to_spawn()
	return list(
		pick(
			/obj/item/weapon/storage/backpack/captain,
			/obj/item/weapon/storage/backpack/satchel_cap,
			/obj/item/weapon/storage/backpack/messenger/com,
			),
		/obj/item/clothing/suit/captunic,
		/obj/item/clothing/suit/storage/capjacket,
		/obj/item/clothing/head/helmet/cap,
		/obj/item/clothing/under/rank/captain,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/weapon/cartridge/captain,
		/obj/item/clothing/head/helmet/tactical/swat,
		/obj/item/clothing/shoes/brown,
		/obj/item/device/radio/headset/heads/captain,
		/obj/item/clothing/gloves/captain,
		/obj/item/clothing/shoes/magboots/captain,
		/obj/item/weapon/gun/energy/gun,
		/obj/item/clothing/suit/armor/captain,
		/obj/item/weapon/melee/telebaton,
		/obj/item/clothing/under/dress/dress_cap,
		/obj/item/device/gps/secure,
		/obj/item/weapon/card/debit/preferred/department/elite/command,
	)


/obj/structure/closet/secure_closet/hop
	name = "Head of Personnel's Locker"
	req_access = list(access_hop)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_broken = "hopsecurebroken"
	icon_off = "hopsecureoff"

/obj/structure/closet/secure_closet/hop/atoms_to_spawn()
	return list(
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/clothing/suit/storage/Hop_Coat,
		/obj/item/clothing/head/helmet/hopcap,
		/obj/item/weapon/cartridge/hop,
		/obj/item/device/radio/headset/heads/hop,
		/obj/item/weapon/storage/box/ids = 2,
		/obj/item/weapon/gun/energy/gun,
		/obj/item/device/flash,
		/obj/item/device/gps/secure,
		/obj/item/weapon/card/debit/preferred/department/civilian,
	)

/obj/structure/closet/secure_closet/hop2
	name = "Head of Personnel's Attire"
	req_access = list(access_hop)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_broken = "hopsecurebroken"
	icon_off = "hopsecureoff"

/obj/structure/closet/secure_closet/hop2/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/head_of_personnel,
		/obj/item/clothing/under/dress/dress_hop,
		/obj/item/clothing/under/dress/dress_hr,
		/obj/item/clothing/under/lawyer/female,
		/obj/item/clothing/under/lawyer/black,
		/obj/item/clothing/under/lawyer/red,
		/obj/item/clothing/under/lawyer/oldman,
		/obj/item/clothing/shoes/brown,
		/obj/item/clothing/shoes/black,
		/obj/item/clothing/shoes/leather,
		/obj/item/clothing/shoes/white,
	)


//The securitygear box can be found at 'code/game/objects/items/weapons/storage/boxes' and it contains one of each:
//sec belt, sec headset, sps, flash, flashbang, boot knife holster, tactical flashlight, sechud, black gloves, stunbaton, taser, pepperspray, sec tape, and hailer.
/obj/structure/closet/secure_closet/hos
	name = "Head of Security's Locker"
	req_access = list(access_hos)
	icon_state = "hossecure1"
	icon_closed = "hossecure"
	icon_locked = "hossecure1"
	icon_opened = "hossecureopen"
	icon_broken = "hossecurebroken"
	icon_off = "hossecureoff"

/obj/structure/closet/secure_closet/hos/atoms_to_spawn()
	return list(
		pick(
			/obj/item/weapon/storage/backpack/security,
			/obj/item/weapon/storage/backpack/satchel_sec,
			/obj/item/weapon/storage/backpack/messenger/sec,
		),
		/obj/item/clothing/head/helmet/tactical/HoS,
		/obj/item/clothing/under/rank/head_of_security/jensen,
		pick(
			/obj/item/clothing/suit/armor/hos/jensen,
			/obj/item/clothing/suit/armor/hos/sundowner),
		/obj/item/clothing/suit/armor/hos,
		/obj/item/clothing/head/helmet/tactical/HoS/dermal,
		/obj/item/weapon/cartridge/hos,
		/obj/item/device/detective_scanner,
		/obj/item/device/radio/headset/heads/hos,
		/obj/item/weapon/shield/riot,
		/obj/item/weapon/storage/lockbox/loyalty,
		/obj/item/weapon/storage/box/flashbangs,
		/obj/item/weapon/storage/lockbox/lawgiver/with_magazine,
		/obj/item/clothing/accessory/holster/handgun/waist,
		/obj/item/weapon/melee/telebaton,
		/obj/item/weapon/card/debit/preferred/department/security,
		/obj/item/weapon/pinpointer,
		/obj/item/weapon/storage/box/large/securitygear,
	)

/obj/structure/closet/secure_closet/warden
	name = "Warden's Locker"
	req_access = list(access_armory)
	icon_state = "wardensecure1"
	icon_closed = "wardensecure"
	icon_locked = "wardensecure1"
	icon_opened = "wardensecureopen"
	icon_broken = "wardensecurebroken"
	icon_off = "wardensecureoff"


/obj/structure/closet/secure_closet/warden/atoms_to_spawn()
	return list(
		pick(
			/obj/item/weapon/storage/backpack/security,
			/obj/item/weapon/storage/backpack/satchel_sec,
			/obj/item/weapon/storage/backpack/messenger/sec,
			),
		/obj/item/clothing/under/rank/warden,
		/obj/item/clothing/suit/armor/vest/warden,
		/obj/item/clothing/head/helmet/tactical/warden,
		/obj/item/weapon/storage/box/flashbangs,
		/obj/item/weapon/storage/box/bolas,
		/obj/item/weapon/batteringram,
		/obj/item/weapon/storage/box/large/securitygear,
	)

/obj/structure/closet/secure_closet/security
	name = "Security Officer's Locker"
	req_access = list(access_security)
	icon_state = "sec1"
	icon_closed = "sec"
	icon_locked = "sec1"
	icon_opened = "secopen"
	icon_broken = "secbroken"
	icon_off = "secoff"

/obj/structure/closet/secure_closet/security/atoms_to_spawn()
	return list(
		pick(
			/obj/item/weapon/storage/backpack/security,
			/obj/item/weapon/storage/backpack/satchel_sec,
			/obj/item/weapon/storage/backpack/messenger/sec,
			),
		/obj/item/clothing/suit/armor/vest/security,
		/obj/item/clothing/head/helmet/tactical/sec/preattached,
		/obj/item/weapon/storage/box/large/securitygear,
	)


/obj/structure/closet/secure_closet/security/cargo

/obj/structure/closet/secure_closet/security/cargo/atoms_to_spawn()
	return ..() + list(
		/obj/item/clothing/accessory/armband/cargo,
		/obj/item/device/encryptionkey/headset_cargo,
	)

/obj/structure/closet/secure_closet/security/engine

/obj/structure/closet/secure_closet/security/engine/atoms_to_spawn()
	return ..() + list(
		/obj/item/clothing/accessory/armband/engine,
		/obj/item/device/encryptionkey/headset_eng,
	)

/obj/structure/closet/secure_closet/security/science

/obj/structure/closet/secure_closet/security/science/atoms_to_spawn()
	return ..() + list(
		/obj/item/clothing/accessory/armband/science,
		/obj/item/device/encryptionkey/headset_sci,
	)

/obj/structure/closet/secure_closet/security/med

/obj/structure/closet/secure_closet/security/med/atoms_to_spawn()
	return ..() + list(
		/obj/item/clothing/accessory/armband/medgreen,
		/obj/item/device/encryptionkey/headset_med,
	)


//The detectivegear box can be found at at the same location as the securitygear box and it contains:
//sec headset, sec hud, black gloves, sps, 2x .38 ammoboxes, speedloader, evidence bag box, scanner, binoculars, and a hand TV set.
/obj/structure/closet/secure_closet/detective
	name = "Detective's Cabinet"
	req_access = list(access_forensics_lockers)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"

/obj/structure/closet/secure_closet/detective/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/det,
		/obj/item/clothing/under/det/noir,
		/obj/item/clothing/suit/storage/det_suit,
		/obj/item/clothing/suit/storage/det_suit/noir,
		/obj/item/clothing/suit/storage/forensics/blue,
		/obj/item/clothing/suit/storage/forensics/red,
		/obj/item/clothing/head/det_hat,
		/obj/item/clothing/head/det_hat/noir,
		/obj/item/clothing/shoes/brown,
		/obj/item/clothing/shoes/laceup,
		/obj/item/clothing/suit/armor/det_suit,
		/obj/item/clothing/accessory/holster/handgun/wornout,
		/obj/item/weapon/gun/projectile/detective,
		/obj/item/weapon/storage/box/large/detectivegear,
	)

/obj/structure/closet/secure_closet/detective/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

/obj/structure/closet/secure_closet/injection
	name = "Lethal Injections"
	req_access = list(access_captain)

/obj/structure/closet/secure_closet/injection/atoms_to_spawn()
	return list(
		/obj/item/weapon/reagent_containers/syringe/giant/chloral = 2,
	)


/obj/structure/closet/secure_closet/brig
	name = "Brig Locker"
	req_access = list(access_brig)
	anchored = 1
	var/id_tag = null

/obj/structure/closet/secure_closet/brig/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/color/prisoner,
		/obj/item/clothing/shoes/orange,
	)

/obj/structure/closet/secure_closet/brig/New()
	..()
	brig_lockers.Add(src)

/obj/structure/closet/secure_closet/brig/Destroy()
	brig_lockers.Remove(src)
	..()



/obj/structure/closet/secure_closet/courtroom
	name = "Courtroom Locker"
	req_access = list(access_court)

/obj/structure/closet/secure_closet/courtroom/atoms_to_spawn()
	return list(
		/obj/item/clothing/shoes/brown,
		/obj/item/weapon/paper/Court = 3,
		/obj/item/weapon/pen,
		/obj/item/clothing/suit/judgerobe,
		/obj/item/clothing/head/powdered_wig,
		/obj/item/weapon/storage/briefcase,
	)


/obj/structure/closet/secure_closet/wall
	name = "wall locker"
	req_access = list(access_security)
	icon_state = "wall-locker1"
	density = 1
	icon_closed = "wall-locker"
	icon_locked = "wall-locker1"
	icon_opened = "wall-lockeropen"
	icon_broken = "wall-lockerbroken"
	icon_off = "wall-lockeroff"

	//too small to put a man in
	large = 0

/obj/structure/closet/secure_closet/wall/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened
