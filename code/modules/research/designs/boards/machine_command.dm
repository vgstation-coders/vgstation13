//Command related machinery.

/datum/design/aicore
	name = "Circuit Design (AI Core)"
	desc = "Allows for the construction of circuit boards used to build new AI cores."
	id = "aicore"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_BIOTECH = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/aicore
	locked = 1
	req_lock_access = list(access_rnd, access_robotics, access_rd)

/datum/design/pdapainter
	name = "PDA Painter Board"
	desc = "The circuit board for a PDA Painter."
	id = "pdapainter"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_ENGINEERING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/pdapainter

/datum/design/telehub
	name = "Circuit Design (Teleporter Generator)"
	desc = "Allows for the construction of circuit boards used to build a Teleporter Generator"
	id = "telehub"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_ENGINEERING = 3, Tc_BLUESPACE = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/telehub

/datum/design/telestation
	name = "Circuit Design (Teleporter Controller)"
	desc = "Allows for the construction of circuit boards used to build a Teleporter Controller."
	id = "telestation"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_ENGINEERING = 3, Tc_BLUESPACE = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/telestation

/datum/design/laborconsole
	name = "Circuit Design (Labor Administration Console)"
	desc = "Allows for the construction of circuit boards used to build a labor administration console."
	id = "laborconsole"
	req_tech = list(Tc_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/labor
