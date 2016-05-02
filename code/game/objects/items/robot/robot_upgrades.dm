// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade
	name = "A borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/locked = 0
	var/require_module = 0
	var/installed = 0
	w_type=RECYK_ELECTRONIC

/*
/obj/item/borg/upgrade/recycle(var/datum/materials/rec)
	for(var/material in materials)
		var/rec_mat=material
		var/CCPS=CC_PER_SHEET_MISC
		if(rec_mat=="metal")
			rec_mat="iron"
			CCPS=CC_PER_SHEET_METAL
		if(rec_mat=="glass")
			CCPS=CC_PER_SHEET_GLASS
		rec.addAmount(material,materials[material]/CCPS)
	return w_type
*/

/obj/item/borg/upgrade/proc/action(var/mob/living/silicon/robot/R)
	if(R.stat == DEAD)
		to_chat(usr, "<span class='warning'>The [src] will not function on a deceased robot.</span>")
		return 1
	if(isMoMMI(R))
		to_chat(usr, "<span class='warning'>The [src] only functions on Nanotrasen Cyborgs.</span>")
	return 0



// Medical Cyborg Stuff

/obj/item/borg/upgrade/medical/surgery
	name = "medical module board"
	desc = "Used to give a medical cyborg advanced care tools."
	icon_state = "cyborg_upgrade"
	require_module = 1

/obj/item/borg/upgrade/medical/surgery/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	if(!istype(R.module, /obj/item/weapon/robot_module/medical))
		to_chat(R, "Upgrade mounting error!  This module is reserved for medical modules!")
		to_chat(usr, "There's no mounting point for the module!")
		return 0
	else
/*		R.module.modules += new/obj/item/weapon/circular_saw
		R.module.modules += new/obj/item/weapon/scalpel
		R.module.modules += new/obj/item/weapon/bonesetter
		R.module.modules += new/obj/item/weapon/bonegel // Requested by Hoshi-chan
		R.module.modules += new/obj/item/weapon/FixOVein
		R.module.modules += new/obj/item/weapon/surgicaldrill
		R.module.modules += new/obj/item/weapon/cautery
		R.module.modules += new/obj/item/weapon/hemostat
		R.module.modules += new/obj/item/weapon/retractor*/
		R.module.modules += new /obj/item/weapon/melee/defibrillator(R.module)
		R.module.modules += new /obj/item/weapon/reagent_containers/borghypo/upgraded(R.module)

		return 1

// End of Medical Cyborg Stuff

/obj/item/borg/upgrade/reset
	name = "robotic module reset board"
	desc = "Used to reset a cyborg's module. Destroys any other upgrades applied to the robot."
	icon_state = "cyborg_upgrade1"
	require_module = 1

/obj/item/borg/upgrade/reset/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	R.uneq_all()
	R.hands.icon_state = "nomod"
	R.icon_state = "robot"
	R.base_icon = "robot"
	R.module.remove_languages(R)
	qdel(R.module)
	R.module = null
	R.camera.network.Remove(list("Engineering","Medical","MINE"))
	R.updatename("Default")
	R.status_flags |= CANPUSH
	R.updateicon()
	R.luminosity = 0 //flashlight fix
	R.resurrect()

	return 1

/obj/item/borg/upgrade/rename
	name = "robot reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = "default name"

/obj/item/borg/upgrade/rename/attack_self(mob/user as mob)
	heldname = stripped_input(user, "Enter new robot name", "Robot Reclassification", heldname, MAX_NAME_LEN)

/obj/item/borg/upgrade/rename/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	R.name = ""
	R.custom_name = null
	R.real_name = ""
	R.updatename()
	R.updateicon()
	to_chat(R, "<span class='warning'>You may now change your name.</span>")
	return 1

/obj/item/borg/upgrade/restart
	name = "robot emergency restart module"
	desc = "Used to force a restart of a disabled-but-repaired robot, bringing it back online."
	icon_state = "cyborg_upgrade1"


/obj/item/borg/upgrade/restart/action(var/mob/living/silicon/robot/R)
	if(R.health < 0)
		to_chat(usr, "You have to repair the robot before using this module!")
		return 0

	if(!R.key)
		for(var/mob/dead/observer/ghost in player_list)
			if(ghost.mind && ghost.mind.current == R)
				R.key = ghost.key

	R.stat = CONSCIOUS
	return 1


