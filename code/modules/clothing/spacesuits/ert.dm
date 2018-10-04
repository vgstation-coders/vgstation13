/obj/item/clothing/head/helmet/space/ert
	name = "emergency response team helmet"
	desc = "A helmet worn by members of the Nanotrasen Emergency Response Team. Armoured, space ready and fire resistant."
	icon_state = "ert_commander"
	item_state = "helm-command"
	armor = list(melee = 50, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 100, rad = 60)
	siemens_coefficient = 0.6
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	clothing_flags = PLASMAGUARD
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	pressure_resistance = 200 * ONE_ATMOSPHERE
	eyeprot = 3
	var/id_suffix = "ERT_empty"

/obj/item/clothing/head/helmet/space/ert/equipped(var/mob/M)
	if (!isERT(M) || !ishuman(M))
		return
	var/mob/living/carbon/human/H = M

	var/datum/role/emergency_responder/R = M.mind.GetRole(RESPONDER)
	R.logo_state = "[id_suffix]-logo"

	if(H.get_item_by_slot(slot_head) == src)
		var/obj/item/weapon/card/id/worn_id = H.get_item_by_slot(slot_wear_id)
		if(istype(worn_id))
			if(findtextEx(worn_id.icon_state,"ERT_")!=0)
				worn_id.icon_state = id_suffix

/obj/item/clothing/suit/space/ert
	name = "emergency response team suit"
	desc = "A suit worn by members of the Nanotrasen Emergency Response Team. Armoured, space ready and fire resistant."
	icon_state = "ert_commander"
	item_state = "suit-command"
	w_class = W_CLASS_LARGE
	slowdown = HARDSUIT_SLOWDOWN_LOW
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 100, rad = 60)
	clothing_flags = PLASMAGUARD
	pressure_resistance = 200 * ONE_ATMOSPHERE
	allowed = list(/obj/item/device/flashlight, /obj/item/weapon/tank, /obj/item/device/t_scanner, /obj/item/device/rcd, /obj/item/weapon/crowbar, \
	/obj/item/weapon/screwdriver, /obj/item/weapon/weldingtool, /obj/item/weapon/wirecutters, /obj/item/weapon/wrench, /obj/item/device/multitool, \
	/obj/item/device/radio, /obj/item/device/analyzer, /obj/item/weapon/gun/energy/laser, /obj/item/weapon/gun/energy/pulse_rifle, \
	/obj/item/weapon/gun/energy/taser, /obj/item/weapon/melee/baton, /obj/item/weapon/gun/energy/gun)
	siemens_coefficient = 0.6
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)

//Commander
/obj/item/clothing/head/helmet/space/ert/commander
	name = "emergency response team commander helmet"
	desc = "A helmet worn by the commander of a Nanotrasen Emergency Response Team. Armoured, space ready and fire resistant."
	icon_state = "ert_commander"
	item_state = "helm-command"
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	id_suffix = "ERT_leader"

/obj/item/clothing/suit/space/ert/commander
	name = "emergency response team commander suit"
	desc = "A suit worn by the commander of a Nanotrasen Emergency Response Team. Armoured, space ready and fire resistant."
	icon_state = "ert_commander"
	item_state = "suit-command"
	slowdown = NO_SLOWDOWN

//Security
/obj/item/clothing/head/helmet/space/ert/security
	name = "emergency response team security helmet"
	desc = "A helmet worn by the security members of a Nanotrasen Emergency Response Team. Armoured, space ready and fire resistant."
	icon_state = "ert_security"
	item_state = "syndicate-helm-black-red"
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	id_suffix = "ERT_security"

/obj/item/clothing/suit/space/ert/security
	name = "emergency response team security suit"
	desc = "A suit worn by the security members of a Nanotrasen Emergency Response Team. Armoured, space ready and fire resistant."
	icon_state = "ert_security"
	item_state = "syndicate-black-red"

//Engineer
/obj/item/clothing/head/helmet/space/ert/engineer
	name = "emergency response team engineer helmet"
	desc = "A helmet worn by the engineering members of a Nanotrasen Emergency Response Team. Armoured, space ready and fire resistant. This one is radiation resistant as well."
	icon_state = "ert_engineer"
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	armor = list(melee = 50, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 100, rad = 100)
	id_suffix = "ERT_engineering"

/obj/item/clothing/suit/space/ert/engineer
	name = "emergency response team engineer suit"
	desc = "A suit worn by the engineering members of a Nanotrasen Emergency Response Team. Armoured, space ready and fire resistant."
	icon_state = "ert_engineer"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 100, rad = 100)

//Medical
/obj/item/clothing/head/helmet/space/ert/medical
	name = "emergency response team medical helmet"
	desc = "A helmet worn by the medical members of a Nanotrasen Emergency Response Team. Armoured, space ready and fire resistant."
	icon_state = "ert_medical"
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	id_suffix = "ERT_medical"

/obj/item/clothing/suit/space/ert/medical
	name = "emergency response team medical suit"
	desc = "A suit worn by the medical members of a Nanotrasen Emergency Response Team. Armoured, space ready and fire resistant."
	icon_state = "ert_medical"
	allowed = list(/obj/item/device/flashlight, /obj/item/weapon/tank, /obj/item/device/t_scanner, /obj/item/device/rcd, /obj/item/weapon/crowbar, \
	/obj/item/weapon/screwdriver, /obj/item/weapon/weldingtool, /obj/item/weapon/wirecutters, /obj/item/weapon/wrench, /obj/item/device/multitool, \
	/obj/item/device/radio, /obj/item/device/analyzer, /obj/item/weapon/gun/energy/laser, /obj/item/weapon/gun/energy/pulse_rifle, \
	/obj/item/weapon/gun/energy/taser, /obj/item/weapon/melee/baton, /obj/item/weapon/gun/energy/gun, /obj/item/roller)
