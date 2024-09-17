////////////////////////////////////////
//CONTAINS: Air Alarms and Fire Alarms//
////////////////////////////////////////

#define AALARM_MODE_SCRUBBING	1
#define AALARM_MODE_REPLACEMENT	2 //like scrubbing, but faster.
#define AALARM_MODE_PANIC		3 //constantly sucks all air
#define AALARM_MODE_CYCLE		4 //sucks off all air, then refill and switches to scrubbing
#define AALARM_MODE_FILL		5 //emergency fill
#define AALARM_MODE_OFF			6 //Shuts it all down.

#define AALARM_SCREEN_MAIN		1
#define AALARM_SCREEN_VENT		2
#define AALARM_SCREEN_SCRUB		3
#define AALARM_SCREEN_MODE		4
#define AALARM_SCREEN_SENSORS	5

#define AALARM_REPORT_TIMEOUT 100

#define RCON_NO		1
#define RCON_YES	2
#define RCON_AUTO	3 //unused

//10,000 joules equates to about 17,000 Btu/h, which is roughly equivalent to a moderately-sized conventional AC unit
//it's also conveniently 10 times what this used to be.
//1000 joules equates to about 1 degree every 2 seconds for a single tile of air.
#define MAX_ENERGY_CHANGE 10000

//min and max temperature that we can heat or cool to, does not affect target temperature
#define MAX_TEMPERATURE T0C+90
#define MIN_TEMPERATURE T0C-40
//maximum target temperature, we can't actually heat up/cool down to these but if things go above/below we'll start cooling/heating.
//copied from the freezer and the heater for now
#define MAX_TARGET_TEMPERATURE T0C + 300
#define MIN_TARGET_TEMPERATURE T0C - 200

//all air alarms in area are connected via magic
/area
	var/obj/machinery/alarm/master_air_alarm
	var/list/air_vent_names = list()
	var/list/air_scrub_names = list()
	var/list/air_vent_info = list()
	var/list/air_scrub_info = list()


// This class represents two bounds which represent the danger level of a certain value.
// Min_1 and Max_1 define a range in which the value is safe (danger level 0). If a value lies outside this range, then a danger level of 1 is given.
// Min_2 and Max_2 define a strictly larger range that encompasses both Min_1 and Max_1. If the value lies outside this range, then a danger level of 2 is given.
// If all values are -1, then it will always return a danger level of 0.
/datum/airalarm_threshold
	var/list/raw_values = list(0,0,0,0)

/datum/airalarm_threshold/New(var/min_2, var/min_1, var/max_1, var/max_2)
	raw_values = list(min_2, min_1, max_1, max_2)

/datum/airalarm_threshold/proc/min_2()
	return raw_values[1]
/datum/airalarm_threshold/proc/min_1()
	return raw_values[2]
/datum/airalarm_threshold/proc/max_1()
	return raw_values[3]
/datum/airalarm_threshold/proc/max_2()
	return raw_values[4]

/datum/airalarm_threshold/proc/assess_danger(var/input)
	// This should probably be a flag or something but I'm too lazy to change it from how it was before.
	if( raw_values[1] == -1 && raw_values[2] == -1 && raw_values[3] == -1 && raw_values[4] == -1 )
		return 0
	if ((raw_values[4] != -1 && input >= raw_values[4]) || (raw_values[1] != -1 && input <= raw_values[1]))
		return 2
	if ((raw_values[3] != -1 && input >= raw_values[3]) || (raw_values[2] != -1 && input <= raw_values[2]))
		return 1
	return 0

/datum/airalarm_threshold/proc/adjust_min2(var/input, var/raw_location)
	adjust_threshold(input, 1)
/datum/airalarm_threshold/proc/adjust_min1(var/input, var/raw_location)
	adjust_threshold(input, 2)
/datum/airalarm_threshold/proc/adjust_max1(var/input, var/raw_location)
	adjust_threshold(input, 3)
/datum/airalarm_threshold/proc/adjust_max2(var/input, var/raw_location)
	adjust_threshold(input, 4)

/datum/airalarm_threshold/proc/adjust_threshold(var/input, var/raw_location)
	raw_values[raw_location] = input
	if(input != -1)
		for(var/i = 1; i <= 4; i++)
			if(raw_values[i] != -1 && ((i < raw_location && raw_values[i] > input) || (i > raw_location && raw_values[i] < input)))
				raw_values[i] = input

/datum/airalarm_threshold/proc/get_index(var/index)
	return raw_values[index]

/datum/airalarm_threshold/proc/deep_copy()
	return new /datum/airalarm_threshold(min_2(), min_1(), max_1(), max_2())




// This datum represents the current configured values of an air alarm including values such as warning thresholds.
/datum/airalarm_configuration
	// Partial pressure, kpa thresholds for each gas. If a gas is not included in here, it will be lumped into "other gases".
	var/list/gas_thresholds = list( GAS_OXYGEN = new /datum/airalarm_threshold(-1, -1, -1, -1),
									GAS_NITROGEN = new /datum/airalarm_threshold(-1, -1, -1, -1),
									GAS_CARBON = new /datum/airalarm_threshold(-1, -1, -1, -1),
									GAS_PLASMA = new /datum/airalarm_threshold(-1, -1, -1, -1),
									GAS_SLEEPING = new /datum/airalarm_threshold(-1, -1, -1, -1),
									GAS_CRYOTHEUM = new /datum/airalarm_threshold(-1, -1, -1, -1) )
	// Partial pressure, kpa threshold for any gas not included in gas_thresholds. These gasses are added up.
	var/datum/airalarm_threshold/other_gas_threshold = new /datum/airalarm_threshold(-1, -1, -1, -1)
	// Kpa thresholds for what pressures are acceptable.
	var/datum/airalarm_threshold/pressure_threshold = new /datum/airalarm_threshold(-1, -1, -1, -1)
	// Thresholds in kelvin for what temperatures are acceptable.
	var/datum/airalarm_threshold/temperature_threshold = new /datum/airalarm_threshold(-1, -1, -1, -1)
	// Target temperature this preset is trying to achieve.
	var/target_temperature = T0C+20
	// What gasses are scrubbed on this preset.
	var/list/scrubbed_gases = list()
	// Automatically switch to the fire suppression preset when a fire is detected.
	var/suppression_mode = FALSE

/datum/airalarm_configuration/proc/deep_config_copy()
	var/datum/airalarm_configuration/to_return = new /datum/airalarm_configuration()
	to_return.gas_thresholds = list()
	for(var/gas_id in gas_thresholds)
		var/datum/airalarm_threshold/our_threshold = gas_thresholds[gas_id]
		to_return.gas_thresholds[gas_id] = our_threshold.deep_copy()
	to_return.temperature_threshold = temperature_threshold.deep_copy()
	to_return.other_gas_threshold = other_gas_threshold.deep_copy()
	to_return.pressure_threshold = pressure_threshold.deep_copy()
	to_return.target_temperature = target_temperature
	to_return.scrubbed_gases = scrubbed_gases.Copy()
	return to_return

// Returns this configuration formatted as a string->data list for use in nanoUI. Please do not use this anywhere else.
/datum/airalarm_configuration/proc/nanoui_config_data()
	var/data[0]
	var/list/noteworthy_gas_thresholds = list()
	for(var/gas_id in gas_thresholds)
		var/datum/airalarm_threshold/threshold = gas_thresholds[gas_id]
		var/datum/gas/target_gas = XGM.gases[gas_id]
		// Reason for this is complicated, but tl;dr nanoui doesn't support nested for loops so we do this.
		var/list/raw_values_formatted = list()
		raw_values_formatted["min2"] = threshold.min_2()
		raw_values_formatted["min1"] = threshold.min_1()
		raw_values_formatted["max1"] = threshold.max_1()
		raw_values_formatted["max2"] = threshold.max_2()
		noteworthy_gas_thresholds += list(list("raw_values" = raw_values_formatted, "name" = target_gas.name, "id" = gas_id))
	data["noteworthy_thresholds"] = noteworthy_gas_thresholds
	data["other_threshold"] = other_gas_threshold.raw_values
	data["pressure_threshold"] = pressure_threshold.raw_values
	data["temperature_threshold"] = temperature_threshold.raw_values
	data["target_temperature"] = target_temperature
	data["scrubbed_gases"] = scrubbed_gases
	data["suppression_mode"] = suppression_mode
	return data




