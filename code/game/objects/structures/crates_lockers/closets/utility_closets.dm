/* Utility Closets
 * Contains:
 *		Emergency Closet
 *		Fire Closet
 *		Tool Closet
 *		Radiation Closet
 *		Bombsuit Closet
 *		Hydrant
 *		First Aid
 */

/*
 * Emergency Closet
 */
/obj/structure/closet/emcloset
	name = "emergency closet"
	desc = "It's a storage unit for emergency breathmasks and o2/n2 tanks."
	icon_state = "emergency"
	icon_closed = "emergency"
	icon_opened = "emergencyopen"

/obj/structure/closet/emcloset/atoms_to_spawn()
	var/static/list/small = list(
		/obj/item/weapon/tank/emergency_oxygen = 2,
		/obj/item/clothing/mask/breath = 2,
		/obj/item/weapon/storage/toolbox/emergency,
	)
	var/static/list/aid = list(
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/weapon/storage/toolbox/emergency,
		/obj/item/clothing/mask/breath,
		/obj/item/weapon/storage/firstaid/o2,
	)
	var/static/list/tank = list(
		/obj/item/weapon/tank/emergency_oxygen/engi,
		/obj/item/clothing/mask/breath,
		/obj/item/weapon/tank/emergency_oxygen/engi,
		/obj/item/clothing/mask/breath,
		/obj/item/weapon/storage/firstaid/o2,
	)
	var/static/list/both = list(
		/obj/item/weapon/storage/toolbox/emergency,
		/obj/item/weapon/tank/emergency_oxygen/engi,
		/obj/item/clothing/mask/breath,
		/obj/item/weapon/storage/firstaid/o2,
	)
	var/list/choices = list()
	choices[small] = 55
	choices[aid] = 25
	choices[tank] = 10
	choices[both] = 10
	return pickweight(choices)

/obj/structure/closet/emcloset/legacy/atoms_to_spawn()
	return list(
		/obj/item/weapon/tank/oxygen,
		/obj/item/clothing/mask/gas,
	)


/obj/structure/closet/emcloset/vox
	name = "vox emergency closet"
	desc = "It's full of life-saving equipment.  Assuming, that is, that you breathe nitrogen."
	icon_state = "emergencyvox"
	icon_closed = "emergencyvox"
	icon_opened = "emergencyvoxopen"

/obj/structure/closet/emcloset/vox/atoms_to_spawn()
	return list(
		/obj/item/weapon/tank/nitrogen = 2,
		/obj/item/clothing/mask/breath/vox = 2,
	)

/*
 * Fire Closet
 */
/obj/structure/closet/firecloset
	name = "fire-safety closet"
	desc = "It's a storage unit for fire-fighting supplies."
	icon_state = "firecloset"
	icon_closed = "firecloset"
	icon_opened = "fireclosetopen"

/obj/structure/closet/firecloset/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/fire/firefighter,
		/obj/item/clothing/mask/gas,
		/obj/item/weapon/tank/oxygen/red,
		/obj/item/weapon/extinguisher,
		/obj/item/clothing/head/hardhat/red,
	)

/obj/structure/closet/firecloset/full/atoms_to_spawn()
	return ..() + /obj/item/device/flashlight

/obj/structure/closet/firecloset/update_icon()
	if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened


/*
 * Tool Closet
 */
/obj/structure/closet/toolcloset
	name = "tool closet"
	desc = "It's a storage unit for tools."
	icon_state = "toolcloset"
	icon_closed = "toolcloset"
	icon_opened = "toolclosetopen"

/obj/structure/closet/toolcloset/atoms_to_spawn()
	. = list()
	if(prob(40))
		. += /obj/item/clothing/suit/storage/hazardvest
	if(prob(70))
		. += /obj/item/device/flashlight
	if(prob(70))
		. += /obj/item/weapon/screwdriver
	if(prob(70))
		. += /obj/item/weapon/wrench
	if(prob(70))
		. += /obj/item/weapon/weldingtool
	if(prob(70))
		. += /obj/item/weapon/crowbar
	if(prob(70))
		. += /obj/item/weapon/wirecutters
	if(prob(70))
		. += /obj/item/device/t_scanner
	if(prob(20))
		. += /obj/item/weapon/storage/belt/utility
	if(prob(30))
		. += /obj/item/stack/cable_coil/random
	if(prob(30))
		. += /obj/item/stack/cable_coil/random
	if(prob(30))
		. += /obj/item/stack/cable_coil/random
	if(prob(20))
		. += /obj/item/device/multitool
	if(prob(5))
		. += /obj/item/clothing/gloves/yellow
	if(prob(40))
		. += /obj/item/clothing/head/hardhat


/*
 * Radiation Closet
 */
/obj/structure/closet/radiation
	name = "radiation suit closet"
	desc = "It's a storage unit for rad-protective suits."
	icon_state = "radsuitcloset"
	icon_opened = "toolclosetopen"
	icon_closed = "radsuitcloset"

/obj/structure/closet/radiation/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/radiation = 2,
		/obj/item/clothing/head/radiation = 2,
		/obj/item/device/geiger_counter,
	)

/*
 * Bombsuit closet
 */
/obj/structure/closet/bombcloset
	name = "\improper EOD closet"
	desc = "It's a storage unit for explosion-protective suits."
	icon_state = "bombsuit"
	icon_closed = "bombsuit"
	icon_opened = "bombsuitopen"

/obj/structure/closet/bombcloset/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/bomb_suit,
		/obj/item/clothing/under/color/black,
		/obj/item/clothing/shoes/black,
		/obj/item/clothing/head/bomb_hood,
	)


/obj/structure/closet/bombclosetsecurity
	name = "\improper EOD closet"
	desc = "It's a storage unit for explosion-protective suits."
	icon_state = "bombsuitsec"
	icon_closed = "bombsuitsec"
	icon_opened = "bombsuitsecopen"

/obj/structure/closet/bombclosetsecurity/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/bomb_suit/security,
		/obj/item/clothing/under/rank/security,
		/obj/item/clothing/shoes/brown,
		/obj/item/clothing/head/bomb_hood/security,
	)

/*
 * Hydrant
 */
/obj/structure/closet/hydrant //wall mounted fire closet
	name = "fire-safety closet"
	desc = "It's a storage unit for fire-fighting supplies."
	icon_state = "hydrant"
	icon_closed = "hydrant"
	icon_opened = "hydrant_open"
	anchored = 1
	density = 0
	wall_mounted = 1
	pick_up_stuff = 0 // #367 - Picks up stuff at src.loc, rather than the offset location.

/obj/structure/closet/hydrant/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/fire/firefighter,
		/obj/item/clothing/mask/gas,
		/obj/item/weapon/tank/oxygen/red,
		/obj/item/weapon/extinguisher,
		/obj/item/clothing/head/hardhat/red,
	)

/*
 * First Aid
 */
/obj/structure/closet/medical_wall //wall mounted medical closet
	name = "first-aid closet"
	desc = "It's wall-mounted storage unit for first aid supplies."
	icon_state = "medical_wall"
	icon_closed = "medical_wall"
	icon_opened = "medical_wall_open"
	anchored = 1
	density = 0
	wall_mounted = 1
	pick_up_stuff = 0 // #367 - Picks up stuff at src.loc, rather than the offset location.

/obj/structure/closet/medical_wall/update_icon()
	if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened
