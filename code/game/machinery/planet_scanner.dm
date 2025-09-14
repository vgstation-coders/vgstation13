#define PLANET_SCANNER_MAX_SCANS 25

/obj/machinery/planet_scanner
	name = "deep space scanner"
	desc = "A sophisticated scanning array capable of detecting suitable planets for exploration. Each scan requires exponentially more power as space becomes more thoroughly explored."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "scanner_unanchor"
	density = TRUE
	anchored = FALSE
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 10
	active_power_usage = 100

	var/scanning = FALSE
	var/scans_completed = 0
	var/base_energy_cost = 1000000 // Base energy cost in Joules
	var/max_power_rate = 10000 // Maximum power consumption rate in Watts (modified by upgrades)
	var/current_scan_energy = 0 // Current energy accumulated in Joules
	var/required_scan_energy = 0 // Required energy for current scan in Joules
	var/energy_efficiency_modifier = 1.0 // Modifier for energy requirements (lower = more efficient)
	var/power_rate_modifier = 1.0 // Modifier for power consumption rate (higher = more power)

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE
	component_parts = newlist(
		/obj/item/weapon/circuitboard/planet_scanner,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor
	)

/obj/machinery/planet_scanner/New()
	..()
	RefreshParts()
	calculate_required_energy()
	update_icon()

/obj/machinery/planet_scanner/RefreshParts()
	var/T = 0
	// Better scanning modules reduce energy requirements by 25% per level
	for(var/obj/item/weapon/stock_parts/scanning_module/SM in component_parts)
		T += SM.rating
	energy_efficiency_modifier = 0.75 ** max(0, T/2 - 1)

	T = 0
	// Better capacitors increase maximum power consumption rate
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		T += C.rating
	// With 2 capacitors: T1=2, T2=4, T3=6, T4=8
	// Power rates: 10kW, 100kW, 500kW, 1.25MW
	switch(T)
		if(2) // T1 capacitors
			max_power_rate = 10000
		if(3)
			max_power_rate = 50000
		if(4) // T2 capacitors
			max_power_rate = 100000
		if(5)
			max_power_rate = 250000
		if(6) // T3 capacitors
			max_power_rate = 500000
		if(7)
			max_power_rate = 750000
		if(8) // T4 capacitors
			max_power_rate = 1250000

	calculate_required_energy()
/obj/machinery/planet_scanner/proc/calculate_required_energy()
	required_scan_energy = round(base_energy_cost * (2 ** scans_completed) * energy_efficiency_modifier)

/obj/machinery/planet_scanner/proc/get_available_power()
	// Get the area power
	var/area/our_area = get_area(src)
	if(!our_area || !our_area.areaapc)
		return 0

	var/obj/machinery/power/apc/apc = our_area.areaapc
	return apc.avail()

/obj/machinery/planet_scanner/update_icon()
	if(!anchored)
		icon_state = "scanner_unanchor"
	else if(stat & (BROKEN|NOPOWER))
		icon_state = "scanner_depower"
	else if(scanning)
		icon_state = "scanner_active"
	else
		icon_state = "scanner_idle"

/obj/machinery/planet_scanner/power_change()
	..()
	update_icon()

/obj/machinery/planet_scanner/wrenchAnchor(var/mob/user, var/obj/item/I)
	if(scanning)
		to_chat(user, "<span class='notice'>Cannot unanchor while scanning!</span>")
		return FALSE
	. = ..()
	if(!.)
		return
	update_icon()

/obj/machinery/planet_scanner/attack_hand(mob/user)
	if(!anchored)
		to_chat(user, "<span class='warning'>\The [src] must be anchored before it can be operated!</span>")
		return
	tgui_interact(user)

/obj/machinery/planet_scanner/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlanetScanner", "Deep Space Scanner")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/planet_scanner/ui_data(mob/user)
	var/list/data = list()
	data["anchored"] = anchored
	data["powered"] = !(stat & (BROKEN|NOPOWER))
	data["scanning"] = scanning
	data["scans_completed"] = scans_completed
	data["max_scans"] = PLANET_SCANNER_MAX_SCANS
	data["required_energy"] = required_scan_energy
	data["min_power_rate"] = max_power_rate
	data["available_power"] = get_available_power()
	if(scanning)
		data["current_energy"] = current_scan_energy
	else
		data["current_energy"] = null
	data["can_scan"] = anchored && !(stat & (BROKEN|NOPOWER)) && !scanning && scans_completed < PLANET_SCANNER_MAX_SCANS
	data["at_scan_limit"] = scans_completed >= PLANET_SCANNER_MAX_SCANS

	if(SSmapping && SSmapping.planets && SSmapping.planets.len > 0)
		var/list/planet_data = list()
		for(var/datum/planet_type/planet in SSmapping.planets)
			var/list/planet_info = list()
			planet_info["name"] = planet.name
			planet_info["desc"] = planet.desc
			planet_info["type"] = planet.type
			planet_info["procedural_name"] = planet.planet_name
			planet_data += list(planet_info)
		data["discovered_planets"] = planet_data
		data["has_discoveries"] = TRUE
	else
		data["discovered_planets"] = null
		data["has_discoveries"] = FALSE

	if(scanning)
		var/progress = min(current_scan_energy / required_scan_energy, 1.0)
		data["progress"] = round(progress * 100, 1)
	else
		data["progress"] = null

	return data