// A preset representing an airalarm_configuration with certain values, as well other identifiers like a name to help selection of a preset.
/datum/airalarm_configuration/preset
	var/name = null
	var/desc = null
	// Whether this is a stock preset that cannot be deleted
	var/core = FALSE

/datum/airalarm_configuration/preset/proc/deep_preset_copy()
	var/datum/airalarm_configuration/preset/to_return = new /datum/airalarm_configuration/preset()
	to_return.name = name
	to_return.desc = desc
	to_return.core = core
	to_return.gas_thresholds = list()
	for(var/gas_id in gas_thresholds)
		var/datum/airalarm_threshold/our_threshold = gas_thresholds[gas_id]
		to_return.gas_thresholds[gas_id] = our_threshold.deep_copy()
	to_return.temperature_threshold = temperature_threshold.deep_copy()
	to_return.other_gas_threshold = other_gas_threshold.deep_copy()
	to_return.pressure_threshold = pressure_threshold.deep_copy()
	to_return.target_temperature = target_temperature
	to_return.scrubbed_gases = scrubbed_gases.Copy()
	return to_return

/datum/airalarm_configuration/preset/proc/nanoui_preset_data()
	var/data = nanoui_config_data()
	data["name"] = name
	data["desc"] = desc
	data["core"] = core
	return data

/datum/airalarm_configuration/preset/human //For humans
	name = "Human"
	desc = "Permits oxygen and nitrogen."
	core = TRUE
	gas_thresholds = list( 	GAS_OXYGEN = new /datum/airalarm_threshold(16, 18, 135, 140),
							GAS_NITROGEN = new /datum/airalarm_threshold(-1, -1, -1, -1),
							GAS_CARBON = new /datum/airalarm_threshold(-1, -1, 5, 10),
							GAS_PLASMA = new /datum/airalarm_threshold(-1, -1, 0.2, 0.5),
							GAS_SLEEPING = new /datum/airalarm_threshold(-1, -1, 0.5, 1),
							GAS_CRYOTHEUM = new /datum/airalarm_threshold(-1, -1, 0.5, 1) )
	other_gas_threshold = new /datum/airalarm_threshold(-1, -1, 0.5, 1)
	pressure_threshold = new /datum/airalarm_threshold(ONE_ATMOSPHERE*0.80, ONE_ATMOSPHERE*0.90, ONE_ATMOSPHERE*1.10, ONE_ATMOSPHERE*1.20)
	temperature_threshold = new /datum/airalarm_threshold(T0C-30, T0C, T0C+40, T0C+70)
	target_temperature = T0C+20
	scrubbed_gases = list( GAS_CARBON, GAS_PLASMA )

/datum/airalarm_configuration/preset/vox //For vox
	name = "Vox"
	desc = "Permits nitrogen only."
	core = TRUE
	gas_thresholds = list( 	GAS_OXYGEN = new /datum/airalarm_threshold(-1, -1, 0.5, 1),
							GAS_NITROGEN = new /datum/airalarm_threshold(16, 18, 135, 140),
							GAS_CARBON = new /datum/airalarm_threshold(-1, -1, 5, 10),
							GAS_PLASMA = new /datum/airalarm_threshold(-1, -1, 0.2, 0.5),
							GAS_SLEEPING = new /datum/airalarm_threshold(-1, -1, 0.5, 1),
							GAS_CRYOTHEUM = new /datum/airalarm_threshold(-1, -1, 0.5, 1) )
	other_gas_threshold = new /datum/airalarm_threshold(-1, -1, 0.5, 1)
	pressure_threshold = new /datum/airalarm_threshold(ONE_ATMOSPHERE*0.80, ONE_ATMOSPHERE*0.90, ONE_ATMOSPHERE*1.10, ONE_ATMOSPHERE*1.20)
	temperature_threshold = new /datum/airalarm_threshold(T0C-30, T0C, T0C+40, T0C+70)
	target_temperature = T0C+20
	scrubbed_gases = list( GAS_OXYGEN, GAS_CARBON, GAS_PLASMA )

/datum/airalarm_configuration/preset/coldroom //Server rooms etc.
	name = "Coldroom"
	desc = "For server rooms and freezers."
	core = TRUE
	gas_thresholds = list( 	GAS_OXYGEN = new /datum/airalarm_threshold(-1, -1, -1, -1),
							GAS_NITROGEN = new /datum/airalarm_threshold(-1, -1, -1, -1),
							GAS_CARBON = new /datum/airalarm_threshold(-1, -1, 5, 10),
							GAS_PLASMA = new /datum/airalarm_threshold(-1, -1, 0.2, 0.5),
							GAS_SLEEPING = new /datum/airalarm_threshold(-1, -1, 0.5, 1),
							GAS_CRYOTHEUM = new /datum/airalarm_threshold(-1, -1, 0.5, 1) )
	other_gas_threshold = new /datum/airalarm_threshold(-1, -1, 0.5, 1)
	pressure_threshold = new /datum/airalarm_threshold(-1, ONE_ATMOSPHERE*0.10, ONE_ATMOSPHERE*1.90, ONE_ATMOSPHERE*2.3)
	temperature_threshold = new /datum/airalarm_threshold(20, 40, 140, 160)
	target_temperature = 90
	scrubbed_gases = list( GAS_OXYGEN, GAS_CARBON, GAS_PLASMA )

/datum/airalarm_configuration/preset/plasmaman //HONK
	name = "Plasmaman"
	desc = "Permits plasma and nitrogen only."
	core = TRUE
	gas_thresholds = list( 	GAS_OXYGEN = new /datum/airalarm_threshold(-1, -1, 0.5, 1),
							GAS_NITROGEN = new /datum/airalarm_threshold(-1, -1, -1, -1),
							GAS_CARBON = new /datum/airalarm_threshold(-1, -1, 5, 10),
							GAS_PLASMA = new /datum/airalarm_threshold(16, 18, 135, 140),
							GAS_SLEEPING = new /datum/airalarm_threshold(-1, -1, 0.5, 1),
							GAS_CRYOTHEUM = new /datum/airalarm_threshold(-1, -1, 0.5, 1) )
	other_gas_threshold = new /datum/airalarm_threshold(-1, -1, 0.5, 1)
	pressure_threshold = new /datum/airalarm_threshold(ONE_ATMOSPHERE*0.80, ONE_ATMOSPHERE*0.90, ONE_ATMOSPHERE*1.10, ONE_ATMOSPHERE*1.20)
	temperature_threshold = new /datum/airalarm_threshold(T0C-30, T0C, T0C+40, T0C+70)
	target_temperature = T0C+20
	scrubbed_gases = list( GAS_OXYGEN, GAS_NITROGEN, GAS_CARBON )

/datum/airalarm_configuration/preset/vacuum
	name = "Vacuum"
	desc = "For rooms to be kept under vacuum."
	core = TRUE
	gas_thresholds = list( 	GAS_OXYGEN = new /datum/airalarm_threshold(-1, -1, 0.5, 1),
							GAS_NITROGEN = new /datum/airalarm_threshold(-1, -1, 0.5, 1),
							GAS_CARBON = new /datum/airalarm_threshold(-1, -1, 0.5, 1),
							GAS_PLASMA = new /datum/airalarm_threshold(-1, -1, 0.5, 1),
							GAS_SLEEPING = new /datum/airalarm_threshold(-1, -1, 0.5, 1),
							GAS_CRYOTHEUM = new /datum/airalarm_threshold(-1, -1, 0.5, 1) )
	other_gas_threshold = new /datum/airalarm_threshold(-1, -1, 0.5, 1)
	pressure_threshold = new /datum/airalarm_threshold(-1, -1, ONE_ATMOSPHERE*0.01, ONE_ATMOSPHERE*0.05)
	temperature_threshold = new /datum/airalarm_threshold(-1, -1, -1, -1)
	target_temperature = T0C+20
	scrubbed_gases = list( GAS_OXYGEN, GAS_NITROGEN, GAS_CARBON, GAS_PLASMA, GAS_SLEEPING, GAS_CRYOTHEUM )

