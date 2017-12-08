#define SPECIFIC_HEAT_TOXIN		200
#define SPECIFIC_HEAT_AIR		20
#define SPECIFIC_HEAT_CDO		30
#define HEAT_CAPACITY_CALCULATION(oxygen,carbon_dioxide,nitrogen,toxins) \
	max(0, carbon_dioxide * SPECIFIC_HEAT_CDO + (oxygen + nitrogen) * SPECIFIC_HEAT_AIR + toxins * SPECIFIC_HEAT_TOXIN)

#define MINIMUM_HEAT_CAPACITY	0.0003
#define TRANSFER_FRACTION 5 //What fraction (1/#) of the air difference to try and transfer

// /vg/ SHIT
#define TEMPERATURE_ICE_FORMATION 273.15 // 273 kelvin is the freezing point of water.
#define MIN_PRESSURE_ICE_FORMATION 10    // 10kPa should be okay

#define GRAPHICS_PLASMA   1
#define GRAPHICS_N2O      2
#define GRAPHICS_REAGENTS 4 //Not used. Yet.
#define GRAPHICS_COLD     8
// END /vg/SHIT

/hook/startup/proc/createGasOverlays()
	plmaster = new /obj/effect/overlay()
	plmaster.icon = 'icons/effects/tile_effects.dmi'
	plmaster.icon_state = "plasma"
	plmaster.layer = FLY_LAYER
	plmaster.plane = EFFECTS_PLANE
	plmaster.mouse_opacity = 0

	slmaster = new /obj/effect/overlay()
	slmaster.icon = 'icons/effects/tile_effects.dmi'
	slmaster.icon_state = "sleeping_agent"
	slmaster.layer = FLY_LAYER
	slmaster.plane = EFFECTS_PLANE
	slmaster.mouse_opacity = 0
	return 1

/datum/gas/sleeping_agent/specific_heat = 40 //These are used for the "Trace Gases" stuff, but is buggy.

/datum/gas/oxygen_agent_b/specific_heat = 300

/datum/gas/volatile_fuel/specific_heat = 30

/datum/gas
	var/moles = 0

	var/specific_heat = 0

/datum/gas_mixture
	var/oxygen = 0		//Holds the "moles" of each of the four gases.
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/toxins = 0

	var/total_moles = 0	//Updated when a reaction occurs.

	var/volume = CELL_VOLUME

	var/temperature = 0 //in Kelvin, use calculate_temperature() to modify

	var/graphics=0

	var/pressure=0

	var/list/datum/gas/trace_gases = list() //Seemed to be a good idea that was abandoned

	var/tmp/fuel_burnt = 0

/datum/gas_mixture/New(datum/gas_mixture/to_copy)
	..()
	if(istype(to_copy))
		volume = to_copy.volume
		copy_from(to_copy)

//Turns out that most of the time, people only want to adjust a single gas at a time, and using a proc set up like this just encourages bad behavior.
//To be purged along with the trace gas system later.
/datum/gas_mixture/proc/adjust(o2 = 0, co2 = 0, n2 = 0, tx = 0, list/datum/gas/traces = list())
	//Purpose: Adjusting the gases within a airmix
	//Called by: Fucking everything!
	//Inputs: The values of the gases to adjust
	//Outputs: null

	oxygen = max(0, oxygen + o2)
	carbon_dioxide = max(0, carbon_dioxide + co2)
	nitrogen = max(0, nitrogen + n2)
	toxins = max(0, toxins + tx)

	//handle trace gasses
	for(var/datum/gas/G in traces)
		var/datum/gas/T = locate(G.type) in trace_gases
		if(T)
			T.moles = max(G.moles + T.moles, 0)
		else if(G.moles > 0)
			trace_gases |= G
	update_values()
	return


//Takes a gas string, and the number of moles to adjust by. Calls update_values() if update isn't 0.
/datum/gas_mixture/proc/adjust_gas(gasid, moles, update = TRUE)
	if(!moles)
		return
	switch(gasid)
		if("oxygen")
			oxygen += moles
		if("plasma")
			toxins += moles
		if("carbon_dioxide")
			carbon_dioxide += moles
		if("nitrogen")
			nitrogen += moles
		else
			CRASH("Invalid gasid!")

	if(update)
		update_values()


