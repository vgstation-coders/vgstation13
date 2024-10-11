// WINTER COATS

/obj/item/clothing/suit/storage/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon_state = "coatwinter"
	item_state = "labcoat"
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	clothing_flags = ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	allowed = list(
		/obj/item/device/flashlight,
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/weapon/tank/emergency_nitrogen)
	hood = new /obj/item/clothing/head/winterhood()

/obj/item/clothing/suit/storage/wintercoat/New()
	if (!hood_up_icon_state)
		hood_up_icon_state = "[icon_state]_t"
	..()

/obj/item/clothing/head/winterhood
	name = "winter hood"
	desc = "A hood attached to a heavy winter jacket."
	icon_state = "whood"
	body_parts_covered = HIDEHEADHAIR
	heat_conductivity = SNOWGEAR_HEAT_CONDUCTIVITY
	wear_override = new/icon("icon" = 'icons/misc/empty.dmi', "icon_state" = "empty")

/obj/item/clothing/suit/storage/wintercoat/security/captain
	name = "captain's winter coat"
	desc = "You guys gonna listen to Garry? You gonna let him give the orders? I mean, he could BE one of those things!"
	icon_state = "coatcaptain"
	clothing_flags = 0
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	armor = list(melee = 20, bullet = 15, laser = 20, energy = 10, bomb = 15, bio = 5, rad = 2)

/obj/item/clothing/suit/storage/wintercoat/security
	name = "security winter coat"
	icon_state = "coatsecurity"
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	armor = list(melee = 40, bullet = 20, laser = 30, energy = 10, bomb = 20, bio = 0, rad = 0)
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
	clothing_flags = 0
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	armor = list(melee = 65, bullet = 30, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	hood = null
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS|IGNORE_INV

/obj/item/clothing/suit/storage/wintercoat/security/warden
	name = "Warden's winter coat"
	icon_state = "coatwarden"
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS|IGNORE_INV
	hood = null

/obj/item/clothing/suit/storage/wintercoat/medical
	name = "medical winter coat"
	icon_state = "coatmedical"
	clothing_flags = 0
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
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
		/obj/item/weapon/switchtool,
		/obj/item/weapon/autopsy_scanner/healthanalyzerpro)

/obj/item/clothing/suit/storage/wintercoat/medical/science //normal labcoats all have the same allowed item list
	name = "science winter coat"
	icon_state = "coatscience"
	clothing_flags = 0
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/wintercoat/engineering
	name = "engineering winter coat"
	icon_state = "coatengineer"
	clothing_flags = 0
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 20)
	allowed = list (
		/obj/item/device/analyzer,
		/obj/item/device/flashlight,
		/obj/item/device/multitool,
		/obj/item/device/radio,
		/obj/item/device/t_scanner,
		/obj/item/tool/crowbar,
		/obj/item/tool/screwdriver,
		/obj/item/tool/weldingtool,
		/obj/item/tool/wirecutters,
		/obj/item/tool/wrench,
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/weapon/tank/emergency_nitrogen,
		/obj/item/device/device_analyser,
		/obj/item/device/rcd)

/obj/item/clothing/suit/storage/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	icon_state = "coatatmos"
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/suit/storage/wintercoat/hydro
	name = "hydroponics winter coat"
	icon_state = "coathydro"
	clothing_flags = 0
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	allowed = list (
		/obj/item/weapon/reagent_containers/spray/plantbgone,
		/obj/item/device/analyzer/plant_analyzer,
		/obj/item/seeds,
		/obj/item/weapon/reagent_containers/glass,
		/obj/item/tool/wirecutters/clippers,
		/obj/item/weapon/minihoe)

/obj/item/clothing/suit/storage/wintercoat/cargo
	name = "cargo winter coat"
	icon_state = "coatcargo"
	clothing_flags = 0
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/suit/storage/wintercoat/prisoner
	name = "prisoner winter coat"
	icon_state = "coatprisoner"
	clothing_flags = 0
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/suit/storage/wintercoat/hop
	name = "Head of Personnel's winter coat"
	icon_state = "coathop"
	clothing_flags = 0
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	desc = "A slightly armoured fur-lined greatcoat. It looks like it's mostly ceremonial."
	armor = list(melee = 30, bullet = 10, laser = 10, energy = 10, bomb = 15, bio = 0, rad = 0)
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
	clothing_flags = 0
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	allowed = list(
		/obj/item/weapon/pickaxe,
		/obj/item/weapon/storage/bag/ore,
		/obj/item/device/mining_scanner,
		/obj/item/weapon/gun/energy/kinetic_accelerator)

