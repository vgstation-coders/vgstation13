/* Types of tanks!
 * Contains:
 *		Oxygen
 *		Anesthetic
 *		Air
 *		Plasma
 *		Emergency Oxygen
 */

/*
 * Oxygen
 */
/obj/item/weapon/tank/oxygen
	name = "oxygen tank"
	desc = "A tank of oxygen."
	icon_state = "oxygen"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD

/obj/item/weapon/tank/oxygen/New()
	. = ..()
	air_contents.adjust_gas(GAS_OXYGEN, (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/weapon/tank/oxygen/empty/New()
	..()
	air_contents.multiply(0)

/obj/item/weapon/tank/oxygen/yellow
	desc = "A tank of oxygen, this one is yellow."
	icon_state = "oxygen_f"

/obj/item/weapon/tank/oxygen/red
	desc = "A tank of oxygen, this one is red."
	icon_state = "oxygen_fr"


/*
 * Anesthetic
 */
/obj/item/weapon/tank/anesthetic
	name = "anesthetic tank"
	desc = "A tank with an N2O/O2 gas mix."
	icon_state = "anesthetic"
	item_state = "an_tank"

/obj/item/weapon/tank/anesthetic/New()
	. = ..()
	air_contents.adjust_multi(
		GAS_SLEEPING, (3 * ONE_ATMOSPHERE) * 70 / (R_IDEAL_GAS_EQUATION * T20C) * N2STANDARD,
		GAS_OXYGEN, (3 * ONE_ATMOSPHERE) * 70 / (R_IDEAL_GAS_EQUATION * T20C) * O2STANDARD)

/*
 * Air
 */
/obj/item/weapon/tank/air
	name = "air tank"
	desc = "Mixed anyone?"
	icon_state = "oxygen"

/obj/item/weapon/tank/air/New()
	. = ..()
	air_contents.adjust_multi(
		GAS_OXYGEN, (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C) * O2STANDARD,
		GAS_NITROGEN, (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C) * N2STANDARD)

/*
 * Plasma
 */
/obj/item/weapon/tank/plasma
	name = "plasma tank"
	desc = "Contains dangerous plasma. Do not inhale. Warning: extremely flammable."
	icon_state = "plasma"
	flags = FPRINT
	slot_flags = null	//they have no straps!

/obj/item/weapon/tank/plasma/New()
	. = ..()
	air_contents.adjust_gas(GAS_PLASMA, (3 * ONE_ATMOSPHERE) * 70 / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/weapon/tank/plasma/empty/New()
	..()
	air_contents.multiply(0)

/obj/item/weapon/tank/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if (istype(W, /obj/item/weapon/gun/projectile/flamethrower))
		var/obj/item/weapon/gun/projectile/flamethrower/F = W
		if ((!F.status)||(F.ptank))
			return
		src.master = F
		F.ptank = src
		user.before_take_item(src)
		src.forceMove(F)
	return

/obj/item/weapon/tank/plasma/plasmaman
	desc = "The lifeblood of plasmamen.  Warning:  Extremely flammable, do not inhale (unless you're a plasmaman)."
	icon_state = "plasma_fr"
	slot_flags = SLOT_BACK
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD

/obj/item/weapon/tank/emergency_plasma
	name = "emergency plasma tank"
	desc = "Used for emergencies. Contains very little plasma, so try to conserve it until you actually need it."
	icon_state = "emergencyp"
	flags = FPRINT
	slot_flags = SLOT_BELT
	w_class = W_CLASS_SMALL
	force = 4.0
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	volume = 2

/obj/item/weapon/tank/emergency_plasma/New()
	. = ..()
	air_contents.adjust_gas(GAS_PLASMA, (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/weapon/tank/emergency_plasma/engi
	name = "extended-capacity emergency plasma tank"
	icon_state = "emergency_engip"
	volume = 6

/*
 * Emergency Oxygen
 */
/obj/item/weapon/tank/emergency_oxygen
	name = "emergency oxygen tank"
	desc = "Used for emergencies. Contains very little oxygen, so try to conserve it until you actually need it."
	icon_state = "emergency"
	flags = FPRINT
	slot_flags = SLOT_BELT
	w_class = W_CLASS_SMALL
	force = 4.0
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	volume = 2 //Tiny. Real life equivalents only have 21 breaths of oxygen in them. They're EMERGENCY tanks anyway -errorage (dangercon 2011)

/obj/item/weapon/tank/emergency_oxygen/New()
	. = ..()
	air_contents.adjust_gas(GAS_OXYGEN, (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/weapon/tank/emergency_oxygen/engi
	name = "extended-capacity emergency oxygen tank"
	icon_state = "emergency_engi"
	volume = 6

/obj/item/weapon/tank/emergency_oxygen/double
	name = "double emergency oxygen tank"
	icon_state = "emergency_double"
	volume = 10

/obj/item/weapon/tank/emergency_oxygen/double/wizard
	name = "gem-encrusted double emergency oxygen tank"
	icon_state = "oxygen_wiz"
	desc = "A gem-encrusted tank of oxygen. This one is purple and arcane."

/obj/item/weapon/tank/emergency_nitrogen
	name = "emergency nitrogen tank"
	desc = "Used for emergencies. Not useful unless you only breathe nitrogen."
	icon_state = "emergency_nitrogen"
	slot_flags = SLOT_BELT
	w_class = W_CLASS_SMALL
	volume = 2
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD

/obj/item/weapon/tank/emergency_nitrogen/New()
	. = ..()
	air_contents.adjust_gas(GAS_NITROGEN, (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/weapon/tank/emergency_nitrogen/engi
	name = "extended-capacity emergency nitrogen tank"
	icon_state = "emergency_engi"
	volume = 6

/*
 * Nitrogen
 */
/obj/item/weapon/tank/nitrogen
	name = "nitrogen tank"
	desc = "A tank of nitrogen."
	icon_state = "oxygen_fr"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD

/obj/item/weapon/tank/nitrogen/New()
	. = ..()
	air_contents.adjust_gas(GAS_NITROGEN, (3 * ONE_ATMOSPHERE) * 70 / (R_IDEAL_GAS_EQUATION * T20C))
