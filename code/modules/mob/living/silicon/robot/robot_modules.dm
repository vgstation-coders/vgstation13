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
	var/languages
	var/list/added_languages
	var/list/upgrades = list()

/obj/item/weapon/robot_module/Destroy()
	if(istype(loc, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = loc
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
	return

/obj/item/weapon/robot_module/New(var/mob/living/silicon/robot/R)
	..()

	languages = list(	LANGUAGE_GALACTIC_COMMON = 1, LANGUAGE_TRADEBAND = 1, LANGUAGE_VOX = 0,
						LANGUAGE_ROOTSPEAK = 0, LANGUAGE_GREY = 0, LANGUAGE_CLATTER = 0,
						LANGUAGE_MONKEY = 0, LANGUAGE_UNATHI = 0, LANGUAGE_CATBEAST = 0,
						LANGUAGE_SKRELLIAN = 0, LANGUAGE_GUTTER = 0, LANGUAGE_MONKEY = 0,
						LANGUAGE_MOUSE = 0, LANGUAGE_HUMAN = 0)
	added_languages = list()
	if(!isMoMMI(R))
		add_languages(R)
	AddToProfiler()
	src.modules += new /obj/item/device/flashlight(src)
	src.modules += new /obj/item/device/flash(src)
	src.emag = new /obj/item/toy/sword(src)
	src.emag.name = "Placeholder Emag Item"
//		src.jetpack = new /obj/item/toy/sword(src)
//		src.jetpack.name = "Placeholder Upgrade Item"
	return

/obj/item/weapon/robot_module/proc/fix_modules() //call this proc to enable clicking the slot of a module to equip it.
	for(var/obj/item/I in modules)
		I.mouse_opacity = 2
	if(emag)
		emag.mouse_opacity = 2

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

#define STANDARD_MAX_KIT 15
/obj/item/weapon/robot_module/standard/New()
	..()
	src.modules += new /obj/item/weapon/melee/baton/loaded/borg(src)
	src.modules += new /obj/item/weapon/extinguisher(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/device/healthanalyzer(src)
	src.modules += new /obj/item/weapon/soap/nanotrasen(src)
	src.modules += new /obj/item/device/taperecorder(src)
	src.modules += new /obj/item/device/megaphone(src)
	src.emag = new /obj/item/weapon/melee/energy/sword(src)
	sensor_augs = list("Security", "Medical", "Mesons", "Disable")


	var/obj/item/stack/medical/bruise_pack/B = new /obj/item/stack/medical/bruise_pack(src)
	B.max_amount = STANDARD_MAX_KIT
	B.amount = STANDARD_MAX_KIT
	src.modules += B

	var/obj/item/stack/medical/ointment/O = new /obj/item/stack/medical/ointment(src)
	O.max_amount = STANDARD_MAX_KIT
	O.amount = STANDARD_MAX_KIT
	src.modules += O

	fix_modules()

/obj/item/weapon/robot_module/standard/respawn_consumable(var/mob/living/silicon/robot/R)
	// Replenish ointment and bandages
	var/list/what = list (
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
	)
	for (var/T in what)
		if (!(locate(T) in src.modules))
			src.modules -= null
			var/obj/item/stack/O = new T(src)
			if(istype(O,/obj/item/stack/medical))
				O.max_amount = STANDARD_MAX_KIT
			src.modules += O
			O.amount = 1
	return



/obj/item/weapon/robot_module/medical
	name = "medical robot module"

#define MEDBORG_MAX_KIT 10
/obj/item/weapon/robot_module/medical/New()
	..()
	
	src.modules += new /obj/item/device/healthanalyzer(src)
	src.modules += new /obj/item/weapon/reagent_containers/borghypo(src)
	src.modules += new /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg(src,src)
	src.modules += new /obj/item/weapon/reagent_containers/dropper/robodropper(src)
	src.modules += new /obj/item/weapon/reagent_containers/syringe(src)
	src.modules += new /obj/item/weapon/storage/bag/chem(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.modules += new /obj/item/weapon/scalpel(src)
	src.modules += new /obj/item/weapon/hemostat(src)
	src.modules += new /obj/item/weapon/retractor(src)
	src.modules += new /obj/item/weapon/circular_saw(src)
	src.modules += new /obj/item/weapon/cautery(src)
	src.modules += new /obj/item/weapon/bonegel(src)
	src.modules += new /obj/item/weapon/bonesetter(src)
	src.modules += new /obj/item/weapon/FixOVein(src)
	src.modules += new /obj/item/weapon/surgicaldrill(src)
	src.modules += new /obj/item/weapon/revivalprod(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/inflatable_dispenser/robot(src)
	src.modules += new /obj/item/roller_holder(src)
	src.emag = new /obj/item/weapon/reagent_containers/spray(src)
	sensor_augs = list("Medical", "Disable")

	src.emag.reagents.add_reagent(PACID, 250)
	src.emag.name = "Polyacid spray"

	var/obj/item/stack/medical/advanced/bruise_pack/B = new /obj/item/stack/medical/advanced/bruise_pack(src)
	B.max_amount = MEDBORG_MAX_KIT
	B.amount = MEDBORG_MAX_KIT
	src.modules += B

	var/obj/item/stack/medical/advanced/ointment/O = new /obj/item/stack/medical/advanced/ointment(src)
	O.max_amount = MEDBORG_MAX_KIT
	O.amount = MEDBORG_MAX_KIT
	src.modules += O

	var/obj/item/stack/medical/splint/S = new /obj/item/stack/medical/splint(src)
	S.max_amount = MEDBORG_MAX_KIT
	S.amount = MEDBORG_MAX_KIT
	src.modules += S

	fix_modules()

/obj/item/weapon/robot_module/medical/respawn_consumable(var/mob/living/silicon/robot/R)
	var/list/what = list (
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/stack/medical/splint,
	)
	for (var/T in what)
		if (!(locate(T) in src.modules))
			src.modules -= null
			var/obj/item/stack/O = new T(src)
			if(istype(O,/obj/item/stack/medical))
				O.max_amount = MEDBORG_MAX_KIT
			src.modules += O
			O.amount = 1
	return


/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"


/obj/item/weapon/robot_module/engineering/New()
	..()
	
	src.emag = new /obj/item/borg/stun(src)
	src.modules += new /obj/item/device/rcd/borg/engineering(src)
	src.modules += new /obj/item/device/rcd/rpd(src) //What could possibly go wrong?
	src.modules += new /obj/item/weapon/extinguisher(src)
	src.modules += new /obj/item/weapon/extinguisher/foam(src)
	src.modules += new /obj/item/weapon/weldingtool/largetank(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/wirecutters(src)
	src.modules += new /obj/item/device/multitool(src)
	src.modules += new /obj/item/device/t_scanner(src)
	src.modules += new /obj/item/device/analyzer(src)
	src.modules += new /obj/item/taperoll/atmos(src)
	src.modules += new /obj/item/taperoll/engineering(src)
	src.modules += new /obj/item/device/rcd/tile_painter(src)
	src.modules += new /obj/item/device/material_synth/robot(src)
	src.modules += new /obj/item/device/silicate_sprayer(src)
	src.modules += new /obj/item/device/holomap(src)
	src.modules += new /obj/item/weapon/inflatable_dispenser/robot(src)
	sensor_augs = list("Mesons", "Disable")

	var/obj/item/stack/cable_coil/W = new /obj/item/stack/cable_coil(src)
	W.amount = 50
	W.max_amount = 50
	src.modules += W

	fix_modules()


/obj/item/weapon/robot_module/engineering/respawn_consumable(var/mob/living/silicon/robot/R)
	var/list/what = list (
		/obj/item/stack/cable_coil
	)
	for (var/T in what)
		if (!(locate(T) in src.modules))
			src.modules -= null
			var/obj/item/stack/O = new T(src)
			if(istype(O,/obj/item/stack/cable_coil))
				O.max_amount = 50
			src.modules += O
			O.amount = 1
	return

/obj/item/weapon/robot_module/engineering/recharge_consumable(var/mob/living/silicon/robot/R)
	for(var/T in src.modules)
		if(!(locate(T) in src.modules)) //Remove nulls
			src.modules -= null

	recharge_tick++
	if(recharge_tick < recharge_time)
		return 0
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

/obj/item/weapon/robot_module/security/New()
	..()
	src.modules += new /obj/item/weapon/melee/baton/loaded/borg(src)
	src.modules += new /obj/item/weapon/gun/energy/taser/cyborg(src)
	src.modules += new /obj/item/weapon/handcuffs/cyborg(src)
	src.modules += new /obj/item/weapon/reagent_containers/spray/pepper(src)
	src.modules += new /obj/item/taperoll/police(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.emag = new /obj/item/weapon/gun/energy/laser/cyborg(src)
	sensor_augs = list("Security", "Medical", "Disable")
	fix_modules()

/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"


/obj/item/weapon/robot_module/janitor/New()
	..()
	src.modules += new /obj/item/weapon/soap/nanotrasen(src)
	src.modules += new /obj/item/weapon/storage/bag/trash(src)
	src.modules += new /obj/item/weapon/mop(src)
	src.modules += new /obj/item/device/lightreplacer/borg(src)
	src.modules += new /obj/item/weapon/reagent_containers/glass/bucket(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.emag = new /obj/item/weapon/reagent_containers/spray(src)

	src.emag.reagents.add_reagent(LUBE, 250)
	src.emag.name = "Lube spray"
	fix_modules()



/obj/item/weapon/robot_module/butler
	name = "service robot module"


/obj/item/weapon/robot_module/butler/New()
	languages = list(
					LANGUAGE_GALACTIC_COMMON	= 1,
					LANGUAGE_UNATHI		= 1,
					LANGUAGE_CATBEAST	= 1,
					LANGUAGE_SKRELLIAN	= 1,
					LANGUAGE_ROOTSPEAK	= 1,
					LANGUAGE_TRADEBAND	= 1,
					LANGUAGE_GUTTER		= 1,
					LANGUAGE_MONKEY		= 1,
					)
	..()
	src.modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	src.modules += new /obj/item/weapon/reagent_containers/food/condiment/enzyme(src)
	src.modules += new /obj/item/weapon/pen/robopen(src)

	src.modules += new /obj/item/device/rcd/borg/rsf(src)

	src.modules += new /obj/item/weapon/reagent_containers/dropper/robodropper(src)

	var/obj/item/weapon/lighter/zippo/L = new /obj/item/weapon/lighter/zippo(src)
	L.lit = 1
	L.update_brightness()
	src.modules += L

	src.modules += new /obj/item/weapon/tray/robotray(src)

	src.modules += new /obj/item/weapon/reagent_containers/food/drinks/shaker(src)

	src.modules += new /obj/item/weapon/dice/borg(src)

	src.modules += new /obj/item/weapon/crowbar(src)

	src.emag = new /obj/item/weapon/reagent_containers/food/drinks/beer(src)

	var/datum/reagents/R = new/datum/reagents(50)
	src.emag.reagents = R
	R.my_atom = src.emag
	R.add_reagent(BEER2, 50)
	src.emag.name = "Mickey Finn's Special Brew"
	fix_modules()



/obj/item/weapon/robot_module/miner
	name = "supply robot module"

/obj/item/weapon/robot_module/miner/New()
	..()
	src.emag = new /obj/item/borg/stun(src)
	src.modules += new /obj/item/weapon/storage/bag/ore(src)
	src.modules += new /obj/item/weapon/pickaxe/drill/borg(src)
	src.modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)
	src.modules += new /obj/item/device/mining_scanner(src)
	src.modules += new /obj/item/weapon/gun/energy/kinetic_accelerator/cyborg(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	sensor_augs = list("Mesons", "Disable")
//		src.modules += new /obj/item/weapon/pickaxe/shovel(src) Uneeded due to buffed drill

	var/obj/item/device/destTagger/tag = new /obj/item/device/destTagger(src)
	tag.mode = 1 //For editing the tag list
	src.modules += tag

	var/obj/item/stack/package_wrap/W = new /obj/item/stack/package_wrap(src)
	W.amount = 24
	W.max_amount = 24
	src.modules += W

	fix_modules()

/obj/item/weapon/robot_module/miner/respawn_consumable(var/mob/living/silicon/robot/R)
	var/list/what = list (
		/obj/item/stack/package_wrap
	)
	for (var/T in what)
		if (!(locate(T) in src.modules))
			src.modules -= null
			var/obj/item/stack/O = new T(src)
			if(istype(O,/obj/item/stack/package_wrap))
				O.max_amount = 24
			src.modules += O
			O.amount = 1

/obj/item/weapon/robot_module/syndicate
	name = "syndicate robot module"


/obj/item/weapon/robot_module/syndicate/New()
	src.modules += new /obj/item/weapon/melee/energy/sword(src)
	src.modules += new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(src)
	src.modules += new /obj/item/weapon/card/emag(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	sensor_augs = list("Security", "Medical", "Mesons", "Thermal", "Light Amplification", "Disable")
	fix_modules()

/obj/item/weapon/robot_module/combat
	name = "combat robot module"

/obj/item/weapon/robot_module/combat/New()
	src.modules += new /obj/item/weapon/gun/energy/laser/cyborg(src)
	src.modules += new /obj/item/weapon/pickaxe/plasmacutter(src)
	src.modules += new /obj/item/weapon/pickaxe/jackhammer/combat(src)
	src.modules += new /obj/item/borg/combat/shield(src)
	src.modules += new /obj/item/borg/combat/mobility(src)
	src.modules += new /obj/item/weapon/wrench(src) //Is a combat android really going to be stopped by a chair?
	src.modules += new /obj/item/weapon/crowbar(src)
	src.emag = new /obj/item/weapon/gun/energy/laser/cannon/cyborg(src)
	sensor_augs = list("Security", "Medical", "Mesons", "Thermal", "Light Amplification", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/tg17355
	name = "tg17355 robot module"

/obj/item/weapon/robot_module/tg17355/New()
	..()
	src.modules += new /obj/item/weapon/cookiesynth(src)
	src.modules += new /obj/item/device/harmalarm(src)
	src.modules += new /obj/item/weapon/reagent_containers/borghypo/peace(src)
	src.modules += new /obj/item/weapon/inflatable_dispenser(src)
	src.modules += new /obj/item/borg/cyborghug(src)
	src.modules += new /obj/item/weapon/extinguisher(src)
	src.emag = new /obj/item/weapon/reagent_containers/borghypo/peace/hacked(src)
	sensor_augs = list("Medical", "Disable")
	fix_modules()

/obj/item/weapon/robot_module/proc/add_languages(var/mob/living/silicon/robot/R)
	for(var/language in languages)
		if(R.add_language(language, languages[language]))
			added_languages |= language

/obj/item/weapon/robot_module/proc/remove_languages(var/mob/living/silicon/robot/R)
	for(var/language in added_languages)
		R.remove_language(language)
	added_languages.len = 0

#undef STANDARD_MAX_KIT
#undef MEDBORG_MAX_KIT
