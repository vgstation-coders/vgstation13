// Encounter datum - represents a scanner-discovered encounter zone
/datum/encounter
	var/name = "Deep Space Encounter"
	var/encounter_name = "Unknown Signal"
	var/desc = "Anomalous readings detected in this sector of deep space."
	var/icon/ico
	var/datum/virtual_z/v
	var/hidden = FALSE
	var/list/placed_bounds = list() // list of list(x_min, y_min, x_max, y_max) for vault positions
	var/list/shuttle_reservation = null // list(x_min, y_min, x_max, y_max) - pre-reserved shuttle landing zone
	var/list/shuttle_docking_ports = list() // shuttle datum -> docking port

/datum/encounter/New()
	..()
	encounter_name = generate_encounter_name()
	desc = generate_encounter_desc()
	ico = icon('icons/ui/planet_scanner/128x128.dmi', "bg")
	var/icon/fg = icon('icons/ui/planet_scanner/64x64.dmi', "encounter")
	ico.Blend(fg, ICON_OVERLAY, 32, 32)

/datum/encounter/proc/generate_encounter_name()
	var/list/prefixes = list("Unknown", "Anomalous", "Uncharted", "Distress", "Faint", "Encrypted", "Fragmented", "Recurring")
	var/list/types = list("Signal", "Beacon", "Transmission", "Reading", "Signature", "Contact", "Echo")
	var/designation = "[pick("A","B","C","D","E","F","G","H","K","L","M","N","P","R","S","T","V","X","Z")]-[rand(100,999)]"
	return "[pick(prefixes)] [pick(types)] [designation]"

/datum/encounter/proc/generate_encounter_desc()
	var/list/descriptions = list(
		"Long-range sensors have detected unusual energy signatures emanating from this region. The source remains unidentified.",
		"A cluster of artificial structures has been detected drifting in this sector. Origin unknown.",
		"Faint electromagnetic emissions suggest the presence of derelict technology in this area.",
		"Sensor sweeps reveal anomalous material compositions inconsistent with natural stellar phenomena.",
		"Fragmented subspace transmissions have been triangulated to this location. Contents undecipherable.",
		"Gravitometric analysis indicates the presence of dense artificial objects in otherwise empty space.",
		"Residual radiation patterns suggest recent activity in this sector. No active transponders detected."
	)
	return pick(descriptions)

/// Creates or returns an existing docking port for the given shuttle on this encounter's vlevel
/datum/encounter/proc/get_shuttle_docking_port(datum/shuttle/shuttle)
	if(!shuttle?.linked_port || !shuttle.linked_area || !v)
		return null

	// Return existing port if still valid
	var/obj/docking_port/destination/existing = shuttle_docking_ports[shuttle]
	if(existing?.loc)
		return existing
	shuttle_docking_ports -= shuttle

	var/list/dims = shuttle.get_size()
	if(!dims)
		return null
	var/shuttle_width = dims[1]
	var/shuttle_height = dims[2]

	var/list/offsets = shuttle.get_docking_port_offset()
	if(!offsets || offsets.len < 2)
		return null
	var/port_offset_x = offsets[1]
	var/port_offset_y = offsets[2]

	var/buffer = 7
	if(v.size_x < shuttle_width + 2 * buffer || v.size_y < shuttle_height + 2 * buffer)
		return null

	var/bl_x = 0
	var/bl_y = 0
	var/found = FALSE

	// Use pre-reserved shuttle landing zone if available
	if(shuttle_reservation)
		// The reservation stores the exclusion zone (shuttle bbox + 2-turf buffer)
		// Recover the shuttle bottom-left from the exclusion bounds
		bl_x = shuttle_reservation[1] + 2
		bl_y = shuttle_reservation[2] + 2
		found = TRUE
	else
		// No reservation - find a position that doesn't overlap vaults
		var/safe_x_min = v.x_min + buffer
		var/safe_x_max = v.x_max - shuttle_width - buffer + 1
		var/safe_y_min = v.y_min + buffer
		var/safe_y_max = v.y_max - shuttle_height - buffer + 1

		for(var/attempt = 1 to 50)
			var/try_x = rand(safe_x_min, safe_x_max)
			var/try_y = rand(safe_y_min, safe_y_max)
			var/shuttle_x_max = try_x + shuttle_width + 1
			var/shuttle_y_max = try_y + shuttle_height + 1
			var/shuttle_x_min = try_x - 2
			var/shuttle_y_min = try_y - 2

			var/valid = TRUE
			for(var/list/bounds in placed_bounds)
				if(!(shuttle_x_max < bounds[1] || shuttle_x_min > bounds[3] || shuttle_y_max < bounds[2] || shuttle_y_min > bounds[4]))
					valid = FALSE
					break

			if(valid)
				bl_x = try_x
				bl_y = try_y
				found = TRUE
				break

	if(!found)
		return null

	// Place docking port
	var/turf/port_base = locate(bl_x + port_offset_x, bl_y + port_offset_y, v.z())
	var/turf/port_turf = get_step(port_base, shuttle.linked_port.dir)
	var/port_dir = turn(shuttle.linked_port.dir, 180)

	var/obj/docking_port/destination/dock = new(port_turf)
	dock.dir = port_dir
	dock.areaname = encounter_name
	dock.base_turf_type = /turf/space
	dock.link_to_shuttle(shuttle)

	shuttle_docking_ports[shuttle] = dock
	return dock

