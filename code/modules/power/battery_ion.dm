// Generic battery machine
// stores power

/obj/machinery/power/battery/portable
	name = "portable power storage unit"
	desc = "A Ion-model portable storage unit, used to transport charge around the station."
	icon_state = "port_smes"
	density = 1
	anchored = 0
	use_power = 0

	capacity = 3e6

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE

	var/obj/machinery/power/battery_port/connected_to

/obj/machinery/power/battery/portable/New()
	..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/port_smes,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/power/battery/portable/Destroy()
	if(connected_to)
		connected_to.disconnect_battery()
	..()

/obj/machinery/power/battery/portable/initialize()
	..()
	if(anchored)
		var/obj/machinery/power/battery_port/port = locate() in src.loc
		if(port)
			port.connect_battery(src)

/obj/machinery/power/battery/portable/get_powernet()
	if(connected_to)
		return connected_to.get_powernet()

/obj/machinery/power/battery/portable/add_avail(var/amount)
	if(connected_to)
		connected_to.add_avail(amount)

/obj/machinery/power/battery/portable/add_load(var/amount)
	if(connected_to)
		connected_to.add_load(amount)

/obj/machinery/power/battery/portable/excess()
	if(connected_to)
		return connected_to.excess()
	return 0

/obj/machinery/power/battery/portable/wrenchAnchor(var/mob/user)
	. = ..()
	if(!.)
		return
	if(anchored)
		var/obj/machinery/power/battery_port/port = locate() in src.loc
		if(port)
			port.connect_battery(src)
	else
		if(connected_to)
			connected_to.disconnect_battery()

/obj/machinery/power/battery/portable/update_icon()
	if(stat & BROKEN)
		return

	..()

	if(connected_to)
		connected_to.update_icon()
	return

/obj/machinery/power/battery/portable/power_change()
	. = ..()
	if (stat & BROKEN)
		return

	update_icon()
		

/obj/machinery/power/battery/portable/get_terminal()
	if(connected_to)
		return connected_to.terminal
	return null
