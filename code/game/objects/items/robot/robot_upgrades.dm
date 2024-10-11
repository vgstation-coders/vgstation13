// robot_upgrades.dm
// Contains various borg upgrades.

#define FAILED_TO_ADD 1

/obj/item/borg/upgrade
	name = "robot upgrade"
	desc = "Protected by Firmware Rights Management."
	icon = 'icons/obj/module.dmi'
	var/locked = FALSE
	var/list/required_modules = list()
	var/list/required_upgrades = list()
	var/list/modules_to_add = list()
	var/list/modules_to_remove = list() //Use this if you want to replace or disable items that the borg might already have
	var/multi_upgrades = FALSE
	w_type = RECYK_ELECTRONIC


/obj/item/borg/upgrade/proc/locate_component(var/obj/item/C, var/mob/living/silicon/robot/R, var/mob/living/user)
	if(!C || !R)
		return null

	var/obj/item/I = R.installed_module(C)

	if(!I)
		if(user)
			to_chat(user, "\The [R] is missing one of the needed components!")
		return null

	return I

/obj/item/borg/upgrade/proc/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user, var/ignore_cover = FALSE)
	if(!R.module)
		to_chat(user, "<span class='warning'>\The [R] must choose a module before it can be upgraded!</span>")
		return FAILED_TO_ADD

	if(required_modules.len)
		if(!(R.modtype in required_modules))
			to_chat(user, "<span class='warning'>\The [src] will not fit into \the [R.module.name]!</span>")
			return FAILED_TO_ADD

	if(required_upgrades.len)
		for(var/U in required_upgrades)
			if(!R.module.upgrades.Find(U))
				to_chat(user, "<span class='warning'>\The [R] is missing a required upgrade to install [src].</span>")
				return FAILED_TO_ADD

	if(R.isDead())
		to_chat(user, "<span class='warning'>\The [src] will not function on a broken robot.</span>")
		return FAILED_TO_ADD

	if(!R.opened && !ignore_cover)
		to_chat(user, "<span class='warning'>You must first open \the [R]'s cover!</span>")
		return FAILED_TO_ADD

	if(!multi_upgrades && (type in R.module.upgrades))
		to_chat(user, "<span class='warning'>There is already \a [src] in \the [R].</span>")
		return FAILED_TO_ADD

	R.module.upgrades += type

	if(modules_to_add.len)
		for(var/module_to_add in modules_to_add)
			if(!locate_component(module_to_add, R))
				R.module.modules += new module_to_add(R.module)

	if(modules_to_remove.len)
		for(var/module_to_remove in modules_to_remove)
			var/delete_object = locate_component(module_to_remove, R)
			if(delete_object)
				R.module.modules -= delete_object
				qdel(delete_object)

	to_chat(user, "<span class='notice'>You successfully apply \the [src] to \the [R].</span>")
	user.drop_item(src, R)

/obj/item/borg/upgrade/proc/securify_module(var/mob/living/silicon/robot/R)
	if(!istype(R.module.radio_key, /obj/item/device/encryptionkey/headset_sec)) //If they have no sec key, give them one.
		R.module.ResetEncryptionKey(R)
		R.module.radio_key = /obj/item/device/encryptionkey/headset_sec
		R.module.AddEncryptionKey(R)

	if(!("Security" in R.module.sensor_augs)) //If they don't have a SECHUD, give them one.
		pop(R.module.sensor_augs)
		R.module.sensor_augs.Add("Security", "Disable")

	if(!HAS_MODULE_QUIRK(R, MODULE_IS_THE_LAW)) //Make them able to *law and *halt
		R.module.quirk_flags |= MODULE_IS_THE_LAW

	if(R.modtype == HUG_MODULE)
		var/obj/item/weapon/cookiesynth/C = locate_component(/obj/item/weapon/cookiesynth, R)
		if(C)
			C.Lawize()
		var/obj/item/device/harmalarm/H = locate_component(/obj/item/device/harmalarm, R)
		if(H)
			H.Lawize()

/obj/item/borg/upgrade/reset
	name = "cyborg reset board"
	desc = "Used to reset a cyborg's module. Destroys any other upgrades applied to the robot."
	icon_state = "cyborg_upgrade1"

