//Misc machinery boards.

/datum/design/recharge_station
	name = "Circuit Design (Cyborg Recharging Station)"
	desc = "Allows for the construction of circuit boards used to build a Cyborg Recharging Station."
	id = "recharge_station"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_POWERSTORAGE = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/recharge_station

/datum/design/photocopier
	name = "Circuit Design (Photocopier)"
	desc = "Allows for the construction of circuit boards to build photocopiers."
	id = "photocopier"
	req_tech = list ("powerstorage" = 2, "engineering" = 2, "programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/photocopier

/datum/design/fax
	name = "Circuit Design (Fax)"
	desc = "Allows for the construction of circuit boards to build fax machines."
	id = "fax"
	req_tech = list ("bluespace" = 2, "materials" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/fax

/datum/design/condimaster
	name = "Circuit Design (CondiMaster)"
	desc = "Allows for the cosntruction of circuit boards used to build CondiMasters"
	id="condimaster"
	req_tech = list ("engineering" = 3, "biotech" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/condimaster

/datum/design/snackbarmachine
	name = "Circuit Design (SnackBar Machine)"
	desc = "Allows for the cosntruction of circuit boards used to build SnackBar Machines"
	id="snackbarmachine"
	req_tech = list ("engineering" = 3, "biotech" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/snackbar_machine

/datum/design/processing_unit
	name = "Circuit Design (Ore Processor)"
	desc = "Allows for the construction of circuit boards used to build an ore processor."
	id = "smelter"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_MATERIALS = 3, Tc_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/processing_unit

/datum/design/processing_unit/recycling
	name = "Circuit Design (Recycling Furnace)"
	desc = "Allows for the construction of circuit boards used to build a recycling furnace."
	id = "smelter_recycling"
	build_path = /obj/item/weapon/circuitboard/processing_unit/recycling

/datum/design/stacking_unit
	name = "Circuit Design (Stacking Machine)"
	desc = "Allows for the construction of circuit boards used to build a stacking machine."
	id = "stackingmachine"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_MATERIALS = 3, Tc_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/stacking_unit

/datum/design/vendomat
	name = "Circuit Design (Vending Machine)"
	desc = "Allows for the construction of circuit boards used to build a vending machines."
	id = "vendomat"
	req_tech = list(Tc_MATERIALS = 1, Tc_ENGINEERING = 1, Tc_POWERSTORAGE = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Misc"
	build_path = /obj/item/weapon/circuitboard/vendomat

/datum/design/sorting_machine
	name = "Circuit Design (Recycling Sorting Machine)"
	desc = "Allows for the construction of circuit boards used to build a recycling sorting machine"
	id = "sortingmachine"
	req_tech = list(Tc_MATERIALS = 3, Tc_ENGINEERING = 3, Tc_PROGRAMMING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	build_path = /obj/item/weapon/circuitboard/sorting_machine/recycling

/datum/design/sorting_machine/destination
	name = "Circuit Design (Destinations Sorting Machine)"
	desc = "Allows for the construction of circuit boards used to build a destinations sorting machine"
	id = "destsortingmachine"
	build_path = /obj/item/weapon/circuitboard/sorting_machine/destination

/datum/design/washing_machine
	name = "Circuit Design (Washing Machine)"
	desc = "Allows for the construction of circuit boards used to build a washing machine."
	id = "washingmachine"
	req_tech = list(Tc_MATERIALS = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	build_path = /obj/item/weapon/circuitboard/washing_machine

/datum/design/dses_range_boost
	name = "DSES range booster"
	desc = "A high-gain amplifier circuit for a DSES receiver, effectively doubling the range."
	id = "dses_range_boost"
	req_tech = list(Tc_BLUESPACE = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_SILVER = 100, SACID = 20)
	build_path = /obj/item/weapon/dses_module/range_boost

/datum/design/dses_cost_reduc
	name = "DSES ping resource optimizer"
	desc = "Optimizes the cost of DSES pings, reducing the amount of energy needed per ping."
	id = "dses_cost_reduc"
	req_tech = list(Tc_POWERSTORAGE = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, MAT_URANIUM = 50, SACID = 20)
	build_path = /obj/item/weapon/dses_module/cost_reduc

/datum/design/dses_pulse_dir
	name = "DSES ping resonation locator"
	desc = "A much more sensitive listening system which can give a direction to a bounce-back ping."
	id = "dses_ping_res"
	req_tech = list(Tc_BLUESPACE = 3, Tc_MAGNETS = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 75, MAT_SILVER = 75, SACID = 20)
	build_path = /obj/item/weapon/dses_module/pulse_direction


/datum/design/dses_gps_log
	name = "DSES ping resonance logger"
	desc = "Basic memory unit for co-ordinating and logging the locations of succesful pings."
	id = "dses_ping_log"
	req_tech = list(Tc_PROGRAMMING = 3, Tc_MAGNETS = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 300, MAT_SILVER = 300, MAT_DIAMOND = 100, SACID = 30)
	build_path = /obj/item/weapon/dses_module/gps_logger

/datum/design/dses_auto_ping
	name = "DSES automated ping system"
	desc = "Basic clock timer for automating the pinging system, turning it into a toggle."
	id = "dses_auto_ping"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2500, MAT_URANIUM = 300, MAT_DIAMOND = 100, SACID = 30)
	build_path = /obj/item/weapon/dses_module/ping_timer

/datum/design/dses_dist_get
	name = "DSES ping distance approximation system"
	desc = "A small mathematic system that calculates signal decay between transmission and sending, to approximate distance."
	id = "dses_dist_get"
	req_tech = list(Tc_BLUESPACE = 4, Tc_MAGNETS = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2500, MAT_PLASMA = 300, MAT_URANIUM = 100, SACID = 30)
	build_path = /obj/item/weapon/dses_module/distance_get