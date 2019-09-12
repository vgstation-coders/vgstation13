// WINTER COATS

/obj/item/clothing/suit/storage/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon_state = "coatwinter"
	item_state = "labcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	allowed = list(
		/obj/item/device/flashlight,
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/weapon/tank/emergency_nitrogen)
	var/is_hooded = 0
	var/nohood = 0
	var/obj/item/clothing/head/winterhood/hood
	actions_types = list(/datum/action/item_action/toggle_hood)

/obj/item/clothing/suit/storage/wintercoat/New()
	if(!nohood)
		hood = new(src)
	else
		actions_types = null

	..()

/obj/item/clothing/head/winterhood
	name = "winter hood"
	desc = "A hood attached to a heavy winter jacket."
	icon_state = "whood"
	body_parts_covered = HIDEHEADHAIR
	flags = HIDEHAIRCOMPLETELY
	heat_conductivity = SNOWGEAR_HEAT_CONDUCTIVITY
	var/obj/item/clothing/suit/storage/wintercoat/coat

/obj/item/clothing/head/winterhood/New(var/obj/item/clothing/suit/storage/wintercoat/wc)
	..()
	if(istype(wc))
		coat = wc
	else if(!coat)
		qdel(src)

/obj/item/clothing/suit/storage/wintercoat/security/captain
	name = "captain's winter coat"
	icon_state = "coatcaptain"
	armor = list(melee = 20, bullet = 15, laser = 20, energy = 10, bomb = 15, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/wintercoat/security
	name = "security winter coat"
	icon_state = "coatsecurity"
	armor = list(melee = 25, bullet = 20, laser = 20, energy = 15, bomb = 20, bio = 0, rad = 0)
	allowed = list(
		/obj/item/weapon/gun/energy,
		/obj/item/weapon/reagent_containers/spray/pepper,
		/obj/item/weapon/gun/projectile,
		/obj/item/ammo_storage,
		/obj/item/ammo_casing,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/handcuffs,
		/obj/item/weapon/gun/lawgiver,
		/obj/item/weapon/gun/siren,
		/obj/item/weapon/gun/mahoguny,
		/obj/item/weapon/gun/grenadelauncher,
		/obj/item/weapon/bikehorn/baton,
		/obj/item/weapon/blunderbuss,
		/obj/item/weapon/legcuffs/bolas,
		/obj/item/device/hailer)

/obj/item/clothing/suit/storage/wintercoat/security/hos
	name = "Head of Security's winter coat"
	icon_state = "coathos"
	armor = list(melee = 65, bullet = 30, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	nohood = 1
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS|IGNORE_INV

/obj/item/clothing/suit/storage/wintercoat/security/warden
	name = "Warden's winter coat"
	icon_state = "coatwarden"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS|IGNORE_INV
	nohood = 1

/obj/item/clothing/suit/storage/wintercoat/medical
	name = "medical winter coat"
	icon_state = "coatmedical"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 50, rad = 0)
	allowed = list(
		/obj/item/roller,
		/obj/item/device/analyzer,
		/obj/item/stack/medical,
		/obj/item/weapon/dnainjector,
		/obj/item/weapon/reagent_containers/dropper,
		/obj/item/weapon/reagent_containers/syringe,
		/obj/item/weapon/reagent_containers/hypospray,
		/obj/item/device/healthanalyzer,
		/obj/item/device/flashlight/pen,
		/obj/item/weapon/minihoe,
		/obj/item/weapon/switchtool)

/obj/item/clothing/suit/storage/wintercoat/medical/science //normal labcoats all have the same allowed item list
	name = "science winter coat"
	icon_state = "coatscience"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/wintercoat/engineering
	name = "engineering winter coat"
	icon_state = "coatengineer"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 20)
	allowed = list (
		/obj/item/device/analyzer,
		/obj/item/device/flashlight,
		/obj/item/device/multitool,
		/obj/item/device/radio,
		/obj/item/device/t_scanner,
		/obj/item/weapon/crowbar,
		/obj/item/weapon/screwdriver,
		/obj/item/weapon/weldingtool,
		/obj/item/weapon/wirecutters,
		/obj/item/weapon/wrench,
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/weapon/tank/emergency_nitrogen,
		/obj/item/device/device_analyser,
		/obj/item/device/rcd)

/obj/item/clothing/suit/storage/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	icon_state = "coatatmos"

/obj/item/clothing/suit/storage/wintercoat/hydro
	name = "hydroponics winter coat"
	icon_state = "coathydro"
	allowed = list (
		/obj/item/weapon/reagent_containers/spray/plantbgone,
		/obj/item/device/analyzer/plant_analyzer,
		/obj/item/seeds,
		/obj/item/weapon/reagent_containers/glass,
		/obj/item/weapon/wirecutters/clippers,
		/obj/item/weapon/minihoe)

