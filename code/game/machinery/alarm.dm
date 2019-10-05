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

//All gases that do not fall under "other"
#define CHECKED_GAS GAS_OXYGEN, GAS_NITROGEN, GAS_CARBON, GAS_PLASMA, GAS_SLEEPING

//all air alarms in area are connected via magic
/area
	var/obj/machinery/alarm/master_air_alarm
	var/list/air_vent_names = list()
	var/list/air_scrub_names = list()
	var/list/air_vent_info = list()
	var/list/air_scrub_info = list()

//These are the system presets that define things like gas concentrations and pressures
/datum/airalarm_preset //this one is a blank preset that checks for NOTHING
	var/name = null
	var/desc = null
	var/core = FALSE //whether this is a stock preset that cannot be deleted
	var/list/oxygen = list(-1, -1, -1, -1) // Partial pressure, kpa
	var/list/nitrogen = list(-1, -1, -1, -1) // Partial pressure, kpa
	var/list/carbon_dioxide = list(-1, -1, -1, -1) // Partial pressure, kpa
	var/list/plasma = list(-1, -1, -1, -1) // Partial pressure, kpa
	var/list/n2o = list(-1, -1, -1, -1) // Partial pressure, kpa
	var/list/other = list(-1, -1, -1, -1) // Partial pressure, kpa
	var/list/pressure = list(-1, -1, -1, -1) // kpa
	var/list/temperature = list(-1, -1, -1, -1) // Kelvin
	var/target_temperature = T0C+20 // Kelvin
	var/list/scrubbers_gases = list("oxygen" = 0, "nitrogen" = 0, "carbon_dioxide" = 0, "plasma" = 0, "n2o" = 0)

/datum/airalarm_preset/New(var/datum/airalarm_preset/P, var/name, var/desc, var/core, var/list/oxygen, var/list/nitrogen,
							var/list/carbon_dioxide, var/list/plasma, var/list/n2o, var/list/other, var/list/pressure,
							var/list/temperature, var/list/target_temperature, var/list/scrubbers_gases)
	if(P)
		src.name = P.name
		src.desc = P.desc
		src.core = P.core
		src.oxygen = P.oxygen.Copy()
		src.nitrogen = P.nitrogen.Copy()
		src.carbon_dioxide = P.carbon_dioxide.Copy()
		src.plasma = P.plasma.Copy()
		src.n2o = P.n2o.Copy()
		src.other = P.other.Copy()
		src.pressure = P.pressure.Copy()
		src.temperature = P.temperature.Copy()
		src.target_temperature = P.target_temperature
		src.scrubbers_gases = P.scrubbers_gases.Copy()
	if(name)
		src.name = name
	if(desc)
		src.desc = desc
	if(core != null)
		src.core = core
	if(oxygen)
		src.oxygen = oxygen
	if(nitrogen)
		src.nitrogen = nitrogen
	if(plasma)
		src.plasma = plasma
	if(n2o)
		src.n2o = n2o
	if(other)
		src.other = other
	if(pressure)
		src.pressure = pressure
	if(temperature)
		src.temperature = temperature
	if(target_temperature)
		src.target_temperature = target_temperature
	if(scrubbers_gases)
		src.scrubbers_gases = scrubbers_gases

/datum/airalarm_preset/human //For humans
	name = "Human"
	desc = "Permits Oxygen and Nitrogen"
	core = TRUE
	oxygen = list(16, 18, 135, 140)
	nitrogen = list(-1, -1,  -1,  -1)
	carbon_dioxide = list(-1, -1, 5, 10)
	plasma = list(-1, -1, 0.2, 0.5)
	n2o = list(-1, -1, 0.5, 1)
	other = list(-1, -1, 0.5, 1)
	pressure = list(ONE_ATMOSPHERE*0.80, ONE_ATMOSPHERE*0.90, ONE_ATMOSPHERE*1.10, ONE_ATMOSPHERE*1.20)
	temperature = list(T0C-30, T0C, T0C+40, T0C+70)
	target_temperature = T0C+20
	scrubbers_gases = list("oxygen" = 0, "nitrogen" = 0, "carbon_dioxide" = 1, "plasma" = 1, "n2o" = 0)

