/*
 * For reference, this is the JSON being produced by ui_data() that will be sent to PowerMonitor.js:
 *
 *  {
 *      "engineer_access": Boolean. Whether the user has minor engineering access (same access as APCs). Enables priority buttons.
 *      "attached": Boolean. Whether the console is attached to a grid
 *
 *      "history": {
 *          "supply": Float List. Contains previous measurements of power available to the grid.
 *          "demand": Float List. Contains previous measurements of power requested by the grid.
 *      },
 *      "supply": String. Last measured supply, preformatted. eg: 1234.5 becomes "1.23 kW"
 *      "demand": String. Last measured demand, preformatted.
 *
 *      "areas": Map. Key is the area's \ref, value is area stats and machine list. May contain a
 *                fake "\ref[null]" area named "Other" grouping any machines whose area can't be determined
 *               Value is as follows:
 *      {
 *          "name": String. Area name
 *
 *          "demand": Float. Sum of machine and APC demand in this area.
 *          "f_demand": String. Preformatted version of "demand". eg: 1234.5 becomes "1.23 kW"
 *
 *          "charge": Float, 0 to 100. Area's APC percent charge
 *          "charging": Integer, -1 to 1. Whether the area's APC is currently charging (1), unchanged (0) or discharging (-1)
 *
 *          "eqp": Integer, 0 to 3. Whether the APC's equipment channel is off (0), auto-off (1), on (2) or auto-on (3)
 *          "lgt": Integer, 0 to 3. Whether the APC's light channel is off (0), auto-off (1), on (2) or auto-on (3)
 *          "env": Integer, 0 to 3. Whether the APC's enviroment channel is off (0), auto-off (1), on (2) or auto-on (3)
 *
 *          "machines": Map. Key is the machine's identifier, usually derived from "\ref[src]". May identify separate aspects
 *                       of the same object, eg: powering things in an APC's area (identified as "\ref[src]") vs recharging said
 *                       APC's battery (identified as "\ref[src]_b").
 *                      Value is as follows:
 *          {
 *              "ref": String, "\ref[src]". A reference, for use in Topic() calls, to the object managing this machine's priority
 *              "name": String. Machine name.
 *
 *              "priority": Integer, ranges 1 to 11. Machine priority. Keep in mind priority level 1 is reserved for
 *                           rogue power consumers (eg: syndicate tech, pulse demons) and not meant to be recognized.
 *
 *              "demand": Float. Power being requested by this machine
 *              "f_demand": String. Preformatted version of "demand". eg: 1234.5 becomes "1.23 kW"
 *
 *              "isbattery": Boolean. Whether this machine has an internal battery, eg: an SMES, an APC's battery
 *              "charge": Float, 0 to 100. Machine percent charge
 *              "charging": Integer, -1 to 1. Whether the machine's battery is charging (1), unchanged (0) or discharging (-1)
 *          }
 *      }
 *  }
*/

/obj/machinery/computer/powermonitor
	name = "power monitor"
	desc = "It monitors power levels across the station."
	icon = 'icons/obj/computer.dmi'
	icon_state = "power"
	circuit = /obj/item/weapon/circuitboard/powermonitor

	use_auto_lights = 1
	light_range_on = 2
	light_power_on = 1
	light_color = LIGHT_COLOR_YELLOW

	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 300
	active_power_usage = 300

	//var/datum/powernet/connected_powernet
	var/datum/power_connection/power_connection = null

	var/list/history = list()
	var/record_size = 60
	var/record_interval = 50
	var/next_record = 0

/obj/machinery/computer/powermonitor/New()
	..()
	power_connection = new(src)

/obj/machinery/computer/powermonitor/Destroy()
	if(power_connection)
		QDEL_NULL(power_connection)
	. = ..()

/obj/machinery/computer/powermonitor/initialize()
	..()
	search()
	history["supply"] = list()
	history["demand"] = list()

/obj/machinery/computer/powermonitor/proc/search()

	var/obj/machinery/power/apc/areaapc = get_area(src).areaapc
	if(areaapc)
		var/turf/T = get_turf(areaapc)
		var/obj/structure/cable/C = T.get_cable_node()
		power_connection.connect(C)

	power_connection.connect()

/obj/machinery/computer/powermonitor/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	tgui_interact(user)

