/obj/item/weapon/circuitboard/trade
	name = "Circuit board (Trade Console)"
	desc = "A circuit board for running a computer used for long-range communication with Shoal traders."
	build_path = /obj/machinery/computer/trade
	origin_tech = Tc_PROGRAMMING + "=4"

/datum/design/trade
	name = "Circuit Design (Trade Console)"
	desc = "Allows for the construction of circuit boards used to build a trade console."
	id = "tradeconsole"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_ENGINEERING = 3, Tc_BLUESPACE = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, SACID = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/trade