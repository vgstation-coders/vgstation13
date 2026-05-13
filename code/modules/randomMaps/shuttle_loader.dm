// Shuttle loading via map element. Used by maps that declare load_shuttles.
//
// Each entry in /datum/map/load_shuttles is a /datum/map_element/shuttle subtype.
// At map init time (after fixedvaults), each one loads its DMM into a fresh
// VZ_PARKING vlevel, places a parking destination port at the shuttle's docking
// turf, and back-fills the global shuttle datum so setup_shuttles() picks it
// up like any other shuttle.
//
// After all shuttles are initialized, generate_shuttle_docking_vlevels() walks
// every unordered pair of load_shuttles shuttles and, for the first compatible
// dynamic-port pair, creates a permanent docking vlevel with destination ports
// laid out so the dynamic ports line up when both shuttles dock.

// Registry of /datum/shuttle datums by type, populated in /datum/shuttle/New.
// Lets the shuttle loader resolve a shuttle datum even if its area doesn't
// exist yet (and so it isn't in the global shuttles list).
var/global/list/shuttle_datums_by_path = list()

// Loaded shuttle map elements, in load order. Used to drive docking-vlevel pairing.
var/global/list/datum/map_element/shuttle/loaded_shuttle_map_elements = list()

//
// Dynamic shuttle docking port: lives on a shuttle hull at a valid ship-to-ship
// docking location. Marks where another shuttle could dock against this one.
// Mappers place these inside shuttle DMMs and configure whitelist/blacklist.
//
// NOT picked as the shuttle's primary linked_port (see /datum/shuttle/initialize).
//
/obj/docking_port/shuttle/dynamic
	name = "dynamic docking port"
	icon_state = "docking_dynamic"
	areaname = "rendezvous"

	// If non-null and non-empty, only shuttles whose datum istype() one of these paths may dock here. Null/empty means no whitelist constraint.
	var/list/shuttle_whitelist = null
	// Shuttles whose datum istype() any of these paths may not dock here.
	var/list/shuttle_blacklist = list()

/obj/docking_port/shuttle/dynamic/can_shuttle_move(datum/shuttle/S)
	if(S && linked_shuttle == S)
		return 1
	return 0

/obj/docking_port/shuttle/dynamic/proc/allows_shuttle(datum/shuttle/S)
	if(!S)
		return FALSE
	if(shuttle_whitelist && shuttle_whitelist.len)
		var/matched = FALSE
		for(var/T in shuttle_whitelist)
			if(istext(T))
				T = text2path(T)
			if(T && istype(S, T))
				matched = TRUE
				break
		if(!matched)
			return FALSE
	for(var/T in shuttle_blacklist)
		if(istext(T))
			T = text2path(T)
		if(T && istype(S, T))
			return FALSE
	return TRUE

// A dynamic port is "occupied" if some shuttle has a dock_request commitment
// against it; either docked alongside (current_port is a dock_request with
// pa==src or pb==src) or inbound to one (destination_port likewise). This
// covers both "another ship is here right now" and "another ship is enroute
// and has reserved this slot".
/obj/docking_port/shuttle/dynamic/proc/is_occupied()
	for(var/datum/shuttle/S in shuttles)
		var/obj/docking_port/destination/dock_request/cur = S.current_port
		if(istype(cur) && cur.source_req && (cur.source_req.pa == src || cur.source_req.pb == src))
			return TRUE
		var/obj/docking_port/destination/dock_request/dst = S.destination_port
		if(istype(dst) && dst.source_req && (dst.source_req.pa == src || dst.source_req.pb == src))
			return TRUE
	return FALSE

//
// Map element that loads a shuttle DMM into its own VZ_PARKING vlevel.
//
/datum/map_element/shuttle
	name = "shuttle"
	vz_type = VZ_PARKING

	// Type path of the global /datum/shuttle this DMM provides the body for.
	var/shuttle_datum_path = null

	// Buffer of empty space turfs around the shuttle inside its parking vlevel.
	var/parking_buffer = 7

	// If non-zero, the parking vlevel will be exactly this wide/tall instead of being sized dynamically from the shuttle dimensions + parking_buffer.
	var/parking_width = 0
	var/parking_height = 0

	// If set, after the shuttle finishes loading + setup, the loader moves it from its parking vlevel onto the destination port matched by this type from all_docking_ports.
	// The port must already exist when the move runs (typically placed inside a fixedvault that loads earlier in load_custom_fixedvaults() which runs before load_shuttles()).
	// The parking vlevel itself is still created so the shuttle has a home to return to.
	var/initial_dock_port_path = null