/datum/airalarm_configuration/preset/fire_suppression
	name = "Fire Suppression"
	desc = "Replaces combustible gasses with inert gasses."
	core = TRUE
	gas_thresholds = list( 	GAS_OXYGEN = new /datum/airalarm_threshold(-1, -1, 0.2, 0.5),
							GAS_NITROGEN = new /datum/airalarm_threshold(16, 18, 135, 140),
							GAS_CARBON = new /datum/airalarm_threshold(-1, -1, -1, -1),
							GAS_PLASMA = new /datum/airalarm_threshold(-1, -1, 0.2, 0.5),
							GAS_SLEEPING = new /datum/airalarm_threshold(-1, -1, -1, -1),
							GAS_CRYOTHEUM = new /datum/airalarm_threshold(-1, -1, -1, -1) )
	other_gas_threshold = new /datum/airalarm_threshold(-1, -1, 0.5, 1)
	pressure_threshold = new /datum/airalarm_threshold(-1, -1, -1, -1)
	temperature_threshold = new /datum/airalarm_threshold(T0C-50, T0C-25, T0C+25, T0C+50)
	target_temperature = T0C
	scrubbed_gases = list( GAS_OXYGEN, GAS_PLASMA )

//these are used for the UIs and new ones can be added and existing ones edited at the CAC
var/global/list/airalarm_presets = list(
	"Human" = new /datum/airalarm_configuration/preset/human,
	"Vox" = new /datum/airalarm_configuration/preset/vox,
	"Coldroom" = new /datum/airalarm_configuration/preset/coldroom,
	"Plasmaman" = new /datum/airalarm_configuration/preset/plasmaman,
	"Vacuum" = new /datum/airalarm_configuration/preset/vacuum,
	"Fire Suppression" = new /datum/airalarm_configuration/preset/fire_suppression,
)
var/global/list/air_alarms = list()





/obj/machinery/alarm
	desc = "An alarm used to control the area's atmospherics systems."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm0"
	anchored = 1
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 100
	active_power_usage = 200
	power_channel = ENVIRON
	req_one_access = list(access_atmospherics, access_engine_minor)
	var/frequency = 1439
	//var/skipprocess = 0 //Experimenting
	var/alarm_frequency = 1437
	var/remote_control = 1
	var/rcon_setting = RCON_YES
	var/rcon_time = 0
	var/locked = 1
	var/datum/wires/alarm/wires = null
	var/wiresexposed = 0 // If it's been screwdrivered open.
	var/AAlarmwires = 31
	var/shorted = 0

	var/mode = AALARM_MODE_SCRUBBING
	var/screen = AALARM_SCREEN_MAIN
	var/area_uid
	var/local_danger_level = 0
	var/alarmActivated = 0 // Manually activated (independent from danger level)
	var/danger_averted_confidence=0
	var/buildstage = 2 //2 is built, 1 is building, 0 is frame.
	var/cycle_after_preset = 1 // Whether we automatically cycle when presets are changed

	var/target_temperature //Manual override for target temperature changing, usable for maps/admin vv edits
	var/regulating_temperature = 0

	var/datum/radio_frequency/radio_connection

	var/preset_key = "Human"
	var/datum/airalarm_configuration/config

	machine_flags = WIREJACK

	var/auto_suppress = FALSE //automatically switch to the fire suppression preset when a fire is detected

/obj/machinery/alarm/xenobio
	req_one_access = list(access_rd, access_atmospherics, access_engine_minor, access_xenobiology)
	req_access = list()

/obj/machinery/alarm/execution
	req_one_access = list(access_atmospherics, access_engine_minor, access_brig)
	req_access = list()

/obj/machinery/alarm/server
	preset_key = "Coldroom"
	req_one_access = list(access_rd, access_atmospherics, access_engine_minor)
	req_access = list()

/obj/machinery/alarm/vox
	preset_key = "Vox"
	req_one_access = list()
	req_access = list(access_trade)

/obj/machinery/alarm/vacuum
	preset_key = "Vacuum"

/obj/machinery/alarm/New(var/loc, var/dir, var/building = 0)
	..()
	wires = new(src)

	if(building)
		if(loc)
			src.forceMove(loc)

		if(dir)
			src.dir = dir

		buildstage = 0
		wiresexposed = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 * PIXEL_MULTIPLIER : 24 * PIXEL_MULTIPLIER)
		pixel_y = (dir & 3)? (dir ==1 ? -24 * PIXEL_MULTIPLIER: 24 * PIXEL_MULTIPLIER) : 0
		update_icon()
		if(ticker && ticker.current_state == 3)//if the game is running
			src.initialize()
		return

	first_run()
	update_icon()

/obj/machinery/alarm/Destroy()
	if(wires)
		QDEL_NULL(wires)
	for(var/obj/machinery/computer/atmoscontrol/AC in atmos_controllers)
		if(AC.current == src)
			AC.current = null
			nanomanager.update_uis(src)
	var/area/this_area = get_area(src)
	if(src in this_area.air_alarms)
		this_area.air_alarms.Remove(src)
	air_alarms -= src
	..()

/obj/machinery/alarm/proc/apply_preset(var/no_cycle_after=0, var/propagate=1)
	if(airalarm_presets[preset_key])
		var/datum/airalarm_configuration/preset/preset = airalarm_presets[preset_key]
		config = preset.deep_config_copy()
	else
		config = new /datum/airalarm_configuration/preset/human()
	if(!no_cycle_after)
		mode = AALARM_MODE_CYCLE
	// Propagate settings.
	if(propagate)
		var/area/this_area = get_area(src)
		for (var/obj/machinery/alarm/AA in this_area)
			if ( !(AA.stat & (NOPOWER|BROKEN|FORCEDISABLE)) && !AA.shorted)
				AA.preset_key=preset_key
				AA.apply_preset(1, 0) // Only this air alarm should send a cycle.
		apply_mode() //reapply this to update scrubbers and other things

/obj/machinery/alarm/Entered(atom/movable/Obj, atom/OldLoc)
	var/area/old_area = get_area(OldLoc)
	var/area/new_area = get_area(Obj)
	if(old_area != new_area)
		old_area.air_alarms.Remove(src)
		new_area.air_alarms.Add(src)
	return ..()

/obj/machinery/alarm/initialize()
	add_self_to_holomap()
	set_frequency(frequency)
	if (!master_is_operating())
		elect_master()

