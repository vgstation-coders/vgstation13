//Captain's Spacesuit
/obj/item/clothing/head/helmet/space/rig/capspace
	name = "Captain's space helmet"
	icon_state = "capspace_0"
	item_state = "capspacehelmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Only for the most fashionable of military figureheads."
	body_parts_covered = HEAD|EARS|EYES
	body_parts_visible_override = EYES
	permeability_coefficient = 0.01
	armor = list(melee = 65, bullet = 50, laser = 50,energy = 25, bomb = 50, bio = 100, rad = 50)
	allowed = list(/obj/item/device/flashlight)
	light_power = 1.7
	light_range = 4
	on = 0
	no_light = 0
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	species_restricted = null


/obj/item/clothing/head/helmet/space/rig/capspace/update_icon()
	icon_state = "capspace_[on]"
	return

/obj/item/clothing/suit/space/rig/captain
	name = "Captain's rig armor"
	desc = "A bulky, heavy-duty piece of exclusive Nanotrasen armor. YOU are in charge!"
	icon_state = "caparmor"
	item_state = "capspacesuit"
	species_restricted = null
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	w_class = W_CLASS_LARGE
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	clothing_flags = ONESIZEFITSALL
	pressure_resistance = 200 * ONE_ATMOSPHERE
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET
	allowed = list(/obj/item/weapon/tank, /obj/item/weapon/tank/emergency_oxygen, /obj/item/device/flashlight,/obj/item/weapon/gun/energy, /obj/item/weapon/gun/projectile, /obj/item/ammo_storage, /obj/item/ammo_casing, /obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_nitrogen)
	slowdown = HARDSUIT_SLOWDOWN_HIGH
	armor = list(melee = 65, bullet = 50, laser = 50, energy = 25, bomb = 50, bio = 100, rad = 50)
	siemens_coefficient = 0.7
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	head_type = /obj/item/clothing/head/helmet/space/rig/capspace

/obj/item/clothing/suit/space/rig/captain/old
	icon_state = "oldcaparmor"

/obj/item/clothing/suit/space/rig/centcomm
	name = "Centcomm rig armor"
	desc = "This bulky armor is the property of Nanotrasen's supreme leader. Witness and behold!"
	icon_state = "centcom"
	item_state = "centcom"
	w_class = W_CLASS_LARGE
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	clothing_flags = ONESIZEFITSALL | PLASMAGUARD
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET
	allowed = list(/obj/item/weapon/tank, /obj/item/weapon/tank/emergency_oxygen, /obj/item/device/flashlight,/obj/item/weapon/gun/energy, /obj/item/weapon/gun/projectile, /obj/item/ammo_storage, /obj/item/ammo_casing, /obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_nitrogen)
	armor = list(melee = 65, bullet = 55, laser = 50, energy = 25, bomb = 50, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	siemens_coefficient = 0
	head_type = /obj/item/clothing/head/helmet/space/rig/capspace

/obj/item/clothing/suit/space/rig/centcomm/old
	icon_state = "oldcentcom"