/obj/item/borg/upgrade/reset/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	if(HAS_MODULE_QUIRK(R, MODULE_IS_DEFINITIVE))
		visible_message("<span class='notice'>\The [R] buzzes oddly, and ejects \the [src].</span>")
		playsound(src, 'sound/machines/buzz-two.ogg', 50, 0)
		R.module.upgrades -= type
		src.forceMove(R.loc)
		return FAILED_TO_ADD

	if(/obj/item/borg/upgrade/vtec in R.module.upgrades)
		R.movement_speed_modifier -= SILICON_VTEC_SPEED_BONUS

	qdel(R.module)
	R.set_module_sprites(list("Default" = "robot"))
	R.updatename("Default")

/obj/item/borg/upgrade/rename
	var/heldname = ""
	name = "cyborg rename board"
	desc = "Used to rename a cyborg, or allow a cyborg to rename themselves."
	icon_state = "cyborg_upgrade1"

/obj/item/borg/upgrade/rename/attack_self(mob/user as mob)
	heldname = reject_bad_name(stripped_input(user, "Enter new robot name to force, or leave clear to let the robot pick a name", "Robot Rename", heldname, MAX_NAME_LEN),1)
	desc = "[initial(desc)][heldname ? " Current selected name is \"[heldname]\".":""]"

/obj/item/borg/upgrade/rename/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	if(!heldname)
		R.custom_name = null
		R.updatename()
		if(R.can_diagnose()) //Few know this verb exists, hence a message
			to_chat(R, "<span class='info' style=\"font-family:Courier\">You may now change your name through the Namepick verb, under Robot Commands.</span>")
		R.namepick_uses ++
	else
		R.name = heldname
		R.custom_name = heldname
		R.real_name = heldname
		R.updatename()
		if(R.can_diagnose())
			to_chat(R, "<span class='info' style=\"font-family:Courier\">Your name has been changed to \"[heldname]\".</span>")
	R.module.upgrades -= /obj/item/borg/upgrade/rename //So you can rename more than once

/obj/item/borg/upgrade/restart
	name = "cyborg emergency restart board"
	desc = "Used to force a restart of a disabled-but-repaired robot, bringing it back online."
	icon_state = "cyborg_upgrade1"

/obj/item/borg/upgrade/restart/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(R.health < 0)
		playsound(R, "sound/machines/buzz-two.ogg", 50, 0)
		to_chat(user, "You have to repair \the [R] before using this module!")
		return FALSE

	playsound(R, "sound/machines/click.ogg", 20, 1)
	to_chat(user, "You plug \the [src] into \the [R]'s core circuitry.")
	sleep(5)
	playsound(R, "sound/machines/paistartup.ogg", 50, 1)
	sleep(5)

	if(!R.key)
		for(var/mob/dead/observer/ghost in player_list)
			if(ghost.mind && ghost.mind.current == R)
				R.key = ghost.key

	playsound(R, "sound/voice/liveagain.ogg", 75, 1)
	R.stat = CONSCIOUS
	R.resurrect()

	if(R.can_diagnose())
		to_chat(R, "<span style=\"font-family:Courier\">System reboot finished successfully.</span>")

/obj/item/borg/upgrade/vtec
	name = "cyborg VTEC upgrade board"
	desc = "Used to kick in a robot's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"

/obj/item/borg/upgrade/vtec/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)

	if(..())
		return FAILED_TO_ADD

	R.movement_speed_modifier += SILICON_VTEC_SPEED_BONUS

/obj/item/borg/upgrade/jetpack
	name = "cyborg jetpack module board"
	desc = "A carbon dioxide jetpack suitable for low-gravity operations."
	icon_state = "cyborg_upgrade3"
	required_modules = list(SUPPLY_MODULE, ENGINEERING_MODULE, COMBAT_MODULE, SYNDIE_BLITZ_MODULE, SYNDIE_CRISIS_MODULE, NANOTRASEN_MOMMI, SOVIET_MOMMI)
	modules_to_add = list(/obj/item/weapon/tank/jetpack/carbondioxide/silicon)