// Configuration constants
#define PLANET_SCANNER_MAX_SCANS 25
#define PLANET_SCANNER_BASE_ENERGY_COST 1000000 // Base energy cost in Joules
#define PLANET_SCANNER_ENERGY_EXPONENT 2 // Exponential growth factor for scan costs
#define PLANET_SCANNER_SCAN_MODULE_EFFICIENCY 0.75 // Energy efficiency per scanning module tier
#define PLANET_SCANNER_TICK_DURATION 2 // Seconds per process tick
#define PLANET_SCANNER_DISK_PRINT_COOLDOWN 30 SECONDS // Cooldown between disk prints

// Power constants (Watts) for different capacitor tiers
#define POWER_T1 10000 // 10 kW
#define POWER_T1_MIXED 50000 // 50 kW
#define POWER_T2 100000 // 100 kW
#define POWER_T2_MIXED 250000 // 250 kW
#define POWER_T3 500000 // 500 kW
#define POWER_T3_MIXED 750000 // 750 kW
#define POWER_T4 1250000 // 1.25 MW

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

	// Scanning state
	var/scanning = FALSE
	var/scans_completed = 0
	var/current_scan_energy = 0 // Current energy accumulated in Joules
	var/required_scan_energy = 0 // Required energy for current scan in Joules
	var/waiting_for_generation = FALSE // Waiting for planet generation to complete

	// Upgrade modifiers
	var/max_power = POWER_T1 // Maximum power consumption in Watts (modified by upgrades)
	var/energy_efficiency_modifier = 1.0 // Modifier for energy requirements (lower = more efficient)

	// Cooldown tracking
	var/last_disk_print_time = 0 // World time of last disk print

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
	calculate_energy_efficiency()
	calculate_max_power()
	calculate_required_energy()

/// Calculate energy efficiency based on scanning module upgrades
/obj/machinery/planet_scanner/proc/calculate_energy_efficiency()
	var/total_rating = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/SM in component_parts)
		total_rating += SM.rating

	// Each scanning module tier reduces energy requirements
	// Formula: efficiency = 0.75^(tiers_above_base)
	// With 2 modules: T1=2, T2=4, T3=6, T4=8
	var/tiers_above_base = max(0, total_rating / 2 - 1)
	energy_efficiency_modifier = PLANET_SCANNER_SCAN_MODULE_EFFICIENCY ** tiers_above_base

