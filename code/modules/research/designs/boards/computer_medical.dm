//Medical computer & console boards.

/datum/design/med_data
	name = "Circuit Design (Medical Records)"
	desc = "Allows for the construction of circuit boards used to build a medical records console."
	id = "med_data"
	req_tech = list(Tc_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/med_data

/datum/design/operating
	name = "Circuit Design (Operating Computer)"
	desc = "Allows for the construction of circuit boards used to build an operating computer console."
	id = "operating"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_BIOTECH = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/operating

///datum/design/pandemic
//	name = "Circuit Design (PanD.E.M.I.C. 2200)"
//	desc = "Allows for the construction of circuit boards used to build a PanD.E.M.I.C. 2200 Console."
//	id = "pandemic"
//	req_tech = list(Tc_PROGRAMMING = 2, Tc_BIOTECH = 2)
//	build_type = IMPRINTER
//	materials = list(MAT_GLASS = 2000, SACID = 20)
//	category = "Console Boards"
//	build_path = /obj/item/weapon/circuitboard/pandemic

/datum/design/crewconsole
	name = "Circuit Design (Crew monitoring computer)"
	desc = "Allows for the construction of circuit boards used to build a Crew monitoring computer."
	id = "crewconsole"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_MAGNETS = 2, Tc_BIOTECH = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/crew

/datum/design/clonecontrol
	name = "Circuit Design (Cloning Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
	id = "clonecontrol"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_BIOTECH = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/cloning
