
////////////////////////////////////////
// External Shield Generator

/obj/item/weapon/circuitboard/shield_gen_ex
	name = "Circuit board (Experimental hull shield generator)"
	board_type = MACHINE
	build_path = "/obj/machinery/shield_gen/external"
	origin_tech = Tc_BLUESPACE + "=4;" + Tc_PHORONTECH + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator/nano/pico" = 2,
							"/obj/item/weapon/stock_parts/subspace/transmitter" = 1,
							"/obj/item/weapon/stock_parts/subspace/crystal" = 1,
							"/obj/item/weapon/stock_parts/subspace/amplifier" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1,
							"/obj/item/stack/cable_coil" = 5)

////////////////////////////////////////
// Shield Generator

/obj/item/weapon/circuitboard/shield_gen
	name = "Circuit board (Experimental shield generator)"
	board_type = MACHINE
	build_path = "/obj/machinery/shield_gen/external"
	origin_tech = Tc_BLUESPACE + "=4;" + Tc_PHORONTECH + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator/nano/pico" = 2,
							"/obj/item/weapon/stock_parts/subspace/transmitter" = 1,
							"/obj/item/weapon/stock_parts/subspace/crystal" = 1,
							"/obj/item/weapon/stock_parts/subspace/amplifier" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1,
							"/obj/item/stack/cable_coil" = 5)

////////////////////////////////////////
// Shield Capacitor

/obj/item/weapon/circuitboard/shield_cap
	name = "Circuit board (Experimental shield capacitor)"
	board_type = MACHINE
	build_path = "/obj/machinery/shield_capacitor"
	origin_tech = Tc_MAGNETS + "=3;" + Tc_POWERSTORAGE + "=4"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator/nano/pico" = 2,
							"/obj/item/weapon/stock_parts/subspace/filter" = 1,
							"/obj/item/weapon/stock_parts/subspace/treatment" = 1,
							"/obj/item/weapon/stock_parts/subspace/analyzer" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1,
							"/obj/item/stack/cable_coil" = 5)
