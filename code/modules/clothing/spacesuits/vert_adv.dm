/obj/item/clothing/head/helmet/space/space_adv
	name = "Space working hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "rig0_rd"
	item_state = "rdhelm"
	armor = list(melee = 60, bullet = 20, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECITON_TEMPERATURE
	canremove = 1

/obj/item/clothing/suit/space/space_adv
	name = "Space working hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "rdrig"
	item_state = "rdrig"
	slowdown = 1
	species_fit = list("Vox")
	armor = list(melee = 60, bullet = 40, laser = 30,energy = 5, bomb = 35, bio = 100, rad = 80)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/bag/ore,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/weapon/rcd)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECITON_TEMPERATURE
	canremove = 1
	var/depl = 0
	var/mob/living/carbon/affecting = null //The wearer






                     //____DEPLOY_____//
/obj/item/clothing/suit/space/space_adv/proc/depl() //Body cheking
	set name = "Deploy Helmet"
	set category = "Suit"
	set src in usr

	if(istype(usr:wear_suit, /obj/item/clothing/suit/space/space_adv))
		if(!istype(usr:head, /obj/item/clothing/head))               //Head gear cheking
			var/obj/item/clothing/head/helmet/space/space_adv/n_hood //Шлем
			usr.update_icons()


			affecting = usr
			depl = 1
			canremove = 0
			if(istype(usr:wear_suit, /obj/item/clothing/suit/space/space_adv/military))
				usr.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/space_adv/military, slot_head)
			if(istype(usr:wear_suit, /obj/item/clothing/suit/space/space_adv/swat))
				usr.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/space_adv/swat, slot_head)
			if(istype(usr:wear_suit, /obj/item/clothing/suit/space/space_adv))
				usr.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/space_adv, slot_head)

//			var/obj/item/clothing/head/helmet/space/space_adv
//			usr.contents += /obj/item/clothing/head/helmet/space/space_adv
//			usr:head = /obj/item/clothing/head/helmet/space/space_adv  //Head create

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

                      //____RETRACT_____//
/obj/item/clothing/suit/space/space_adv/proc/retr()

	set name = "Retract Helmet"
	set category = "Suit"
	set src in usr
	var/obj/item/clothing/head/helmet/space/space_adv/n_hood //Шлем
	n_hood = usr:head
	usr.update_icons()

	if(n_hood)//HEAD should be attached

		usr:client.screen -= n_hood
		usr.u_equip(n_hood)
		del(n_hood)
//		usr.contents -= n_hood
//		usr:head = null //Delete head
		usr.update_icons()
		usr.update_hud()
		usr.client.screen -= /obj/item/clothing/head/helmet/space/space_adv

//		canremove = 1
//		n_hood = usr:head
//		n_hood.canremove = 1
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

                     //____CHECKING_____//
/obj/item/clothing/suit/space/space_adv/proc/depl_a()
	if(depl)
		verbs -= /obj/item/clothing/suit/space/space_adv/proc/depl
		verbs += /obj/item/clothing/suit/space/space_adv/proc/retr
	else
		verbs += /obj/item/clothing/suit/space/space_adv/proc/depl
		verbs -= /obj/item/clothing/suit/space/space_adv/proc/retr
	return

/obj/item/clothing/suit/space/space_adv/New()
	..()
	verbs += /obj/item/clothing/suit/space/space_adv/proc/depl//suit initialize verb





	                 //____OTHER SUITS_____//

///Military
/obj/item/clothing/head/helmet/space/space_adv/military
	name = "Military space hardsuit helmet"
	desc = "A special helmet designed for military forces"
	icon_state = "rig0_military"
	item_state = "militaryhelm"
	armor = list(melee = 60, bullet = 70, laser = 60, energy = 50, bomb = 75, bio = 100, rad = 80)

/obj/item/clothing/suit/space/space_adv/military
	name = "Military space hardsuit"
	desc = "A special suit designed for military forces, armored with portable plastel armor layer"
	icon_state = "militaryrig"
	item_state = "militaryrig"
	armor = list(melee = 60, bullet = 80, laser = 60, energy = 50, bomb = 75, bio = 100, rad = 80)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/baton)




//SWAT
/obj/item/clothing/head/helmet/space/space_adv/swat
	name = "Swat space hardsuit helmet"
	desc = "A special helmet designed for SWAT, armored with close combat kewlar layers"
	icon_state = "rig0_swat"
	item_state = "secswatrig"
	armor = list(melee = 90, bullet = 60, laser = 60, energy = 20, bomb = 45, bio = 100, rad = 80)

/obj/item/clothing/suit/space/space_adv/swat
	name = "SWAT space hardsuit"
	desc = "A special suit designed for SWAT, armored with close combat kewlar layers"
	icon_state = "swatrig"
	item_state = "swatrig"
	armor = list(melee = 80, bullet = 50, laser = 50, energy = 20, bomb = 45, bio = 100, rad = 80)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/baton)