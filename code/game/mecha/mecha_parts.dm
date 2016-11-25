/////////////////////////
////// Mecha Parts //////
/////////////////////////

/obj/item/mecha_parts
	name = "mecha part"
	icon = 'icons/mecha/mech_construct.dmi'
	icon_state = "blank"
	w_class = W_CLASS_GIANT
	flags = FPRINT
	siemens_coefficient = 1
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2"


/obj/item/mecha_parts/chassis
	name="Mecha Chassis"
	icon_state = "backbone"
	var/datum/construction/construct
	flags = FPRINT
	siemens_coefficient = 1

/obj/item/mecha_parts/chassis/attackby(obj/item/W as obj, mob/user as mob)
	if(!construct || !construct.action(W, user))
		..()
	return

/obj/item/mecha_parts/chassis/attack_hand()
	return

/////////// Ripley

/obj/item/mecha_parts/chassis/ripley
	name = "Ripley Chassis"

/obj/item/mecha_parts/chassis/ripley/New()
	..()
	construct = new /datum/construction/mecha_chassis/ripley(src)

/obj/item/mecha_parts/part/ripley_torso
	name="Ripley Torso"
	desc="A torso part of Ripley APLU. Contains power unit, processing core and life support systems."
	icon_state = "ripley_harness"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_BIOTECH + "=2;" + Tc_ENGINEERING + "=2"

/obj/item/mecha_parts/part/ripley_left_arm
	name="Ripley Left Arm"
	desc="A Ripley APLU left arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "ripley_l_arm"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=2"

/obj/item/mecha_parts/part/ripley_right_arm
	name="Ripley Right Arm"
	desc="A Ripley APLU right arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "ripley_r_arm"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=2"

/obj/item/mecha_parts/part/ripley_left_leg
	name="Ripley Left Leg"
	desc="A Ripley APLU left leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "ripley_l_leg"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=2"

/obj/item/mecha_parts/part/ripley_right_leg
	name="Ripley Right Leg"
	desc="A Ripley APLU right leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "ripley_r_leg"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=2"

///////// Gygax

/obj/item/mecha_parts/chassis/gygax
	name = "Gygax Chassis"

/obj/item/mecha_parts/chassis/gygax/New()
	..()
	construct = new /datum/construction/mecha_chassis/gygax(src)

/obj/item/mecha_parts/part/gygax_torso
	name="Gygax Torso"
	desc="A torso part of Gygax. Contains power unit, processing core and life support systems. Has an additional equipment slot."
	icon_state = "gygax_harness"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_BIOTECH + "=3;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/gygax_head
	name="Gygax Head"
	desc="A Gygax head. Houses advanced surveilance and targeting sensors."
	icon_state = "gygax_head"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_MAGNETS + "=3;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/gygax_left_arm
	name="Gygax Left Arm"
	desc="A Gygax left arm. Data and power sockets are compatible with most exosuit tools and weapons."
	icon_state = "gygax_l_arm"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/gygax_right_arm
	name="Gygax Right Arm"
	desc="A Gygax right arm. Data and power sockets are compatible with most exosuit tools and weapons."
	icon_state = "gygax_r_arm"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/gygax_left_leg
	name="Gygax Left Leg"
	icon_state = "gygax_l_leg"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/gygax_right_leg
	name="Gygax Right Leg"
	icon_state = "gygax_r_leg"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/gygax_armour
	name="Gygax Armour Plates"
	icon_state = "gygax_armour"
	origin_tech = Tc_MATERIALS + "=6;" + Tc_COMBAT + "=4;" + Tc_ENGINEERING + "=5"


//////////// Durand

/obj/item/mecha_parts/chassis/durand
	name = "Durand Chassis"

/obj/item/mecha_parts/chassis/durand/New()
	..()
	construct = new /datum/construction/mecha_chassis/durand(src)

