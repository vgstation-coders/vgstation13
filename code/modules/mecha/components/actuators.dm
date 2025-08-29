/obj/item/mecha_parts/component/actuator
	name = "mecha actuator"
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "motor"
	w_class = W_CLASS_GIANT
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	component_type = MECH_ACTUATOR
	start_damaged = FALSE
	step_delay = 20
	emp_resistance = 0
	optimal_type = null	// List, if it exists. Exosuits meant to use the component.
	integrity_danger_mod = 0.6	// Multiplier for comparison to max_integrity before problems start.
	max_integrity = 40
	relative_size = 25
	internal_damage_flag = MECHA_INT_CONTROL_LOST
	broken_icon = "motor_broken"
	var/combat_punches = TRUE
	var/rigid = FALSE

/obj/item/mecha_parts/component/actuator/get_step_delay()
	return step_delay

/obj/item/mecha_parts/component/actuator/solder_act(mob/living/user, obj/item/tool/solder/S)
	if(!user || !src)
		return

	if(S.do_solder(user, src, 2 SECONDS, 4))
		S.playtoolsound(loc, 100)
		to_chat(user, "<span class='warning'>You [combat_punches ? "solder over" : "remove the solder from"] the high-pressure electro-hydraulic power socket [src].</span>")
		if(combat_punches)
			combat_punches = FALSE
		else
			combat_punches = TRUE

/obj/item/mecha_parts/component/actuator/hispeed
	name = "overclocked mecha actuator"
	icon_state = "motor_hispeed"
	step_delay = -100
	relative_size = 35
	emp_resistance = -1
	integrity_danger_mod = 0.7
	max_integrity = 20

/obj/item/mecha_parts/component/actuator/durable
	name = "reinforced mecha actuator"
	icon_state = "motor_durable"
	step_delay = 100
	relative_size = 35
	emp_resistance = 1
	integrity_danger_mod = 0.5
	max_integrity = 80

/obj/item/mecha_parts/component/actuator/stable
	name = "rigid mecha movement system"
	desc = "A rigid, non-articulated movement system for exosuits. Prevents strafing and climbing over obstacles, but has excellent stability in any condition."
	icon_state = "motor_hispeed"
	step_delay = 100
	relative_size = 35
	emp_resistance = 3
	integrity_danger_mod = 0.5
	max_integrity = 120
	rigid = TRUE