/// Calculate maximum power consumption based on capacitor upgrades
/obj/machinery/planet_scanner/proc/calculate_max_power()
	var/total_rating = 0
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		total_rating += C.rating

	// With 2 capacitors: T1=2, T2=4, T3=6, T4=8
	// Power scales significantly with tier to reduce scan time
	switch(total_rating)
		if(2) // T1 capacitors
			max_power = POWER_T1
		if(3)
			max_power = POWER_T1_MIXED
		if(4) // T2 capacitors
			max_power = POWER_T2
		if(5)
			max_power = POWER_T2_MIXED
		if(6) // T3 capacitors
			max_power = POWER_T3
		if(7)
			max_power = POWER_T3_MIXED
		if(8) // T4 capacitors
			max_power = POWER_T4
		else
			max_power = POWER_T1

/// Calculate the energy required for the next scan
/// Energy requirement doubles with each completed scan, modified by efficiency upgrades
/obj/machinery/planet_scanner/proc/calculate_required_energy()
	required_scan_energy = round(PLANET_SCANNER_BASE_ENERGY_COST * (PLANET_SCANNER_ENERGY_EXPONENT ** scans_completed) * energy_efficiency_modifier)

/// Get the amount of power available from the area's APC
/// Returns: Available power in Watts, or 0 if no APC is available
/obj/machinery/planet_scanner/proc/get_available_power()
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
	else if(scanning || waiting_for_generation)
		icon_state = "scanner_active"
	else if(istype(src, /obj/machinery/planet_scanner/shuttle))
		var/obj/machinery/planet_scanner/shuttle/S = src
		if(S.passive_scanning)
			icon_state = "scanner_passive"
			return
		icon_state = "scanner_idle"
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

	// Machine status
	data["anchored"] = anchored
	data["powered"] = !(stat & (BROKEN|NOPOWER))
	data["scanning"] = scanning
	data["scans_completed"] = scans_completed
	data["max_scans"] = PLANET_SCANNER_MAX_SCANS
	data["at_scan_limit"] = scans_completed >= PLANET_SCANNER_MAX_SCANS
	data["can_scan"] = can_start_scan()
	data["waiting_for_generation"] = waiting_for_generation
	data["other_scan_in_progress"] = (SSmapping?.scanning || SSmapping?.generating) && !scanning && !waiting_for_generation
	data["scanning_disabled"] = SSmapping.scanning_disabled

	// Power and energy information
	data["required_energy"] = required_scan_energy
	data["min_power_rate"] = max_power
	data["available_power"] = get_available_power()
	data["current_energy"] = scanning ? current_scan_energy : null
	data["progress"] = get_scan_progress()

	// Generation stage information
	if(waiting_for_generation && SSmapping)
		data["generation_stage"] = SSmapping.current_stage
		data["generation_progress"] = get_generation_stage_progress()
	else
		data["generation_stage"] = null
		data["generation_progress"] = null

	// Discoveries (planets + encounters)
	data["has_discoveries"] = (SSmapping?.planets.len > 0) || (SSmapping?.encounters.len > 0)
	data["discovered_planets"] = get_planet_list_data()

	return data

/// Check if the scanner is ready to start a new scan
/obj/machinery/planet_scanner/proc/can_start_scan()
	return anchored && !(stat & (BROKEN|NOPOWER)) && !scanning && scans_completed < PLANET_SCANNER_MAX_SCANS && !SSmapping?.scanning && !SSmapping?.generating && !SSmapping.scanning_disabled

/// Get the current scan progress as a percentage (0-100), or null if not scanning
/obj/machinery/planet_scanner/proc/get_scan_progress()
	if(!scanning && !waiting_for_generation)
		return null
	if(waiting_for_generation)
		return 100 // Show 100% while waiting for generation
	var/progress = min(current_scan_energy / required_scan_energy, 1.0)
	return round(progress * 100, 1)

/// Get the progress of the current generation stage as a percentage (0-100)
/obj/machinery/planet_scanner/proc/get_generation_stage_progress()
	if(!SSmapping || !SSmapping.generating)
		return 0

	switch(SSmapping.current_stage)
		if(1)
			if(SSmapping.terrain_queue.len > 0)
				return round((SSmapping.queue_index / SSmapping.terrain_queue.len) * 100, 1)
		if(3)
			if(SSmapping.population_queue.len > 0)
				return round((SSmapping.queue_index / SSmapping.population_queue.len) * 100, 1)
		else
			return 100

	return 0

