/obj/structure/closet/syndicate
	name = "armory closet"
	desc = "Why is this here?"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"


/obj/structure/closet/syndicate/personal
	desc = "It's a storage unit for operative gear."

/obj/structure/closet/syndicate/personal/atoms_to_spawn()
	return list(
		/obj/item/weapon/tank/jetpack/oxygen/nukeops,
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/head/helmet/space/rig/syndi,
		/obj/item/clothing/suit/space/rig/syndi,
		/obj/item/weapon/cell/high,
		/obj/item/device/pda/syndicate/door,
		/obj/item/weapon/pinpointer/nukeop,
		/obj/item/weapon/shield/energy,
		/obj/item/clothing/shoes/magboots/syndie,
		/obj/item/weapon/storage/bag/ammo_pouch,
		/obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical,
		/obj/item/clothing/accessory/holster/handgun/waist,
		/obj/item/clothing/accessory/storage/bandolier,
	)

/obj/structure/closet/syndicate/nuclear
	desc = "It's a storage unit for nuclear-operative gear."

/obj/structure/closet/syndicate/nuclear/atoms_to_spawn()
	return list(
		/obj/item/ammo_storage/magazine/a12mm/ops = 5,
		/obj/item/weapon/storage/box/handcuffs,
		/obj/item/weapon/storage/box/flashbangs,
		/obj/item/weapon/storage/box/emps,
		/obj/item/weapon/gun/energy/gun = 5,
		/obj/item/device/pda/syndicate,
		/obj/item/device/radio/uplink/nukeops,
	)

/obj/structure/closet/syndicate/resources
	desc = "An old, dusty locker."

/obj/structure/closet/syndicate/resources/spawn_contents()
	..()
	var/common_min = 30 //Minimum amount of minerals in the stack for common minerals
	var/common_max = 50 //Maximum amount of HONK in the stack for HONK common minerals
	var/rare_min = 5  //Minimum HONK of HONK in the stack HONK HONK rare minerals
	var/rare_max = 20 //Maximum HONK HONK HONK in the HONK for HONK rare HONK

	var/pickednum = rand(1, 50)

	//Sad trombone
	if(pickednum == 1)
		var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(src)
		P.name = "IOU"
		P.info = "Sorry man, we needed the money so we sold your stash. It's ok, we'll double our money for sure this time!"

	//Metal (common ore)
	if(pickednum >= 2)
		var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
		M.amount = rand(common_min, common_max)

	//Glass (common ore)
	if(pickednum >= 5)
		new /obj/item/stack/sheet/glass/glass(src, rand(common_min, common_max))

	//Plasteel (common ore) Because it has a million more uses then plasma
	if(pickednum >= 10)
		new /obj/item/stack/sheet/plasteel(src, rand(common_min, common_max))

	//Plasma (rare ore)
	if(pickednum >= 15)
		new /obj/item/stack/sheet/mineral/plasma(src, rand(rare_min, rare_max))

	//Silver (rare ore)
	if(pickednum >= 20)
		new /obj/item/stack/sheet/mineral/silver(src, rand(rare_min, rare_max))

	//Gold (rare ore)
	if(pickednum >= 30)
		new /obj/item/stack/sheet/mineral/gold(src, rand(rare_min, rare_max))

	//Uranium (rare ore)
	if(pickednum >= 40)
		new /obj/item/stack/sheet/mineral/uranium(src, rand(rare_min, rare_max))

	//Diamond (rare HONK)
	if(pickednum >= 45)
		new /obj/item/stack/sheet/mineral/diamond(src, rand(rare_min, rare_max))

	//Jetpack (You hit the jackpot!)
	if(pickednum == 50)
		new /obj/item/weapon/tank/jetpack/carbondioxide(src)

/obj/structure/closet/syndicate/resources/everything
	desc = "It's an emergency storage closet for repairs."

/obj/structure/closet/syndicate/resources/everything/spawn_contents()
	var/list/resources = list(
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/glass/glass,
		/obj/item/stack/sheet/mineral/gold,
		/obj/item/stack/sheet/mineral/silver,
		/obj/item/stack/sheet/mineral/plasma,
		/obj/item/stack/sheet/mineral/uranium,
		/obj/item/stack/sheet/mineral/diamond,
		/obj/item/stack/sheet/mineral/clown,
		/obj/item/stack/sheet/plasteel,
		/obj/item/stack/rods,
	)

	for(var/i = 0, i<2, i++)
		for(var/res in resources)
			var/obj/item/stack/R = new res(src)
			R.amount = R.max_amount

/obj/structure/closet/vox_raiders
	name = "vox armory closet"
	desc = "Polly wants a gun."
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"

/obj/structure/closet/vox_raiders/atoms_to_spawn()
	return list(
		/obj/item/clothing/head/helmet/space/vox/pressure,
		/obj/item/clothing/mask/breath/vox,
		/obj/item/clothing/shoes/magboots/vox,
		/obj/item/clothing/suit/space/vox/pressure,
		/obj/item/clothing/under/vox/vox_casual,
		/obj/item/weapon/tank/jetpack/nitrogen,
	)


/obj/structure/closet/vox_raiders/trader
	name = "vox armory closet"
	desc = "Polly wants a gun."
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"

/obj/structure/closet/vox_raiders/trader/atoms_to_spawn()
	return list(
		/obj/abstract/map/spawner/space/vox/trader/spacesuit,
		/obj/item/clothing/mask/breath/vox,
		/obj/item/clothing/shoes/magboots/vox,
		/obj/item/clothing/under/vox/vox_casual,
		/obj/item/weapon/tank/jetpack/nitrogen,
		/obj/item/clothing/suit/space/vox/civ/mushmen,
		/obj/item/clothing/head/helmet/space/vox/civ/mushmen,
	)
