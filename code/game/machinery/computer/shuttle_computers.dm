//Docking port disks
//Insert into a shuttle computer to unlock a new destination
/obj/item/weapon/disk/shuttle_coords
	name = "shuttle destination disk"
	desc = "A small disk containing encrypted coordinates and tracking data."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "disk_shuttle"

	var/obj/docking_port/destination/destination //Docking port linked to this disk.
	//If this variable contains a path like (/obj/structure/docking_port/destination/my_dungeon), the disk will find a destination docking port of that type and automatically link to it
	//See example below

	var/header = "SDC Data Disk" //Name of the disk, shown on the console. SDC stands Shuttle Destination Coordinates

	var/list/allowed_shuttles = list() //List of allowed shuttles. Accepts paths (for example /datum/shuttle/arrival). If empty, all shuttles are allowed
	starting_materials = list(MAT_GLASS = 1250)

//Example:
/obj/item/weapon/disk/shuttle_coords/station_arrivals
	destination = /obj/docking_port/destination/transport/station
	header = "station arrivals"

/obj/item/weapon/disk/shuttle_coords/station_auxillary
	name = "auxillary docking disk"
	header = "station auxillary docking"
	destination = /obj/docking_port/destination/salvage/arrivals
	allowed_shuttles = list(/datum/shuttle/custom)

/obj/item/weapon/disk/shuttle_coords/disk_jockey
	name = "Russian propaganda station destination disk"
	header = "DJ station"
	destination = /obj/docking_port/destination/salvage/dj
	starting_materials = list(MAT_GLASS = 1250, MAT_GOLD = 1250)

/obj/item/weapon/disk/shuttle_coords/vault
	allowed_shuttles = list(/datum/shuttle/mining, /datum/shuttle/research, /datum/shuttle/security)

///obj/item/weapon/disk/shuttle_coords/vault/random -> leads to a random vault with a docking port!
/obj/item/weapon/disk/shuttle_coords/vault/random/initialize()
	var/list/L = list()
	for(var/obj/docking_port/destination/vault/V in all_docking_ports)
		if(!V.valid_random_destination)
			continue
		L.Add(V)

	if(L.len)
		destination = pick(L)

	..()

	if(!destination)
		name = "blank shuttle destination disk"
		desc = "A small disk containing nothing."

//This disk will link to station's arrivals when spawned

/obj/item/weapon/disk/shuttle_coords/New()
	..()

	if(ticker)
		initialize()

/obj/item/weapon/disk/shuttle_coords/initialize()
	if(ispath(destination))
		spawn()
			destination = locate(destination) in all_docking_ports
			if(destination)
				destination.disk_references.Add(src)
	else
		header = "ERROR"

/obj/item/weapon/disk/shuttle_coords/Destroy()
	// If a disk is destroyed before initialize() runs, `destination` could
	// be a type path instead of an instance.
	if(istype(destination))
		destination.disk_references.Remove(src)
		destination = null

	..()

/obj/item/weapon/disk/shuttle_coords/proc/compatible(datum/shuttle/S)
	if(!allowed_shuttles.len)
		return TRUE

	return is_type_in_list(S, allowed_shuttles)

/obj/item/weapon/disk/shuttle_coords/proc/reset()
	destination = null
	header = "ERROR"

/obj/item/weapon/disk/shuttle_coords/free_move
	name = "shuttle free-movement driver"
	desc = "This disk contains a piece of software which converts coordinates into subspace trajectories, which shuttle computers are able to use."
	header = "FREE-MOVE DRIVER"

/obj/item/weapon/disk/shuttle_coords/free_move/initialize()
	..()
	header = initial(header)

/obj/item/weapon/disk/shuttle_coords/procedural
	name = "planetary destination disk"
	desc = "A disk containing coordinates to a recently discovered planet."
	header = "PLANETARY LANDING"
	var/datum/planet_type/planet_ref
	var/datum/encounter/encounter_ref

/obj/docking_port/destination/coord //Specific subtype to hunt for when doing cleanup

