/obj/item/mecha_parts/component/gas
	name = "mecha life-support"
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "lifesupport"
	w_class = W_CLASS_GIANT
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	component_type = MECH_GAS
	emp_resistance = 1
	integrity_danger_mod = 0.4
	max_integrity = 50
	step_delay = 30
	relative_size = 30
	internal_damage_flag = MECHA_INT_TANK_BREACH
	broken_icon = "lifesupport_broken"
	var/beeper = TRUE

/obj/item/mecha_parts/component/gas/reinforced
	name = "reinforced mecha life-support"
	icon_state = "lifesupport_durable"
	emp_resistance = 2
	max_integrity = 80
	step_delay = 70
	relative_size = 35
