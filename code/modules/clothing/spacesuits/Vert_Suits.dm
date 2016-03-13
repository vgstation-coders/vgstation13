//Code by vert1881/Lilorien Vert
//Space ninja autif. for e.g


/obj/item/clothing/head/helmet/space/rig/space_adv
	name = "Space working hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "rig.0.rd"
	item_state = "rdhelm"
	armor = list(melee = 60, bullet = 20, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	canremove = 1
	_color = "rd"


/obj/item/clothing/suit/space/rig/space_adv
	name = "Space working hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "rdrig"
	item_state = "rdrig"
	slowdown = 1
	species_fit = list("Vox")
	armor = list(melee = 50, bullet = 40, laser = 30,energy = 5, bomb = 35, bio = 100, rad = 80)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/bag/ore,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe)
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	canremove = 1
	depl_item = "space_adv"


//Space ninja autif. for e.g

                     //____DEPLOY_____//
/obj/item/clothing/suit/space/rig/proc/depl() //Body cheking
	set name = "Deploy helmet of suit"
	set category = "Object"
	set src in usr

	if(istype(usr:wear_suit, /obj/item/clothing/suit/space/rig))
		if(!istype(usr:head, /obj/item/clothing/head))//Head gear cheking
			var/obj/item/clothing/head/helmet/space/rig/n_hood//Шлем
			usr.update_icons()
			affecting = usr
			depl = 1
			canremove = 0
			usr.equip_to_slot_or_del(new depl_item, slot_head) // Helm creation
			n_hood = usr:head
			n_hood.canremove = 0
			usr.update_icons()
			usr.update_hud()
			usr << "\red <B>DEPLOYED</B>\n"
			depl_a() //verbs
			return
		else
			usr << "\red <B>ERROR</B>: 100113 \black HEAD GEAR LOCATED \nABORTING..."
			return 0
	return

/obj/item/clothing/suit/space/rig/proc/retr()
	set name = "Retract helmet of suit"
	set category = "Object"
	set src in usr
	var/obj/item/clothing/head/helmet/space/rig/n_hood //Шлем
	n_hood = usr:head
	usr.update_icons()

	if(n_hood._color  == _color)//HEAD should be attached
		n_hood.canremove = 1
		usr:client.screen -= n_hood
		usr.u_equip(n_hood)
		del(n_hood)
		usr.update_icons()
		usr.update_hud()
		usr.client.screen -= /obj/item/clothing/head/helmet/space/rig
		depl = 0
		canremove = 1
		affecting = null
		usr << "\red <B>RETRACTED</B>\n"
		depl_a()
	else
		usr << "\red <B>ERROR</B>: 100113 \black HEAD GEAR NOT LOCATED \nABORTING..."
	depl_a()
	usr.update_icons()
	usr.update_hud()
	return

/obj/item/clothing/suit/space/rig/proc/depl_a()
	if(depl)
		verbs -= /obj/item/clothing/suit/space/rig/proc/depl
		sleep(5)
		verbs += /obj/item/clothing/suit/space/rig/proc/retr
	else
		verbs -= /obj/item/clothing/suit/space/rig/proc/retr
		sleep(5)
		verbs += /obj/item/clothing/suit/space/rig/proc/depl
	return

/obj/item/clothing/suit/space/rig/space_adv/New()
	..()
	verbs += /obj/item/clothing/suit/space/rig/proc/depl//suit initialize verb

/obj/item/clothing/suit/space/rig/New()
	..()
	verbs += /obj/item/clothing/suit/space/rig/proc/depl//suit initialize verb

/obj/item/weapon/wrench/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(user.zone_sel.selecting == "head")
		src.add_fingerprint(user)
		if(istype(M:wear_suit, /obj/item/clothing/suit/space/rig/))
			user.visible_message("\red [user] begins to unwrench [M]'s suit.", "\red You begin to unwrench the suit of [M].")
			sleep(20)
			var/obj/item/clothing/head/helmet/space/rig/n_hood //Шлем
			var/obj/item/clothing/suit/space/rig/n_body
			n_hood = M:head
			n_body = M:wear_suit
			if(n_hood)
				n_hood.canremove = 1
				M.u_equip(n_hood)
				n_body.canremove = 1
			else
				return ..()
	else
		return ..()