/obj/item/weapon/card/shuttle_pass
	name = "shuttle pass"
	desc = "A one-use shuttle activation pass, for limited access to high-security transportation."
	icon_state = "data"
	item_state = "card-id"
	var/obj/docking_port/destination/destination
	var/allowed_shuttle

/obj/item/weapon/card/shuttle_pass/New()
	..()
	if(ticker)
		initialize()

/obj/item/weapon/card/shuttle_pass/initialize()
	if(ispath(destination))
		spawn()
			destination = locate(destination) in all_docking_ports

/obj/item/weapon/card/shuttle_pass/Destroy()
	destination = null
	..()

/obj/item/weapon/card/shuttle_pass/ert
	name = "\improper ERT shuttle pass"
	destination = /obj/docking_port/destination/transport/station
	allowed_shuttle = /datum/shuttle/transport

#define MAX_SHUTTLE_NAME_LEN

/obj/machinery/computer/shuttle_control
	name = "shuttle console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	req_access = null
	circuit = "/obj/item/weapon/circuitboard/shuttle_control"

	machine_flags = EMAGGABLE | SCREWTOGGLE | WRENCHMOVE

	light_color = LIGHT_COLOR_BLUE

	var/datum/shuttle/shuttle

	var/obj/docking_port/selected_port

	var/allow_selecting_all = 0 //if 1, allow selecting ALL ports, not only those of linked shuttle
								//only abusable by admins

	var/allow_silicons = 1		//If 0, AIs and cyborgs can't use this computer
								//used for admin-only shuttles so that borgs cant hijack 'em

	var/obj/item/weapon/disk/shuttle_coords/disk

	//Variables used for custom destinations
	var/custom_x = 0
	var/custom_y = 0
	var/custom_z = 0
	var/custom_rot = 0

	// For landing on procgen planets
	var/procgen_target

/obj/machinery/computer/shuttle_control/New()
	if(shuttle)
		name = "[shuttle.name] console"

	.=..()

/obj/machinery/computer/shuttle_control/Destroy()
	if(disk)
		QDEL_NULL(disk)

	..()

/obj/machinery/computer/shuttle_control/proc/announce(var/message)
	return say(message)

/obj/machinery/computer/shuttle_control/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/disk/shuttle_coords))
		insert_disk(O, user)

	if(istype(O, /obj/item/weapon/card/shuttle_pass))
		use_pass(O, user)

	if(istype(O,/obj/item/device/shuttle_holopainter))
		if(do_after(user, src, 1 SECONDS, needhand = TRUE))
			shuttle.update_appearance(O, user)
			if(O.emagged)
				playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
				visible_message("<span class='notice'>\The [O] honks pensively.</span>", user)
	..()

/obj/machinery/computer/shuttle_control/attack_hand(mob/user as mob)
	if(..(user))
		return
	user.set_machine(src)
	add_fingerprint(user)
	tgui_interact(user)

/obj/machinery/computer/shuttle_control/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShuttleControl")
		ui.open()

/obj/machinery/computer/shuttle_control/ui_state(mob/user)
	if(isAdminGhost(user))
		return global.admin_state
	return global.default_state