/// Build the list of discoveries (planets + encounters) for the UI
/// Returns: List of discovery data dictionaries, or null if none found
/obj/machinery/planet_scanner/proc/get_planet_list_data()
	var/list/planet_data = list()

	for(var/datum/planet_type/planet in SSmapping.planets)
		if(planet.hidden)
			continue

		var/list/planet_info = list()
		planet_info["name"] = planet.name
		planet_info["desc"] = planet.desc
		planet_info["type"] = planet.type
		planet_info["procedural_name"] = planet.planet_name
		planet_info["icon_data"] = icon2base64(planet.ico)
		planet_info["is_encounter"] = FALSE

		// Get all beacons on this planet
		var/list/beacons = list()
		var/has_active_beacon = FALSE
		if(planet.v)
			var/datum/virtual_z/vz = planet.v
			for(var/obj/item/device/gps/planetary/gps in GPS_list)
				var/turf/gps_turf = get_turf(gps)
				var/datum/virtual_z/gps_vz = gps_turf.get_virtual_z()
				if(!gps_vz)
					continue
				if(gps_vz == vz && gps.transmitting)
					var/list/beacon_info = list()
					beacon_info["tag"] = gps.gpstag
					beacon_info["active"] = gps.beacon_active
					beacon_info["location"] = gps.get_location_name()
					if(gps.beacon_active)
						has_active_beacon = TRUE
					beacons += list(beacon_info)

		planet_info["beacons"] = beacons
		planet_info["has_active_beacon"] = has_active_beacon
		planet_data += list(planet_info)

	for(var/datum/encounter/enc in SSmapping.encounters)
		if(enc.hidden)
			continue

		var/list/enc_info = list()
		enc_info["name"] = enc.name
		enc_info["desc"] = enc.desc
		enc_info["procedural_name"] = enc.encounter_name
		enc_info["icon_data"] = icon2base64(enc.ico)
		enc_info["is_encounter"] = TRUE
		enc_info["beacons"] = list()
		enc_info["has_active_beacon"] = FALSE
		planet_data += list(enc_info)

	return planet_data.len ? planet_data : null

/obj/machinery/planet_scanner/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("start_scan")
			if(!can_start_scan())
				return FALSE
			start_scan(usr)
			return TRUE
		if("print_disk")
			var/planet_index = text2num(params["planet_index"])
			if(!validate_planet_index(planet_index, usr))
				return FALSE
			print_destination_disk(usr, planet_index)
			return TRUE

/// Validate that a discovery index from the UI is valid
/// Args:
///   planet_index - 0-indexed index from the frontend (covers planets + encounters)
///   user - The mob to send error messages to
/// Returns: TRUE if valid, FALSE otherwise
/obj/machinery/planet_scanner/proc/validate_planet_index(planet_index, mob/user)
	var/datum/discovery = get_discovery_by_ui_index(planet_index)
	if(!discovery)
		if(user)
			to_chat(user, "<span class='warning'>Invalid selection.</span>")
		return FALSE
	return TRUE

/// Get a planet or encounter datum by UI index (0-indexed, matching the combined list order)
/obj/machinery/planet_scanner/proc/get_discovery_by_ui_index(ui_index)
	var/current = 0

	for(var/datum/planet_type/planet in SSmapping.planets)
		if(planet.hidden)
			continue
		if(current == ui_index)
			return planet
		current++

	for(var/datum/encounter/enc in SSmapping.encounters)
		if(enc.hidden)
			continue
		if(current == ui_index)
			return enc
		current++

	return null

/obj/machinery/planet_scanner/ui_state(mob/user)
	return default_state

/// Start a new planet scan
/obj/machinery/planet_scanner/proc/start_scan(mob/user)
	scanning = TRUE
	current_scan_energy = 0
	use_power = MACHINE_POWER_USE_ACTIVE
	SSmapping.scanning = TRUE
	update_icon()
	return TRUE

