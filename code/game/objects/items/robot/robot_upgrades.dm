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
		usr << "<span class='warning'>The [src] will not function on a deceased robot.</span>"
		return 1
	if(isMoMMI(R))
		usr << "<span class='warning'>The [src] is only compactible with Nanotrasen Cyborgs.</span>"
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
		R << "Upgrade mounting error!  This module is reserved for medical modules!"
		usr << "There's no mounting point for the module!"
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
		R.module.modules += new/obj/item/weapon/melee/defibrillator
		R.module.modules += new /obj/item/weapon/reagent_containers/borghypo/upgraded(src)

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
	del(R.module)
	R.module = null
	R.camera.network.Remove(list("Engineering","Medical","MINE"))
	R.updatename("Default")
	R.status_flags |= CANPUSH
	R.updateicon()
	R.luminosity = 0 //flashlight fix

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
	R.name = heldname
	R.custom_name = heldname
	R.real_name = heldname

	return 1

/obj/item/borg/upgrade/restart
	name = "robot emergency restart module"
	desc = "Used to force a restart of a disabled-but-repaired robot, bringing it back online."
	icon_state = "cyborg_upgrade1"


/obj/item/borg/upgrade/restart/action(var/mob/living/silicon/robot/R)
	if(R.health < 0)
		usr << "You have to repair the robot before using this module!"
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
		R << "Upgrade mounting error!  No suitable hardpoint detected!"
		usr << "There's no mounting point for the module!"
		return 0

	var/obj/item/weapon/gun/energy/taser/cyborg/T = locate() in R.module
	if(!T)
		T = locate() in R.module.contents
	if(!T)
		T = locate() in R.module.modules
	if(!T)
		usr << "This robot has had its taser removed!"
		return 0

	if(T.recharge_time <= 2)
		R << "Maximum cooling achieved for this hardpoint!"
		usr << "There's no room for another cooling unit!"
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
		R.module.modules += new/obj/item/weapon/tank/jetpack/carbondioxide
		for(var/obj/item/weapon/tank/jetpack/carbondioxide in R.module.modules)
			R.internals = src
		//R.icon_state="Miner+j"
		return 1
	else
		R << "<span class='warning'>Upgrade mounting error!  No suitable hardpoint detected!</span>"
		usr << "<span class='warning'>There's no mounting point for the module!</span>"
		return 0


/obj/item/borg/upgrade/syndicate/
	name = "Illegal Equipment Module"
	desc = "Unlocks the hidden, deadlier functions of a robot."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/syndicate/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(R.emagged == 1)
		return 0

	R.emagged = 1
	return 1

/obj/item/borg/upgrade/construction
	name = "Construction Equipment Upgrade"
	desc = "Used to give engineering cyborgs more materials to work with."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/construction/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(istype(R.module, /obj/item/weapon/robot_module/engineering))
		// Add plasma glass
		var/obj/item/stack/sheet/glass/plasmaglass/PG = new /obj/item/stack/sheet/glass/plasmaglass(src)
		PG.g_amt = 0
		PG.amount = 50
		R.module.modules += PG

		// Add reinforced plasma glass
		var/obj/item/stack/sheet/glass/plasmarglass/PG_R = new /obj/item/stack/sheet/glass/plasmarglass(src)
		PG_R.g_amt = 0
		PG.amount = 50
		R.module.modules += PG_R

		// Add plasteel
		var/obj/item/stack/sheet/plasteel/PS = new /obj/item/stack/sheet/plasteel(src)
		PS.m_amt = 0
		PS.amount = 50
		PS.recipes = null //Remove recipes so that plasteel may only be used for r.walls
		R.module.modules += PS

		// Add a tile painter
		R.module.modules += new/obj/item/weapon/tile_painter

		// Add a bunch of stupid tiles
		var/obj/item/stack/tile/carpet/T_C = new/obj/item/stack/tile/carpet
		T_C.amount = T_C.max_amount
		var/obj/item/stack/tile/wood/T_W = new/obj/item/stack/tile/wood
		T_W.amount = T_W.max_amount
		var/obj/item/stack/tile/grass/T_G = new/obj/item/stack/tile/grass
		T_G.amount = T_G.max_amount
		var/obj/item/stack/tile/light/T_L = new/obj/item/stack/tile/light
		T_L.amount = T_L.max_amount
		T_L.state = 0 //Normal

		R.module.modules += T_C
		R.module.modules += T_W
		R.module.modules += T_G
		R.module.modules += T_L
		return 1
	else
		R << "<span class='warning'>Upgrade mounting error!  No suitable hardpoint detected!</span>"
		usr << "<span class='warning'>There's no mounting point for the module!</span>"
		return 0