/obj/machinery/computer/shuttle_control/ui_data(mob/user)
	// Stale port cleanup so the UI never tries to act on a deleted port.
	if(selected_port && !selected_port.loc)
		selected_port = null

	var/list/data = list(
		"is_admin" = !!isAdminGhost(user),
		"is_silicon" = !!issilicon(user),
		"allow_selecting_all" = allow_selecting_all,
		"allow_silicons" = allow_silicons,
		"console_name" = name,
	)

	// No shuttle linked yet: surface only the linker so the user has somewhere to go.
	if(!shuttle)
		data["has_shuttle"] = FALSE
		data["available_shuttles"] = build_link_candidates(get_area(src), admin_only = FALSE)
		data["admin_available_shuttles"] = isAdminGhost(user) ? build_link_candidates(get_area(src), admin_only = TRUE) : null
		return data

	data["has_shuttle"] = TRUE
	data["shuttle_name"] = shuttle.name
	data["lockdown"] = !!shuttle.lockdown
	data["lockdown_reason"] = istext(shuttle.lockdown) ? shuttle.lockdown : null
	data["moving"] = !!shuttle.moving
	data["has_linked_area"] = !!shuttle.linked_area
	data["destination_areaname"] = shuttle.destination_port ? capitalize(shuttle.destination_port.areaname) : null
	data["current_areaname"] = shuttle.current_port ? capitalize(shuttle.current_port.areaname) : null
	var/cd = max(shuttle.last_moved + shuttle.cooldown - world.time, 0)
	data["cooldown_seconds_left"] = cd ? max(round(cd * 0.1), 0) : 0
	data["selected_ref"] = selected_port ? "\ref[selected_port]" : null
	data["procgen_target"] = procgen_target

	// Phase + progress. Resolved in priority order so the most disruptive
	// state always wins (e.g. lockdown beats a stale cooldown timer).
	var/list/phase_data = compute_phase()
	data["phase"] = phase_data["phase"]
	data["phase_seconds_left"] = phase_data["seconds_left"]
	data["phase_seconds_total"] = phase_data["seconds_total"]

	// Destination ports.
	var/list/ports = list()
	var/list/source_ports
	if(allow_selecting_all)
		source_ports = all_docking_ports
	else
		source_ports = shuttle.docking_ports
	for(var/obj/docking_port/destination/D in source_ports)
		// Surface ports come via the procedural disk panel; suppress their
		// dupes from the main list to keep the UI uncluttered.
		if(istype(D, /obj/docking_port/destination/planet_surface) && istype(disk, /obj/item/weapon/disk/shuttle_coords/procedural))
			continue
		ports += list(list(
			"ref" = "\ref[D]",
			"name" = capitalize(D.areaname),
			"occupied" = !!D.docked_with,
			"selected" = (D == selected_port),
		))
	data["destinations"] = ports

	// Disk panel.
	if(disk)
		var/list/disk_data = list("header" = disk.header)
		if(istype(disk, /obj/item/weapon/disk/shuttle_coords/free_move))
			disk_data["kind"] = "freemove"
			disk_data["custom_x"] = custom_x
			disk_data["custom_y"] = custom_y
			disk_data["custom_z"] = custom_z
			disk_data["custom_rot"] = custom_rot
			if(disk.destination)
				disk_data["dest_name"] = capitalize(disk.destination.areaname)
		else if(istype(disk, /obj/item/weapon/disk/shuttle_coords/procedural))
			var/obj/item/weapon/disk/shuttle_coords/procedural/proc_disk = disk
			disk_data["kind"] = "procedural"
			disk_data["compatible"] = !!proc_disk.compatible(shuttle)
			if(proc_disk.planet_ref)
				disk_data["target_label"] = "[proc_disk.planet_ref.planet_name] Landing"
				disk_data["target_kind"] = "planet"
			else if(proc_disk.encounter_ref)
				disk_data["target_label"] = proc_disk.encounter_ref.encounter_name
				disk_data["target_kind"] = "encounter"
			disk_data["selected"] = (procgen_target != null)
		else
			disk_data["kind"] = "fixed"
			disk_data["compatible"] = !!disk.compatible(shuttle)
			if(disk.destination)
				disk_data["dest_ref"] = "\ref[disk.destination]"
				disk_data["dest_name"] = capitalize(disk.destination.areaname)
				disk_data["dest_occupied"] = !!disk.destination.docked_with
				disk_data["selected"] = (disk.destination == selected_port)
		data["disk"] = disk_data
	else
		data["disk"] = null

	// Dock-request panel.
	if(shuttle.pending_request)
		var/datum/shuttle_dock_request/req = shuttle.pending_request
		var/secs_left = max(round((req.expires_at - world.time) * 0.1), 0)
		data["dock_request"] = list(
			"is_initiator" = (req.initiator == shuttle),
			"other_name" = (req.initiator == shuttle) ? req.target.name : req.initiator.name,
			"mode" = (req.mode == SDR_MODE_RENDEZVOUS) ? "rendezvous" : "in_place",
			"secs_left" = secs_left,
			"timeout_seconds" = round(SDR_REQUEST_TIMEOUT / 10),
		)
	else
		data["dock_request"] = null
	data["dockable_now"] = !!shuttle.is_in_dockable_vlevel()

	// Picker payloads (cheap to compute; included unconditionally so the
	// frontend modals can render without an extra round-trip).
	data["dock_targets"] = build_dock_request_targets()
	data["available_shuttles"] = build_link_candidates(get_area(src), admin_only = FALSE)
	data["admin_available_shuttles"] = isAdminGhost(user) ? build_link_candidates(get_area(src), admin_only = TRUE) : null
	data["internal_ports"] = build_internal_ports()

	return data