/obj/item/clothing/suit/storage/wintercoat/cargo
	name = "cargo winter coat"
	icon_state = "coatcargo"

/obj/item/clothing/suit/storage/wintercoat/prisoner
	name = "prisoner winter coat"
	icon_state = "coatprisoner"

/obj/item/clothing/suit/storage/wintercoat/hop
	name = "Head of Personnel's winter coat"
	icon_state = "coathop"
	armor = list(melee = 50, bullet = 10, laser = 25, energy = 10, bomb = 0, bio = 0, rad = 0)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS|IGNORE_INV
	allowed = list(
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/weapon/tank/emergency_nitrogen,
		/obj/item/device/flashlight,
		/obj/item/weapon/gun/energy,
		/obj/item/weapon/gun/projectile,
		/obj/item/ammo_storage,
		/obj/item/ammo_casing,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/handcuffs,
		/obj/item/weapon/storage/fancy/cigarettes,
		/obj/item/weapon/lighter,
		/obj/item/device/detective_scanner,
		/obj/item/device/taperecorder)

/obj/item/clothing/suit/storage/wintercoat/miner
	name = "mining winter coat"
	icon_state = "coatminer"
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	allowed = list(
		/obj/item/weapon/pickaxe,
		/obj/item/weapon/storage/bag/ore,
		/obj/item/device/mining_scanner,
		/obj/item/weapon/gun/energy/kinetic_accelerator)

/obj/item/clothing/suit/storage/wintercoat/clown
	name = "Elfen winter coat"
	icon_state = "coatclown"
	allowed = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		/obj/item/weapon/bananapeel,
		/obj/item/weapon/soap,
		/obj/item/weapon/reagent_containers/spray,
		/obj/item/weapon/bikehorn)

/obj/item/clothing/suit/storage/wintercoat/engineering/ce
	name = "Chief Engineer's winter coat"
	icon_state = "coatce"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 50)

/obj/item/clothing/suit/storage/wintercoat/medical/cmo
	name = "Chief Medical Officer's winter coat"
	icon_state = "coatcmo"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 70, rad = 0)

/obj/item/clothing/suit/storage/wintercoat/medical/paramedic
	name = "paramedic winter coat"
	icon_state = "coatpara"

/obj/item/clothing/suit/storage/wintercoat/engineering/mechanic
	name = "mechanics winter coat"
	icon_state = "coatmech"

/obj/item/clothing/suit/storage/wintercoat/bartender
	name = "bartender winter coat"
	icon_state = "coatbar"
	allowed = list(
		/obj/item/weapon/gun/projectile/shotgun/doublebarrel,
		/obj/item/weapon/reagent_containers/food/drinks/shaker,
		/obj/item/weapon/reagent_containers/food/drinks/discount_shaker)


#define HAS_HOOD 1
#define NO_HOOD 0
/obj/item/clothing/suit/storage/wintercoat/proc/togglehood()
	set name = "Toggle Hood"
	set category = "Object"
	set src in usr
	if(usr.incapacitated())
		return
	else
		var/mob/living/carbon/human/user = usr
		if(!istype(user))
			return
		if(user.get_item_by_slot(slot_wear_suit) != src)
			to_chat(user, "You have to put the coat on first.")
			return
		if(!is_hooded && !user.get_item_by_slot(slot_head) && hood.mob_can_equip(user,slot_head))
			to_chat(user, "You put the hood up.")
			hoodup(user)
		else if(user.get_item_by_slot(slot_head) == hood)
			hooddown(user)
			to_chat(user, "You put the hood down.")
		else
			to_chat(user, "You try to put your hood up, but there is something in the way.")
			return
		user.update_inv_wear_suit()

/obj/item/clothing/suit/storage/wintercoat/attack_self()
	togglehood()

/obj/item/clothing/suit/storage/wintercoat/proc/hoodup(var/mob/living/carbon/human/user)
	user.equip_to_slot(hood, slot_head)
	icon_state = "[initial(icon_state)]_t"
	is_hooded = HAS_HOOD
	user.update_inv_wear_suit()

/obj/item/clothing/suit/storage/wintercoat/proc/hooddown(var/mob/living/carbon/human/user,var/unequip = 1)
	icon_state = "[initial(icon_state)]"
	if(unequip)
		user.u_equip(user.head,0)
	is_hooded = NO_HOOD
	user.update_inv_wear_suit()

/obj/item/clothing/suit/storage/wintercoat/unequipped(var/mob/living/carbon/human/user)
	if(hood && istype(user) && user.get_item_by_slot(slot_head) == hood)
		hooddown(user)

/obj/item/clothing/head/winterhood/pickup(var/mob/living/carbon/human/user)
	if(coat && istype(coat) && user.get_item_by_slot(slot_wear_suit) == coat)
		coat.hooddown(user,unequip = 0)
		user.drop_from_inventory(src)
		forceMove(coat)
