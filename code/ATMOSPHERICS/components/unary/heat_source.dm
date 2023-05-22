/obj/machinery/atmospherics/unary/heat_reservoir
//currently the same code as cold_sink but anticipating process() changes

	icon = 'icons/obj/atmospherics/cold_sink.dmi'
	icon_state = "intact_off"
	density = 1
	use_power = MACHINE_POWER_USE_IDLE

	name = "Heat Reservoir"
	desc = "Heats gas when connected to pipe network."

	var/on = 0

	var/current_temperature = T20C
	var/current_heat_capacity = 50000 //totally random


/obj/machinery/atmospherics/unary/heat_reservoir/process()
	. = ..()
	if(!on)
		return
	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	var/old_temperature = air_contents.temperature

	if(combined_heat_capacity > 0)
		var/combined_energy = current_temperature*current_heat_capacity + air_heat_capacity*air_contents.temperature
		if(air_contents.temperature < current_temperature) //if its colder than we can heat it, heat it
			air_contents.temperature = combined_energy/combined_heat_capacity

	//todo: have current temperature affected. require power to bring up current temperature again

	if(abs(old_temperature-air_contents.temperature) > 0.1)
		network.update = 1
	return 1
