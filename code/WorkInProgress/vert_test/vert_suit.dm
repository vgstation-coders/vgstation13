/obj/item/clothing/head/helmet/space/space_adv
	name = "Space working hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon = 'icons/vert/BL_HEAD.dmi'
	icon_state = "space_adv_head"
	item_state = "space_adv_head"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECITON_TEMPERATURE
	canremove = 1

/obj/item/clothing/suit/space/space_adv
	name = "Space working hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon = 'icons/vert/BL_SPACE.dmi'
	icon_state = "space_adv_body"
	item_state = "space_adv_body"
	slowdown = 1
	species_fit = list("Vox")
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/bag/ore,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/weapon/rcd)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECITON_TEMPERATURE
	canremove = 1
	var/depl = 0
	var/obj/item/clothing/head/helmet/space/space_adv/n_hood //Шлем
	var/mob/living/carbon/affecting = null //The wearer, Без понятия зачем этого, но без него не работает


/obj/item/clothing/suit/space/space_adv/proc/depl()
	set name = "Deploy Helmet"
	set category = "Object"
	set src in usr

	if(!istype(usr:head, /obj/item/clothing/head/helmet/space/space_adv))
		usr << "\red <B>ERROR</B>: 100113 \black UNABLE TO LOCATE HEAD GEAR\nABORTING..."
		depl_a()

		return 0
	affecting = usr
	depl = 1
	canremove = 0
	n_hood = usr:head
	n_hood.canremove = 0
	usr << "\red <B>Complete</B>\n"
	depl_a() //verbs

/obj/item/clothing/suit/space/space_adv/proc/retr()

	set name = "Retract Helmet"
	set category = "Object"
	set src in usr

	affecting = null
	canremove = 1
	if(n_hood)//Should be attached, might not be attached.
		n_hood = usr:head
		n_hood.canremove = 1
		depl = 0
	usr << "\red <B>Complete</B>\n"
	depl_a()


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