/obj/machinery/planet_scanner/process()
	if(!anchored)
		update_icon()
		return

	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		if(scanning)
			abort_scan("no power")
		return

	if(scanning)
		process_scanning()

	..()

/obj/machinery/planet_scanner/proc/process_scanning()
	if(waiting_for_generation)
		if(!SSmapping.generating)
			finalize_scan()
		return

	var/available_power = get_available_power()
	if(available_power <= 0)
		abort_scan("no power")
		return

	// Consume power and accumulate energy
	var/power_consumed = min(available_power, max_power)
	accumulate_scan_energy(power_consumed)
	use_power(power_consumed)

	// Check if scan is complete
	if(current_scan_energy >= required_scan_energy)
		complete_scan()

/// Accumulate energy for the current scan based on power consumed
/// Energy (Joules) = Power (Watts) × Time (seconds)
/obj/machinery/planet_scanner/proc/accumulate_scan_energy(power_consumed)
	var/energy_per_tick = power_consumed * PLANET_SCANNER_TICK_DURATION
	current_scan_energy += energy_per_tick

/// Abort the current scan due to an error condition
/obj/machinery/planet_scanner/proc/abort_scan(reason)
	visible_message("<span class='warning'>[src] stops scanning due to [reason]!</span>")
	scanning = FALSE
	waiting_for_generation = FALSE
	current_scan_energy = 0
	use_power = MACHINE_POWER_USE_IDLE
	SSmapping.scanning = FALSE
	playsound(src, 'sound/machines/alert.ogg', 50, 1)
	update_icon()

/// Complete the current scan and spawn a new planet or encounter (energy requirement met)
/obj/machinery/planet_scanner/proc/complete_scan()
	use_power = MACHINE_POWER_USE_IDLE // Stop consuming power
	SSmapping.scanning = FALSE

	if(prob(20)) // 20% chance of detecting an encounter instead of a planet
		spawn_new_encounter()
		finalize_scan()
	else
		waiting_for_generation = TRUE
		spawn_new_planet()

/// Finalize the scan after planet generation is complete
/obj/machinery/planet_scanner/proc/finalize_scan()
	scanning = FALSE
	waiting_for_generation = FALSE
	scans_completed++
	playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
	visible_message("<span class='notice'>[src] completes its scan and displays the results.</span>")
	calculate_required_energy()
	update_icon()

/// Spawn a new planet with random type
/// Returns: The planet type that was spawned
/obj/machinery/planet_scanner/proc/spawn_new_planet()
	if(!SSmapping)
		CRASH("New planet spawn attempted before mapping subsystem initialized")

	var/selected_planet_type = select_random_planet_type()

	SSmapping.spawn_planet(selected_planet_type, FALSE, map.planet_size)

	return selected_planet_type

/// Select a random planet type from available types
/obj/machinery/planet_scanner/proc/select_random_planet_type()
	var/list/available_planets = SSmapping.planet_types.Copy()
	return pick(available_planets)

/// Spawn a new encounter zone
/obj/machinery/planet_scanner/proc/spawn_new_encounter()
	if(!SSmapping)
		CRASH("New encounter spawn attempted before mapping subsystem initialized")

	SSmapping.generate_scanner_encounter()

/obj/machinery/planet_scanner/proc/print_destination_disk(mob/user, planet_index)
	if(world.time < last_disk_print_time + PLANET_SCANNER_DISK_PRINT_COOLDOWN)
		to_chat(user, "<span class='warning'>Disk printer is still cooling down! Please wait [(last_disk_print_time + PLANET_SCANNER_DISK_PRINT_COOLDOWN - world.time)] seconds.</span>")
		return FALSE

	var/datum/discovery = get_discovery_by_ui_index(planet_index)
	if(!discovery)
		to_chat(user, "<span class='warning'>Data corrupted or invalid.</span>")
		return FALSE

	var/obj/item/weapon/disk/shuttle_coords/procedural/disk = new(get_turf(src))

	if(istype(discovery, /datum/planet_type))
		var/datum/planet_type/planet = discovery
		to_chat(user, "<span class='notice'>Printing destination disk for [planet.planet_name]...</span>")
		disk.planet_ref = planet
		disk.header = "[planet.planet_name] Landing"
	else if(istype(discovery, /datum/encounter))
		var/datum/encounter/enc = discovery
		to_chat(user, "<span class='notice'>Printing destination disk for [enc.encounter_name]...</span>")
		disk.encounter_ref = enc
		disk.header = "[enc.encounter_name]"
		disk.name = "encounter destination disk"
		disk.desc = "A disk containing coordinates to a deep space encounter zone."

	playsound(src, 'sound/effects/dotmatrixprinter.ogg', 40, 1)
	last_disk_print_time = world.time

	return TRUE