/datum/airalarm_preset/vox //For vox
	name = "Vox"
	desc = "Permits Nitrogen only"
	core = TRUE
	oxygen = list(-1, -1, 0.5, 1)
	nitrogen = list(16, 18, 135,  140)
	carbon_dioxide = list(-1, -1, 5, 10)
	plasma = list(-1, -1, 0.2, 0.5)
	n2o = list(-1, -1, 0.5, 1)
	other = list(-1, -1, 0.5, 1)
	pressure = list(ONE_ATMOSPHERE*0.80, ONE_ATMOSPHERE*0.90, ONE_ATMOSPHERE*1.10, ONE_ATMOSPHERE*1.20)
	temperature = list(T0C-30, T0C, T0C+40, T0C+70)
	target_temperature = T0C+20
	scrubbers_gases = list("oxygen" = 1, "nitrogen" = 0, "carbon_dioxide" = 1, "plasma" = 1, "n2o" = 0)

/datum/airalarm_preset/coldroom //Server rooms etc.
	name = "Coldroom"
	desc = "For server rooms and freezers"
	core = TRUE
	oxygen = list(-1, -1, -1, -1)
	nitrogen = list(-1, -1, -1, -1)
	carbon_dioxide = list(-1, -1, 5, 10)
	plasma = list(-1, -1, 0.2, 0.5)
	n2o = list(-1, -1, 0.5, 1)
	other = list(-1, -1, 0.5, 1)
	pressure = list(-1, ONE_ATMOSPHERE*0.10, ONE_ATMOSPHERE*1.90, ONE_ATMOSPHERE*2.3)
	temperature = list(20, 40, 140, 160)
	target_temperature = 90
	scrubbers_gases = list("oxygen" = 1, "nitrogen" = 0, "carbon_dioxide" = 1, "plasma" = 1, "n2o" = 0)

/datum/airalarm_preset/plasmaman //HONK
	name = "Plasmaman"
	desc = "Permits Plasma and Nitrogen only"
	core = TRUE
	oxygen = list(-1, -1, 0.5, 1)
	nitrogen = list(-1, -1, -1, -1)
	carbon_dioxide = list(-1, -1, 5, 10)
	plasma = list(16, 18, 135, 140)
	n2o = list(-1, -1, 0.5, 1)
	other = list(-1, -1, 0.5, 1)
	pressure = list(ONE_ATMOSPHERE*0.80, ONE_ATMOSPHERE*0.90, ONE_ATMOSPHERE*1.10, ONE_ATMOSPHERE*1.20)
	temperature = list(T0C-30, T0C, T0C+40, T0C+70)
	target_temperature = T0C+20
	scrubbers_gases = list("oxygen" = 1, "nitrogen" = 1, "carbon_dioxide" = 1, "plasma" = 0, "n2o" = 0)

//these are used for the UIs and new ones can be added and existing ones edited at the CAC
var/global/list/airalarm_presets = list(
	"Human" = new /datum/airalarm_preset/human,
	"Vox" = new /datum/airalarm_preset/vox,
	"Coldroom" = new /datum/airalarm_preset/coldroom,
	"Plasmaman" = new /datum/airalarm_preset/plasmaman,
)

/obj/machinery/alarm
	desc = "An alarm used to control the area's atmospherics systems."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm0"
	anchored = 1
	use_power = 1
	idle_power_usage = 100
	active_power_usage = 200
	power_channel = ENVIRON
	req_one_access = list(access_atmospherics, access_engine_equip)
	var/frequency = 1439
	//var/skipprocess = 0 //Experimenting
	var/alarm_frequency = 1437
	var/remote_control = 1
	var/rcon_setting = RCON_YES
	var/rcon_time = 0
	var/locked = 1
	var/datum/wires/alarm/wires = null
	var/wiresexposed = 0 // If it's been screwdrivered open.
	var/aidisabled = 0
	var/AAlarmwires = 31
	var/shorted = 0

	var/mode = AALARM_MODE_SCRUBBING
	var/datum/airalarm_preset/preset = "Human"
	var/screen = AALARM_SCREEN_MAIN
	var/area_uid
	var/local_danger_level = 0
	var/alarmActivated = 0 // Manually activated (independent from danger level)
	var/danger_averted_confidence=0
	var/buildstage = 2 //2 is built, 1 is building, 0 is frame.
	var/cycle_after_preset = 1 // Whether we automatically cycle when presets are changed

	var/target_temperature = T0C+20
	var/regulating_temperature = 0

	var/datum/radio_frequency/radio_connection

	var/list/TLV = list()

	machine_flags = WIREJACK

/obj/machinery/alarm/supports_holomap()
	return TRUE

/obj/machinery/alarm/xenobio
	req_one_access = list(access_rd, access_atmospherics, access_engine_equip, access_xenobiology)
	req_access = list()