//Same as adjust_gas(), but takes a temperature which is mixed in with the gas.
/datum/gas_mixture/proc/adjust_gas_temp(gasid, moles, temp, update = TRUE)
	if(moles > 0 && abs(temperature - temp) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity()

		var/giver_heat_capacity = moles
		switch(gasid)
			if("oxygen", "nitrogen")
				giver_heat_capacity *= SPECIFIC_HEAT_AIR
			if("plasma")
				giver_heat_capacity *= SPECIFIC_HEAT_TOXIN
			if("carbon_dioxide")
				giver_heat_capacity *= SPECIFIC_HEAT_CDO
			else
				CRASH("Invalid gasid!")

		var/combined_heat_capacity = giver_heat_capacity + self_heat_capacity
		temperature = (temp * giver_heat_capacity + temperature * self_heat_capacity) / combined_heat_capacity

	adjust_gas(gasid, moles, update)


//Variadic version of adjust_gas(). Takes any number of gas and mole pairs and applies them.
/datum/gas_mixture/proc/adjust_multi()
	ASSERT(!(args.len % 2))

	for(var/i = 1; i < args.len; i += 2)
		adjust_gas(args[i], args[i + 1], update = FALSE)

	update_values()


//Variadic version of adjust_gas_temp(). Takes any number of gas, mole and temperature associations and applies them.
//This proc is evil. Temperature will not behave how you expect it to. You have been warned.
/datum/gas_mixture/proc/adjust_multi_temp()
	ASSERT(!(args.len % 3))

	for(var/i = 1; i < args.len; i += 3)
		adjust_gas_temp(args[i], args[i + 1], args[i + 2], update = FALSE)

	update_values()


//Merges all the gas from another mixture into this one. Adjusts temperature correctly.
//Does not modify giver in any way.
/datum/gas_mixture/proc/merge(datum/gas_mixture/giver)
	if(!giver)
		return 0

	var/self_heat_capacity = heat_capacity()
	var/giver_heat_capacity = giver.heat_capacity()

	temperature = (temperature * self_heat_capacity + giver.temperature * giver_heat_capacity) / (self_heat_capacity + giver_heat_capacity)
	adjust_multi(\
		"oxygen", giver.oxygen,\
		"nitrogen", giver.nitrogen,\
		"plasma", giver.toxins,\
		"carbon_dioxide", giver.carbon_dioxide)

	if(giver.trace_gases.len) //This really should use adjust(), but I think it would break things, and I don't care enough to fix a system I'm removing soon anyway.
		for(var/datum/gas/trace_gas in giver.trace_gases)
			var/datum/gas/corresponding = locate(trace_gas.type) in trace_gases
			if(!corresponding)
				corresponding = new trace_gas.type()
				trace_gases += corresponding
			corresponding.moles += trace_gas.moles
		update_values()

	return 1


//Equalizes this mixture's gases with another's, changing both mixtures. Essentially, fully mixes the two, but keeps them separate.
//Modifies sharer as well as src. (I'll laugh if someone poorly regexes out src. and this comment becomes incomprehensible)
/datum/gas_mixture/proc/equalize(datum/gas_mixture/sharer)
	merge(sharer)
	sharer.multiply(0) //Empty it out.
	sharer.merge(remove_ratio(sharer.volume / (volume + sharer.volume)))
	return 1


/datum/gas_mixture/proc/return_temperature()
	return temperature


/datum/gas_mixture/proc/return_volume()
	return max(0, volume)


/datum/gas_mixture/proc/thermal_energy()
	return temperature*heat_capacity()

///////////////////////////////
//PV=nRT - related procedures//
///////////////////////////////

/datum/gas_mixture/proc/heat_capacity()
	//Purpose: Returning the heat capacity of the gas mix
	//Called by: UNKNOWN
	//Inputs: None
	//Outputs: Heat capacity

	var/heat_capacity = HEAT_CAPACITY_CALCULATION(oxygen,carbon_dioxide,nitrogen,toxins)

	if(trace_gases && trace_gases.len) //sanity check because somehow the tracegases gets nulled?
		for(var/datum/gas/trace_gas in trace_gases)
			heat_capacity += trace_gas.moles*trace_gas.specific_heat

	return max(MINIMUM_HEAT_CAPACITY,heat_capacity)


//Adds or removes thermal energy. Returns the actual thermal energy change, as in the case of removing energy we can't go below TCMB.
/datum/gas_mixture/proc/add_thermal_energy(var/thermal_energy)
	if (total_moles == 0)
		return 0

	var/heat_capacity = heat_capacity()
	if (thermal_energy < 0)
		if (temperature < TCMB)
			return 0
		var/thermal_energy_limit = -(temperature - TCMB)*heat_capacity	//ensure temperature does not go below TCMB
		thermal_energy = max( thermal_energy, thermal_energy_limit )	//thermal_energy and thermal_energy_limit are negative here.
	temperature += thermal_energy/heat_capacity
	return thermal_energy


//Returns the thermal energy change required to get to a new temperature
/datum/gas_mixture/proc/get_thermal_energy_change(var/new_temperature)
	return heat_capacity()*(max(new_temperature, 0) - temperature)


//The below wasn't even implemented yet in the big XGM PR. Just saving it here for later.

////Technically vacuum doesn't have a specific entropy. Just use a really big number (infinity would be ideal) here so that it's easy to add gas to vacuum and hard to take gas out.
//#define SPECIFIC_ENTROPY_VACUUM		150000
//
//
////Returns the ideal gas specific entropy of the whole mix. This is the entropy per mole of /mixed/ gas.
///datum/gas_mixture/proc/specific_entropy()
//	if (!gas.len || total_moles == 0)
//		return SPECIFIC_ENTROPY_VACUUM
//
//	. = 0
//	for(var/g in gas)
//		. += gas[g] * specific_entropy_gas(g)
//	. /= total_moles
//
//
///*
//	It's arguable whether this should even be called entropy anymore. It's more "based on" entropy than actually entropy now.
//	Returns the ideal gas specific entropy of a specific gas in the mix. This is the entropy due to that gas per mole of /that/ gas in the mixture, not the entropy due to that gas per mole of gas mixture.
//	For the purposes of SS13, the specific entropy is just a number that tells you how hard it is to move gas. You can replace this with whatever you want.
//	Just remember that returning a SMALL number == adding gas to this gas mix is HARD, taking gas away is EASY, and that returning a LARGE number means the opposite (so a vacuum should approach infinity).
//	So returning a constant/(partial pressure) would probably do what most players expect. Although the version I have implemented below is a bit more nuanced than simply 1/P in that it scales in a way
//	which is bit more realistic (natural log), and returns a fairly accurate entropy around room temperatures and pressures.
//*/
///datum/gas_mixture/proc/specific_entropy_gas(var/gasid)
//	if (!(gasid in gas) || gas[gasid] == 0)
//		return SPECIFIC_ENTROPY_VACUUM	//that gas isn't here
//
//	//V/(m*T) = R/(partial pressure)
//	var/molar_mass = XGM.molar_mass[gasid]
//	var/specific_heat = XGM.specific_heat[gasid]
//	return R_IDEAL_GAS_EQUATION * ( log( (IDEAL_GAS_ENTROPY_CONSTANT*volume/(gas[gasid] * temperature)) * (molar_mass*specific_heat*temperature)**(2/3) + 1 ) +  15 )
//
//	//alternative, simpler equation
//	//var/partial_pressure = gas[gasid] * R_IDEAL_GAS_EQUATION * temperature / volume
//	//return R_IDEAL_GAS_EQUATION * ( log (1 + IDEAL_GAS_ENTROPY_CONSTANT/partial_pressure) + 20 )


/datum/gas_mixture/proc/update_values()
	//Purpose: Calculating and storing values which were normally called CONSTANTLY
	//Called by: Anything that changes values within a gas mix.
	//Inputs: None
	//Outputs: None

	total_moles = oxygen + carbon_dioxide + nitrogen + toxins

	if(trace_gases.len)
		for(var/datum/gas/trace_gas in trace_gases)
			total_moles += trace_gas.moles

	if(volume>0)
		pressure = total_moles()*R_IDEAL_GAS_EQUATION*temperature/volume
	else
		pressure = 0

	return


/datum/gas_mixture/proc/total_moles()
	return total_moles


/datum/gas_mixture/proc/return_pressure()
	//Purpose: Calculating Current Pressure
	//Called by:
	//Inputs: None
	//Outputs: Gas pressure.
	return pressure


/datum/gas_mixture/proc/remove(amount)
	//Purpose: Removes a certain number of moles from the air.
	//Called by: ?
	//Inputs: How many moles to remove.
	//Outputs: Removed air.

	var/sum = total_moles()
	amount = min(amount,sum) //Can not take more air than tile has!
	if(amount <= 0)
		return null

	var/datum/gas_mixture/removed = new


	removed.oxygen = QUANTIZE((oxygen/sum)*amount)
	removed.nitrogen = QUANTIZE((nitrogen/sum)*amount)
	removed.carbon_dioxide = QUANTIZE((carbon_dioxide/sum)*amount)
	removed.toxins = QUANTIZE((toxins/sum)*amount)

	oxygen -= removed.oxygen
	nitrogen -= removed.nitrogen
	carbon_dioxide -= removed.carbon_dioxide
	toxins -= removed.toxins

	if(trace_gases.len)
		for(var/datum/gas/trace_gas in trace_gases)
			var/datum/gas/corresponding = new trace_gas.type()
			removed.trace_gases += corresponding

			corresponding.moles = (trace_gas.moles/sum)*amount
			trace_gas.moles -= corresponding.moles
/*
	if(aerosols.total_volume > 1)
		removed.aerosols.trans_to_atmos(src,(aerosols.total_volume/sum)*amount)
*/

	removed.temperature = temperature
	update_values()
	removed.update_values()

	return removed


/datum/gas_mixture/proc/remove_ratio(ratio)
	//Purpose: Removes a certain ratio of the air.
	//Called by: ?
	//Inputs: Percentage to remove.
	//Outputs: Removed air.

	if(ratio <= 0)
		return null

	ratio = min(ratio, 1)

	var/datum/gas_mixture/removed = new

	removed.oxygen = QUANTIZE(oxygen*ratio)
	removed.nitrogen = QUANTIZE(nitrogen*ratio)
	removed.carbon_dioxide = QUANTIZE(carbon_dioxide*ratio)
	removed.toxins = QUANTIZE(toxins*ratio)

	oxygen -= removed.oxygen
	nitrogen -= removed.nitrogen
	carbon_dioxide -= removed.carbon_dioxide
	toxins -= removed.toxins

	if(trace_gases.len)
		for(var/datum/gas/trace_gas in trace_gases)
			var/datum/gas/corresponding = new trace_gas.type()
			removed.trace_gases += corresponding

			corresponding.moles = trace_gas.moles*ratio
			trace_gas.moles -= corresponding.moles

	removed.temperature = temperature
	update_values()
	removed.update_values()

	return removed


//Removes a volume of gas from the mixture and returns a gas_mixture containing the removed air with the given volume.
/datum/gas_mixture/proc/remove_volume(removed_volume)
	var/datum/gas_mixture/removed = remove_ratio(removed_volume/volume)
	removed.volume = removed_volume
	removed.update_values()
	return removed


////////////////////////////////////////////
//Procedures used for very specific events//
////////////////////////////////////////////

/datum/gas_mixture/proc/check_tile_graphic()
	//Purpose: Calculating the graphic for a tile
	//Called by: Turfs updating
	//Inputs: None
	//Outputs: 1 if graphic changed, 0 if unchanged

	var/old_graphics = graphics

	graphics = 0

	// If configured and cold, maek ice
	if(zas_settings.Get(/datum/ZAS_Setting/ice_formation))
		if(temperature <= TEMPERATURE_ICE_FORMATION && return_pressure()>MIN_PRESSURE_ICE_FORMATION)
			// If we're just forming, do a probability check. Otherwise, KEEP IT ON~
			// This ordering will hopefully keep it from sampling random noise every damn tick.
			//if(was_icy || (!was_icy && prob(25)))
			graphics |= GRAPHICS_COLD

	if((toxins / volume * CELL_VOLUME) > MOLES_PLASMA_VISIBLE)
		graphics |= GRAPHICS_PLASMA

	if(length(trace_gases))
		var/datum/gas/sleeping_agent = locate(/datum/gas/sleeping_agent) in trace_gases
		if(sleeping_agent && ((sleeping_agent.moles / volume * CELL_VOLUME) > 1))
			graphics |= GRAPHICS_N2O
/*
	if(aerosols && aerosols.total_volume >= 1)
		graphics |= GRAPHICS_REAGENTS
*/

	return graphics != old_graphics

/datum/gas_mixture/proc/react(atom/dump_location)
	//Purpose: Calculating if it is possible for a fire to occur in the airmix
	//Called by: Air mixes updating?
	//Inputs: None
	//Outputs: If a fire occured

	 //set to 1 if a notable reaction occured (used by pipe_network)

	return zburn(null) // ? (was: return reacting)


//////////////////////////////////////////////
//Procs for general gas spread calculations.//
//////////////////////////////////////////////


/datum/gas_mixture/proc/copy_from(datum/gas_mixture/sample)
	//Purpose: Copies the per unit volume properties of sample.
	//Called by: airgroups splitting, ?
	//Inputs: Gas to copy
	//Outputs: 1

	oxygen = sample.oxygen
	carbon_dioxide = sample.carbon_dioxide
	nitrogen = sample.nitrogen
	toxins = sample.toxins

	temperature = sample.temperature

	trace_gases.len = 0
	if(sample.trace_gases.len > 0)
		for(var/datum/gas/trace_gas in sample.trace_gases)
			var/datum/gas/corresponding = new trace_gas.type()
			trace_gases += corresponding

			corresponding.moles = trace_gas.moles

	multiply(volume / sample.volume)
	return 1

//The general form of the calculation used in compare() to check if two numbers are separated by at least a given abslute value AND relative value.
//Not guaranteed to produce the same result if the order of the vars to check is switched, but since its purpose is approximation anyway, it should be fine.
#define FAIL_SIMILARITY_CHECK(ownvar, samplevar, absolute, relative) (abs((ownvar) - (samplevar)) > (absolute) && \
	(((ownvar) < (1 - (relative)) * (samplevar)) || ((ownvar) > (1 + (relative)) * (samplevar))))

