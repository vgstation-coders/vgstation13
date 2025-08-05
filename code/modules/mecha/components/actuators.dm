
/obj/item/mecha_parts/component/actuator
	name = "mecha actuator"
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "motor"
	w_class = W_CLASS_GIANT
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	component_type = MECH_ACTUATOR
	start_damaged = FALSE
	step_delay = 0
	emp_resistance = 1
	optimal_type = null	// List, if it exists. Exosuits meant to use the component.
	integrity_danger_mod = 0.6	// Multiplier for comparison to max_integrity before problems start.
	max_integrity = 50
	relative_size = 10
	internal_damage_flag = MECHA_INT_CONTROL_LOST
	broken_icon = "motor_broken"
	var/turn_delay = 1
	var/equipment_delay = 1

/obj/item/mecha_parts/component/actuator/get_step_delay()
	return step_delay

/obj/item/mecha_parts/component/actuator/hispeed
	name = "overclocked mecha actuator"
	step_delay = -1
	turn_delay = -1
	equipment_delay = -1
	relative_size = 20
	emp_resistance = -1
	integrity_danger_mod = 0.7
	max_integrity = 25

/obj/item/mecha_parts/component/actuator/durable
	name = "reinforced mecha actuator"
	step_delay = 1
	turn_delay = 1.5
	equipment_delay = 1.5
	relative_size = 25
	emp_resistance = 1
	integrity_danger_mod = 0.5
	max_integrity = 100
