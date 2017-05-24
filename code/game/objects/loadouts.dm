/obj/abstract/loadout
	var/list/items_to_spawn = list()

/obj/abstract/loadout/New(turf/T, var/mob/M)
	..(T)
	if(istype(M))
		equip_items(M)
	spawn(10)	//to allow its items to be manually spawned and accessed, for the purposes of obtaining references
		if(!gcDestroyed)
			get_items()
			qdel(src)

/obj/abstract/loadout/proc/get_items()
	. = spawn_items()
	qdel(src)

/obj/abstract/loadout/proc/equip_items(var/mob/M)
	M.unequip_everything()	//unequip everything before equipping loadout
	var/list/spawned_items = spawn_items()
	M.recursive_list_equip(spawned_items)
	qdel(src)

/obj/abstract/loadout/proc/spawn_items()
	var/list/to_return = list()
	for(var/T in items_to_spawn)
		if(ispath(T, /obj/item))
			var/obj/item/I = new T(loc)
			to_return.Add(I)
	return to_return


/obj/abstract/loadout/gemsuit
	items_to_spawn = list(/obj/item/clothing/head/helmet/space/rig/wizard,
						/obj/item/clothing/suit/space/rig/wizard,
						/obj/item/clothing/gloves/purple,
						/obj/item/clothing/shoes/sandal)

/obj/abstract/loadout/nazi_rigsuit
	items_to_spawn = list(/obj/item/clothing/head/helmet/space/rig/nazi,
						/obj/item/clothing/suit/space/rig/nazi)

/obj/abstract/loadout/soviet_rigsuit
	items_to_spawn = list(/obj/item/clothing/head/helmet/space/rig/soviet,
						/obj/item/clothing/suit/space/rig/soviet)

/obj/abstract/loadout/dredd_gear
	items_to_spawn = list(/obj/item/clothing/under/darkred,
						/obj/item/clothing/suit/armor/xcomsquaddie/dredd,
						/obj/item/clothing/glasses/hud/security,
						/obj/item/clothing/mask/gas/swat,
						/obj/item/clothing/head/helmet/dredd,
						/obj/item/clothing/gloves/combat,
						/obj/item/clothing/shoes/combat,
						/obj/item/weapon/storage/belt/security,
						/obj/item/weapon/gun/lawgiver)

/obj/abstract/loadout/standard_space_gear
	items_to_spawn = list(/obj/item/clothing/shoes/black,
						/obj/item/clothing/under/color/grey,
						/obj/item/clothing/suit/space,
						/obj/item/clothing/head/helmet/space,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/engineer_RIG
	items_to_spawn = list(/obj/item/clothing/suit/space/rig,
						/obj/item/clothing/head/helmet/space/rig,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/CE_RIG
	items_to_spawn = list(/obj/item/clothing/suit/space/rig/elite,
						/obj/item/clothing/head/helmet/space/rig/elite,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/mining_RIG
	items_to_spawn = list(/obj/item/clothing/suit/space/rig/mining,
						/obj/item/clothing/head/helmet/space/rig/mining,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/syndi_RIG
	items_to_spawn = list(/obj/item/clothing/suit/space/rig/syndi,
						/obj/item/clothing/head/helmet/space/rig/syndi,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/wizard_RIG
	items_to_spawn = list(/obj/item/clothing/suit/space/rig/wizard,
						/obj/item/clothing/head/helmet/space/rig/wizard,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/medical_RIG
	items_to_spawn = list(/obj/item/clothing/suit/space/rig/medical,
						/obj/item/clothing/head/helmet/space/rig/medical,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/atmos_RIG
	items_to_spawn = list(/obj/item/clothing/suit/space/rig/atmos,
						/obj/item/clothing/head/helmet/space/rig/atmos,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/tournament_standard_red
	items_to_spawn = list(/obj/item/clothing/under/color/red,
						/obj/item/clothing/shoes/black,
						/obj/item/clothing/suit/armor/vest,
						/obj/item/clothing/head/helmet/thunderdome,
						/obj/item/weapon/gun/energy/pulse_rifle/destroyer,
						/obj/item/weapon/kitchen/utensil/knife/large,
						/obj/item/weapon/grenade/smokebomb)

/obj/abstract/loadout/tournament_standard_green
	items_to_spawn = list(/obj/item/clothing/under/color/green,
						/obj/item/clothing/shoes/black,
						/obj/item/clothing/suit/armor/vest,
						/obj/item/clothing/head/helmet/thunderdome,
						/obj/item/weapon/gun/energy/pulse_rifle/destroyer,
						/obj/item/weapon/kitchen/utensil/knife/large,
						/obj/item/weapon/grenade/smokebomb)

/obj/abstract/loadout/tournament_gangster
	items_to_spawn = list(/obj/item/clothing/under/det,
						/obj/item/clothing/shoes/black,
						/obj/item/clothing/suit/storage/det_suit,
						/obj/item/clothing/glasses/thermal/monocle,
						/obj/item/clothing/head/det_hat,
						/obj/item/weapon/cloaking_device,
						/obj/item/weapon/gun/projectile,
						/obj/item/ammo_storage/box/a357)

/obj/abstract/loadout/tournament_chef
	items_to_spawn = list(/obj/item/clothing/under/rank/chef,
						/obj/item/clothing/suit/chef,
						/obj/item/clothing/shoes/black,
						/obj/item/clothing/head/chefhat,
						/obj/item/weapon/kitchen/rollingpin,
						/obj/item/weapon/kitchen/utensil/knife/large,
						/obj/item/weapon/kitchen/utensil/knife/large,
						/obj/item/weapon/kitchen/utensil/knife/large)
/*
/obj/abstract/loadout/tournament_janitor
	items_to_spawn = list(/obj/item/clothing/under/rank/janitor,
						/obj/item/clothing/shoes/black,
						/obj/item/weapon/storage/backpack,
						/obj/item/weapon/mop,
						/obj/item/weapon/reagent_containers/glass/bucket,
						)

/obj/abstract/loadout/
	items_to_spawn = list(,
						)

/obj/abstract/loadout/
	items_to_spawn = list(,
						)

/obj/abstract/loadout/
	items_to_spawn = list(,
						)

/obj/abstract/loadout/
	items_to_spawn = list(,
						)
*/