/datum/map_element/shuttle/initialize(list/objects)
	..()
	loaded_shuttle_map_elements |= src

	if(!shuttle_datum_path)
		warning("/datum/map_element/shuttle [type] has no shuttle_datum_path set")
		return

	var/datum/shuttle/S = shuttle_datums_by_path[shuttle_datum_path]
	if(!S)
		warning("/datum/map_element/shuttle [type]: cannot find global shuttle datum [shuttle_datum_path]. Was the shuttle datum's New() called before maps loaded?")
		return

	// Find shuttle areas in the loaded objects and back-fill the shuttle datum.
	var/list/loaded_areas = list()
	for(var/atom/A in objects)
		var/area/found_area
		if(isturf(A))
			found_area = A.loc
		else if(isarea(A))
			found_area = A
		if(found_area && !(found_area in loaded_areas))
			loaded_areas |= found_area

	S.attach_loaded_areas(loaded_areas)

	// Place the parking destination port at the shuttle's docking turf so the shuttle auto-docks here when initialize() runs in setup_shuttles().
	var/obj/docking_port/shuttle/shuttle_port = null
	for(var/area/A in S.linked_areas)
		for(var/obj/docking_port/shuttle/P in A.contents)
			if(istype(P, /obj/docking_port/shuttle/dynamic))
				continue
			shuttle_port = P
			break
		if(shuttle_port)
			break

	if(!shuttle_port)
		warning("/datum/map_element/shuttle [type]: loaded shuttle has no primary /obj/docking_port/shuttle")
		return

	var/turf/dest_turf = get_step(get_turf(shuttle_port), shuttle_port.dir)
	if(!dest_turf)
		warning("/datum/map_element/shuttle [type]: shuttle docking turf is off-map")
		return

	var/obj/docking_port/destination/parking = new(dest_turf)
	parking.dir = turn(shuttle_port.dir, 180)
	parking.areaname = "[S.name] parking"
	S.parking_port = parking

// Loads each /datum/map_element/shuttle entry in map.load_shuttles into its own parking vlevel.
/proc/load_map_shuttles()
	for(var/T in map.load_shuttles)
		var/datum/map_element/shuttle/ME
		if(ispath(T, /datum/map_element/shuttle))
			ME = new T
		else if(istype(T, /datum/map_element/shuttle))
			ME = T
		else
			warning("load_map_shuttles: ignoring [T] - not a /datum/map_element/shuttle path or instance")
			continue

		// Add a vLevel with adequate padding
		ME.assign_dimensions()
		var/vlevel_w = ME.parking_width ? ME.parking_width : ME.width + ME.parking_buffer * 2
		var/vlevel_h = ME.parking_height ? ME.parking_height : ME.height + ME.parking_buffer * 2
		var/datum/virtual_z/parking_vz = map.addVLevel(vlevel_w, vlevel_h)
		parking_vz.level_type = ME.vz_type
		parking_vz.name = "[ME.name] parking"

		// Center the shuttle within the vLevel
		var/x_offset = round((vlevel_w - ME.width) / 2)
		var/y_offset = round((vlevel_h - ME.height) / 2)
		ME.load(parking_vz.x_min - 1 + x_offset, parking_vz.y_min - 1 + y_offset, parking_vz.parent_z.z, ME.rotation)

		// Tie the parking vlevel to the shuttle datum once we know which one ended up linked to the loaded areas.
		var/datum/shuttle/S = shuttle_datums_by_path[ME.shuttle_datum_path]
		if(S)
			parking_vz.linked_shuttle = S

// After setup_shuttles() has run, give each loaded shuttle a transit vlevel (if it doesn't have one yet) and fire its post_setup() hook.
/proc/setup_shuttle_transit_areas()
	if(!loaded_shuttle_map_elements.len)
		return

	for(var/datum/map_element/shuttle/ME in loaded_shuttle_map_elements)
		var/datum/shuttle/S = shuttle_datums_by_path[ME.shuttle_datum_path]
		if(!S || !S.linked_port)
			continue
		if(!S.transit_port)
			var/obj/docking_port/destination/transit/transit = generate_transit_area(S)
			if(transit)
				S.set_transit_dock(transit)
				S.add_dock(transit)
		S.post_setup()

		// If the mapper requested a specific starting dock, relocate the shuttle off its parking vlevel and onto that port now.
		if(ME.initial_dock_port_path)
			var/obj/docking_port/destination/target = null
			for(var/obj/docking_port/destination/D in all_docking_ports)
				if(istype(D, ME.initial_dock_port_path))
					target = D
					break
			if(!target)
				warning("/datum/map_element/shuttle [ME.type]: initial_dock_port_path [ME.initial_dock_port_path] not found in all_docking_ports")
			else if(!S.move_to_dock(target, ignore_innacuracy = 1))
				warning("/datum/map_element/shuttle [ME.type]: failed to move [S.name] to initial dock [ME.initial_dock_port_path]")