/obj/machinery/planet_scanner/shuttle
	name = "shuttle deep space scanner"
	desc = "A deep space scanner modified for shuttle installation. Discovered destinations can be added directly to the shuttle's navigation computer."

	component_parts = newlist(
		/obj/item/weapon/circuitboard/planet_scanner/shuttle,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor
	)

	// Tracks which discoveries (planet_type or encounter datums) have been added to the shuttle
	var/list/added_discoveries = list()

	// Passive scanning state
	var/passive_scanning = FALSE
	var/passive_scan_progress = 0 // Accumulated progress (completes at 1.0)

/// Override to pass the shuttle to encounter generation for proper shuttle reservation
/obj/machinery/planet_scanner/shuttle/spawn_new_encounter()
	if(!SSmapping)
		CRASH("New encounter spawn attempted before mapping subsystem initialized")
	SSmapping.generate_scanner_encounter(get_shuttle())

/// Get the shuttle this scanner is installed on by checking the area
/obj/machinery/planet_scanner/shuttle/proc/get_shuttle()
	var/area/our_area = get_area(src)
	if(!our_area)
		return null
	return our_area.get_shuttle()

/// Check if the shuttle is currently parked in deep space (VZ_PARKING)
/obj/machinery/planet_scanner/shuttle/proc/shuttle_in_space()
	var/datum/shuttle/shuttle = get_shuttle()
	if(!shuttle?.current_port)
		return FALSE
	var/datum/virtual_z/vz = shuttle.current_port.get_virtual_z()
	if(!vz)
		return FALSE
	return (vz.level_type == VZ_PARKING)

/// Check if the shuttle is currently in hyperspace transit (VZ_TRANSIT)
/obj/machinery/planet_scanner/shuttle/proc/shuttle_in_transit()
	var/datum/shuttle/shuttle = get_shuttle()
	if(!shuttle?.current_port)
		return FALSE
	var/datum/virtual_z/vz = shuttle.current_port.get_virtual_z()
	if(!vz)
		return FALSE
	return (vz.level_type == VZ_TRANSIT)

/// Reduce exponential growth by 50% - use 1.5 exponent instead of 2
/obj/machinery/planet_scanner/shuttle/calculate_required_energy()
	required_scan_energy = round(PLANET_SCANNER_BASE_ENERGY_COST * (1.5 ** scans_completed) * energy_efficiency_modifier)

/// Override to also require shuttle to be in space
/obj/machinery/planet_scanner/shuttle/can_start_scan()
	return ..() && get_shuttle() && shuttle_in_space()

/// Override process to handle passive scanning in transit
/obj/machinery/planet_scanner/shuttle/process()
	// Handle passive scan waiting for planet generation to complete
	if(waiting_for_generation && !scanning)
		if(!SSmapping.generating)
			waiting_for_generation = FALSE
			SSmapping.scanning = FALSE
			scans_completed++
			playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
			visible_message("<span class='notice'>[src] has passively detected a new planet in hyperspace.</span>")
			calculate_required_energy()
			update_icon()

	// Handle passive scanning when in transit and not actively scanning
	else if(!scanning && !waiting_for_generation && shuttle_in_transit() && !SSmapping?.scanning && !SSmapping?.generating && scans_completed < PLANET_SCANNER_MAX_SCANS && !(stat & (BROKEN|FORCEDISABLE)) && anchored)
		if(!passive_scanning)
			passive_scanning = TRUE
			update_icon()
		// 50% chance each tick to advance by 1/150 - averages ~10 min (300 ticks) to complete
		if(prob(50))
			passive_scan_progress += 1.0 / 150
		if(passive_scan_progress >= 1.0)
			complete_passive_scan()
	else if(passive_scanning && !waiting_for_generation)
		// Left transit - pause passive scan but keep progress for next visit
		passive_scanning = FALSE
		update_icon()

	..()
	return // Prevent PROCESS_KILL from parent - shuttle scanner must keep processing for passive scans

