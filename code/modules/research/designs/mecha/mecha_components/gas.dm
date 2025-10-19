/datum/design/mech_gas_basic
	name = "Module Design (Mecha Lifesupport)"
	id = "mech_actuator_basic"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 1)
	build_path = /obj/item/mecha_parts/component/gas
	category = "Exosuit_Lifesupport"
	materials = list(MAT_IRON = 5000)

/datum/design/mech_gas_reinforced
	name = "Module Design (Mecha Reinforced Lifesupport)"
	id = "mech_actuator_basic"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 4)
	build_path = /obj/item/mecha_parts/component/gas/reinforced
	category = "Exosuit_Lifesupport"
	materials = list(MAT_IRON = 10000, MAT_PLASMA = 5000)