//The above except for gases specifically.
#define FAIL_AIR_SIMILARITY_CHECK(ownvar, samplevar) (FAIL_SIMILARITY_CHECK((ownvar), (samplevar), MINIMUM_AIR_TO_SUSPEND, MINIMUM_AIR_RATIO_TO_SUSPEND))

/datum/gas_mixture/proc/compare(datum/gas_mixture/sample)
	//Purpose: Compares sample to self to see if within acceptable ranges that group processing may be enabled
	//Called by: Airgroups trying to rebuild
	//Inputs: Gas mix to compare
	//Outputs: 1 if can rebuild, 0 if not.
	if(!istype(sample))
		return 0

	if(FAIL_SIMILARITY_CHECK(temperature, sample.temperature, MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND, MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND))
		return 0
	if(FAIL_SIMILARITY_CHECK(pressure, sample.pressure, MINIMUM_PRESSURE_DELTA_TO_SUSPEND, MINIMUM_PRESSURE_RATIO_TO_SUSPEND))
		return 0

	var/volume_ratio = volume / sample.volume //We want to compare the number of moles per unit volume, not total.

	if(FAIL_AIR_SIMILARITY_CHECK(oxygen, sample.oxygen * volume_ratio))
		return 0
	if(FAIL_AIR_SIMILARITY_CHECK(nitrogen, sample.nitrogen * volume_ratio))
		return 0
	if(FAIL_AIR_SIMILARITY_CHECK(carbon_dioxide, sample.carbon_dioxide * volume_ratio))
		return 0
	if(FAIL_AIR_SIMILARITY_CHECK(toxins, sample.toxins * volume_ratio))
		return 0

	var/check_moles
	if(sample.trace_gases.len)
		for(var/datum/gas/trace_gas in sample.trace_gases)
			var/datum/gas/corresponding = locate(trace_gas.type) in trace_gases
			if(corresponding)
				check_moles = corresponding.moles / volume_ratio
			else
				check_moles = 0

			if(FAIL_AIR_SIMILARITY_CHECK(check_moles, trace_gas.moles))
				return 0

	if(trace_gases.len)
		for(var/datum/gas/trace_gas in trace_gases)
			var/datum/gas/corresponding = locate(trace_gas.type) in sample.trace_gases
			if(corresponding)
				check_moles = corresponding.moles * volume_ratio
			else
				check_moles = 0

			if(FAIL_AIR_SIMILARITY_CHECK(trace_gas.moles, check_moles))
				return 0

	return 1