// Resolves the shuttle's current phase, returning a list with:
//   "phase"          : one of "idle", "warmup", "transit", "cooldown",
//                      "awaiting_dock", "bs_warmup", "bs_jump", "lockdown"
//   "seconds_left"   : seconds remaining in the current phase, or 0
//   "seconds_total"  : full duration of the current phase, for progress bars
//                      (0 if no meaningful denominator exists)
//
// WARMUP and TRANSIT share a single denominator (pre_flight_delay +
// transit_delay) so the bar reads as one continuous trip from departure
// to arrival.
/obj/machinery/computer/shuttle_control/proc/compute_phase()
	var/list/result = list("phase" = "idle", "seconds_left" = 0, "seconds_total" = 0)
	if(!shuttle)
		return result

	if(shuttle.lockdown)
		result["phase"] = "lockdown"
		return result

	// Bluespace jump. The base /datum/shuttle implementation returns 0 for
	// every shuttle that doesn't support a jump, so this works on any map.
	// Map-specific subtypes (e.g. /datum/shuttle/odyssey) override
	// get_bluespace_state() and get_bluespace_timing() to fill in the timer.
	var/bs_state = shuttle.get_bluespace_state()
	if(bs_state)
		result["phase"] = (bs_state == 2) ? "bs_jump" : "bs_warmup"
		var/list/timing = shuttle.get_bluespace_timing()
		if(timing)
			result["seconds_left"] = timing["seconds_left"]
			result["seconds_total"] = timing["seconds_total"]
		return result

	if(shuttle.moving)
		var/elapsed_ds = max(world.time - shuttle.last_moved, 0)
		var/total_ds = shuttle.pre_flight_delay + shuttle.transit_delay
		if(elapsed_ds < shuttle.pre_flight_delay)
			result["phase"] = "warmup"
		else
			result["phase"] = "transit"
		result["seconds_left"] = max(round((total_ds - elapsed_ds) * 0.1), 0)
		result["seconds_total"] = max(round(total_ds * 0.1), 0)
		return result

	if(shuttle.pending_request && shuttle.pending_request.initiator == shuttle)
		result["phase"] = "awaiting_dock"
		return result

	var/cd_ds = max(shuttle.last_moved + shuttle.cooldown - world.time, 0)
	if(cd_ds > 0)
		result["phase"] = "cooldown"
		result["seconds_left"] = max(round(cd_ds * 0.1), 0)
		result["seconds_total"] = max(round(shuttle.cooldown * 0.1), 0)

	return result

// Lists shuttles the dock-request modal is allowed to target. Mirrors the
// gating in the original Topic dock_request_open handler.
/obj/machinery/computer/shuttle_control/proc/build_dock_request_targets()
	var/list/L = list()
	if(!shuttle || !shuttle.is_in_dockable_vlevel())
		return L
	for(var/datum/shuttle/S in shuttles)
		if(S == shuttle)
			continue
		if(!S.is_in_dockable_vlevel())
			continue
		if(S.pending_request)
			continue
		L += list(list("name" = S.name, "ref" = "\ref[S]"))
	return L

