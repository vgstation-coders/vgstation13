/obj/item/weapon/robot_module
	name = "robot module"
	w_class = W_CLASS_GIANT

	var/speed_modifier = CYBORG_STANDARD_SPEED_MODIFIER
	var/default_modules = TRUE //Do we start with a flash/light?

	//Quirks
	var/quirk_flags = MODULE_CAN_BE_PUSHED

	//Icons
	var/list/sprites = list()

	//Modules
	var/list/modules = list()
	var/list/upgrades = list()
	var/obj/item/emag = null
	var/obj/item/borg/upgrade/jetpack = null

	//HUD
	var/list/sensor_augs
	var/module_holder = "nomod"

	//Languages
	var/list/languages = list()
	var/list/added_languages = list() //Bookkeeping

	//Radio
	var/radio_key = null

	//Camera
	var/list/networks = list()
	var/list/added_networks = list() //Bookkeeping

	//Respawnables
	var/recharge_tick = 0
	var/list/respawnables
	var/respawnables_max_amount = 0

/obj/item/weapon/robot_module/Destroy()
	if(istype(loc, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = loc
		RemoveStatusFlags(R)
		RemoveCameraNetworks(R)
		ResetEncryptionKey(R)
		UpdateModuleHolder(R, TRUE)
		R.remove_module() //Helps remove screen references on robot end

	for(var/obj/A in modules)
		if(istype(A, /obj/item/weapon/storage) && loc)
			var/obj/item/weapon/storage/S = A
			S.empty_contents_to(loc)
		qdel(A)
	modules = null
	if(emag)
		QDEL_NULL(emag)
	if(jetpack)
		QDEL_NULL(jetpack)
	QDEL_LIST_NULL(upgrades)
	..()

/obj/item/weapon/robot_module/proc/on_emag()
	if(emag)
		modules += emag
	rebuild()

/obj/item/weapon/robot_module/emp_act(severity)
	if(modules)
		for(var/obj/O in modules)
			O.emp_act(severity)
	if(emag)
		emag.emp_act(severity)
	..()

/obj/item/weapon/robot_module/New(var/mob/living/silicon/robot/R)
	..()
	add_languages(R)
	if(default_modules)
		AddDefaultModules()
	UpdateModuleHolder(R)
	AddCameraNetworks(R)
	AddEncryptionKey(R)
	ApplyStatusFlags(R)

/obj/item/weapon/robot_module/proc/AddDefaultModules()
	modules += new /obj/item/device/flashlight(src)
	modules += new /obj/item/device/flash(src)

/obj/item/weapon/robot_module/proc/UpdateModuleHolder(var/mob/living/silicon/robot/R, var/reset = FALSE)
	if(R.hands) //To prevent runtimes when spawning borgs with forced module and no client.
		if(reset)
			R.hands.icon_state = initial(R.hands.icon_state)
		else
			if(module_holder)
				R.hands.icon_state = module_holder

/obj/item/weapon/robot_module/proc/AddCameraNetworks(var/mob/living/silicon/robot/R)
	if(!R.camera && networks.len > 0) //Alright this module adds the borg to a CAMERANET but it has no camera, so we give it one.
		R.camera = new /obj/machinery/camera(R)
		R.camera.c_tag = R.real_name
		R.camera.network = list() //Empty list to prevent it from appearing where it isn't supposed to.
	if(R.camera)
		for(var/network in networks)
			if(!(network in R.camera.network))
				R.camera.network += network
				added_networks += network

/obj/item/weapon/robot_module/proc/RemoveCameraNetworks(var/mob/living/silicon/robot/R)
	if(R.camera)
		for(var/removed_network in added_networks)
			R.camera.network -= removed_network
	added_networks = null

/obj/item/weapon/robot_module/proc/AddEncryptionKey(var/mob/living/silicon/robot/R)
	if(!R.radio)
		return
	if(radio_key)
		R.radio.insert_key(new radio_key(R.radio))

/obj/item/weapon/robot_module/proc/ResetEncryptionKey(var/mob/living/silicon/robot/R)
	if(!R.radio)
		return
	if(radio_key)
		R.radio.reset_key()

/obj/item/weapon/robot_module/proc/ApplyStatusFlags(var/mob/living/silicon/robot/R)
	if(!(quirk_flags & MODULE_CAN_BE_PUSHED))
		R.status_flags &= ~CANPUSH

/obj/item/weapon/robot_module/proc/RemoveStatusFlags(var/mob/living/silicon/robot/R)
	if(!(quirk_flags & MODULE_CAN_BE_PUSHED))
		R.status_flags |= CANPUSH

/obj/item/weapon/robot_module/proc/fix_modules() //call this proc to enable clicking the slot of a module to equip it.
	var/mob/living/silicon/robot/owner = loc
	if(!istype(owner))
		return
	var/list/equipped_slots = owner.get_all_slots()
	for(var/obj/item/I in (modules + emag))
		if(I in equipped_slots)
			continue // mouse_opacity must not be 2 for equipped items
		I.mouse_opacity = 2

/obj/item/weapon/robot_module/proc/respawn_consumable(var/mob/living/silicon/robot/R)
	if(respawnables && respawnables.len)
		for(var/T in respawnables)
			if(!(locate(T) in modules))
				modules -= null
				var/obj/item/stack/O = new T(src)
				if(istype(O,T))
					O.max_amount = respawnables_max_amount
				modules += O
				O.amount = 1

/obj/item/weapon/robot_module/proc/rebuild()//Rebuilds the list so it's possible to add/remove items from the module
	var/list/temp_list = modules
	modules = list()
	for(var/obj/O in temp_list)
		if(O)
			modules += O

/obj/item/weapon/robot_module/proc/add_languages(var/mob/living/silicon/robot/R)
	for(var/language_name in languages)
		if(R.add_language(language_name))
			added_languages |= language_name

/obj/item/weapon/robot_module/proc/remove_languages(var/mob/living/silicon/robot/R)
	for(var/language_name in added_languages)
		R.remove_language(language_name, TRUE) //We remove the ability to speak but keep the ability to understand.
	added_languages.Cut()

//Modules
/obj/item/weapon/robot_module/standard
	name = "standard robot module"
	module_holder = "standard"
	sprites = list(
		"Default" = "robot",
		"Antique" = "robot_old",
		"Droid" = "droid",
		"Marina" = "marinaSD",
		"Sleek" = "sleekstandard",
		"#11" = "servbot",
		"Spider" = "spider-standard",
		"Kodiak - 'Polar'" = "kodiak-standard",
		"Noble" = "Noble-STD",
		"R34 - STR4a 'Durin'" = "durin"
		)
	respawnables = list(
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
		)
	respawnables_max_amount = STANDARD_MAX_KIT

/obj/item/weapon/robot_module/standard/New()
	..()

	modules += new /obj/item/tool/crowbar(src)
	modules += new /obj/item/weapon/extinguisher/mini(src)
	modules += new /obj/item/weapon/melee/baton/loaded/borg(src)
	modules += new /obj/item/tool/wrench(src)
	modules += new /obj/item/device/healthanalyzer(src)
	modules += new /obj/item/weapon/soap/nanotrasen(src)
	modules += new /obj/item/device/taperecorder(src)
	modules += new /obj/item/device/megaphone(src)
	var/obj/item/stack/medical/bruise_pack/B = new /obj/item/stack/medical/bruise_pack(src)
	B.max_amount = STANDARD_MAX_KIT
	B.amount = STANDARD_MAX_KIT
	modules += B
	var/obj/item/stack/medical/ointment/O = new /obj/item/stack/medical/ointment(src)
	O.max_amount = STANDARD_MAX_KIT
	O.amount = STANDARD_MAX_KIT
	modules += O
	emag = new /obj/item/weapon/melee/energy/sword(src)

	sensor_augs = list("Security", "Medical", "Mesons", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/medical
	name = "medical robot module"
	module_holder = "medical"
	quirk_flags = MODULE_CAN_HANDLE_MEDICAL | MODULE_CAN_HANDLE_CHEMS | MODULE_CAN_LIFT_VIROTAPE
	networks = list(CAMERANET_MEDBAY)
	radio_key = /obj/item/device/encryptionkey/headset_med
	sprites = list(
		"Default" = "medbot",
		"Needles" = "needles",
		"Surgeon" = "surgeon",
		"EVE" = "eve",
		"Droid" = "droid-medical",
		"Marina" = "marina",
		"Sleek" = "sleekmedic",
		"#17" = "servbot-medi",
		"Kodiak - 'Arachne'" = "arachne",
		"Noble" = "Noble-MED",
		"R34 - MED6a 'Gibbs'" = "gibbs"
		)
	speed_modifier = CYBORG_MEDICAL_SPEED_MODIFIER
	respawnables = list(
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/stack/medical/splint
		)
	respawnables_max_amount = MEDICAL_MAX_KIT

/obj/item/weapon/robot_module/medical/New()
	..()

	modules += new /obj/item/tool/crowbar(src)
	modules += new /obj/item/weapon/extinguisher/mini(src)
	modules += new /obj/item/device/healthanalyzer(src)
	modules += new /obj/item/device/antibody_scanner(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo(src)
	modules += new /obj/item/weapon/gripper/chemistry(src)
	modules += new /obj/item/weapon/reagent_containers/dropper/robodropper(src)
	modules += new /obj/item/weapon/reagent_containers/syringe(src)
	modules += new /obj/item/weapon/storage/bag/chem(src)
	modules += new /obj/item/tool/scalpel(src)
	modules += new /obj/item/tool/hemostat(src)
	modules += new /obj/item/tool/retractor(src)
	modules += new /obj/item/tool/circular_saw(src)
	modules += new /obj/item/tool/cautery(src)
	modules += new /obj/item/tool/bonegel(src)
	modules += new /obj/item/tool/bonesetter(src)
	modules += new /obj/item/tool/FixOVein(src)
	modules += new /obj/item/tool/surgicaldrill(src)
	modules += new /obj/item/weapon/revivalprod(src)
	modules += new /obj/item/weapon/inflatable_dispenser/robot(src)
	modules += new /obj/item/robot_rack/bed(src)
	modules += new /obj/item/weapon/cookiesynth/lollipop(src)
	var/obj/item/stack/medical/advanced/bruise_pack/B = new /obj/item/stack/medical/advanced/bruise_pack(src)
	B.max_amount = MEDICAL_MAX_KIT
	B.amount = MEDICAL_MAX_KIT
	modules += B
	var/obj/item/stack/medical/advanced/ointment/O = new /obj/item/stack/medical/advanced/ointment(src)
	O.max_amount = MEDICAL_MAX_KIT
	O.amount = MEDICAL_MAX_KIT
	modules += O
	var/obj/item/stack/medical/splint/S = new /obj/item/stack/medical/splint(src)
	S.max_amount = MEDICAL_MAX_KIT
	S.amount = MEDICAL_MAX_KIT
	modules += S
	emag = new /obj/item/weapon/reagent_containers/spray/pacid(src)

	sensor_augs = list("Medical", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"
	module_holder = "engineer"
	quirk_flags = MODULE_CAN_BE_PUSHED | MODULE_HAS_MAGPULSE | MODULE_CAN_LIFT_ENGITAPE
	networks = list(CAMERANET_ENGI)
	radio_key = /obj/item/device/encryptionkey/headset_eng
	sprites = list(
		"Default" = "engibot",
		"Engiseer" = "engiseer",
		"Landmate" = "landmate",
		"Wall-E" = "wall-e",
		"Droid" = "droid-engineer",
		"Marina" = "marinaEN",
		"Sleek" = "sleekengineer",
		"#25" = "servbot-engi",
		"Kodiak" = "kodiak-eng",
		"Noble" = "Noble-ENG",
		"R34 - ENG7a 'Conagher'" = "conagher"
		)
	speed_modifier = CYBORG_ENGINEERING_SPEED_MODIFIER
	respawnables = list(/obj/item/stack/cable_coil/yellow)
	respawnables_max_amount = ENGINEERING_MAX_COIL

/obj/item/weapon/robot_module/engineering/New()
	..()

	modules += new /obj/item/tool/crowbar(src)
	modules += new /obj/item/weapon/extinguisher(src)
	modules += new /obj/item/weapon/extinguisher/foam(src)
	modules += new /obj/item/device/rcd/borg/engineering(src)
	modules += new /obj/item/device/rcd/rpd(src) //What could possibly go wrong?
	modules += new /obj/item/tool/weldingtool/largetank(src)
	modules += new /obj/item/tool/screwdriver(src)
	modules += new /obj/item/tool/wrench(src)
	modules += new /obj/item/tool/wirecutters(src)
	modules += new /obj/item/device/multitool(src)
	modules += new /obj/item/device/t_scanner(src)
	modules += new /obj/item/device/analyzer(src)
	modules += new /obj/item/taperoll/atmos(src)
	modules += new /obj/item/taperoll/engineering(src)
	modules += new /obj/item/device/material_synth/robot/engiborg(src)
	modules += new /obj/item/device/silicate_sprayer(src)
	modules += new /obj/item/device/holomap(src)
	modules += new /obj/item/weapon/inflatable_dispenser/robot(src)
	modules += new /obj/item/borg/fire_shield
	var/obj/item/stack/cable_coil/W = new /obj/item/stack/cable_coil/yellow(src)
	W.amount = ENGINEERING_MAX_COIL
	W.max_amount = ENGINEERING_MAX_COIL
	modules += W
	emag = new /obj/item/borg/stun(src)

	sensor_augs = list("Mesons", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/security
	name = "security robot module"
	module_holder = "security"
	quirk_flags = MODULE_IS_THE_LAW | MODULE_CAN_LIFT_SECTAPE
	radio_key = /obj/item/device/encryptionkey/headset_sec
	sprites = list(
		"Default" = "secbot",
		"Bloodhound" = "bloodhound",
		"Securitron" = "securitron",
		"Droid 'Black Knight'" = "droid-security",
		"Marina" = "marinaSC",
		"Sleek" = "sleeksecurity",
		"#9" = "servbot-sec",
		"Kodiak" = "kodiak-sec",
		"Noble" = "Noble-SEC",
		"R34 - SEC10a 'Woody'" = "woody"
		)
	speed_modifier = CYBORG_SECURITY_SPEED_MODIFIER

/obj/item/weapon/robot_module/security/New()
	..()

	modules += new /obj/item/tool/crowbar(src)
	modules += new /obj/item/weapon/melee/baton/loaded/borg(src)
	modules += new /obj/item/weapon/gun/energy/taser/cyborg(src)
	modules += new /obj/item/weapon/handcuffs/cyborg(src)
	modules += new /obj/item/weapon/reagent_containers/spray/pepper(src)
	modules += new /obj/item/taperoll/police(src)
	modules += new /obj/item/device/hailer(src)
	emag = new /obj/item/weapon/gun/energy/laser/cyborg(src)

	sensor_augs = list("Security", "Medical", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"
	module_holder = "janitor"
	quirk_flags = MODULE_CAN_BE_PUSHED | MODULE_CLEAN_ON_MOVE
	sprites = list(
		"Default" = "janbot",
		"Mechaduster" = "mechaduster",
		"HAN-D" = "han-d",
		"Mop Gear Rex" = "mopgearrex",
		"Droid - 'Mopbot'"  = "droid-janitor",
		"Marina" = "marinaJN",
		"Sleek" = "sleekjanitor",
		"#29" = "servbot-jani",
		"Noble" = "Noble-JAN",
		"R34 - CUS3a 'Flynn'" = "flynn"
		)
	speed_modifier = CYBORG_JANITOR_SPEED_MODIFIER

/obj/item/weapon/robot_module/janitor/New()
	..()

	modules += new /obj/item/tool/crowbar(src)
	modules += new /obj/item/weapon/extinguisher/mini(src)
	modules += new /obj/item/weapon/soap/nanotrasen(src)
	modules += new /obj/item/weapon/storage/bag/trash(src)
	modules += new /obj/item/weapon/mop(src)
	modules += new /obj/item/device/lightreplacer/borg(src)
	modules += new /obj/item/weapon/reagent_containers/glass/bucket(src)
	emag = new /obj/item/weapon/reagent_containers/spray/lube(src)

	fix_modules()

/obj/item/weapon/robot_module/butler
	name = "service robot module"
	module_holder = "service"
	quirk_flags = MODULE_CAN_BE_PUSHED | MODULE_CAN_HANDLE_CHEMS | MODULE_CAN_HANDLE_FOOD | MODULE_CAN_BUY
	radio_key = /obj/item/device/encryptionkey/headset_service
	sprites = list(
		"Default - 'Butler'" = "servbot_m",
		"Default - 'Waitress'" = "servbot_f",
		"Default - 'Bro'" = "brobot",
		"Default - 'Fro'" = "frobot",
		"Default - 'Maximillion'" = "maximillion",
		"Default - 'Hydro'" = "hydrobot",
		"Toiletbot" = "toiletbot",
		"Marina" = "marinaSV",
		"Sleek" = "sleekservice",
		"#27" = "servbot-service",
		"Kodiak - 'Teddy'" = "kodiak-service",
		"Noble" = "Noble-SRV",
		"R34 - SRV9a 'Llyod'" = "lloyd"
		)
	languages = list(
		LANGUAGE_UNATHI,
		LANGUAGE_CATBEAST,
		LANGUAGE_SKRELLIAN,
		LANGUAGE_GREY,
		LANGUAGE_CLATTER,
		LANGUAGE_VOX,
		LANGUAGE_GOLEM,
		LANGUAGE_SLIME,
		)
	speed_modifier = CYBORG_SERVICE_SPEED_MODIFIER

/obj/item/weapon/robot_module/butler/New()
	..()

	modules += new /obj/item/tool/crowbar(src)
	modules += new /obj/item/weapon/extinguisher/mini(src)
	modules += new /obj/item/weapon/gripper/service(src)
	modules += new /obj/item/weapon/pen/robopen(src)
	modules += new /obj/item/weapon/dice/borg(src)
	modules += new /obj/item/device/rcd/borg/rsf(src)
	modules += new /obj/item/device/rcd/tile_painter(src)
	modules += new /obj/item/weapon/lighter/zippo(src)
	modules += new /obj/item/device/instrument/instrument_synth(src)
	modules += new /obj/item/weapon/tray/robotray(src)
	modules += new /obj/item/weapon/reagent_containers/dropper/robodropper(src)
	modules += new /obj/item/weapon/reagent_containers/food/drinks/shaker(src)
	modules += new /obj/item/weapon/reagent_containers/glass/rag/robo(src)
	modules += new /obj/item/device/chem_synth/robot/service(src)
	modules += new /obj/item/weapon/kitchen/utensil/knife/large(src)
	modules += new /obj/item/weapon/kitchen/rollingpin(src)
	modules += new /obj/item/weapon/storage/bag/food/borg(src)

	emag = new /obj/item/weapon/kitchen/utensil/knife/large/butch(src)

	fix_modules()

/obj/item/weapon/robot_module/butler/on_emag()
	//add some spicy chemicals to the synth
	for(var/M in modules)
		if(istype(M, /obj/item/device/chem_synth/robot/service))
			var/obj/item/device/chem_synth/robot/service/synth = M
			synth.emag_act(null)
			break
	. = ..()


/obj/item/weapon/robot_module/miner
	name = "supply robot module"
	module_holder = "miner"
	quirk_flags = MODULE_CAN_CLOSE_CLOSETS
	networks = list(CAMERANET_MINE)
	radio_key = /obj/item/device/encryptionkey/headset_mining
	sprites = list(
		"Default" = "minerbot",
		"Treadhead" = "miner",
		"Wall-A" = "wall-a",
		"Droid" = "droid-miner",
		"Marina" = "marinaMN",
		"Sleek" = "sleekminer",
		"#31" = "servbot-miner",
		"Kodiak" = "kodiak-miner",
		"Noble" = "Noble-SUP",
		"R34 - MIN2a 'Ishimura'" = "ishimura"
		)
	speed_modifier = CYBORG_SUPPLY_SPEED_MODIFIER
	respawnables = list(/obj/item/stack/package_wrap)
	respawnables_max_amount = SUPPLY_MAX_WRAP

/obj/item/weapon/robot_module/miner/New()
	..()

	modules += new /obj/item/tool/crowbar(src)
	modules += new /obj/item/weapon/extinguisher/mini(src)
	modules += new /obj/item/weapon/storage/bag/ore/auto(src)
	modules += new /obj/item/weapon/pickaxe/drill/borg(src)
	modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)
	modules += new /obj/item/device/mining_scanner(src)
	modules += new /obj/item/weapon/gun/energy/kinetic_accelerator/cyborg(src)
	modules += new /obj/item/weapon/gripper/no_use/inserter(src)
	modules += new /obj/item/device/destTagger/cyborg(src)
	modules += new /obj/item/weapon/storage/bag/clipboard(src)
	modules += new /obj/item/device/gps/cyborg(src)
	var/obj/item/stack/package_wrap/W = new /obj/item/stack/package_wrap(src)
	W.amount = SUPPLY_MAX_WRAP
	W.max_amount = SUPPLY_MAX_WRAP
	modules += W
	emag = new /obj/item/borg/stun(src)

	sensor_augs = list("Mesons", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/syndicate
	name = "syndicate-modded combat robot module"
	module_holder = "malf"
	quirk_flags = MODULE_IS_DEFINITIVE | MODULE_HAS_PROJ_RES
	networks = list(CAMERANET_NUKE)
	radio_key = /obj/item/device/encryptionkey/syndicate
	speed_modifier = CYBORG_SYNDICATE_SPEED_MODIFIER

/obj/item/weapon/robot_module/syndicate/New()
	..()

	modules += new /obj/item/tool/crowbar(src)
	fix_modules()

/obj/item/weapon/robot_module/syndicate/blitzkrieg
	name = "syndicate blitzkrieg robot module"
	sprites = list(
		"Motile" = "motile-syndie"
		)

/obj/item/weapon/robot_module/syndicate/blitzkrieg/New()
	..()

	modules += new /obj/item/tool/wrench(src) //This thing supposed to be a hacked and modded combat cyborg, is it really going to be stopped by a chair or table?
	modules += new /obj/item/weapon/pinpointer/nukeop(src)
	modules += new /obj/item/weapon/gun/projectile/automatic/c20r(src)
	modules += new /obj/item/robot_rack/ammo/a12mm(src)
	modules += new /obj/item/weapon/pickaxe/plasmacutter/heat_axe(src)

	sensor_augs = list("Thermal", "Light Amplification", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/syndicate/crisis
	name = "syndicate crisis robot module"
	sprites = list(
		"Droid" = "droid-crisis"
		)

/obj/item/weapon/robot_module/syndicate/crisis/New()
	..()

	quirk_flags |= MODULE_CAN_HANDLE_MEDICAL | MODULE_CAN_HANDLE_CHEMS | MODULE_CAN_LIFT_VIROTAPE

	modules += new /obj/item/weapon/card/emag(src)
	modules += new /obj/item/weapon/extinguisher/mini(src)
	modules += new /obj/item/weapon/inflatable_dispenser(src)
	modules += new /obj/item/device/chameleon(src)
	modules += new /obj/item/weapon/gripper/chemistry(src)
	modules += new /obj/item/device/healthanalyzer(src)
	modules += new /obj/item/device/reagent_scanner/adv(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo/crisis(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo/biofoam(src)
	modules += new /obj/item/weapon/revivalprod(src)
	modules += new /obj/item/weapon/switchtool/surgery/maxed(src)
	modules += new /obj/item/robot_rack/bed/syndie(src)
	modules += new /obj/item/weapon/cookiesynth/lollipop(src)

	sensor_augs = list("Thermal", "Medical", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/combat
	name = "combat robot module"
	module_holder = "malf"
	quirk_flags = MODULE_IS_THE_LAW | MODULE_HAS_PROJ_RES
	radio_key = /obj/item/device/encryptionkey/headset_sec
	sprites = list(
		"Bladewolf" = "bladewolf",
		"Bladewolf MK-2" = "bladewolfmk2",
		"Mr. Gutsy" = "mrgutsy",
		"Droid" = "droid-combat",
		"Droid - 'Rottweiler'" = "rottweiler-combat",
		"Marina" = "marinaCB",
		"#41" = "servbot-combat",
		"Kodiak - 'Grizzly'" = "kodiak-combat",
		"Sleek" = "sleekcombat",
		"R34 - WAR8a 'Chesty'" = "chesty"
		)
	speed_modifier = CYBORG_COMBAT_SPEED_MODIFIER

/obj/item/weapon/robot_module/combat/New()
	..()

	modules += new /obj/item/tool/crowbar(src)
	modules += new /obj/item/weapon/gun/energy/laser/cyborg(src)
	modules += new /obj/item/weapon/pickaxe/plasmacutter(src)
	modules += new /obj/item/weapon/pickaxe/jackhammer/combat(src)
	modules += new /obj/item/borg/combat/shield(src)
	modules += new /obj/item/borg/combat/mobility(src)
	modules += new /obj/item/tool/wrench(src) //Is a combat machine really going to be stopped by a chair?
	emag = new /obj/item/weapon/gun/energy/laser/cannon/cyborg(src)

	sensor_augs = list("Security", "Medical", "Mesons", "Thermal", "Light Amplification", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/tg17355
	name = "tg17355 robot module"
	module_holder = "brobot"
	quirk_flags = MODULE_CAN_BE_PUSHED | MODULE_IS_DEFINITIVE
	sprites = list(
		"Peacekeeper" = "peaceborg",
		"Omoikane" = "omoikane"
	)
	speed_modifier = CYBORG_TG17355_SPEED_MODIFIER

/obj/item/weapon/robot_module/tg17355/New()
	..()

	modules += new /obj/item/weapon/extinguisher/mini(src)
	modules += new /obj/item/weapon/cookiesynth(src)
	modules += new /obj/item/device/harmalarm(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo/peace(src)
	modules += new /obj/item/weapon/inflatable_dispenser(src)
	modules += new /obj/item/borg/cyborghug(src)
	emag = new /obj/item/weapon/reagent_containers/borghypo/peace/hacked(src)

	sensor_augs = list("Medical", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/starman
	name = "starman robot module"
	module_holder = "starman"
	quirk_flags = MODULE_IS_DEFINITIVE | MODULE_IS_FLASHPROOF
	sprites = list(
		"Basic" = "starman",
	)
	speed_modifier = CYBORG_STARMAN_SPEED_MODIFIER
	default_modules = FALSE

/obj/item/weapon/robot_module/starman/New()

	modules += new /obj/item/weapon/gun/energy/starman_beam(src)
	modules += new /obj/item/device/starman_hailer(src)

	sensor_augs = list("Thermal", "Light Amplification", "Disable")

	fix_modules()