#undef FAIL_AIR_SIMILARITY_CHECK
#undef FAIL_SIMILARITY_CHECK

/datum/gas_mixture/proc/add(datum/gas_mixture/right_side)
	if(!right_side)
		return 0
	oxygen += right_side.oxygen
	carbon_dioxide += right_side.carbon_dioxide
	nitrogen += right_side.nitrogen
	toxins += right_side.toxins

	if(trace_gases.len || right_side.trace_gases.len)
		for(var/datum/gas/trace_gas in right_side.trace_gases)
			var/datum/gas/corresponding = locate(trace_gas.type) in trace_gases
			if(!corresponding)
				corresponding = new trace_gas.type()
				trace_gases += corresponding
			corresponding.moles += trace_gas.moles

	update_values()
	return 1

/datum/gas_mixture/proc/subtract(datum/gas_mixture/right_side)
	//Purpose: Subtracts right_side from air_mixture. Used to help turfs mingle
	//Called by: Pipelines ending in a break (or something)
	//Inputs: Gas mix to remove
	//Outputs: 1

	oxygen = max(0, oxygen - right_side.oxygen)
	carbon_dioxide = max(0, carbon_dioxide - right_side.carbon_dioxide)
	nitrogen = max(0, nitrogen - right_side.nitrogen)
	toxins = max(0, toxins - right_side.toxins)

	if(trace_gases.len || right_side.trace_gases.len)
		for(var/datum/gas/trace_gas in right_side.trace_gases)
			var/datum/gas/corresponding = locate(trace_gas.type) in trace_gases
			if(corresponding)
				corresponding.moles = max(0, corresponding.moles - trace_gas.moles)

	update_values()
	return 1

