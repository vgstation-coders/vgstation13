/obj/structure/closet/secure_closet/engineering_chief
	name = "\improper Chief Engineer's locker"
	req_access = list(access_ce)
	icon_state = "securece1"
	icon_closed = "securece"
	icon_locked = "securece1"
	icon_opened = "secureceopen"
	icon_broken = "securecebroken"
	icon_off = "secureceoff"

/obj/structure/closet/secure_closet/engineering_chief/atoms_to_spawn()
	return list(
		pick(
			/obj/item/weapon/storage/backpack/industrial,
			/obj/item/weapon/storage/backpack/satchel_eng,
			/obj/item/weapon/storage/backpack/messenger/engi,
			),
		/obj/item/blueprints/primary,
		/obj/item/clothing/under/rank/chief_engineer,
		/obj/item/clothing/head/hardhat/white,
		/obj/item/clothing/head/welding,
		/obj/item/clothing/gloves/yellow,
		/obj/item/clothing/shoes/workboots,
		/obj/item/weapon/cartridge/ce,
		/obj/item/device/radio/headset/heads/ce,
		/obj/item/weapon/storage/box/inflatables,
		/obj/item/weapon/inflatable_dispenser,
		/obj/item/weapon/storage/toolbox/mechanical,
		/obj/item/device/t_scanner/advanced,
		/obj/item/device/device_analyser/advanced,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/mask/gas,
		/obj/item/device/multitool,
		/obj/item/device/flash,
		/obj/item/device/gps/engineering,
		/obj/item/weapon/storage/belt/utility/chief,
		/obj/item/clothing/glasses/scanner/material,
		/obj/item/weapon/card/debit/preferred/department/engineering,
	)

/obj/structure/closet/secure_closet/engineering_electrical
	name = "electrical supplies locker"
	req_access = list(access_engine_equip)
	icon_state = "secureengelec1"
	icon_closed = "secureengelec"
	icon_locked = "secureengelec1"
	icon_opened = "toolclosetopen"
	icon_broken = "secureengelecbroken"
	icon_off = "secureengelecoff"

/obj/structure/closet/secure_closet/engineering_electrical/atoms_to_spawn()
	return list(
		/obj/item/weapon/storage/toolbox/electrical = 3,
		/obj/item/weapon/rcl,
		/obj/item/weapon/circuitboard/power_control = 3,
		/obj/item/clothing/gloves/yellow = 2,
		/obj/item/device/multitool = 3,
	)

/obj/structure/closet/secure_closet/engineering_welding
	name = "welding supplies locker"
	req_access = list(access_engine_equip)
	icon_state = "secureengweld1"
	icon_closed = "secureengweld"
	icon_locked = "secureengweld1"
	icon_opened = "toolclosetopen"
	icon_broken = "secureengweldbroken"
	icon_off = "secureengweldoff"

/obj/structure/closet/secure_closet/engineering_welding/atoms_to_spawn()
	return list(
		/obj/item/clothing/head/welding = 3,
		/obj/item/weapon/weldingtool/largetank = 3,
	)

/obj/structure/closet/secure_closet/engineering_personal
	name = "\improper Engineer's locker"
	req_access = list(access_engine_equip)
	icon_state = "secureeng1"
	icon_closed = "secureeng"
	icon_locked = "secureeng1"
	icon_opened = "secureengopen"
	icon_broken = "secureengbroken"
	icon_off = "secureengoff"

/obj/structure/closet/secure_closet/engineering_personal/atoms_to_spawn()
	return list(
		pick(
			/obj/item/weapon/storage/backpack/industrial,
			/obj/item/weapon/storage/backpack/satchel_eng,
			/obj/item/weapon/storage/backpack/messenger/engi,
			),
		/obj/item/clothing/under/rank/engineer,
		/obj/item/clothing/shoes/workboots,
		/obj/item/weapon/storage/box/inflatables,
		/obj/item/weapon/storage/toolbox/mechanical,
		/obj/item/device/radio/headset/headset_eng,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/mask/gas,
		pick(
			/obj/item/clothing/glasses/scanner/meson/prescription,
			/obj/item/clothing/glasses/scanner/meson),
		/obj/item/taperoll/engineering,
		/obj/item/taperoll/engineering,
		/obj/item/device/gps/engineering,
		/obj/item/clothing/glasses/scanner/material,
	)

