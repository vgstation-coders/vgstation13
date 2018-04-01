//LISTMOS
//indices of values in gas lists.
#define MOLES			1
#define ARCHIVE			2
#define GAS_META		3
#define META_GAS_SPECIFIC_HEAT	1
#define META_GAS_NAME			2
#define META_GAS_MOLES_VISIBLE	3
#define META_GAS_OVERLAY		4
#define META_GAS_DANGER			5
#define META_GAS_ID				6

//ATMOS
//stuff you should probably leave well alone!
#define R_IDEAL_GAS_EQUATION	8.31	//kPa*L/(K*mol)
#define ONE_ATMOSPHERE			101.325	//kPa
#define TCMB					2.7		// -270.3degC
#define TCRYO					225		// -48.15degC
#define T0C						273.15	// 0degC
#define T20C					293.15	// 20degC

#define MOLES_CELLSTANDARD		(ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))	//moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC
#define M_CELL_WITH_RATIO		(MOLES_CELLSTANDARD * 0.005) //compared against for superconductivity
#define O2STANDARD				0.21	//percentage of oxygen in a normal mixture of air
#define N2STANDARD				0.79	//same but for nitrogen
#define MOLES_O2STANDARD		(MOLES_CELLSTANDARD*O2STANDARD)	// O2 standard value (21%)
#define MOLES_N2STANDARD		(MOLES_CELLSTANDARD*N2STANDARD)	// N2 standard value (79%)
#define CELL_VOLUME				2500	//liters in a cell
#define BREATH_VOLUME			0.5		//liters in a normal breath
#define BREATH_PERCENTAGE		(BREATH_VOLUME/CELL_VOLUME)					//Amount of air to take a from a tile

//EXCITED GROUPS
#define EXCITED_GROUP_BREAKDOWN_CYCLES				4		//number of FULL air controller ticks before an excited group breaks down (averages gas contents across turfs)
#define EXCITED_GROUP_DISMANTLE_CYCLES				16		//number of FULL air controller ticks before an excited group dismantles and removes its turfs from active
#define MINIMUM_AIR_RATIO_TO_SUSPEND				0.1		//Ratio of air that must move to/from a tile to reset group processing
#define MINIMUM_AIR_RATIO_TO_MOVE					0.001	//Minimum ratio of air that must move to/from a tile
#define MINIMUM_AIR_TO_SUSPEND						(MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND)	//Minimum amount of air that has to move before a group processing can be suspended
#define MINIMUM_MOLES_DELTA_TO_MOVE					(MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_MOVE) //Either this must be active
#define MINIMUM_TEMPERATURE_TO_MOVE					(T20C+100)			//or this (or both, obviously)
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND		4		//Minimum temperature difference before group processing is suspended
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER		0.5		//Minimum temperature difference before the gas temperatures are just set to be equal
#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION		T20C+10
#define MINIMUM_TEMPERATURE_START_SUPERCONDUCTION	T20C+200

//HEAT TRANSFER COEFFICIENTS
//Must be between 0 and 1. Values closer to 1 equalize temperature faster
//Should not exceed 0.4 else strange heat flow occur
#define WALL_HEAT_TRANSFER_COEFFICIENT		0.0
#define OPEN_HEAT_TRANSFER_COEFFICIENT		0.4
#define WINDOW_HEAT_TRANSFER_COEFFICIENT	0.1		//a hack for now
#define HEAT_CAPACITY_VACUUM				7000	//a hack to help make vacuums "cold", sacrificing realism for gameplay

//FIRE
#define FIRE_MINIMUM_TEMPERATURE_TO_SPREAD	150+T0C
#define FIRE_MINIMUM_TEMPERATURE_TO_EXIST	100+T0C
#define FIRE_SPREAD_RADIOSITY_SCALE			0.85
#define FIRE_GROWTH_RATE					40000	//For small fires
#define PLASMA_MINIMUM_BURN_TEMPERATURE		100+T0C

//GASES
#define MIN_TOXIC_GAS_DAMAGE				1
#define MAX_TOXIC_GAS_DAMAGE				10
#define MOLES_GAS_VISIBLE					0.5		//Moles in a standard cell after which gases are visible

