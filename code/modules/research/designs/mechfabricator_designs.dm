//Cyborg
/datum/design/borg_suit
	name = "Cyborg Endoskeleton"
	id = "borg_suit"
	build_type = MECHFAB
	build_path = /obj/item/robot_suit
	materials = list(MAT_METAL=15000)
	construction_time = 500
	category = list("Cyborg")

/datum/design/borg_chest
	name = "Cyborg Torso"
	id = "borg_chest"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/chest/robot
	materials = list(MAT_METAL=40000)
	construction_time = 350
	category = list("Cyborg")

/datum/design/borg_head
	name = "Cyborg Head"
	id = "borg_head"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/robot
	materials = list(MAT_METAL=5000)
	construction_time = 350
	category = list("Cyborg")

/datum/design/borg_l_arm
	name = "Cyborg Left Arm"
	id = "borg_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/l_arm/robot
	materials = list(MAT_METAL=10000)
	construction_time = 200
	category = list("Cyborg")

/datum/design/borg_r_arm
	name = "Cyborg Right Arm"
	id = "borg_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/r_arm/robot
	materials = list(MAT_METAL=10000)
	construction_time = 200
	category = list("Cyborg")

/datum/design/borg_l_leg
	name = "Cyborg Left Leg"
	id = "borg_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/l_leg/robot
	materials = list(MAT_METAL=10000)
	construction_time = 200
	category = list("Cyborg")

/datum/design/borg_r_leg
	name = "Cyborg Right Leg"
	id = "borg_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/r_leg/robot
	materials = list(MAT_METAL=10000)
	construction_time = 200
	category = list("Cyborg")

//Ripley
/datum/design/ripley_chassis
	name = "Exosuit Chassis (APLU \"Ripley\")"
	id = "ripley_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/ripley
	materials = list(MAT_METAL=20000)
	construction_time = 100
	category = list("Ripley")

//firefighter subtype
/datum/design/firefighter_chassis
	name = "Exosuit Chassis (APLU \"Firefighter\")"
	id = "firefighter_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/firefighter
	materials = list(MAT_METAL=20000)
	construction_time = 100
	category = list("Firefighter")

/datum/design/ripley_torso
	name = "Exosuit Torso (APLU \"Ripley\")"
	id = "ripley_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_torso
	materials = list(MAT_METAL=20000, MAT_GLASS=7500)
	construction_time = 200
	category = list("Ripley","Firefighter")

/datum/design/ripley_left_arm
	name = "Exosuit Left Arm (APLU \"Ripley\")"
	id = "ripley_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_arm
	materials = list(MAT_METAL=15000)
	construction_time = 150
	category = list("Ripley","Firefighter")

/datum/design/ripley_right_arm
	name = "Exosuit Right Arm (APLU \"Ripley\")"
	id = "ripley_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_arm
	materials = list(MAT_METAL=15000)
	construction_time = 150
	category = list("Ripley","Firefighter")

/datum/design/ripley_left_leg
	name = "Exosuit Left Leg (APLU \"Ripley\")"
	id = "ripley_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_leg
	materials = list(MAT_METAL=15000)
	construction_time = 150
	category = list("Ripley","Firefighter")

/datum/design/ripley_right_leg
	name = "Exosuit Right Leg (APLU \"Ripley\")"
	id = "ripley_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_leg
	materials = list(MAT_METAL=15000)
	construction_time = 150
	category = list("Ripley","Firefighter")

//Odysseus
/datum/design/odysseus_chassis
	name = "Exosuit Chassis (\"Odysseus\")"
	id = "odysseus_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/odysseus
	materials = list(MAT_METAL=20000)
	construction_time = 100
	category = list("Odysseus")

/datum/design/odysseus_torso
	name = "Exosuit Torso (\"Odysseus\")"
	id = "odysseus_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_torso
	materials = list(MAT_METAL=12000)
	construction_time = 180
	category = list("Odysseus")

/datum/design/odysseus_head
	name = "Exosuit Head (\"Odysseus\")"
	id = "odysseus_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_head
	materials = list(MAT_METAL=6000,MAT_GLASS=10000)
	construction_time = 100
	category = list("Odysseus")

