/datum/gas_reaction
	var/name = "Empty Gas Reaction"
	var/caching_flags = 0

// Used for caching purposes. Returns true if this reaction can occur inside this mixture - i.e. the necessary reagents are inside the mixture. Caching_flags
// determine when this function is called - if no flags, it will be called constantly on every update to a mixture. Additional flags will improve efficiency by
// reducing calls.
/datum/gas_reaction/proc/reaction_is_possible( datum/gas_mixture/mixture )
	return FALSE

// Given that this reaction is the only reaction occuring in mixture, how much of each reagent would it use up this tick? Values must be accurate, since if for instance
// another reaction requests 80% of the oxygen and this one also requests 80%, then it will scale it down so that each one only uses 50% oxygen.
/datum/gas_reaction/proc/reaction_amounts_requested( datum/gas_mixture/mixture )
	var/to_return[]
	return to_return

// Actually perform the reaction on the given mixture. reactant_amounts may be the same what was returned by reaction_amounts_requested, or it could be
// multiplied by a factor to be smaller. Reactants will always be in the same ratio you gave in reaction_amounts_requested, however.
/datum/gas_reaction/proc/perform_reaction( datum/gas_mixture/mixture, reactant_amounts )
	return



// Cryotheum catalyzes oxygen to slowly evaporate but produce a tiny bit of cold up to 232K. This essentially exists so that cryo floods are a little chilly, lol.
// Requires a ratio of 1 Cryo : 50 Oxygen to reach maximum speed.
/datum/gas_reaction/cryotheum_oxygen_reaction
	name = "Cryotheum-Oxygen Reaction"

/datum/gas_reaction/cryotheum_oxygen_reaction/reaction_is_possible(datum/gas_mixture/mixture)
	return mixture[GAS_CRYOTHEUM] > 0 && mixture[GAS_OXYGEN] > 0

/datum/gas_reaction/cryotheum_oxygen_reaction/reaction_amounts_requested(datum/gas_mixture/mixture)
	var/to_return[] = list()
	var/catalyst_coefficient = min(1.0, mixture[GAS_CRYOTHEUM] / mixture[GAS_OXYGEN] * 50)
	to_return[GAS_OXYGEN] = catalyst_coefficient * mixture[GAS_OXYGEN]*0.0015
	return to_return

/datum/gas_reaction/cryotheum_oxygen_reaction/perform_reaction(datum/gas_mixture/mixture, reactant_amounts)
	var/reaction_coefficient = reactant_amounts[GAS_OXYGEN]
	mixture[GAS_OXYGEN] = max(0, mixture[GAS_OXYGEN] - reaction_coefficient)
	// -120000 times 0.0015 * mols of oxygen should reduce a normal room by about 1.7C every time this ticks.
	mixture.add_thermal_energy( reaction_coefficient * -120000, 232.8952)


// Cryotheum reacts with itself in the presence of plasma, disappearing but drastically lowering temperatures. Small amounts of gas will near-instantly turn to 0.1K, whereas
// very large amounts will cool down at a decent rate.
/datum/gas_reaction/cryotheum_plasma_reaction
	name = "Plasma Catalyzed Cryotheum Reaction"

/datum/gas_reaction/cryotheum_plasma_reaction/reaction_is_possible(datum/gas_mixture/mixture)
	return mixture[GAS_CRYOTHEUM] > 0 && mixture[GAS_PLASMA] > 0

/datum/gas_reaction/cryotheum_plasma_reaction/reaction_amounts_requested(datum/gas_mixture/mixture)
	var/to_return[] = list()
	var/catalyst_coefficient = min(1.0, mixture[GAS_PLASMA] / mixture[GAS_CRYOTHEUM] * 10)
	to_return[GAS_CRYOTHEUM] = catalyst_coefficient * mixture[GAS_CRYOTHEUM]*0.2
	return to_return

/datum/gas_reaction/cryotheum_plasma_reaction/perform_reaction(datum/gas_mixture/mixture, reactant_amounts)
	var/reaction_coefficient = reactant_amounts[GAS_CRYOTHEUM]
	mixture[GAS_CRYOTHEUM] = max(0, mixture[GAS_CRYOTHEUM] - reaction_coefficient)
	// Cryotheum can only cool things down to 0.1K. As we approach that temperature, it cools less and less. Conversely, at higher temperatures it cools more.
	var/distance_to_min_temp = max(0, mixture.temperature - 0.1)
	var/logarithmic_modifier = max(0, log(40, distance_to_min_temp+1))
	// Arbitrary number to reduce temperature by a significant amount, hardcapped at the minimum temperature.
	mixture.add_thermal_energy( logarithmic_modifier * reaction_coefficient * -700000, 0.1)



// Cryotheum dissapates when above 0C. Goes faster the hotter it is.
/datum/gas_reaction/cryotheum_dissipation
	name = "Cryotheum Dissipation"

/datum/gas_reaction/cryotheum_dissipation/reaction_is_possible(datum/gas_mixture/mixture)
	return mixture[GAS_CRYOTHEUM] > 0 && mixture.temperature > T0C

/datum/gas_reaction/cryotheum_dissipation/reaction_amounts_requested(datum/gas_mixture/mixture)
	var/to_return[] = list()
	// Determine what percentage of the gas we will be dissapating based on the temperature. At 2200K, 100% of the gas will dissapate. At 273.15K, 0% of the gas will dissapate.
	// Scales linearly between those values.
	to_return[GAS_CRYOTHEUM] = (mixture[GAS_CRYOTHEUM] * min(1, (mixture.temperature-T0C)/1926.85))
	// To prevent infinitely small numbers, if it's below 0.01 moles we can just delete the rest.
	to_return[GAS_CRYOTHEUM] = max(0.01, to_return[GAS_CRYOTHEUM])
	return to_return

/datum/gas_reaction/cryotheum_dissipation/perform_reaction(datum/gas_mixture/mixture, reactant_amounts)
	mixture[GAS_CRYOTHEUM] = max(0, mixture[GAS_CRYOTHEUM] - reactant_amounts[GAS_CRYOTHEUM])


