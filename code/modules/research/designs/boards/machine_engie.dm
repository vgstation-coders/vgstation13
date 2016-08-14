//Engineering related machinery boards.

//
//POWER STUFF
//

/datum/design/smes
	name = "Circuit Design (SMES) "
	desc = "Allows for the construction of circuit boards used to build SMES Power Storage Units."
	id="smes"
	req_tech = list(Tc_POWERSTORAGE = 4, Tc_ENGINEERING = 4, Tc_PROGRAMMING = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/smes

/datum/design/treadmill
	name = "Circuit Design (Treadmill Generator)"
	desc = "Allows for the construction of circuit boards used to build Treadmill Generators."
	id="treadmill"
	req_tech = list(Tc_POWERSTORAGE = 4, Tc_ENGINEERING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/treadmill

/datum/design/cell_charger
	name = "Circuit Design (Cell Charger)"
	desc = "Allows for the construction of circuit boards used to build a cell charger"
	id = "cellcharger"
	req_tech = list(Tc_MATERIALS = 2, Tc_ENGINEERING = 2, Tc_POWERSTORAGE = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/cell_charger

//
//P.A.C.M.A.N
//

/datum/design/pacman
	name = "PACMAN-type Generator Board"
	desc = "The circuit board that for a PACMAN-type portable generator."
	id = "pacman"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_PLASMATECH = 3, Tc_POWERSTORAGE = 3, Tc_ENGINEERING = 3)
	build_type = IMPRINTER
	reliability_base = 79
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/pacman

/datum/design/superpacman
	name = "SUPERPACMAN-type Generator Board"
	desc = "The circuit board that for a SUPERPACMAN-type portable generator."
	id = "superpacman"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_POWERSTORAGE = 4, Tc_ENGINEERING = 4)
	build_type = IMPRINTER
	reliability_base = 76
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/pacman/super

/datum/design/mrspacman
	name = "MRSPACMAN-type Generator Board"
	desc = "The circuit board that for a MRSPACMAN-type portable generator."
	id = "mrspacman"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_POWERSTORAGE = 5, Tc_ENGINEERING = 5)
	build_type = IMPRINTER
	reliability_base = 74
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/pacman/mrs

//
//ATMOSPHERIC MACHINERY.
//