/// Complete a passive scan - same result as active scan but triggered by transit
/obj/machinery/planet_scanner/shuttle/proc/complete_passive_scan()
	passive_scanning = FALSE
	passive_scan_progress = 0
	update_icon()

	SSmapping.scanning = TRUE

	if(prob(50))
		spawn_new_encounter()
		SSmapping.scanning = FALSE
		scans_completed++
		playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
		visible_message("<span class='notice'>[src] has passively detected an anomaly in hyperspace.</span>")
		calculate_required_energy()
	else
		waiting_for_generation = TRUE
		spawn_new_planet()

/obj/machinery/planet_scanner/shuttle/ui_data(mob/user)
	// Ensure we stay in the machines processing list (base machinery PROCESS_KILLs idle machines)
	if(!inMachineList)
		inMachineList = 1
		machines += src

	var/list/data = ..()

	data["is_shuttle_scanner"] = TRUE

	var/datum/shuttle/shuttle = get_shuttle()
	data["shuttle_found"] = !!shuttle
	data["shuttle_name"] = shuttle?.name
	data["shuttle_in_space"] = shuttle_in_space()
	data["passive_scanning"] = passive_scanning
	data["passive_progress"] = passive_scanning ? round(passive_scan_progress * 100, 1) : null

	// Build per-discovery "already added" flags
	var/list/added_flags = list()
	if(data["discovered_planets"])
		for(var/list/planet_entry in data["discovered_planets"])
			var/ui_index = added_flags.len
			var/datum/discovery = get_discovery_by_ui_index(ui_index)
			added_flags += list(discovery ? (discovery in added_discoveries) : FALSE)
	data["added_destinations"] = added_flags

	return data

/obj/machinery/planet_scanner/shuttle/ui_act(action, params)
	if(action == "print_disk")
		return FALSE // Disable disk printing on shuttle scanner

	if(action == "add_destination")
		var/planet_index = text2num(params["planet_index"])
		if(!validate_planet_index(planet_index, usr))
			return FALSE
		add_destination(usr, planet_index)
		return TRUE

	return ..()

/// Add a discovered planet or encounter as a permanent shuttle destination
/obj/machinery/planet_scanner/shuttle/proc/add_destination(mob/user, planet_index)
	var/datum/shuttle/shuttle = get_shuttle()
	if(!shuttle)
		to_chat(user, "<span class='warning'>No shuttle detected. The scanner must be installed on a shuttle.</span>")
		return FALSE

	var/datum/discovery = get_discovery_by_ui_index(planet_index)
	if(!discovery)
		to_chat(user, "<span class='warning'>Data corrupted or invalid.</span>")
		return FALSE

	if(discovery in added_discoveries)
		to_chat(user, "<span class='warning'>This destination has already been added to the shuttle's navigation.</span>")
		return FALSE

	if(istype(discovery, /datum/planet_type))
		var/datum/planet_type/planet = discovery
		if(!(planet?.v))
			to_chat(user, "<span class='warning'>Planet data unavailable.</span>")
			return FALSE

		var/list/shuttle_size = shuttle.get_size()
		if(!shuttle_size)
			to_chat(user, "<span class='warning'>Unable to determine shuttle dimensions.</span>")
			return FALSE

		var/obj/docking_port/destination/planet_surface/surface_port = find_shuttle_landing_position(shuttle, planet)
		if(!surface_port)
			to_chat(user, "<span class='warning'>No suitable landing zone found on [planet.planet_name].</span>")
			return FALSE

		shuttle.add_dock(surface_port)
		added_discoveries += discovery
		to_chat(user, "<span class='notice'>[planet.planet_name] has been added to [shuttle.name]'s navigation destinations.</span>")
		playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
		return TRUE

	else if(istype(discovery, /datum/encounter))
		var/datum/encounter/enc = discovery
		var/obj/docking_port/destination/dock = enc.get_shuttle_docking_port(shuttle)
		if(!dock)
			to_chat(user, "<span class='warning'>Unable to calculate a safe approach vector for [enc.encounter_name].</span>")
			return FALSE

		shuttle.add_dock(dock)
		added_discoveries += discovery
		to_chat(user, "<span class='notice'>[enc.encounter_name] has been added to [shuttle.name]'s navigation destinations.</span>")
		playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
		return TRUE

	return FALSE

