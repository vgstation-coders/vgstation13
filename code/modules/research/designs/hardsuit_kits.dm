/datum/design/rig_engineer
	name = "Engineering Hardsuit Parts Kit"
	desc = "A set of parts for building an engineering hardsuit."
	id = "rig_engineer"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_MATERIALS = 4, Tc_POWERSTORAGE = 3, Tc_PLASMATECH = 2)
	build_type = MECHFAB
	materials = list(MAT_IRON = 6000, MAT_GLASS = 3000, MAT_PLASMA = 1000)
	build_path = /obj/item/device/rigparts/engineering
	category = "Hardsuit_Parts"

/datum/design/rig_atmos
	name = "Atmospherics Hardsuit Parts Kit"
	desc = "A set of parts for building an atmospherics hardsuit."
	id = "rig_atmos"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_MATERIALS = 4, Tc_PLASMATECH = 4)
	build_type = MECHFAB
	materials = list(MAT_IRON = 6000, MAT_GLASS = 3000, MAT_SILVER = 1000, MAT_PLASMA = 1000)
	build_path = /obj/item/device/rigparts/atmos
	category = "Hardsuit_Parts"

/datum/design/rig_medical
	name = "Medical Hardsuit Parts Kit"
	desc = "A set of parts for building a medical hardsuit."
	id = "rig_medical"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_MATERIALS = 4, Tc_BIOTECH = 2)
	build_type = MECHFAB
	materials = list(MAT_IRON = 6000, MAT_GLASS = 3000, MAT_SILVER = 1000)
	build_path = /obj/item/device/rigparts/medical
	category = "Hardsuit_Parts"

/datum/design/rig_mining
	name = "Mining Hardsuit Parts Kit"
	desc = "A set of parts for building a mining hardsuit."
	id = "rig_mining"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_MATERIALS = 4, Tc_ENGINEERING = 2)
	build_type = MECHFAB
	materials = list(MAT_IRON = 10000, MAT_GLASS = 3000)
	build_path = /obj/item/device/rigparts/mining
	category = "Hardsuit_Parts"

/datum/design/rig_arch
	name = "Archaeology Hardsuit Parts Kit"
	desc = "A set of parts for building an archaeology hardsuit."
	id = "rig_arch"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_MATERIALS = 4, Tc_ANOMALY = 2)
	build_type = MECHFAB
	materials = list(MAT_IRON = 8000, MAT_GLASS = 3000, MAT_GOLD = 1000)
	build_path = /obj/item/device/rigparts/arch
	category = "Hardsuit_Parts"

/datum/design/rig_security
	name = "Security Hardsuit Parts Kit"
	desc = "A set of parts for building a security hardsuit."
	id = "rig_security"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_MATERIALS = 4, Tc_COMBAT = 4)
	build_type = MECHFAB
	materials = list(MAT_IRON = 8000, MAT_GLASS = 3000, MAT_URANIUM = 1000)
	build_path = /obj/item/device/rigparts/security
	category = "Hardsuit_Parts"


