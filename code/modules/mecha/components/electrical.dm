
/obj/item/mecha_parts/component/electrical
	name = "mecha electrical & data processing core"
	desc = "A standard issue electrical and data hub for a mecha."
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "board"
	w_class = W_CLASS_GIANT
	origin_tech = Tc_POWERSTORAGE + "=1;" + Tc_ENGINEERING + "=1"
	component_type = MECH_ELECTRIC
	emp_resistance = 0
	integrity_danger_mod = 0.4
	max_integrity = 50
	step_delay = 30
	relative_size = 20
	internal_damage_flag = MECHA_INT_SHORT_CIRCUIT
	broken_icon = "board_broken"
	var/efficiency_mod = 1
	var/locking = TRUE
/*
/obj/item/mecha_parts/component/electrical/attackby(obj/item/W as obj, mob/user as mob) // todo: Add soldering interaction
	if(issolder(W))
		var/obj/item/tool/solder/S = W
			if(S.do_solder(user, src, 2 SECONDS, 4))
				S.playtoolsound(loc, 100)
				to_chat(user, "<span class='notice'>You can_lock ? disable : enable the core's locking system.</span>")
				if(can_lock)
					can_lock = FALSE
				else
					can_lock = TRUE
*/
/obj/item/mecha_parts/component/electrical/high_current
	name = "efficient mecha electrical & data core"
	desc = "A data and electrical hub optimized for higher energy throughput."
	icon_state = "board_efficient"
	origin_tech = Tc_POWERSTORAGE + "=4;" + Tc_ENGINEERING + "=3"
	emp_resistance = -1
	max_integrity = 30
	relative_size = 25
	efficiency_mod = 0.5

/obj/item/mecha_parts/component/electrical/durable
	name = "armoured mecha electrical & data core"
	desc = "A standard data and electrical hub, covered by a sheath of armour."
	icon_state = "board_durable"
	origin_tech = Tc_POWERSTORAGE + "=4;" + Tc_ENGINEERING + "=3"
	emp_resistance = 2
	max_integrity = 150
	step_delay = 70
	relative_size = 25
	efficiency_mod = 2