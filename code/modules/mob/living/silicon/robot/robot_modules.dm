
var/global/list/robot_modules = list(
	"Standard"		= /obj/item/weapon/robot_module/standard,
	"Service" 		= /obj/item/weapon/robot_module/butler,
	"Supply" 		= /obj/item/weapon/robot_module/miner,
	"Medical" 		= /obj/item/weapon/robot_module/medical,
	"Security" 		= /obj/item/weapon/robot_module/security,
	"Engineering"	= /obj/item/weapon/robot_module/engineering,
	"Janitor" 		= /obj/item/weapon/robot_module/janitor,
	"Combat" 		= /obj/item/weapon/robot_module/combat,
	"Syndicate"		= /obj/item/weapon/robot_module/syndicate,
	"TG17355"		= /obj/item/weapon/robot_module/tg17355
)

/obj/item/weapon/robot_module
	name = "robot module"
	icon = 'icons/obj/module.dmi'
	//icon_state = "std_module"
	w_class = W_CLASS_GIANT
	item_state = "electronic"
	flags = FPRINT
	siemens_coefficient = 1

	var/list/modules = list()
	var/obj/item/emag = null
	var/obj/item/borg/upgrade/jetpack = null
	var/recharge_tick = 0
	var/recharge_time = 10 // when to recharge a consumable, only used for engi borgs atm
	var/list/sensor_augs
	var/languages = list(
		LANGUAGE_GALACTIC_COMMON = TRUE,
		LANGUAGE_TRADEBAND = TRUE,
		)
	var/list/added_languages
	var/list/upgrades = list()
	var/networks = list()
	var/sprites = list()
	var/can_be_pushed = TRUE
	var/no_slip = FALSE
	var/radio_key = null

	// Bookkeeping
	var/list/added_networks = list()

