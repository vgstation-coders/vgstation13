//Command related computers & consoles.

/datum/design/lawupload
	name = "Circuit Design (Law Upload)"
	desc = "Allows for the construction of circuit boards used to build an Law Upload Console."
	id = "lawupload"
	req_tech = list(Tc_PROGRAMMING = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/lawupload
	locked = 1
	req_lock_access = list(access_rnd, access_robotics, access_rd)

/datum/design/lawupload/longrange
	name = "Circuit Design (Long Range Law Upload)"
	desc = "Allows for the construction of circuit boards used to build a Long Range Law Upload Console."
	id = "lawuploadlongrange"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_MATERIALS = 9, Tc_BLUESPACE = 3, Tc_MAGNETS = 5)
	materials = list(MAT_GLASS = 2000, SACID = 20)
	build_path = /obj/item/weapon/circuitboard/lawupload/longrange

/datum/design/comconsole
	name = "Circuit Design (Communications)"
	desc = "Allows for the construction of circuit boards used to build a communications console."
	id = "comconsole"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_MAGNETS = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/communications

/datum/design/idcardconsole
	name = "Circuit Design (ID Computer)"
	desc = "Allows for the construction of circuit boards used to build an ID computer."
	id = "idcardconsole"
	req_tech = list(Tc_PROGRAMMING = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/card

/datum/design/teleconsole
	name = "Circuit Design (Teleporter Console)"
	desc = "Allows for the construction of circuit boards used to build a teleporter control console."
	id = "teleconsole"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_BLUESPACE = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/teleporter