/*
	                 //____OTHER SUITS____//
/obj/item/clothing/head/helmet/space/rig/space_adv/black
	name = "suspicius looking advanced hardsuit helmet"
	desc = "It's a reinforced engineering hardsuit helmet inspiring fear in the ordinary people."
	icon_state = "rig.0.black"
	item_state = "black.helm"
	_color = "black"
	armor = list(melee = 30, bullet = 40, laser = 30, energy = 10, bomb = 50, bio = 100, rad = 100)
	species_restricted = list("exclude","Vox")
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/rig/space_adv/black
	icon_state = "rig-black"
	name = "suspicius looking advanced hardsuit"
	species_restricted = list("exclude","Vox")
	desc = "It's a reinforced engineering hardsuit inspiring fear in the ordinary people."
	item_state = "black_hardsuit"
	icon_state = "black_hardsuit"
	armor = list(melee = 40, bullet = 40, laser = 30, energy = 15, bomb = 50, bio = 100, rad = 100)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECITON_TEMPERATURE

///Military // Cargo color suits
/obj/item/clothing/head/helmet/space/rig/space_adv/military
	name = "Military space hardsuit helmet"
	desc = "A special helmet designed for military forces"
	icon_state = "rig.0.military"
	item_state = "militaryhelm"
	armor = list(melee = 60, bullet = 50, laser = 50, energy = 60, bomb = 75, bio = 100, rad = 80)
	_color = "military"
	/obj/item/clothing/glasses/hud/security/process_hud

/obj/item/clothing/suit/space/rig/space_adv/military
	name = "Military space hardsuit"
	desc = "A special suit designed for military forces, armored with portable plastel armor layer"
	icon_state = "militaryrig"
	item_state = "militaryrig"
	armor = list(melee = 40, bullet = 70, laser = 60, energy = 50, bomb = 75, bio = 100, rad = 80)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/baton)

//SWAT //Red suits
/obj/item/clothing/head/helmet/space/rig/space_adv/swat
	name = "Swat space hardsuit helmet"
	desc = "A special helmet designed for SWAT, armored with close combat kewlar layers"
	icon_state = "rig.0.swat"
	item_state = "secswatrig"
	_color = "swat"
	armor = list(melee = 75, bullet = 50, laser = 30, energy = 20, bomb = 45, bio = 100, rad = 80)
	/obj/item/clothing/glasses/hud/security/process_hud

/obj/item/clothing/suit/space/rig/space_adv/swat
	name = "SWAT space hardsuit"
	desc = "A special suit designed for SWAT, armored with close combat kewlar layers"
	icon_state = "swatrig"
	item_state = "swatrig"
	armor = list(melee = 75, bullet = 50, laser = 30, energy = 10, bomb = 45, bio = 100, rad = 80)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/baton)

// //Rare suits
/obj/item/clothing/head/helmet/space/rig/space_adv/faction
	name = "Suspicious looking special space hardsuit helmet"
	desc = "Heavy modifed SWAT space suit helmet, armored with close combat kewlar layers, bullet armor layer, advanced anti radiation suit hat. "
	icon_state = "rig.0.frac"
	item_state = "fracrig"
	_color = "frac"
	var/brightness_on = 6
	armor = list(melee = 80, bullet = 50, laser = 60, energy = 20, bomb = 45, bio = 100, rad = 100)
	var/vision_mode = 0

	attack_self(mob/living/user as mob)
		if(user.a_intent == "harm")
			switch(vision_mode)
				if(0)
					vision_mode = 0
					user << "\red [src.name] you force switch stupid vision mode to sec hud"
					///obj/item/clothing/glasses/hud/security/process_hud - todo
				if(1)
					vision_mode = 1
					///obj/item/clothing/glasses/thermal - todo
					user << "\red [src.name] you force switch stupid vision mode to thermal"
			return

		..()


/obj/item/clothing/suit/space/rig/space_adv/faction
	name = "Suspicious looking SWAT space hardsuit"
	desc = "Heavy modifed SWAT space suit, armored with close combat kewlar layers, bullet armor layer, advanced anti radiation suit."
	icon_state = "fracrig"
	item_state = "fracrig"
	armor = list(melee = 70, bullet = 70, laser = 60, energy = 25, bomb = 45, bio = 100, rad = 100)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee)

/obj/item/clothing/head/helmet/space/rig/space_adv/roaper
	name = "Roaper space space hardsuit"
	desc = "Unknown suit"
	icon_state = "rig.0.roaper"
	item_state = "roaper"
	_color = "roaper"
	var/brightness_on = 6
	armor = list(melee = 40, bullet = 60, laser = 40, energy = 15, bomb = 45, bio = 100, rad = 100)
	var/vision_mode = 0

/obj/item/clothing/suit/space/rig/space_adv/roaper
	name = "Roaper space hardsuit"
	desc = "unknown suit"
	icon_state = "roaper"
	item_state = "roaper"
	armor = list(melee = 40, bullet = 60, laser = 40, energy = 15, bomb = 45, bio = 100, rad = 100)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee) */


//Code by vert1881/Lilorien Vert && Viton/Ak72ti