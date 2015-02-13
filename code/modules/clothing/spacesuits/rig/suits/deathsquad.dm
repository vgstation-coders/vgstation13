/obj/item/clothing/head/helmet/space/void/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "rig0-deathsquad"
	item_state = "rig0-deathsquad"
	armor = list(melee = 65, bullet = 55, laser = 35,energy = 20, bomb = 40, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.2
	species_restricted = list("exclude","Vox")
	_color = "deathsquad"
	flags = FPRINT | STOPSPRESSUREDMG | PLASMAGUARD

/obj/item/clothing/suit/space/void/deathsquad
	name = "deathsquad suit"
	desc = "A heavily armored suit that protects against a lot of things. Used in special operations."
	icon_state = "rig-deathsquad"
	item_state = "rig-deathsquad"
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/weapon/pinpointer,/obj/item/weapon/shield/energy,/obj/item/weapon/plastique,/obj/item/weapon/disk/nuclear)
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 60, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.5
	species_restricted = list("exclude","Vox")
	flags = FPRINT | STOPSPRESSUREDMG | PLASMAGUARD