/obj/item/clothing/suit/storage/wintercoat/clown
	name = "Elfen winter coat"
	icon_state = "coatclown"
	clothing_flags = 0
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	allowed = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		/obj/item/weapon/bananapeel,
		/obj/item/weapon/soap,
		/obj/item/weapon/reagent_containers/spray,
		/obj/item/weapon/bikehorn)

/obj/item/clothing/suit/storage/wintercoat/mime
	name = "mime winter coat"
	icon_state = "coatmime"
	clothing_flags = 0
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/suit/storage/wintercoat/engineering/ce
	name = "Chief Engineer's winter coat"
	icon_state = "coatce"
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 50)

/obj/item/clothing/suit/storage/wintercoat/medical/cmo
	name = "Chief Medical Officer's winter coat"
	icon_state = "coatcmo"
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 70, rad = 0)

/obj/item/clothing/suit/storage/wintercoat/medical/paramedic
	name = "paramedic winter coat"
	icon_state = "coatpara"
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	allowed = list(
		/obj/item/device/analyzer,
		/obj/item/stack/medical,
		/obj/item/weapon/dnainjector,
		/obj/item/weapon/reagent_containers/dropper,
		/obj/item/weapon/reagent_containers/syringe,
		/obj/item/weapon/reagent_containers/hypospray,
		/obj/item/device/healthanalyzer,
		/obj/item/device/flashlight/pen,
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/weapon/tank/emergency_nitrogen,
		/obj/item/device/radio,
		/obj/item/device/gps,
		/obj/item/roller,
		/obj/item/weapon/autopsy_scanner/healthanalyzerpro,
		/obj/item/device/pcmc)

/obj/item/clothing/suit/storage/wintercoat/engineering/mechanic
	name = "mechanics winter coat"
	icon_state = "coatmech"
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/suit/storage/wintercoat/bartender
	name = "bartender winter coat"
	icon_state = "coatbar"
	clothing_flags = 0
	species_fit = list(GREY_SHAPED, VOX_SHAPED, INSECT_SHAPED)
	desc = "A heavy jacket made from 'synthetic' animal furs. Reinforced to avoid tearing when breaking up bar fights."
	armor = list(melee = 20, bullet = 10, laser = 10, energy = 0, bomb = 10, bio = 0, rad = 0)
	allowed = list(
		/obj/item/weapon/gun/projectile/shotgun/doublebarrel,
		/obj/item/weapon/reagent_containers/food/drinks/shaker,
		/obj/item/weapon/reagent_containers/food/drinks/discount_shaker)

/obj/item/clothing/suit/storage/wintercoat/janitor
	name = "janitor winter coat"
	icon_state = "coatjanitor"
	clothing_flags = 0
	species_fit = list(GREY_SHAPED, VOX_SHAPED)
	allowed = list(
		/obj/item/weapon/soap,
		/obj/item/weapon/caution,
		/obj/item/weapon/reagent_containers/glass/bucket,
		/obj/item/weapon/mop,
		/obj/item/weapon/reagent_containers/spray,
		/obj/item/weapon/grenade/chem_grenade/cleaner
	)


/obj/item/clothing/suit/storage/wintercoat/druid
	name = "druid winter robes"
	icon_state = "druid_snow"
	clothing_flags = 0
	species_fit = list(INSECT_SHAPED)
	wizard_garb = 1


#define HAS_HOOD 1
#define NO_HOOD 0
/*
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
*/

/obj/item/clothing/suit/storage/wintercoat/hoodie
	name = "White hoodie"
	desc = "A casual hoodie to keep you warm and comfy."
	icon_state = "hoodie"
	item_state = "hoodie"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing.dmi')
	clothing_flags = 0
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)
	clothing_flags = COLORS_OVERLAY | ONESIZEFITSALL
	hood_suit_name = "hoodie"

/obj/item/clothing/suit/storage/wintercoat/hoodie/grey
	name = "Grey Hoodie"
	icon_state = "hoodiedark"
	item_state = "hoodiedark"