/datum/gas_mixture/proc/multiply(factor)
	oxygen *= factor
	carbon_dioxide *= factor
	nitrogen *= factor
	toxins *= factor

	if(trace_gases && trace_gases.len)
		for(var/datum/gas/trace_gas in trace_gases)
			trace_gas.moles *= factor

	update_values()
	return 1

/datum/gas_mixture/proc/divide(factor)
	oxygen /= factor
	carbon_dioxide /= factor
	nitrogen /= factor
	toxins /= factor

	if(trace_gases && trace_gases.len)
		for(var/datum/gas/trace_gas in trace_gases)
			trace_gas.moles /= factor

	update_values()
	return 1


//Mixes the given ratio of the two gas_mixtures.
//Ratio should always be between 0 and 1, of course.
//The exact values 0 and 1 won't break, but are useless, as they are respectively equivalent to doing nothing and using equalize().
/datum/gas_mixture/proc/share_ratio(datum/gas_mixture/other, ratio)
	var/total_volume = volume + other.volume

	var/datum/gas_mixture/holder = remove_ratio(ratio * other.volume / total_volume)
	merge(other.remove_ratio(ratio * volume / total_volume))
	other.merge(holder)


//Each value in this list corresponds to the proportion of gas shared between the gas_mixtures in share_tiles() when connecting_tiles is equal to its index.
//(If connecting_tiles is greater than 6, it still uses the sixth one.)
var/static/list/sharing_lookup_table = list(0.30, 0.40, 0.48, 0.54, 0.60, 0.66)

