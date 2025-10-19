/datum/design/mech_actuator_basic
	name = "Module Design (Mecha Actuator)"
	id = "mech_actuator_basic"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 1)
	build_path = /obj/item/mecha_parts/component/actuator
	category = "Exosuit_Actuator"
	materials = list(MAT_IRON = 5000)

/datum/design/mech_actuator_durable
	name = "Module Design (Mecha Reinforced Actuator)"
	id = "mech_actuator_durable"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 3)
	build_path = /obj/item/mecha_parts/component/actuator/durable
	category = "Exosuit_Actuator"
	materials = list(MAT_IRON = 10000, MAT_PLASMA = 5000)

/datum/design/mech_actuator_hispeed
	name = "Module Design (Mecha Hi-Speed Actuator)"
	id = "mech_actuator_hispeed"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 5)
	build_path = /obj/item/mecha_parts/component/actuator/hispeed
	category = "Exosuit_Actuator"
	materials = list(MAT_IRON = 5000, MAT_SILVER = 5000, MAT_GOLD = 5000, MAT_DIAMOND = 5000)

/datum/design/mech_actuator_stable
	name = "Module Design (Mecha All-Conditions Stable Actuator)"
	id = "mech_actuator_stable"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 5)
	build_path = /obj/item/mecha_parts/component/actuator/stable
	category = "Exosuit_Actuator"
	materials = list(MAT_IRON = 5000, MAT_SILVER = 5000, MAT_GOLD = 5000, MAT_PLASMA = 5000)
