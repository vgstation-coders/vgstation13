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

/datum/design/recharger
	name = "Circuit Design (Recharger)"
	desc = "Allows for the construction of circuit boards used to build Weapon Rechargers"
	id="recharger"
	req_tech = list(Tc_POWERSTORAGE = 2, Tc_COMBAT = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 3)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/recharger


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

/datum/design/coin_press
	name = "Circuit Design (Coin Press)"
	desc = "Allows for the construction of circuit boards used to build a coin press."
	id = "coin_press"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_MATERIALS = 3, Tc_ENGINEERING = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/coin_press

/datum/design/vendomat
	name = "Circuit Design (Vending Machine)"
	desc = "Allows for the construction of circuit boards used to build a vending machines."
	id = "vendomat"
	req_tech = list(Tc_MATERIALS = 1, Tc_ENGINEERING = 1, Tc_POWERSTORAGE = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 3)
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

/datum/design/holopad
	name = "Circuit Design (Holopad)"
	desc = "Allows for the construction of circuit boards used to build holopads."
	id = "holopad"
	req_tech = list(Tc_MAGNETS = 2, Tc_PROGRAMMING = 2, Tc_BLUESPACE = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/holopad

/datum/design/ammolathe
	name = "Circuit Design (Ammolathe)"
	desc = "Allows for the construction of circuit boards used to build ammolathes."
	id = "ammolathe"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_ENGINEERING = 2, Tc_COMBAT = 4, Tc_NANOTRASEN = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/ammolathe

/datum/design/chem_dispenser/brewer
	name = "Circuit Design (Brewer)"
	desc = "Allows for the construction of circuit boards used to build a brewer."
	id = "brewer"
	build_path = /obj/item/weapon/circuitboard/chem_dispenser/brewer

/datum/design/chem_dispenser/soda_dispenser
	name = "Circuit Design (Soda Dispenser)"
	desc = "Allows for the construction of circuit boards used to build a soda dispenser."
	id = "soda_dispenser"
	build_path = /obj/item/weapon/circuitboard/chem_dispenser/soda_dispenser

/datum/design/chem_dispenser/booze_dispenser
	name = "Circuit Design (Booze Dispenser)"
	desc = "Allows for the construction of circuit boards used to build a booze dispenser."
	id = "booze_dispenser"
	build_path = /obj/item/weapon/circuitboard/chem_dispenser/booze_dispenser

