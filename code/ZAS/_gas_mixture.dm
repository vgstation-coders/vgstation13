#define MINIMUM_HEAT_CAPACITY	0.0003
#define TRANSFER_FRACTION 5 //What fraction (1/#) of the air difference to try and transfer

// /vg/ SHIT
#define TEMPERATURE_ICE_FORMATION 273.15 // 273 kelvin is the freezing point of water.
#define MIN_PRESSURE_ICE_FORMATION 10    // 10kPa should be okay
// END /vg/SHIT

/datum/gas_mixture
	//Associative list of gas moles.
	//Gases with 0 moles are not tracked and are pruned by update_values()
	var/list/gas = list()

	var/total_moles = 0	//Updated when a reaction occurs.

	var/volume = CELL_VOLUME

	var/temperature = 0 //in Kelvin

	//List of active tile overlays for this gas_mixture.  Updated by check_tile_graphic()
	var/list/graphic = list()

	var/pressure = 0

	var/tmp/fuel_burnt = 0

/datum/gas_mixture/New(datum/gas_mixture/to_copy)
	..()
	if(istype(to_copy))
		volume = to_copy.volume
		copy_from(to_copy)


//Since gases not present in the mix are culled from the list, we use this to make sure a number is returned for any valid gas.
/datum/gas_mixture/proc/operator[](idx)
	return gas[idx] || (XGM.gases[idx] ? 0 : null)

//This just allows the [] operator to be used for writes as well as reads. The above proc means this WILL work with +=, etc., for any valid gas.
/datum/gas_mixture/proc/operator[]=(idx, val)
	gas[idx] = val


//Takes a gas string, and the number of moles to adjust by. Calls update_values() if update isn't 0.
/datum/gas_mixture/proc/adjust_gas(gasid, moles, update = TRUE)
	if(!moles)
		return

	src[gasid] += moles

	if(update)
		update_values()