/obj/item/borg/upgrade/jetpack/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	for(var/obj/item/weapon/tank/jetpack/carbondioxide in R.module.modules)
		R.internals = src

/obj/item/borg/upgrade/syndicate
	name = "cyborg illegal equipment board"
	desc = "Unlocks the hidden, deadlier functions of a robot."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/syndicate/New()
	..()
	required_modules = default_nanotrasen_robot_modules + emergency_nanotrasen_robot_modules + special_robot_modules //No MoMMI, i like it the way it is.

/obj/item/borg/upgrade/syndicate/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(R.emagged || R.illegal_weapons) //Dum Dum
		return FAILED_TO_ADD

	if(..())
		return FAILED_TO_ADD

	if(R.can_diagnose())
		to_chat(R, "<span class='danger'>ALERT: Malicious code detected in \the [name].</span>")

	message_admins("[key_name_admin(user)] ([user.type]) used \a [name] on \the [R](\a [R.modtype] [R.braintype]).")

	R.illegal_weapons = TRUE
	R.SetEmagged()

/obj/item/borg/upgrade/bootyborg
	name = "cyborg Backdoor Rearranging Activation Protocol upgrade"
	icon_state = "gooncode"

/obj/item/borg/upgrade/bootyborg/New()
	..()
	required_modules = default_nanotrasen_robot_modules + emergency_nanotrasen_robot_modules

