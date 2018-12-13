// robot_upgrades.dm
// Contains various borg upgrades.

#define FAILED_TO_ADD 1

/obj/item/borg/upgrade
	name = "A borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	var/locked = FALSE
	var/list/required_module = list()
	var/add_to_mommis = FALSE
	var/list/modules_to_add = list()
	var/multi_upgrades = FALSE
	w_type=RECYK_ELECTRONIC


/obj/item/borg/upgrade/proc/locate_component(var/obj/item/C, var/mob/living/silicon/robot/R, var/mob/living/user)
	if(!C || !R || !user)
		return null

	var/obj/item/I = R.installed_module(C)

	if(!I)
		to_chat(user, "This cyborg is missing one of the needed components!")
		return null
	return I

/obj/item/borg/upgrade/proc/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user, var/ignore_cover = FALSE)
	if(!R.module)
		to_chat(user, "<span class='warning'>The borg must choose a module before he can be upgraded!</span>")
		return FAILED_TO_ADD

	if(isMoMMI(R))
		if(!add_to_mommis)
			to_chat(user, "<span class='warning'>\The [src] only functions on Cyborgs.</span>")
			return FAILED_TO_ADD
	else if(required_module.len)
		if(!(R.module.type in required_module))
			to_chat(user, "<span class='warning'>\The [src] will not fit into \the [R.module.name]!</span>")
			return FAILED_TO_ADD

	if(R.isDead())
		to_chat(user, "<span class='warning'>\The [src] will not function on a deceased robot.</span>")
		return FAILED_TO_ADD

	if(!R.opened && !ignore_cover)
		to_chat(user, "<span class='warning'>You must first open \the [src]'s cover!</span>")
		return FAILED_TO_ADD

	if(!multi_upgrades && (type in R.module.upgrades))
		to_chat(user, "<span class='warning'>There is already \a [src] in [R].</span>")
		return FAILED_TO_ADD

	R.module.upgrades += type

	if(modules_to_add.len)
		for(var/module_to_add in modules_to_add)
			R.module.modules += new module_to_add(R.module)

	to_chat(user, "<span class='notice'>You successfully apply \the [src] to [R].</span>")
	user.drop_item(src, R)

/obj/item/borg/upgrade/reset
	name = "cyborg reset board"
	desc = "Used to reset a cyborg's module. Destroys any other upgrades applied to the robot."
	icon_state = "cyborg_upgrade1"

/obj/item/borg/upgrade/reset/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	if(HAS_MODULE_QUIRK(R, MODULE_IS_DEFINITIVE))
		visible_message("<span class='notice'>[R] buzzes oddly, and ejects \the [src].</span>")
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
	if (heldname)
		desc = "Used to rename a cyborg, or allow a cyborg to rename themselves. Current selected name is \"[heldname]\"."
	else
		desc = "Used to rename a cyborg, or allow a cyborg to rename themselves."

/obj/item/borg/upgrade/rename/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	if (!heldname)
		R.custom_name = null
		R.updatename()
		if(R.can_diagnose()) //Few know this verb exists, hence a message
			to_chat(R, "<span class='info' style=\"font-family:Courier\">You may now change your name through the Namepick verb, under Robot Commands.</span>")
		R.namepick_uses ++
		R.module.upgrades -= /obj/item/borg/upgrade/rename //So you can rename more than once
	else
		R.name = heldname
		R.custom_name = heldname
		R.real_name = heldname
		R.updatename()
		R.updateicon()
		if(R.can_diagnose())
			to_chat(R, "<span class='info' style=\"font-family:Courier\">Your name has been changed to \"[heldname]\".</span>")
		R.module.upgrades -= /obj/item/borg/upgrade/rename

/obj/item/borg/upgrade/restart
	name = "cyborg emergency restart board"
	desc = "Used to force a restart of a disabled-but-repaired robot, bringing it back online."
	icon_state = "cyborg_upgrade1"


/obj/item/borg/upgrade/restart/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	playsound(R, "sound/machines/click.ogg", 20, 1)
	to_chat(user, "You plug the board into the robot's core circuitry.")

	sleep(5)

	if(R.health < 0)
		playsound(R, "sound/machines/buzz-two.ogg", 50, 0)
		to_chat(user, "You have to repair the robot before using this module!")
		return FALSE

	playsound(R, "sound/machines/paistartup.ogg", 50, 1)
	to_chat(user, "<span style=\"font-family:Courier\">Systems reboot initialized successfully.</span>")

	sleep(5)

	if(!R.key)
		for(var/mob/dead/observer/ghost in player_list)
			if(ghost.mind && ghost.mind.current == R)
				R.key = ghost.key

	playsound(R, "sound/voice/liveagain.ogg", 75, 1)
	R.stat = CONSCIOUS
	R.resurrect()

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