// Lists shuttle datums offered by the link-to-shuttle picker. admin_only=TRUE
// drops the LINK_FORBIDDEN exclusion that the player-facing path enforces.
/obj/machinery/computer/shuttle_control/proc/build_link_candidates(area/this_area, admin_only = FALSE)
	var/list/L = list()
	for(var/datum/shuttle/S in shuttles)
		var/needs_password = FALSE
		if(S.can_link_to_computer == LINK_FORBIDDEN)
			if(!admin_only)
				continue
		else if(S.can_link_to_computer == LINK_FREE || (this_area && this_area.get_shuttle() == S))
			needs_password = FALSE
		else if(S.password)
			needs_password = TRUE
		else
			continue
		L += list(list("name" = S.name, "ref" = "\ref[S]", "needs_password" = needs_password))
	return L

// Lists internal shuttle docking ports for the link-to-port modal.
/obj/machinery/computer/shuttle_control/proc/build_internal_ports()
	var/list/L = list()
	if(!shuttle || !shuttle.linked_area)
		return L
	for(var/obj/docking_port/shuttle/S in shuttle.shuttle_contents())
		L += list(list("name" = capitalize(S.areaname), "ref" = "\ref[S]"))
	return L

/// Only pass `user` if the mob is directly interacting through the UI.
/obj/machinery/computer/shuttle_control/proc/try_move(mob/user)
	if(!shuttle)
		if(user)
			to_chat(user, "<span class='warning'>No shuttle detected.</span>")
		return

	// Land on a planet or travel to an encounter
	if(procgen_target && istype(disk, /obj/item/weapon/disk/shuttle_coords/procedural))
		var/obj/item/weapon/disk/shuttle_coords/procedural/proc_disk = disk
		if(proc_disk.planet_ref)
			travel_to_planet(proc_disk.planet_ref, user)
			return
		else if(proc_disk.encounter_ref)
			travel_to_encounter(proc_disk.encounter_ref, user)
			return

	if(!selected_port && shuttle.docking_ports.len >= 2)
		selected_port = pick(shuttle.docking_ports - shuttle.current_port)

	if(istype(selected_port, /obj/docking_port/destination/planet_surface))
		var/obj/docking_port/destination/planet_surface/surface_port = selected_port
		var/datum/virtual_z/vz = surface_port.get_virtual_z()

		// Reuse existing transit port if valid, otherwise create a new one
		var/obj/docking_port/destination/transit/transit_port = shuttle.transit_port
		if(!transit_port)
			transit_port = generate_transit_area(shuttle)
			shuttle.set_transit_dock(transit_port)
		if(transit_port)
			transit_port.areaname = "transit to [vz?.planet?.planet_name]" || "planet surface"
			transit_port.generate_borders = 1

	//Send a message to the shuttle to move
	shuttle.travel_to(selected_port, src, user)

	selected_port = null
	procgen_target = null
	updateUsrDialog()

/obj/machinery/computer/shuttle_control/proc/travel_to_planet(datum/planet_type/planet, mob/user)
	if(!(planet?.v))
		to_chat(user, "<span class='warning'>Planet data unavailable.</span>")
		return

	var/list/shuttle_size = shuttle.get_size()
	if(!shuttle_size)
		to_chat(user, "<span class='warning'>Unable to determine shuttle dimensions.</span>")
		return

	if(istype(shuttle.current_port, /obj/docking_port/destination/planet_surface))
		var/datum/virtual_z/vz = shuttle.current_port.get_virtual_z()
		if(vz == planet.v)
			to_chat(user, "<span class='warning'>The shuttle is already on [planet.planet_name].</span>")
			return

	// Get or create a landing zone for this shuttle
	var/obj/docking_port/destination/planet_surface/surface_port = planet.v.get_shuttle_landing_zone(shuttle, shuttle_size)
	if(!surface_port)
		to_chat(user, "<span class='warning'>No suitable landing zone found on [planet.planet_name].</span>")
		return

	// Set the disk's destination to the surface port for validation purposes
	if(istype(disk, /obj/item/weapon/disk/shuttle_coords/procedural))
		var/obj/item/weapon/disk/shuttle_coords/procedural/proc_disk = disk
		proc_disk.destination = surface_port

	// Reuse existing transit port if valid, otherwise create a new one
	var/obj/docking_port/destination/transit/transit_port = shuttle.transit_port
	if(!transit_port)
		transit_port = generate_transit_area(shuttle)
		if(!transit_port)
			to_chat(user, "<span class='warning'>Failed to create transit area.</span>")
			return
		shuttle.set_transit_dock(transit_port)
	transit_port.areaname = "transit to [planet.planet_name]"
	transit_port.generate_borders = 1

	shuttle.travel_to(surface_port, src, user)