/datum/design/odysseus_left_arm
	name = "Exosuit Left Arm (\"Odysseus\")"
	id = "odysseus_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_arm
	materials = list(MAT_METAL=6000)
	construction_time = 120
	category = list("Odysseus")

/datum/design/odysseus_right_arm
	name = "Exosuit Right Arm (\"Odysseus\")"
	id = "odysseus_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_arm
	materials = list(MAT_METAL=6000)
	construction_time = 120
	category = list("Odysseus")

/datum/design/odysseus_left_leg
	name = "Exosuit Left Leg (\"Odysseus\")"
	id = "odysseus_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_leg
	materials = list(MAT_METAL=7000)
	construction_time = 130
	category = list("Odysseus")

/datum/design/odysseus_right_leg
	name = "Exosuit Right Leg (\"Odysseus\")"
	id = "odysseus_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_leg
	materials = list(MAT_METAL=7000)
	construction_time = 130
	category = list("Odysseus")

//Gygax
/datum/design/gygax_chassis
	name = "Exosuit Chassis (\"Gygax\")"
	id = "gygax_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/gygax
	materials = list(MAT_METAL=20000)
	construction_time = 100
	category = list("Gygax")

/datum/design/gygax_torso
	name = "Exosuit Torso (\"Gygax\")"
	id = "gygax_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_torso
	materials = list(MAT_METAL=20000,MAT_GLASS=10000,MAT_DIAMOND=2000)
	construction_time = 300
	category = list("Gygax")

/datum/design/gygax_head
	name = "Exosuit Head (\"Gygax\")"
	id = "gygax_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_head
	materials = list(MAT_METAL=10000,MAT_GLASS=5000, MAT_DIAMOND=2000)
	construction_time = 200
	category = list("Gygax")

/datum/design/gygax_left_arm
	name = "Exosuit Left Arm (\"Gygax\")"
	id = "gygax_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_arm
	materials = list(MAT_METAL=15000, MAT_DIAMOND=1000)
	construction_time = 200
	category = list("Gygax")

/datum/design/gygax_right_arm
	name = "Exosuit Right Arm (\"Gygax\")"
	id = "gygax_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_arm
	materials = list(MAT_METAL=15000, MAT_DIAMOND=1000)
	construction_time = 200
	category = list("Gygax")

/datum/design/gygax_left_leg
	name = "Exosuit Left Leg (\"Gygax\")"
	id = "gygax_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_leg
	materials = list(MAT_METAL=15000, MAT_DIAMOND=2000)
	construction_time = 200
	category = list("Gygax")

/datum/design/gygax_right_leg
	name = "Exosuit Right Leg (\"Gygax\")"
	id = "gygax_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_leg
	materials = list(MAT_METAL=15000, MAT_DIAMOND=2000)
	construction_time = 200
	category = list("Gygax")

/datum/design/gygax_armor
	name = "Exosuit Armor (\"Gygax\")"
	id = "gygax_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_armor
	materials = list(MAT_METAL=15000,MAT_DIAMOND=10000,MAT_TITANIUM=10000)
	construction_time = 600
	category = list("Gygax")

//Durand
/datum/design/durand_chassis
	name = "Exosuit Chassis (\"Durand\")"
	id = "durand_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/durand
	materials = list(MAT_METAL=25000)
	construction_time = 100
	category = list("Durand")

/datum/design/durand_torso
	name = "Exosuit Torso (\"Durand\")"
	id = "durand_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_torso
	materials = list(MAT_METAL=25000,MAT_GLASS=10000,MAT_SILVER=10000)
	construction_time = 300
	category = list("Durand")

/datum/design/durand_head
	name = "Exosuit Head (\"Durand\")"
	id = "durand_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_head
	materials = list(MAT_METAL=10000,MAT_GLASS=15000,MAT_SILVER=2000)
	construction_time = 200
	category = list("Durand")

/datum/design/durand_left_arm
	name = "Exosuit Left Arm (\"Durand\")"
	id = "durand_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_arm
	materials = list(MAT_METAL=10000,MAT_SILVER=4000)
	construction_time = 200
	category = list("Durand")

/datum/design/durand_right_arm
	name = "Exosuit Right Arm (\"Durand\")"
	id = "durand_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_arm
	materials = list(MAT_METAL=10000,MAT_SILVER=4000)
	construction_time = 200
	category = list("Durand")

