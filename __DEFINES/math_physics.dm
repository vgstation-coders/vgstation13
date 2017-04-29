#define PI 3.141592653

// The TRUE circle constant!
#define TAU (PI * 2)

//"fancy" math for calculating time in ms from tick_usage percentage and the length of ticks
//percent_of_tick_used * (ticklag * 100(to convert to ms)) / 100(percent ratio)
//collapsed to percent_of_tick_used * tick_lag
#define TICK_DELTA_TO_MS(percent_of_tick_used) ((percent_of_tick_used) * world.tick_lag)
#define TICK_USAGE_TO_MS(starting_tickusage) (TICK_DELTA_TO_MS(world.tick_usage-starting_tickusage))

#define R_IDEAL_GAS_EQUATION       8.31    // kPa*L/(K*mol).
#define ONE_ATMOSPHERE             101.325 // kPa.
#define IDEAL_GAS_ENTROPY_CONSTANT 1164    // (mol^3 * s^3) / (kg^3 * L).

// Radiation constants.
#define STEFAN_BOLTZMANN_CONSTANT    5.6704e-8 // W/(m^2*K^4).
#define COSMIC_RADIATION_TEMPERATURE 3.15      // K.
#define AVERAGE_SOLAR_RADIATION      200       // W/m^2. Kind of arbitrary. Really this should depend on the sun position much like solars.
#define RADIATOR_OPTIMUM_PRESSURE    3771      // kPa at 20 C. This should be higher as gases aren't great conductors until they are dense. Used the critical pressure for air.
#define GAS_CRITICAL_TEMPERATURE     132.65    // K. The critical point temperature for air.

#define RADIATOR_EXPOSED_SURFACE_AREA_RATIO 0.04 // (3 cm + 100 cm * sin(3deg))/(2*(3+100 cm)). Unitless ratio.
#define HUMAN_EXPOSED_SURFACE_AREA          5.2 //m^2, surface area of 1.7m (H) x 0.46m (D) cylinder

#define T0C  273.15 //    0.0 degrees celcius
#define T20C 293.15 //   20.0 degrees celcius
#define TCMB 2.73   // -270.3 degrees celcius

#define KELVIN  +0   // So you can write "10 KELVIN"
#define CELCIUS +T0C // So you can write "10 CELCIUS"

#define CLAMP01(x) max(0, min(1, x))
#define QUANTIZE(variable) (round(variable,0.0001))

#define INFINITY 1.#INF

#define TICKS_IN_DAY    24*60*60*10
#define TICKS_IN_SECOND 10

#define SIMPLE_SIGN(X) ((X) < 0 ? -1 : 1)
#define SIGN(X) ((X) ? SIMPLE_SIGN(X) : 0)

#define SPEED_OF_LIGHT 3e8 //not exact but hey!
#define SPEED_OF_LIGHT_SQ 9e+16

#define MELTPOINT_GLASS     1774 KELVIN
#define MELTPOINT_STEEL     1783 KELVIN
#define MELTPOINT_GOLD      1337 KELVIN
#define MELTPOINT_SILVER    1235 KELVIN
#define MELTPOINT_DIAMOND   3823 KELVIN
#define MELTPOINT_BANANIUM  696  KELVIN
#define MELTPOINT_URANIUM   1405 KELVIN
#define MELTPOINT_PLASMA    373  KELVIN
#define MELTPOINT_PLASTEEL  0 // Cannot melt.
#define MELTPOINT_SILICON   1686 KELVIN
#define MELTPOINT_PLASTIC   453  KELVIN
#define MELTPOINT_SNOW      304  KELVIN