/obj/machinery/computer/shuttle_control/proc/travel_to_encounter(datum/encounter/encounter, mob/user)
	if(!(encounter?.v))
		to_chat(user, "<span class='warning'>Encounter data unavailable.</span>")
		return

	var/obj/docking_port/destination/dock = encounter.get_shuttle_docking_port(shuttle)
	if(!dock)
		to_chat(user, "<span class='warning'>Unable to find a safe approach vector for this shuttle.</span>")
		return

	if(istype(disk, /obj/item/weapon/disk/shuttle_coords/procedural))
		var/obj/item/weapon/disk/shuttle_coords/procedural/proc_disk = disk
		proc_disk.destination = dock

	var/obj/docking_port/destination/transit/transit_port = shuttle.transit_port
	if(!transit_port)
		transit_port = generate_transit_area(shuttle)
		if(!transit_port)
			to_chat(user, "<span class='warning'>Failed to create transit area.</span>")
			return
		shuttle.set_transit_dock(transit_port)
	transit_port.areaname = "transit to [encounter.encounter_name]"
	transit_port.generate_borders = 1

	shuttle.travel_to(dock, src, user)

/obj/machinery/computer/shuttle_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(issilicon(usr) && !allow_silicons)
		to_chat(usr, "<span class='notice'>There seems to be a firewall preventing you from accessing this device.</span>")
		return TRUE

	add_fingerprint(usr)
	var/needs_admin = (copytext(action, 1, 7) == "admin_")

	// Player-facing actions all gate on access, except: disk handling and
	// course plotting (no access check in the original Topic handler either),
	// and the admin paths which only check ghost status.
	var/static/list/skip_allowed = list(
		"eject_disk",
		"set_custom_coord",
		"process_custom_coord",
	)
	if(!needs_admin && !(action in skip_allowed))
		if(!allowed(usr))
			to_chat(usr, "<span class='red'>Access denied.</span>")
			return TRUE

	if(needs_admin && !isAdminGhost(usr))
		to_chat(usr, "You must be an admin for this.")
		return TRUE

	switch(action)
		if("move")
			try_move(usr)
			return TRUE

		if("select_port")
			var/obj/docking_port/A = locate(params["ref"]) in all_docking_ports
			if(!A)
				return TRUE
			selected_port = A
			procgen_target = null
			return TRUE

		if("select_procedural")
			if(!istype(disk, /obj/item/weapon/disk/shuttle_coords/procedural))
				return TRUE
			var/obj/item/weapon/disk/shuttle_coords/procedural/proc_disk = disk
			if(proc_disk.planet_ref)
				procgen_target = proc_disk.planet_ref.planet_name
			else if(proc_disk.encounter_ref)
				procgen_target = proc_disk.encounter_ref.encounter_name
			selected_port = null
			return TRUE

		if("link_to_shuttle")
			if(!shuttle_link_request(params, admin_path = FALSE))
				return TRUE
			return TRUE

		if("link_to_port")
			if(!shuttle || !shuttle.linked_area)
				return TRUE
			var/obj/docking_port/shuttle/S = locate(params["ref"])
			if(!istype(S))
				return TRUE
			if(!(S in shuttle.shuttle_contents()))
				return TRUE
			S.link_to_shuttle(shuttle)
			to_chat(usr, "Successfully linked [capitalize(shuttle.name)] to the port.")
			return TRUE

		if("set_custom_coord")
			if(!istype(disk, /obj/item/weapon/disk/shuttle_coords/free_move))
				return TRUE
			var/value = text2num(params["value"])
			if(isnull(value))
				return TRUE
			switch(params["axis"])
				if("x")
					custom_x = value
				if("y")
					custom_y = value
				if("z")
					custom_z = value
				if("rot")
					custom_rot = value
			return TRUE

		if("process_custom_coord")
			if(!istype(disk, /obj/item/weapon/disk/shuttle_coords/free_move))
				return TRUE
			var/turf/dest = locate(\
				shuttle.linked_port.x + custom_x,\
				shuttle.linked_port.y + custom_y,\
				shuttle.linked_port.z + custom_z\
			)
			if(!dest || dest.z == map.zCentcomm || (!istype(dest, /turf/space) && !shuttle.destroy_everything))
				to_chat(usr, "Error! Bad coordinates.")
				return TRUE
			if(istype(disk.destination, /obj/docking_port/destination/coord))
				if(shuttle.current_port == disk.destination)
					shuttle.current_port = null
				QDEL_NULL(disk.destination)
			disk.destination = new /obj/docking_port/destination/coord(dest)
			disk.destination.dir = angle2dir(dir2angle(shuttle.linked_port.dir) + custom_rot + 180)
			disk.destination.areaname = "COURSE:[time2text(world.timeofday, "MM:DD")]:[game_year]:[worldtime2text()]"
			to_chat(usr, "Destination calculated!")
			return TRUE

		if("eject_disk")
			if(!disk)
				// Insert flow: pull a disk from the user's hand if they have one.
				var/obj/item/weapon/disk/shuttle_coords/D = usr.get_active_hand()
				if(istype(D))
					insert_disk(D, usr)
				return TRUE
			disk.forceMove(get_turf(src))
			usr.put_in_hands(disk)
			to_chat(usr, "<span class='info'>You eject \the [disk] from \the [src].</span>")
			if(disk.destination == selected_port)
				selected_port = null
			procgen_target = null
			disk = null
			return TRUE

		if("dock_request_open")
			if(!shuttle)
				return TRUE
			if(shuttle.pending_request)
				to_chat(usr, "<span class='warning'>A docking request is already pending.</span>")
				return TRUE
			if(!shuttle.is_in_dockable_vlevel())
				to_chat(usr, "<span class='warning'>This shuttle is not parked in a dockable location.</span>")
				return TRUE
			var/datum/shuttle/target = locate(params["ref"])
			if(!istype(target) || !(target in shuttles))
				return TRUE
			var/code = shuttle.request_docking(target, usr)
			if(code != SDR_OK_PENDING && code != SDR_OK_AUTO_ACCEPTED)
				to_chat(usr, "<span class='warning'>Cannot request docking: [shuttle.dock_request_error_message(code)]</span>")
			return TRUE

		if("dock_request_cancel")
			if(shuttle?.pending_request && shuttle.pending_request.initiator == shuttle)
				shuttle.pending_request.cancel()
			return TRUE

		if("dock_request_accept")
			if(shuttle?.pending_request && shuttle.pending_request.target == shuttle)
				shuttle.pending_request.accept()
			return TRUE

		if("dock_request_reject")
			if(!(shuttle?.pending_request && shuttle.pending_request.target == shuttle))
				return TRUE
			var/reason = params["reason"]
			if(!istext(reason))
				reason = ""
			shuttle.pending_request.reject(reason)
			return TRUE

		// --- Admin-only paths --------------------------------------------
		if("admin_link_to_shuttle")
			var/datum/shuttle/S = locate(params["ref"])
			if(istype(S) && (S in shuttles))
				shuttle = S
			return TRUE

		if("admin_unlink_shuttle")
			shuttle = null
			return TRUE

		if("admin_toggle_lockdown")
			if(!shuttle)
				return TRUE
			if(shuttle.lockdown)
				shuttle.lockdown = 0
			else
				var/reason = params["reason"]
				shuttle.lockdown = istext(reason) && length(reason) ? reason : 1
			return TRUE

		if("admin_toggle_select_all")
			allow_selecting_all = !allow_selecting_all
			to_chat(usr, allow_selecting_all ? "Now selecting from all existing docking ports." : "Now selecting from shuttle's docking ports.")
			return TRUE

		if("admin_reset")
			if(!shuttle)
				return TRUE
			shuttle.initialize()
			to_chat(usr, "Shuttle's list of travel destinations has been reset")
			return TRUE

		if("admin_toggle_silicon_use")
			allow_silicons = !allow_silicons
			to_chat(usr, allow_silicons ? "Silicons may now use [src] again." : "Silicons can no longer use [src].")
			return TRUE

	return FALSE

