#define PI 3.141592653

// The TRUE circle constant!
#define TAU (PI * 2)

//"fancy" math for calculating time in ms from tick_usage percentage and the length of ticks
//percent_of_tick_used * (ticklag * 100(to convert to ms)) / 100(percent ratio)
//collapsed to percent_of_tick_used * tick_lag
#define TICK_DELTA_TO_MS(percent_of_tick_used) ((percent_of_tick_used) * world.tick_lag)
#define TICK_USAGE_TO_MS(starting_tickusage) (TICK_DELTA_TO_MS(world.tick_usage-starting_tickusage))

#define R_IDEAL_GAS_EQUATION	8.314 //kPa*L/(K*mol)
#define ONE_ATMOSPHERE		101.325	//kPa

#define T0C  273.15					// 0degC
#define T20C 293.15					// 20degC
#define TCMB 2.73					// -270.42degC

#define INFINITY 1e31 //closer than enough

#define SPEED_OF_LIGHT 3e8 //not exact but hey!
#define SPEED_OF_LIGHT_SQ 9e+16

#define MELTPOINT_GLASS   1500+T0C
#define MELTPOINT_STEEL   1510+T0C
#define MELTPOINT_SILICON 1687 // KELVIN
#define MELTPOINT_PLASTIC 180+T0C
#define MELTPOINT_SNOW	304.15	//about 30°C
