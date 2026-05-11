/datum/design/roswell/chassis
	name = "Exosuit Structure (Roswell chassis)"
	desc = "Used to build a Roswell chassis."
	id = "roswell_chassis"
	req_tech = list(Tc_COMBAT = 1,Tc_ALIEN = 5)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/roswell
	category = "Roswell"
	materials = list(MAT_IRON=10000,MAT_RETICULITE=10000)

/datum/design/roswell/body
	name = "Exosuit Structure (Roswell body)"
	desc = "Used to build a Roswell body."
	id = "roswell_body"
	req_tech = list(Tc_COMBAT = 1,Tc_ALIEN = 5)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/roswell_body
	category = "Roswell"
	materials = list(MAT_IRON=35000,MAT_GLASS=10000,MAT_RETICULITE=10000)

/datum/design/roswell/dome
	name = "Exosuit Structure (Roswell dome)"
	desc = "Used to build a Roswell dome."
	id = "roswell_dome"
	req_tech = list(Tc_COMBAT = 1,Tc_ALIEN = 5)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/roswell_dome
	category = "Roswell"
	materials = list(MAT_GLASS=20000,MAT_RETICULITE=5000)

/datum/design/roswell/hoverer
	name = "Exosuit Structure (Roswell hoverer)"
	desc = "Used to build a Roswell hoverer."
	id = "roswell_hoverer"
	req_tech = list(Tc_COMBAT = 1,Tc_ALIEN = 5)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/roswell_hoverer
	category = "Roswell"
	materials = list(MAT_IRON=20000,MAT_RETICULITE=5000)