/obj/item/weapon/robot_module/Destroy()
	if(istype(loc, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = loc
		RemoveStatusFlags(R)
		RemoveCameraNetworks(R)
		ResetEncryptionKey(R)
		R.remove_module() //Helps remove screen references on robot end

	for(var/obj/A in modules)
		qdel(A)
	modules = null
	if(emag)
		qdel(emag)
		emag = null
	if(jetpack)
		qdel(jetpack)
		jetpack = null
	for(var/obj/A in upgrades)
		qdel(upgrades)
	upgrades = null
	..()

/obj/item/weapon/robot_module/proc/recharge_consumable()
	return

/obj/item/weapon/robot_module/proc/on_emag()
	if(emag)
		modules += emag
	rebuild()
	..()

/obj/item/weapon/robot_module/emp_act(severity)
	if(modules)
		for(var/obj/O in modules)
			O.emp_act(severity)
	if(emag)
		emag.emp_act(severity)
	..()

/obj/item/weapon/robot_module/New(var/mob/living/silicon/robot/R, var/default = TRUE)
	..()
	added_languages = list()
	add_languages(R)
	AddToProfiler()
	if(default)
		AddDefaultModules()
	AddCameraNetworks(R)
	AddEncryptionKey(R)
	ApplyStatusFlags(R)

/obj/item/weapon/robot_module/proc/AddDefaultModules()
	modules += new /obj/item/device/flashlight(src)
	modules += new /obj/item/device/flash(src)

/obj/item/weapon/robot_module/proc/AddCameraNetworks(var/mob/living/silicon/robot/R)
	if(R.camera && CAMERANET_ROBOTS in R.camera.network)
		for(var/network in networks)
			if(!(network in R.camera.network))
				R.camera.network.Add(network)
				added_networks.Add(network)

/obj/item/weapon/robot_module/proc/RemoveCameraNetworks(var/mob/living/silicon/robot/R)
	if(R.camera)
		R.camera.network.Cut(added_networks)
		added_networks.Cut()

/obj/item/weapon/robot_module/proc/AddEncryptionKey(var/mob/living/silicon/robot/R)
	if(!R.radio)
		return
	R.radio.insert_key(new radio_key(R.radio))

/obj/item/weapon/robot_module/proc/ResetEncryptionKey(var/mob/living/silicon/robot/R)
	if(!R.radio)
		return
	if(radio_key)
		R.radio.reset_key()

/obj/item/weapon/robot_module/proc/ApplyStatusFlags(var/mob/living/silicon/robot/R)
	if(!can_be_pushed)
		R.status_flags &= ~CANPUSH

/obj/item/weapon/robot_module/proc/RemoveStatusFlags(var/mob/living/silicon/robot/R)
	if(!can_be_pushed)
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
	return

/obj/item/weapon/robot_module/proc/rebuild()//Rebuilds the list so it's possible to add/remove items from the module
	var/list/temp_list = modules
	modules = list()
	for(var/obj/O in temp_list)
		if(O)
			modules += O

/obj/item/weapon/robot_module/standard
	name = "standard robot module"
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

#define STANDARD_MAX_KIT 15
/obj/item/weapon/robot_module/standard/New()
	..()

	modules += new /obj/item/weapon/melee/baton/loaded/borg(src)
	modules += new /obj/item/weapon/extinguisher(src)
	modules += new /obj/item/weapon/wrench(src)
	modules += new /obj/item/weapon/crowbar(src)
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

/obj/item/weapon/robot_module/standard/respawn_consumable(var/mob/living/silicon/robot/R)
	// Replenish ointment and bandages
	var/list/what = list (
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
	)
	for (var/T in what)
		if (!(locate(T) in modules))
			modules -= null
			var/obj/item/stack/O = new T(src)
			if(istype(O,/obj/item/stack/medical))
				O.max_amount = STANDARD_MAX_KIT
			modules += O
			O.amount = 1
	return

/obj/item/weapon/robot_module/medical
	name = "medical robot module"
	networks = list(CAMERANET_MEDBAY)
	radio_key = /obj/item/device/encryptionkey/headset_med
	can_be_pushed = FALSE
	sprites = list(
		"Default" = "Medbot",
		"Advanced Droid" = "droid-medical",
		"Needles" = "medicalrobot",
		"Droid" = "surgeon",
		"Marina" = "marina",
		"Sleek" = "sleekmedic",
		"#17" = "servbot-medi",
		"Kodiak - 'Arachne'" = "arachne",
		"Noble" = "Noble-MED",
		"R34 - MED6a 'Gibbs'" = "gibbs"
		)

#define MEDBORG_MAX_KIT 10
/obj/item/weapon/robot_module/medical/New()
	..()

	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/device/healthanalyzer(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo(src)
	modules += new /obj/item/weapon/gripper/chemistry(src)
	modules += new /obj/item/weapon/reagent_containers/dropper/robodropper(src)
	modules += new /obj/item/weapon/reagent_containers/syringe(src)
	modules += new /obj/item/weapon/storage/bag/chem(src)
	modules += new /obj/item/weapon/extinguisher/mini(src)
	modules += new /obj/item/weapon/scalpel(src)
	modules += new /obj/item/weapon/hemostat(src)
	modules += new /obj/item/weapon/retractor(src)
	modules += new /obj/item/weapon/circular_saw(src)
	modules += new /obj/item/weapon/cautery(src)
	modules += new /obj/item/weapon/bonegel(src)
	modules += new /obj/item/weapon/bonesetter(src)
	modules += new /obj/item/weapon/FixOVein(src)
	modules += new /obj/item/weapon/surgicaldrill(src)
	modules += new /obj/item/weapon/revivalprod(src)
	modules += new /obj/item/weapon/inflatable_dispenser/robot(src)
	modules += new /obj/item/roller_holder(src)
	var/obj/item/stack/medical/advanced/bruise_pack/B = new /obj/item/stack/medical/advanced/bruise_pack(src)
	B.max_amount = MEDBORG_MAX_KIT
	B.amount = MEDBORG_MAX_KIT
	modules += B
	var/obj/item/stack/medical/advanced/ointment/O = new /obj/item/stack/medical/advanced/ointment(src)
	O.max_amount = MEDBORG_MAX_KIT
	O.amount = MEDBORG_MAX_KIT
	modules += O
	var/obj/item/stack/medical/splint/S = new /obj/item/stack/medical/splint(src)
	S.max_amount = MEDBORG_MAX_KIT
	S.amount = MEDBORG_MAX_KIT
	modules += S
	emag = new /obj/item/weapon/reagent_containers/spray(src)
	emag.reagents.add_reagent(PACID, 250)
	emag.name = "Polyacid spray"

	sensor_augs = list("Medical", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/medical/respawn_consumable(var/mob/living/silicon/robot/R)
	var/list/what = list (
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/stack/medical/splint,
	)
	for (var/T in what)
		if (!(locate(T) in modules))
			modules -= null
			var/obj/item/stack/O = new T(src)
			if(istype(O,/obj/item/stack/medical))
				O.max_amount = MEDBORG_MAX_KIT
			modules += O
			O.amount = 1
	return


/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"
	networks = list(CAMERANET_ENGI)
	radio_key = /obj/item/device/encryptionkey/headset_eng
	no_slip = TRUE
	sprites = list(
		"Default" = "Engineering",
		"Antique" = "engineerrobot",
		"Engiseer" = "Engiseer",
		"Droid - 'Landmate'" = "landmate",
		"Marina" = "marinaEN",
		"Sleek" = "sleekengineer",
		"#25" = "servbot-engi",
		"Kodiak" = "kodiak-eng",
		"Noble" = "Noble-ENG",
		"R34 - ENG7a 'Conagher'" = "conagher"
		)

/obj/item/weapon/robot_module/engineering/New()
	..()

	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/device/rcd/borg/engineering(src)
	modules += new /obj/item/device/rcd/rpd(src) //What could possibly go wrong?
	modules += new /obj/item/weapon/extinguisher(src)
	modules += new /obj/item/weapon/extinguisher/foam(src)
	modules += new /obj/item/weapon/weldingtool/largetank(src)
	modules += new /obj/item/weapon/screwdriver(src)
	modules += new /obj/item/weapon/wrench(src)
	modules += new /obj/item/weapon/wirecutters(src)
	modules += new /obj/item/device/multitool(src)
	modules += new /obj/item/device/t_scanner(src)
	modules += new /obj/item/device/analyzer(src)
	modules += new /obj/item/taperoll/atmos(src)
	modules += new /obj/item/taperoll/engineering(src)
	modules += new /obj/item/device/rcd/tile_painter(src)
	modules += new /obj/item/device/material_synth/robot/engiborg(src)
	modules += new /obj/item/device/silicate_sprayer(src)
	modules += new /obj/item/device/holomap(src)
	modules += new /obj/item/weapon/inflatable_dispenser/robot(src)
	var/obj/item/stack/cable_coil/W = new /obj/item/stack/cable_coil(src)
	W.amount = 50
	W.max_amount = 50
	modules += W
	emag = new /obj/item/borg/stun(src)

	sensor_augs = list("Mesons", "Disable")

	fix_modules()


/obj/item/weapon/robot_module/engineering/respawn_consumable(var/mob/living/silicon/robot/R)
	var/list/what = list (
		/obj/item/stack/cable_coil
	)
	for (var/T in what)
		if (!(locate(T) in modules))
			modules -= null
			var/obj/item/stack/O = new T(src)
			if(istype(O,/obj/item/stack/cable_coil))
				O.max_amount = 50
			modules += O
			O.amount = 1
	return

/obj/item/weapon/robot_module/engineering/recharge_consumable(var/mob/living/silicon/robot/R)
	for(var/T in modules)
		if(!(locate(T) in modules)) //Remove nulls
			modules -= null

	recharge_tick++
	if(recharge_tick < recharge_time)
		return FALSE
	recharge_tick = 0
	if(R && R.cell)
		respawn_consumable(R)
		var/list/um = R.contents|R.module.modules
		// ^ makes sinle list of active (R.contents) and inactive modules (R.module.modules)
		for(var/obj/item/stack/O in um)
			// Engineering
			if(istype(O,/obj/item/stack/cable_coil))
				if(O.amount < 50)
					O.amount += 1
					R.cell.use(50) 		//Take power from the borg...
				if(O.amount > 50)
					O.amount = 50


/obj/item/weapon/robot_module/security
	name = "security robot module"
	radio_key = /obj/item/device/encryptionkey/headset_sec
	can_be_pushed = FALSE
	sprites = list(
		"Default" = "secborg",
		"Black Knight" = "securityrobot",
		"Bloodhound" = "bloodhound",
		"Droid - 'Securitron'" = "securitron",
		"Marina" = "marinaSC",
		"Sleek" = "sleeksecurity",
		"#9" = "servbot-sec",
		"Kodiak" = "kodiak-sec",
		"Noble" = "Noble-SEC",
		"R34 - SEC10a 'Woody'" = "woody"
		)

/obj/item/weapon/robot_module/security/New()
	..()

	modules += new /obj/item/weapon/crowbar(src)
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
	sprites = list(
		"Default" = "JanBot2",
		"Antique - 'Mopbot'"  = "janitorrobot",
		"Mechaduster" = "mechaduster",
		"HAN-D" = "han-d",
		"Droid - 'Mop Gear Rex'" = "mopgearrex",
		"Marina" = "marinaJN",
		"Sleek" = "sleekjanitor",
		"#29" = "servbot-jani",
		"Noble" = "Noble-JAN",
		"R34 - CUS3a 'Flynn'" = "flynn"
		)

/obj/item/weapon/robot_module/janitor/New()
	..()

	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/weapon/soap/nanotrasen(src)
	modules += new /obj/item/weapon/storage/bag/trash(src)
	modules += new /obj/item/weapon/mop(src)
	modules += new /obj/item/device/lightreplacer/borg(src)
	modules += new /obj/item/weapon/reagent_containers/glass/bucket(src)
	emag = new /obj/item/weapon/reagent_containers/spray(src)
	emag.reagents.add_reagent(LUBE, 250)
	emag.name = "Lube spray"

	fix_modules()

/obj/item/weapon/robot_module/butler
	name = "service robot module"
	radio_key = /obj/item/device/encryptionkey/headset_service
	sprites = list(
		"Default" = "Service2",
		"Waitress" = "Service",
		"Bro" = "Brobot",
		"Rich" = "maximillion",
		"Hydro" = "Hydrobot",
		"Droid" = "toiletbot",
		"Marina" = "marinaSV",
		"Sleek" = "sleekservice",
		"#27" = "servbot-service",
		"Kodiak - 'Teddy'" = "kodiak-service",
		"Noble" = "Noble-SRV",
		"R34 - SRV9a 'Llyod'" = "lloyd"
		)
	languages = list(
		LANGUAGE_GALACTIC_COMMON = TRUE,
		LANGUAGE_UNATHI	= TRUE,
		LANGUAGE_CATBEAST = TRUE,
		LANGUAGE_SKRELLIAN = TRUE,
		LANGUAGE_ROOTSPEAK = TRUE,
		LANGUAGE_TRADEBAND = TRUE,
		LANGUAGE_GUTTER	= TRUE,
		LANGUAGE_MONKEY	= TRUE,
		)

/obj/item/weapon/robot_module/butler/New()
	..()

	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/weapon/gripper/service(src)
	modules += new /obj/item/weapon/pen/robopen(src)
	modules += new /obj/item/weapon/dice/borg(src)
	modules += new /obj/item/device/rcd/borg/rsf(src)
	modules += new /obj/item/weapon/lighter/zippo(src)
	modules += new /obj/item/device/instrument/instrument_synth(src)
	modules += new /obj/item/weapon/tray/robotray(src)
	modules += new /obj/item/weapon/reagent_containers/dropper/robodropper(src)
	modules += new /obj/item/weapon/reagent_containers/glass/replenishing/cyborg(src)

	emag = new /obj/item/weapon/reagent_containers/glass/replenishing/cyborg/hacked(src)

	fix_modules()

/obj/item/weapon/robot_module/miner
	name = "supply robot module"
	networks = list(CAMERANET_MINE)
	radio_key = /obj/item/device/encryptionkey/headset_mining
	sprites = list(
		"Default" = "Miner_old",
		"Treadhead" = "Miner",
		"Droid" = "droid-miner",
		"Marina" = "marinaMN",
		"Sleek" = "sleekminer",
		"#31" = "servbot-miner",
		"Kodiak" = "kodiak-miner",
		"Noble" = "Noble-SUP",
		"R34 - MIN2a 'Ishimura'" = "ishimura"
		)

/obj/item/weapon/robot_module/miner/New()
	..()

	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/weapon/storage/bag/ore(src)
	modules += new /obj/item/weapon/pickaxe/drill/borg(src)
	modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)
	modules += new /obj/item/device/mining_scanner(src)
	modules += new /obj/item/weapon/gun/energy/kinetic_accelerator/cyborg(src)
	modules += new /obj/item/weapon/gripper/no_use/inserter(src)
	var/obj/item/device/destTagger/tag = new /obj/item/device/destTagger(src)
	tag.mode = 1 //For editing the tag list
	modules += tag
	var/obj/item/stack/package_wrap/W = new /obj/item/stack/package_wrap(src)
	W.amount = 24
	W.max_amount = 24
	modules += W
	emag = new /obj/item/borg/stun(src)

	sensor_augs = list("Mesons", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/miner/respawn_consumable(var/mob/living/silicon/robot/R)
	var/list/what = list (
		/obj/item/stack/package_wrap
	)
	for (var/T in what)
		if (!(locate(T) in modules))
			modules -= null
			var/obj/item/stack/O = new T(src)
			if(istype(O,/obj/item/stack/package_wrap))
				O.max_amount = 24
			modules += O
			O.amount = 1

/obj/item/weapon/robot_module/syndicate
	name = "syndicate robot module"
	networks = list(CAMERANET_NUKE)
	radio_key = /obj/item/device/encryptionkey/syndicate
	can_be_pushed = FALSE
	sprites = list(
		"Droid - 'Rottweiler'" = "rottweiler-combat"
		)

/obj/item/weapon/robot_module/syndicate/New()
	..()

	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/weapon/melee/energy/sword(src)
	modules += new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(src)
	modules += new /obj/item/weapon/card/emag(src)

	sensor_augs = list("Security", "Medical", "Mesons", "Thermal", "Light Amplification", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/combat
	name = "combat robot module"
	radio_key = /obj/item/device/encryptionkey/headset_sec
	can_be_pushed = FALSE
	sprites = list(
		"Bladewolf MK-2" = "bladewolfmk2",
		"Mr. Gutsy" = "mrgutsy",
		"Droid" = "droid-combat",
		"Droid - 'Rottweiler'" = "rottweiler-combat",
		"Marina" = "marinaCB",
		"#41" = "servbot-combat",
		"Kodiak - 'Grizzly'" = "kodiak-combat",
		"R34 - WAR8a 'Chesty'" = "chesty"
		)

/obj/item/weapon/robot_module/combat/New()
	..()

	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/weapon/gun/energy/laser/cyborg(src)
	modules += new /obj/item/weapon/pickaxe/plasmacutter(src)
	modules += new /obj/item/weapon/pickaxe/jackhammer/combat(src)
	modules += new /obj/item/borg/combat/shield(src)
	modules += new /obj/item/borg/combat/mobility(src)
	modules += new /obj/item/weapon/wrench(src) //Is a combat android really going to be stopped by a chair?
	emag = new /obj/item/weapon/gun/energy/laser/cannon/cyborg(src)

	sensor_augs = list("Security", "Medical", "Mesons", "Thermal", "Light Amplification", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/tg17355
	name = "tg17355 robot module"
	sprites = list(
		"Peacekeeper" = "peaceborg",
		"Omoikane" = "omoikane"
	)

/obj/item/weapon/robot_module/tg17355/New()
	..()

	modules += new /obj/item/weapon/cookiesynth(src)
	modules += new /obj/item/device/harmalarm(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo/peace(src)
	modules += new /obj/item/weapon/inflatable_dispenser(src)
	modules += new /obj/item/borg/cyborghug(src)
	modules += new /obj/item/weapon/extinguisher(src)
	emag = new /obj/item/weapon/reagent_containers/borghypo/peace/hacked(src)

	sensor_augs = list("Medical", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/proc/add_languages(var/mob/living/silicon/robot/R)
	for(var/language in languages)
		if(R.add_language(language, languages[language]))
			added_languages |= language

/obj/item/weapon/robot_module/proc/remove_languages(var/mob/living/silicon/robot/R)
	for(var/language in added_languages)
		R.remove_language(language)
	added_languages.Cut()

#undef STANDARD_MAX_KIT
#undef MEDBORG_MAX_KIT