/obj/machinery/alarm/process()
	if((stat & (NOPOWER|BROKEN|FORCEDISABLE)) || shorted || buildstage != 2)
		use_power = MACHINE_POWER_USE_NONE
		return

	var/turf/simulated/location = loc
	if(!istype(location))
		return//returns if loc is not simulated

	if(!isnull(target_temperature))
		set_temperature(target_temperature, FALSE)
		target_temperature = null

	var/datum/gas_mixture/environment = location.return_air()

	// Handle temperature adjustment here.
	if(environment.temperature < config.target_temperature - 2 || environment.temperature > config.target_temperature  + 2 || regulating_temperature)
		//If it goes too far, we should adjust ourselves back before stopping.
		var/actual_target_temperature = config.target_temperature
		if(config.temperature_threshold.assess_danger(actual_target_temperature))
			//use the max or min safe temperature
			actual_target_temperature = clamp(actual_target_temperature, config.temperature_threshold.min_1(), config.temperature_threshold.max_1())
		var/thermo_changed = FALSE
		if(!regulating_temperature)
			if(environment.temperature > config.target_temperature)
				regulating_temperature = "cooling"
			else
				regulating_temperature = "heating"
			thermo_changed = TRUE
		else if(regulating_temperature == "heating" && environment.temperature > config.target_temperature)
			regulating_temperature = "cooling"
			thermo_changed = TRUE
		else if(regulating_temperature == "cooling" && environment.temperature < config.target_temperature)
			regulating_temperature = "heating"
			thermo_changed = TRUE
		if(thermo_changed)
			visible_message("\The [src] clicks as it starts [regulating_temperature] the room.",\
			"You hear a click and a faint electronic hum.")

		var/datum/gas_mixture/gas = environment.remove_volume(0.25 * CELL_VOLUME)
		if(gas)
			var/heat_capacity = gas.heat_capacity()
			var/energy_used = min(abs(heat_capacity * (gas.temperature - actual_target_temperature)), MAX_ENERGY_CHANGE)

			// We need to cool ourselves, but only if the gas isn't already colder than what we can do.
			if (environment.temperature > actual_target_temperature && gas.temperature >= MIN_TEMPERATURE)
				gas.temperature -= energy_used / heat_capacity
				use_power(energy_used/3) //these are heat pumps, so they can have a >100% efficiency, typically about 300%
			// We need to warm ourselves, but only if the gas isn't already hotter than what we can do.
			else if (environment.temperature < actual_target_temperature && gas.temperature <= MAX_TEMPERATURE)
				gas.temperature += energy_used / heat_capacity
				use_power(energy_used/3)

			environment.merge(gas)

			if (abs(environment.temperature - actual_target_temperature) <= 0.5)
				visible_message("\The [src] clicks quietly as it stops [regulating_temperature] the room.",\
				"You hear a click as a faint electronic humming stops.")
				regulating_temperature = 0

	var/old_level = local_danger_level
	var/new_danger = calculate_local_danger_level(environment)

	if (new_danger < old_level)
		danger_averted_confidence++
		use_power = MACHINE_POWER_USE_IDLE

	// Only change danger level if:
	// we're going up a level
	// OR if we're going down a level and have sufficient confidence (prevents spamming update_icon).
	if (old_level < new_danger || (danger_averted_confidence >= 5 && new_danger < old_level))
		setDangerLevel(new_danger)
		update_icon()
		danger_averted_confidence = 0 // Reset counter.
		use_power = MACHINE_POWER_USE_ACTIVE

	if (mode==AALARM_MODE_CYCLE && environment.return_pressure()<ONE_ATMOSPHERE*0.05)
		mode=AALARM_MODE_FILL
		apply_mode()


	//atmos computer remote controll stuff
	switch(rcon_setting)
		if(RCON_NO)
			remote_control = 0
		/*
		if(RCON_AUTO)
			if(local_danger_level == 2)
				remote_control = 1
			else
				remote_control = 0
		*/
		if(RCON_YES)
			remote_control = 1
	if(auto_suppress)
		var/area/this_area = get_area(src)
		if(this_area.fire)
			preset_key = "Fire Suppression"
			apply_preset(1)
	return

/obj/machinery/alarm/proc/calculate_local_danger_level(const/datum/gas_mixture/environment)
	if (wires.IsIndexCut(AALARM_WIRE_AALARM))
		return 2 // MAXIMUM ALARM (With gravelly voice) - N3X.

	if (isnull(environment))
		return 0

	var/other_moles
	var/worst_dangerlevel = max(config.pressure_threshold.assess_danger(environment.pressure),
								config.temperature_threshold.assess_danger(environment.temperature))

	for(var/gas_id in environment.gas)
		var/datum/gas/gas_datum = XGM.gases[gas_id]
		if(gas_datum.flags & XGM_GAS_NOTEWORTHY)
			var/datum/airalarm_threshold/threshold = config.gas_thresholds[gas_id]
			worst_dangerlevel = max(worst_dangerlevel, threshold.assess_danger(environment.partial_pressure(gas_id)))
		else
			other_moles += environment[gas_id]

	return max(worst_dangerlevel, config.other_gas_threshold.assess_danger(other_moles / environment.total_moles * environment.pressure))

/obj/machinery/alarm/proc/master_is_operating()
	var/area/this_area = get_area(src)
	return this_area.master_air_alarm && !(this_area.master_air_alarm.stat & (FORCEDISABLE|NOPOWER|BROKEN))

/obj/machinery/alarm/proc/elect_master()
	var/area/this_area = get_area(src)
	for (var/obj/machinery/alarm/AA in this_area)
		if (!(AA.stat & (NOPOWER|BROKEN|FORCEDISABLE)))
			this_area.master_air_alarm = AA
			return 1
	return 0

/obj/machinery/alarm/update_icon()
	if(wiresexposed)
		icon_state = "alarmx"
		kill_moody_light()
		return
	if((stat & (NOPOWER|BROKEN|FORCEDISABLE)) || shorted)
		icon_state = "alarmp"
		kill_moody_light()
		return
	var/area/this_area = get_area(src)
	switch(max(local_danger_level, this_area.atmosalm-1))
		if (0)
			icon_state = "alarm0"
			update_moody_light('icons/lighting/moody_lights.dmi', "overlay_alarm0")
		if (1)
			icon_state = "alarm2" //yes, alarm2 is yellow alarm
			update_moody_light('icons/lighting/moody_lights.dmi', "overlay_alarm1")
		if (2)
			icon_state = "alarm1"
			update_moody_light('icons/lighting/moody_lights.dmi', "overlay_alarm1")

/obj/machinery/alarm/receive_signal(datum/signal/signal)
	var/area/this_area = get_area(src)
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE) || !this_area)
		return
	if (this_area.master_air_alarm != src)
		if (master_is_operating())
			return
		elect_master()
		if (this_area.master_air_alarm != src)
			return
	if(!signal || signal.encryption)
		return
	var/id_tag = signal.data["tag"]
	if (!id_tag)
		return
	if (signal.data["area"] != area_uid)
		return
	if (signal.data["sigtype"] != "status")
		return

	var/dev_type = signal.data["device"]
	if(!(id_tag in this_area.air_scrub_names) && !(id_tag in this_area.air_vent_names))
		register_env_machine(id_tag, dev_type)

	if(dev_type == "AScr")
		this_area.air_scrub_info[id_tag] = signal.data
	else if(dev_type == "AVP")
		this_area.air_vent_info[id_tag] = signal.data

/obj/machinery/alarm/proc/register_env_machine(var/m_id, var/device_type)
	var/new_name
	var/area/this_area = get_area(src)
	if (device_type=="AVP")
		new_name = "[this_area.name] Vent Pump #[this_area.air_vent_names.len+1]"
		this_area.air_vent_names[m_id] = new_name
	else if (device_type=="AScr")
		new_name = "[this_area.name] Air Scrubber #[this_area.air_scrub_names.len+1]"
		this_area.air_scrub_names[m_id] = new_name
	else
		return
	spawn (10)
		send_signal(m_id, list("init" = new_name) )

/obj/machinery/alarm/proc/refresh_all()
	var/area/this_area = get_area(src)
	for(var/id_tag in this_area.air_vent_names)
		var/list/I = this_area.air_vent_info[id_tag]
		if (I && I["timestamp"]+AALARM_REPORT_TIMEOUT/2 > world.time)
			continue
		send_signal(id_tag, list("status") )
	for(var/id_tag in this_area.air_scrub_names)
		var/list/I = this_area.air_scrub_info[id_tag]
		if (I && I["timestamp"]+AALARM_REPORT_TIMEOUT/2 > world.time)
			continue
		send_signal(id_tag, list("status") )

/obj/machinery/alarm/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_TO_AIRALARM)

/obj/machinery/alarm/proc/send_signal(var/target, var/list/command)//sends signal 'command' to 'target'. Returns 0 if no radio connection, 1 otherwise
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new /datum/signal
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = command
	signal.data["tag"] = target
	signal.data["sigtype"] = "command"

	radio_connection.post_signal(src, signal, RADIO_FROM_AIRALARM)

	return 1

/obj/machinery/alarm/proc/set_temperature(var/temp, var/propagate=1)
	config.target_temperature = temp
	//propagate to other air alarms in the area
	if(propagate)
		var/area/this_area = get_area(src)
		for (var/obj/machinery/alarm/AA in this_area)
			if (!(AA.stat & (NOPOWER|BROKEN|FORCEDISABLE)) && !AA.shorted)
				AA.config.target_temperature  = temp

/obj/machinery/alarm/proc/set_threshold(var/env, var/index, var/value, var/propagate=1)
	// TODO: Refactor how external sources can adjust config thresholds. This is not a very clean way to do it.
	var/datum/airalarm_threshold/target

	value = max(value, -1.0)
	if(env == "temperature")
		target = config.temperature_threshold
		value = min(value, 5000)
	else if(env == "pressure")
		target = config.pressure_threshold
		value = min(value, 50*ONE_ATMOSPHERE)
	else
		value = min(value, 200)
		value = round(value, 0.01)
		if(env == "other")
			target = config.other_gas_threshold
		else
			target = config.gas_thresholds[env]

	target.adjust_threshold(value, index)

	//propagate to other air alarms in the area
	if(propagate)
		apply_mode()
		var/area/this_area = get_area(src)
		for (var/obj/machinery/alarm/AA in this_area)
			if (!(AA.stat & (NOPOWER|BROKEN|FORCEDISABLE)) && !AA.shorted)
				AA.set_threshold(env, index, value, 0)

