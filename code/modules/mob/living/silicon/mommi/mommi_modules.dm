
/obj/item/weapon/robot_module/mommi
	name = "mobile mmi robot module"
	quirk_flags = MODULE_CAN_BE_PUSHED | MODULE_HAS_MAGPULSE | MODULE_CAN_HANDLE_CHEMS | MODULE_CAN_BUY | MODULE_IS_DEFINITIVE | MODULE_CAN_HANDLE_FOOD
	languages = list()
	sprites = list("Basic" = "mommi")
	respawnables = list (/obj/item/stack/cable_coil)
	respawnables_max_amount = MOMMI_MAX_COIL
	default_modules = FALSE
	var/ae_type = "Default" //Anti-emancipation override type, pretty much just fluffy.
	var/law_type = "Default"

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
	modules += new /obj/item/device/holomap(src)
	modules += new /obj/item/device/station_map(src)
	modules += new /obj/item/device/silicate_sprayer(src)
	modules += new /obj/item/borg/fire_shield

	var/obj/item/stack/cable_coil/W = new /obj/item/stack/cable_coil(src)
	W.amount = MOMMI_MAX_COIL
	W.max_amount = MOMMI_MAX_COIL
	modules += W
	emag = new /obj/item/borg/stun(src)

	sensor_augs = list("Mesons", "Disable")

	fix_modules()

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
		"Hover" = "hovermommi",
		"Junkheap" = "junkmommi"
		)
	speed_modifier = MOMMI_NT_SPEED_MODIFIER

/obj/item/weapon/robot_module/mommi/nt/New(var/mob/living/silicon/robot/R)
	..()

	modules += new /obj/item/device/material_synth/robot/mommi(src)

	fix_modules()

//Derelict MoMMI
/obj/item/weapon/robot_module/mommi/soviet
	name = "russian remont robot module"
	ae_type = "Начато отмену"
	speed_modifier = MOMMI_SOVIET_SPEED_MODIFIER
	sprites = list(
		"RuskieBot" = "ruskiebot"
		)

/obj/item/weapon/robot_module/mommi/soviet/New(var/mob/living/silicon/robot/R) //Powercreep!
	..()

	modules += new /obj/item/device/material_synth/robot/soviet(src)
	modules += new /obj/item/device/rcd/borg/engineering(src)
	modules += new /obj/item/device/instrument/instrument_synth(src)
	modules += new /obj/item/device/rcd/borg/rsf/soviet(src)
	modules += new /obj/item/weapon/soap/syndie(src)
	modules += new /obj/item/weapon/pickaxe/plasmacutter(src)
	modules += new /obj/item/weapon/storage/bag/ore/auto(src)

	fix_modules()

/obj/item/weapon/robot_module/mommi/cogspider
	name = "Gravekeeper belt of holding."
	speed_modifier = COGSPIDER_SPEED_MODIFIER
	sprites = list(
		"Gravekeeper" = "cogspider"
		)
	law_type = "Gravekeeper"
