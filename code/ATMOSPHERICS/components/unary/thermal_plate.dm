#define NO_GAS 0.01
#define SOME_GAS 1
#define ENERGY_MULT 6.4


/obj/machinery/atmospherics/unary/thermal_plate
//Based off Heat Reservoir and Space Heater
//Transfers heat between a pipe system and environment, based on which has a greater thermal energy concentration

	icon = 'icons/obj/atmospherics/cold_sink.dmi'
	icon_state = "off"
	level = 1
	var/radiation_capacity = 30000 //Radiation isn't particularly effective (TODO BALANCE)
	name = "Thermal Transfer Plate"
	desc = "Transfers heat to and from an area."

/obj/machinery/atmospherics/unary/thermal_plate/process()
	. = ..()

	var/datum/gas_mixture/environment = loc.return_air()

	//Get processable air sample and thermal info from environment

	var/environment_moles = environment.molar_density() * CELL_VOLUME

	if(environment_moles < NO_GAS)
		return radiate()
	else if(environment_moles < SOME_GAS)
		return 0

	//Get same info from connected gas

	var/datum/gas_mixture/internal_removed = air_contents.remove_ratio(0.25)

	if (!internal_removed)
		return

	var/datum/gas_mixture/external_removed = environment.remove(0.25 * environment_moles)

	var/combined_heat_capacity = internal_removed.heat_capacity() + external_removed.heat_capacity()
	var/combined_energy = internal_removed.thermal_energy() + external_removed.thermal_energy()

	if(!combined_heat_capacity)
		combined_heat_capacity = 1
	var/final_temperature = combined_energy / combined_heat_capacity

	external_removed.temperature = final_temperature
	environment.merge(external_removed)

	internal_removed.temperature = final_temperature
	air_contents.merge(internal_removed)

	network.update = 1

	return 1

/obj/machinery/atmospherics/unary/thermal_plate/hide(var/i) //to make the little pipe section invisible, the icon changes.
	var/prefix=""
	if(i == 1 && istype(loc, /turf/simulated))
		prefix="h"
	icon_state = "[prefix]off"
	update_icon()
	return ..()

/obj/machinery/atmospherics/unary/thermal_plate/proc/radiate()
	if(network && network.radiate) //Since each member of a network has the same gases each tick
		air_contents.copy_from(network.radiate) //We can cut down on processing time by only calculating radiate() once and then applying the result
		return

	var/datum/gas_mixture/internal_removed = air_contents.remove_ratio(0.25)

	if (!internal_removed)
		return

	var/combined_heat_capacity = internal_removed.heat_capacity() + radiation_capacity
	var/combined_energy = internal_removed.thermal_energy() + (radiation_capacity * ENERGY_MULT)

	var/final_temperature = combined_energy / combined_heat_capacity

	internal_removed.temperature = final_temperature
	air_contents.merge(internal_removed)

	if (network)
		network.update = 1
		network.radiate = air_contents

	return 1

/obj/machinery/atmospherics/unary/thermal_plate/hide(var/i) //to make the little pipe section invisible, the icon changes.
	update_icon()

#undef NO_GAS
#undef SOME_GAS
#undef ENERGY_MULT
