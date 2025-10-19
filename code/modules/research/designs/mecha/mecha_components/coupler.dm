/datum/design/mech_coupler
	name = "Module Design (Mecha Coupler)"
	id = "mech_coupler"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 1)
	build_path = /obj/item/mecha_parts/component/coupler
	category = "Exosuit_Coupler"
	materials = list(MAT_IRON = 10000, MAT_SILVER = 2000)

/datum/design/mech_coupler_durable
	name = "Module Design (Mecha Manual Coupler)"
	id = "mech_coupler_durable"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 1)
	build_path = /obj/item/mecha_parts/component/coupler/durable
	category = "Exosuit_Coupler"
	materials = list(MAT_IRON = 15000)