/obj/item/mecha_parts/part/durand_torso
	name="Durand Torso"
	icon_state = "durand_harness"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=3;" + Tc_BIOTECH + "=3;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/durand_head
	name="Durand Head"
	icon_state = "durand_head"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=3;" + Tc_MAGNETS + "=3;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/durand_left_arm
	name="Durand Left Arm"
	icon_state = "durand_l_arm"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/durand_right_arm
	name="Durand Right Arm"
	icon_state = "durand_r_arm"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/durand_left_leg
	name="Durand Left Leg"
	icon_state = "durand_l_leg"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/durand_right_leg
	name="Durand Right Leg"
	icon_state = "durand_r_leg"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/durand_armour
	name="Durand Armour Plates"
	icon_state = "durand_armour"
	origin_tech = Tc_MATERIALS + "=5;" + Tc_COMBAT + "=4;" + Tc_ENGINEERING + "=5"



//////////// Marauder

/obj/item/mecha_parts/chassis/marauder
	name = "Marauder Chassis"

/obj/item/mecha_parts/chassis/marauder/New()
	..()
	construct = new /datum/construction/mecha_chassis/marauder(src)

/obj/item/mecha_parts/part/marauder_torso
	name="Marauder Torso"
	icon_state = "marauder_harness"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=3;" + Tc_BIOTECH + "=3;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/marauder_head
	name="Marauder Head"
	icon_state = "marauder_head"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=3;" + Tc_MAGNETS + "=3;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/marauder_left_arm
	name="Marauder Left Arm"
	icon_state = "marauder_l_arm"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/marauder_right_arm
	name="Marauder Right Arm"
	icon_state = "marauder_r_arm"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/marauder_left_leg
	name="Marauder Left Leg"
	icon_state = "marauder_l_leg"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/marauder_right_leg
	name="Marauder Right Leg"
	icon_state = "marauder_r_leg"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=3"

/obj/item/mecha_parts/part/marauder_armour
	name="Marauder Armour Plates"
	icon_state = "marauder_armour"
	origin_tech = Tc_MATERIALS + "=5;" + Tc_COMBAT + "=4;" + Tc_ENGINEERING + "=5"



////////// Firefighter

/obj/item/mecha_parts/chassis/firefighter
	name = "Firefighter Chassis"

/obj/item/mecha_parts/chassis/firefighter/New()
	..()
	construct = new /datum/construction/mecha_chassis/firefighter(src)
/*
/obj/item/mecha_parts/part/firefighter_torso
	name="Ripley-on-Fire Torso"
	icon_state = "ripley_harness"

/obj/item/mecha_parts/part/firefighter_left_arm
	name="Ripley-on-Fire Left Arm"
	icon_state = "ripley_l_arm"

/obj/item/mecha_parts/part/firefighter_right_arm
	name="Ripley-on-Fire Right Arm"
	icon_state = "ripley_r_arm"

/obj/item/mecha_parts/part/firefighter_left_leg
	name="Ripley-on-Fire Left Leg"
	icon_state = "ripley_l_leg"

/obj/item/mecha_parts/part/firefighter_right_leg
	name="Ripley-on-Fire Right Leg"
	icon_state = "ripley_r_leg"
*/

////////// HONK

/obj/item/mecha_parts/chassis/honker
	name = "H.O.N.K Chassis"

/obj/item/mecha_parts/chassis/honker/New()
	..()
	construct = new /datum/construction/mecha_chassis/honker(src)

/obj/item/mecha_parts/part/honker_torso
	name="H.O.N.K Torso"
	icon_state = "honker_harness"

/obj/item/mecha_parts/part/honker_head
	name="H.O.N.K Head"
	icon_state = "honker_head"

/obj/item/mecha_parts/part/honker_left_arm
	name="H.O.N.K Left Arm"
	icon_state = "honker_l_arm"

/obj/item/mecha_parts/part/honker_right_arm
	name="H.O.N.K Right Arm"
	icon_state = "honker_r_arm"

/obj/item/mecha_parts/part/honker_left_leg
	name="H.O.N.K Left Leg"
	icon_state = "honker_l_leg"

/obj/item/mecha_parts/part/honker_right_leg
	name="H.O.N.K Right Leg"
	icon_state = "honker_r_leg"


////////// Phazon

/obj/item/mecha_parts/chassis/phazon
	name = "Phazon Chassis"
	origin_tech = Tc_MATERIALS + "=7"