/obj/machinery/alarm/execution
	req_one_access = list(access_atmospherics, access_engine_equip, access_brig)
	req_access = list()

/obj/machinery/alarm/server
	preset = "Coldroom"
	req_one_access = list(access_rd, access_atmospherics, access_engine_equip)
	req_access = list()

/obj/machinery/alarm/vox
	preset = "Vox"
	req_one_access = list()
	req_access = list(access_trade)

/obj/machinery/alarm/proc/apply_preset(var/no_cycle_after=0, var/propagate=1)
	var/datum/airalarm_preset/presetdata = airalarm_presets[preset]
	if(!presetdata)
		presetdata = new /datum/airalarm_preset/human()
	TLV["oxygen"] =			presetdata.oxygen.Copy()
	TLV["nitrogen"] =		presetdata.nitrogen.Copy()
	TLV["carbon_dioxide"] = presetdata.carbon_dioxide.Copy()
	TLV["plasma"] =			presetdata.plasma.Copy()
	TLV["n2o"] =			presetdata.n2o.Copy()
	TLV["other"] =			presetdata.other.Copy()
	TLV["pressure"] =		presetdata.pressure.Copy()
	TLV["temperature"] =	presetdata.temperature.Copy()
	target_temperature =	presetdata.target_temperature
	if(!no_cycle_after)
		mode = AALARM_MODE_CYCLE
	// Propagate settings.
	if(propagate)
		var/area/this_area = get_area(src)
		for (var/obj/machinery/alarm/AA in this_area)
			if ( !(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
				AA.preset=preset
				AA.apply_preset(1, 0) // Only this air alarm should send a cycle.
		apply_mode() //reapply this to update scrubbers and other things


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

/obj/machinery/alarm/Destroy()
	if(wires)
		qdel(wires)
		wires = null
	for(var/obj/machinery/computer/atmoscontrol/AC in atmos_controllers)
		if(AC.current == src)
			AC.current = null
			nanomanager.update_uis(src)

	..()

/obj/machinery/alarm/proc/first_run()
	var/area/this_area = get_area(src)
	area_uid = this_area.uid
	name = "[this_area.name] Air Alarm"

	// breathable air according to human/Life()
	/*
	TLV["oxygen"] =			list(16, 19, 135, 140) // Partial pressure, kpa
	TLV["nitrogen"] =		list(-1, -1,  -1,  -1) // Partial pressure, kpa
	TLV["carbon_dioxide"] = list(-1.0, -1.0, 5, 10) // Partial pressure, kpa
	TLV["plasma"] =			list(-1.0, -1.0, 0.2, 0.5) // Partial pressure, kpa
	TLV["other"] =			list(-1.0, -1.0, 0.5, 1.0) // Partial pressure, kpa
	TLV["pressure"] =		list(ONE_ATMOSPHERE*0.80,ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE*1.10,ONE_ATMOSPHERE*1.20) /* kpa */
	TLV["temperature"] =	list(T0C-26, T0C, T0C+40, T0C+66) // K
	*/
	apply_preset(1, 0) // Don't cycle and don't propagate.
	apply_mode() //apply mode to scrubbers and vents


/obj/machinery/alarm/initialize()
	add_self_to_holomap()
	set_frequency(frequency)
	if (!master_is_operating())
		elect_master()


/obj/machinery/alarm/process()
	if((stat & (NOPOWER|BROKEN)) || shorted || buildstage != 2)
		use_power = 0
		return

	var/turf/simulated/location = loc
	if(!istype(location))
		return//returns if loc is not simulated

	var/datum/gas_mixture/environment = location.return_air()

	// Handle temperature adjustment here.
	if(environment.temperature < target_temperature - 2 || environment.temperature > target_temperature + 2 || regulating_temperature)
		//If it goes too far, we should adjust ourselves back before stopping.
		var/actual_target_temperature = target_temperature
		if(get_danger_level(actual_target_temperature, TLV["temperature"]))
			//use the max or min safe temperature
			actual_target_temperature = Clamp(actual_target_temperature, TLV["temperature"][2], TLV["temperature"][3])

		if(!regulating_temperature)
			regulating_temperature = 1
			visible_message("\The [src] clicks as it starts [environment.temperature > target_temperature ? "cooling" : "heating"] the room.",\
			"You hear a click and a faint electronic hum.")

		var/datum/gas_mixture/gas = environment.remove_volume(0.25 * CELL_VOLUME)
		if(gas)
			var/heat_capacity = gas.heat_capacity()
			var/energy_used = min(abs(heat_capacity * (gas.temperature - actual_target_temperature)), MAX_ENERGY_CHANGE)
			var/cooled = 0 //1 means we cooled this tick, 0 means we warmed. Used for the message below.

			// We need to cool ourselves, but only if the gas isn't already colder than what we can do.
			if (environment.temperature > actual_target_temperature && gas.temperature >= MIN_TEMPERATURE)
				gas.temperature -= energy_used / heat_capacity
				use_power(energy_used/3) //these are heat pumps, so they can have a >100% efficiency, typically about 300%
				cooled = 1
			// We need to warm ourselves, but only if the gas isn't already hotter than what we can do.
			else if (environment.temperature < actual_target_temperature && gas.temperature <= MAX_TEMPERATURE)
				gas.temperature += energy_used / heat_capacity
				use_power(energy_used/3)

			environment.merge(gas)

			if (abs(environment.temperature - actual_target_temperature) <= 0.5)
				regulating_temperature = 0
				visible_message("\The [src] clicks quietly as it stops [cooled ? "cooling" : "heating"] the room.",\
				"You hear a click as a faint electronic humming stops.")

	var/old_level = local_danger_level
	var/new_danger = calculate_local_danger_level(environment)

	if (new_danger < old_level)
		danger_averted_confidence++
		use_power = 1

	// Only change danger level if:
	// we're going up a level
	// OR if we're going down a level and have sufficient confidence (prevents spamming update_icon).
	if (old_level < new_danger || (danger_averted_confidence >= 5 && new_danger < old_level))
		setDangerLevel(new_danger)
		update_icon()
		danger_averted_confidence = 0 // Reset counter.
		use_power = 2

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
	return

/obj/machinery/alarm/proc/calculate_local_danger_level(const/datum/gas_mixture/environment)
	if (wires.IsIndexCut(AALARM_WIRE_AALARM))
		return 2 // MAXIMUM ALARM (With gravelly voice) - N3X.

	if (isnull(environment))
		return 0

	var/other_moles
	for(var/g in environment.gas)
		switch(g)
			if(CHECKED_GAS)
				//Do nothing
			else
				other_moles += environment[g]


	var/pressure_dangerlevel = get_danger_level(environment.pressure, TLV["pressure"])
	var/oxygen_dangerlevel = get_danger_level(environment.partial_pressure(GAS_OXYGEN), TLV["oxygen"])
	var/nitrogen_dangerlevel = get_danger_level(environment.partial_pressure(GAS_NITROGEN), TLV["nitrogen"])
	var/co2_dangerlevel = get_danger_level(environment.partial_pressure(GAS_CARBON), TLV["carbon_dioxide"])
	var/plasma_dangerlevel = get_danger_level(environment.partial_pressure(GAS_PLASMA), TLV["plasma"])
	var/temperature_dangerlevel = get_danger_level(environment.temperature, TLV["temperature"])
	var/n2o_dangerlevel = get_danger_level(environment.partial_pressure(GAS_SLEEPING), TLV["n2o"])
	var/other_dangerlevel = get_danger_level(other_moles / environment.total_moles * environment.pressure, TLV["other"])

	return max(
		pressure_dangerlevel,
		oxygen_dangerlevel,
		co2_dangerlevel,
		nitrogen_dangerlevel,
		plasma_dangerlevel,
		n2o_dangerlevel,
		other_dangerlevel,
		temperature_dangerlevel
		)

/obj/machinery/alarm/proc/master_is_operating()
	var/area/this_area = get_area(src)
	return this_area.master_air_alarm && !(this_area.master_air_alarm.stat & (NOPOWER|BROKEN))


/obj/machinery/alarm/proc/elect_master()
	var/area/this_area = get_area(src)
	for (var/obj/machinery/alarm/AA in this_area)
		if (!(AA.stat & (NOPOWER|BROKEN)))
			this_area.master_air_alarm = AA
			return 1
	return 0

/obj/machinery/alarm/proc/get_danger_level(const/current_value, const/list/danger_levels)
	if(!danger_levels || !danger_levels.len)
		return 0
	if ((current_value >= danger_levels[4] && danger_levels[4] > 0) || current_value <= danger_levels[1])
		return 2
	if ((current_value >= danger_levels[3] && danger_levels[3] > 0) || current_value <= danger_levels[2])
		return 1

	return 0

/obj/machinery/alarm/update_icon()
	if(wiresexposed)
		icon_state = "alarmx"
		return
	if((stat & (NOPOWER|BROKEN)) || shorted)
		icon_state = "alarmp"
		return
	var/area/this_area = get_area(src)
	switch(max(local_danger_level, this_area.atmosalm-1))
		if (0)
			icon_state = "alarm0"
		if (1)
			icon_state = "alarm2" //yes, alarm2 is yellow alarm
		if (2)
			icon_state = "alarm1"

/obj/machinery/alarm/receive_signal(datum/signal/signal)
	var/area/this_area = get_area(src)
	if(stat & (NOPOWER|BROKEN) || !this_area)
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

	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = command
	signal.data["tag"] = target
	signal.data["sigtype"] = "command"

	radio_connection.post_signal(src, signal, RADIO_FROM_AIRALARM)
//			to_chat(world, text("Signal [] Broadcasted to []", command, target))

	return 1

/obj/machinery/alarm/proc/set_temperature(var/temp, var/propagate=1)
	target_temperature = temp
	//propagate to other air alarms in the area
	if(propagate)
		var/area/this_area = get_area(src)
		for (var/obj/machinery/alarm/AA in this_area)
			if (!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
				AA.target_temperature = temp

/obj/machinery/alarm/proc/set_threshold(var/env, var/index, var/value, var/propagate=1)
	var/list/selected = TLV[env]
	if (value<0)
		selected[index] = -1.0
	else if (env=="temperature" && value>5000)
		selected[index] = 5000
	else if (env=="pressure" && value>50*ONE_ATMOSPHERE)
		selected[index] = 50*ONE_ATMOSPHERE
	else if (env!="temperature" && env!="pressure" && value>200)
		selected[index] = 200
	else
		value = round(value,0.01)
		selected[index] = value
	//blegh
	if(index == 1)
		if(selected[1] > selected[2])
			selected[2] = selected[1]
		if(selected[1] > selected[3])
			selected[3] = selected[1]
		if(selected[1] > selected[4])
			selected[4] = selected[1]
	if(index == 2)
		if(selected[1] > selected[2])
			selected[1] = selected[2]
		if(selected[2] > selected[3])
			selected[3] = selected[2]
		if(selected[2] > selected[4])
			selected[4] = selected[2]
	if(index == 3)
		if(selected[1] > selected[3])
			selected[1] = selected[3]
		if(selected[2] > selected[3])
			selected[2] = selected[3]
		if(selected[3] > selected[4])
			selected[4] = selected[3]
	if(index == 4)
		if(selected[1] > selected[4])
			selected[1] = selected[4]
		if(selected[2] > selected[4])
			selected[2] = selected[4]
		if(selected[3] > selected[4])
			selected[3] = selected[4]

	//propagate to other air alarms in the area
	if(propagate)
		apply_mode()
		var/area/this_area = get_area(src)
		for (var/obj/machinery/alarm/AA in this_area)
			if (!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
				AA.set_threshold(env, index, value, 0)

/obj/machinery/alarm/proc/set_alarm(var/alarm, var/propagate=1)
	alarmActivated = alarm
	update_icon()
	if(propagate)
		var/area/this_area = get_area(src)
		for (var/obj/machinery/alarm/AA in this_area)
			if (!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
				AA.set_alarm(alarm, 0)
		this_area.updateDangerLevel()

/obj/machinery/alarm/proc/apply_mode()
	var/list/current_pressures = TLV["pressure"]
	var/target_pressure = (current_pressures[2] + current_pressures[3])/2
	var/area/this_area = get_area(src)
	switch(mode)
		if(AALARM_MODE_SCRUBBING)
			for(var/device_id in this_area.air_scrub_names)
				var/datum/airalarm_preset/presetdata = airalarm_presets[preset]
				if(!presetdata)
					presetdata = new /datum/airalarm_preset/human()
				var/o2 = presetdata.scrubbers_gases["oxygen"]
				var/n2 = presetdata.scrubbers_gases["nitrogen"]
				var/co2 = presetdata.scrubbers_gases["carbon_dioxide"]
				var/n2o = presetdata.scrubbers_gases["n2o"]
				var/plasma = presetdata.scrubbers_gases["plasma"]
				send_signal(device_id, list("power"= 1, "co2_scrub"= co2, "o2_scrub" = o2, "n2_scrub" = n2, "tox_scrub" = plasma, "n2o_scrub" = n2o, "scrubbing"= 1, "panic_siphon"= 0) )
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

	var/datum/signal/alert_signal = getFromPool(/datum/signal)
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
	if(aidisabled)
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

	var/list/current_settings = TLV["pressure"]
	var/pressure_dangerlevel = get_danger_level(environment.pressure, current_settings)

	current_settings = TLV["oxygen"]
	var/oxygen_dangerlevel = get_danger_level(environment.partial_pressure(GAS_OXYGEN), current_settings)
	var/oxygen_percent = round(environment[GAS_OXYGEN] / total * 100, 2)

	current_settings = TLV["nitrogen"]
	var/nitrogen_dangerlevel = get_danger_level(environment.partial_pressure(GAS_NITROGEN), current_settings)
	var/nitrogen_percent = round(environment[GAS_NITROGEN] / total * 100, 2)

	current_settings = TLV["carbon_dioxide"]
	var/co2_dangerlevel = get_danger_level(environment.partial_pressure(GAS_CARBON), current_settings)
	var/co2_percent = round(environment[GAS_CARBON] / total * 100, 2)

	current_settings = TLV["plasma"]
	var/plasma_dangerlevel = get_danger_level(environment.partial_pressure(GAS_PLASMA), current_settings)
	var/plasma_percent = round(environment[GAS_PLASMA] / total * 100, 2)

	current_settings = TLV["n2o"]
	var/n2o_dangerlevel = get_danger_level(environment.partial_pressure(GAS_SLEEPING), current_settings)
	var/n2o_percent = round(environment[GAS_SLEEPING] / total * 100, 2)

	current_settings = TLV["other"]
	var/other_moles
	for(var/g in environment.gas)
		switch(g)
			if(CHECKED_GAS)
				//Do nothing
			else
				other_moles += environment[g]
	var/other_dangerlevel = get_danger_level(other_moles / total * environment.pressure, current_settings)
	var/other_percent = round(other_moles / total * 100, 2)

	current_settings = TLV["temperature"]
	var/temperature_dangerlevel = get_danger_level(environment.temperature, current_settings)


	var/data[0]
	data["pressure"]=environment.pressure
	data["temperature"]=environment.temperature
	data["temperature_c"]=round(environment.temperature - T0C, 0.1)

	var/percentages[0]
	percentages["oxygen"]=oxygen_percent
	percentages["nitrogen"]=nitrogen_percent
	percentages["co2"]=co2_percent
	percentages["plasma"]=plasma_percent
	percentages["n2o"]=n2o_percent
	percentages["other"]=other_percent
	data["contents"]=percentages

	var/danger[0]
	danger["pressure"]=pressure_dangerlevel
	danger["temperature"]=temperature_dangerlevel
	danger["oxygen"]=oxygen_dangerlevel
	danger["nitrogen"]=nitrogen_dangerlevel
	danger["co2"]=co2_dangerlevel
	danger["plasma"]=plasma_dangerlevel
	danger["n2o"]=n2o_dangerlevel
	danger["other"]=other_dangerlevel
	danger["overall"]=max(pressure_dangerlevel,oxygen_dangerlevel,nitrogen_dangerlevel,co2_dangerlevel,plasma_dangerlevel,other_dangerlevel,temperature_dangerlevel)
	data["danger"]=danger
	return data

/obj/machinery/alarm/proc/get_nano_data(mob/user, fromAtmosConsole=0)
	var/area/this_area = get_area(src)
	var/data[0]
	data["air"]=ui_air_status()
	data["alarmActivated"]=alarmActivated //|| local_danger_level==2
	data["sensors"]=TLV

	// Locked when:
	//   Not sent from atmos console AND
	//   Not silicon AND locked AND
	//   NOT adminghost.
	data["locked"]=!fromAtmosConsole && (!(istype(user, /mob/living/silicon)) && locked) && !isAdminGhost(user)

	data["rcon"]=rcon_setting
	data["rcon_enabled"] = remote_control
	data["target_temp"] = target_temperature - T0C
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
		var/datum/airalarm_preset/preset_datum = airalarm_presets[preset]
		tmplist[++tmplist.len] = list("name" = preset_datum.name, "desc" = preset_datum.desc)
	data["presets"] = tmplist
	data["preset"]=preset
	data["screen"]=screen
	data["cycle_after_preset"] = cycle_after_preset
	data["firedoor_override"] = this_area.doors_overridden

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

/obj/machinery/alarm/Topic(href, href_list)
	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1
	if(..())
		return 1
	if(href_list["rcon"])
		if(locked && !issilicon(usr) && !usr.hasFullAccess())
			return 1
		rcon_setting = text2num(href_list["rcon"])
		//propagate to other AAs in the area
		var/area/this_area = get_area(src)
		for (var/obj/machinery/alarm/AA in this_area)
			if ( !(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
				AA.rcon_setting = rcon_setting
		return 1

	add_fingerprint(usr)

	//testing(href)
	if(href_list["command"])
		if(locked && !issilicon(usr) && !usr.hasFullAccess())
			return 1
		var/device_id = href_list["id_tag"]
		switch(href_list["command"])
			if( "power",
				"set_external_pressure",
				"set_internal_pressure",
				"checks",
				"co2_scrub",
				"tox_scrub",
				"n2o_scrub",
				"o2_scrub",
				"n2_scrub",
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
						if(newval>1000+ONE_ATMOSPHERE)
							newval = 1000+ONE_ATMOSPHERE
						if(newval<0)
							newval = 0
					val = newval

				send_signal(device_id, list(href_list["command"] = val ) )

			if("set_threshold")
				var/env = href_list["env"]
				var/threshold = text2num(href_list["var"])
				var/list/selected = TLV[env]
				var/list/thresholds = list("lower bound", "low warning", "high warning", "upper bound")
				var/newval = input("Enter [thresholds[threshold]] for [env]", "Alarm triggers", selected[threshold]) as num|null
				if (isnull(newval) || ..() || (locked && !issilicon(usr) && !usr.hasFullAccess()))
					return 1
				set_threshold(env, threshold, newval, 1)
		return 1
	if(href_list["reset_thresholds"])
		if(locked && !issilicon(usr) && !usr.hasFullAccess())
			return 1
		apply_preset(1) //just apply the preset without cycling
		return 1

	if(href_list["screen"])
		screen = text2num(href_list["screen"])
		return 1

	if(href_list["atmos_alarm"])
		if(locked && !issilicon(usr) && !usr.hasFullAccess())
			return 1
		set_alarm(1)
		return 1

	if(href_list["atmos_reset"])
		if(locked && !issilicon(usr) && !usr.hasFullAccess())
			return 1
		set_alarm(0)
		return 1

	if(href_list["enable_override"])
		if(locked && !issilicon(usr) && !usr.hasFullAccess())
			return 1
		var/area/this_area = get_area(src)
		this_area.doors_overridden = 1
		this_area.UpdateFirelocks()
		update_icon()
		return 1

	if(href_list["disable_override"])
		if(locked && !issilicon(usr) && !usr.hasFullAccess())
			return 1
		var/area/this_area = get_area(src)
		this_area.doors_overridden = 0
		this_area.UpdateFirelocks()
		update_icon()
		return 1

	if(href_list["mode"])
		if(locked && !issilicon(usr) && !usr.hasFullAccess())
			return 1
		mode = text2num(href_list["mode"])
		apply_mode()
		return 1

	if(href_list["toggle_cycle_after_preset"])
		if(locked && !issilicon(usr) && !usr.hasFullAccess())
			return 1
		cycle_after_preset = !cycle_after_preset
		return 1

	if(href_list["preset"])
		if(locked && !issilicon(usr) && !usr.hasFullAccess())
			return 1
		if(href_list["preset"] in airalarm_presets)
			preset = href_list["preset"]
			apply_preset(!cycle_after_preset)
		return 1

	if(href_list["temperature"])
		var/list/selected = TLV["temperature"]
		var/max_temperature
		var/min_temperature
		if(!locked || issilicon(usr) || usr.hasFullAccess())
			max_temperature = MAX_TARGET_TEMPERATURE - T0C
			min_temperature = MIN_TARGET_TEMPERATURE - T0C
		else
			max_temperature = selected[3] - T0C
			min_temperature = selected[2] - T0C
		var/input_temperature = input("What temperature (in C) would you like the system to target? (Capped between [min_temperature]C and [max_temperature]C).\n\nNote that the cooling unit in this air alarm can not go below [MIN_TEMPERATURE]C or above [MAX_TEMPERATURE]C by itself. ", "Thermostat Controls") as num|null
		if(input_temperature==null)
			return 1
		if(!input_temperature || input_temperature >= max_temperature || input_temperature <= min_temperature)
			to_chat(usr, "<span class='warning'>Temperature must be between [min_temperature]C and [max_temperature]C.</span>")
		else
			input_temperature = input_temperature + T0C
			set_temperature(input_temperature)
		return 1

/obj/machinery/alarm/attackby(obj/item/W as obj, mob/user as mob)
	src.add_fingerprint(user)

	switch(buildstage)
		if(2)
			if(W.is_screwdriver(user))  // Opening that Air Alarm up.
				wiresexposed = !wiresexposed
				to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"].")
				playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
				update_icon()
				return

			if(wiresexposed && !wires.IsAllCut() && iswiretool(W))
				return attack_hand(user)
			else if(wiresexposed && wires.IsAllCut() && iswirecutter(W))
				buildstage = 1
				update_icon()
				user.visible_message("<span class='attack'>[user] has cut the wiring from \the [src]!</span>", "You have cut the last of the wiring from \the [src].")
				playsound(src, 'sound/items/Wirecutter.ogg', 50, 1)
				getFromPool(/obj/item/stack/cable_coil, get_turf(user), 5)
				return
			if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))// trying to unlock the interface with an ID card
				if(stat & (NOPOWER|BROKEN))
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
				playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
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

			else if(iswrench(W))
				to_chat(user, "You remove the air alarm assembly from the wall!")
				new /obj/item/mounted/frame/alarm_frame(get_turf(user))
				playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
				qdel(src)
				return

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
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	var/last_process = 0
	var/wiresexposed = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone
	var/shelter = 1
	var/alarm = 0

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
		return

	if(stat & BROKEN)
		icon_state = "firex"
	else if(stat & NOPOWER)
		icon_state = "firep"
	else
		icon_state = "fire[detecting ? "0" : "1"][shelter ? "s" : "e"]"
		if(z == 1 && security_level)
			src.overlays += image('icons/obj/monitors.dmi', "overlay_[get_security_level()]")
		else
			src.overlays += image('icons/obj/monitors.dmi', "overlay_green")

/obj/machinery/firealarm/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(src.detecting)
		if(exposed_temperature > T0C+200)
			src.alarm()			// added check of detector status here

/obj/machinery/firealarm/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/firealarm/bullet_act(BLAH)
	return src.alarm()

/obj/machinery/firealarm/CtrlClick(var/mob/user)
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
	src.add_fingerprint(user)

	if (istype(W,/obj/item/inflatable/shelter))
		qdel(W)
		shelter = TRUE
		update_icon()
		return

	if (W.is_screwdriver(user) && buildstage == 2)
		wiresexposed = !wiresexposed
		to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"].")
		playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
		update_icon()
		return

	if(wiresexposed)
		switch(buildstage)
			if(2)
				if (ismultitool(W))
					src.detecting = !( src.detecting )
					user.visible_message("<span class='attack'>[user] has [detecting ? "re" : "dis"]connected [src]'s detecting unit!</span>", "You have [detecting ? "re" : "dis"]reconnected [src]'s detecting unit.")
					playsound(src, 'sound/items/healthanalyzer.ogg', 50, 1)
				if(iswirecutter(W))
					to_chat(user, "You begin to cut the wiring...")
					playsound(src, 'sound/items/Wirecutter.ogg', 50, 1)
					if (do_after(user, src,  50) && buildstage == 2 && wiresexposed)
						buildstage=1
						user.visible_message("<span class='attack'>[user] has cut the wiring from \the [src]!</span>", "You have cut the last of the wiring from \the [src].")
						update_icon()
						getFromPool(/obj/item/stack/cable_coil, get_turf(user), 5)
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
					playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
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

				else if(iswrench(W))
					to_chat(user, "You remove the fire alarm assembly from the wall!")
					new /obj/item/mounted/frame/firealarm(get_turf(user))
					playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
					qdel(src)
		return

	src.alarm()

/obj/machinery/firealarm/process()
	if(stat & (NOPOWER|BROKEN))
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
	if((user.stat && !isobserver(user)) || stat & (NOPOWER|BROKEN))
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
				if(Adjacent(usr)&&!isAdminGhost(usr)) //Silicons AND adminghosts drop it to the floor
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
	if (!( src.working ))
		return
	var/area/this_area = get_area(src)
	this_area.firealert()
	update_icon()
	alarm = 1
	//playsound(src, 'sound/ambience/signal.ogg', 75, 0)

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
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6

/obj/machinery/partyalarm/New()
	..()
	var/area/this_area = get_area(src)
	name = "[this_area.name] party alarm"

/obj/machinery/partyalarm/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/partyalarm/attack_hand(mob/user as mob)
	if((user.stat && !isobserver(user)) || stat & (NOPOWER|BROKEN))
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
	if (usr.stat || stat & (BROKEN|NOPOWER))
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



#undef CHECKED_GAS
