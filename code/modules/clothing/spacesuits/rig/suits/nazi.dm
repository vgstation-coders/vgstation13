/obj/item/clothing/head/helmet/space/void/nazi
	name = "nazi hardhelmet"
	desc = "This is the face of das vaterland's top elite. Gas or energy are your only escapes."
	item_state = "rig0-nazi"
	icon_state = "rig0-nazi"
	species_restricted = list("exclude","Vox")//GAS THE VOX
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	_color = "nazi"

/obj/item/clothing/suit/space/void/nazi
	name = "nazi hardsuit"
	desc = "The attire of a true krieger. All shall fall, and only das vaterland will remain."
	item_state = "rig-nazi"
	icon_state = "rig-nazi"
	slowdown = 1
	species_restricted = list("exclude","Vox")//GAS THE VOX
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/)
