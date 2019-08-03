/datum/design/bruise_pack
	name = "Roll of gauze"
	desc = "Some sterile gauze to wrap around bloody stumps."
	id = "bruise_pack"
	req_tech = list(Tc_BIOTECH = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 400, MAT_GLASS = 125)
	category = "Medical"
	build_path = /obj/item/stack/medical/bruise_pack

/datum/design/ointment
	name = "Ointment"
	desc = "Used to treat those nasty burns."
	id = "ointment"
	req_tech = list(Tc_BIOTECH = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 400, MAT_GLASS = 125)
	category = "Medical"
	build_path = /obj/item/stack/medical/ointment

/datum/design/adv_bruise_pack
	name = "Advanced trauma kit"
	desc = "Used to treat those nasty bruises."
	id = "adv_bruise_pack"
	req_tech = list(Tc_BIOTECH = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 600, MAT_GLASS = 250)
	category = "Medical"
	build_path = /obj/item/stack/medical/advanced/bruise_pack

/datum/design/adv_ointment
	name = "Advanced burn kit"
	desc = "Used to treat those nasty burns."
	id = "adv_ointment"
	req_tech = list(Tc_BIOTECH = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 600, MAT_GLASS = 250)
	category = "Medical"
	build_path = /obj/item/stack/medical/advanced/ointment

/datum/design/adv_reagent_scanner
	name = "Advanced Reagent Scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents."
	id = "adv_mass_spectrometer"
	req_tech = list(Tc_BIOTECH = 2, Tc_MAGNETS = 4)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 30, MAT_GLASS = 20)
	category = "Medical"
	build_path = /obj/item/device/reagent_scanner/adv
/*
/datum/design/adv_mass_spectrometer
	name = "Advanced Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood and their quantities."
	id = "adv_mass_spectrometer"
	req_tech = list(Tc_BIOTECH = 2, Tc_MAGNETS = 4)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 30, MAT_GLASS = 20)
	reliability_base = 74
	category = "Medical"
	build_path = /obj/item/device/mass_spectrometer/adv
*/
/datum/design/defibrillator
	name = "Defibrillator"
	desc = "A handheld emergency defibrillator, used to bring people back from the brink of death or put them there."
	id = "defibrillator"
	req_tech = list(Tc_MAGNETS = 3, Tc_MATERIALS = 4, Tc_BIOTECH = 4)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 9000, MAT_SILVER = 250, MAT_GLASS = 10000)
	category = "Medical"
	build_path = /obj/item/weapon/melee/defibrillator

/datum/design/healthanalyzer
	name = "Health Analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	id = "healthanalyzer"
	req_tech = list(Tc_MAGNETS = 2, Tc_BIOTECH = 2)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 1000, MAT_GLASS = 1000)
	category = "Medical"
	build_path = /obj/item/device/healthanalyzer

/datum/design/electricthermometer
	name = "Electronic thermometer"
	desc = "An electronic thermal probe used to accurately read the temperature of an object."
	id = "electricthermometer"
	req_tech = list(Tc_ENGINEERING = 3, Tc_BIOTECH = 2)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 1000, MAT_GLASS = 1000)
	category = "Medical"
	build_path = /obj/item/weapon/thermometer/electronic

/datum/design/health_hud
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	id = "health_hud"
	req_tech = list(Tc_BIOTECH = 2, Tc_MAGNETS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 50, MAT_GLASS = 50)
	category = "Medical"
	build_path = /obj/item/clothing/glasses/hud/health

/datum/design/chemmask
	name = "Chemical Mask"
	desc = "A rather sinister mask designed for connection to a chemical pack, providing the pack's safeties are disabled."
	id = "chemmask"
	req_tech = list(Tc_BIOTECH = 5, Tc_MATERIALS = 5, Tc_ENGINEERING = 5, Tc_COMBAT = 5, Tc_SYNDICATE = 5)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 500, MAT_SILVER = 100)
	category = "Medical"
	build_path = /obj/item/clothing/mask/chemmask

/datum/design/antibody_scanner
	name = "Immunity Scanner"
	desc = "A hand-held body scanner able to evaluate the immune system of the subject."
	id = "antibody_scanner"
	req_tech = list(Tc_MAGNETS = 2, Tc_BIOTECH = 2)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 1000, MAT_GLASS = 1000)
	category = "Medical"
	build_path = /obj/item/device/antibody_scanner

/datum/design/plasmabeaker
	name = "Plasma Beaker"
	desc = "A beaker designed to act as a catalyst in some reactions."
	id = "plasmabeaker"
	req_tech = list(Tc_PLASMATECH = 4, Tc_MATERIALS = 4)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 3750, MAT_PLASMA = 8000)
	category = "Medical"
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/large/plasma