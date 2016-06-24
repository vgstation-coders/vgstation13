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
						LANGUAGE_MONKEY = 0, LANGUAGE_UNATHI = 0, LANGUAGE_SIIK_TAJR = 0,
						LANGUAGE_SKRELLIAN = 0, LANGUAGE_GUTTER = 0, LANGUAGE_MONKEY = 0,
						LANGUAGE_MOUSE = 0, LANGUAGE_HUMAN = 0)
	added_languages = list()
	if(!isMoMMI(R)) add_languages(R)
	AddToProfiler()
	modules += new /obj/item/device/flashlight(src)
	modules += new /obj/item/device/flash(src)
	emag = new /obj/item/toy/sword(src)
	emag.name = "Placeholder Emag Item"
//		jetpack = new /obj/item/toy/sword(src)
//		jetpack.name = "Placeholder Upgrade Item"
	return

obj/item/weapon/robot_module/proc/fix_modules() //call this proc to enable clicking the slot of a module to equip it.
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

/obj/item/weapon/robot_module/standard/New()
	..()
	modules += new /obj/item/weapon/melee/baton/loaded(src)
	modules += new /obj/item/weapon/extinguisher(src)
	modules += new /obj/item/weapon/wrench(src)
	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/device/healthanalyzer(src)
	modules += new /obj/item/weapon/soap/nanotrasen(src)
	modules += new /obj/item/device/taperecorder(src)
	modules += new /obj/item/device/megaphone(src)
	emag = new /obj/item/weapon/melee/energy/sword(src)
	sensor_augs = list("Security", "Medical", "Mesons", "Disable")


	var/obj/item/stack/medical/bruise_pack/B = new /obj/item/stack/medical/bruise_pack(src)
	B.max_amount = 15
	B.amount = 15
	modules += B

	var/obj/item/stack/medical/ointment/O = new /obj/item/stack/medical/ointment(src)
	O.max_amount = 15
	O.amount = 15
	modules += O

	fix_modules()

/obj/item/weapon/robot_module/standard/respawn_consumable(var/mob/living/silicon/robot/R)
	// Recharge baton battery
	for(var/obj/item/weapon/melee/baton/B in modules)
		if(B && B.bcell)
			B.bcell.give(175)
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
				O.max_amount = 15
			modules += O
			O.amount = 1
	return



/obj/item/weapon/robot_module/medical
	name = "medical robot module"


