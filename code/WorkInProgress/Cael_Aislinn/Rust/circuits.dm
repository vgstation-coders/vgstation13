//////////////////////////////////////
// RUST Core Control computer

/obj/item/weapon/circuitboard/rust_core_control
	name = "Circuit board (R-UST Mk. 7 core controller)"
	desc = "A circuit board used to run the core controller computer of a R-UST Mk. 7 engine."
	build_path = /obj/machinery/computer/rust_core_control
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_ENGINEERING + "=4"

//////////////////////////////////////
// RUST Core Monitor computer

/obj/item/weapon/circuitboard/rust_core_monitor
	name = "Circuit board (R-UST Mk. 7 core monitor)"
	desc = "A circuit board used to run the core monitoring computer of a R-UST Mk. 7 engine."
	build_path = /obj/machinery/computer/rust_core_monitor
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_ENGINEERING + "=4"

//////////////////////////////////////
// RUST Fuel Control computer

/obj/item/weapon/circuitboard/rust_fuel_control
	name = "Circuit board (R-UST Mk. 7 fuel controller)"
	desc = "A circuit board used to run the fuel injection computer of a R-UST Mk. 7 engine."
	build_path = /obj/machinery/computer/rust_fuel_control
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_ENGINEERING + "=4"

//////////////////////////////////////
// RUST Fuel Port board

/obj/item/weapon/module/rust_fuel_port
	name = "Internal circuitry (R-UST Mk. 7 fuel port)"
	desc = "A circuit board used to run the wall-mounted fuel port for a R-UST Mk. 7 engine."
	icon_state = "card_mod"
	origin_tech = Tc_ENGINEERING + "=4;" + Tc_MATERIALS + "=5"

//////////////////////////////////////
// RUST Fuel Compressor board

/obj/item/weapon/module/rust_fuel_compressor
	name = "Internal circuitry (R-UST Mk. 7 fuel compressor)"
	desc = "A circuit board used to run the wall-mounted fuel rod assembler of a R-UST Mk. 7 engine."
	icon_state = "card_mod"
	origin_tech = Tc_MATERIALS + "=6;" + Tc_PLASMATECH + "=4"

//////////////////////////////////////
// RUST Tokamak Core board

/obj/item/weapon/circuitboard/rust_core
	name = "Internal circuitry (R-UST Mk. 7 tokamak core)"
	desc = "A circuit board used to run the core machine of a R-UST Mk. 7 engine."
	build_path = /obj/machinery/power/rust_core
	board_type = MACHINE
	origin_tech = Tc_BLUESPACE + "=3;" + Tc_PLASMATECH + "=4;" + Tc_MAGNETS + "=5;" + Tc_POWERSTORAGE + "=6"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator/nano/pico = 2,
							/obj/item/weapon/stock_parts/micro_laser/high/ultra = 1,
							/obj/item/weapon/stock_parts/subspace/crystal = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

//////////////////////////////////////
// RUST Fuel Injector board

/obj/item/weapon/circuitboard/rust_injector
	name = "Internal circuitry (R-UST Mk. 7 fuel injector)"
	desc = "A circuit board used to run the fuel injection machine of a R-UST Mk. 7 engine."
	build_path = /obj/machinery/power/rust_fuel_injector
	board_type = MACHINE
	origin_tech = Tc_POWERSTORAGE + "=3;" + Tc_ENGINEERING + "=4;" + Tc_PLASMATECH + "=4;" + Tc_MATERIALS + "=6"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator/nano/pico = 2,
							/obj/item/weapon/stock_parts/scanning_module/adv/phasic = 1,
							/obj/item/weapon/stock_parts/matter_bin/adv/super = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

//Gyrotron controller board.
/obj/item/weapon/circuitboard/rust_gyrotron_control
	name = "Circuit board (R-UST Mk. 7 gyrotron controller)"
	desc = "A circuit board used to run the gyrotron controller computer of a R-UST Mk. 7 engine."
	build_path = /obj/machinery/computer/rust_gyrotron_controller
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_ENGINEERING + "=4"
