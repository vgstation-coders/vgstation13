////////////////////////////////////////
//////////////MISC Boards///////////////
////////////////////////////////////////

/datum/design/board/smes
	name = "Machine Design (SMES Board)"
	desc = "The circuit board for a SMES."
	id = "smes"
	build_path = /obj/item/circuitboard/machine/smes
	category = list ("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/announcement_system
	name = "Machine Design (Automated Announcement System Board)"
	desc = "The circuit board for an automated announcement system."
	id = "automated_announcement"
	build_path = /obj/item/circuitboard/machine/announcement_system
	category = list("Subspace Telecomms")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/turbine_computer
	name = "Computer Design (Power Turbine Console Board)"
	desc = "The circuit board for a power turbine console."
	id = "power_turbine_console"
	build_path = /obj/item/circuitboard/computer/turbine_computer
	category = list ("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/emitter
	name = "Machine Design (Emitter Board)"
	desc = "The circuit board for an emitter."
	id = "emitter"
	build_path = /obj/item/circuitboard/machine/emitter
	category = list ("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/power_compressor
	name = "Machine Design (Power Compressor Board)"
	desc = "The circuit board for a power compressor."
	id = "power_compressor"
	build_path = /obj/item/circuitboard/machine/power_compressor
	category = list ("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/power_turbine
	name = "Machine Design (Power Turbine Board)"
	desc = "The circuit board for a power turbine."
	id = "power_turbine"
	build_path = /obj/item/circuitboard/machine/power_turbine
	category = list ("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/thermomachine
	name = "Machine Design (Freezer/Heater Board)"
	desc = "The circuit board for a freezer/heater."
	id = "thermomachine"
	build_path = /obj/item/circuitboard/machine/thermomachine
	category = list ("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/space_heater
	name = "Machine Design (Space Heater Board)"
	desc = "The circuit board for a space heater."
	id = "space_heater"
	build_path = /obj/item/circuitboard/machine/space_heater
	category = list ("Engineering Machinery")
	departmental_flags = ALL

/datum/design/board/teleport_station
	name = "Machine Design (Teleportation Station Board)"
	desc = "The circuit board for a teleportation station."
	id = "tele_station"
	build_path = /obj/item/circuitboard/machine/teleporter_station
	category = list ("Teleportation Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/teleport_hub
	name = "Machine Design (Teleportation Hub Board)"
	desc = "The circuit board for a teleportation hub."
	id = "tele_hub"
	build_path = /obj/item/circuitboard/machine/teleporter_hub
	category = list ("Teleportation Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/quantumpad
	name = "Machine Design (Quantum Pad Board)"
	desc = "The circuit board for a quantum telepad."
	id = "quantumpad"
	build_path = /obj/item/circuitboard/machine/quantumpad
	category = list ("Teleportation Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/launchpad
	name = "Machine Design (Bluespace Launchpad Board)"
	desc = "The circuit board for a bluespace Launchpad."
	id = "launchpad"
	build_path = /obj/item/circuitboard/machine/launchpad
	category = list ("Teleportation Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/launchpad_console
	name = "Machine Design (Bluespace Launchpad Console Board)"
	desc = "The circuit board for a bluespace launchpad Console."
	id = "launchpad_console"
	build_path = /obj/item/circuitboard/computer/launchpad_console
	category = list ("Teleportation Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/teleconsole
	name = "Computer Design (Teleporter Console)"
	desc = "Allows for the construction of circuit boards used to build a teleporter control console."
	id = "teleconsole"
	build_path = /obj/item/circuitboard/computer/teleporter
	category = list("Teleportation Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/sleeper
	name = "Machine Design (Sleeper Board)"
	desc = "The circuit board for a sleeper."
	id = "sleeper"
	build_path = /obj/item/circuitboard/machine/sleeper
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_MEDICAL
	category = list ("Medical Machinery")

/datum/design/board/cryotube
	name = "Machine Design (Cryotube Board)"
	desc = "The circuit board for a cryotube."
	id = "cryotube"
	build_path = /obj/item/circuitboard/machine/cryo_tube
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_MEDICAL
	category = list ("Medical Machinery")

/datum/design/board/chem_dispenser
	name = "Machine Design (Portable Chem Dispenser Board)"
	desc = "The circuit board for a portable chem dispenser."
	id = "chem_dispenser"
	build_path = /obj/item/circuitboard/machine/chem_dispenser
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_MEDICAL
	category = list ("Medical Machinery")

/datum/design/board/chem_master
	name = "Machine Design (Chem Master Board)"
	desc = "The circuit board for a Chem Master 3000."
	id = "chem_master"
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_MEDICAL
	build_path = /obj/item/circuitboard/machine/chem_master
	category = list ("Medical Machinery")

/datum/design/board/chem_heater
	name = "Machine Design (Chemical Heater Board)"
	desc = "The circuit board for a chemical heater."
	id = "chem_heater"
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_MEDICAL
	build_path = /obj/item/circuitboard/machine/chem_heater
	category = list ("Medical Machinery")

/datum/design/board/smoke_machine
	name = "Machine Design (Smoke Machine)"
	desc = "The circuit board for a smoke machine."
	id = "smoke_machine"
	build_path = /obj/item/circuitboard/machine/smoke_machine
	category = list ("Medical Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/board/reagentgrinder
	name = "Machine Design (All-In-One Grinder)"
	desc = "The circuit board for an All-In-One Grinder."
	id = "reagentgrinder"
	build_path = /obj/item/circuitboard/machine/reagentgrinder
	category = list ("Medical Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/clonecontrol
	name = "Computer Design (Cloning Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
	id = "clonecontrol"
	build_path = /obj/item/circuitboard/computer/cloning
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	category = list("Medical Machinery")

/datum/design/board/clonepod
	name = "Machine Design (Clone Pod)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	build_path = /obj/item/circuitboard/machine/clonepod
	category = list("Medical Machinery")

/datum/design/board/clonescanner
	name = "Machine Design (Cloning Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	build_path = /obj/item/circuitboard/machine/clonescanner
	category = list("Medical Machinery")

/datum/design/board/biogenerator
	name = "Machine Design (Biogenerator Board)"
	desc = "The circuit board for a biogenerator."
	id = "biogenerator"
	build_path = /obj/item/circuitboard/machine/biogenerator
	category = list ("Hydroponics Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/board/hydroponics
	name = "Machine Design (Hydroponics Tray Board)"
	desc = "The circuit board for a hydroponics tray."
	id = "hydro_tray"
	build_path = /obj/item/circuitboard/machine/hydroponics
	category = list ("Hydroponics Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/board/destructive_analyzer
	name = "Machine Design (Destructive Analyzer Board)"
	desc = "The circuit board for a destructive analyzer."
	id = "destructive_analyzer"
	build_path = /obj/item/circuitboard/machine/destructive_analyzer
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/experimentor
	name = "Machine Design (E.X.P.E.R.I-MENTOR Board)"
	desc = "The circuit board for an E.X.P.E.R.I-MENTOR."
	id = "experimentor"
	build_path = /obj/item/circuitboard/machine/experimentor
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/protolathe
	name = "Machine Design (Protolathe Board)"
	desc = "The circuit board for a protolathe."
	id = "protolathe"
	build_path = /obj/item/circuitboard/machine/protolathe
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/circuit_imprinter
	name = "Machine Design (Circuit Imprinter Board)"
	desc = "The circuit board for a circuit imprinter."
	id = "circuit_imprinter"
	build_path = /obj/item/circuitboard/machine/circuit_imprinter
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/rdservercontrol
	name = "Computer Design (R&D Server Control Console Board)"
	desc = "The circuit board for an R&D Server Control Console."
	id = "rdservercontrol"
	build_path = /obj/item/circuitboard/computer/rdservercontrol
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/rdserver
	name = "Machine Design (R&D Server Board)"
	desc = "The circuit board for an R&D Server."
	id = "rdserver"
	build_path = /obj/item/circuitboard/machine/rdserver
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/mechfab
	name = "Machine Design (Exosuit Fabricator Board)"
	desc = "The circuit board for an Exosuit Fabricator."
	id = "mechfab"
	build_path = /obj/item/circuitboard/machine/mechfab
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/cyborgrecharger
	name = "Machine Design (Cyborg Recharger Board)"
	desc = "The circuit board for a Cyborg Recharger."
	id = "cyborgrecharger"
	build_path = /obj/item/circuitboard/machine/cyborgrecharger
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/mech_recharger
	name = "Machine Design (Mechbay Recharger Board)"
	desc = "The circuit board for a Mechbay Recharger."
	id = "mech_recharger"
	build_path = /obj/item/circuitboard/machine/mech_recharger
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/microwave
	name = "Machine Design (Microwave Board)"
	desc = "The circuit board for a microwave."
	id = "microwave"
	build_path = /obj/item/circuitboard/machine/microwave
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/gibber
	name = "Machine Design (Gibber Board)"
	desc = "The circuit board for a gibber."
	id = "gibber"
	build_path = /obj/item/circuitboard/machine/gibber
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/board/smartfridge
	name = "Machine Design (Smartfridge Board)"
	desc = "The circuit board for a smartfridge."
	id = "smartfridge"
	build_path = /obj/item/circuitboard/machine/smartfridge
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/monkey_recycler
	name = "Machine Design (Monkey Recycler Board)"
	desc = "The circuit board for a monkey recycler."
	id = "monkey_recycler"
	build_path = /obj/item/circuitboard/machine/monkey_recycler
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SERVICE

/datum/design/board/seed_extractor
	name = "Machine Design (Seed Extractor Board)"
	desc = "The circuit board for a seed extractor."
	id = "seed_extractor"
	build_path = /obj/item/circuitboard/machine/seed_extractor
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/board/processor
	name = "Machine Design (Food Processor Board)"
	desc = "The circuit board for a food processor."
	id = "processor"
	build_path = /obj/item/circuitboard/machine/processor
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/board/slimeprocessor
	name = "Machine Design (Slime Processor Board)"
	desc = "The circuit board for a slime processor."
	id = "slimeprocessor"
	build_path = /obj/item/circuitboard/machine/processor/slime
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/recycler
	name = "Machine Design (Recycler Board)"
	desc = "The circuit board for a recycler."
	id = "recycler"
	build_path = /obj/item/circuitboard/machine/recycler
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/holopad
	name = "Machine Design (AI Holopad Board)"
	desc = "The circuit board for a holopad."
	id = "holopad"
	build_path = /obj/item/circuitboard/machine/holopad
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/autolathe
	name = "Machine Design (Autolathe Board)"
	desc = "The circuit board for an autolathe."
	id = "autolathe"
	build_path = /obj/item/circuitboard/machine/autolathe
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ALL		//Lets be honest here half the maps have public ones.

/datum/design/board/recharger
	name = "Machine Design (Weapon Recharger Board)"
	desc = "The circuit board for a Weapon Recharger."
	id = "recharger"
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 100)
	build_path = /obj/item/circuitboard/machine/recharger
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/vendor
	name = "Machine Design (Vendor Board)"
	desc = "The circuit board for a Vendor."
	id = "vendor"
	build_path = /obj/item/circuitboard/machine/vendor
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/ore_redemption
	name = "Machine Design (Ore Redemption Board)"
	desc = "The circuit board for an Ore Redemption machine."
	id = "ore_redemption"
	build_path = /obj/item/circuitboard/machine/ore_redemption
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/mining_equipment_vendor
	name = "Machine Design (Mining Rewards Vender Board)"
	desc = "The circuit board for a Mining Rewards Vender."
	id = "mining_equipment_vendor"
	build_path = /obj/item/circuitboard/machine/mining_equipment_vendor
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_CARGO

/datum/design/board/tesla_coil
	name = "Machine Design (Tesla Coil Board)"
	desc = "The circuit board for a tesla coil."
	id = "tesla_coil"
	build_path = /obj/item/circuitboard/machine/tesla_coil
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/grounding_rod
	name = "Machine Design (Grounding Rod Board)"
	desc = "The circuit board for a grounding rod."
	id = "grounding_rod"
	build_path = /obj/item/circuitboard/machine/grounding_rod
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/plantgenes
	name = "Machine Design (Plant DNA Manipulator Board)"
	desc = "The circuit board for a plant DNA manipulator."
	id = "plantgenes"
	build_path = /obj/item/circuitboard/machine/plantgenes
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/board/ntnet_relay
	name = "Machine Design (NTNet Relay Board)"
	desc = "The circuit board for a wireless network relay."
	id = "ntnet_relay"
	build_path = /obj/item/circuitboard/machine/ntnet_relay
	category = list("Subspace Telecomms")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/limbgrower
	name = "Machine Design (Limb Grower Board)"
	desc = "The circuit board for a limb grower."
	id = "limbgrower"
	build_path = /obj/item/circuitboard/machine/limbgrower
	category = list("Medical Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/board/deepfryer
	name = "Machine Design (Deep Fryer)"
	desc = "The circuit board for a Deep Fryer."
	id = "deepfryer"
	build_path = /obj/item/circuitboard/machine/deep_fryer
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/board/donksofttoyvendor
	name = "Machine Design (Donksoft Toy Vendor Board)"
	desc = "The circuit board for a Donksoft Toy Vendor."
	id = "donksofttoyvendor"
	build_path = /obj/item/circuitboard/machine/vending/donksofttoyvendor
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ALL			//Toys!!

/datum/design/board/cell_charger
	name = "Machine Design (Cell Charger Board)"
	desc = "The circuit board for a cell charger."
	id = "cell_charger"
	build_path = /obj/item/circuitboard/machine/cell_charger
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/dish_drive
	name = "Machine Design (Dish Drive)"
	desc = "The circuit board for a dish drive."
	id = "dish_drive"
	build_path = /obj/item/circuitboard/machine/dish_drive
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE
