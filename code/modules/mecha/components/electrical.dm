
/obj/item/mecha_parts/component/electrical
	name = "mecha electrical harness"
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "board"
	w_class = W_CLASS_GIANT
	origin_tech = Tc_POWERSTORAGE + "=1;" + Tc_ENGINEERING + "=1"
	component_type = MECH_ELECTRIC
	emp_resistance = 1
	integrity_danger_mod = 0.4
	max_integrity = 50
	step_delay = 0
	relative_size = 10
	internal_damage_flag = MECHA_INT_SHORT_CIRCUIT
	var/charge_cost_mod = 1

/obj/item/mecha_parts/component/electrical/high_current
	name = "efficient mecha electrical harness"
	origin_tech = Tc_POWERSTORAGE + "=4;" + Tc_ENGINEERING + "=3"
	emp_resistance = -1
	max_integrity = 25
	relative_size = 25
	charge_cost_mod = 0.5

/obj/item/mecha_parts/component/electrical/durable
	name = "reinforced mecha electrical harness"
	origin_tech = Tc_POWERSTORAGE + "=4;" + Tc_ENGINEERING + "=3"
	emp_resistance = 1
	max_integrity = 100
	step_delay = 1
	relative_size = 25
	charge_cost_mod = 1.25