/obj/item/borg/upgrade/vtec
	name = "cyborg VTEC upgrade board"
	desc = "Used to kick in a robot's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	add_to_mommis = TRUE

/obj/item/borg/upgrade/vtec/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)

	if(..())
		return FAILED_TO_ADD

	R.movement_speed_modifier += SILICON_VTEC_SPEED_BONUS

/obj/item/borg/upgrade/jetpack
	name = "cyborg jetpack module board"
	desc = "A carbon dioxide jetpack suitable for low-gravity operations."
	icon_state = "cyborg_upgrade3"
	required_module = list(/obj/item/weapon/robot_module/miner, /obj/item/weapon/robot_module/engineering, /obj/item/weapon/robot_module/combat, /obj/item/weapon/robot_module/syndicate/blitzkrieg, /obj/item/weapon/robot_module/syndicate/crisis)
	modules_to_add = list(/obj/item/weapon/tank/jetpack/carbondioxide/silicon)
	add_to_mommis = TRUE

/obj/item/borg/upgrade/jetpack/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	for(var/obj/item/weapon/tank/jetpack/carbondioxide in R.module.modules)
		R.internals = src

/obj/item/borg/upgrade/syndicate/
	name = "cyborg illegal equipment board"
	desc = "Unlocks the hidden, deadlier functions of a robot."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/syndicate/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(R.illegal_weapons == TRUE)
		return FAILED_TO_ADD

	if(..())
		return FAILED_TO_ADD

	message_admins("[key_name_admin(user)] ([user.type]) used \a [name] on [R] (a [R.type]).")

	R.illegal_weapons = TRUE
	R.SetEmagged()

//Medical Stuff
/obj/item/borg/upgrade/medical
	name = "medical cyborg MK-2 upgrade board"
	desc = "Used to give a medical cyborg advanced care tools."
	icon_state = "cyborg_upgrade"
	required_module = list(/obj/item/weapon/robot_module/medical, /obj/item/weapon/robot_module/syndicate/crisis)
	modules_to_add = list(/obj/item/weapon/melee/defibrillator,/obj/item/weapon/reagent_containers/borghypo/upgraded)

/obj/item/borg/upgrade/medical/organ_gripper
	name = "medical cyborg organ gripper upgrade"
	desc = "Used to give a medical cyborg a organ gripper."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper-medical"
	modules_to_add = list(/obj/item/weapon/gripper/organ)

//Engineering stuff
/obj/item/borg/upgrade/engineering
	name = "engineering cyborg MK-2 upgrade board"
	desc = "Adds several tools and materials for the robot to use."
	icon_state = "cyborg_upgrade3"
	required_module = list(/obj/item/weapon/robot_module/engineering)
	modules_to_add = list(/obj/item/weapon/wrench/socket)

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
	required_module = list(/obj/item/weapon/robot_module/engineering)
	modules_to_add = list(/obj/item/weapon/gripper/magnetic)

//Service Stuff
/obj/item/borg/upgrade/cook
	name = "service cyborg cooking upgrade board"
	desc = "Used to give a service cyborg cooking tools and upgrade their service gripper to be able to handle food."
	icon_state = "cyborg_upgrade2"
	required_module = list(/obj/item/weapon/robot_module/butler)
	modules_to_add = list(/obj/item/weapon/kitchen/utensil/knife/large, /obj/item/weapon/kitchen/rollingpin, /obj/item/weapon/storage/bag/food/borg)

/obj/item/borg/upgrade/cook/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	var/obj/item/weapon/gripper/service/G = locate_component(/obj/item/weapon/gripper/service, R, user)
	if(!G)
		return FAILED_TO_ADD

	G.can_hold.Add(/obj/item/weapon/reagent_containers/food)

/obj/item/borg/upgrade/hydro
	name = "service cyborg H.U.E.Y. upgrade board"
	desc = "Used to give a service cyborg hydroponics tools and upgrade their service gripper to be able to handle seeds and glass containers."
	icon_state = "mainboard"
	required_module = list(/obj/item/weapon/robot_module/butler)
	modules_to_add = list(/obj/item/weapon/minihoe, /obj/item/weapon/wirecutters/clippers, /obj/item/weapon/storage/bag/plants/portactor, /obj/item/device/analyzer/plant_analyzer)