/obj/item/mecha_parts/chassis/phazon/New()
	..()
	construct = new /datum/construction/mecha_chassis/phazon(src)

/obj/item/mecha_parts/part/phazon_torso
	name="Phazon Torso"
	icon_state = "phazon_harness"
	origin_tech = Tc_PROGRAMMING + "=5;" + Tc_MATERIALS + "=9;" + Tc_BLUESPACE + "=10;" + Tc_POWERSTORAGE + "=6"

/obj/item/mecha_parts/part/phazon_head
	name="Phazon Head"
	icon_state = "phazon_head"
	origin_tech = Tc_PROGRAMMING + "=5;" + Tc_MATERIALS + "=9;" + Tc_MAGNETS + "=6"

/obj/item/mecha_parts/part/phazon_left_arm
	name="Phazon Left Arm"
	icon_state = "phazon_l_arm"
	origin_tech = Tc_MATERIALS + "=9;" + Tc_BLUESPACE + "=6;" + Tc_MAGNETS + "=2"

/obj/item/mecha_parts/part/phazon_right_arm
	name="Phazon Right Arm"
	icon_state = "phazon_r_arm"
	origin_tech = Tc_MATERIALS + "=9;" + Tc_BLUESPACE + "=6;" + Tc_MAGNETS + "=2"

/obj/item/mecha_parts/part/phazon_left_leg
	name="Phazon Left Leg"
	icon_state = "phazon_l_leg"
	origin_tech = Tc_MATERIALS + "=9;" + Tc_BLUESPACE + "=6;" + Tc_MAGNETS + "=3"

/obj/item/mecha_parts/part/phazon_right_leg
	name="Phazon Right Leg"
	icon_state = "phazon_r_leg"
	origin_tech = Tc_MATERIALS + "=9;" + Tc_BLUESPACE + "=6;" + Tc_MAGNETS + "=3"

/obj/item/mecha_parts/part/phazon_phase_array
	name="Phase Array"
	icon_state = "phazon_phase_array"
	origin_tech = Tc_MATERIALS + "=9;" + Tc_BLUESPACE + "=10;" + Tc_MAGNETS + "=3"

///////// Odysseus


/obj/item/mecha_parts/chassis/odysseus
	name = "Odysseus Chassis"

/obj/item/mecha_parts/chassis/odysseus/New()
	..()
	construct = new /datum/construction/mecha_chassis/odysseus(src)

/obj/item/mecha_parts/part/odysseus_head
	name="Odysseus Head"
	icon_state = "odysseus_head"
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_MATERIALS + "=2"

/obj/item/mecha_parts/part/odysseus_torso
	name="Odysseus Torso"
	desc="A torso part of Odysseus. Contains power unit, processing core and life support systems."
	icon_state = "odysseus_torso"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_BIOTECH + "=2;" + Tc_ENGINEERING + "=2"

/obj/item/mecha_parts/part/odysseus_left_arm
	name="Odysseus Left Arm"
	desc="An Odysseus left arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "odysseus_l_arm"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=2"

/obj/item/mecha_parts/part/odysseus_right_arm
	name="Odysseus Right Arm"
	desc="An Odysseus right arm. Data and power sockets are compatible with most exosuit tools."
	icon_state = "odysseus_r_arm"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=2"

/obj/item/mecha_parts/part/odysseus_left_leg
	name="Odysseus Left Leg"
	desc="An Odysseus left leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "odysseus_l_leg"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=2"

/obj/item/mecha_parts/part/odysseus_right_leg
	name="Odysseus Right Leg"
	desc="A Odysseus right leg. Contains somewhat complex servodrives and balance maintaining systems."
	icon_state = "odysseus_r_leg"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=2"

/*/obj/item/mecha_parts/part/odysseus_armour
	name="Odysseus Carapace"
	icon_state = "odysseus_armour"
	origin_tech = Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=3"
	construction_time = 200
	materials = list(MAT_IRON=15000)*/


///////// Circuitboards

/obj/item/weapon/circuitboard/mecha
	name = "Exosuit Circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "circuitboard"
	board_type = OTHER
	flags = FPRINT
	siemens_coefficient = 1
	force = 5.0
	w_class = W_CLASS_SMALL
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15

