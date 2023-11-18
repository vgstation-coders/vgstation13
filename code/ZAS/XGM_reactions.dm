/datum/gas_reaction
	var/name = "Empty Gas Reaction"
	var/caching_flags = 0

// Used for caching purposes. Returns true if this reaction can occur inside this mixture - i.e. the necessary reagents are inside the mixture. Caching_flags
// determine when this function is called - if no flags, it will be called constantly on every update to a mixture. Additional flags will improve efficiency by
// reducing calls.
/datum/gas_reaction/proc/reaction_is_possible( datum/gas_mixture/mixture )
	return FALSE

// Given that this reaction is the only reaction occuring in mixture, how much of each reagent would it use up this tick?
/datum/gas_reaction/proc/reaction_amounts_requested( datum/gas_mixture/mixture )
	var/to_return[]
	return to_return

// Actually perform the reaction on the given mixture. reactant_amounts may be the same what was returned by reaction_amounts_requested, or it could be
// multiplied by a factor. It is guaranteed to be in the proper ratio of your reaction though, given that you made reaction_amounts_requested
// return the proper ratio. And it will never give you reactant_amounts that are greater than what the mixture has.
/datum/gas_reaction/proc/perform_reaction( datum/gas_mixture/mixture, reactant_amounts )
	return





// Cryotheum reacts with itself in the presence of plasma, disappearing but lowering temperatures.
/datum/gas_reaction/cryotheum_plasma_reaction
	name = "Plasma Catalyzed Cryotheum Reaction"

/datum/gas_reaction/cryotheum_nitrogen_reaction/reaction_is_possible(datum/gas_mixture/mixture)
	return mixture[GAS_CRYOTHEUM] > 0 && mixture[GAS_PLASMA] > 0

/datum/gas_reaction/cryotheum_nitrogen_reaction/reaction_amounts_requested(datum/gas_mixture/mixture)
	var/to_return[] = list()
	var/catalyst_coefficient = min(1.0, mixture[GAS_PLASMA] / mixture[GAS_CRYOTHEUM] * 10)
	to_return[GAS_CRYOTHEUM] = catalyst_coefficient * mixture[GAS_CRYOTHEUM]*0.2
	return to_return

/datum/gas_reaction/cryotheum_nitrogen_reaction/perform_reaction(datum/gas_mixture/mixture, reactant_amounts)
	var/reaction_coefficient = reactant_amounts[GAS_CRYOTHEUM]
	mixture[GAS_CRYOTHEUM] = max(0, mixture[GAS_CRYOTHEUM] - reaction_coefficient)
	// Cryotheum can only cool things down to 0.1K. As we approach that temperature, it cools less and less. Conversely, at higher temperatures it cools more.
	var/distance_to_min_temp = max(0, mixture.temperature - 0.1)
	var/logarithmic_modifier = max(0, log(40, distance_to_min_temp+1))
	mixture.add_thermal_energy( logarithmic_modifier * reaction_coefficient * -60000, 0.2)
	mixture.adjust_gas()

// Cryotheum dissapates when above 20C. Goes faster the hotter it is.
/datum/gas_reaction/cryotheum_dissapation
	name = "Cryotheum Dissapation"

/datum/gas_reaction/cryotheum_dissapation/reaction_is_possible(datum/gas_mixture/mixture)
	return mixture[GAS_CRYOTHEUM] > 0

/datum/gas_reaction/cryotheum_dissapation/reaction_amounts_requested(datum/gas_mixture/mixture)
	var/to_return[] = list()
	var/temperature_delta = mixture.temperature - T0C
	if(temperature_delta < 0)
		return to_return
	// Determine what percentage of the gas we will be dissapating based on the temperature. At 2200K, 100% of the gas will dissapate. At 273.15K, 0% of the gas will dissapate.
	to_return[GAS_CRYOTHEUM] = (mixture[GAS_CRYOTHEUM] * min(1, (mixture.temperature-T0C)/1926.85))
	// To prevent infinitely small numbers, if it's below 0.01 moles we can just delete the rest.
	to_return[GAS_CRYOTHEUM] = max(0.01, to_return[GAS_CRYOTHEUM])
	return to_return

/datum/gas_reaction/cryotheum_dissapation/perform_reaction(datum/gas_mixture/mixture, reactant_amounts)
	mixture[GAS_CRYOTHEUM] = max(0, mixture[GAS_CRYOTHEUM] - reactant_amounts[GAS_CRYOTHEUM])