// Resolves a player-side link-to-shuttle request, including the password gate.
// Returns TRUE on success (link performed) and FALSE on any failure path so
// the caller can decide whether to keep going.
/obj/machinery/computer/shuttle_control/proc/shuttle_link_request(list/params, admin_path = FALSE)
	var/datum/shuttle/S = locate(params["ref"])
	if(!istype(S) || !(S in shuttles))
		return FALSE
	var/area/this_area = get_area(src)
	var/freely_listable = (S.can_link_to_computer == LINK_FREE) || (this_area && this_area.get_shuttle() == S)

	if(S.can_link_to_computer == LINK_FORBIDDEN && !admin_path)
		return FALSE

	if(!freely_listable && S.password)
		var/password_attempt = text2num(params["password"])
		if(isnull(password_attempt) || password_attempt != S.password)
			to_chat(usr, "<span class='warning'>Incorrect password.</span>")
			return FALSE

	link_to(S)
	to_chat(usr, "Successfully linked [src] to [capitalize(S.name)]!")
	return TRUE

/obj/machinery/computer/shuttle_control/proc/insert_disk(obj/item/weapon/disk/shuttle_coords/SC, mob/user)
	if(!shuttle)
		to_chat(user, "<span class='info'>\The [src] is unresponsive.</span>")
		return

	if(!istype(SC))
		if(istype(SC, /obj/item/weapon/disk)) //It's a disk, but not a compactible one
			to_chat(user, "<span class='info'>The disk is rejected by \the [src].</span>")

		return

	if(disk)
		//An old disk is already inserted.
		to_chat(user, "<span class='warning'>The old [disk.name] pops out of the disk slot!</span>")
		disk.forceMove(loc)
		procgen_target = null
		disk = null

	if(user.drop_item(SC, src))
		disk = SC
		to_chat(user, "<span class='info'>You insert \the [SC] into \the [src].</span>")
		updateUsrDialog()

