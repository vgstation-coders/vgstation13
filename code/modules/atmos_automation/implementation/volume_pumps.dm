/datum/automation/set_volume_pump_power
	name = "Volume Pump: Power"
	var/pump = null
	var/state = 0

/datum/automation/set_volume_pump_power/Export()
	var/list/json = ..()
	json["pump"] = pump
	json["state"] = state
	return json

/datum/automation/set_volume_pump_power/Import(var/list/json)
	..(json)
	pump = json["pump"]
	state = text2num(json["state"])

/datum/automation/set_volume_pump_power/process()
	if(pump)
		parent.send_signal(list("tag" = pump, "command" = "power", "value" = state, "type" = SIGNAL_TYPE_ATMOS_VOLUME_PUMP))
	return 0

/datum/automation/set_volume_pump_power/GetText()
	return "Set volume pump <a href=\"?src=\ref[src];set_pump=1\">[fmtString(pump)]</a> power to <a href=\"?src=\ref[src];toggle_state=1\">[state ? "on" : "off"]</a>."

/datum/automation/set_volume_pump_power/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["toggle_state"])
		state = !state
		parent.updateUsrDialog()
		return 1

	if(href_list["set_pump"])
		var/list/pump_names = list()
		for(var/obj/machinery/atmospherics/binary/volume_pump/I in atmos_machines)
			if(!isnull(I.id_tag) && I.frequency == parent.frequency)
				pump_names |= I.id_tag

		pump = input("Select a pump:", "Sensor Data", pump) as null | anything in pump_names
		parent.updateUsrDialog()
		return 1

/datum/automation/set_volume_pump_rate
	name = "Volume Pump: Rate"
	var/pump = null
	var/rate = 0

/datum/automation/set_volume_pump_rate/Export()
	var/list/json = ..()
	json["pump"] = pump
	json["rate"] = rate
	return json

/datum/automation/set_volume_pump_rate/Import(var/list/json)
	..(json)
	pump = json["pump"]
	rate = text2num(json["rate"])

/datum/automation/set_volume_pump_rate/process()
	if(pump)
		parent.send_signal(list ("tag" = pump, "command" = "set_transfer_rate", "value" = rate, "type" = SIGNAL_TYPE_ATMOS_VOLUME_PUMP))
	return 0

/datum/automation/set_volume_pump_rate/GetText()
	return "Set volume pump <a href=\"?src=\ref[src];set_pump=1\">[fmtString(pump)]</a> transfer rate to <a href=\"?src=\ref[src];set_rate=1\">[rate]</a> L/s."

/datum/automation/set_volume_pump_rate/Topic(href,href_list)
	. = ..()
	if(.)
		return

	if(href_list["set_rate"])
		rate = input("Set transfer rate in L/s.", "Rate", rate) as num
		parent.updateUsrDialog()
		return 1

	if(href_list["set_pump"])
		var/list/pump_names = list()
		for(var/obj/machinery/atmospherics/binary/volume_pump/I in atmos_machines)
			if(!isnull(I.id_tag) && I.frequency == parent.frequency)
				pump_names |= I.id_tag
		if(pump_names.len == 0)
			to_chat(usr, "<span class='warning'>Unable to find any volume pump on this frequency.</span>")
		else
			pump = input("Select a pump:", "Sensor Data", pump) as null | anything in pump_names
		parent.updateUsrDialog()
		return 1
