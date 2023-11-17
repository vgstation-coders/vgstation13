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



// Cryotheum reacts with nitrogen at a 1:2 ratio to produce N2O and also consumes a lot of heat.
/datum/gas_reaction/cryotheum_nitrogen_reaction
	name = "Cryotheum-Nitrogen Reaction"

/datum/gas_reaction/cryotheum_nitrogen_reaction/reaction_is_possible(datum/gas_mixture/mixture)
	return mixture[GAS_CRYOTHEUM] > 0 && mixture[GAS_NITROGEN] > 0

/datum/gas_reaction/cryotheum_nitrogen_reaction/reaction_amounts_requested(datum/gas_mixture/mixture)
	var/base_amount = min(mixture[GAS_CRYOTHEUM], mixture[GAS_NITROGEN]/2) * 0.2
	var/to_return[] = list()
	to_return[GAS_CRYOTHEUM] = base_amount
	to_return[GAS_NITROGEN] = base_amount*2
	return to_return

/datum/gas_reaction/cryotheum_nitrogen_reaction/perform_reaction(datum/gas_mixture/mixture, reactant_amounts)
	var/reaction_coefficient = reactant_amounts[GAS_CRYOTHEUM]

	mixture[GAS_CRYOTHEUM] -= reactant_amounts[GAS_CRYOTHEUM]
	mixture[GAS_NITROGEN] -= reactant_amounts[GAS_NITROGEN]
	mixture.adjust_gas(GAS_SLEEPING, reaction_coefficient)
	mixture.add_thermal_energy( reaction_coefficient * -5000, 0.5)
	return



// Cryotheum dissapates when above 20C. Goes faster the hotter it is.
/datum/gas_reaction/cryotheum_dissapation
	name = "Cryotheum Dissapation"

// "Possible" here means that we want to run perform_reaction. reaction_is_possible is called an absolute ton and it's much more efficient
// if we can use a caching_flag to reduce the amount of calls, so here we only check if there is any cryotheum and we can decide whether to
// actually disappated in perform_reaction.
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
	mixture[GAS_CRYOTHEUM] -= reactant_amounts[GAS_CRYOTHEUM]
	return