/obj/item/borg/upgrade/bootyborg/attempt_action(var/mob/living/silicon/robot/R, var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	if(R.modtype == SECURITY_MODULE || R.modtype == COMBAT_MODULE)
		R.base_icon = "booty-red"
	else if(R.modtype == ENGINEERING_MODULE || R.modtype == SUPPLY_MODULE)
		R.base_icon = "booty-yellow"
	else if(R.modtype == SERVICE_MODULE)
		R.base_icon = "booty-flower"
	else if(R.modtype == MEDICAL_MODULE)
		R.base_icon = "booty-white"
	else if(R.modtype == JANITOR_MODULE)
		R.base_icon = "booty-green"
	else
		R.base_icon = "booty-blue"
	R.icon_state = R.base_icon

//Medical Stuff
/obj/item/borg/upgrade/medical_upgrade
	name = "medical cyborg MK-2 upgrade board"
	desc = "Used to give a medical cyborg advanced care tools. Also increases storage capacity for medical consumables."
	icon_state = "cyborg_upgrade"
	required_modules = list(MEDICAL_MODULE, SYNDIE_CRISIS_MODULE)
	modules_to_add = list(/obj/item/weapon/melee/defibrillator,/obj/item/weapon/reagent_containers/borghypo/upgraded)

/obj/item/borg/upgrade/medical_upgrade/attempt_action(var/mob/living/silicon/robot/R, var/mob/living/user)
	if(..())
		return FAILED_TO_ADD
	R.module.respawnables_max_amount = MEDICAL_MAX_KIT * 2

/obj/item/borg/upgrade/surgery
	name = "medical cyborg advanced surgery pack"
	desc = "Enables a medical cyborg to have advanced surgery tools."
	icon_state = "cyborg_upgrade"
	required_modules = list(MEDICAL_MODULE, SYNDIE_CRISIS_MODULE)
	modules_to_add = list(/obj/item/tool/scalpel/laser/tier2, /obj/item/tool/circular_saw/plasmasaw,
	/obj/item/tool/retractor/manager, /obj/item/tool/hemostat/pico, /obj/item/tool/surgicaldrill/diamond,
	/obj/item/tool/bonesetter/bone_mender, /obj/item/tool/FixOVein/clot)
	modules_to_remove = list(/obj/item/tool/scalpel, /obj/item/tool/hemostat, /obj/item/tool/retractor,
	/obj/item/tool/circular_saw, /obj/item/tool/cautery, /obj/item/tool/surgicaldrill, /obj/item/tool/bonesetter,
	/obj/item/tool/FixOVein)

/obj/item/borg/upgrade/organ_gripper
	name = "medical cyborg organ gripper upgrade"
	desc = "Used to give a medical cyborg a organ gripper."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper-medical"
	required_modules = list(MEDICAL_MODULE, SYNDIE_CRISIS_MODULE)
	modules_to_add = list(/obj/item/weapon/gripper/organ)

//Engineering stuff
/obj/item/borg/upgrade/engineering
	name = "engineering cyborg MK-2 upgrade board"
	desc = "Adds several tools and materials for the robot to use."
	icon_state = "cyborg_upgrade3"
	required_modules = list(ENGINEERING_MODULE, NANOTRASEN_MOMMI, SOVIET_MOMMI)
	modules_to_add = list(/obj/item/tool/wrench/socket)

/obj/item/borg/upgrade/engineering/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	var/obj/item/device/material_synth/S = locate_component(/obj/item/device/material_synth, R, user)
	if(!S)
		return FAILED_TO_ADD

	S.materials_scanned |= list("plasma glass" = /obj/item/stack/sheet/glass/plasmaglass,
								"reinforced plasma glass" = /obj/item/stack/sheet/glass/plasmarglass,
								"carpet tiles" = /obj/item/stack/tile/carpet)

/obj/item/borg/upgrade/magnetic_gripper
	name = "engineering cyborg magnetic gripper upgrade"
	desc = "Used to give a engineering cyborg a magnetic gripper."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"
	required_modules = list(ENGINEERING_MODULE)
	modules_to_add = list(/obj/item/weapon/gripper/magnetic)

//Service Stuff
/obj/item/borg/upgrade/hydro
	name = "service cyborg H.U.E.Y. upgrade board"
	desc = "Used to give a service cyborg hydroponics tools and upgrade their service gripper to be able to handle seeds and diskettes."
	icon_state = "mainboard"
	required_modules = list(SERVICE_MODULE)
	modules_to_add = list(
		/obj/item/weapon/minihoe,
		/obj/item/weapon/hatchet,
		/obj/item/weapon/pickaxe/shovel/spade,
		/obj/item/tool/wirecutters/clippers,
		/obj/item/weapon/storage/bag/plants/portactor,
		/obj/item/device/analyzer/plant_analyzer,
		/obj/item/weapon/reagent_containers/glass/bottle/robot/water,
		/obj/item/weapon/reagent_containers/glass/bottle/robot/eznutrient
		)

/obj/item/borg/upgrade/hydro/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	var/obj/item/weapon/gripper/service/G = locate_component(/obj/item/weapon/gripper/service, R, user)
	if(!G)
		return FAILED_TO_ADD

	G.can_hold.Add(/obj/item/seeds, /obj/item/weapon/disk/botany)
	G.valid_containers.Add(/obj/item/weapon/storage/lockbox/diskettebox/open/botanydisk,/obj/item/weapon/storage/lockbox/diskettebox/large/open/botanydisk)

/obj/item/borg/upgrade/hydro_adv
	name = "service cyborg H.U.E.Y. MK-2 upgrade board"
	desc = "Used to give a service cyborg more hydroponics tools to combat vines and mutate plants."
	icon_state = "mainboard"
	required_modules = list(SERVICE_MODULE)
	required_upgrades = list(/obj/item/borg/upgrade/hydro)
	modules_to_add = list(
		/obj/item/floral_somatoray,
		/obj/item/weapon/scythe,
		/obj/item/weapon/reagent_containers/spray/plantbgone
		)

/obj/item/borg/upgrade/honk
	name = "service cyborg H.O.N.K. upgrade board"
	desc = "Used to give a service cyborg fun toys, Honk!"
	icon_state = "gooncode"
	required_modules = list(SERVICE_MODULE, HUG_MODULE)
	modules_to_add = list(/obj/item/weapon/bikehorn, /obj/item/weapon/stamp/clown, /obj/item/toy/crayon/rainbow, /obj/item/toy/waterflower, /obj/item/device/soundsynth)

/obj/item/borg/upgrade/honk/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	if(has_icon(R.icon, "[R.base_icon]-clown")) //Honk!
		R.set_module_sprites(list("Honk" = "[R.base_icon]-clown"))

	if(R.modtype == HUG_MODULE)
		var/obj/item/device/harmalarm/H = locate_component(/obj/item/device/harmalarm, R)
		if(H)
			H.Honkize()
		var/obj/item/weapon/cookiesynth/C = locate_component(/obj/item/weapon/cookiesynth, R)
		if(C)
			C.Honkize()

	playsound(R, 'sound/items/AirHorn.ogg', 50, 1)

	R.module.quirk_flags |= MODULE_IS_A_CLOWN

//Security Stuff
/obj/item/borg/upgrade/tasercooler
	name = "security cyborg rapid taser cooling upgrade board"
	desc = "Used to cool a mounted taser, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	required_modules = list(SECURITY_MODULE, HUG_MODULE)
	multi_upgrades = TRUE


/obj/item/borg/upgrade/tasercooler/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	var/obj/item/weapon/gun/energy/taser/cyborg/T = locate_component(/obj/item/weapon/gun/energy/taser/cyborg, R, user)
	if(!T)
		return FAILED_TO_ADD

	if(T.recharge_time <= 2)
		if(R.can_diagnose())
			to_chat(R, "<span style=\"font-family:Courier\">Maximum cooling achieved for \the [T] hardpoint.</span>")
		to_chat(user, "There's no room for another cooling unit!")
		return FAILED_TO_ADD

	T.recharge_time = max(2 , T.recharge_time - 4)


/obj/item/borg/upgrade/noir
	name = "security cyborg N.O.I.R. upgrade board"
	desc = "So that's the way you scientific detectives work. My god! for a fat, middle-aged, hard-boiled, pig-headed guy, you've got the vaguest way of doing things I ever heard of."
	icon_state = "mainboard"
	required_modules = list(SECURITY_MODULE, HUG_MODULE)
	modules_to_add = list(/obj/item/weapon/gripper/service/noir, /obj/item/weapon/storage/evidencebag, /obj/item/cyborglens, /obj/item/device/taperecorder, /obj/item/weapon/gun/projectile/detective, /obj/item/ammo_storage/speedloader/c38/cyborg)

/obj/item/borg/upgrade/noir/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	var/list/new_icons = list()
	if(has_icon(R.icon, "[R.base_icon]-noir"))
		new_icons += list("Hardboiled" = "[R.base_icon]-noir")
	if(has_icon(R.icon, "[R.base_icon]-noirbw"))
		new_icons += list("Noir" = "[R.base_icon]-noirbw")
	if(new_icons.len > 0)
		R.set_module_sprites(new_icons)

	if(R.modtype == HUG_MODULE)
		securify_module(R)

		var/obj/item/weapon/cookiesynth/C = locate_component(/obj/item/weapon/cookiesynth, R)
		if(C)
			C.Noirize()

/obj/item/borg/upgrade/warden
	name = "security cyborg W.A.T.C.H. upgrade board"
	desc = "Used to give a security cyborg supervisory enforcement tools."
	icon_state = "mcontroller"
	required_modules = list(SECURITY_MODULE, HUG_MODULE)
	modules_to_add = list(/obj/item/weapon/batteringram, /obj/item/weapon/implanter/cyborg, /obj/item/weapon/card/robot/security, /obj/item/tool/wrench, /obj/item/weapon/handcuffs/cyborg) //Secborgs have cuffs, but hugborgs can't do warden job properly without them.

/obj/item/borg/upgrade/warden/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	//Trusty warden armor.
	R.component_extension = "/kevlar"
	R.upgrade_components()

	var/list/new_icons = list()
	if(has_icon(R.icon, "[R.base_icon]-warden"))
		new_icons += list("Warden" = "[R.base_icon]-warden")
	if(has_icon(R.icon, "[R.base_icon]-H"))
		new_icons += list("Heavy" = "[R.base_icon]-H")
	if(new_icons.len > 0)
		R.set_module_sprites(new_icons)

	if(R.modtype == HUG_MODULE)
		securify_module(R)

	R.module.quirk_flags |= MODULE_HAS_FLASH_RES

/obj/item/borg/upgrade/hos
	name = "security cyborg H.O.S. upgrade board"
	desc = "A special upgrade used to promote security cyborgs with both N.O.I.R. and W.A.T.C.H. upgrades installed to head of silicons."
	icon_state = "mcontroller"
	required_modules = list(SECURITY_MODULE, HUG_MODULE)
	required_upgrades = list(/obj/item/borg/upgrade/noir, /obj/item/borg/upgrade/warden)
	modules_to_add = list(/obj/item/weapon/gun/lawgiver, /obj/item/weapon/gun/grenadelauncher)

/obj/item/borg/upgrade/hos/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	var/obj/item/weapon/gripper/service/noir/G = locate_component(/obj/item/weapon/gripper/service/noir, R, user)
	if(!G)
		return FAILED_TO_ADD

	var/obj/item/weapon/gun/projectile/detective/PG = locate_component(/obj/item/weapon/gun/projectile/detective, R, user)
	if(!PG)
		return FAILED_TO_ADD

	var/obj/item/ammo_storage/speedloader/c38/cyborg/SL = locate_component(/obj/item/ammo_storage/speedloader/c38/cyborg, R, user)
	if(!SL)
		return FAILED_TO_ADD

	var/obj/item/weapon/gun/energy/taser/cyborg/T = locate_component(/obj/item/weapon/gun/energy/taser/cyborg, R)

	if(T) //Since having a taser isn't necessary for this upgrade, this is fine.
		R.module.modules -= T
		qdel(T)
	R.module.modules -= PG
	qdel(PG)
	R.module.modules -= SL
	qdel(SL)


	G.can_hold.Add(/obj/item/ammo_storage/magazine/lawgiver, /obj/item/weapon/grenade, /obj/item/weapon/reagent_containers/food/snacks/donut)
	G.desc += "This one was also tweaked to be able to hold lawgiver magazines, grenades and... DONUTS!"

	if(!R.dna) //Time to get ready to use that lawgiver.
		R.dna = new /datum/dna(null)
		R.dna.real_name = R.real_name
		R.dna.unique_enzymes = md5(R.dna.real_name)

	if(R.modtype == HUG_MODULE)
		R.set_module_sprites(list("Head of Silicons" = "peaceborg-hos"))

	R.module.quirk_flags |= MODULE_IS_FLASHPROOF | MODULE_IS_DEFINITIVE

//Supply Stuff
/obj/item/borg/upgrade/hook
	name = "supply cyborg hookshot upgrade"
	desc = "Used to give a supply cyborg a hookshot."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "hookshot"
	required_modules = list(SUPPLY_MODULE)
	modules_to_add = list(/obj/item/weapon/gun/hookshot)

/obj/item/borg/upgrade/portosmelter
	name = "supply cyborg portable ore processor upgrade"
	desc = "Used to give a supply cyborg a portable ore processor."
	icon = 'icons/obj/mining.dmi'
	icon_state = "portsmelter0"
	required_modules = list(SUPPLY_MODULE, SOVIET_MOMMI)
	modules_to_add = list(/obj/item/weapon/storage/bag/ore/furnace)

/obj/item/borg/upgrade/xenoarch
	name = "supply cyborg xenoarchaeology upgrade"
	desc = "Used to give a supply cyborg xenoarchaeology tools."
	icon_state = "cyborg_upgrade"
	required_modules = list(SUPPLY_MODULE)
	modules_to_add = list(/obj/item/device/depth_scanner,/obj/item/weapon/pickaxe/excavationdrill,/obj/item/device/measuring_tape,/obj/item/device/core_sampler)

/obj/item/borg/upgrade/xenoarch_adv
	name = "supply cyborg advanced xenoarchaeology upgrade"
	desc = "Used to give a supply cyborg even better xenoarchaeology tools."
	icon_state = "cyborg_upgrade"
	required_modules = list(SUPPLY_MODULE)
	required_upgrades = list(/obj/item/borg/upgrade/xenoarch)
	modules_to_add = list(/obj/item/weapon/pickaxe/excavationdrill/adv,/obj/item/device/xenoarch_scanner/adv,/obj/item/device/artifact_finder)
	modules_to_remove = list(/obj/item/weapon/pickaxe/excavationdrill)

#undef FAILED_TO_ADD