//Same as adjust_gas(), but takes a temperature which is mixed in with the gas.
/datum/gas_mixture/proc/adjust_gas_temp(gasid, moles, temp, update = TRUE)
	if(moles > 0 && abs(temperature - temp) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity()
		var/giver_heat_capacity = XGM.specific_heat[gasid] * moles
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
//This proc is evil. Temperature will not behave how you expect it to unless this mixture starts off empty.
//Honestly, just make a new gas_mixture and merge it into this one instead.
/datum/gas_mixture/proc/adjust_multi_temp()
	ASSERT(!(args.len % 3))

	for(var/i = 1; i < args.len; i += 3)
		adjust_gas_temp(args[i], args[i + 1], args[i + 2], update = FALSE)

	update_values()


//Merges all the gas from another mixture into this one. Adjusts temperature correctly.
//Does not modify giver in any way.
/datum/gas_mixture/proc/merge(datum/gas_mixture/giver, update = TRUE)
	if(!giver)
		return 0

	var/self_heat_capacity = heat_capacity()
	var/giver_heat_capacity = giver.heat_capacity()
	temperature = (temperature * self_heat_capacity + giver.temperature * giver_heat_capacity) / (self_heat_capacity + giver_heat_capacity)

	for(var/g in giver.gas)
		adjust_gas(g, giver.gas[g], FALSE)

	if(update)
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
	return temperature * heat_capacity()


/datum/gas_mixture/proc/molar_density(g) //Per liter. You should probably be using pressure instead, but considering this had to be made, you wouldn't be the first not to.
	return (g ? src[g] : total_moles) / volume


/datum/gas_mixture/proc/partial_pressure(g)
	return total_moles && (src[g] / total_moles * pressure) //&& short circuits if total_moles is 0, and returns the second expression if it is not.

///////////////////////////////
//PV=nRT - related procedures//
///////////////////////////////

/datum/gas_mixture/proc/heat_capacity()
	var/heat_capacity = 0

	for(var/g in gas)
		heat_capacity += XGM.specific_heat[g] * gas[g]

	return max(MINIMUM_HEAT_CAPACITY, heat_capacity)


//Adds or removes thermal energy. Returns the actual thermal energy change, as in the case of removing energy we can't go below TCMB.
/datum/gas_mixture/proc/add_thermal_energy(var/thermal_energy)
	if(total_moles == 0)
		return 0

	var/heat_capacity = heat_capacity()
	if(thermal_energy < 0)
		if(temperature < TCMB)
			return 0
		var/thermal_energy_limit = -(temperature - TCMB) * heat_capacity	//ensure temperature does not go below TCMB
		thermal_energy = max(thermal_energy, thermal_energy_limit)	//thermal_energy and thermal_energy_limit are negative here.
	temperature += thermal_energy/heat_capacity
	return thermal_energy


//Returns the thermal energy change required to get to a new temperature
/datum/gas_mixture/proc/get_thermal_energy_change(var/new_temperature)
	return heat_capacity() * (max(new_temperature, 0) - temperature)


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
//	if (src[gasid] == 0)
//		return SPECIFIC_ENTROPY_VACUUM	//that gas isn't here
//
//	//V/(m*T) = R/(partial pressure)
//	var/molar_mass = XGM.molar_mass[gasid]
//	var/specific_heat = XGM.specific_heat[gasid]
//	return R_IDEAL_GAS_EQUATION * ( log( (IDEAL_GAS_ENTROPY_CONSTANT*volume/(src[gasid] * temperature)) * (molar_mass*specific_heat*temperature)**(2/3) + 1 ) +  15 )
//
//	//alternative, simpler equation
//	//var/partial_pressure = src[gasid] * R_IDEAL_GAS_EQUATION * temperature / volume
//	//return R_IDEAL_GAS_EQUATION * ( log (1 + IDEAL_GAS_ENTROPY_CONSTANT/partial_pressure) + 20 )


//Updates the calculated vars (total_moles, pressure, etc.) (actually currently only those two), and culls empty gases from the mix.
//Called by default by all methods that alter a gas_mixture, and should be called if you manually alter it.
/datum/gas_mixture/proc/update_values()
	total_moles = 0
	for(var/g in gas)
		var/moles = gas[g]
		if(moles)
			total_moles += gas[g]
		else
			gas -= g

	if(volume > 0)
		pressure = total_moles * R_IDEAL_GAS_EQUATION * temperature / volume
	else
		pressure = 0


/datum/gas_mixture/proc/total_moles()
	return total_moles


/datum/gas_mixture/proc/return_pressure()
	return pressure


//Removes the given number of moles from src, and returns a new gas_mixture containing the removed gas.
/datum/gas_mixture/proc/remove(moles, update = TRUE, update_removed = TRUE)
	var/sum = total_moles
	moles = min(moles, sum) //Cannot take more air than tile has!
	var/ratio = sum && (moles / sum) //Don't divide by zero
	return remove_ratio(ratio, update, update_removed)


//Removes the given proportion of the gas in src, and returns a new gas_mixture containing the removed gas.
/datum/gas_mixture/proc/remove_ratio(ratio, update = TRUE, update_removed = TRUE)
	var/datum/gas_mixture/removed = new()

	if(ratio <= 0 || total_moles <= 0)
		return removed

	ratio = min(ratio, 1)

	for(var/g in gas)
		var/moles = gas[g] * ratio
		gas[g] -= moles
		removed[g] += moles

	removed.temperature = temperature

	if(update)
		update_values()
	if(update_removed)
		removed.update_values()

	return removed


//Removes the given volume of gas from src, and returns a new gas_mixture containing the removed gas, with the given volume.
/datum/gas_mixture/proc/remove_volume(removed_volume, update = TRUE, update_removed = TRUE)
	var/datum/gas_mixture/removed = remove_ratio(removed_volume / volume, update, FALSE)
	removed.volume = removed_volume
	if(update_removed)
		removed.update_values()
	return removed


////////////////////////////////////////////
//Procedures used for very specific events//
////////////////////////////////////////////

//Rechecks the gas_mixture and adjusts the graphic list if needed.
//Two lists can be passed by reference if you need know specifically which graphics were added and removed.
/datum/gas_mixture/proc/check_tile_graphic(list/graphic_add = null, list/graphic_remove = null)
	for(var/g in XGM.overlay_limit)
		if(graphic.Find(XGM.tile_overlay[g]))
			//Overlay is already applied for this gas, check if it's still valid.
			if(molar_density(g) <= XGM.overlay_limit[g])
				if(!graphic_remove)
					graphic_remove = list()
				graphic_remove += XGM.tile_overlay[g]
		else
			//Overlay isn't applied for this gas, check if it's valid and needs to be added.
			if(molar_density(g) > XGM.overlay_limit[g])
				if(!graphic_add)
					graphic_add = list()
				graphic_add += XGM.tile_overlay[g]

	. = 0
	//Apply changes
	if(graphic_add && graphic_add.len)
		graphic += graphic_add
		. = 1
	if(graphic_remove && graphic_remove.len)
		graphic -= graphic_remove
		. = 1

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


//Copies the gases from sample to src, per unit volume.
/datum/gas_mixture/proc/copy_from(datum/gas_mixture/sample)
	gas.len = 0
	for(var/g in sample.gas)
		src[g] = sample.gas[g]

	temperature = sample.temperature

	multiply(volume / sample.volume)
	return 1

//The general form of the calculation used in compare() to check if two numbers are separated by at least a given abslute value AND relative value.
//Not guaranteed to produce the same result if the order of the vars to check is switched, but since its purpose is approximation anyway, it should be fine.
#define FAIL_SIMILARITY_CHECK(ownvar, samplevar, absolute, relative) (abs((ownvar) - (samplevar)) > (absolute) && \
	(((ownvar) < (1 - (relative)) * (samplevar)) || ((ownvar) > (1 + (relative)) * (samplevar))))

//The above except for gases specifically.
#define FAIL_AIR_SIMILARITY_CHECK(ownvar, samplevar) (FAIL_SIMILARITY_CHECK((ownvar), (samplevar), MINIMUM_AIR_TO_SUSPEND, MINIMUM_AIR_RATIO_TO_SUSPEND))