//REACTIONS
//return values for reactions (bitflags)
#define NO_REACTION		0
#define REACTING		1
#define STOP_REACTIONS 	2

// Pressure limits.
#define HAZARD_HIGH_PRESSURE				550		//This determins at what pressure the ultra-high pressure red icon is displayed. (This one is set as a constant)
#define WARNING_HIGH_PRESSURE				325		//This determins when the orange pressure icon is displayed (it is 0.7 * HAZARD_HIGH_PRESSURE)
#define WARNING_LOW_PRESSURE				50		//This is when the gray low pressure icon is displayed. (it is 2.5 * HAZARD_LOW_PRESSURE)
#define HAZARD_LOW_PRESSURE					20		//This is when the black ultra-low pressure icon is displayed. (This one is set as a constant)

#define TEMPERATURE_DAMAGE_COEFFICIENT		1.5		//This is used in handle_temperature_damage() for humans, and in reagents that affect body temperature. Temperature damage is multiplied by this amount.

#define BODYTEMP_NORMAL						310.15			//The natural temperature for a body
#define BODYTEMP_AUTORECOVERY_DIVISOR		11		//This is the divisor which handles how much of the temperature difference between the current body temperature and 310.15K (optimal temperature) humans auto-regenerate each tick. The higher the number, the slower the recovery. This is applied each tick, so long as the mob is alive.
#define BODYTEMP_AUTORECOVERY_MINIMUM		12		//Minimum amount of kelvin moved toward 310K per tick. So long as abs(310.15 - bodytemp) is more than 50.
#define BODYTEMP_COLD_DIVISOR				6		//Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is lower than their body temperature. Make it lower to lose bodytemp faster.
#define BODYTEMP_HEAT_DIVISOR				15		//Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is higher than their body temperature. Make it lower to gain bodytemp faster.
#define BODYTEMP_COOLING_MAX				-100		//The maximum number of degrees that your body can cool in 1 tick, due to the environment, when in a cold area.
#define BODYTEMP_HEATING_MAX				30		//The maximum number of degrees that your body can heat up in 1 tick, due to the environment, when in a hot area.

#define BODYTEMP_HEAT_DAMAGE_LIMIT			(BODYTEMP_NORMAL + 50) // The limit the human body can take before it starts taking damage from heat.
#define BODYTEMP_COLD_DAMAGE_LIMIT			(BODYTEMP_NORMAL - 50) // The limit the human body can take before it starts taking damage from coldness.


#define SPACE_HELM_MIN_TEMP_PROTECT			2.0		//what min_cold_protection_temperature is set to for space-helmet quality headwear. MUST NOT BE 0.
#define SPACE_HELM_MAX_TEMP_PROTECT			1500	//Thermal insulation works both ways /Malkevin
#define SPACE_SUIT_MIN_TEMP_PROTECT			2.0		//what min_cold_protection_temperature is set to for space-suit quality jumpsuits or suits. MUST NOT BE 0.
#define SPACE_SUIT_MAX_TEMP_PROTECT			1500

#define FIRE_SUIT_MIN_TEMP_PROTECT			60		//Cold protection for firesuits
#define FIRE_SUIT_MAX_TEMP_PROTECT			30000	//what max_heat_protection_temperature is set to for firesuit quality suits. MUST NOT BE 0.
#define FIRE_HELM_MIN_TEMP_PROTECT			60		//Cold protection for fire helmets
#define FIRE_HELM_MAX_TEMP_PROTECT			30000	//for fire helmet quality items (red and white hardhats)

#define FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT	35000	//what max_heat_protection_temperature is set to for firesuit quality suits. MUST NOT BE 0.
#define FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT	35000	//for fire helmet quality items (red and white hardhats)

#define HELMET_MIN_TEMP_PROTECT				160		//For normal helmets
#define HELMET_MAX_TEMP_PROTECT				600		//For normal helmets
#define ARMOR_MIN_TEMP_PROTECT				160		//For armor
#define ARMOR_MAX_TEMP_PROTECT				600		//For armor