/obj/machinery/planet_scanner/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("start_scan")
			if(!anchored)
				return FALSE
			if(stat & (BROKEN|NOPOWER))
				return FALSE
			if(scans_completed >= PLANET_SCANNER_MAX_SCANS)
				return FALSE
			if(scanning)
				return FALSE
			start_scan(usr)
			return TRUE
		if("print_disk")
			var/planet_index = text2num(params["planet_index"])
			if(!SSmapping || !SSmapping.planets || !SSmapping.planets.len)
				return FALSE
			// planet_index comes from frontend (0-indexed), check bounds accordingly
			if(planet_index < 0 || planet_index >= SSmapping.planets.len)
				to_chat(usr, "<span class='warning'>Invalid planet selected.</span>")
				return FALSE
			print_destination_disk(usr, planet_index)
			return TRUE

/obj/machinery/planet_scanner/ui_state(mob/user)
	return default_state

/obj/machinery/planet_scanner/proc/start_scan(mob/user)
	scanning = TRUE
	current_scan_energy = 0
	use_power = MACHINE_POWER_USE_ACTIVE
	update_icon()
	return TRUE

/obj/machinery/planet_scanner/process()
	if(!anchored)
		update_icon()
		return

	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		if(scanning)
			visible_message("<span class='warning'>[src] stops scanning due to no power!</span>")
			scanning = FALSE
			current_scan_energy = 0
			use_power = MACHINE_POWER_USE_IDLE
			playsound(src, 'sound/machines/alert.ogg', 50, 1)
			update_icon()
			return
		return

	if(scanning)
		// Get available power and consume what we can (up to max_power_rate)
		var/available_power = get_available_power()
		if(available_power <= 0)
			visible_message("<span class='warning'>[src] stops scanning due to no power!</span>")
			scanning = FALSE
			current_scan_energy = 0
			use_power = MACHINE_POWER_USE_IDLE
			playsound(src, 'sound/machines/alert.ogg', 50, 1)
			update_icon()
			return

		// Use the minimum of available power and max power rate
		var/power_consumed = min(available_power, max_power_rate)

		// Calculate energy accumulated this tick based on power consumed
		// Power subsystem and machinery subsystem both tick every 2 seconds
		// Energy (Joules) = Power (Watts) × Time (seconds)
		// So each tick: Energy = power_consumed × 2 seconds
		var/energy_per_tick = power_consumed * 2
		current_scan_energy += energy_per_tick

		// Consume the power from the grid through area power system
		use_power(power_consumed)

		// Check if scan is complete
		if(current_scan_energy >= required_scan_energy)
			scanning = FALSE
			use_power = MACHINE_POWER_USE_IDLE
			scans_completed++
			playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
			spawn_new_planet()
			calculate_required_energy()
			update_icon()
	..()

/obj/machinery/planet_scanner/proc/spawn_new_planet()
	if(!SSmapping)
		CRASH("New planet spawn attempted before mapping subsystem initialized")

	// Pick random planet type
	var/list/available_planets = SSmapping.planet_types.Copy()
	var/selected_planet_type = pick(available_planets)

	// Pick random ruin
	var/list/available_ruins = list()
	for(var/ruin_path in subtypesof(/datum/map_element/mining_surprise))
		available_ruins += ruin_path

	var/selected_ruin_type = null
	if(available_ruins.len)
		selected_ruin_type = pick(available_ruins)

	SSmapping.spawn_planetoid(selected_planet_type, selected_ruin_type)

	return selected_planet_type

/obj/machinery/planet_scanner/proc/print_destination_disk(mob/user, planet_index)
	if(!SSmapping || !SSmapping.planets || !SSmapping.planets.len)
		to_chat(user, "<span class='warning'>No planets discovered to print.</span>")
		return FALSE

	// Convert from 0-indexed frontend to 1-indexed DM list
	var/dm_index = planet_index + 1
	if(dm_index < 1 || dm_index > SSmapping.planets.len)
		to_chat(user, "<span class='warning'>Invalid planet selected.</span>")
		return FALSE

	var/datum/planet_type/planet = SSmapping.planets[dm_index]
	if(!planet)
		to_chat(user, "<span class='warning'>Planet data corrupted.</span>")
		return FALSE

	// For now, just show a message. This could be expanded to create actual disk items
	to_chat(user, "<span class='notice'>Printing destination disk for [planet.planet_name]...</span>")
	playsound(src, 'sound/effects/dotmatrixprinter.ogg', 40, 1)

	// TODO: Create actual destination disk item with planet data
	// This would require implementing a destination disk item type

	return TRUE


#undef PLANET_SCANNER_MAX_SCANS