/obj/item/borg/upgrade/hydro/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	var/obj/item/weapon/gripper/service/G = locate_component(/obj/item/weapon/gripper/service, R, user)
	if(!G)
		return FAILED_TO_ADD

	G.can_hold.Add(/obj/item/seeds, /obj/item/weapon/reagent_containers/glass)

/obj/item/borg/upgrade/honk
	name = "service cyborg H.O.N.K. upgrade board"
	desc = "Used to give a service cyborg fun toys, Honk!"
	icon_state = "gooncode"
	required_module = list(/obj/item/weapon/robot_module/butler, /obj/item/weapon/robot_module/tg17355)
	modules_to_add = list(/obj/item/weapon/bikehorn, /obj/item/weapon/stamp/clown, /obj/item/toy/crayon/rainbow, /obj/item/toy/waterflower, /obj/item/device/soundsynth)

/obj/item/borg/upgrade/honk/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	if(has_icon(R.icon, "[R.base_icon]-clown")) //Honk!
		R.set_module_sprites(list("Honk" = "[R.base_icon]-clown"))

	var/obj/item/device/harmalarm/H = locate_component(/obj/item/device/harmalarm, R, user)
	if(H)
		H.Honkize()
	var/obj/item/weapon/cookiesynth/C = locate_component(/obj/item/weapon/cookiesynth, R, user)
	if(C)
		C.Honkize()

	playsound(R, 'sound/items/AirHorn.ogg', 50, 1)

	R.module.quirk_flags |= MODULE_IS_A_CLOWN

//Security Stuff
/obj/item/borg/upgrade/tasercooler
	name = "security cyborg rapid taser cooling upgrade board"
	desc = "Used to cool a mounted taser, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	required_module = list(/obj/item/weapon/robot_module/security)
	multi_upgrades = TRUE


/obj/item/borg/upgrade/tasercooler/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	var/obj/item/weapon/gun/energy/taser/cyborg/T = locate_component(/obj/item/weapon/gun/energy/taser/cyborg, R, user)
	if(!T)
		return FAILED_TO_ADD

	if(T.recharge_time <= 2)
		to_chat(R, "Maximum cooling achieved for this hardpoint!")
		to_chat(user, "There's no room for another cooling unit!")
		return FAILED_TO_ADD

	if(..())
		return FAILED_TO_ADD
	else
		T.recharge_time = max(2 , T.recharge_time - 4)

/obj/item/borg/upgrade/noir
	name = "security cyborg N.O.I.R. upgrade board"
	desc = "So that's the way you scientific detectives work. My god! for a fat, middle-aged, hard-boiled, pig-headed guy, you've got the vaguest way of doing things I ever heard of."
	icon_state = "mainboard"
	required_module = list(/obj/item/weapon/robot_module/security, /obj/item/weapon/robot_module/tg17355)
	modules_to_add = list(/obj/item/weapon/gripper/service/noir, /obj/item/weapon/evidencebag, /obj/item/cyborglens, /obj/item/device/taperecorder, /obj/item/weapon/gun/projectile/detective, /obj/item/ammo_storage/speedloader/c38/cyborg)

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

	securify_module(R)

	var/obj/item/weapon/cookiesynth/C = locate_component(/obj/item/weapon/cookiesynth, R, user)
	if(C)
		C.Noirize()

/obj/item/borg/upgrade/warden
	name = "security cyborg W.A.T.C.H. upgrade board"
	desc = "Used to give a security cyborg supervisory enforcement tools."
	icon_state = "mcontroller"
	required_module = list(/obj/item/weapon/robot_module/security, /obj/item/weapon/robot_module/tg17355)
	modules_to_add = list(/obj/item/weapon/batteringram, /obj/item/weapon/implanter/cyborg, /obj/item/weapon/card/robot/security, /obj/item/weapon/wrench)

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

	securify_module(R)

	var/obj/item/weapon/cookiesynth/C = locate_component(/obj/item/weapon/cookiesynth, R, user)
	if(C)
		C.Lawize()

//Supply Stuff
/obj/item/borg/upgrade/hook
	name = "supply cyborg hookshot upgrade"
	desc = "Used to give a supply cyborg a hookshot."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "hookshot"
	required_module = list(/obj/item/weapon/robot_module/miner)
	modules_to_add = list(/obj/item/weapon/gun/hookshot)

#undef FAILED_TO_ADD