/obj/machinery/alarm/proc/set_alarm(var/alarm, var/propagate=1)
	alarmActivated = alarm
	update_icon()
	if(propagate)
		var/area/this_area = get_area(src)
		for (var/obj/machinery/alarm/AA in this_area)
			if (!(AA.stat & (NOPOWER|BROKEN|FORCEDISABLE)) && !AA.shorted)
				AA.set_alarm(alarm, 0)
		this_area.updateDangerLevel()

/obj/machinery/alarm/proc/apply_mode()
	var/datum/airalarm_threshold/current_pressure_threshold = config.pressure_threshold
	var/target_pressure = (current_pressure_threshold.min_1() + current_pressure_threshold.max_1())/2
	var/area/this_area = get_area(src)
	switch(mode)
		if(AALARM_MODE_SCRUBBING)
			for(var/device_id in this_area.air_scrub_names)
				var/datum/airalarm_configuration/preset/presetdata = airalarm_presets[preset_key]
				if(!presetdata)
					presetdata = new /datum/airalarm_configuration/preset/human()

				var/list/signal_data = list("power"= 1, "scrubbing"= 1, "panic_siphon"= 0)
				for(var/gas_id in XGM.gases)
					signal_data[gas_id + "_scrub"] = (gas_id in presetdata.scrubbed_gases)
				send_signal(device_id,  signal_data)
			for(var/device_id in this_area.air_vent_names)
				send_signal(device_id, list("power"= 1, "checks"= 1, "set_external_pressure"= target_pressure) )

		if(AALARM_MODE_PANIC, AALARM_MODE_CYCLE)
			for(var/device_id in this_area.air_scrub_names)
				send_signal(device_id, list("power"= 1, "panic_siphon"= 1) )
			for(var/device_id in this_area.air_vent_names)
				send_signal(device_id, list("power"= 0) )

		if(AALARM_MODE_REPLACEMENT)
			for(var/device_id in this_area.air_scrub_names)
				send_signal(device_id, list("power"= 1, "panic_siphon"= 1) )
			for(var/device_id in this_area.air_vent_names)
				send_signal(device_id, list("power"= 1, "checks"= 1, "set_external_pressure"= target_pressure) )

		if(AALARM_MODE_FILL)
			for(var/device_id in this_area.air_scrub_names)
				send_signal(device_id, list("power"= 0) )
			for(var/device_id in this_area.air_vent_names)
				send_signal(device_id, list("power"= 1, "checks"= 1, "set_external_pressure"= target_pressure) )

		if(AALARM_MODE_OFF)
			for(var/device_id in this_area.air_scrub_names)
				send_signal(device_id, list("power"= 0) )
			for(var/device_id in this_area.air_vent_names)
				send_signal(device_id, list("power"= 0) )

// This sets our danger level, and, if it's changed, forces a new election of danger levels.
/obj/machinery/alarm/proc/setDangerLevel(var/new_danger_level)
	if(local_danger_level==new_danger_level)
		return
	local_danger_level=new_danger_level
	var/area/this_area = get_area(src)
	if(this_area.updateDangerLevel())
		post_alert(new_danger_level)

/obj/machinery/alarm/proc/post_alert(alert_level)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(alarm_frequency)
	if(!frequency)
		return

	var/datum/signal/alert_signal = new /datum/signal
	alert_signal.source = src
	alert_signal.transmission_method = 1
	var/area/this_area = get_area(src)
	alert_signal.data["zone"] = this_area.name
	alert_signal.data["type"] = "Atmospheric"

	if(alert_level==2)
		alert_signal.data["alert"] = "severe"
	else if (alert_level==1)
		alert_signal.data["alert"] = "minor"
	else if (alert_level==0)
		alert_signal.data["alert"] = "clear"

	frequency.post_signal(src, alert_signal)

/obj/machinery/alarm/proc/air_doors_close(manual)
	var/area/this_area = get_area(src)
	this_area.CloseFirelocks()

/obj/machinery/alarm/proc/air_doors_open(manual)
	var/area/this_area = get_area(src)
	this_area.OpenFirelocks()

///////////////
//END HACKING//
///////////////

/obj/machinery/alarm/attack_hand(mob/user)
	. = ..()

	if(wiresexposed)
		wires.Interact(user)
		return
	else if (.)
		return

	interact(user)

/obj/machinery/alarm/attack_ai(mob/user)
	if(stat & NOAICONTROL)
		to_chat(user, "<span class='warning'>AI control of this device has been disabled.</span>")
		return
	..()

/obj/machinery/alarm/proc/ui_air_status()
	var/turf/location = get_turf(src)

	if (isnull(location))
		return null

	var/datum/gas_mixture/environment = location.return_air()
	var/total = environment.total_moles
	if(total==0)
		return null

	var/data[0]
	data["pressure"]=environment.pressure
	data["temperature"]=environment.temperature
	data["temperature_c"]=round(environment.temperature - T0C, 0.1)
	data["pressure_danger"] = config.pressure_threshold.assess_danger(environment.pressure)
	data["temperature_danger"] = config.temperature_threshold.assess_danger(environment.temperature)

	var/list/noteworthy_gases = list()
	var/worst_dangerlevel = 0
	var/other_moles = 0
	for(var/gas_id in XGM.gases)
		var/datum/gas/gas_datum = XGM.gases[gas_id]
		if(gas_datum.flags & XGM_GAS_NOTEWORTHY)
			var/list/raw_gas_data = list()
			var/datum/airalarm_threshold/threshold = config.gas_thresholds[gas_id]
			raw_gas_data["danger"] = threshold.assess_danger(environment.partial_pressure(gas_id))
			raw_gas_data["percentage"] = round(environment[gas_id] / total * 100, 2)
			raw_gas_data["name"] = gas_datum.name
			noteworthy_gases += list(raw_gas_data)
			worst_dangerlevel = max(worst_dangerlevel, raw_gas_data["danger"])
		else
			if(environment[gas_id])
				other_moles += environment[gas_id]
	var/list/raw_other_gas_data = list()
	raw_other_gas_data["danger"] = config.other_gas_threshold.assess_danger(other_moles / total * environment.pressure)
	raw_other_gas_data["percentage"] = round(other_moles / total * 100, 2)
	raw_other_gas_data["name"] = "Other"
	noteworthy_gases += list(raw_other_gas_data)
	data["overall_danger"] = max(worst_dangerlevel, raw_other_gas_data["danger"])
	data["noteworthy_gases"] = noteworthy_gases

	return data