/datum/design/freezer
	name = "Circuit Design (Freezer)"
	desc = "Allows for the construction of circuit boards to build freezers."
	id = "freezer"
	req_tech = list(Tc_POWERSTORAGE = 3, Tc_ENGINEERING = 4, Tc_BIOTECH = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/freezer

/datum/design/heater
	name = "Circuit Design (Heater)"
	desc = "Allows for the construction of circuit boards to build heaters."
	id ="heater"
	req_tech = list(Tc_POWERSTORAGE = 3, Tc_ENGINEERING = 5, Tc_BIOTECH = 4)
	build_type = IMPRINTER
	materials = list (MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/heater

/datum/design/pipedispenser
	name = "Circuit Design (Pipe Dispenser)"
	desc = "Allows for the construction of circuit boards used to build a Pipe Dispenser."
	id = "pipedispenser"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_MATERIALS = 3, Tc_ENGINEERING = 2, Tc_POWERSTORAGE = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/pipedispenser

/datum/design/pipedispenser/disposal
	name = "Circuit Design (Disposal Pipe Dispenser)"
	desc = "Allows for the construction of circuit boards used to build a Pipe Dispenser."
	id = "dpipedispenser"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_MATERIALS = 3, Tc_ENGINEERING = 2, Tc_POWERSTORAGE = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/pipedispenser/disposal

//
//MECHANICS MACHINES.
//

/datum/design/reverse_engine
	name = "Circuit Design (Reverse Engine)"
	desc = "Allows for the construction of circuit boards used to build a Reverse Engine."
	id = "reverse_engine"
	req_tech = list(Tc_MATERIALS = 6, Tc_PROGRAMMING = 4, Tc_ENGINEERING = 3, Tc_BLUESPACE = 3, Tc_POWERSTORAGE = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/reverse_engine

/datum/design/blueprinter
	name = "Circuit Design (Blueprint Printer)"
	desc = "Allows for the construction of circuit boards used to build a Blueprint Printer."
	id = "blueprinter"
	req_tech = list(Tc_ENGINEERING = 3, Tc_PROGRAMMING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/blueprinter

/datum/design/general_fab
	name = "Circuit Design (General Fabricator)"
	desc = "Allows for the construction of circuit boards used to build a General Fabricator."
	id = "gen_fab"
	req_tech = list(Tc_MATERIALS = 3, Tc_ENGINEERING = 2, Tc_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/generalfab

/datum/design/flatpacker
	name = "Circuit Design (Flatpack Fabricator)"
	desc = "Allows for the construction of circuit boards used to build a Flatpack Fabricator."
	id = "flatpacker"
	req_tech = list(Tc_MATERIALS = 5, Tc_ENGINEERING = 4, Tc_POWERSTORAGE = 3, Tc_PROGRAMMING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/flatpacker

//BEAMS.

/datum/design/prism
	name = "Circuit Design (Optical Prism)"
	desc = "Allows for the construction of circuit boards used to build an optical Prism"
	id = "prism"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/prism

//BEST ENGINE (DESIGN WISE)

/datum/design/rust_fuel_port
	name = "Internal circuitry (R-UST Mk. 7 fuel port)"
	desc = "Allows for the construction of circuit boards used to build a fuel injection port for the R-UST Mk. 7 fusion engine."
	id = "rust_fuel_port"
	req_tech = list(Tc_ENGINEERING = 4, Tc_MATERIALS = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20, MAT_URANIUM = 3000)
	category = "Misc"
	build_path = "/obj/item/weapon/module/rust_fuel_port"

/datum/design/rust_fuel_compressor
	name = "Circuit Design (R-UST Mk. 7 fuel compressor)"
	desc = "Allows for the construction of circuit boards used to build a fuel compressor of the R-UST Mk. 7 fusion engine."
	id = "rust_fuel_compressor"
	req_tech = list(Tc_MATERIALS = 6, Tc_PLASMATECH = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20, MAT_PLASMA = 3000, MAT_DIAMOND = 1000)
	category = "Misc"
	build_path = "/obj/item/weapon/module/rust_fuel_compressor"

/datum/design/rust_core
	name = "Internal circuitry (R-UST Mk. 7 tokamak core)"
	desc = "The circuit board that for a RUST-pattern tokamak fusion core."
	id = "pacman"
	req_tech = list(bluespace = 3, plasmatech = 4, magnets = 5, powerstorage = 6)
	build_type = IMPRINTER
	reliability_base = 79
	materials = list(MAT_GLASS = 2000, SACID = 20, MAT_PLASMA = 3000, MAT_DIAMOND = 2000)
	category = "Misc"
	build_path = "/obj/item/weapon/circuitboard/rust_core"

/datum/design/rust_injector
	name = "Internal circuitry (R-UST Mk. 7 tokamak core)"
	desc = "The circuit board that for a RUST-pattern particle accelerator."
	id = "pacman"
	req_tech = list(powerstorage = 3, engineering = 4, plasmatech = 4, materials = 6)
	build_type = IMPRINTER
	reliability_base = 79
	materials = list(MAT_GLASS = 2000, SACID = 20, MAT_PLASMA = 3000, MAT_URANIUM = 2000)
	category = "Misc"
	build_path = "/obj/item/weapon/circuitboard/rust_core"

//Cael shield gen designs.

/datum/design/shield_gen_ex
	name = "Circuit Design (Experimental hull shield generator)"
	desc = "Allows for the construction of circuit boards used to build an experimental hull shield generator."
	id = "shield_gen"
	req_tech = list(Tc_BLUESPACE = 4, Tc_PLASMATECH = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20, MAT_PLASMA = 10000, MAT_DIAMOND = 5000, MAT_GOLD = 10000)
	build_path = "/obj/machinery/shield_gen/external"

/datum/design/shield_gen
	name = "Circuit Design (Experimental shield generator)"
	desc = "Allows for the construction of circuit boards used to build an experimental shield generator."
	id = "shield_gen"
	req_tech = list(Tc_BLUESPACE = 4, Tc_PLASMATECH = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20, MAT_PLASMA = 10000, MAT_DIAMOND = 5000, MAT_GOLD = 10000)
	build_path = "/obj/machinery/shield_gen/external"

/datum/design/shield_cap
	name = "Circuit Design (Experimental shield capacitor)"
	desc = "Allows for the construction of circuit boards used to build an experimental shielding capacitor."
	id = "shield_cap"
	req_tech = list(Tc_MAGNETS = 3, Tc_POWERSTORAGE = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20, MAT_PLASMA = 10000, MAT_DIAMOND = 5000, MAT_SILVER = 10000)
	build_path = "/obj/machinery/shield_gen/external"
