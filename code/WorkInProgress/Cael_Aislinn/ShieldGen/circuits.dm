
////////////////////////////////////////
// External Shield Generator

/obj/item/weapon/circuitboard/shield_gen_ex
	name = "Circuit board (Starscreen-EX external shield generator)"
	desc = "A circuit board used to run a Starscreen-EX external shield generator. There's a plate soldered just over one of the identifying chips."
	board_type = MACHINE
	build_path = /obj/machinery/shield_gen/external
	origin_tech = Tc_BLUESPACE + "=4;" + Tc_PLASMATECH + "=3"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/subspace/transmitter = 1,
							/obj/item/weapon/stock_parts/subspace/crystal = 1,
							/obj/item/weapon/stock_parts/subspace/amplifier = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/shield_gen_ex/solder_improve(var/mob/user)
	to_chat(user, "<span class='notice'>You set the shield generator circuit to project normal shields.</span>")
	new /obj/item/weapon/circuitboard/shield_gen(user.loc)
	qdel(src)

////////////////////////////////////////
// Shield Generator

/obj/item/weapon/circuitboard/shield_gen
	name = "Circuit board (Starscreen shield generator)"
	desc = "A circuit board used to run a Starscreen shield generator. There's a plate soldered just under one of the identifying chips."
	board_type = MACHINE
	build_path = /obj/machinery/shield_gen
	origin_tech = Tc_BLUESPACE + "=4;" + Tc_PLASMATECH + "=3"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/subspace/transmitter = 1,
							/obj/item/weapon/stock_parts/subspace/crystal = 1,
							/obj/item/weapon/stock_parts/subspace/amplifier = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/shield_gen/solder_improve(var/mob/user)
	to_chat(user, "<span class='notice'>You set the shield generator circuit to project external hull shields.</span>")
	new /obj/item/weapon/circuitboard/shield_gen_ex(user.loc)
	qdel(src)

////////////////////////////////////////
// Shield Capacitor

/obj/item/weapon/circuitboard/shield_cap
	name = "Circuit board (Starscreen shield capacitor)"
	desc = "A circuit board used to run a Starscreen shield capacitor."
	board_type = MACHINE
	build_path = /obj/machinery/shield_capacitor
	origin_tech = Tc_MAGNETS + "=3;" + Tc_POWERSTORAGE + "=4"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 2,
							/obj/item/weapon/stock_parts/subspace/filter = 1,
							/obj/item/weapon/stock_parts/subspace/treatment = 1,
							/obj/item/weapon/stock_parts/subspace/analyzer = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)