/obj/machinery/alarm/proc/get_nano_data(mob/user, fromAtmosConsole=0)
	var/area/this_area = get_area(src)
	var/data[0]
	data["air"]=ui_air_status()
	data["alarmActivated"]=alarmActivated //|| local_danger_level==2
	data["thresholds"]=config.nanoui_config_data()
	// Locked when:
	//   Not sent from atmos console AND
	//   Not silicon AND locked AND
	//   NOT adminghost.
	data["locked"]=!fromAtmosConsole && (!(istype(user, /mob/living/silicon)) && locked) && !isAdminGhost(user) && !(OMNI_LINK(user,src))

	data["rcon"]=rcon_setting
	data["rcon_enabled"] = remote_control
	data["target_temp"] = config.target_temperature  - T0C
	data["atmos_alarm"] = this_area.atmosalm
	data["modes"] = list(
		AALARM_MODE_SCRUBBING   = list("name"="Filtering",   "desc"="Scrubs out contaminants"),\
		AALARM_MODE_REPLACEMENT = list("name"="Replace Air", "desc"="Siphons out air while replacing"),\
		AALARM_MODE_PANIC       = list("name"="Panic",       "desc"="Siphons air out of the room"),\
		AALARM_MODE_CYCLE       = list("name"="Cycle",       "desc"="Siphons air before replacing"),\
		AALARM_MODE_FILL        = list("name"="Fill",        "desc"="Shuts off scrubbers and opens vents"),\
		AALARM_MODE_OFF         = list("name"="Off",         "desc"="Shuts off vents and scrubbers"))
	data["mode"]=mode

	var/list/tmplist = new/list()
	for(var/preset in airalarm_presets)
		var/datum/airalarm_configuration/preset/preset_datum = airalarm_presets[preset]
		tmplist[++tmplist.len] = list("name" = preset_datum.name, "desc" = preset_datum.desc)
	data["presets"] = tmplist
	data["preset"]=preset_key
	data["screen"]=screen
	data["cycle_after_preset"] = cycle_after_preset
	data["firedoor_override"] = this_area.doors_overridden
	data["suppression_mode"] = auto_suppress

	var/list/vents=list()
	if(this_area.air_vent_names.len)
		for(var/id_tag in this_area.air_vent_names)
			var/vent_info[0]
			var/long_name = this_area.air_vent_names[id_tag]
			var/list/vent_data = this_area.air_vent_info[id_tag]
			if(!vent_data)
				continue
			vent_info["id_tag"]=id_tag
			vent_info["name"]=long_name
			vent_info += vent_data
			vents+=list(vent_info)
	data["vents"]=vents

	var/list/scrubbers=list()
	if(this_area.air_scrub_names.len)
		for(var/id_tag in this_area.air_scrub_names)
			var/long_name = this_area.air_scrub_names[id_tag]
			var/list/scrubber_data = this_area.air_scrub_info[id_tag]
			if(!scrubber_data)
				continue
			scrubber_data["id_tag"]=id_tag
			scrubber_data["name"]=long_name
			scrubbers+=list(scrubber_data)
	data["scrubbers"]=scrubbers

	var/list/gas_datums=list()
	for(var/gas_id in XGM.gases)
		var/datum/gas/gas_datum = XGM.gases[gas_id]
		var/list/datum_data = list()
		datum_data["id"] = gas_id
		datum_data["name"] = gas_datum.name
		datum_data["short_name"] = gas_datum.short_name != null ? gas_datum.short_name : gas_datum.name
		gas_datums += list(datum_data)
	data["gas_datums"]=gas_datums
	return data


/obj/machinery/alarm/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/list/data=src.get_nano_data(user,FALSE)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		// The ui does not exist, so we'll create a new one.
		ui = new(user, src, ui_key, "air_alarm.tmpl", name, 580, 410)
		// When the UI is first opened this is the data it will use.
		ui.set_initial_data(data)
		// Open the new ui window.
		ui.open()
		// Auto update every Master Controller tick.
		ui.set_auto_update(1)

/obj/machinery/alarm/interact(mob/user)
	if(buildstage!=2)
		return
	if(!shorted)
		ui_interact(user)

/obj/machinery/alarm/proc/buttonCheck(mob/user)
	if(!locked)
		return 1
	if(issilicon(user))
		return 1
	if(user.hasFullAccess())
		return 1
	if(OMNI_LINK(user,src))
		return 1
	if(isAdminGhost(user))
		return 1
	return 0

/obj/machinery/alarm/Topic(href, href_list)
	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1
	if(..())
		return 1

	add_fingerprint(usr)


	//These options MUST be first in Topic() because they do not require access check as below
	if(href_list["screen"])
		screen = text2num(href_list["screen"])
		return 1

	if(href_list["temperature"])
		var/datum/airalarm_threshold/temperature_threshold = config.temperature_threshold
		var/max_temperature
		var/min_temperature
		if(buttonCheck(usr))
			max_temperature = MAX_TARGET_TEMPERATURE - T0C
			min_temperature = MIN_TARGET_TEMPERATURE - T0C
		else
			max_temperature = temperature_threshold.max_1() - T0C
			min_temperature = temperature_threshold.min_1() - T0C
		var/input_temperature = input("What temperature (in C) would you like the system to target? (Capped between [min_temperature]C and [max_temperature]C).\n\nNote that the cooling unit in this air alarm can not go below [MIN_TEMPERATURE - T0C]C or above [MAX_TEMPERATURE - T0C]C by itself. ", "Thermostat Controls") as num|null
		if(input_temperature==null)
			return 1
		input_temperature = round(clamp(input_temperature, min_temperature, max_temperature) + T0C, 0.01)
		set_temperature(input_temperature)
		return 1

	if(!buttonCheck(usr))
		to_chat(usr, "<span class='warning'>It's locked!</span>")
		return 1

	if(href_list["rcon"])
		rcon_setting = text2num(href_list["rcon"])
		//propagate to other AAs in the area
		var/area/this_area = get_area(src)
		for (var/obj/machinery/alarm/AA in this_area)
			if ( !(AA.stat & (NOPOWER|BROKEN|FORCEDISABLE)) && !AA.shorted)
				AA.rcon_setting = rcon_setting
		return 1

	if(href_list["command"])
		var/device_id = href_list["id_tag"]
		var/command = href_list["command"]
		if(command in XGM.gases)
			var/val=text2num(href_list["val"])
			send_signal(device_id, list(command+"_scrub" = val ))
		else
			switch(href_list["command"])
				if( "power",
					"set_external_pressure",
					"set_internal_pressure",
					"checks",
					"panic_siphon",
					"scrubbing",
					"direction")
					var/val
					if(href_list["val"])
						val=text2num(href_list["val"])
					else
						var/newval = input("Enter new value") as num|null
						if(isnull(newval))
							return 1
						if(href_list["command"]=="set_external_pressure")
							newval = clamp(newval, 0, 1000+ONE_ATMOSPHERE)
						val = newval

					send_signal(device_id, list(href_list["command"] = val ) )

				if("set_threshold")
					var/env = href_list["env"]
					var/threshold = text2num(href_list["var"])
					var/list/thresholds = list("lower bound", "low warning", "high warning", "upper bound")
					var/newval = input("Enter [thresholds[threshold]] for [env]", "Alarm triggers", 0) as num|null
					if (isnull(newval) || ..() || !buttonCheck(usr))
						return 1
					set_threshold(env, threshold, newval, 1)
		return 1
	if(href_list["reset_thresholds"])
		apply_preset(1) //just apply the preset without cycling
		return 1

	if(href_list["atmos_alarm"])
		set_alarm(1)
		return 1

	if(href_list["atmos_reset"])
		set_alarm(0)
		return 1

	if(href_list["enable_override"])
		var/area/this_area = get_area(src)
		this_area.doors_overridden = 1
		this_area.UpdateFirelocks()
		update_icon()
		return 1

	if(href_list["disable_override"])
		var/area/this_area = get_area(src)
		this_area.doors_overridden = 0
		this_area.UpdateFirelocks()
		update_icon()
		return 1

	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		apply_mode()
		return 1

	if(href_list["toggle_cycle_after_preset"])
		cycle_after_preset = !cycle_after_preset
		return 1

	if(href_list["preset"])
		if(href_list["preset"] in airalarm_presets)
			preset_key = href_list["preset"]
			apply_preset(!cycle_after_preset)
		return 1

	if(href_list["auto_suppress"])
		auto_suppress = !auto_suppress
		return 1

/obj/machinery/alarm/attackby(obj/item/W as obj, mob/user as mob)
	src.add_fingerprint(user)

	switch(buildstage)
		if(2)
			if(W.is_screwdriver(user))  // Opening that Air Alarm up.
				wiresexposed = !wiresexposed
				to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"].")
				W.playtoolsound(src, 50)
				update_icon()
				return

			if(wiresexposed && !wires.IsAllCut() && iswiretool(W))
				return attack_hand(user)
			else if(wiresexposed && wires.IsAllCut() && W.is_wirecutter(user))
				buildstage = 1
				update_icon()
				user.visible_message("<span class='attack'>[user] has cut the wiring from \the [src]!</span>", "You have cut the last of the wiring from \the [src].")
				W.playtoolsound(src, 50)
				new /obj/item/stack/cable_coil(get_turf(user), 5)
				return
			if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))// trying to unlock the interface with an ID card
				if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
					to_chat(user, "It does nothing")
					return
				else
					if(allowed(user) && !wires.IsIndexCut(AALARM_WIRE_IDSCAN))
						locked = !locked
						to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the Air Alarm interface.</span>")
						nanomanager.update_uis(src)
					else
						to_chat(user, "<span class='warning'>Access denied.</span>")
			return ..() //Sanity

		if(1)
			if(iscablecoil(W))
				var/obj/item/stack/cable_coil/coil = W
				if(coil.amount < 5)
					to_chat(user, "You need more cable for this!")
					return
				for(var/i, i<= 5, i++)
					wires.UpdateCut(i, 1, user)

				to_chat(user, "You wire \the [src]!")
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				coil.use(5)
				buildstage = 2
				update_icon()
				first_run()
				return

			else if(iscrowbar(W))
				to_chat(user, "You start prying out the circuit...")
				W.playtoolsound(src, 50)
				if(do_after(user, src, 20) && buildstage == 1)
					to_chat(user, "You pry out the circuit!")
					new /obj/item/weapon/circuitboard/air_alarm(get_turf(user))
					buildstage = 0
					update_icon()
				return
		if(0)
			if(istype(W, /obj/item/weapon/circuitboard/air_alarm))
				to_chat(user, "You insert the circuit!")
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				qdel(W)
				buildstage = 1
				update_icon()
				return

			else if(W.is_wrench(user))
				to_chat(user, "You remove the air alarm assembly from the wall!")
				new /obj/item/mounted/frame/alarm_frame(get_turf(user))
				W.playtoolsound(src, 50)
				qdel(src)
				return

