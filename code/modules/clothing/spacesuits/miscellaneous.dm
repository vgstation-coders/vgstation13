/obj/item/clothing/suit/proc/step_action() //So that the clown spacesuit can squeak

//Paramedic EVA suit
/obj/item/clothing/head/helmet/space/paramedic
	name = "Paramedic EVA helmet"
	desc = "A paramedic space helmet. Used in the recovery of bodies from space."
	icon_state = "paramedic-eva-helmet"
	item_state = "paramedic-eva-helmet"
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)

/obj/item/clothing/suit/space/paramedic
	name = "Paramedic EVA suit"
	icon_state = "paramedic-eva"
	item_state = "paramedic-eva"
	desc = "A paramedic space suit. Used in the recovery of bodies from space."
	species_restricted = list("exclude",VOX_SHAPED)
	slowdown = HARDSUIT_SLOWDOWN_LOW

//Space santa outfit suit
/obj/item/clothing/head/helmet/space/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"
	flags = FPRINT

/obj/item/clothing/suit/space/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"
	slowdown = NO_SLOWDOWN
	clothing_flags = ONESIZEFITSALL
	allowed = list(/obj/item) //for stuffing exta special presents


//Space pirate outfit
/obj/item/clothing/head/helmet/space/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0.9

/obj/item/clothing/suit/space/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	w_class = W_CLASS_MEDIUM
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen)
	slowdown = NO_SLOWDOWN
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0.9

/obj/item/clothing/suit/space/ghettorig
	name = "jury-rigged space-proof firesuit"
	icon_state = "ghettorig"
	item_state = "ghettorig"
	desc = "A firesuit jury-rigged into being 'space-proof' somehow."
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/weapon/extinguisher)
	pressure_resistance = 4 * ONE_ATMOSPHERE
	slowdown = 5 //just wear a firesuit instead if you want to go fast
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	heat_conductivity = 0 //thanks, blanket
	gas_transfer_coefficient = 0.60
	permeability_coefficient = 0.30

/obj/item/clothing/head/hardhat/red/ghettorig //yes, it's actually just a hardhat
	name = "jury-rigged space-proof fire helmet"
	desc = "A firefighter helmet and gas mask combined and jury-rigged into being 'space-proof' somehow."
	icon = 'icons/mob/head.dmi'
	icon_state = "hardhat0_ghetto"
	item_state = "hardhat0_ghetto"
	_color = "ghetto"
	pressure_resistance = 4 * ONE_ATMOSPHERE
	body_parts_covered = FULL_HEAD|BEARD
	heat_conductivity = 0
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	eyeprot = 0
	species_fit = list(GREY_SHAPED)

/obj/item/clothing/suit/space/ancient //slightly better then an anomalist's space suit
	name = "ancient space suit"
	icon_state = "nasa"
	item_state = "nasa"
	desc = "Drifting, falling, floating, weightless, coming home."
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank)
	armor = list(melee = 10, bullet = 10, laser = 10,energy = 10, bomb = 50, bio = 100, rad = 100)
	species_restricted = list("Human")

/obj/item/clothing/head/helmet/space/ancient
	name = "ancient space helmet"
	icon_state = "nasa"
	item_state = "nasa"
	desc = "Take your protein pills and put your helmet on."
	armor = list(melee = 10, bullet = 10, laser = 10,energy = 10, bomb = 50, bio = 100, rad = 100)
	species_restricted =list("Human")

//Clown Space Suit
/obj/item/clothing/head/helmet/space/clown
	name = "clown helmet"
	desc = "The large grinning clown face on the front of the helmet is equal parts funny and creepy."
	icon_state = "clown-eva-helmet"
	item_state = "clown-eva-helmet"
	species_restricted = list("exclude",VOX_SHAPED)

/obj/item/clothing/suit/space/clown
	name = "clown spacesuit"
	desc = "Many clowns tragically drowned in space before the duck floaty was added to the suit's design."
	icon_state = "clown-eva"
	item_state = "clown-eva"
	species_restricted = list("exclude",VOX_SHAPED)
	allowed = list(/obj/item/weapon/reagent_containers/food/snacks/grown/banana, /obj/item/weapon/bananapeel, /obj/item/weapon/soap, /obj/item/weapon/reagent_containers/spray, /obj/item/weapon/tank)
	slowdown = HARDSUIT_SLOWDOWN_LOW

	var/step_sound = "clownstep"
	var/footstep = 1	//used for squeeks whilst walking

/obj/item/clothing/suit/space/clown/step_action()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc

		if(H.m_intent == "run")
			if(footstep > 1)
				footstep = 0
				playsound(H, step_sound, 50, 1) // this will get annoying very fast.
			else
				footstep++
		else
			playsound(H, step_sound, 20, 1)

//Prisoner Softsuits. Syndi-sprite merely cosmetic and has shit stats
/obj/item/clothing/head/helmet/space/prison
	name = "Prisoner Helmet"
	icon_state = "syndicate-helm-orange"
	item_state = "syndicate-helm-orange"
	desc = "A Orange Space Helmet meant to provide minimal space protection."

/obj/item/clothing/suit/space/prison
	name = "Prisoner Space Suit"
	icon_state = "syndicate-orange"
	item_state = "syndicate-orange"
	desc = "A Orange Space Suit meant to provide minimal space protection."