/obj/item/clothing/suit/storage/wintercoat/hoodie/black
	name = "Black hoodie"
	icon_state = "hoodiedark"
	item_state = "hoodiedark"
	color = "#4A4A4B" //Grey but it looks black

/obj/item/clothing/suit/storage/wintercoat/hoodie/red
	name = "Red hoodie"
	color = "#D91414" //Red

/obj/item/clothing/suit/storage/wintercoat/hoodie/darkred
	name = "Dark red hoodie"
	icon_state = "hoodiedark"
	item_state = "hoodiedark"
	color = "#D91414" //Red

/obj/item/clothing/suit/storage/wintercoat/hoodie/orange
	name = "Orange hoodie"
	color = "#F57600" //orange

/obj/item/clothing/suit/storage/wintercoat/hoodie/yellow
	name = "Yellow hoodie"
	color = "#FDd104" //Yellow

/obj/item/clothing/suit/storage/wintercoat/hoodie/brown
	name = "Brown hoodie"
	color = "#FD8F0d" //orange
	icon_state = "hoodiedark"
	item_state = "hoodiedark"

/obj/item/clothing/suit/storage/wintercoat/hoodie/green
	name = "Green hoodie"
	color = "#009933" //Green

/obj/item/clothing/suit/storage/wintercoat/hoodie/darkgreen
	name = "Dark green hoodie"
	color = "#5C9E54"
	icon_state = "hoodiedark"
	item_state = "hoodiedark"

/obj/item/clothing/suit/storage/wintercoat/hoodie/lime
	name = "Lime hoodie"
	color = "#99ff33" //Lime

/obj/item/clothing/suit/storage/wintercoat/hoodie/blue
	name = "Blue hoodie"
	color = "#0000ff" //Blue

/obj/item/clothing/suit/storage/wintercoat/hoodie/darkblue
	name = "Dark blue hoodie"
	color = "#0000ff" //Blue
	icon_state = "hoodiedark"
	item_state = "hoodiedark"

/obj/item/clothing/suit/storage/wintercoat/hoodie/cyan
	name = "Cyan hoodie"
	color = "#00ffff" //Cyan

/obj/item/clothing/suit/storage/wintercoat/hoodie/teal
	name = "Teal hoodie"
	icon_state = "hoodiedark"
	item_state = "hoodiedark"
	color = "#00ffff" //Cyan

/obj/item/clothing/suit/storage/wintercoat/hoodie/purple
	name = "Purple hoodie"
	color = "#9900CC" //Purple

/obj/item/clothing/suit/storage/wintercoat/hoodie/darkpurple
	name = "Dark purple hoodie"
	color = "#9557C5"
	icon_state = "hoodiedark"
	item_state = "hoodiedark"

/obj/item/clothing/suit/storage/wintercoat/hoodie/pink
	name = "Pink Hoodie"
	color = "#FFCCCC" //Light Pink

/obj/item/clothing/suit/storage/wintercoat/fur // think one of those big vintage fur coats you find in your grandmothers closet
	name = "heavy fur coat"
	icon_state = "furcoat"
	item_state = "furcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS //the sprite extends down to the ankles, it can protect the legs
	clothing_flags = 0
	species_fit = list(INSECT_SHAPED)
	desc = "A thick fur coat. You're not sure what animal its fur is from."
	hood = null //most fur coats dont have a hood
	var/belted = TRUE
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 10, bomb = 5, bio = 0, rad = 0) //its a big thick frontiersman fur coat, putting it on as partially protective
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

/obj/item/clothing/suit/storage/wintercoat/fur/update_icon()
	icon_state="[initial(icon_state)][!belted ? "_beltless" : null]"

/obj/item/clothing/suit/storage/wintercoat/fur/verb/toggle()
	set name = "Toggle Coat Belt"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return 0

	if(belted)
		to_chat(usr, "You remove the coat's belt.")
		src.body_parts_covered |= IGNORE_INV
		sterility = initial(sterility)+30
	else
		to_chat(usr, "You fasten the coat's belt.")
		src.body_parts_covered ^= IGNORE_INV
		sterility = initial(sterility)
	belted=!belted
	update_icon()
	usr.update_inv_wear_suit()	//so our overlays update

/obj/item/clothing/suit/storage/wintercoat/fur/New()
	. = ..()
	actions_types |= list(/datum/action/item_action/toggle_belt)
	update_icon()