/obj/structure/closet/secure_closet/engineering_atmos
	name = "\improper Atmospheric Technician's locker"
	req_access = list(access_atmospherics)
	icon_state = "secureatmos1"
	icon_closed = "secureatmos"
	icon_locked = "secureatmos1"
	icon_opened = "secureatmosopen"
	icon_broken = "secureatmosbroken"
	icon_off = "secureatmosoff"

/obj/structure/closet/secure_closet/engineering_atmos/atoms_to_spawn()
	return list(
		pick(
			/obj/item/weapon/storage/backpack/industrial,
			/obj/item/weapon/storage/backpack/satchel_eng,
			/obj/item/weapon/storage/backpack/messenger/engi,
			),
		/obj/item/clothing/under/rank/atmospheric_technician,
		/obj/item/clothing/shoes/workboots,
		/obj/item/weapon/storage/box/inflatables,
		/obj/item/weapon/storage/toolbox/mechanical,
		/obj/item/weapon/extinguisher/foam,
		/obj/item/device/radio/headset/headset_eng,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/mask/gas,
		/obj/item/taperoll/atmos,
		/obj/item/pipe_planner,
		/obj/item/weapon/wrench/socket,
		/obj/item/weapon/gun/projectile/flare,
		/obj/item/ammo_storage/box/flare,
		/obj/item/device/rcd/rpd,
		/obj/item/device/analyzer,
		/obj/item/clothing/glasses/scanner/material,
		/obj/item/device/gps/engineering,
	)

/obj/structure/closet/secure_closet/engineering_mechanic
	name = "\improper Mechanic's locker"
	req_access = list(access_mechanic)
	icon_state = "securemechni1"
	icon_closed = "securemechni"
	icon_locked = "securemechni1"
	icon_opened = "securemechniopen"
	icon_broken = "securemechnibroken"
	icon_off = "securemechnioff"

/obj/structure/closet/secure_closet/engineering_mechanic/atoms_to_spawn()
	return list(
		pick(
			/obj/item/weapon/storage/backpack/industrial,
			/obj/item/weapon/storage/backpack/satchel_eng,
			/obj/item/weapon/storage/backpack/messenger/engi,
			),
		/obj/item/clothing/under/rank/mechanic,
		/obj/item/clothing/shoes/workboots,
		/obj/item/weapon/storage/toolbox/mechanical,
		/obj/item/device/radio/headset/headset_engsci,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/device/device_analyser,
		/obj/item/weapon/soap/nanotrasen,
		/obj/item/clothing/gloves/black,
		/obj/item/device/assembly_frame = 2,
		pick(
			/obj/item/clothing/head/welding,
			/obj/item/clothing/glasses/welding),
	)

/obj/structure/closet/secure_closet/engineering_general
	name = "engineering locker"
	req_access = list(access_engine_equip)
	icon_state = "secureeng1"
	icon_closed = "secureeng"
	icon_locked = "secureeng1"
	icon_opened = "secureengopen"
	icon_broken = "secureengbroken"
	icon_off = "secureengoff"

/obj/structure/closet/crate/secure/large/reinforced/shard
	name = "supermatter shard crate"
	req_access = list(access_engine_equip)
	var/payload = /obj/machinery/power/supermatter/shard
	var/mapping_idtag

/obj/structure/closet/crate/secure/large/reinforced/shard/spawn_contents()
	if(payload)
		var/obj/machinery/power/supermatter/S = new payload(src)
		if(mapping_idtag && istype(S))
			S.id_tag = mapping_idtag

/obj/structure/closet/crate/secure/large/reinforced/shard/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover,/obj/machinery/power/supermatter))
		return 1
	. = ..()

/obj/structure/closet/crate/secure/large/reinforced/shard/can_close()
	for(var/obj/machinery/power/supermatter/S in loc)
		if(S.damage) //This is what I like to call predicting the metagame
			return 0
	return ..()


/obj/structure/closet/crate/secure/large/reinforced/shard/crystal
	name = "supermatter crystal crate"
	payload = /obj/machinery/power/supermatter

/obj/structure/closet/crate/secure/large/reinforced/shard/empty
	payload = null
