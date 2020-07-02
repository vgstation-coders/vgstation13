/datum/gas
	var/id = ""
	var/name = "Unnamed Gas"
	var/short_name // HTML-formatted short name.
	var/specific_heat = 20	// J/(mol*K)
	var/molar_mass = 0.032	// kg/mol

	var/tile_overlay = null //The overlay to draw over tiles containing this gas if it is visible. Can be anything that the overlays list will accept.
	var/overlay_limit = null //If the molar_density of this gas in a zone is strictly greater than this number, it is visible.

	var/flags = 0

//This should probably be in a different file, but currently it's only used here.
/image/effect
	plane = EFFECTS_PLANE

/datum/gas/proc/is_human_safe(var/moles, var/datum/gas_mixture/mixture)
	return TRUE

/datum/gas/oxygen
	id = GAS_OXYGEN
	name = "Oxygen"
	short_name = "O<sub>2</sub>"
	specific_heat = 20	// J/(mol*K)
	molar_mass = 0.032	// kg/mol

	flags = XGM_GAS_OXIDIZER

/datum/gas/oxygen/is_human_safe(var/moles, var/datum/gas_mixture/mixture)
	return abs(moles/mixture.total_moles() - O2STANDARD) < 0.02

/datum/gas/nitrogen
	id = GAS_NITROGEN
	name = "Nitrogen"
	short_name = "N<sub>2</sub>"
	specific_heat = 20	// J/(mol*K)
	molar_mass = 0.028	// kg/mol

/datum/gas/nitrogen/is_human_safe(var/moles, var/datum/gas_mixture/mixture)
	return abs(moles/mixture.total_moles() - N2STANDARD) < 0.2

/datum/gas/carbon_dioxide
	id = GAS_CARBON
	name = "Carbon Dioxide"
	short_name = "CO<sub>2</sub>"
	specific_heat = 30	// J/(mol*K)
	molar_mass = 0.044	// kg/mol

	flags = XGM_GAS_LOGGED

/datum/gas/carbon_dioxide/is_human_safe(var/moles, var/datum/gas_mixture/mixture)
	return moles/mixture.total_moles() < 0.01

/datum/gas/plasma
	id = GAS_PLASMA
	name = "Plasma"

	//Note that this has a significant impact on TTV yield.
	//Because it is so high, any leftover plasma soaks up a lot of heat and drops the yield pressure.
	specific_heat = 200	// J/(mol*K)

	//Hypothetical group 14 (same as carbon), period 8 element.
	//Using multiplicity rule, it's atomic number is 162
	//and following a N/Z ratio of 1.5, the molar mass of a monatomic gas is:
	molar_mass = 0.405	// kg/mol

	tile_overlay = new /image/effect('icons/effects/tile_effects.dmi', "plasma", FLY_LAYER)
	overlay_limit = MOLES_PLASMA_VISIBLE / CELL_VOLUME
	flags = XGM_GAS_FUEL | XGM_GAS_CONTAMINANT | XGM_GAS_LOGGED

/datum/gas/plasma/is_human_safe(var/moles, var/datum/gas_mixture/mixture)
	return moles/mixture.total_moles() < 0.01

/datum/gas/sleeping_agent
	id = GAS_SLEEPING
	name = "Sleeping Agent"
	short_name = "N<sub>2</sub>O"
	specific_heat = 40	// J/(mol*K)
	molar_mass = 0.044	// kg/mol. N₂O

	tile_overlay = new /image/effect('icons/effects/tile_effects.dmi', "sleeping_agent", FLY_LAYER)
	overlay_limit = 1 / CELL_VOLUME
	flags = XGM_GAS_OXIDIZER | XGM_GAS_LOGGED // N₂O is a powerful oxidizer

/datum/gas/sleeping_agent/is_human_safe(var/moles, var/datum/gas_mixture/mixture)
	return moles/mixture.total_moles() < 0.01

/datum/gas/volatile_fuel
	id = GAS_VOLATILE
	name = "Volatile Fuel"

	specific_heat = 30
	molar_mass = 0.163 // @MoMMI#9954 roll 32 405

	flags = XGM_GAS_FUEL | XGM_GAS_LOGGED

/datum/gas/volatile_fuel/is_human_safe(var/moles, var/datum/gas_mixture/mixture)
	return moles/mixture.total_moles() < 0.01

/datum/gas/oxygen_agent_b
	id = GAS_OXAGENT
	name = "Oxygen Agent B"

	specific_heat = 300
	molar_mass = 0.300

	flags = XGM_GAS_FUEL | XGM_GAS_OXIDIZER | XGM_GAS_CONTAMINANT | XGM_GAS_LOGGED

/datum/gas/oxygen_agent_b/is_human_safe(var/moles, var/datum/gas_mixture/mixture)
	return moles/mixture.total_moles() < 0.01
