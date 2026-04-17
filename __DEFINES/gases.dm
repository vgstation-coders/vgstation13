#define GAS_OXYGEN   "oxygen"
#define GAS_NITROGEN "nitrogen"
#define GAS_CARBON   "carbon_dioxide"
#define GAS_PLASMA   "plasma"
#define GAS_SLEEPING "sleeping_agent"
#define GAS_CRYOTHEUM "cryotheum"
#define GAS_VOLATILE "volatile_fuel"
#define GAS_OXAGENT  "oxygen_agent_b"
#define GAS_RADON  "radon"

#define SHOW_PLASMA   1
#define SHOW_SLEEPING 2
#define SHOW_CRYOTHEUM 4

var/static/list/gas2show = list(
		GAS_PLASMA = SHOW_PLASMA,
		GAS_SLEEPING = SHOW_SLEEPING,
		GAS_CRYOTHEUM = SHOW_CRYOTHEUM,
	)
