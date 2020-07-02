/obj/structure/closet/secure_closet/medical1
	name = "Medicine Closet"
	desc = "Filled with medical junk."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
	req_access = list(access_medical)


/obj/structure/closet/secure_closet/medical1/atoms_to_spawn()
	return list(
		/obj/item/weapon/storage/box/syringes,
		/obj/item/weapon/reagent_containers/dropper = 2,
		/obj/item/weapon/reagent_containers/glass/beaker = 2,
		/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline = 2,
		/obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 2,
	)


/obj/structure/closet/secure_closet/medical2
	name = "Anesthetic"
	desc = "Used to knock people out."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
	req_access = list(access_surgery)


/obj/structure/closet/secure_closet/medical2/atoms_to_spawn()
	return list(
		/obj/item/weapon/tank/anesthetic = 3,
		/obj/item/clothing/mask/breath/medical = 3,
	)



/obj/structure/closet/secure_closet/medical3
	name = "Medical Doctor's Locker"
	req_access = list(access_surgery)
	icon_state = "securemed1"
	icon_closed = "securemed"
	icon_locked = "securemed1"
	icon_opened = "securemedopen"
	icon_broken = "securemedbroken"
	icon_off = "securemedoff"

/obj/structure/closet/secure_closet/medical3/atoms_to_spawn()
	. = list(
		/obj/item/clothing/monkeyclothes/doctor = 2,
		pick(
			/obj/item/weapon/storage/backpack/medic,
			/obj/item/weapon/storage/backpack/satchel_med,
			/obj/item/weapon/storage/backpack/messenger/med,),
		/obj/item/clothing/under/rank/nursesuit,
		/obj/item/clothing/head/nursehat,
	)
	switch(pick("blue", "green", "purple"))
		if ("blue")
			. += /obj/item/clothing/under/rank/medical/blue
			. += /obj/item/clothing/head/surgery/blue
		if ("green")
			. += /obj/item/clothing/under/rank/medical/green
			. += /obj/item/clothing/head/surgery/green
		if ("purple")
			. += /obj/item/clothing/under/rank/medical/purple
			. += /obj/item/clothing/head/surgery/purple
	switch(pick("blue", "green", "purple"))
		if ("blue")
			. += /obj/item/clothing/under/rank/medical/blue
			. += /obj/item/clothing/head/surgery/blue
		if ("green")
			. += /obj/item/clothing/under/rank/medical/green
			. += /obj/item/clothing/head/surgery/green
		if ("purple")
			. += /obj/item/clothing/under/rank/medical/purple
			. += /obj/item/clothing/head/surgery/purple
	. += list(
		/obj/item/clothing/under/rank/medical,
		/obj/item/clothing/under/rank/nurse,
		/obj/item/clothing/under/rank/orderly,
		/obj/item/clothing/suit/storage/labcoat,
		/obj/item/clothing/suit/storage/fr_jacket,
		/obj/item/clothing/shoes/white,
		/obj/item/device/radio/headset/headset_med,
		/obj/item/weapon/storage/belt/medical,
		/obj/item/clothing/glasses/hud/health/prescription,
	)


/obj/structure/closet/secure_closet/CMO
	name = "Chief Medical Officer's Locker"
	req_access = list(access_cmo)
	icon_state = "cmosecure1"
	icon_closed = "cmosecure"
	icon_locked = "cmosecure1"
	icon_opened = "cmosecureopen"
	icon_broken = "cmosecurebroken"
	icon_off = "cmosecureoff"

/obj/structure/closet/secure_closet/CMO/atoms_to_spawn()
	. = list(
		pick(
			/obj/item/weapon/storage/backpack/medic,
			/obj/item/weapon/storage/backpack/satchel_med,
			/obj/item/weapon/storage/backpack/messenger/med),
		/obj/item/clothing/head/bio_hood/cmo,
		/obj/item/clothing/suit/bio_suit/cmo,
		/obj/item/clothing/shoes/white,
	)
	switch(pick("blue", "green", "purple"))
		if ("blue")
			. += /obj/item/clothing/under/rank/medical/blue
			. += /obj/item/clothing/head/surgery/blue
		if ("green")
			. += /obj/item/clothing/under/rank/medical/green
			. += /obj/item/clothing/head/surgery/green
		if ("purple")
			. += /obj/item/clothing/under/rank/medical/purple
			. += /obj/item/clothing/head/surgery/purple
	. += list(
		/obj/item/clothing/under/rank/chief_medical_officer,
		/obj/item/clothing/suit/storage/labcoat/cmo,
		/obj/item/weapon/cartridge/cmo,
		/obj/item/clothing/gloves/latex,
		/obj/item/clothing/shoes/brown,
		/obj/item/device/radio/headset/heads/cmo,
		/obj/item/weapon/storage/belt/medical,
		/obj/item/device/flash,
		/obj/item/weapon/reagent_containers/hypospray,
		/obj/item/weapon/card/debit/preferred/department/medical,
	)


/obj/structure/closet/secure_closet/animal
	name = "Animal Control"
	req_access = list(access_surgery)

/obj/structure/closet/secure_closet/animal/atoms_to_spawn()
	return list(
		/obj/item/device/assembly/signaler,
		/obj/item/device/radio/electropack = 3,
	)


/obj/structure/closet/secure_closet/chemical
	name = "Chemical Closet"
	desc = "Store dangerous chemicals in here."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
	req_access = list(access_chemistry)

/obj/structure/closet/secure_closet/chemical/atoms_to_spawn()
	return list(
		/obj/item/weapon/storage/fancy/vials,
		/obj/item/weapon/storage/box/pillbottles = 2,
		/obj/item/weapon/book/manual/chemistry_manual,
		/obj/item/weapon/reagent_containers/glass/jar/erlenmeyer = 2
	)

/obj/structure/closet/secure_closet/medical_wall
	name = "First Aid Closet"
	desc = "It's a secure wall-mounted storage unit for first aid supplies."
	icon_state = "medical_wall_locked"
	icon_closed = "medical_wall_unlocked"
	icon_locked = "medical_wall_locked"
	icon_opened = "medical_wall_open"
	icon_broken = "medical_wall_spark"
	icon_off = "medical_wall_off"
	anchored = 1
	density = FALSE
	wall_mounted = 1
	req_access = list(access_medical)

/obj/structure/closet/secure_closet/medical_wall/update_icon()
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

/obj/structure/closet/secure_closet/paramedic
	name = "Paramedic Gear"
	desc = "A locker with gear designed for use by paramedics, including an EVA suit."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
	req_access = list(access_paramedic)

/obj/structure/closet/secure_closet/paramedic/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/space/paramedic,
		/obj/item/clothing/head/helmet/space/paramedic,
		/obj/item/clothing/shoes/magboots/para,
		/obj/item/clothing/accessory/storage/webbing/paramed,
		/obj/item/weapon/storage/firstaid/internalbleed = 2,
	)
