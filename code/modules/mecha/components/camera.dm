/obj/item/mecha_parts/component/camera
	name = "standard mecha imaging system"
	desc = "A basic camera system, that allows the pilot of a mecha to see outside."
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "camera"
	w_class = W_CLASS_GIANT
	origin_tech = Tc_POWERSTORAGE + "=1;" + Tc_ENGINEERING + "=1"
	component_type = MECH_CAMERA
	emp_resistance = 0
	integrity_danger_mod = 0.5
	max_integrity = 50
	step_delay = 0
	relative_size = 15
	broken_icon = "camera_broken"

/obj/item/mecha_parts/component/camera/night
	name = "night-vision mecha imaging system"
	desc = "An enhanced camera system, granting the pilot the ability to see even in darkness."
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "camera"
	origin_tech = Tc_POWERSTORAGE + "=5;" + Tc_ENGINEERING + "=5"
	emp_resistance = -1
	integrity_danger_mod = 0.6
	max_integrity = 35
	step_delay = 0
	relative_size = 20

/obj/item/mecha_parts/component/camera/thermal
	name = "standard mecha imaging system"
	desc = "An enhanced camera system, highlighting nearby heat signatures."
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "camera"
	origin_tech = Tc_POWERSTORAGE + "=7;" + Tc_ENGINEERING + "=6"
	emp_resistance = -1
	integrity_danger_mod = 0.75
	max_integrity = 25
	step_delay = 0
	relative_size = 20
