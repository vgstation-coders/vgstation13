//Medical machinery boards.

/datum/design/cryo
	name = "Circuit Design (Cryo)"
	desc = "Allows for the construction of circuit boards used to build a Cryo Cell."
	id = "cryo"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_BIOTECH = 3, Tc_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/cryo

/datum/design/chem_dispenser
	name = "Circuit Design (Chemistry Dispenser)"
	desc = "Allows for the construction of circuit boards used to build a Chemistry Dispenser."
	id = "chem_dispenser"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_BIOTECH = 5, Tc_ENGINEERING = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/chem_dispenser

/datum/design/scan_console
	name = "Circuit Design (DNA Machine)"
	desc = "Allows for the construction of circuit boards used to build a new DNA scanning console."
	id = "scan_console"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_BIOTECH = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/scan_consolenew

/datum/design/defib_recharger
	name = "Circuit Design (Defib Recharger)"
	desc = "Allows for the construction of circuit boards used to build Defib Rechargers"
	id="defib_recharger"
	req_tech = list(Tc_POWERSTORAGE = 2, Tc_ENGINEERING = 2, Tc_PROGRAMMING = 3, Tc_BIOTECH = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/defib_recharger

/datum/design/chemmaster3000
	name = "Circuit Design (ChemMaster 3000)"
	desc = "Allows for the cosntruction of circuit boards used to build ChemMaster 3000s."
	id="chemmaster3000"
	req_tech = list ("engineering" = 3, "biotech" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/chemmaster3000

/datum/design/clonepod
	name = "Circuit Design (Clone Pod)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_BIOTECH = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/clonepod

/datum/design/clonescanner
	name = "Circuit Design (Cloning Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_BIOTECH = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/clonescanner

/datum/design/fbs
	name = "Circuit Design (Body Scanner)"
	desc = "Allows for the construction of circuit boards used to build a body scanner."
	id = "bodyscanner"
	req_tech = list(Tc_BIOTECH = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	build_path = /obj/item/weapon/circuitboard/fullbodyscanner

/datum/design/sleeper
	name = "Circuit Design (Sleeper)"
	desc = "Allows for the construction of circuit boards used to build a sleeper."
	id = "sleeper"
	req_tech = list(Tc_BIOTECH = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	build_path = /obj/item/weapon/circuitboard/sleeper

/datum/design/bioprinter
	name = "Circuit Design (Bioprinter)"
	desc = "Allows for the construction of Bioprinter equipment."
	id = "s-bioprinter"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_ENGINEERING = 2, Tc_BIOTECH = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/bioprinter

//CHEM HEATING/COOLING

/datum/design/chemheater
	name = "Circuit Design (Directed Laser Heater)"
	desc = "Allows for the construction of circuit boards used to build a directed laser heater."
	id = "chemheater"
	req_tech = list(Tc_BIOTECH = 3, Tc_ENGINEERING = 3, Tc_PROGRAMMING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/chemheater

/datum/design/chemcooler
	name = "Circuit Design (Cryonic Wave Projector)"
	desc = "Allows for the construction of circuit boards used to build a cryonic wave projector."
	id = "chemcooler"
	req_tech = list(Tc_BIOTECH = 3, Tc_ENGINEERING = 3, Tc_PROGRAMMING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/chemcooler

//VIROLOGY

/datum/design/incubator
	name = "Circuit Design (Pathogenic Incubator)"
	desc = "Allows for the construction of circuit boards used to build a pathogenic incubator."
	id = "incubator"
	req_tech = list(Tc_MATERIALS = 4, Tc_BIOTECH = 5, Tc_MAGNETS = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/incubator

/datum/design/diseaseanalyser
	name = "Circuit Design (Disease Analyser)"
	desc = "Allows for the construction of circuit boards used to build a disease analyzer."
	id = "diseaseanalyser"
	req_tech = list(Tc_ENGINEERING = 3, Tc_BIOTECH = 3, Tc_PROGRAMMING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/diseaseanalyser

/datum/design/splicer
	name = "Circuit Design (Disease Splicer)"
	desc = "Allows for the construction of circuit boards used to build a disease splicer."
	id = "splicer"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_BIOTECH = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/splicer

/datum/design/centrifuge
	name = "Circuit Design (Isolation Centrifuge)"
	desc = "Allows for the construction of circuit boards used to build an isolation centrifuge."
	id = "centrifuge"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_BIOTECH = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/centrifuge