//Compares src's gas to sample's gas, per unit volume.
//Returns TRUE if they are close enough to equal to equalize or merge (in the case of zones), FALSE otherwise.
/datum/gas_mixture/proc/compare(datum/gas_mixture/sample)
	if(!istype(sample))
		return FALSE

	if(FAIL_SIMILARITY_CHECK(temperature, sample.temperature, MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND, MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND))
		return FALSE
	if(FAIL_SIMILARITY_CHECK(pressure, sample.pressure, MINIMUM_PRESSURE_DELTA_TO_SUSPEND, MINIMUM_PRESSURE_RATIO_TO_SUSPEND))
		return FALSE

	for(var/g in gas | sample.gas)
		if(FAIL_AIR_SIMILARITY_CHECK(molar_density(g), sample.molar_density(g)))
			return FALSE

	return TRUE

#undef FAIL_AIR_SIMILARITY_CHECK
#undef FAIL_SIMILARITY_CHECK


/datum/gas_mixture/proc/add(datum/gas_mixture/right_side)
	if(!istype(right_side))
		return FALSE

	for(var/g in right_side.gas)
		src[g] += right_side.gas[g]

	update_values()
	return TRUE


/datum/gas_mixture/proc/subtract(datum/gas_mixture/right_side)
	if(!istype(right_side))
		return FALSE

	for(var/g in right_side.gas)
		src[g] -= right_side.gas[g]

	update_values()
	return TRUE


/datum/gas_mixture/proc/multiply(factor)
	for(var/g in gas)
		gas[g] *= factor

	update_values()
	return TRUE


/datum/gas_mixture/proc/divide(factor)
	for(var/g in gas)
		gas[g] /= factor

	update_values()
	return TRUE


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
	var/datum/gas_mixture/sharer = new() //Make a new gas_mixture to copy unsim_air into so it doesn't get changed.
	sharer.volume = unsim_air.volume + volume + 3 * CELL_VOLUME //Then increase the copy's volume so larger rooms don't drain slowly as fuck.
		//Why add the 3 * CELL_VOLUME, you ask? To mirror the old behavior. Why did the old behavior add three tiles to the total? I have no idea.
	sharer.copy_from(unsim_air) //Finally, perform the actual copy
	return share_tiles(sharer, connecting_tiles)


/datum/gas_mixture/proc/english_contents_list()
	var/list/all_contents = list()

	for(var/g in gas)
		all_contents += XGM.name[g]

	return english_list(all_contents)


/datum/gas_mixture/proc/loggable_contents()
	var/naughty_stuff = list()

	for(var/g in gas)
		if(XGM.flags[g] & XGM_GAS_LOGGED)
			naughty_stuff += "<span class='bold red'>[XGM.short_name[g]]</span>"
	return english_list(naughty_stuff, nothing_text = "")



//Unsimulated gas_mixture
//Acts like a gas_mixture, except none of the procs actually change it.

/datum/gas_mixture/unsimulated/adjust_gas(gasid, moles, update = TRUE)
	return


/datum/gas_mixture/unsimulated/adjust_gas_temp(gasid, moles, temp, update = TRUE)
	return


/datum/gas_mixture/unsimulated/adjust_multi()
	ASSERT(!(args.len % 2))


/datum/gas_mixture/unsimulated/adjust_multi_temp()
	ASSERT(!(args.len % 3))


/datum/gas_mixture/unsimulated/merge(datum/gas_mixture/giver)
	return !isnull(giver)


/datum/gas_mixture/unsimulated/equalize(datum/gas_mixture/sharer)
	return sharer.equalize(src) //Won't actually equalize the two mixtures, but will affect sharer the same way it would have if src weren't unsimulated.


/datum/gas_mixture/unsimulated/add_thermal_energy(var/thermal_energy)
	return 0


/datum/gas_mixture/unsimulated/get_thermal_energy_change(var/new_temperature)
	return 0 //Real answer would be infinity, but that would be virtually guaranteed to cause problems.


/datum/gas_mixture/unsimulated/remove_ratio(ratio, update, update_removed = TRUE)
	var/datum/gas_mixture/removed = new()

	if(ratio <= 0 || total_moles <= 0)
		return removed

	ratio = min(ratio, 1)

	for(var/g in gas)
		removed[g] += gas[g] * ratio

	removed.temperature = temperature

	if(update_removed)
		removed.update_values()

	return removed


/datum/gas_mixture/unsimulated/copy_from(datum/gas_mixture/sample)
	return FALSE


/datum/gas_mixture/unsimulated/add(datum/gas_mixture/right_side)
	return FALSE


/datum/gas_mixture/unsimulated/subtract(datum/gas_mixture/right_side)
	return FALSE


/datum/gas_mixture/unsimulated/multiply(factor)
	return FALSE


/datum/gas_mixture/unsimulated/divide(factor)
	return FALSE
