/*
 * Contains:
 *		Fire protection
 *		Bomb protection
 *		Radiation protection
 */

/*
 * Fire protection
 */

/obj/item/clothing/suit/fire
	name = "firesuit"
	desc = "A suit that protects against fire and heat."
	icon_state = "fire"
	item_state = "fire_suit"
	origin_tech = Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=1"
	w_class = W_CLASS_LARGE//bulky item
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS|HIDETAIL
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/weapon/extinguisher,/obj/item/tool/irons,/obj/item/tool/crowbar/halligan)
	slowdown = HARDSUIT_SLOWDOWN_LOW
	clothing_flags = ONESIZEFITSALL
	pressure_resistance = 3 * ONE_ATMOSPHERE
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(VOX_SHAPED)
	flammable = FALSE


/obj/item/clothing/suit/fire/firefighter
	icon_state = "firesuit"
	item_state = "firefighter"
	var/stage = 0

/obj/item/clothing/suit/fire/firefighter/attackby(obj/item/W,mob/user)
	..()
	if(istype(W,/obj/item/clothing/suit/spaceblanket) && !stage)
		stage = 1
		to_chat(user,"<span class='notice'>You add \the [W] to \the [src]</span>")
		qdel(W)
	if(istype(W,/obj/item/stack/cable_coil) && stage == 1)
		var/obj/item/stack/cable_coil/C = W
		if(C.amount <= 4)
			return
		to_chat(user,"<span class='notice'>You tie up \the [src] with some of \the [C]</span>")
		C.use(4)
		var/obj/ghetto = new /obj/item/clothing/suit/space/ghettorig (src.loc)
		qdel(src)
		user.put_in_hands(ghetto)

/obj/item/clothing/suit/fire/heavy
	name = "firesuit"
	desc = "A suit that protects against extreme fire and heat."
	//icon_state = "thermal"
	item_state = "ro_suit"
	w_class = W_CLASS_LARGE//bulky item
	slowdown = HARDSUIT_SLOWDOWN_MED

/*
 * Bomb protection
 */
/obj/item/clothing/head/bomb_hood
	name = "bomb hood"
	desc = "Use in case of bomb."
	icon_state = "bombsuit"
	flags = FPRINT
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 100, bio = 0, rad = 0)
	body_parts_covered = FULL_HEAD|BEARD|HIDEHAIR
	body_parts_visible_override = EYES
	siemens_coefficient = 0
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

	on_armory_manifest = TRUE

/obj/item/clothing/suit/bomb_suit
	name = "bomb suit"
	desc = "A suit designed for safety when handling explosives."
	icon_state = "bombsuit"
	item_state = "bombsuit"
	w_class = W_CLASS_LARGE //Bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags = FPRINT
	body_parts_covered = ARMS|LEGS|FULL_TORSO|HIDETAIL
	slowdown = HARDSUIT_SLOWDOWN_HIGH
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 100, bio = 0, rad = 0)
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	on_armory_manifest = TRUE

/obj/item/clothing/head/bomb_hood/security
	icon_state = "bombsuitsec"
	item_state = "bombsuitsec"


/obj/item/clothing/suit/bomb_suit/security
	icon_state = "bombsuitsec"
	item_state = "bombsuitsec"
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs)

/obj/item/clothing/head/advancedeod_helmet
	name = "Advanced EOD Helmet"
	desc = "Use in case of very large bomb."
	icon_state = "advancedeod_helmet"
	item_state = "advancedeod_helmet"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT
	armor = list(melee = 80, bullet = 80, laser = 40,energy = 20, bomb = 100, bio = 0, rad = 0)
	body_parts_covered = FULL_HEAD|BEARD|HIDEHAIR
	species_restricted = list("exclude",VOX_SHAPED)
	siemens_coefficient = 0



/obj/item/clothing/suit/advancedeod
	name = "Advanced EOD Suit"
	desc = "A heavy suit designed for heavy protection."
	icon_state = "advancedeod"
	item_state = "advancedeod"
	w_class = W_CLASS_LARGE//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags = FPRINT
	body_parts_covered = FULL_TORSO|LEGS|FEET|ARMS
	slowdown = HARDSUIT_SLOWDOWN_MED
	armor = list(melee = 80, bullet = 80, laser = 40,energy = 20, bomb = 100, bio = 0, rad = 0)
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(INSECT_SHAPED)
	species_restricted = list("exclude",VOX_SHAPED)
	siemens_coefficient = 0
	clothing_flags = ONESIZEFITSALL

/*
 * Radiation protection
 */
/obj/item/clothing/head/radiation
	name = "radiation hood"
	icon_state = "rad"
	desc = "A hood with radiation protective properties. Label: Made with lead, do not eat insulation."
	flags = FPRINT
	body_parts_covered = FULL_HEAD|HIDEHAIR
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 60, rad = 100)
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	body_parts_visible_override = EYES|BEARD


/obj/item/clothing/suit/radiation
	name = "radiation suit"
	desc = "A suit that protects against radiation. Label: Made with lead, do not eat insulation."
	icon_state = "rad"
	item_state = "rad_suit"
	w_class = W_CLASS_LARGE//bulky item
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	body_parts_covered = FULL_BODY|HIDETAIL
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen)
	slowdown = 1.5
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 60, rad = 100)
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	clothing_flags = ONESIZEFITSALL

