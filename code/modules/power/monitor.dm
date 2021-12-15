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

	use_power = 1
	idle_power_usage = 300
	active_power_usage = 300

	var/datum/powernet/connected_powernet

	var/list/history = list()
	var/record_size = 60
	var/record_interval = 50
	var/next_record = 0

/obj/machinery/computer/powermonitor/initialize()
	..()
	search()
	history["supply"] = list()
	history["demand"] = list()

/obj/machinery/computer/powermonitor/proc/search()
	var/obj/machinery/power/apc/areaapc = get_area(src).areaapc
	if(areaapc)
		connected_powernet = areaapc.terminal.powernet

	var/obj/structure/cable/attached = null
	var/turf/T = loc
	if(isturf(T))
		attached = locate() in T
	if(attached)
		connected_powernet = attached.get_powernet()

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

/obj/machinery/computer/powermonitor/ui_data()
	var/list/data = list()
	data["stored"] = record_size
	data["interval"] = record_interval / 10
	data["attached"] = connected_powernet ? TRUE : FALSE
	data["history"] = history
	data["areas"] = list()

	if(!connected_powernet)
		return data
	data["supply"] = format_watts(connected_powernet.avail)
	data["demand"] = format_watts(connected_powernet.viewload)
	for(var/obj/machinery/power/terminal/term in connected_powernet.nodes)
		var/obj/machinery/power/apc/apc = term.master
		if(!istype(apc))
			continue
		data["areas"] += list(list(
			"name" = get_area(apc).name,
			"charge" = apc.cell?.percent() || 0,
			"load" = format_watts(apc.lastused_total),
			"charging" = apc.charging,
			"eqp" = apc.equipment,
			"lgt" = apc.lighting,
			"env" = apc.environ
		))
	return data


/obj/machinery/computer/powermonitor/proc/record()
	if(world.time >= next_record)
		next_record = world.time + record_interval

		var/list/supply = history["supply"]
		var/list/demand = history["demand"]

		if(connected_powernet)
			supply += connected_powernet.avail
			if(supply.len > record_size)
				supply.Cut(1, 2)

			demand += connected_powernet.viewload
			if(demand.len > record_size)
				demand.Cut(1, 2)

/obj/machinery/computer/powermonitor/power_change()
	..()
	search()
	if(stat & BROKEN)
		icon_state = "broken"
	else
		if (stat & (FORCEDISABLE|NOPOWER))
			spawn(rand(0, 15))
				icon_state = "c_unpowered"
		else
			icon_state = initial(icon_state)

/obj/machinery/computer/powermonitor/process()
	record()
