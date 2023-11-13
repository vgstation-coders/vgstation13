/datum/gas_reaction
	var/name = "Empty Gas Reaction"

// Used for caching purposes. Returns true if this reaction can occur inside this mixture - i.e. the necessary reagents are there, and
/datum/gas_reaction/proc/reaction_is_possible( datum/gas_mixture/mixture )
	return FALSE

// Given that this reaction is the only reaction occuring in mixture, how much of each reagent would it use up this tick?
/datum/gas_reaction/proc/reaction_amounts_requested( datum/gas_mixture/mixture )
	var/to_return[]
	return to_return

// Actually perform the reaction on the given mixture. reactant_amounts may be the same what was returned by reaction_amounts_requested, or it could be
// multiplied by a factor. It is guaranteed to be in the proper ratio of your reaction though, given that you made reaction_amounts_requested
// return the proper ratio. And it will never give you an amount greater than what the gas system is.
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
	mixture.add_thermal_energy( reaction_coefficient * -50000, 0.5)
	return

/datum/gas_reaction/oxygen_nitrogen_test
	name = "Test 1"

/datum/gas_reaction/oxygen_nitrogen_test/reaction_is_possible(datum/gas_mixture/mixture)
	return mixture[GAS_OXYGEN] > 0 && mixture[GAS_NITROGEN] > 0

/datum/gas_reaction/oxygen_nitrogen_test/reaction_amounts_requested(datum/gas_mixture/mixture)
	var/base_amount = min(mixture[OXYGEN], mixture[GAS_NITROGEN]) * 0.2
	var/to_return[] = list()
	to_return[GAS_CRYOTHEUM] = base_amount
	to_return[GAS_NITROGEN] = base_amount
	return to_return

/datum/gas_reaction/oxygen_nitrogen_test/perform_reaction(datum/gas_mixture/mixture, reactant_amounts)
	mixture.add_thermal_energy( 50, 0.5)
	return

/datum/gas_reaction/oxygen_nitrogen_test/two
	name = "Test 2"

/datum/gas_reaction/oxygen_nitrogen_test/three
	name = "Test 3"

/datum/gas_reaction/oxygen_nitrogen_test/four
	name = "Test 4"

/datum/gas_reaction/oxygen_nitrogen_test/five
	name = "Test 5"

/datum/gas_reaction/oxygen_nitrogen_test/six
	name = "Test 6"

/datum/gas_reaction/oxygen_nitrogen_test/seven
	name = "Test 7"

/datum/gas_reaction/oxygen_nitrogen_test/eight
	name = "Test 8"

/datum/gas_reaction/oxygen_nitrogen_test/nine
	name = "Test 9"



