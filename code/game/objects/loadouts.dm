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
