#define GAS_OXYGEN   "oxygen"
#define GAS_NITROGEN "nitrogen"
#define GAS_CARBON   "carbon_dioxide"
#define GAS_PLASMA   "plasma"
#define GAS_SLEEPING "sleeping_agent"
#define GAS_VOLATILE "volatile_fuel"
#define GAS_OXAGENT  "oxygen_agent_b"

/decl/xgm_gas/oxygen
	id = GAS_OXYGEN
	name = "Oxygen"
	specific_heat = 20	// J/(mol*K)
	molar_mass = 0.032	// kg/mol

	flags = XGM_GAS_OXIDIZER

/decl/xgm_gas/nitrogen
	id = GAS_NITROGEN
	name = "Nitrogen"
	specific_heat = 20	// J/(mol*K)
	molar_mass = 0.028	// kg/mol

/decl/xgm_gas/carbon_dioxide
	id = GAS_CARBON
	name = "Carbon Dioxide"
	specific_heat = 30	// J/(mol*K)
	molar_mass = 0.044	// kg/mol

/decl/xgm_gas/plasma
	id = GAS_PLASMA
	name = "Plasma"

	//Note that this has a significant impact on TTV yield.
	//Because it is so high, any leftover phoron soaks up a lot of heat and drops the yield pressure.
	specific_heat = 200	// J/(mol*K)

	//Hypothetical group 14 (same as carbon), period 8 element.
	//Using multiplicity rule, it's atomic number is 162
	//and following a N/Z ratio of 1.5, the molar mass of a monatomic gas is:
	molar_mass = 0.405	// kg/mol

	tile_overlay = "plasma"
	overlay_limit = MOLES_PLASMA_VISIBLE
	flags = XGM_GAS_FUEL | XGM_GAS_CONTAMINANT

/decl/xgm_gas/sleeping_agent
	id =  GAS_SLEEPING
	name = "Sleeping Agent"
	specific_heat = 40	// J/(mol*K)
	molar_mass = 0.044	// kg/mol. N2O

	tile_overlay = "sleeping_agent"
	overlay_limit = 1
	flags = XGM_GAS_OXIDIZER //N2O is a powerful oxidizer

/decl/xgm_gas/volatile_fuel
	id = GAS_VOLATILE
	name = "Volatile Fuel"

	specific_heat = 30
	molar_mass = 0.163 // @MoMMI#9954 roll 32 405

	flags = XGM_GAS_FUEL

/decl/xgm_gas/oxygen_agent_b
	id = GAS_OXAGENT
	name = "Oxygen Agent B"

	specific_heat = 300
	molar_mass = 0.300

	flags = XGM_GAS_FUEL | XGM_GAS_OXIDIZER | XGM_GAS_CONTAMINANT
