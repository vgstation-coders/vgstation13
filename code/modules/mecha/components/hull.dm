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
	step_delay = 1
	broken_icon = "hull_broken"
	var/max_temperature = 10000
	var/max_pressure = HAZARD_HIGH_PRESSURE * 10
	var/surprise = FALSE // It's a surprise!
	var/pressure_proof = FALSE

/obj/item/mecha_parts/component/hull/lightweight
	name = "lightweight mecha hull"
	icon_state = "hull_light"
	origin_tech = Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=2"
	max_integrity = 25
	step_delay = 0
	integrity_danger_mod = 0.5
	max_temperature = 5000
	max_pressure = HAZARD_HIGH_PRESSURE

/obj/item/mecha_parts/component/hull/durable
	name = "durable mecha hull"
	icon_state = "hull_durable"
	origin_tech = Tc_MATERIALS + "=4;" + Tc_ENGINEERING + "=3"
	max_integrity = 100
	step_delay = 2
	integrity_danger_mod = 0.3
	max_temperature = 15000
	max_pressure = HAZARD_HIGH_PRESSURE * 5

/obj/item/mecha_parts/component/hull/heavy
	name = "heavily armoured mecha hull"
	icon_state = "hull_durable"
	origin_tech = Tc_MATERIALS + "=4;" + Tc_ENGINEERING + "=3"
	max_integrity = 150
	step_delay = 3
	integrity_danger_mod = 0.3
	max_temperature = 20000
	max_pressure = HAZARD_HIGH_PRESSURE * 8

/obj/item/mecha_parts/component/hull/atmos
	name = "environment-sealed mecha hull"
	origin_tech = Tc_MATERIALS + "=5;" + Tc_ENGINEERING + "=5"
	max_integrity = 35
	step_delay = 1
	max_temperature = 100000
	pressure_proof = TRUE // This should just null it out right

/obj/item/mecha_parts/component/hull/carbon
	name = "carbon-fibre mecha hull"
	desc = "An ultra-light hull composed of layered carbon-fibre, the label reads advertises it as completely temperature- and pressure-proof, developed by Atmosgate &copy; All rights reserved)."
	origin_tech = Tc_MATERIALS + "=6;" + Tc_ENGINEERING + "=6"
	max_integrity = 35
	step_delay = 0
	max_temperature = 1000
	max_pressure = HAZARD_HIGH_PRESSURE * 15 // But at what cost?

///obj/item/mecha_parts/component/hull/carbon/proc/surprise
