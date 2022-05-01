// --- Pressure Valve Status: Enabled/Disabled ---
/datum/automation/set_pressure_valve_status
	name = "Pressure Valve: Status"
	var/pvalve = null
	var/enable = FALSE

/datum/automation/set_pressure_valve_status/Export()
	var/list/json = ..()
	json["pvalve"]=pvalve
	json["enable"]=enable
	return json

/datum/automation/set_pressure_valve_status/Import(var/list/json)
	..(json)
	pvalve = json["pvalve"]
	enable = text2num(json["enable"])

/datum/automation/set_pressure_valve_status/process()
	if(pvalve)
		parent.send_signal(list ("tag" = pvalve, "command" = "enable", "enable" = enable))
	return 0

/datum/automation/set_pressure_valve_status/GetText()
	// Enable/Disable pressure valve "valve_id"
	return "<a href=\"?src=\ref[src];set_enable=1\">[enable?"Enable":"Disable"]</a> pressure valve <a href=\"?src=\ref[src];set_subject=1\">[fmtString(pvalve)]</a>"

/datum/automation/set_pressure_valve_status/Topic(href,href_list)
	if(href_list["set_enable"])
		enable =! enable
		parent.updateUsrDialog()
		return 1

	if(href_list["set_subject"])
		var/list/pvalves=list()
		for(var/obj/machinery/atmospherics/trinary/pressure_valve/digital/V in atmos_machines)
			if(!isnull(V.id_tag) && V.frequency == parent.frequency)
				pvalves |= V.id_tag
		if(pvalves.len == 0)
			to_chat(usr, "<span class='warning'>Unable to find any pressure valves on this frequency.</span>")
			return
		pvalve = input("Select a valve:", "Sensor Data", pvalve) as null | anything in pvalves
		parent.updateUsrDialog()
		return 1

// --- Pressure Valve Mode: Threshold and Above/Below ---
/datum/automation/set_pressure_valve_mode
	name = "Pressure Valve: Mode"
	var/pvalve = null
	var/threshold = 0
	var/above = TRUE // Open if pressure above/below threshold


/datum/automation/set_pressure_valve_mode/Export()
	var/list/json = ..()
	json["pvalve"]=pvalve
	json["threshold"]=threshold
	json["above"]=above
	return json

/datum/automation/set_pressure_valve_mode/Import(var/list/json)
	..(json)
	pvalve = json["pvalve"]
	threshold = text2num(json["threshold"])
	above = text2num(json["above"])

/datum/automation/set_pressure_valve_mode/process()
	if(pvalve)
		parent.send_signal(list ("tag" = pvalve, "command" = "mode", "above" = above, "threshold" = threshold))
	return 0

/datum/automation/set_pressure_valve_mode/GetText()
	// Set pressure valve "valve_id" to open while above/below a threshold of X kPa.
	return "Set pressure valve <a href=\"?src=\ref[src];set_subject=1\">[fmtString(pvalve)]</a> to open while <a href=\"?src=\ref[src];set_above=1\">[above?"above":"below"]</a> a threshold of <a href=\"?src=\ref[src];set_threshold=1\">[threshold]</a> kPa."

/datum/automation/set_pressure_valve_mode/Topic(href,href_list)
	if(href_list["set_above"])
		above =! above
		parent.updateUsrDialog()
		return 1

	if(href_list["set_threshold"])
		threshold = max(0, input("Set threshold pressure in kPa.", "Pressure", threshold) as num)
		parent.updateUsrDialog()
		return 1

	if(href_list["set_subject"])
		var/list/pvalves=list()
		for(var/obj/machinery/atmospherics/trinary/pressure_valve/digital/V in atmos_machines)
			if(!isnull(V.id_tag) && V.frequency == parent.frequency)
				pvalves |= V.id_tag
		if(pvalves.len == 0)
			to_chat(usr, "<span class='warning'>Unable to find any pressure valves on this frequency.</span>")
			return
		pvalve = input("Select a valve:", "Sensor Data", pvalve) as null | anything in pvalves
		parent.updateUsrDialog()
		return 1
