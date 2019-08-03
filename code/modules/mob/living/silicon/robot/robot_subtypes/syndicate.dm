//Syndicate subtype because putting this on new() is fucking retarded.
/mob/living/silicon/robot/syndie
	modtype = "Syndicate"
	icon_state = "robot_old"
	req_access = list(access_syndicate)
	cell_type = /obj/item/weapon/cell/hyper
	startup_sound = 'sound/mecha/nominalsyndi.ogg'
	startup_vary = FALSE
	syndicate = TRUE
	var/obj/item/clothing/accessory/holomap_chip/holochip = null

/mob/living/silicon/robot/syndie/getModules()
	return syndicate_robot_modules

/mob/living/silicon/robot/syndie/GetRobotAccess()
	return get_all_syndicate_access()

/mob/living/silicon/robot/syndie/New()
	..()
	UnlinkSelf()
	laws = new /datum/ai_laws/syndicate_override()

	if(!holochip)
		holochip = new /obj/item/clothing/accessory/holomap_chip/syndicate_robot(src)
		holochip.equipped(src)

/mob/living/silicon/robot/syndie/setup_PDA()
	return

/mob/living/silicon/robot/syndie/blitz/New()
	..()
	pick_module(SYNDIE_BLITZ_MODULE)
	install_upgrade(src, /obj/item/borg/upgrade/jetpack)

/mob/living/silicon/robot/syndie/crisis/New()
	..()
	pick_module(SYNDIE_CRISIS_MODULE)
	install_upgrade(src, /obj/item/borg/upgrade/vtec)