/obj/machinery/computer/shuttle_control/proc/use_pass(obj/item/weapon/card/shuttle_pass/P, mob/user)
	if(!istype(P))
		return

	if(user.drop_item(P, src))
		if(shuttle && shuttle.type == P.allowed_shuttle)
			if(shuttle.travel_to(P.destination, src, user))
				to_chat(user, "<span class='info'>You insert \the [P] into \the [src].</span>")
				qdel(P)
				return
		to_chat(user, "<span class='info'>You insert \the [P] into \the [src], but it is rejected.</span>")
		user.put_in_hands(P)

/obj/machinery/computer/shuttle_control/kick_act(mob/user)
	..()
	if(is_operational() && (user ? user.lucky_prob(5, luckfactor = 1/5) : prob(5)))
		try_move()

/obj/machinery/computer/shuttle_control/emp_act(severity)
	if(is_operational() && prob(50))
		try_move()

/obj/machinery/computer/shuttle_control/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")
	return ..() // Nothing happens (?)

/obj/machinery/computer/shuttle_control/proc/link_to(var/datum/shuttle/S, var/add_to_list = 1)
	if(shuttle)
		if(src in shuttle.control_consoles)
			shuttle.control_consoles -= src

	shuttle = S
	if(add_to_list)
		shuttle.control_consoles |= src
	req_access = shuttle.req_access
	updateUsrDialog()

/obj/machinery/computer/shuttle_control/emag_act(mob/user as mob)
	..()
	req_access = list()
	if(user)
		to_chat(user, "You disable the console's access requirement.")

#undef MAX_SHUTTLE_NAME_LEN
