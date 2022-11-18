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

// --- Conditional Valve Mode: Threshold and Above/Below ---
/datum/automation/set_conditional_valve_mode
	name = "Conditional Valve: Mode"
	var/cvalve = null

	var/mode = CVALVE_MODE_PRESSURE // Gas characteristic whose value will be measured and compared
	var/control_input = CVALVE_INPUT_CENTER // The pipe we will be reading a control value from
	var/threshold_source = CVALVE_THRESHOLD_CONSTANT // The threshold we will be checking our control value against. Can be `constant_threshold`, can be a value from some other pipe
	var/constant_threshold = 0 // Threshold above or below which the valve will stay open (if enabled)
	var/above = TRUE // Open if pressure above/below threshold

	var/list/mode2label = list(
		CVALVE_MODE_PRESSURE = "pressure",
		CVALVE_MODE_TEMPERATURE = "temperature"
	)

	var/list/mode2unit = list(
		CVALVE_MODE_PRESSURE = "kPA",
		CVALVE_MODE_TEMPERATURE = "K"
	)

	var/list/control2label = list(
		CVALVE_INPUT_LEFT = "left",
		CVALVE_INPUT_CENTER = "center",
		CVALVE_INPUT_RIGHT = "right"
	)

	var/list/threshold2label = list(
		CVALVE_THRESHOLD_LEFT = "the left pipe's",
		CVALVE_THRESHOLD_CONSTANT = "a given value",
		CVALVE_THRESHOLD_RIGHT = "the right pipe's"
	)

/datum/automation/set_conditional_valve_mode/Export()
	var/list/json = ..()
	json["cvalve"] = cvalve
	json["mode"] = mode
	json["above"] = above
	json["control"] = control_input
	json["threshold"] = threshold_source
	json["constant"] = constant_threshold
	return json

/datum/automation/set_conditional_valve_mode/Import(var/list/json)
	..(json)
	cvalve = json["cvalve"]
	mode = json["mode"]
	above = text2num(json["above"])
	control_input = json["control"]
	threshold_source = json["threshold"]
	constant_threshold = text2num(json["constant"])

/datum/automation/set_conditional_valve_mode/process()
	if(cvalve)
		parent.send_signal(list(
			"tag" = cvalve,
			"command" = "mode",
			"mode" = mode,
			"above" = above,
			"control" = control_input,
			"threshold" = threshold_source,
			"constant" = constant_threshold
		))
	return 0

/datum/automation/set_conditional_valve_mode/GetText()
	// Set conditional valve "valve_id" to open if [pressure|temperature] in the [left|center|right] pipe
	//  is [higher|lower] than [a given value of XXXX [kPA|ºK]|the [left|right] pipe's].
	return {"
		Set conditional valve <a href=\"?src=\ref[src];set_subject=1\">[fmtString(cvalve)]</a> to open
		if <a href=\"?src=\ref[src];set_mode=1\">[fmtString(mode2label[mode])]</a>
		in the <a href=\"?src=\ref[src];set_control=1\">[control2label[control_input]]</a> pipe
		is <a href=\"?src=\ref[src];toggle_condition=1\">[above ? "higher" : "lower"]</a>
		than <a href=\"?src=\ref[src];set_threshold=1\">[threshold2label[threshold_source]]</a>
		[threshold_source == CVALVE_THRESHOLD_CONSTANT? "of <a href=\"?src=\ref[src];set_constant=1\">[fmtString(constant_threshold)]</a> [mode2unit[mode]]" : ""]
	"}

/datum/automation/set_conditional_valve_mode/proc/build_input_list(original_list)
	var/list/reverse_list = list()
	for (var/i in original_list)
		reverse_list[original_list[i]] = i
	return reverse_list

/datum/automation/set_conditional_valve_mode/Topic(href,href_list)

	if (href_list["toggle_condition"])
		above = !above
		parent.updateUsrDialog()
		return 1

	if (href_list["set_mode"])
		var/list/input_list = build_input_list(mode2label)
		var/selected_mode = input("Select a value to compare:", "Compare value") as null | anything in input_list
		mode = input_list[selected_mode]
		parent.updateUsrDialog()
		return 1

	if (href_list["set_control"])
		var/list/input_list = build_input_list(control2label)
		var/selected_mode = input("Select the pipe that will control the valve:", "Control input") as null | anything in input_list
		control_input = input_list[selected_mode]
		parent.updateUsrDialog()
		return 1

	if (href_list["set_threshold"])
		var/list/input_list = build_input_list(threshold2label)
		var/selected_mode = input("Select the source of the value to use as a threshold:", "Threshold source") as null | anything in input_list
		threshold_source = input_list[selected_mode]
		parent.updateUsrDialog()
		return 1

	if(href_list["set_constant"])
		constant_threshold = input("Set threshold [mode2label[mode]], in [mode2unit[mode]].", "Threshold", constant_threshold) as num
		constant_threshold = max(0, constant_threshold)
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
		cvalve = input("Select a valve:", "Valves", cvalve) as null | anything in cvalves
		parent.updateUsrDialog()
		return 1
