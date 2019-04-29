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

#define MEGAWATT 1000000
#define TEN_MEGAWATTS 10000000
#define HUNDRED_MEGAWATTS 100000000
#define GIGAWATT 1000000000

// Radiation constants.
#define STEFAN_BOLTZMANN_CONSTANT    5.6704e-8 // W/(m^2*K^4).
#define COSMIC_RADIATION_TEMPERATURE 3.15      // K.
#define AVERAGE_SOLAR_RADIATION      200       // W/m^2. Kind of arbitrary. Really this should depend on the sun position much like solars.
#define RADIATOR_OPTIMUM_PRESSURE    3771      // kPa at 20 C. This should be higher as gases aren't great conductors until they are dense. Used the critical pressure for air.
#define GAS_CRITICAL_TEMPERATURE     132.65    // K. The critical point temperature for air.

#define T0C  273.15					// 0degC
#define T20C 293.15					// 20degC
#define TCMB 2.73					// -270.42degC

#define QUANTIZE(variable)		(round(variable, 0.0001))

#define INFINITY 1.#INF

#define SPEED_OF_LIGHT 3e8 //not exact but hey!
#define SPEED_OF_LIGHT_SQ 9e+16

#define MELTPOINT_GLASS   (1500+T0C)
#define MELTPOINT_STEEL   (1510+T0C)
#define MELTPOINT_PLASMA (MELTPOINT_STEEL+500)
#define MELTPOINT_SILICON 1687 // KELVIN
#define MELTPOINT_PLASTIC (180+T0C)
#define MELTPOINT_SNOW	304.15	//about 30°C
#define MELTPOINT_CARBON (T0C+3550)
#define MELTPOINT_GOLD (T0C+1064)
#define MELTPOINT_SILVER (T0C+961.8)
#define MELTPOINT_URANIUM (T0C+1132)
#define MELTPOINT_POTASSIUM (T0C+63.5)
#define MELTPOINT_BRASS (T0C+940)
#define MELTPOINT_MYTHRIL (T0C+893) //Using sterling silver (because silver steel) as base

// The highest number supported is a signed 32-bit floating point number.
// Integers beyond the 24 bit range are represented as single-precision floating points, and thus will lose accuracy beyond the range of +/- 16777216
#define SHORT_REAL_LIMIT 16777216
