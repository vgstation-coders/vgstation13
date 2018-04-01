/obj/machinery/atmospherics/components/trinary/filter
	name = "gas filter"
	icon_state = "filter_off"
	desc = "Very useful for filtering gasses."
	density = FALSE
	can_unwrench = TRUE
	var/on = FALSE
	var/target_pressure = ONE_ATMOSPHERE
	var/filter_type = null
	var/frequency = 0
	var/datum/radio_frequency/radio_connection

	construction_type = /obj/item/pipe/trinary/flippable
	pipe_state = "filter"

/obj/machinery/atmospherics/components/trinary/filter/flipped
	icon_state = "filter_off_f"
	flipped = TRUE

// These two filter types have critical_machine flagged to on and thus causes the area they are in to be exempt from the Grid Check event.

/obj/machinery/atmospherics/components/trinary/filter/critical
	critical_machine = TRUE

/obj/machinery/atmospherics/components/trinary/filter/flipped/critical
	critical_machine = TRUE

/obj/machinery/atmospherics/components/trinary/filter/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/trinary/filter/Destroy()
	SSradio.remove_object(src,frequency)
	return ..()

/obj/machinery/atmospherics/components/trinary/filter/atmos //Used for atmos waste loops
	on = TRUE
	icon_state = "filter_on"
	
/obj/machinery/atmospherics/components/trinary/filter/atmos/n2
	name = "nitrogen filter"
	filter_type = "n2"
/obj/machinery/atmospherics/components/trinary/filter/atmos/o2
	name = "oxygen filter"
	filter_type = "o2"
/obj/machinery/atmospherics/components/trinary/filter/atmos/co2
	name = "carbon dioxide filter"
	filter_type = "co2"
/obj/machinery/atmospherics/components/trinary/filter/atmos/n2o
	name = "nitrous oxide filter"
	filter_type = "n2o"
/obj/machinery/atmospherics/components/trinary/filter/atmos/plasma
	name = "plasma filter"
	filter_type = "plasma"

/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped //This feels wrong, I know
	icon_state = "filter_on_f"
	flipped = TRUE
	
/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped/n2
	name = "nitrogen filter"
	filter_type = "n2"
/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped/o2
	name = "oxygen filter"
	filter_type = "o2"
/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped/co2
	name = "carbon dioxide filter"
	filter_type = "co2"
/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped/n2o
	name = "nitrous oxide filter"
	filter_type = "n2o"
/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped/plasma
	name = "plasma filter"
	filter_type = "plasma"
	
/obj/machinery/atmospherics/components/trinary/filter/update_icon()
	cut_overlays()
	for(var/direction in GLOB.cardinals)
		if(direction & initialize_directions)
			var/obj/machinery/atmospherics/node = findConnecting(direction)
			if(node)
				add_overlay(getpipeimage('icons/obj/atmospherics/components/trinary_devices.dmi', "cap", direction, node.pipe_color))
				continue
			add_overlay(getpipeimage('icons/obj/atmospherics/components/trinary_devices.dmi', "cap", direction))
	..()

/obj/machinery/atmospherics/components/trinary/filter/update_icon_nopipes()
	if(on && nodes[1] && nodes[2] && nodes[3] && is_operational())
		icon_state = "filter_on[flipped?"_f":""]"
		return
	icon_state = "filter_off[flipped?"_f":""]"

/obj/machinery/atmospherics/components/trinary/filter/power_change()
	var/old_stat = stat
	..()
	if(stat != old_stat)
		update_icon()

/obj/machinery/atmospherics/components/trinary/filter/process_atmos()
	..()
	if(!on || !(nodes[1] && nodes[2] && nodes[3]) || !is_operational())
		return

	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/air2 = airs[2]
	var/datum/gas_mixture/air3 = airs[3]

	var/output_starting_pressure = air3.return_pressure()

	if(output_starting_pressure >= target_pressure)
		//No need to transfer if target is already full!
		return

	//Calculate necessary moles to transfer using PV=nRT

	var/pressure_delta = target_pressure - output_starting_pressure
	var/transfer_moles

	if(air1.temperature > 0)
		transfer_moles = pressure_delta*air3.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

	//Actually transfer the gas

	if(transfer_moles > 0)
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)

		if(!removed)
			return

		var/filtering = TRUE
		if(!ispath(filter_type))
			if(filter_type)
				filter_type = gas_id2path(filter_type) //support for mappers so they don't need to type out paths
			else
				filtering = FALSE

		if(filtering && removed.gases[filter_type])
			var/datum/gas_mixture/filtered_out = new

			filtered_out.temperature = removed.temperature
			filtered_out.add_gas(filter_type)
			filtered_out.gases[filter_type][MOLES] = removed.gases[filter_type][MOLES]

			removed.gases[filter_type][MOLES] = 0
			removed.garbage_collect()

			var/datum/gas_mixture/target = (air2.return_pressure() < target_pressure ? air2 : air1) //if there's no room for the filtered gas; just leave it in air1
			target.merge(filtered_out)

		air3.merge(removed)

	update_parents()

/obj/machinery/atmospherics/components/trinary/filter/atmosinit()
	set_frequency(frequency)
	return ..()

/obj/machinery/atmospherics/components/trinary/filter/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
																	datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_filter", name, 475, 195, master_ui, state)
		ui.open()

/obj/machinery/atmospherics/components/trinary/filter/ui_data()
	var/data = list()
	data["on"] = on
	data["pressure"] = round(target_pressure)
	data["max_pressure"] = round(MAX_OUTPUT_PRESSURE)

	data["filter_types"] = list()
	data["filter_types"] += list(list("name" = "Nothing", "path" = "", "selected" = !filter_type))
	for(var/path in GLOB.meta_gas_info)
		var/list/gas = GLOB.meta_gas_info[path]
		data["filter_types"] += list(list("name" = gas[META_GAS_NAME], "id" = gas[META_GAS_ID], "selected" = (path == gas_id2path(filter_type))))

	return data

/obj/machinery/atmospherics/components/trinary/filter/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "max")
				pressure = MAX_OUTPUT_PRESSURE
				. = TRUE
			else if(pressure == "input")
				pressure = input("New output pressure (0-[MAX_OUTPUT_PRESSURE] kPa):", name, target_pressure) as num|null
				if(!isnull(pressure) && !..())
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				target_pressure = CLAMP(pressure, 0, MAX_OUTPUT_PRESSURE)
				investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", INVESTIGATE_ATMOS)
		if("filter")
			filter_type = null
			var/filter_name = "nothing"
			var/gas = gas_id2path(params["mode"])
			if(gas in GLOB.meta_gas_info)
				filter_type = gas
				filter_name	= GLOB.meta_gas_info[gas][META_GAS_NAME]
			investigate_log("was set to filter [filter_name] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
	update_icon()

/obj/machinery/atmospherics/components/trinary/filter/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational())
		to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
		return FALSE
