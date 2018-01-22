
/obj/item/weapon/robot_module/mommi
	name = "mobile mmi robot module"
	languages = list()
	no_slip = TRUE
	sprites = list(
		"Basic" = "mommi"
		)
	var/ae_type = "Default" //Anti-emancipation override type, pretty much just fluffy.

/obj/item/weapon/robot_module/mommi/New(var/mob/living/silicon/robot/R)
	..()

	modules += new /obj/item/weapon/weldingtool/largetank(src)
	modules += new /obj/item/weapon/screwdriver(src)
	modules += new /obj/item/weapon/wrench(src)
	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/weapon/wirecutters(src)
	modules += new /obj/item/device/multitool(src)
	modules += new /obj/item/device/t_scanner(src)
	modules += new /obj/item/device/analyzer(src)
	modules += new /obj/item/weapon/extinguisher(src)
	modules += new /obj/item/weapon/extinguisher/foam(src)
	modules += new /obj/item/device/rcd/rpd(src)
	modules += new /obj/item/device/rcd/tile_painter(src)
	modules += new /obj/item/blueprints/mommiprints(src)
	modules += new /obj/item/device/material_synth/robot/mommi(src)
	modules += new /obj/item/device/holomap(src)
	modules += new /obj/item/device/station_map(src)
	modules += new /obj/item/device/silicate_sprayer(src)
	var/obj/item/stack/cable_coil/W = new /obj/item/stack/cable_coil(src)
	W.amount = 50
	W.max_amount = 50 //Override MAXCOIL
	modules += W
	emag = new /obj/item/borg/stun(src)

	sensor_augs = list("Mesons", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/mommi/respawn_consumable(var/mob/living/silicon/robot/R)
	var/list/what = list (/obj/item/stack/cable_coil)
	for(var/T in what)
		if(!(locate(T) in modules))
			modules -= null
			var/O = new T(src)
			if(istype(O,/obj/item/stack/cable_coil))
				O:max_amount = 50
			modules += O
			O:amount = 1

//Nanotrasen's MoMMI
/obj/item/weapon/robot_module/mommi/nt
	name = "nanotrasen mobile mmi robot module"
	networks = list(CAMERANET_ENGI)
	radio_key = /obj/item/device/encryptionkey/headset_eng
	ae_type = "Nanotrasen patented"
	sprites = list(
		"Basic" = "mommi",
		"Keeper" = "keeper",
		"Prime" = "mommiprime",
		"Prime Alt" = "mommiprime-alt",
		"Replicator" = "replicator",
		"RepairBot" = "repairbot",
		"Hover" = "hovermommi"
		)
	speed_modifier = MOMMI_NT_SPEED_MODIFIER

//Derelict MoMMI
/obj/item/weapon/robot_module/mommi/soviet
	name = "russian remont robot module"
	ae_type = "Начато отмену"
	speed_modifier = MOMMI_SOVIET_SPEED_MODIFIER

/obj/item/weapon/robot_module/mommi/soviet/New(var/mob/living/silicon/robot/R)
	..()
	//Powercreep, YEAH!
	modules += new /obj/item/device/rcd/borg(src)
	modules += new /obj/item/device/lightreplacer/borg(src)
	modules += new /obj/item/weapon/pickaxe/plasmacutter(src)
	modules += new /obj/item/weapon/storage/bag/ore/auto(src)