/datum/design/durand_left_leg
	name = "Exosuit Left Leg (\"Durand\")"
	id = "durand_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_leg
	materials = list(MAT_METAL=15000,MAT_SILVER=4000)
	construction_time = 200
	category = list("Durand")

/datum/design/durand_right_leg
	name = "Exosuit Right Leg (\"Durand\")"
	id = "durand_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_leg
	materials = list(MAT_METAL=15000,MAT_SILVER=4000)
	construction_time = 200
	category = list("Durand")

/datum/design/durand_armor
	name = "Exosuit Armor (\"Durand\")"
	id = "durand_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_armor
	materials = list(MAT_METAL=30000,MAT_URANIUM=25000,MAT_TITANIUM=20000)
	construction_time = 600
	category = list("Durand")

//H.O.N.K
/datum/design/honk_chassis
	name = "Exosuit Chassis (\"H.O.N.K\")"
	id = "honk_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/honker
	materials = list(MAT_METAL=20000)
	construction_time = 100
	category = list("H.O.N.K")

/datum/design/honk_torso
	name = "Exosuit Torso (\"H.O.N.K\")"
	id = "honk_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_torso
	materials = list(MAT_METAL=20000,MAT_GLASS=10000,MAT_BANANIUM=10000)
	construction_time = 300
	category = list("H.O.N.K")

/datum/design/honk_head
	name = "Exosuit Head (\"H.O.N.K\")"
	id = "honk_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_head
	materials = list(MAT_METAL=10000,MAT_GLASS=5000,MAT_BANANIUM=5000)
	construction_time = 200
	category = list("H.O.N.K")

/datum/design/honk_left_arm
	name = "Exosuit Left Arm (\"H.O.N.K\")"
	id = "honk_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_left_arm
	materials = list(MAT_METAL=15000,MAT_BANANIUM=5000)
	construction_time = 200
	category = list("H.O.N.K")

/datum/design/honk_right_arm
	name = "Exosuit Right Arm (\"H.O.N.K\")"
	id = "honk_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_right_arm
	materials = list(MAT_METAL=15000,MAT_BANANIUM=5000)
	construction_time = 200
	category = list("H.O.N.K")

/datum/design/honk_left_leg
	name = "Exosuit Left Leg (\"H.O.N.K\")"
	id = "honk_left_leg"
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/part/honker_left_leg
	materials = list(MAT_METAL=20000,MAT_BANANIUM=5000)
	construction_time = 200
	category = list("H.O.N.K")

/datum/design/honk_right_leg
	name = "Exosuit Right Leg (\"H.O.N.K\")"
	id = "honk_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_right_leg
	materials = list(MAT_METAL=20000,MAT_BANANIUM=5000)
	construction_time = 200
	category = list("H.O.N.K")


//Phazon
/datum/design/phazon_chassis
	name = "Exosuit Chassis (\"Phazon\")"
	id = "phazon_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/phazon
	materials = list(MAT_METAL=20000)
	construction_time = 100
	category = list("Phazon")

/datum/design/phazon_torso
	name = "Exosuit Torso (\"Phazon\")"
	id = "phazon_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_torso
	materials = list(MAT_METAL=35000,MAT_GLASS=10000,MAT_PLASMA=20000)
	construction_time = 300
	category = list("Phazon")

/datum/design/phazon_head
	name = "Exosuit Head (\"Phazon\")"
	id = "phazon_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_head
	materials = list(MAT_METAL=15000,MAT_GLASS=5000,MAT_PLASMA=10000)
	construction_time = 200
	category = list("Phazon")

/datum/design/phazon_left_arm
	name = "Exosuit Left Arm (\"Phazon\")"
	id = "phazon_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_left_arm
	materials = list(MAT_METAL=20000,MAT_PLASMA=10000)
	construction_time = 200
	category = list("Phazon")

/datum/design/phazon_right_arm
	name = "Exosuit Right Arm (\"Phazon\")"
	id = "phazon_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_right_arm
	materials = list(MAT_METAL=20000,MAT_PLASMA=10000)
	construction_time = 200
	category = list("Phazon")

/datum/design/phazon_left_leg
	name = "Exosuit Left Leg (\"Phazon\")"
	id = "phazon_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_left_leg
	materials = list(MAT_METAL=20000,MAT_PLASMA=10000)
	construction_time = 200
	category = list("Phazon")