// Run after construction process is finished and air alarm is initially built.
/obj/machinery/alarm/proc/first_run()
	var/area/this_area = get_area(src)
	area_uid = this_area.uid
	name = "[this_area.name] Air Alarm"
	this_area.air_alarms.Add(src)
	air_alarms += src

	apply_preset(1, 0) // Don't cycle and don't propagate.
	apply_mode() //apply mode to scrubbers and vents

/obj/machinery/alarm/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	spawn(rand(0,15))
		update_icon()

/obj/machinery/alarm/examine(mob/user)
	..()
	if (buildstage < 2)
		to_chat(user, "<span class='info'>It is not wired.</span>")
	if (buildstage < 1)
		to_chat(user, "<span class='info'>The circuit is missing.</span>")

/obj/machinery/alarm/wirejack(var/mob/living/silicon/pai/P)
	if(..())
		locked = !locked
		update_icon()
		return 1
	return 0

/obj/machinery/alarm/is_in_range(var/mob/user)
	if(!..())
		return OMNI_LINK(user,src)
	return TRUE

/obj/machinery/alarm/supports_holomap()
	return TRUE

/*
FIRE ALARM
*/
/obj/machinery/firealarm
	name = "Fire Alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0s"
	var/detecting = 1.0
	var/working = 1.0
	var/time = 10.0
	var/timing = 0.0
	var/lockdownbyai = 0
	anchored = 1.0
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	machine_flags = EMAGGABLE
	var/last_process = 0
	var/wiresexposed = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone
	var/shelter = 1
	var/alarm = 0
	var/last_alarm_time = 0
	var/alarm_delay = 10 SECONDS

/obj/machinery/firealarm/empty
	shelter = 0

/obj/machinery/firealarm/supports_holomap()
	return TRUE

/obj/machinery/firealarm/initialize()
	..()
	add_self_to_holomap()

/obj/machinery/firealarm/update_icon()
	overlays.len = 0
	if(wiresexposed)
		icon_state = "fire_b[buildstage]"
		kill_moody_light_all()
		return

	if(stat & BROKEN)
		icon_state = "firex"
		kill_moody_light_all()
	else if(stat & (FORCEDISABLE|NOPOWER))
		icon_state = "firep"
		kill_moody_light_all()
	else
		icon_state = "fire[detecting ? "0" : "1"][shelter ? "s" : "e"]"
		update_moody_light_index("detecting", 'icons/lighting/moody_lights.dmi', "overlay_firealarm_[detecting ? "" : "not"]detecting")
		if (shelter)
			update_moody_light_index("shelter", 'icons/lighting/moody_lights.dmi', "overlay_firealarm_shelter")
		else
			kill_moody_light_index("shelter")
		if(z == map.zMainStation)
			overlays += image('icons/obj/monitors.dmi', "overlay_[get_security_level()]")
			update_moody_light_index("seclevel", 'icons/lighting/moody_lights.dmi', "overlay_firealarm_alert_[get_security_level()]")
		else
			overlays += image('icons/obj/monitors.dmi', "overlay_green")
			update_moody_light_index("seclevel", 'icons/lighting/moody_lights.dmi', "overlay_firealarm_alert_green")

/obj/machinery/firealarm/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(src.detecting)
		if(exposed_temperature > T0C+200)
			src.alarm()			// added check of detector status here

/obj/machinery/firealarm/bullet_act(BLAH)
	src.alarm()
	return ..()

/obj/machinery/firealarm/CtrlClick(var/mob/user)
	if (!(user.dexterity_check())) // Squeak
		return
	if(user.incapacitated() || (!in_range(src, user) && !issilicon(user)))
		return
	else
		if(alarm == 1)
			reset()
		else
			alarm()

/obj/machinery/firealarm/AICtrlClick()
	if(alarm == 1)
		reset()
	else
		alarm()

/obj/machinery/firealarm/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50/severity))
		alarm()
	..()

/obj/machinery/firealarm/MouseDropTo(atom/movable/AM, mob/user)
	if(user.incapacitated() || user.lying || !Adjacent(user) || !user.Adjacent(src))
		return
	if(istype(AM,/obj/structure/inflatable/shelter))
		var/obj/structure/inflatable/shelter/S = AM
		S.deflate()
	if(istype(AM,/obj/item/inflatable/shelter))
		attackby(AM,user)

/obj/machinery/firealarm/attackby(obj/item/W as obj, mob/user as mob)
	..()
	src.add_fingerprint(user)

	if (istype(W,/obj/item/inflatable/shelter))
		qdel(W)
		shelter = TRUE
		update_icon()
		return
	if (W.is_screwdriver(user) && buildstage == 2)
		wiresexposed = !wiresexposed
		to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"].")
		W.playtoolsound(src, 50)
		update_icon()
		return

	if(wiresexposed)
		switch(buildstage)
			if(2)
				if (W.is_multitool(user))
					src.detecting = !( src.detecting )
					user.visible_message("<span class='attack'>[user] has [detecting ? "re" : "dis"]connected [src]'s detecting unit!</span>", "You have [detecting ? "re" : "dis"]connected [src]'s detecting unit.")
					playsound(src, 'sound/items/healthanalyzer.ogg', 50, 1)
				if(W.is_wirecutter(user))
					to_chat(user, "You begin to cut the wiring...")
					W.playtoolsound(src, 50)
					if (do_after(user, src,  50) && buildstage == 2 && wiresexposed)
						buildstage=1
						user.visible_message("<span class='attack'>[user] has cut the wiring from \the [src]!</span>", "You have cut the last of the wiring from \the [src].")
						update_icon()
						new /obj/item/stack/cable_coil(get_turf(user), 5)
			if(1)
				if(iscablecoil(W))
					var/obj/item/stack/cable_coil/coil = W
					if(coil.amount < 5)
						to_chat(user, "You need more cable for this!")
						return
					coil.use(5)

					buildstage = 2
					to_chat(user, "You wire \the [src]!")
					update_icon()

				else if(iscrowbar(W))
					to_chat(user, "You start prying out the circuit...")
					W.playtoolsound(src, 50)
					if (do_after(user, src,  20) && buildstage == 1)
						to_chat(user, "You pry out the circuit!")
						new /obj/item/weapon/circuitboard/fire_alarm(get_turf(user))
						buildstage = 0
						update_icon()
			if(0)
				if(istype(W, /obj/item/weapon/circuitboard/fire_alarm))
					to_chat(user, "You insert the circuit!")
					playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
					qdel(W)
					buildstage = 1
					update_icon()

				else if(W.is_wrench(user))
					to_chat(user, "You remove the fire alarm assembly from the wall!")
					new /obj/item/mounted/frame/firealarm(get_turf(user))
					W.playtoolsound(src, 50)
					qdel(src)
		return

	src.alarm()

