//Medical machinery boards.

/datum/design/cryo
	name = "Circuit Design (Cryo)"
	desc = "Allows for the construction of circuit boards used to build a Cryo Cell."
	id = "cryo"
	req_tech = list(PROGRAMMING = 4, BIOTECH = 3, ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/cryo

/datum/design/chem_dispenser
	name = "Circuit Design (Chemistry Dispenser)"
	desc = "Allows for the construction of circuit boards used to build a Chemistry Dispenser."
	id = "chem_dispenser"
	req_tech = list(PROGRAMMING = 3, BIOTECH = 5, ENGINEERING = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/chem_dispenser

/datum/design/scan_console
	name = "Circuit Design (DNA Machine)"
	desc = "Allows for the construction of circuit boards used to build a new DNA scanning console."
	id = "scan_console"
	req_tech = list(PROGRAMMING = 2, BIOTECH = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/scan_consolenew

/datum/design/defib_recharger
	name = "Circuit Design (Defib Recharger)"
	desc = "Allows for the construction of circuit boards used to build Defib Rechargers"
	id="defib_recharger"
	req_tech = list(POWERSTORAGE = 2, ENGINEERING = 2, PROGRAMMING = 3, BIOTECH = 4)
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
	req_tech = list(PROGRAMMING = 3, BIOTECH = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/clonepod

/datum/design/clonescanner
	name = "Circuit Design (Cloning Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	req_tech = list(PROGRAMMING = 3, BIOTECH = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/clonescanner

/datum/design/fbs
	name = "Circuit Design (Body Scanner)"
	desc = "Allows for the construction of circuit boards used to build a body scanner."
	id = "bodyscanner"
	req_tech = list(BIOTECH = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	build_path = /obj/item/weapon/circuitboard/fullbodyscanner

/datum/design/sleeper
	name = "Circuit Design (Sleeper)"
	desc = "Allows for the construction of circuit boards used to build a sleeper."
	id = "sleeper"
	req_tech = list(BIOTECH = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	build_path = /obj/item/weapon/circuitboard/sleeper

/datum/design/bioprinter
	name = "Circuit Design (Bioprinter)"
	desc = "Allows for the construction of Bioprinter equipment."
	id = "s-bioprinter"
	req_tech = list(PROGRAMMING = 3, ENGINEERING = 2, BIOTECH = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/bioprinter

//VIROLOGY

/datum/design/incubator
	name = "Circuit Design (Pathogenic Incubator)"
	desc = "Allows for the construction of circuit boards used to build a pathogenic incubator."
	id = "incubator"
	req_tech = list(MATERIALS = 4, BIOTECH = 5, MAGNETS = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/incubator

/datum/design/diseaseanalyser
	name = "Circuit Design (Disease Analyser)"
	desc = "Allows for the construction of circuit boards used to build a disease analyzer."
	id = "diseaseanalyser"
	req_tech = list(ENGINEERING = 3, BIOTECH = 3, PROGRAMMING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/diseaseanalyser

/datum/design/splicer
	name = "Circuit Design (Disease Splicer)"
	desc = "Allows for the construction of circuit boards used to build a disease splicer."
	id = "splicer"
	req_tech = list(PROGRAMMING = 3, BIOTECH = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/splicer

/datum/design/centrifuge
	name = "Circuit Design (Isolation Centrifuge)"
	desc = "Allows for the construction of circuit boards used to build an isolation centrifuge."
	id = "centrifuge"
	req_tech = list(PROGRAMMING = 3, BIOTECH = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/centrifuge