/datum/design/phazon_right_leg
	name = "Exosuit Right Leg (\"Phazon\")"
	id = "phazon_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_right_leg
	materials = list(MAT_METAL=20000,MAT_PLASMA=10000)
	construction_time = 200
	category = list("Phazon")

/datum/design/phazon_armor
	name = "Exosuit Armor (\"Phazon\")"
	id = "phazon_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_armor
	materials = list(MAT_METAL=25000,MAT_PLASMA=20000,MAT_TITANIUM=20000)
	construction_time = 300
	category = list("Phazon")

//Exosuit Equipment
/datum/design/mech_hydraulic_clamp
	name = "Exosuit Engineering Equipment (Hydraulic Clamp)"
	id = "mech_hydraulic_clamp"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_drill
	name = "Exosuit Engineering Equipment (Drill)"
	id = "mech_drill"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/drill
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_mining_scanner
	name = "Exosuit Engineering Equipment (Mining Scanner)"
	id = "mech_mscanner"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/mining_scanner
	materials = list(MAT_METAL=5000,MAT_GLASS=2500)
	construction_time = 50
	category = list("Exosuit Equipment")

/datum/design/mech_extinguisher
	name = "Exosuit Engineering Equipment (Extinguisher)"
	id = "mech_extinguisher"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/extinguisher
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_cable_layer
	name = "Exosuit Engineering Equipment (Cable Layer)"
	id = "mech_cable_layer"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/cable_layer
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_generator
	name = "Exosuit Equipment (Plasma Generator)"
	id = "mech_generator"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/generator
	materials = list(MAT_METAL=10000,MAT_GLASS=1000,MAT_SILVER=2000,MAT_PLASMA=5000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_mousetrap_mortar
	name = "H.O.N.K Mousetrap Mortar"
	id = "mech_mousetrap_mortar"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/mousetrap_mortar
	materials = list(MAT_METAL=20000,MAT_BANANIUM=5000)
	construction_time = 300
	category = list("Exosuit Equipment")

/datum/design/mech_banana_mortar
	name = "H.O.N.K Banana Mortar"
	id = "mech_banana_mortar"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar
	materials = list(MAT_METAL=20000,MAT_BANANIUM=5000)
	construction_time = 300
	category = list("Exosuit Equipment")

/datum/design/mech_honker
	name = "HoNkER BlAsT 5000"
	id = "mech_honker"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/honker
	materials = list(MAT_METAL=20000,MAT_BANANIUM=10000)
	construction_time = 500
	category = list("Exosuit Equipment")

/datum/design/mech_punching_glove
	name = "Oingo Boingo Punch-face"
	id = "mech_punching_face"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove
	materials = list(MAT_METAL=20000,MAT_BANANIUM=7500)
	construction_time = 400
	category = list("Exosuit Equipment")

/////////////////////////////////////////
//////////////Borg Upgrades//////////////
/////////////////////////////////////////

/datum/design/borg_upgrade_rename
	name = "Cyborg Upgrade (Rename Board)"
	id = "borg_upgrade_rename"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/rename
	materials = list(MAT_METAL=35000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_restart
	name = "Cyborg Upgrade (Emergency Reboot Board)"
	id = "borg_upgrade_restart"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/restart
	materials = list(MAT_METAL=60000 , MAT_GLASS=5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_vtec
	name = "Cyborg Upgrade (VTEC Module)"
	id = "borg_upgrade_vtec"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/vtec
	materials = list(MAT_METAL=80000 , MAT_GLASS=6000 , MAT_URANIUM= 5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_thrusters
	name = "Cyborg Upgrade (Ion Thrusters)"
	id = "borg_upgrade_thrusters"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/thrusters
	materials = list(MAT_METAL=10000, MAT_PLASMA=5000, MAT_URANIUM = 6000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_disablercooler
	name = "Cyborg Upgrade (Rapid Disabler Cooling Module)"
	id = "borg_upgrade_disablercooler"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/disablercooler
	materials = list(MAT_METAL=80000 , MAT_GLASS=6000 , MAT_GOLD= 2000, MAT_DIAMOND = 500)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_diamonddrill
	name = "Cyborg Upgrade (Diamond Drill)"
	id = "borg_upgrade_diamonddrill"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/ddrill
	materials = list(MAT_METAL=10000, MAT_DIAMOND=2000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_holding
	name = "Cyborg Upgrade (Ore Satchel of Holding)"
	id = "borg_upgrade_holding"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/soh
	materials = list(MAT_METAL = 10000, MAT_GOLD = 250, MAT_URANIUM = 500)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_lavaproof
	name = "Cyborg Upgrade (Lavaproof Tracks)"
	id = "borg_upgrade_lavaproof"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/lavaproof
	materials = list(MAT_METAL = 10000, MAT_PLASMA = 4000, MAT_TITANIUM = 5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_syndicate_module
	name = "Cyborg Upgrade (Illegal Modules)"
	id = "borg_syndicate_module"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/syndicate
	materials = list(MAT_METAL=10000,MAT_GLASS=15000,MAT_DIAMOND = 10000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_selfrepair
	name = "Cyborg Upgrade (Self-repair)"
	id = "borg_upgrade_selfrepair"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/selfrepair
	materials = list(MAT_METAL=15000, MAT_GLASS=15000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_expandedsynthesiser
	name = "Cyborg Upgrade (Hypospray Expanded Synthesiser)"
	id = "borg_upgrade_expandedsynthesiser"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/hypospray/expanded
	materials = list(MAT_METAL=15000, MAT_GLASS=15000, MAT_PLASMA=5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_highstrengthsynthesiser
	name = "Cyborg Upgrade (Hypospray High-Strength Synthesiser)"
	id = "borg_upgrade_highstrengthsynthesiser"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/hypospray/high_strength
	materials = list(MAT_METAL=15000, MAT_GLASS=15000, MAT_PLASMA=10000, MAT_URANIUM=5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_piercinghypospray
	name = "Cyborg Upgrade (Piercing Hypospray)"
	id = "borg_upgrade_piercinghypospray"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/piercing_hypospray
	materials = list(MAT_METAL=15000, MAT_GLASS=15000, MAT_TITANIUM=10000, MAT_DIAMOND=5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_defibrillator
	name = "Cyborg Upgrade (Defibrillator)"
	id = "borg_upgrade_defibrillator"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/defib
	materials = list(MAT_METAL=15000, MAT_GLASS=15000, MAT_SILVER=10000, MAT_GOLD=10000, MAT_TITANIUM=5000, MAT_DIAMOND=5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_expand
	name = "Cyborg Upgrade (Expand)"
	id = "borg_upgrade_expand"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/expand
	materials = list(MAT_METAL=200000, MAT_TITANIUM=5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/boris_ai_controller
	name = "B.O.R.I.S. AI-Cyborg Remote Control Module"
	id = "borg_ai_control"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/ai
	materials = list(MAT_METAL = 1200, MAT_GLASS = 1500, MAT_GOLD = 200)
	construction_time = 50
	category = list("Misc")

/datum/design/borg_upgrade_rped
	name = "Cyborg Upgrade (RPED)"
	id = "borg_upgrade_rped"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/rped
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_pinpointer
	name = "Cyborg Upgrade (Crew pinpointer)"
	id = "borg_upgrade_pinpointer"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/pinpointer
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

//Misc
/datum/design/mecha_tracking
	name = "Exosuit Tracking Beacon"
	id = "mecha_tracking"
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/mecha_tracking
	materials = list(MAT_METAL=500)
	construction_time = 50
	category = list("Misc")

/datum/design/mecha_tracking_ai_control
	name = "AI Control Beacon"
	id = "mecha_tracking_ai_control"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_tracking/ai_control
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_SILVER = 200)
	construction_time = 50
	category = list("Misc")

/datum/design/drone_shell
	name = "Drone Shell"
	desc = "A shell of a maintenance drone, an expendable robot built to perform station repairs."
	id = "drone_shell"
	build_type = MECHFAB | PROTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 350)
	construction_time=150
	build_path = /obj/item/drone_shell
	category = list("Misc")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/synthetic_flash
	name = "Flash"
	desc = "When a problem arises, SCIENCE is the solution."
	id = "sflash"
	build_type = MECHFAB
	materials = list(MAT_METAL = 750, MAT_GLASS = 750)
	construction_time = 100
	build_path = /obj/item/device/assembly/flash/handheld
	category = list("Misc")
