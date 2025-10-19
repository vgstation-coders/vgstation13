/datum/design/mech_hull_basic
	name = "Module Design (Mecha Hull)"
	id = "mech_hull_basic"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 1)
	build_path = /obj/item/mecha_parts/component/hull
	category = "Exosuit_Hull"
	materials = list(MAT_IRON = 10000)

/datum/design/mech_hull_lightweight
	name = "Module Design (Mecha Lightweight Hull)"
	id = "mech_hull_"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 1)
	build_path = /obj/item/mecha_parts/component/hull/lightweight
	category = "Exosuit_Hull"
	materials = list(MAT_IRON = 5000, MAT_PLASTIC = 5000)

/datum/design/mech_hull_durable
	name = "Module Design (Mecha Reinforced Hull)"
	id = "mech_hull_durable"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 3, Tc_MATERIALS = 3)
	build_path = /obj/item/mecha_parts/component/hull/durable
	category = "Exosuit_Hull"
	materials = list(MAT_IRON = 10000, MAT_PLASMA = 7500)

/datum/design/mech_hull_heavy
	name = "Module Design (Mecha Super-Heavy Hull)"
	id = "mech_hull_heavy"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 5, Tc_MATERIALS = 5)
	build_path = /obj/item/mecha_parts/component/hull/heavy
	category = "Exosuit_Hull"
	materials = list(MAT_IRON = 15000, MAT_PLASMA = 10000, MAT_URANIUM = 5000)

/datum/design/mech_hull_atmos
	name = "Module Design (Mecha Atmosphere-Proof Hull)"
	id = "mech_hull_atmos"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 6, Tc_MATERIALS = 6)
	build_path = /obj/item/mecha_parts/component/hull/atmos
	category = "Exosuit_Hull"
	materials = list(MAT_IRON = 7500, MAT_PLASMA = 5000)
