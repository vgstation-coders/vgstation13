//These are things in the "robotics" category on the protolathe, not robotics things like mecha parts.

/datum/design/posibrain
	name = "Positronic Brain"
	desc = "Allows for the construction of a positronic brain"
	id = "posibrain"
	req_tech = list(Tc_ENGINEERING = 4, Tc_MATERIALS = 6, Tc_BLUESPACE = 2, Tc_PROGRAMMING = 4)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 2000, MAT_GLASS = 1000, MAT_SILVER = 1000, MAT_GOLD = 1000, MAT_PLASMA = 1000)
	category = "Robotics"
	build_path = /obj/item/device/mmi/posibrain

/datum/design/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	id = "mmi"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_BIOTECH = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_IRON = 1000, MAT_GLASS = 500)
	reliability_base = 76
	build_path = /obj/item/device/mmi
	category = "Robotics"

/datum/design/adv_lungs
	name = "Advanced Lungs"
	desc = "These lungs can operate at higher pressures, and provide built-in filtering capabilities."
	id = "adv_lungs"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_BIOTECH = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_IRON = 2000, MAT_GLASS = 500)
	build_path = /obj/item/organ/internal/lungs/filter
	category = "Robotics"

/datum/design/adv_eyes
	name = "Advanced Eyes"
	desc = "These eyes have built-in welding protection and enhance night-vision."
	id = "adv_eyes_1"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_BIOTECH = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_IRON = 500, MAT_GLASS = 2000)
	build_path = /obj/item/organ/internal/eyes/adv_1
	category = "Robotics"

/datum/design/adv_kidneys
	name = "Advanced Kidneys"
	desc = "These kidneys have advanced blood filtering systems to remove toxins from the body."
	id = "adv_kidneys"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_BIOTECH = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_IRON = 2000, MAT_GLASS = 500)
	build_path = /obj/item/organ/internal/kidneys/filter
	category = "Robotics"

/datum/design/mmi_radio
	name = "Radio-enabled Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a built-in radio."
	id = "mmi_radio"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_BIOTECH = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_IRON = 1200, MAT_GLASS = 500)
	reliability_base = 74
	build_path = /obj/item/device/mmi/radio_enabled
	category = "Robotics"

/datum/design/synthetic_flash
	name = "Synthetic Flash"
	desc = "When a problem arises, SCIENCE is the solution."
	id = "sflash"
	req_tech = list(Tc_MAGNETS = 3, Tc_COMBAT = 2)
	build_type = MECHFAB
	materials = list(MAT_IRON = 750, MAT_GLASS = 750)
	reliability_base = 76
	build_path = /obj/item/device/flash/synthetic
	category = "Robotics"

/datum/design/nanopaste
	name = "Nanopaste"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	id = "nanopaste"
	req_tech = list(Tc_MATERIALS = 4, Tc_ENGINEERING = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 7000, MAT_GLASS = 7000)
	category = "Robotics"
	build_path = /obj/item/stack/nanopaste

/datum/design/robotanalyzer
	name = "Cyborg Analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	id = "robotanalyzer"
	req_tech = list(Tc_MAGNETS = 3, Tc_ENGINEERING = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 8000, MAT_GLASS = 2000)
	category = "Robotics"
	build_path = /obj/item/device/robotanalyzer

/datum/design/diagnostic_hud
	name = "Diagnostic HUD"
	desc = "A heads-up display that displays diagnostic information for compatible cyborgs and exosuits."
	id = "diagnostic_hud"
	req_tech = list(Tc_BIOTECH = 2, Tc_MAGNETS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 100, MAT_GLASS = 100)
	category = "Robotics"
	build_path = /obj/item/clothing/glasses/hud/diagnostic