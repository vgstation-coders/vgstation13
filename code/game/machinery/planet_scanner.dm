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
	var/max_scans = 25
	var/base_power_cost = 100000
	var/scan_time = 30 SECONDS
	var/current_scan_power = 0
	var/required_scan_power = 0
	var/scan_start_time = 0

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE
	component_parts = newlist(
		/obj/item/weapon/circuitboard/planet_scanner,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/capacitor
	)

/obj/machinery/planet_scanner/New()
	..()
	calculate_required_power()
	update_icon()

/obj/machinery/planet_scanner/proc/calculate_required_power()
	required_scan_power = base_power_cost * (2 ** scans_completed)

/obj/machinery/planet_scanner/examine(mob/user)
	..()
	if(scans_completed >= max_scans)
		to_chat(user, "<span class='notice'>The scanner's display shows: 'EXPLORATION LIMIT REACHED - NO MORE SUITABLE PLANETS DETECTED'</span>")
	else if(scanning)
		to_chat(user, "<span class='notice'>The scanner is currently performing a deep space scan. Power consumption: [current_scan_power]/[required_scan_power] watts.</span>")
	else
		to_chat(user, "<span class='notice'>The scanner's display shows: 'READY FOR SCAN [scans_completed + 1]/[max_scans] - REQUIRED POWER: [required_scan_power] WATTS'</span>")

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
		to_chat(user, "<span class='notice'>Cannot anchor/unanchor while scanning!</span>")
		return FALSE
	. = ..()
	if(!.)
		return
	update_icon()

/obj/machinery/planet_scanner/attack_hand(mob/user)
	if(!anchored)
		to_chat(user, "<span class='warning'>\The [src] must be anchored before it can be operated!</span>")
		return

	if(stat & (BROKEN|NOPOWER))
		to_chat(user, "<span class='warning'>\The [src] has no power!</span>")
		return

	if(scans_completed >= max_scans)
		to_chat(user, "<span class='warning'>The scanner has reached its exploration limit. No more suitable planets can be detected in this region of space.</span>")
		return

	if(scanning)
		to_chat(user, "<span class='notice'>The scanner is already performing a scan.</span>")
		return

	start_scan(user)

/obj/machinery/planet_scanner/proc/start_scan(mob/user)
	to_chat(user, "<span class='notice'>You activate \the [src]. It begins scanning deep space for suitable planets...</span>")
	visible_message("<span class='notice'>\The [src] hums to life and begins its scanning sequence.</span>")

	scanning = TRUE
	current_scan_power = 0
	scan_start_time = world.time
	use_power = MACHINE_POWER_USE_ACTIVE
	update_icon()

/obj/machinery/planet_scanner/process()
	if(!anchored)
		update_icon()
		return

	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		if(scanning)
			abort_scan("power failure")
		return

	if(scanning)
		// Check if we've been scanning too long (safety check)
		if(world.time - scan_start_time > scan_time * 2)
			abort_scan("system timeout")
			return

		// Calculate progress based on elapsed time
		var/elapsed_time = world.time - scan_start_time
		var/progress = min(elapsed_time / scan_time, 1.0)
		current_scan_power = progress * required_scan_power

		// Consume power from the grid each tick while scanning
		use_power(active_power_usage)

		// Show progress every 15 seconds (approximately every 8 process cycles)
		if((world.time - scan_start_time) % 150 == 0 && progress < 1.0)
			visible_message("<span class='notice'>\The [src] continues scanning... ([round(progress * 100)]% complete)</span>")

		// Check if scan is complete
		if(progress >= 1.0)
			complete_scan()

	..() // Call parent process

/obj/machinery/planet_scanner/proc/abort_scan(reason)
	scanning = FALSE
	current_scan_power = 0
	use_power = MACHINE_POWER_USE_IDLE
	update_icon()
	visible_message("<span class='warning'>\The [src] stops scanning due to [reason].</span>")

/obj/machinery/planet_scanner/proc/complete_scan()
	scanning = FALSE
	use_power = MACHINE_POWER_USE_IDLE
	scans_completed++

	visible_message("<span class='notice'>\The [src] completes its scan with a satisfied beep!</span>")
	playsound(src, 'sound/machines/ding.ogg', 50, 1)

	// Generate the planet
	spawn_new_planet()

	// Calculate power for next scan
	calculate_required_power()
	update_icon()

/obj/machinery/planet_scanner/proc/spawn_new_planet()
	if(!SSmapping)
		visible_message("<span class='warning'>\The [src] displays an error: 'MAPPING SUBSYSTEM UNAVAILABLE'</span>")
		return

	// Get random planet type
	var/list/available_planets = SSmapping.planet_types.Copy()
	if(!available_planets.len)
		visible_message("<span class='warning'>\The [src] displays an error: 'NO PLANET TYPES AVAILABLE'</span>")
		return

	var/selected_planet_type = pick(available_planets)

	// Get random ruin type
	var/list/available_ruins = list()
	for(var/ruin_path in subtypesof(/datum/map_element/mining_surprise))
		available_ruins += ruin_path

	var/selected_ruin_type = null
	if(available_ruins.len)
		selected_ruin_type = pick(available_ruins)

	message_admins("Planet scanner at [src.x],[src.y],[src.z] is generating a new planet (scan #[scans_completed])")

	try
		var/new_z_level = SSmapping.spawn_planetoid(selected_planet_type, selected_ruin_type)
		if(new_z_level)
			var/datum/planet_type/planet_instance = new selected_planet_type
			visible_message("<span class='notice'>\The [src] displays: 'PLANET DETECTED AND CATALOGUED - TYPE: [planet_instance.name] - Z-LEVEL: [new_z_level]'</span>")
			message_admins("Successfully generated [planet_instance.name] on z-level [new_z_level]")
			qdel(planet_instance)
		else
			visible_message("<span class='warning'>\The [src] displays an error: 'PLANET GENERATION FAILED'</span>")
			message_admins("Planet scanner failed to generate planet")
	catch(var/exception/e)
		visible_message("<span class='warning'>\The [src] displays an error: 'CRITICAL SYSTEM ERROR'</span>")
		message_admins("Planet scanner encountered error: [e]")

/obj/item/weapon/circuitboard/planet_scanner
	name = "circuit board (Deep Space Scanner)"
	build_path = /obj/machinery/planet_scanner
	board_type = "machine"
	origin_tech = "programming=3;engineering=3;bluespace=4"
	req_components = list(
		/obj/item/weapon/stock_parts/scanning_module = 2,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/capacitor = 1
	)
