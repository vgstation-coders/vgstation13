/datum/design/marauder/chassis
	name = "Exosuit Structure (Marauder chassis)"
	desc = "Used to build a Marauder chassis."
	id = "marauder_chassis"
	req_tech = list(Tc_COMBAT = 2, Tc_NANOTRASEN = 5)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/marauder
	category = "Nanotrasen"
	materials = list(MAT_IRON=25000)

/datum/design/marauder/torso
	name = "Exosuit Structure (Marauder torso)"
	desc = "Used to build a Marauder torso."
	id = "marauder_torso"
	req_tech = list(Tc_COMBAT = 2, Tc_NANOTRASEN = 5)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/marauder_torso
	category = "Nanotrasen"
	materials = list(MAT_IRON=55000,MAT_GLASS=20000,MAT_SILVER=10000)

/datum/design/marauder/l_arm
	name = "Exosuit Structure (Marauder left arm)"
	desc = "Used to build a Marauder left arm."
	id = "marauder_larm"
	req_tech = list(Tc_COMBAT = 5, Tc_NANOTRASEN = 5)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/marauder_left_arm
	category = "Nanotrasen"
	materials = list(MAT_IRON=35000,MAT_SILVER=3000)

/datum/design/marauder/r_arm
	name = "Exosuit Structure (Marauder right arm)"
	desc = "Used to build a Marauder right arm."
	id = "marauder_rarm"
	req_tech = list(Tc_COMBAT = 4, Tc_NANOTRASEN = 5)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/marauder_right_arm
	category = "Nanotrasen"
	materials = list(MAT_IRON=35000,MAT_SILVER=3000)

/datum/design/marauder/l_leg
	name = "Exosuit Structure (Marauder left leg)"
	desc = "Used to build a Marauder left leg."
	id = "marauder_lleg"
	req_tech = list(Tc_COMBAT = 2, Tc_NANOTRASEN = 5)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/marauder_left_leg
	category = "Nanotrasen"
	materials = list(MAT_IRON=40000,MAT_SILVER=3000)

/datum/design/marauder/r_leg
	name = "Exosuit Structure (Marauder right leg)"
	desc = "Used to build a Marauder right leg."
	id = "marauder_rleg"
	req_tech = list(Tc_COMBAT = 2, Tc_NANOTRASEN = 5)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/marauder_right_leg
	category = "Nanotrasen"
	materials = list(MAT_IRON=40000,MAT_SILVER=3000)

/datum/design/marauder/head
	name = "Exosuit Structure (Marauder head)"
	desc = "Used to build a Marauder head."
	id = "marauder_head"
	req_tech = list(Tc_COMBAT = 2, Tc_NANOTRASEN = 5)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/marauder_head
	category = "Nanotrasen"
	materials = list(MAT_IRON=25000,MAT_GLASS=10000,MAT_SILVER=3000)

/datum/design/marauder/armor
	name = "Exosuit Structure (Marauder plates)"
	desc = "Used to build Marauder armor plates."
	id = "marauder_armor"
	req_tech = list(Tc_COMBAT = 4, Tc_MAGNETS = 5, Tc_NANOTRASEN = 5)
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/marauder_armour
	category = "Nanotrasen"
	materials = list(MAT_IRON=50000,MAT_URANIUM=10000)
