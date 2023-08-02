// --- Conditional Valve Status: Enabled/Disabled ---
/datum/automation/set_conditional_valve_status
	name = "Conditional Valve: Status"
	var/cvalve = null
	var/enable = FALSE

/datum/automation/set_conditional_valve_status/Export()
	var/list/json = ..()
	json["cvalve"]=cvalve
	json["enable"]=enable
	return json

/datum/automation/set_conditional_valve_status/Import(var/list/json)
	..(json)
	cvalve = json["cvalve"]
	enable = text2num(json["enable"])

/datum/automation/set_conditional_valve_status/process()
	if(cvalve)
		parent.send_signal(list ("tag" = cvalve, "command" = "enable", "enable" = enable))
	return 0

/datum/automation/set_conditional_valve_status/GetText()
	// [Enable|Disable] conditional valve "valve_id"
	return "<a href=\"?src=\ref[src];set_enable=1\">[enable?"Enable":"Disable"]</a> conditional valve <a href=\"?src=\ref[src];set_subject=1\">[fmtString(cvalve)]</a>"

/datum/automation/set_conditional_valve_status/Topic(href,href_list)
	if(href_list["set_enable"])
		enable =! enable
		parent.updateUsrDialog()
		return 1

	if(href_list["set_subject"])
		var/list/cvalves=list()
		for(var/obj/machinery/atmospherics/trinary/pressure_valve/digital/V in atmos_machines)
			if(!isnull(V.id_tag) && V.frequency == parent.frequency)
				cvalves |= V.id_tag
		if(cvalves.len == 0)
			to_chat(usr, "<span class='warning'>Unable to find any conditional valves on this frequency.</span>")
			return
		cvalve = input("Select a valve:", "Sensor Data", cvalve) as null | anything in cvalves
		parent.updateUsrDialog()
		return 1
