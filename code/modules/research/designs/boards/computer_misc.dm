//Misc. computer & console boards.

/datum/design/arcademachine
	name = "Circuit Design (Arcade Machine)"
	desc = "Allows for the construction of circuit boards used to build a new arcade machine."
	id = "arcademachine"
	req_tech = list(Tc_PROGRAMMING = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/arcade

/datum/design/ordercomp
	name = "Circuit Design (Supply ordering console)"
	desc = "Allows for the construction of circuit boards used to build a Supply ordering console."
	id = "ordercomp"
	req_tech = list(Tc_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/ordercomp

/datum/design/supplycomp
	name = "Circuit Design (Supply shuttle console)"
	desc = "Allows for the construction of circuit boards used to build a Supply shuttle console."
	id = "supplycomp"
	req_tech = list(Tc_PROGRAMMING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/supplycomp

/datum/design/mining
	name = "Circuit Design (Outpost Status Display)"
	desc = "Allows for the construction of circuit boards used to build an outpost status display console."
	id = "mining"
	req_tech = list(Tc_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/mining

/datum/design/pda_terminal
	name = "Circuit Design (PDA Terminal)"
	desc = "Allows for the construction of circuit boards used to build a PDA Terminal."
	id = "pda_terminal"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_BLUESPACE = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/pda_terminal

/datum/design/pod
	name = "Circuit Design (Mass Driver and Pod Doors Control)"
	desc = "Allows for the construction of circuit boards used to build a Mass Driver and Pod Doors Control."
	id = "pod"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_ENGINEERING = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/pod

/datum/design/smeltcomp
	name = "Circuit Design (Ore Processing Console)"
	desc = "Allows for the construction of circuit boards used to build an ore processing console."
	id = "smeltcomp"
	req_tech = list(Tc_MATERIALS = 2, Tc_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/smeltcomp

/datum/design/stacking_unit_console
	name = "Circuit Design (Stacking Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a stacking machine console."
	id = "stackconsole"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_MATERIALS = 3, Tc_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/stacking_machine_console

/datum/design/shuttle_control
	name = "Circuit Design (Universal Shuttle Control)"
	desc = "Allows for the construction of circuit boards used to build a Shuttle Control console."
	id = "shuttlecontrol"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_ENGINEERING = 3, Tc_BLUESPACE = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/shuttle_control
