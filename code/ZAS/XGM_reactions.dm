/datum/gas_reaction
	var/name = "Empty Gas Reaction"
	var/caching_flags = 0

// Used for caching purposes. Returns true if this reaction can occur inside this mixture - i.e. the necessary reagents are inside the mixture. Caching_flags
// determine when this function is called - if no flags, it will be called constantly on every update to a mixture. Additional flags will improve efficiency by
// reducing calls.
/datum/gas_reaction/proc/reaction_is_possible(datum/gas_mixture/mixture)
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
	return mixture[GAS_CRYOTHEUM] > 0 && QUANTIZE(mixture.molar_density(GAS_CRYOTHEUM)) * CELL_VOLUME > MOLES_CRYOTHEUM_VISIBLE && mixture[GAS_OXYGEN] > 0

/datum/gas_reaction/cryotheum_oxygen_reaction/reaction_amounts_requested(datum/gas_mixture/mixture)
	var/to_return[] = list()
	// Reach maximum efficiency when the Cryo:Oxy ratio is 1:50 or higher. Any less and scale linearly, i.e. 1:100 is half speed.
	var/catalyst_coefficient = min(1.0, mixture[GAS_CRYOTHEUM] / mixture[GAS_OXYGEN] * 50)
	to_return[GAS_OXYGEN] = catalyst_coefficient * mixture[GAS_OXYGEN]*0.0015
	return to_return

/datum/gas_reaction/cryotheum_oxygen_reaction/perform_reaction(datum/gas_mixture/mixture, reactant_amounts)
	var/reaction_coefficient = reactant_amounts[GAS_OXYGEN]
	mixture[GAS_OXYGEN] = max(0, mixture[GAS_OXYGEN] - reaction_coefficient)
	// Should reduce a normal room down to a minimum of around -30C in less than a minute.
	var/const/temp_loss_per_one_reaction = -170000
	var/const/min_oxy_reaction_temperature = 242.8952
	mixture.add_thermal_energy( reaction_coefficient * temp_loss_per_one_reaction, min_oxy_reaction_temperature)


// Cryotheum reacts with itself in the presence of plasma, disappearing but drastically lowering temperatures. Small amounts of gas will near-instantly turn to 0.1K, whereas
// very large amounts will cool down at a decent rate.
/datum/gas_reaction/cryotheum_plasma_reaction
	name = "Plasma Catalyzed Cryotheum Reaction"

/datum/gas_reaction/cryotheum_plasma_reaction/reaction_is_possible(datum/gas_mixture/mixture)
	return mixture[GAS_CRYOTHEUM] > 0 && QUANTIZE(mixture.molar_density(GAS_PLASMA)) * CELL_VOLUME > MOLES_PLASMA_VISIBLE

/datum/gas_reaction/cryotheum_plasma_reaction/reaction_amounts_requested(datum/gas_mixture/mixture)
	var/to_return[] = list()
	// Reach maximum efficiency when the Plasma/Cryo ratio is 1:10 or higher. Any less and scale linearly, i.e. 1:20 is half speed.
	var/catalyst_coefficient = min(1.0, mixture[GAS_PLASMA] / mixture[GAS_CRYOTHEUM] * 10)
	to_return[GAS_CRYOTHEUM] = catalyst_coefficient * mixture[GAS_CRYOTHEUM]*0.2
	return to_return

/datum/gas_reaction/cryotheum_plasma_reaction/perform_reaction(datum/gas_mixture/mixture, reactant_amounts)
	var/reaction_coefficient = reactant_amounts[GAS_CRYOTHEUM]

	mixture[GAS_CRYOTHEUM] = max(0, mixture[GAS_CRYOTHEUM] - reaction_coefficient)
	// Cryotheum can only cool things down to 0.1K. However, the cooling power changes based on the current temperature of the mixture - that is, the closer it is to 0.1K,
	// the more it cools. This exists for a lot of reasons, but the big one is that cryotheum was broken as a way to cool engines by simply pumping a bunch of cryotheum into
	// it. This will help cement it as more of a plasma-cooling method while still allowing it as an engine cooling method in some scenarios.
	var/const/min_temp = 0.1
	var/distance_to_min_temp = max(0, mixture.temperature - min_temp)
	// Cooling coefficient with the current numbers will reach a max of 6 at around 10K and will scale down from there, reaching around 0.4 at 300K and 0.13 at 1000K.
	var/cooling_coefficient = min(1, 80 / distance_to_min_temp) + min(5, 50 / distance_to_min_temp)

	// Arbitrary number to reduce temperature by a significant amount.
	var/const/base_temp_loss_per_one_reaction = -240000
	mixture.add_thermal_energy( cooling_coefficient * reaction_coefficient * base_temp_loss_per_one_reaction, 0.1)
