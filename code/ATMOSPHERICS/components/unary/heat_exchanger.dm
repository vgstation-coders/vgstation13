/obj/machinery/atmospherics/unary/heat_exchanger

	icon = 'icons/obj/atmospherics/heat_exchanger.dmi'
	icon_state = "main"
	density = 1

	name = "heat exchanger"
	desc = "Exchanges heat between two input gases. Setup for fast heat transfer"

	var/obj/machinery/atmospherics/unary/heat_exchanger/partner = null
	var/update_cycle

/obj/machinery/atmospherics/unary/heat_exchanger/initialize()
	if(!partner)
		var/partner_connect = turn(dir,180)

		for(var/obj/machinery/atmospherics/unary/heat_exchanger/target in get_step(src,partner_connect))
			if(target.dir & get_dir(src,target))
				partner = target
				partner.partner = src
				break

	..()

/obj/machinery/atmospherics/unary/heat_exchanger/process()
	. = ..()
	if(!partner || !air_master || air_master.current_cycle <= update_cycle)
		return

	update_cycle = air_master.current_cycle
	partner.update_cycle = air_master.current_cycle

	var/air_heat_capacity = air_contents.heat_capacity()
	var/other_air_heat_capacity = partner.air_contents.heat_capacity()
	var/combined_heat_capacity = other_air_heat_capacity + air_heat_capacity

	var/old_temperature = air_contents.temperature
	var/other_old_temperature = partner.air_contents.temperature

	if(combined_heat_capacity > 0)
		var/combined_energy = partner.air_contents.temperature*other_air_heat_capacity + air_heat_capacity*air_contents.temperature

		var/new_temperature = combined_energy/combined_heat_capacity
		air_contents.temperature = new_temperature
		partner.air_contents.temperature = new_temperature

	if(network)
		if(abs(old_temperature-air_contents.temperature) > 1)
			network.update = 1

	if(partner.network)
		if(abs(other_old_temperature-partner.air_contents.temperature) > 1)
			partner.network.update = 1

	return 1

/obj/machinery/atmospherics/unary/heat_exchanger/icon_node_con(var/dir)
	var/static/list/node_con = list(
		"[NORTH]" = image('icons/obj/atmospherics/heat_exchanger.dmi', "intact", dir = NORTH),
		"[SOUTH]" = image('icons/obj/atmospherics/heat_exchanger.dmi', "intact", dir = SOUTH),
		"[EAST]"  = image('icons/obj/atmospherics/heat_exchanger.dmi', "intact", dir = EAST),
		"[WEST]"  = image('icons/obj/atmospherics/heat_exchanger.dmi', "intact", dir = WEST)
	)

	return node_con["[dir]"]

/obj/machinery/atmospherics/unary/heat_exchanger/icon_node_ex(var/dir)
	var/static/list/node_ex = list(
		"[NORTH]" = image('icons/obj/atmospherics/heat_exchanger.dmi', "exposed", dir = NORTH),
		"[SOUTH]" = image('icons/obj/atmospherics/heat_exchanger.dmi', "exposed", dir = SOUTH),
		"[EAST]"  = image('icons/obj/atmospherics/heat_exchanger.dmi', "exposed", dir = EAST),
		"[WEST]"  = image('icons/obj/atmospherics/heat_exchanger.dmi', "exposed", dir = WEST)
	)

	return node_ex["[dir]"]

/obj/machinery/atmospherics/unary/heat_exchanger/hide(var/i)
	update_icon()