#define GLOVES_MIN_TEMP_PROTECT				2.0		//For some gloves (black and)
#define GLOVES_MAX_TEMP_PROTECT				1500	//For some gloves
#define SHOES_MIN_TEMP_PROTECT				2.0		//For gloves
#define SHOES_MAX_TEMP_PROTECT				1500	//For gloves

#define PRESSURE_DAMAGE_COEFFICIENT			4		//The amount of pressure damage someone takes is equal to (pressure / HAZARD_HIGH_PRESSURE)*PRESSURE_DAMAGE_COEFFICIENT, with the maximum of MAX_PRESSURE_DAMAGE
#define MAX_HIGH_PRESSURE_DAMAGE			4
#define LOW_PRESSURE_DAMAGE					4		//The amount of damage someone takes when in a low pressure area (The pressure threshold is so low that it doesn't make sense to do any calculations, so it just applies this flat value).

#define COLD_SLOWDOWN_FACTOR				20		//Humans are slowed by the difference between bodytemp and BODYTEMP_COLD_DAMAGE_LIMIT divided by this

//PIPES
//Atmos pipe limits
#define MAX_OUTPUT_PRESSURE					4500 // (kPa) What pressure pumps and powered equipment max out at.
#define MAX_TRANSFER_RATE					200 // (L/s) Maximum speed powered equipment can work at.

//used for device_type vars
#define UNARY		1
#define BINARY 		2
#define TRINARY		3
#define QUATERNARY	4

//TANKS
#define TANK_MELT_TEMPERATURE				1000000	//temperature in kelvins at which a tank will start to melt
#define TANK_LEAK_PRESSURE					(30.*ONE_ATMOSPHERE)	//Tank starts leaking
#define TANK_RUPTURE_PRESSURE				(35.*ONE_ATMOSPHERE)	//Tank spills all contents into atmosphere
#define TANK_FRAGMENT_PRESSURE				(40.*ONE_ATMOSPHERE)	//Boom 3x3 base explosion
#define TANK_FRAGMENT_SCALE	    			(6.*ONE_ATMOSPHERE)		//+1 for each SCALE kPa aboe threshold
#define TANK_MAX_RELEASE_PRESSURE 			(ONE_ATMOSPHERE*3)
#define TANK_MIN_RELEASE_PRESSURE 			0
#define TANK_DEFAULT_RELEASE_PRESSURE 		16

//CANATMOSPASS
#define ATMOS_PASS_YES 1
#define ATMOS_PASS_NO 0
#define ATMOS_PASS_PROC -1 //ask CanAtmosPass()
#define ATMOS_PASS_DENSITY -2 //just check density
#define CANATMOSPASS(A, O) ( A.CanAtmosPass == ATMOS_PASS_PROC ? A.CanAtmosPass(O) : ( A.CanAtmosPass == ATMOS_PASS_DENSITY ? !A.density : A.CanAtmosPass ) )

//LAVALAND
#define LAVALAND_EQUIPMENT_EFFECT_PRESSURE 50 //what pressure you have to be under to increase the effect of equipment meant for lavaland
#define LAVALAND_DEFAULT_ATMOS "o2=14;n2=23;TEMP=300"

//ATMOSIA GAS MONITOR TAGS
#define ATMOS_GAS_MONITOR_INPUT_O2 "o2_in"
#define ATMOS_GAS_MONITOR_OUTPUT_O2 "o2_out"
#define ATMOS_GAS_MONITOR_SENSOR_O2 "o2_sensor"

#define ATMOS_GAS_MONITOR_INPUT_TOX "tox_in"
#define ATMOS_GAS_MONITOR_OUTPUT_TOX "tox_out"
#define ATMOS_GAS_MONITOR_SENSOR_TOX "tox_sensor"

#define ATMOS_GAS_MONITOR_INPUT_AIR "air_in"
#define ATMOS_GAS_MONITOR_OUTPUT_AIR "air_out"
#define ATMOS_GAS_MONITOR_SENSOR_AIR "air_sensor"

