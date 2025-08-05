
/obj/item/mecha_parts/component/hull
	name = "mecha hull"
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "hull"
	w_class = W_CLASS_GIANT
	origin_tech = Tc_MATERIALS + "=1;" + Tc_ENGINEERING + "=1"
	component_type = MECH_HULL
	emp_resistance = 0	// Amount of emp 'levels' removed.
	optimal_type = null	// List, if it exists. Exosuits meant to use the component.
	integrity_danger_mod = 0.5	// Multiplier for comparison to max_integrity before problems start.
	max_integrity = 50
	internal_damage_flag = MECHA_INT_FIRE
	step_delay = 1
	broken_icon = "hull_broken"

/obj/item/mecha_parts/component/hull/lightweight
	name = "lightweight mecha hull"
	origin_tech = Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=2"
	max_integrity = 25
	step_delay = 0
	integrity_danger_mod = 0.5

/obj/item/mecha_parts/component/hull/durable
	name = "durable mecha hull"
	origin_tech = Tc_MATERIALS + "=4;" + Tc_ENGINEERING + "=3"
	max_integrity = 100
	step_delay = 2
	integrity_danger_mod = 0.25
