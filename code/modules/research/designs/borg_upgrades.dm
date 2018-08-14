/datum/design/borg_syndicate_module
	name = "Cyborg illegal equipment board"
	desc = "Allows for the construction of illegal upgrades for cyborgs"
	id = "borg_syndicate_module"
	build_type = MECHFAB
	req_tech = list(Tc_COMBAT = 4, Tc_SYNDICATE = 3)
	build_path = /obj/item/borg/upgrade/syndicate
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=10000, MAT_GLASS=15000, MAT_DIAMOND=10000)

/datum/design/borg_reset_board
	name = "Cyborg reset board"
	desc = "Used to reset cyborgs to their default module."
	id = "borg_reset_board"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/reset
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=10000)

/datum/design/borg_rename_board
	name = "Cyborg rename board"
	desc = "Used to rename cyborgs."
	id = "borg_rename_board"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/rename
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=35000)

/datum/design/borg_restart_board
	name = "Cyborg emergency restart board"
	desc = "Used to restart cyborgs."
	id = "borg_restart_board"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/restart
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=60000, MAT_GLASS=5000)

/datum/design/borg_vtec_board
	name = "Cyborg VTEC upgrade"
	desc = "Used to upgrade a borg's speed."
	id = "borg_vtec_board"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/vtec
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=80000, MAT_GLASS=6000, MAT_GOLD=5000)

/datum/design/borg_jetpack_board
	name = "Cyborg jetpack upgrade"
	desc = "Used to give cyborgs a jetpack."
	id = "borg_jetpack_board"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/jetpack
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=10000, MAT_PLASMA=15000, MAT_URANIUM=20000)

/datum/design/borg_tasercooler_board
	name = "Security cyborg rapid taser cooling upgrade"
	desc = "Used to upgrade cyborg taser cooling."
	id = "borg_tasercooler_board"
	req_tech = list(Tc_COMBAT = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/tasercooler
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=80000, MAT_GLASS=6000, MAT_GOLD=2000, MAT_DIAMOND=500)

/datum/design/borg_engineer_upgrade
	name = "Engineering cyborg MK-2 upgrade"
	desc = "Used to give an engineering cyborg more materials."
	id = "borg_engineer_module"
	build_type = MECHFAB
	req_tech = list(Tc_ENGINEERING = 1)
	build_path = /obj/item/borg/upgrade/engineering
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=10000, MAT_GLASS=10000, MAT_PLASMA=5000)

/datum/design/borg_magnetic_gripper_board
	name = "Engineering cyborg magnetic gripper upgrade"
	desc = "Used to give a engineering cyborg a magnetic gripper."
	id = "borg_magnetic_gripper_board"
	req_tech = list(Tc_MAGNETS = 5, Tc_ENGINEERING = 5, Tc_ANOMALY = 3)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/magnetic_gripper
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=80000, MAT_PLASMA=50000, MAT_URANIUM=5000, MAT_DIAMOND=5000, MAT_PLASTIC=5000)

/datum/design/medical_module_surgery
	name = "Medical cyborg MK-2 upgrade"
	desc = "Used to give a medical cyborg advanced care tools."
	id = "medical_module_surgery"
	req_tech = list(Tc_BIOTECH = 3, Tc_ENGINEERING = 3)
	build_type = MECHFAB
	materials = list(MAT_IRON=80000, MAT_GLASS=20000, MAT_SILVER=5000)
	build_path = /obj/item/borg/upgrade/medical
	category = "Robotic_Upgrade_Modules"

/datum/design/borg_organ_gripper_board
	name = "Medical cyborg organ gripper upgrade"
	desc = "Used to give a medical cyborg a organ gripper."
	id = "borg_organ_gripper_board"
	req_tech = list(Tc_BIOTECH = 5, Tc_ENGINEERING = 4, Tc_ANOMALY = 3)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/medical/organ_gripper
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=80000, MAT_PLASMA=50000, MAT_SILVER=5000, MAT_GOLD=5000, MAT_PLASTIC=5000)

/datum/design/borg_service_upgrade
	name = "Service cyborg cooking upgrade"
	desc = "Used to give a service cyborg cooking tools and upgrade their service gripper to be able to handle food."
	id = "borg_service_module"
	req_tech = list(Tc_BIOTECH = 2, Tc_ENGINEERING = 3, Tc_PROGRAMMING = 2, Tc_ANOMALY = 2)
	build_type = MECHFAB
	materials = list(MAT_IRON=45000, MAT_GLASS=8000, MAT_GOLD=2500)
	build_path = /obj/item/borg/upgrade/cook
	category = "Robotic_Upgrade_Modules"

/datum/design/borg_service_upgrade_hydro
	name = "Service cyborg H.U.E.Y. upgrade"
	desc = "Used to give a service cyborg hydroponics tools and upgrade their service gripper to be able to handle seeds, weed killers, sprayers and glass containers."
	id = "borg_service_module_hydro"
	req_tech = list(Tc_BIOTECH = 4, Tc_ENGINEERING = 2, Tc_PROGRAMMING = 2, Tc_ANOMALY = 2)
	build_type = MECHFAB
	materials = list(MAT_IRON=45000, MAT_GLASS=8000, MAT_PLASTIC=2500)
	build_path = /obj/item/borg/upgrade/hydro
	category = "Robotic_Upgrade_Modules"

/datum/design/borg_service_upgrade_honk
	name = "Service cyborg H.O.N.K. upgrade"
	desc = "Used to give a service cyborg fun toys!"
	id = "borg_service_module_honk"
	req_tech = list(Tc_NANOTRASEN = 1, Tc_MATERIALS = 3, Tc_BIOTECH = 3)
	build_type = MECHFAB
	materials = list(MAT_CARDBOARD=5000, MAT_CLOWN=5000)
	build_path = /obj/item/borg/upgrade/honk
	category = "Robotic_Upgrade_Modules"