/obj/item/weapon/circuitboard/mecha/ripley
	origin_tech = Tc_PROGRAMMING + "=3"

/obj/item/weapon/circuitboard/mecha/ripley/peripherals
	name = "Circuit board (Ripley Peripherals Control module)"
	icon_state = "mcontroller"

/obj/item/weapon/circuitboard/mecha/ripley/main
	name = "Circuit board (Ripley Central Control module)"
	icon_state = "mainboard"

/obj/item/weapon/circuitboard/mecha/gygax
	origin_tech = Tc_PROGRAMMING + "=4"

/obj/item/weapon/circuitboard/mecha/gygax/peripherals
	name = "Circuit board (Gygax Peripherals Control module)"
	icon_state = "mcontroller"

/obj/item/weapon/circuitboard/mecha/gygax/targeting
	name = "Circuit board (Gygax Weapon Control and Targeting module)"
	icon_state = "mcontroller"
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_COMBAT + "=4"

/obj/item/weapon/circuitboard/mecha/gygax/main
	name = "Circuit board (Gygax Central Control module)"
	icon_state = "mainboard"

/obj/item/weapon/circuitboard/mecha/durand
	origin_tech = Tc_PROGRAMMING + "=4"

/obj/item/weapon/circuitboard/mecha/durand/peripherals
	name = "Circuit board (Durand Peripherals Control module)"
	icon_state = "mcontroller"

/obj/item/weapon/circuitboard/mecha/durand/targeting
	name = "Circuit board (Durand Weapon Control and Targeting module)"
	icon_state = "mcontroller"
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_COMBAT + "=4"

/obj/item/weapon/circuitboard/mecha/durand/main
	name = "Circuit board (Durand Central Control module)"
	icon_state = "mainboard"

/obj/item/weapon/circuitboard/mecha/marauder
	origin_tech = Tc_PROGRAMMING + "=4"

/obj/item/weapon/circuitboard/mecha/marauder/peripherals
	name = "Circuit board (Marauder Peripherals Control module)"
	icon_state = "mcontroller"

/obj/item/weapon/circuitboard/mecha/marauder/targeting
	name = "Circuit board (Marauder Weapon Control and Targeting module)"
	icon_state = "mcontroller"
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_COMBAT + "=4"

/obj/item/weapon/circuitboard/mecha/marauder/main
	name = "Circuit board (Marauder Central Control module)"
	icon_state = "mainboard"

/obj/item/weapon/circuitboard/mecha/honker
	origin_tech = Tc_PROGRAMMING + "=4"

/obj/item/weapon/circuitboard/mecha/honker/peripherals
	name = "Circuit board (H.O.N.K Peripherals Control module)"
	icon_state = "mcontroller"

/obj/item/weapon/circuitboard/mecha/honker/targeting
	name = "Circuit board (H.O.N.K Weapon Control and Targeting module)"
	icon_state = "mcontroller"

/obj/item/weapon/circuitboard/mecha/honker/main
	name = "Circuit board (H.O.N.K Central Control module)"
	icon_state = "mainboard"

/obj/item/weapon/circuitboard/mecha/odysseus
	origin_tech = Tc_PROGRAMMING + "=3"

/obj/item/weapon/circuitboard/mecha/odysseus/peripherals
	name = "Circuit board (Odysseus Peripherals Control module)"
	icon_state = "mcontroller"

/obj/item/weapon/circuitboard/mecha/odysseus/main
	name = "Circuit board (Odysseus Central Control module)"
	icon_state = "mainboard"

/obj/item/weapon/circuitboard/mecha/phazon
	origin_tech = Tc_MATERIALS + "=9;" + Tc_BLUESPACE + "=10"

/obj/item/weapon/circuitboard/mecha/phazon/peripherals
	name = "Circuit board (Phazon Peripherals Control module)"
	icon_state = "mcontroller"

/obj/item/weapon/circuitboard/mecha/phazon/main
	name = "Circuit board (Phazon Central Control module)"
	icon_state = "mainboard"

/obj/item/weapon/circuitboard/mecha/pod
	name = "Circuit board (Space Pod Mainboard)"
	icon_state = "mainboard"
