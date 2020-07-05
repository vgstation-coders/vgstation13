/datum/automation/set_cooler_state
	name = "Thermoelectric Cooler: Power"
	var/cooler = null
	var/state = 0

/datum/automation/set_cooler_state/Export()
	var/list/json = ..()
	json["cooler"] = cooler
	json["state"] = state
	return json

/datum/automation/set_cooler_state/Import(list/json)
	..(json)
	cooler = json["cooler"]
	state = text2num(json["state"])

/datum/automation/set_cooler_state/process()
	if(cooler)
		parent.send_signal(list("tag" = cooler, "command" = "cooler_set","state" = state))
	return 0

/datum/automation/set_cooler_state/GetText()
	return "Set thermoelectric cooler <a href=\"?src=\ref[src];set_subject=1\">[fmtString(cooler)]</a> to <a href=\"?src=\ref[src];set_state=1\">[state?"on":"off"]</a>."

/datum/automation/set_cooler_state/Topic(href, href_list)
	if(href_list["set_state"])
		state = !state
		parent.updateUsrDialog()
		return 1
	if(href_list["set_subject"])
		var/list/coolers = list()
		for(var/obj/machinery/atmospherics/binary/heat_pump/C in atmos_machines)
			if(!isnull(C.id_tag) && C.frequency == parent.frequency)
				coolers |= C.id_tag
		if(coolers.len == 0)
			to_chat(usr, "<span class='warning'>Unable to find any thermoelectric coolers on this frequency.</span>")
			return
		cooler = input("Select a thermoelectric cooler:", "Sensor Data", cooler) as null|anything in coolers
		parent.updateUsrDialog()
		return 1
