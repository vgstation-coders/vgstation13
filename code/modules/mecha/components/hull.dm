/obj/item/mecha_parts/component/hull
	name = "mecha hull"
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "hull"
	w_class = W_CLASS_GIANT
	origin_tech = Tc_MATERIALS + "=1;" + Tc_ENGINEERING + "=1"
	component_type = MECH_HULL
	emp_resistance = 4	// Amount of emp 'levels' removed.
	optimal_type = null	// List, if it exists. Exosuits meant to use the component.
	integrity_danger_mod = 0.5	// Multiplier for comparison to max_integrity before problems start.
	max_integrity = 40
	internal_damage_flag = MECHA_INT_FIRE
	step_delay = 100
	broken_icon = "hull_broken"
	var/max_temperature = 2000
	var/max_pressure = HAZARD_HIGH_PRESSURE * 10
	var/surprise = FALSE // It's a surprise!
	var/pressure_proof = FALSE
	var/hull_soak = 0.5 // Percentage of damage 'soaked' by the hull

/obj/item/mecha_parts/component/hull/lightweight
	name = "lightweight mecha hull"
	icon_state = "hull_light"
	origin_tech = Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=2"
	max_integrity = 25
	step_delay = 20
	integrity_danger_mod = 0.5
	max_temperature = 500
	max_pressure = HAZARD_HIGH_PRESSURE
	hull_soak = 0.3

/obj/item/mecha_parts/component/hull/durable
	name = "durable mecha hull"
	icon_state = "hull_durable"
	origin_tech = Tc_MATERIALS + "=4;" + Tc_ENGINEERING + "=3"
	max_integrity = 100
	step_delay = 200
	integrity_danger_mod = 0.3
	max_temperature = 5000
	max_pressure = HAZARD_HIGH_PRESSURE * 5
	hull_soak = 0.6

/obj/item/mecha_parts/component/hull/heavy
	name = "heavily armoured mecha hull"
	icon_state = "hull_durable"
	origin_tech = Tc_MATERIALS + "=4;" + Tc_ENGINEERING + "=3"
	max_integrity = 150
	step_delay = 300
	integrity_danger_mod = 0.3
	max_temperature = 10000
	max_pressure = HAZARD_HIGH_PRESSURE * 8
	hull_soak = 0.7

/obj/item/mecha_parts/component/hull/atmos
	name = "environment-sealed mecha hull"
	origin_tech = Tc_MATERIALS + "=5;" + Tc_ENGINEERING + "=5"
	max_integrity = 35
	step_delay = 100
	max_temperature = 100000
	pressure_proof = TRUE // This should just null it out right
	hull_soak = 0.5

/obj/item/mecha_parts/component/hull/carbon
	name = "carbon-fibre mecha hull"
	desc = "An ultra-light hull composed of layered carbon-fibre, the label reads advertises it as completely temperature- and pressure-proof, developed by Atmosgate &copy; All rights reserved)."
	origin_tech = Tc_MATERIALS + "=6;" + Tc_ENGINEERING + "=6"
	max_integrity = 35
	step_delay = 20
	max_temperature = 1000
	max_pressure = HAZARD_HIGH_PRESSURE * 15 // But at what cost?
	hull_soak = 0.3

///obj/item/mecha_parts/component/hull/carbon/proc/surprise

/obj/item/mecha_parts/component/hull/durable/killdozer // killdozer
	name = "reinforced concrete citadel"
	icon_state = "hull_durable"
	origin_tech = Tc_MATERIALS + "=4;" + Tc_ENGINEERING + "=3"
	max_integrity = 1000
	step_delay = 400
	integrity_danger_mod = 0.1
	max_temperature = 10000
	max_pressure = HAZARD_HIGH_PRESSURE * 20
	always_repair = TRUE
	hull_soak = 1