/obj/machinery/firealarm/process()
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return

	var/turf/simulated/location = loc
	if(shelter && istype(location)) //If simulated turf and we have a shelter to drop
		var/datum/gas_mixture/environment = location.return_air()
		if(environment.partial_pressure(GAS_PLASMA) > 0.5) //Partial Pressure of 0.5kPa
			var/obj/item/inflatable/shelter/S = new /obj/item/inflatable/shelter(loc)
			S.inflate()
			shelter = FALSE
			update_icon()
			visible_message("<span class='warning'>\The [S] springs free of the fire alarm autonomously and inflates!</span>")

	if(src.timing)
		if(src.time > 0)
			src.time = src.time - ((world.timeofday - last_process)/10)
		else
			src.alarm()
			src.time = 0
			src.timing = 0
		src.updateDialog()
	last_process = world.timeofday

	if(locate(/obj/effect/fire) in loc)
		alarm()

	return

/obj/machinery/firealarm/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
		update_icon()
	else
		spawn(rand(0,15))
			stat |= NOPOWER
			update_icon()

/obj/machinery/firealarm/attack_hand(mob/user as mob)
	if((user.stat && !isobserver(user)) || stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return

	if (!(user.dexterity_check())) // No squeaks or moos allowed.
		return

	if (buildstage != 2)
		return

	user.set_machine(src)
	var/area/this_area = get_area(src)
	var/second = round(src.time) % 60
	var/minute = (round(src.time) - second) / 60
	var/dat = {"<HTML><HEAD></HEAD><BODY><TT><B>Fire alarm</B>
	<A href='?src=\ref[src];alarm=1'>[this_area.fire ? "Reset" : "Alarm"] - Lockdown</A>\n
	<HR>The current alert level is: [get_security_level()]</b><br><br>\n
	Timer System: <A href='?src=\ref[src];time=1'>[timing ? "Stop Time Lock" : "Initiate Time Lock"]</A><BR>\n
	Time Left: [(minute ? "[minute]:" : null)][second]
	<A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>\n</TT></BODY></HTML><BR><BR>"}

	if(shelter)
		dat += "An emergency shelter is mounted within. <A href='?src=\ref[src];shelter=1'>Retrieve</A>"
	else
		dat += "The shelter has been removed. <A href='?src=\ref[src];shelter=1'>Insert</A>"
	user << browse(dat, "window=firealarm")
	onclose(user, "firealarm")

/obj/machinery/firealarm/Topic(href, href_list)
	if(..())
		return 1

	if (buildstage != 2)
		return

	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)
		if (href_list["alarm"])
			var/area/A = get_area(src)
			if(A.fire) //This var doesn't actually represent whether there is a fire, only if it's alarming or not
				reset()
			else
				alarm()
		else if (href_list["time"])
			timing = !timing
			last_process = world.timeofday
		else if (href_list["tp"])
			var/tp = text2num(href_list["tp"])
			time += tp
			time = min(max(round(src.time), 0), 120)
		else if (href_list["shelter"])
			if(shelter)
				var/obj/O = new /obj/item/inflatable/shelter(loc)
				if(!isAdminGhost(usr)) //Silicons AND adminghosts drop it to the floor
					usr.put_in_hands(O)
				shelter = FALSE
				update_icon()
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I,/obj/item/inflatable/shelter))
					qdel(I)
					shelter = TRUE
					update_icon()

		src.updateUsrDialog()

		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=firealarm")
		return
	return

/obj/machinery/firealarm/proc/reset()
	if (!( src.working ))
		return
	var/area/this_area = get_area(src)
	this_area.firereset()
	update_icon()
	alarm = 0

/obj/machinery/firealarm/proc/alarm()
	if (!( src.working ) || alarm || (stat & (NOPOWER|BROKEN|FORCEDISABLE)))
		return
	var/area/this_area = get_area(src)
	this_area.firealert()
	update_icon()
	alarm = 1
	if(world.time - last_alarm_time < alarm_delay)
		return
	if(emagged)
		playsound(src, 'sound/misc/imperial_alert.ogg', 75, 0, 5)
	else
		playsound(src, 'sound/misc/fire_alarm.ogg', 75, 0, 5)
	last_alarm_time = world.time

var/global/list/firealarms = list() //shrug

/obj/machinery/firealarm/New(loc, dir, building)
	..()
	var/area/this_area = get_area(src)
	name = "[this_area.name] fire alarm"
	if(loc)
		src.forceMove(loc)

	if(dir)
		src.dir = dir

	if(building)
		buildstage = 0
		wiresexposed = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 * PIXEL_MULTIPLIER: 24 * PIXEL_MULTIPLIER)
		pixel_y = (dir & 3)? (dir ==1 ? -24 * PIXEL_MULTIPLIER: 24 * PIXEL_MULTIPLIER) : 0

	machines.Remove(src)
	firealarms |= src
	processing_objects += src
	update_icon()

/obj/machinery/firealarm/Destroy()
	firealarms.Remove(src)
	..()

/obj/machinery/firealarm/npc_tamper_act(mob/living/L)
	alarm()

/obj/machinery/firealarm/kick_act(mob/living/carbon/human/H)
	..()
	if(shelter && prob(50))
		new /obj/item/inflatable/shelter(loc)
		shelter = FALSE
		update_icon()
		visible_message("<span class='notice'>\The shelter detaches from \the [src]!</span>")

/obj/machinery/firealarm/emag_act(mob/user as mob)
	emagged = TRUE
	to_chat(user, "You scramble \the [src]'s audio processor.")
	..()

/obj/machinery/partyalarm
	name = "\improper PARTY BUTTON"
	desc = "Cuban Pete is in the house!"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	var/detecting = 1.0
	var/working = 1.0
	var/time = 10.0
	var/timing = 0.0
	var/lockdownbyai = 0
	anchored = 1.0
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 2
	active_power_usage = 6

/obj/machinery/partyalarm/New()
	..()
	var/area/this_area = get_area(src)
	name = "[this_area.name] party alarm"

/obj/machinery/partyalarm/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/partyalarm/attack_hand(mob/user as mob)
	if((user.stat && !isobserver(user)) || stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return

	user.machine = src
	var/d1
	var/d2
	var/area/this_area = get_area(src)
	if (istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon/ai))
		if (this_area.party)
			d1 = text("<A href='?src=\ref[];reset=1'>No Party :(</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>PARTY!!!</A>", src)
		if (timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = time % 60
		var/minute = (time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>Party Button</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
		user << browse(dat, "window=partyalarm")
		onclose(user, "partyalarm")
	else
		if (this_area.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("No Party :("))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("PARTY!!!"))
		if (timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = time % 60
		var/minute = (time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>[]</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", stars("Party Button"), d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
		user << browse(dat, "window=partyalarm")
		onclose(user, "partyalarm")
	return

/obj/machinery/partyalarm/proc/reset()
	if (!( working ))
		return
	var/area/this_area = get_area(src)
	this_area.partyreset()
	return

/obj/machinery/partyalarm/proc/alarm()
	if (!( working ))
		return
	var/area/this_area = get_area(src)
	this_area.partyalert()
	return

/obj/machinery/partyalarm/Topic(href, href_list)
	if(..())
		return 1
	if (usr.stat || stat & (BROKEN|NOPOWER|FORCEDISABLE))
		return

	usr.machine = src
	if (href_list["reset"])
		reset()
	else
		if (href_list["alarm"])
			alarm()
		else
			if (href_list["time"])
				timing = text2num(href_list["time"])
			else
				if (href_list["tp"])
					var/tp = text2num(href_list["tp"])
					time += tp
					time = min(max(round(time), 0), 120)
	updateUsrDialog()

	add_fingerprint(usr)
	return

/obj/machinery/alarm/npc_tamper_act(mob/living/L)
	if(wires)
		wires.npc_tamper(L)

/obj/machinery/alarm/AltClick(mob/user)
	if(!user.incapacitated() && Adjacent(user) && user.dexterity_check() && allowed(user))
		locked = !locked
		to_chat(user, "You [locked ? "" : "un"]lock \the [src] interface.")
		update_icon()
	return ..()

/proc/get_station_avg_temp()
	var/avg_temp = 0
	var/avg_divide = 0
	for(var/obj/machinery/alarm/alarm in machines)
		var/turf/simulated/location = alarm.loc
		if(!istype(location))
			continue
		var/datum/gas_mixture/environment = location.return_air()
		if(!environment)
			continue
		avg_temp += environment.temperature
		avg_divide++

	if(avg_divide)
		return avg_temp / avg_divide
	return T0C
