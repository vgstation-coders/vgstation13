/obj/item/weapon/rig/industrial
	name = "industrial suit control module"
	suit_type = "industrial hardsuit"
	desc = "A heavy, powerful rig used by construction crews and mining corporations."
	icon_state = "engineering_rig"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	slowdown = 3
	offline_slowdown = 10
	offline_vision_restriction = 2

	req_access = null
	req_one_access = null

	initial_modules = list(
		/obj/item/rig_module/device/plasmacutter,
		/obj/item/rig_module/device/drill,
		/obj/item/rig_module/device/orescanner,
		///obj/item/rig_module/device/rcd,
		/obj/item/rig_module/vision/meson
		)

//Chief Engineer's rig. This is sort of a halfway point between the old hardsuits (voidsuits) and the rig class.
/obj/item/weapon/rig/ce

	name = "advanced voidsuit control module"
	suit_type = "advanced voidsuit"
	desc = "An advanced voidsuit that protects against hazardous, low pressure environments. Shines with a high polish."
	icon_state = "ce_rig"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	slowdown = 0
	offline_slowdown = 0
	offline_vision_restriction = 0

	req_access = list(access_ce)

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/device/plasmacutter,
		///obj/item/rig_module/device/rcd,
		/obj/item/rig_module/vision/meson
		)

	boot_type =  null
	glove_type = null

/obj/item/weapon/rig/hazmat

	name = "AMI control module"
	suit_type = "hazmat"
	desc = "An Anomalous Material Interaction hardsuit that protects against the strangest energies the universe can throw at it."
	icon_state = "science_rig"
	armor = list(melee = 15, bullet = 15, laser = 80, energy = 80, bomb = 60, bio = 100, rad = 100)
	slowdown = 1
	offline_slowdown = 3
	offline_vision_restriction = 1

	req_access = list(access_rd)

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/device/anomaly_scanner
		)

	boot_type =  null
	glove_type = null

//Firefighting/Atmos RIG (old /vg/)
/obj/item/clothing/head/helmet/space/void/atmos/gold
	desc = "A special helmet designed for work in hazardous low pressure environments and extreme temperatures. In other words, perfect for atmos."
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE*2
	name = "atmos hardsuit helmet"
	icon_state = "rig0-atmos_gold"
	item_state = "atmos_gold_helm"
	_color = "atmos"
	species_restricted = list("exclude","Vox")
	//no_light=1

/obj/item/clothing/suit/space/void/atmos/gold
	desc = "A special suit that protects against hazardous low pressure environments and extreme temperatures. In other words, perfect for atmos."
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE*4
	gas_transfer_coefficient = 0.80
	permeability_coefficient = 0.25
	icon_state = "rig-atmos_gold"
	name = "atmos hardsuit"
	item_state = "atmos_gold_hardsuit"
	slowdown = 2
	armor = list(melee = 30, bullet = 5, laser = 40,energy = 5, bomb = 35, bio = 100, rad = 60)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/backpack/satchel_norm,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/weapon/rcd, /obj/item/weapon/extinguisher, /obj/item/weapon/)