//Shares gas with another gas_mixture based on the number of connecting tiles and the above fixed lookup table.
/datum/gas_mixture/proc/share_tiles(datum/gas_mixture/other, connecting_tiles)
	var/ratio = sharing_lookup_table[min(connecting_tiles, sharing_lookup_table.len)] //6 or more interconnecting tiles will max at 66% of air moved per tick.
	share_ratio(other, ratio)
	return compare(other)

/datum/gas_mixture/proc/share_space(datum/gas_mixture/unsim_air, connecting_tiles)
	unsim_air = new(unsim_air) //First, copy unsim_air so it doesn't get changed.
	unsim_air.volume += volume + 3 * CELL_VOLUME //Then increase the copy's volume so larger rooms don't drain slowly as fuck.
		//Why add the 3 * CELL_VOLUME, you ask? To mirror the old behavior. Why did the old behavior add three tiles to the total? I have no idea.
	return share_tiles(unsim_air, connecting_tiles)

/datum/gas_mixture/proc/english_contents_list()
	var/all_contents = list()
	if(oxygen)
		all_contents += "Oxygen"
	if(nitrogen)
		all_contents += "Nitrogen"
	if(carbon_dioxide)
		all_contents += "CO<sub>2</sub>"
	if(toxins)
		all_contents += "Plasma"
	if(locate(/datum/gas/sleeping_agent) in trace_gases)
		all_contents += "N<sub>2</sub>O"
	return english_list(all_contents)

/datum/gas_mixture/proc/loggable_contents()
	var/naughty_stuff = list()
	if(toxins)
		naughty_stuff += "<b><font color='red'>Plasma</font></b>"
	if(carbon_dioxide)
		naughty_stuff += "<b><font color='red'>CO<sub>2</sub></font></b>"
	if(locate(/datum/gas/sleeping_agent) in trace_gases)
		naughty_stuff += "<b><font color='red'>N<sub>2</sub>O</font>"
	return english_list(naughty_stuff, nothing_text = "")
