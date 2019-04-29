/datum/automation/set_gas_pump_power
	name = "Gas Pump: Power"
	var/pump = null
	var/state = 0

/datum/automation/set_gas_pump_power/Export()
	var/list/json = ..()
	json["pump"] = pump
	json["state"] = state
	return json

/datum/automation/set_gas_pump_power/Import(var/list/json)
	..(json)
	pump = json["pump"]
	state = text2num(json["state"])

/datum/automation/set_gas_pump_power/process()
	if(pump)
		parent.send_signal(list("tag" = pump, "command" = "power", "value" = state, "type" = SIGNAL_TYPE_ATMOS_GAS_PUMP))
	return 0

/datum/automation/set_gas_pump_power/GetText()
	return "Set gas pump <a href=\"?src=\ref[src];set_pump=1\">[fmtString(pump)]</a> power to <a href=\"?src=\ref[src];toggle_state=1\">[state ? "on" : "off"]</a>."

/datum/automation/set_gas_pump_power/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["toggle_state"])
		state = !state
		parent.updateUsrDialog()
		return 1

	if(href_list["set_pump"])
		var/list/pump_names = list()
		for(var/obj/machinery/atmospherics/binary/pump/I in atmos_machines)
			if(!isnull(I.id_tag) && I.frequency == parent.frequency)
				pump_names |= I.id_tag

		pump = input("Select a pump:", "Sensor Data", pump) as null | anything in pump_names
		parent.updateUsrDialog()
		return 1

/datum/automation/set_gas_pump_pressure
	name = "Gas Pump: Set Pressure"
	var/pump = null
	var/pressure = 0

/datum/automation/set_gas_pump_pressure/Export()
	var/list/json = ..()
	json["pump"] = pump
	json["pressure"] = pressure
	return json

/datum/automation/set_gas_pump_pressure/Import(var/list/json)
	..(json)
	pump = json["pump"]
	pressure = text2num(json["pressure"])

/datum/automation/set_gas_pump_pressure/process()
	if(pump)
		parent.send_signal(list ("tag" = pump, "command" = "set_target_pressure", "value" = pressure, "type" = SIGNAL_TYPE_ATMOS_GAS_PUMP))
	return 0

/datum/automation/set_gas_pump_pressure/GetText()
	return "Set gas pump <a href=\"?src=\ref[src];set_pump=1\">[fmtString(pump)]</a> target pressure to <a href=\"?src=\ref[src];set_pressure=1\">[pressure]</a> kPa."

/datum/automation/set_gas_pump_pressure/Topic(href,href_list)
	. = ..()
	if(.)
		return

	if(href_list["set_pressure"])
		pressure = input("Set target pressure in kPa.", "Pressure", pressure) as num
		parent.updateUsrDialog()
		return 1

	if(href_list["set_pump"])
		var/list/pump_names = list()
		for(var/obj/machinery/atmospherics/binary/pump/I in atmos_machines)
			if(!isnull(I.id_tag) && I.frequency == parent.frequency)
				pump_names |= I.id_tag
		if(pump_names.len == 0)
			to_chat(usr, "<span class='warning'>Unable to find any gas pump on this frequency.</span>")
		else
			pump = input("Select a pump:", "Sensor Data", pump) as null | anything in pump_names
		parent.updateUsrDialog()
		return 1
