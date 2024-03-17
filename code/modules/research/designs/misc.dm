/datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells. Harmless to other organic life."
	id = "flora_gun"
	req_tech = list(Tc_MATERIALS = 2, Tc_BIOTECH = 3, Tc_POWERSTORAGE = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 2000, MAT_GLASS = 500, MAT_URANIUM = 500)
	category = "Misc"
	build_path = /obj/item/weapon/gun/energy/floragun

/datum/design/janicart_upgrade
	name = "Janicart Upgrade Module"
	desc = "Used to allow the janicart to clean surfaces while moving."
	id = "janicart_upgrade"
	build_type = PROTOLATHE | MECHFAB
	build_path = /obj/item/mecha_parts/janicart_upgrade
	req_tech = list(Tc_ENGINEERING = 1, Tc_MATERIALS = 1)
	materials = list(MAT_IRON=10000)
	category = "Misc"

/datum/design/chempack
	name = "Chemical Pack"
	desc = "Useful for the storage and transport of large volumes of chemicals. Can be used in conjunction with a wide range of chemical-dispensing devices."
	id = "chempack"
	build_type = PROTOLATHE
	build_path = /obj/item/weapon/reagent_containers/chempack
	req_tech = list(Tc_ENGINEERING = 5, Tc_MATERIALS = 3, Tc_BLUESPACE = 3)
	materials = list(MAT_GLASS = 8000, MAT_IRON=2000)
	category = "Misc"

/datum/design/high_roller
	name = "High Roller"
	desc = "A large two-handed paint roller that can cover floors and walls in paint much quicker than with a regular paint roller. Although you can use it to spread any reagent."
	id = "high_roller"
	build_type = PROTOLATHE
	build_path = /obj/item/high_roller
	req_tech = list(Tc_ENGINEERING = 2, Tc_MATERIALS = 3)
	materials = list(MAT_IRON=18750)
	category = "Misc"

/datum/design/mannequin_frame
	name = "Cyber Mannequin Frame"
	desc = "So much effort just just display material goods."
	id = "mannequin_frame"
	build_type = MECHFAB
	build_path = /obj/structure/mannequin_frame
	req_tech = list(Tc_ENGINEERING = 1, Tc_MATERIALS = 1)
	materials = list(MAT_IRON=37500)
	category = "Misc"

/datum/design/polarized_contacts
	name = "Polarized Contacts"
	desc = "Shield your eyes from flashes in style."
	id = "polarized_contacts"
	build_type = PROTOLATHE
	build_path = /obj/item/clothing/glasses/contacts/polarized
	req_tech = list(Tc_ENGINEERING = 4, Tc_MATERIALS = 4, Tc_BIOTECH = 5)
	materials = list(MAT_GLASS = 2000)
	category = "Misc"

/datum/design/xenobiobag
	name = "Slime Extract Bag"
	desc = "A bag that is capable of carrying slime extracts and slime products."
	id = "extract_bag"
	build_type = PROTOLATHE
	build_path = /obj/item/weapon/storage/bag/xenobio
	req_tech = list(Tc_ENGINEERING = 1, Tc_MATERIALS = 1)
	materials = list(MAT_GLASS = 500, MAT_IRON = 750)
	category = "Misc"

/datum/design/fishtank_helper
	name = "Aquarium Clean Module"
	desc = "Automates cleaning of aquariums. Fits all sizes."
	id = "fishtank_helper"
	build_type = PROTOLATHE
	build_path = /obj/item/weapon/fishtools/fishtank_helper
	req_tech = list(Tc_MATERIALS = 2, Tc_BIOTECH = 2, Tc_PROGRAMMING = 2)
	materials = list(MAT_GLASS = 500, MAT_IRON = 1000)
	category = "Misc"

