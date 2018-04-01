/obj/machinery/computer/monitor
	name = "power monitoring console"
	desc = "It monitors power levels across the station."
	icon_screen = "power"
	icon_keyboard = "power_key"
	light_color = LIGHT_COLOR_YELLOW
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 100
	circuit = /obj/item/circuitboard/computer/powermonitor

	var/obj/structure/cable/attached

	var/list/history = list()
	var/record_size = 60
	var/record_interval = 50
	var/next_record = 0

/obj/machinery/computer/monitor/Initialize()
	. = ..()
	search()
	history["supply"] = list()
	history["demand"] = list()

/obj/machinery/computer/monitor/process()
	if(!attached)
		use_power = IDLE_POWER_USE
		search()
	else
		use_power = ACTIVE_POWER_USE
		record()

/obj/machinery/computer/monitor/proc/search()
	var/turf/T = get_turf(src)
	attached = locate() in T

/obj/machinery/computer/monitor/proc/record()
	if(world.time >= next_record)
		next_record = world.time + record_interval

		var/list/supply = history["supply"]
		if(attached.powernet)
			supply += attached.powernet.viewavail
		if(supply.len > record_size)
			supply.Cut(1, 2)

		var/list/demand = history["demand"]
		if(attached.powernet)
			demand += attached.powernet.viewload
		if(demand.len > record_size)
			demand.Cut(1, 2)

/obj/machinery/computer/monitor/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
											datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "power_monitor", name, 1200, 1000, master_ui, state)
		ui.open()

/obj/machinery/computer/monitor/ui_data()
	var/list/data = list()
	data["stored"] = record_size
	data["interval"] = record_interval / 10
	data["attached"] = attached ? TRUE : FALSE
	data["history"] = history
	data["areas"] = list()

	if(attached)
		data["supply"] = DisplayPower(attached.powernet.viewavail)
		data["demand"] = DisplayPower(attached.powernet.viewload)
		for(var/obj/machinery/power/terminal/term in attached.powernet.nodes)
			var/obj/machinery/power/apc/A = term.master
			if(istype(A))
				var/cell_charge
				if(!A.cell)
					cell_charge = 0
				else
					cell_charge = A.cell.percent()
				data["areas"] += list(list(
					"name" = A.area.name,
					"charge" = cell_charge,
					"load" = DisplayPower(A.lastused_total),
					"charging" = A.charging,
					"eqp" = A.equipment,
					"lgt" = A.lighting,
					"env" = A.environ
				))

	return data
