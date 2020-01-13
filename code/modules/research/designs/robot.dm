/datum/design/robot/chassis
	name = "Cyborg Component (Robot endoskeleton)"
	desc = "Used to build a Robot endoskeleton."
	id = "robot_chassis"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_suit
	category = "Robot"
	materials = list(MAT_IRON=50000)

/datum/design/robot/torso
	name = "Cyborg Component (Robot torso)"
	desc = "Used to build a Robot torso."
	id = "robot_torso"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/chest
	category = "Robot"
	materials = list(MAT_IRON=40000)

/datum/design/robot/l_arm
	name = "Cyborg Component (Robot left arm)"
	desc = "Used to build a Robot left arm."
	id = "robot_larm"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_arm
	category = "Robot"
	materials = list(MAT_IRON=18000)

/datum/design/robot/r_arm
	name = "Cyborg Component (Robot right arm)"
	desc = "Used to build a Robot right arm."
	id = "robot_rarm"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_arm
	category = "Robot"
	materials = list(MAT_IRON=18000)

/datum/design/robot/l_leg
	name = "Cyborg Component (Robot left leg)"
	desc = "Used to build a Robot left leg."
	id = "robot_lleg"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_leg
	category = "Robot"
	materials = list(MAT_IRON=15000)

/datum/design/robot/r_leg
	name = "Cyborg Component (Robot right leg)"
	desc = "Used to build a Robot right leg."
	id = "robot_rleg"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_leg
	category = "Robot"
	materials = list(MAT_IRON=15000)

/datum/design/robot/head
	name = "Cyborg Component (Robot head)"
	desc = "Used to build a Robot head."
	id = "robot_head"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/head
	category = "Robot"
	materials = list(MAT_IRON=25000)

/datum/design/robot/ref_torso
	name = "Cyborg Component (Reinforced robot torso)"
	desc = "Used to build a reinforced Robot torso."
	id = "ref_robot_torso"
	req_tech = list(Tc_ENGINEERING = 4, Tc_MATERIALS = 4)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/chest/reinforced
	category = "Robot_Part"
	materials = list(MAT_IRON=40000, MAT_SILVER=10000, MAT_GOLD=5000, MAT_URANIUM=5000, MAT_DIAMOND=5000, MAT_PLASMA=5000)


//Components
/datum/design/robot/binary_commucation_device
	name = "Cyborg Component (Binary Communication Device)"
	desc = "Used to build a binary communication device."
	id = "robot_bin_comms"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/binary_communication_device
	category = "Robot_Part"
	materials = list(MAT_IRON=5000)

/datum/design/robot/radio
	name = "Cyborg Component (Radio)"
	desc = "Used to build a radio."
	id = "robot_radio"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/radio
	category = "Robot_Part"
	materials = list(MAT_IRON=5000)

/datum/design/robot/actuator
	name = "Cyborg Component (Actuator)"
	desc = "Used to build an actuator."
	id = "robot_actuator"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/actuator
	category = "Robot_Part"
	materials = list(MAT_IRON=5000)

/datum/design/robot/diagnosis_unit
	name = "Cyborg Component (Diagnosis Unit)"
	desc = "Used to build a diagnosis unit."
	id = "robot_diagnosis_unit"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/diagnosis_unit
	category = "Robot_Part"
	materials = list(MAT_IRON=5000)

/datum/design/robot/camera
	name = "Cyborg Component (Camera)"
	desc = "Used to build a diagnosis unit."
	id = "robot_camera"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/camera
	category = "Robot_Part"
	materials = list(MAT_IRON=5000)

/datum/design/robot/armour
	name = "Cyborg Component (Armor)"
	desc = "Used to build cyborg armor."
	id = "robot_armour"
	req_tech = list(Tc_ENGINEERING = 1)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/armour
	category = "Robot_Part"
	materials = list(MAT_IRON=5000)

/datum/design/robot/ref_binary_commucation_device
	name = "Cyborg Component (Reinf. Binary Comm. Device)"
	desc = "Used to build a reinforced binary communication device."
	id = "robot_ref_bin_comms"
	req_tech = list(Tc_ENGINEERING = 4, Tc_MATERIALS = 4)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/binary_communication_device/reinforced
	category = "Robot_Part"
	materials = list(MAT_IRON=5000, MAT_GOLD=5000)

/datum/design/robot/ref_radio
	name = "Cyborg Component (Reinforced Radio)"
	desc = "Used to build a reinforced radio."
	id = "robot_ref_radio"
	req_tech = list(Tc_ENGINEERING = 4, Tc_MATERIALS = 4)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/radio/reinforced
	category = "Robot_Part"
	materials = list(MAT_IRON=5000, MAT_URANIUM=5000)

/datum/design/robot/ref_actuator
	name = "Cyborg Component (Reinforced Actuator)"
	desc = "Used to build an reinforced actuator."
	id = "robot_ref_actuator"
	req_tech = list(Tc_ENGINEERING = 4, Tc_MATERIALS = 4)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/actuator/reinforced
	category = "Robot_Part"
	materials = list(MAT_IRON=5000, MAT_SILVER=5000)

/datum/design/robot/ref_diagnosis_unit
	name = "Cyborg Component (Reinforced Diagnosis Unit)"
	desc = "Used to build a reinforced diagnosis unit."
	id = "robot_ref_diagnosis_unit"
	req_tech = list(Tc_ENGINEERING = 4, Tc_MATERIALS = 4)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/diagnosis_unit/reinforced
	category = "Robot_Part"
	materials = list(MAT_IRON=5000, MAT_SILVER=5000)

/datum/design/robot/ref_camera
	name = "Cyborg Component (Reinforced Camera)"
	desc = "Used to build a reinforced diagnosis unit."
	id = "robot_ref_camera"
	req_tech = list(Tc_ENGINEERING = 4, Tc_MATERIALS = 4)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/camera/reinforced
	category = "Robot_Part"
	materials = list(MAT_IRON=5000, MAT_PLASMA=5000)

/datum/design/robot/ref_armour
	name = "Cyborg Component (Reinforced Armor)"
	desc = "Used to build reinforced cyborg armor."
	id = "robot_ref_armour"
	req_tech = list(Tc_ENGINEERING = 4, Tc_MATERIALS = 4)
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/armour/reinforced
	category = "Robot_Part"
	materials = list(MAT_IRON=5000, MAT_DIAMOND=5000)