/datum/design/library_scanner
	name = "Barcode Scanner"
	desc = "Used in registering books for checkin/checkout and longterm archive."
	id = "libscanner"
	build_type = PROTOLATHE
	build_path = /obj/item/weapon/barcodescanner
	req_tech = list(Tc_PROGRAMMING = 1)
	materials = list(MAT_GLASS = 300, MAT_IRON = 500)
	category = "Misc"

/datum/design/dses
	name = "Deep Space Exploration System"
	desc = "A GPS with a high-gain radio antenna and broadcaster for locating proximity objects in space, the explorers friend."
	id = "dses"
	req_tech = list(Tc_BLUESPACE = 4, Tc_MAGNETS = 4)
	build_type = PROTOLATHE | PODFAB
	materials = list(MAT_IRON = 1600, MAT_GLASS = 400)
	category = "Bluespace"
	build_path = /obj/item/device/dses

/datum/design/dses_module_rangeboost
	name = "DSES Ping Long-Range Listener"
	desc = "A high-gain amplifier circuit for a DSES receiver, effectively doubling the range."
	id = "dses_module_rangeboost"
	req_tech = list(Tc_BLUESPACE = 4)
	build_type = PROTOLATHE | PODFAB
	materials = list(MAT_GLASS=3000, MAT_IRON=2500)
	category = "Misc"
	build_path = /obj/item/dses_module/range_boost

/datum/design/dses_module_costreduc
	name = "DSES Ping Resource Optimizer"
	desc = "Optimizes the cost of DSES pings, reducing the amount of energy needed per ping."
	id = "dses_module_costreduc"
	req_tech = list(Tc_POWERSTORAGE = 4)
	build_type = PROTOLATHE | PODFAB
	materials = list(MAT_GLASS=4000)
	category = "Misc"
	build_path = /obj/item/dses_module/cost_reduc

/datum/design/dses_module_pulsedirection
	name = "DSES Ping Resonation Locator"
	desc = "A much more sensitive listening system which can give a direction to a bounce-back ping."
	id = "dses_module_pulsedirection"
	req_tech = list(Tc_BLUESPACE = 4, Tc_MAGNETS = 4)
	build_type = PROTOLATHE | PODFAB
	materials = list(MAT_GLASS=2000, MAT_IRON=3000)
	category = "Misc"
	build_path = /obj/item/dses_module/pulse_direction

/datum/design/dses_module_gpslogger
	name = "DSES Ping Resonance Logger"
	desc = "Basic memory unit for co-ordinating and logging the locations of succesful pings."
	id = "dses_module_gpslogger"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_MAGNETS = 4)
	build_type = PROTOLATHE | PODFAB
	materials = list(MAT_GLASS=2000, MAT_IRON=2000)
	category = "Misc"
	build_path = /obj/item/dses_module/gps_logger

/datum/design/dses_module_pingtimer
	name = "DSES Automated Ping System"
	desc = "Basic clock timer for automating the pinging system, turning it into a toggle."
	id = "dses_module_pingtimer"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_ENGINEERING = 3)
	build_type = PROTOLATHE | PODFAB
	materials = list(MAT_GLASS=2000)
	category = "Misc"
	build_path = /obj/item/dses_module/ping_timer

/datum/design/dses_module_distanceget
	name = "DSES Ping Distance Approximation System"
	desc = "A small mathematic system that calculates signal decay between transmission and sending, to approximate distance."
	id = "dses_module_distanceget"
	req_tech = list(Tc_BLUESPACE = 4, Tc_MAGNETS = 3)
	build_type = PROTOLATHE | PODFAB
	materials = list(MAT_GLASS=2000, MAT_IRON=1000)
	category = "Misc"
	build_path = /obj/item/dses_module/distance_get

/datum/design/trackingglasses
	name = "Eye Tracking Glasses"
	desc = "Eye tracking glasses which allow the wearer to see what others are looking at."
	id = "trackingglasses"
	req_tech = list(Tc_MATERIALS = 6)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 500, MAT_GLASS = 1000, MAT_DIAMOND = 500)
	category = "Misc"
	build_path = /obj/item/clothing/glasses/hud/tracking
