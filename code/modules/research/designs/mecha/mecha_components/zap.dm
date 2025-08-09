/datum/design/mech_electrical_basic
	name = "Module Design (Mecha Zap)"
	id = "mech_electrical_basic"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 1)
	build_path = /obj/item/mecha_parts/component/electrical
	category = "Exosuit_Hull"
	materials = list(MAT_IRON = 10000, MAT_GLASS = 5000)

/datum/design/mech_electrical_hi_current
	name = "Module Design (Mecha Optimized Electrical Hub)"
	id = "mech_electrical_hi_current"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 3)
	build_path = /obj/item/mecha_parts/component/electrical/high_current
	category = "Exosuit_Hull"
	materials = list(MAT_IRON = 5000, MAT_SILVER = 5000, MAT_GOLD = 5000)

/datum/design/mech_electrical_durable
	name = "Module Design (Mecha Reinforced Electrical Hub)"
	id = "mech_electrical_durable"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 3)
	build_path = /obj/item/mecha_parts/component/electrical/durable
	category = "Exosuit_Hull"
	materials = list(MAT_IRON = 15000, MAT_PLASMA = 10000)