/obj/machinery/computer/powermonitor/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PowerMonitor")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/powermonitor/ui_data(mob/user)
	var/list/data = list()

	var/datum/powernet/connected_powernet = power_connection.get_powernet()

	data["engineer_access"] = (access_engine_minor in user.GetAccess()) // Engineer access allows players to modify priorities
	data["attached"] = connected_powernet ? TRUE : FALSE
	data["history"] = history

	if(!connected_powernet)
		return data

	data["supply"] = format_watts(connected_powernet.avail)
	data["demand"] = format_watts(connected_powernet.viewload)

	data["areas"] = list()

	var/list/obj/machinery/power/machines = list()
	for(var/obj/machinery/power/machine in connected_powernet.nodes)
		if (istype(machine, /obj/machinery/power/terminal))
			var/obj/machinery/power/terminal/T = machine
			machine = T.master

		if (istype(machine, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/apc = machine
			var/list/apc_status = apc.get_monitor_status()

			if (apc_status) //broken APCs and APCs being dismantled will return null, don't forget to check for those
				apc_status["\ref[apc]"]["f_demand"] = format_watts(apc_status["\ref[apc]"]["demand"])
				data["areas"]["\ref[get_area(apc)]"] = list(
					"name" = get_area(apc).name,
					"demand" = apc_status["\ref[apc]"]["demand"],
					"charging" = MONITOR_STATUS_BATTERY_STEADY,
					"charge" = 0,
					"eqp" = apc.equipment,
					"lgt" = apc.lighting,
					"env" = apc.environ,
					"machines" = apc_status
				)

				if (apc_status["\ref[apc]_b"])
					apc_status["\ref[apc]_b"]["f_demand"] = format_watts(apc_status["\ref[apc]_b"]["demand"])
					data["areas"]["\ref[get_area(apc)]"]["demand"] += apc_status["\ref[apc]_b"]["demand"]
					data["areas"]["\ref[get_area(apc)]"]["charging"] = apc_status["\ref[apc]_b"]["charging"]
					data["areas"]["\ref[get_area(apc)]"]["charge"] = apc_status["\ref[apc]_b"]["charge"]

		else if (machine && !(machine in machines)) //Some machines (eg: SMES) could have an input terminal and output wire knot on
			machines += machine						// the same grid, counting them twice. This prevents that

	var/unknown_areas = FALSE
	var/list/unknown_area = list(
		"name" = "Other",
		"demand" = 0,
		"machines" = list()
	)

	var/list/areas = data["areas"]
	for (var/obj/machinery/power/machine in machines)
		var/list/status_list = machine.get_monitor_status()
		if (status_list)
			var/list/apcarea = areas["\ref[get_area(machine)]"]
			if (!apcarea)
				unknown_areas = TRUE
				apcarea = unknown_area
			for (var/key in status_list)
				status_list[key]["f_demand"] = format_watts(status_list[key]["demand"])
				apcarea["machines"][key] = status_list[key]
				apcarea["demand"] += status_list[key]["demand"]

	for (var/datum/power_connection/component in connected_powernet.components)
		var/list/status_list = component.get_monitor_status()
		if (status_list)
			var/list/apcarea = areas["\ref[get_area(component.parent)]"]
			if (!apcarea)
				unknown_areas = TRUE
				apcarea = unknown_area
			for (var/key in status_list)
				status_list[key]["f_demand"] = format_watts(status_list[key]["demand"])
				apcarea["machines"][key] = status_list[key]
				apcarea["demand"] += status_list[key]["demand"]

	if (unknown_areas)
		data["areas"]["\ref[null]"] = unknown_area

	for (var/apcarea in areas)
		areas[apcarea]["f_demand"] = format_watts(areas[apcarea]["demand"])

	return data

/obj/machinery/computer/powermonitor/proc/record()
	if(world.time >= next_record)
		next_record = world.time + record_interval

		var/list/supply = history["supply"]
		var/list/demand = history["demand"]

		var/datum/powernet/connected_powernet = power_connection.get_powernet()
		if(connected_powernet)
			supply += connected_powernet.avail
			if(supply.len > record_size)
				supply.Cut(1, 2)

			demand += connected_powernet.viewload
			if(demand.len > record_size)
				demand.Cut(1, 2)

/obj/machinery/computer/powermonitor/power_change()
	search()
	..()

/obj/machinery/computer/powermonitor/process()
	record()

/obj/machinery/computer/powermonitor/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	if(action == "priority")
		var/value = params["value"]
		var/id = params["id"]

		// Ensure the user has engineer access and isn't setting bogus priority values
		if (!(access_engine_minor in ui.user.GetAccess()) || value < POWER_PRIORITY_CRITICAL || value > POWER_PRIORITY_MINIMAL)
			return

		var/datum/D = locate(params["ref"])
		if (istype(D, /obj/machinery/power))
			var/obj/machinery/power/machine = D
			machine.change_priority(value, id)

		else if (istype(D, /datum/power_connection))
			var/datum/power_connection/machine = D
			machine.change_priority(value, id)

		return TRUE