#define ATMOS_GAS_MONITOR_INPUT_MIX "mix_in"
#define ATMOS_GAS_MONITOR_OUTPUT_MIX "mix_out"
#define ATMOS_GAS_MONITOR_SENSOR_MIX "mix_sensor"

#define ATMOS_GAS_MONITOR_INPUT_N2O "n2o_in"
#define ATMOS_GAS_MONITOR_OUTPUT_N2O "n2o_out"
#define ATMOS_GAS_MONITOR_SENSOR_N2O "n2o_sensor"

#define ATMOS_GAS_MONITOR_INPUT_N2 "n2_in"
#define ATMOS_GAS_MONITOR_OUTPUT_N2 "n2_out"
#define ATMOS_GAS_MONITOR_SENSOR_N2 "n2_sensor"

#define ATMOS_GAS_MONITOR_INPUT_CO2 "co2_in"
#define ATMOS_GAS_MONITOR_OUTPUT_CO2 "co2_out"
#define ATMOS_GAS_MONITOR_SENSOR_CO2 "co2_sensor"

#define ATMOS_GAS_MONITOR_INPUT_INCINERATOR "incinerator_in"
#define ATMOS_GAS_MONITOR_OUTPUT_INCINERATOR "incinerator_out"
#define ATMOS_GAS_MONITOR_SENSOR_INCINERATOR "incinerator_sensor"

#define ATMOS_GAS_MONITOR_INPUT_TOXINS_LAB "toxinslab_in"
#define ATMOS_GAS_MONITOR_OUTPUT_TOXINS_LAB "toxinslab_out"
#define ATMOS_GAS_MONITOR_SENSOR_TOXINS_LAB "toxinslab_sensor"

#define ATMOS_GAS_MONITOR_LOOP_DISTRIBUTION "distro-loop_meter"
#define ATMOS_GAS_MONITOR_LOOP_ATMOS_WASTE "atmos-waste_loop_meter"

#define ATMOS_GAS_MONITOR_WASTE_ENGINE "engine-waste_out"
#define ATMOS_GAS_MONITOR_WASTE_ATMOS "atmos-waste_out"

//MULTIPIPES
//IF YOU EVER CHANGE THESE CHANGE SPRITES TO MATCH.
#define PIPING_LAYER_MIN 1
#define PIPING_LAYER_MAX 3
#define PIPING_LAYER_DEFAULT 2
#define PIPING_LAYER_P_X 5
#define PIPING_LAYER_P_Y 5
#define PIPING_LAYER_LCHANGE 0.05

#define PIPING_ALL_LAYER 1					//intended to connect with all layers, check for all instead of just one.
#define PIPING_ONE_PER_TURF 2 				//can only be built if nothing else with this flag is on the tile already.
#define PIPING_DEFAULT_LAYER_ONLY 4			//can only exist at PIPING_LAYER_DEFAULT
#define PIPING_CARDINAL_AUTONORMALIZE 8		//north/south east/west doesn't matter, auto normalize on build.

//HELPERS
#define THERMAL_ENERGY(gas) (gas.temperature * gas.heat_capacity())

#define ADD_GAS(gas_id, out_list)\
	var/list/tmp_gaslist = GLOB.gaslist_cache[gas_id]; out_list[gas_id] = tmp_gaslist.Copy();

#define ASSERT_GAS(gas_id, gas_mixture) if (!gas_mixture.gases[gas_id]) { ADD_GAS(gas_id, gas_mixture.gases) };

GLOBAL_LIST_INIT(pipe_paint_colors, list(
		"Amethyst" = rgb(130,43,255), //supplymain
		"Blue" = rgb(0,0,255),
		"Brown" = rgb(178,100,56),
		"Cyan" = rgb(0,255,249),
		"Dark" = rgb(69,69,69),
		"Green" = rgb(30,255,0),
		"Grey" = rgb(255,255,255),
		"Orange" = rgb(255,129,25),
		"Purple" = rgb(128,0,182),
		"Red" = rgb(255,0,0),
		"Violet" = rgb(64,0,128),
		"Yellow" = rgb(255,198,0)
		))