/// Find a valid landing position on a planet for the shuttle, with permissive terrain checks.
/// Only requires: 5 turf edge buffer, no overlap with placed ruins.
/obj/machinery/planet_scanner/shuttle/proc/find_shuttle_landing_position(datum/shuttle/shuttle, datum/planet_type/planet)
	var/datum/virtual_z/vz = planet.v
	if(!vz || !shuttle?.linked_port)
		return null

	var/list/size = shuttle.get_size()
	if(!size)
		return null
	var/shuttle_width = size[1]
	var/shuttle_height = size[2]

	var/list/offsets = shuttle.get_docking_port_offset()
	if(!offsets || offsets.len < 2)
		return null
	var/port_offset_x = offsets[1]
	var/port_offset_y = offsets[2]

	// 5 turf edge buffer
	var/buffer = 5
	var/safe_x_min = vz.x_min + buffer
	var/safe_x_max = vz.x_max - shuttle_width - buffer + 1
	var/safe_y_min = vz.y_min + buffer
	var/safe_y_max = vz.y_max - shuttle_height - buffer + 1

	if(safe_x_max < safe_x_min || safe_y_max < safe_y_min)
		return null

	// Try random positions, check for ruin overlap only
	for(var/attempt = 1 to 50)
		var/try_x = rand(safe_x_min, safe_x_max)
		var/try_y = rand(safe_y_min, safe_y_max)

		// Check overlap with placed ruins
		var/valid = TRUE
		for(var/list/placed in vz.placed_ruins)
			var/placed_x = placed[1]
			var/placed_y = placed[2]
			var/placed_w = placed[3]
			var/placed_h = placed[4]
			// AABB overlap check with a small buffer around ruins
			if(!((try_x + shuttle_width) < placed_x || try_x > (placed_x + placed_w) || (try_y + shuttle_height) < placed_y || try_y > (placed_y + placed_h)))
				valid = FALSE
				break

		if(!valid)
			continue

		// Valid position found - create docking port
		var/port_x = try_x + port_offset_x
		var/port_y = try_y + port_offset_y
		var/turf/port_base = locate(port_x, port_y, vz.z())
		var/turf/port_turf = get_step(port_base, shuttle.linked_port.dir)
		var/port_dir = turn(shuttle.linked_port.dir, 180)

		var/obj/docking_port/destination/planet_surface/dock = new(port_turf)
		dock.dir = port_dir
		dock.areaname = "[planet.planet_name] surface"
		dock.planet = planet
		if(planet.default_baseturf)
			dock.base_turf_type = planet.default_baseturf

		return dock

	return null


// Cleanup defines
#undef PLANET_SCANNER_MAX_SCANS
#undef PLANET_SCANNER_BASE_ENERGY_COST
#undef PLANET_SCANNER_ENERGY_EXPONENT
#undef PLANET_SCANNER_SCAN_MODULE_EFFICIENCY
#undef PLANET_SCANNER_TICK_DURATION
#undef PLANET_SCANNER_DISK_PRINT_COOLDOWN
#undef POWER_T1
#undef POWER_T1_MIXED
#undef POWER_T2
#undef POWER_T2_MIXED
#undef POWER_T3
#undef POWER_T3_MIXED
#undef POWER_T4
