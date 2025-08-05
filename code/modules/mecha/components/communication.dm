/obj/item/mecha_parts/component/communications
	name = "standard mecha radio"
	desc = "A basic radio component, allowing the mecha's pilot to communicate with the outside world."
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "camera"
	w_class = W_CLASS_GIANT
	origin_tech = Tc_POWERSTORAGE + "=1;" + Tc_ENGINEERING + "=1"
	component_type = MECH_RADIO
	emp_resistance = 0
	integrity_danger_mod = 0.5
	max_integrity = 50
	step_delay = 0
	relative_size = 15
	broken_icon = "radio_broken"
	var/can_use_binary = FALSE
	var/obj/item/device/radio/radio

/obj/item/mecha_parts/component/communications/New()
	radio.name = "[src] radio"
	radio.icon = icon
	radio.icon_state = icon_state
	radio.subspace_transmission = TRUE
//	if(can_use_binary)
//		radio.translate_binary = TRUE

/obj/item/mecha_parts/component/communications/reinforced
	name = "standard mecha radio"
	desc = "A basic radio component, allowing the mecha's pilot to communicate with the outside world."
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "camera"
	w_class = W_CLASS_GIANT
	origin_tech = Tc_POWERSTORAGE + "=2;" + Tc_ENGINEERING + "=3"
	component_type = MECH_RADIO
	emp_resistance = 1
	max_integrity = 75
	step_delay = 1
	relative_size = 25

/obj/item/mecha_parts/component/communications/binary
	name = "mecha binary translation radio"
	desc = "A bulky two-way radio system that allows the mecha's pilot to communicate on binary channels."
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "camera"
	w_class = W_CLASS_GIANT
	origin_tech = Tc_POWERSTORAGE + "=5;" + Tc_ENGINEERING + "=5" + Tc_SYNDICATE + "=5"
	component_type = MECH_RADIO
	emp_resistance = -1
	max_integrity = 25
	relative_size = 25
	can_use_binary = TRUE