/obj/item/weapon/robot_module/medical/New()
	..()
	modules += new /obj/item/device/healthanalyzer(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo(src)
	modules += new /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg(src,src)
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
	modules += new /obj/item/weapon/crowbar(src)
	emag = new /obj/item/weapon/reagent_containers/spray(src)
	sensor_augs = list("Medical", "Disable")

	emag.reagents.add_reagent(PACID, 250)
	emag.name = "Polyacid spray"

	var/obj/item/stack/medical/advanced/bruise_pack/B = new /obj/item/stack/medical/advanced/bruise_pack(src)
	B.max_amount = 10
	B.amount = 10
	modules += B

	var/obj/item/stack/medical/advanced/ointment/O = new /obj/item/stack/medical/advanced/ointment(src)
	O.max_amount = 10
	O.amount = 10
	modules += O

	var/obj/item/stack/medical/splint/S = new /obj/item/stack/medical/splint(src)
	S.max_amount = 10
	S.amount = 10
	modules += S

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
				O.max_amount = 15
			modules += O
			O.amount = 1
	return


/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"


/obj/item/weapon/robot_module/engineering/New()
	..()
	emag = new /obj/item/borg/stun(src)
	modules += new /obj/item/device/rcd/borg/engineering(src)
	modules += new /obj/item/device/rcd/rpd(src) //What could possibly go wrong?
	modules += new /obj/item/weapon/extinguisher(src)
	modules += new /obj/item/weapon/extinguisher/foam(src)
	modules += new /obj/item/weapon/weldingtool/largetank(src)
	modules += new /obj/item/weapon/screwdriver(src)
	modules += new /obj/item/weapon/wrench(src)
	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/weapon/wirecutters(src)
	modules += new /obj/item/device/multitool(src)
	modules += new /obj/item/device/t_scanner(src)
	modules += new /obj/item/device/analyzer(src)
	modules += new /obj/item/taperoll/atmos(src)
	modules += new /obj/item/taperoll/engineering(src)
	modules += new /obj/item/device/rcd/tile_painter(src)
	modules += new /obj/item/device/material_synth/robot(src)
	modules += new /obj/item/device/silicate_sprayer(src)
	modules += new /obj/item/device/holomap(src)
	sensor_augs = list("Mesons", "Disable")

	var/obj/item/stack/cable_coil/W = new /obj/item/stack/cable_coil(src)
	W.amount = 50
	W.max_amount = 50
	modules += W

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
	if(recharge_tick < recharge_time) return 0
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
	modules += new /obj/item/weapon/melee/baton/loaded(src)
	modules += new /obj/item/weapon/gun/energy/taser/cyborg(src)
	modules += new /obj/item/weapon/handcuffs/cyborg(src)
	modules += new /obj/item/weapon/reagent_containers/spray/pepper(src)
	modules += new /obj/item/taperoll/police(src)
	modules += new /obj/item/weapon/crowbar(src)
	emag = new /obj/item/weapon/gun/energy/laser/cyborg(src)
	sensor_augs = list("Security", "Medical", "Disable")
	fix_modules()

/obj/item/weapon/robot_module/security/respawn_consumable(var/mob/living/silicon/robot/R)
	// Recharge baton battery
	for(var/obj/item/M in modules)
		if(istype(M,/obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B=M
			if(B && B.bcell)
				B.bcell.give(175)

/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"


/obj/item/weapon/robot_module/janitor/New()
	..()
	modules += new /obj/item/weapon/soap/nanotrasen(src)
	modules += new /obj/item/weapon/storage/bag/trash(src)
	modules += new /obj/item/weapon/mop(src)
	modules += new /obj/item/device/lightreplacer/borg(src)
	modules += new /obj/item/weapon/reagent_containers/glass/bucket(src)
	modules += new /obj/item/weapon/crowbar(src)
	emag = new /obj/item/weapon/reagent_containers/spray(src)

	emag.reagents.add_reagent(LUBE, 250)
	emag.name = "Lube spray"
	fix_modules()



/obj/item/weapon/robot_module/butler
	name = "service robot module"


/obj/item/weapon/robot_module/butler/New()
	languages = list(
					LANGUAGE_GALACTIC_COMMON	= 1,
					LANGUAGE_UNATHI		= 1,
					LANGUAGE_SIIK_TAJR	= 1,
					LANGUAGE_SKRELLIAN	= 1,
					LANGUAGE_ROOTSPEAK	= 1,
					LANGUAGE_TRADEBAND	= 1,
					LANGUAGE_GUTTER		= 1,
					LANGUAGE_MONKEY		= 1,
					)
	..()
	modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	modules += new /obj/item/weapon/reagent_containers/food/condiment/enzyme(src)
	modules += new /obj/item/weapon/pen/robopen(src)

	modules += new /obj/item/device/rcd/borg/rsf(src)

	modules += new /obj/item/weapon/reagent_containers/dropper/robodropper(src)

	var/obj/item/weapon/lighter/zippo/L = new /obj/item/weapon/lighter/zippo(src)
	L.lit = 1
	L.update_brightness()
	modules += L

	modules += new /obj/item/weapon/tray/robotray(src)

	modules += new /obj/item/weapon/reagent_containers/food/drinks/shaker(src)

	modules += new /obj/item/weapon/dice/d2(src)

	modules += new /obj/item/weapon/dice/d4(src)

	modules += new /obj/item/weapon/dice(src)

	modules += new /obj/item/weapon/dice/d8(src)

	modules += new /obj/item/weapon/dice/d10(src)

	modules += new /obj/item/weapon/dice/d00(src)

	modules += new /obj/item/weapon/dice/d12(src)

	modules += new /obj/item/weapon/dice/d20(src)

	modules += new /obj/item/weapon/crowbar(src)

	emag = new /obj/item/weapon/reagent_containers/food/drinks/beer(src)

	var/datum/reagents/R = new/datum/reagents(50)
	emag.reagents = R
	R.my_atom = emag
	R.add_reagent(BEER2, 50)
	emag.name = "Mickey Finn's Special Brew"
	fix_modules()



/obj/item/weapon/robot_module/miner
	name = "supply robot module"

/obj/item/weapon/robot_module/miner/New()
	..()
	emag = new /obj/item/borg/stun(src)
	modules += new /obj/item/weapon/storage/bag/ore(src)
	modules += new /obj/item/weapon/pickaxe/drill/borg(src)
	modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)
	modules += new /obj/item/device/mining_scanner(src)
	modules += new /obj/item/weapon/gun/energy/kinetic_accelerator/cyborg(src)
	modules += new /obj/item/weapon/crowbar(src)
	sensor_augs = list("Mesons", "Disable")
//		modules += new /obj/item/weapon/pickaxe/shovel(src) Uneeded due to buffed drill

	var/obj/item/device/destTagger/tag = new /obj/item/device/destTagger(src)
	tag.mode = 1 //For editing the tag list
	modules += tag

	var/obj/item/stack/package_wrap/W = new /obj/item/stack/package_wrap(src)
	W.amount = 24
	W.max_amount = 24
	modules += W

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


/obj/item/weapon/robot_module/syndicate/New()
	modules += new /obj/item/weapon/melee/energy/sword(src)
	modules += new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(src)
	modules += new /obj/item/weapon/card/emag(src)
	modules += new /obj/item/weapon/crowbar(src)
	sensor_augs = list("Security", "Medical", "Mesons", "Thermal", "Light Amplification", "Disable")
	fix_modules()

/obj/item/weapon/robot_module/combat
	name = "combat robot module"

/obj/item/weapon/robot_module/combat/New()
	modules += new /obj/item/weapon/gun/energy/laser/cyborg(src)
	modules += new /obj/item/weapon/pickaxe/plasmacutter(src)
	modules += new /obj/item/borg/combat/shield(src)
	modules += new /obj/item/borg/combat/mobility(src)
	modules += new /obj/item/weapon/wrench(src) //Is a combat android really going to be stopped by a chair?
	modules += new /obj/item/weapon/crowbar(src)
	emag = new /obj/item/weapon/gun/energy/lasercannon/cyborg(src)
	sensor_augs = list("Security", "Medical", "Mesons", "Thermal", "Light Amplification", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/proc/add_languages(var/mob/living/silicon/robot/R)
	for(var/language in languages)
		if(R.add_language(language, languages[language]))
			added_languages |= language

/obj/item/weapon/robot_module/proc/remove_languages(var/mob/living/silicon/robot/R)
	for(var/language in added_languages)
		R.remove_language(language)
	added_languages.len = 0
