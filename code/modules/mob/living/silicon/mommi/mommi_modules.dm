var/global/list/mommi_modules = list(
	"Nanotrasen"		= /obj/item/weapon/robot_module/mommi/nt,
	"Soviet" 	= /obj/item/weapon/robot_module/mommi/soviet
	)

/obj/item/weapon/robot_module/mommi
	name = "mobile mmi robot module"
	languages = list(
		LANGUAGE_GALACTIC_COMMON = FALSE,
		LANGUAGE_TRADEBAND = FALSE,
		LANGUAGE_VOX = FALSE,
		LANGUAGE_ROOTSPEAK = FALSE,
		LANGUAGE_GREY = FALSE,
		LANGUAGE_CLATTER = FALSE,
		LANGUAGE_MONKEY = FALSE,
		LANGUAGE_UNATHI = FALSE,
		LANGUAGE_CATBEAST = FALSE,
		LANGUAGE_SKRELLIAN = FALSE,
		LANGUAGE_GUTTER = FALSE,
		LANGUAGE_MONKEY = FALSE,
		LANGUAGE_MOUSE = FALSE,
		LANGUAGE_HUMAN = FALSE,
		LANGUAGE_GOLEM = FALSE,
		LANGUAGE_SLIME = FALSE
		)
	no_slip = TRUE
	sprites = list(
		"Basic" = "mommi",
		"Keeper" = "keeper",
		"Replicator" = "replicator",
		"RepairBot" = "repairbot",
		"Hover" = "hovermommi",
		"Prime" = "mommiprime",
		"Prime Alt" = "mommiprime-alt"
		)

/obj/item/weapon/robot_module/mommi/New(var/mob/living/silicon/robot/R)
	..()

	src.modules += new /obj/item/weapon/weldingtool/largetank(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/wirecutters(src)
	src.modules += new /obj/item/device/multitool(src)
	src.modules += new /obj/item/device/t_scanner(src)
	src.modules += new /obj/item/device/analyzer(src)
	src.modules += new /obj/item/weapon/extinguisher(src)
	src.modules += new /obj/item/weapon/extinguisher/foam(src)
	src.modules += new /obj/item/device/rcd/rpd(src)
	src.modules += new /obj/item/device/rcd/tile_painter(src)
	src.modules += new /obj/item/blueprints/mommiprints(src)
	src.modules += new /obj/item/device/material_synth/robot/mommi(src)
	src.modules += new /obj/item/device/holomap(src)
	src.modules += new /obj/item/device/station_map(src)
	src.modules += new /obj/item/device/silicate_sprayer(src)
	var/obj/item/stack/cable_coil/W = new /obj/item/stack/cable_coil(src)
	W.amount = 50
	W.max_amount = 50 //Override MAXCOIL
	src.modules += W
	src.emag = new /obj/item/borg/stun(src)

	sensor_augs = list("Mesons", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/mommi/respawn_consumable(var/mob/living/silicon/robot/R)
	var/list/what = list (/obj/item/stack/cable_coil)
	for(var/T in what)
		if(!(locate(T) in src.modules))
			src.modules -= null
			var/O = new T(src)
			if(istype(O,/obj/item/stack/cable_coil))
				O:max_amount = 50
			src.modules += O
			O:amount = 1

//Nanotrasen's MoMMI
/obj/item/weapon/robot_module/mommi/nt
	name = "nanotrasen mobile mmi robot module"
	networks = list(CAMERANET_ENGI)
	radio_key = /obj/item/device/encryptionkey/headset_eng

//Derelict MoMMI
/obj/item/weapon/robot_module/mommi/soviet
	name = "russian remont robot module"

/obj/item/weapon/robot_module/mommi/soviet/New(var/mob/living/silicon/robot/R)
	..()

	src.modules += new /obj/item/device/rcd/borg(src) //Powercreep, YEAH!