/obj/item/borg/upgrade/vtec
	name = "robotic VTEC Module"
	desc = "Used to kick in a robot's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	require_module = 1

/obj/item/borg/upgrade/vtec/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(R.speed == -1)
		return 0

	R.speed--
	return 1


/obj/item/borg/upgrade/tasercooler
	name = "robotic Rapid Taser Cooling Module"
	desc = "Used to cool a mounted taser, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	require_module = 1


/obj/item/borg/upgrade/tasercooler/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!istype(R.module, /obj/item/weapon/robot_module/security))
		to_chat(R, "Upgrade mounting error!  No suitable hardpoint detected!")
		to_chat(usr, "There's no mounting point for the module!")
		return 0

	var/obj/item/weapon/gun/energy/taser/cyborg/T = locate() in R.module
	if(!T)
		T = locate() in R.module.contents
	if(!T)
		T = locate() in R.module.modules
	if(!T)
		to_chat(usr, "This robot has had its taser removed!")
		return 0

	if(T.recharge_time <= 2)
		to_chat(R, "Maximum cooling achieved for this hardpoint!")
		to_chat(usr, "There's no room for another cooling unit!")
		return 0

	else
		T.recharge_time = max(2 , T.recharge_time - 4)

	return 1

/obj/item/borg/upgrade/jetpack
	name = "mining robot jetpack"
	desc = "A carbon dioxide jetpack suitable for low-gravity mining operations."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/jetpack/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(istype(R.module, /obj/item/weapon/robot_module/miner) || istype(R.module, /obj/item/weapon/robot_module/engineering) || isMoMMI(R))
		R.module.modules += new/obj/item/weapon/tank/jetpack/carbondioxide(R.module)
		for(var/obj/item/weapon/tank/jetpack/carbondioxide in R.module.modules)
			R.internals = src
		//R.icon_state="Miner+j"
		return 1
	else
		to_chat(R, "<span class='warning'>Upgrade mounting error!  No suitable hardpoint detected!</span>")
		to_chat(usr, "<span class='warning'>There's no mounting point for the module!</span>")
		return 0


/obj/item/borg/upgrade/syndicate/
	name = "Illegal Equipment Module"
	desc = "Unlocks the hidden, deadlier functions of a robot."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/syndicate/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(isMoMMI(R))
		to_chat(R, "<span class='warning'>Your self-protection systems prevent that.</span>")
		message_admins("[key_name_admin(usr)] ([usr.type]) tried to use \a [name] on [R] (a [R.type]).")
		return 0

	if(R.emagged == 1)
		return 0

	message_admins("[key_name_admin(usr)] ([usr.type]) used \a [name] on [R] (a [R.type]).")

	R.SetEmagged(2)
	return 1

/obj/item/borg/upgrade/engineering/
	name = "Engineering Equipment Module"
	desc = "Adds several tools and materials for the robot to use."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/engineering/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!istype(R.module, /obj/item/weapon/robot_module/engineering))
		return 0

	var/obj/item/device/material_synth/S = locate(/obj/item/device/material_synth) in R.module.modules
	if(!S) return 0

	S.materials_scanned |= list("plasma glass" = /obj/item/stack/sheet/glass/plasmaglass,
								"reinforced plasma glass" = /obj/item/stack/sheet/glass/plasmarglass,
								"carpet tiles" = /obj/item/stack/tile/carpet)

	var/obj/item/weapon/wrench/socket/W = locate(/obj/item/weapon/wrench/socket) in R.module.modules
	if(W) return 0

	R.module.modules += new/obj/item/weapon/wrench/socket(R.module)

	return 1

/obj/item/borg/upgrade/service
	name = "service module board"
	desc = "Used to give a service cyborg cooking tools."
	icon_state = "cyborg_upgrade2"
	require_module = 1

/obj/item/borg/upgrade/service/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	if(!istype(R.module, /obj/item/weapon/robot_module/butler))
		to_chat(R, "Upgrade mounting error!  This module is reserved for service modules!")
		to_chat(usr, "There's no mounting point for the module!")
		return 0
	else
		R.module.modules += new /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg(R.module,R.module)
		R.module.modules += new /obj/item/weapon/kitchen/utensil/knife/large(R.module)
		R.module.modules += new /obj/item/weapon/storage/bag/food/borg(R.module)

		return 1
