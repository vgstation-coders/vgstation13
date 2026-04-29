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
	icon_state = "docking_shuttle"
	areaname = "rendezvous"

	// If non-null and non-empty, only shuttles whose datum istype() one of these
	// paths may dock here. Null/empty means no whitelist constraint.
	var/list/shuttle_whitelist = null
	// Shuttles whose datum istype() any of these paths may not dock here.
	var/list/shuttle_blacklist = list()

/obj/docking_port/shuttle/dynamic/proc/allows_shuttle(datum/shuttle/S)
	if(!S)
		return FALSE
	if(shuttle_whitelist && shuttle_whitelist.len)
		var/matched = FALSE
		for(var/T in shuttle_whitelist)
			if(istype(S, T))
				matched = TRUE
				break
		if(!matched)
			return FALSE
	for(var/T in shuttle_blacklist)
		if(istype(S, T))
			return FALSE
	return TRUE

//
// Map element that loads a shuttle DMM into its own VZ_PARKING vlevel.
//
/datum/map_element/shuttle
	name = "shuttle"
	vz_type = VZ_PARKING

	// Type path of the global /datum/shuttle this DMM provides the body for.
	// Required.
	var/shuttle_datum_path = null

	// Buffer of empty space turfs around the shuttle inside its parking vlevel.
	var/parking_buffer = 7

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

	// Place the parking destination port at the shuttle's docking turf so the
	// shuttle auto-docks here when initialize() runs in setup_shuttles().
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

// Loads each /datum/map_element/shuttle entry in map.load_shuttles into its
// own parking vlevel. Called by SSmapping after fixedvaults.
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

		ME.assign_dimensions()
		// Pad each side of the loaded shuttle with parking_buffer turfs. Use
		// addVLevel rather than addMapElementVLevel so the vlevel defaults
		// (movement allowed, teleport allowed, etc.) match a regular parking
		// area instead of a protected dungeon.
		var/datum/virtual_z/parking_vz = map.addVLevel(ME.width + ME.parking_buffer * 2, ME.height + ME.parking_buffer * 2)
		parking_vz.level_type = ME.vz_type
		parking_vz.name = "[ME.name] parking"
		ME.load(parking_vz.x_min - 1 + ME.parking_buffer, parking_vz.y_min - 1 + ME.parking_buffer, parking_vz.parent_z.z, ME.rotation)

		// Tie the parking vlevel to the shuttle datum once we know which one
		// ended up linked to the loaded areas.
		var/datum/shuttle/S = shuttle_datums_by_path[ME.shuttle_datum_path]
		if(S)
			parking_vz.linked_shuttle = S

// After setup_shuttles() has run, build a docking vlevel for every unordered
// pair of load_shuttles shuttles whose dynamic ports allow each other.
/proc/generate_shuttle_docking_vlevels()
	if(!loaded_shuttle_map_elements.len)
		return

	// Collect (shuttle, dynamic_ports) for every shuttle we loaded.
	var/list/datum/shuttle/loaded_shuttles = list()
	for(var/datum/map_element/shuttle/ME in loaded_shuttle_map_elements)
		var/datum/shuttle/S = shuttle_datums_by_path[ME.shuttle_datum_path]
		if(S && S.linked_port)
			loaded_shuttles |= S

	// Generate transit area for each loaded shuttle that doesn't already have one.
	for(var/datum/shuttle/S in loaded_shuttles)
		if(S.transit_port)
			continue
		var/obj/docking_port/destination/transit/transit = generate_transit_area(S)
		if(transit)
			S.set_transit_dock(transit)
			S.add_dock(transit)

	// Walk unordered pairs.
	for(var/i = 1 to loaded_shuttles.len - 1)
		for(var/j = i + 1 to loaded_shuttles.len)
			var/datum/shuttle/A = loaded_shuttles[i]
			var/datum/shuttle/B = loaded_shuttles[j]
			create_shuttle_pair_docking_vlevel(A, B)

	// Post-setup callback so each shuttle datum can decorate transit vlevels,
	// register transition channels, etc. once everything else is in place.
	for(var/datum/shuttle/S in loaded_shuttles)
		S.post_setup()

// Builds one docking vlevel between two shuttles using the first compatible
// pair of /obj/docking_port/shuttle/dynamic on each side. Both shuttles get
// destination ports added so they can dock here independently.
/proc/create_shuttle_pair_docking_vlevel(datum/shuttle/A, datum/shuttle/B)
	var/obj/docking_port/shuttle/dynamic/port_a = null
	var/obj/docking_port/shuttle/dynamic/port_b = null
	for(var/obj/docking_port/shuttle/dynamic/da in A.shuttle_contents())
		if(!da.allows_shuttle(B))
			continue
		for(var/obj/docking_port/shuttle/dynamic/db in B.shuttle_contents())
			if(!db.allows_shuttle(A))
				continue
			port_a = da
			port_b = db
			break
		if(port_a)
			break
	if(!port_a || !port_b)
		return

	var/list/dims_a = A.get_size()
	var/list/dims_b = B.get_size()
	if(!dims_a || !dims_b)
		return

	var/buffer = 25

	// Decide vlevel orientation by the dynamic port's facing.
	// Horizontal pairing (ports face E/W) -> ships side by side along X.
	// Vertical pairing (ports face N/S)   -> ships stacked along Y.
	var/horizontal = (port_a.dir == EAST || port_a.dir == WEST)

	var/vz_w
	var/vz_h
	if(horizontal)
		vz_w = dims_a[1] + dims_b[1] + buffer * 2
		vz_h = max(dims_a[2], dims_b[2]) + buffer * 2
	else
		vz_w = max(dims_a[1], dims_b[1]) + buffer * 2
		vz_h = dims_a[2] + dims_b[2] + buffer * 2

	var/datum/virtual_z/dock_vz = map.addVLevel(vz_w, vz_h)
	dock_vz.level_type = VZ_SPACE
	dock_vz.name = "[A.name] / [B.name] rendezvous"

	// Pick the rendezvous turf - where port_a will end up after A docks here.
	// Place it so port_b ends one step in port_a.dir, then both shuttles + buffer fit.
	var/rx
	var/ry
	if(horizontal)
		// Ship A on the side opposite port_a.dir, ship B on the same side.
		// E.g. port_a.dir == EAST -> A on west, B on east; rendezvous near the middle.
		ry = dock_vz.y_min + buffer + (max(dims_a[2], dims_b[2]) >> 1)
		if(port_a.dir == EAST)
			rx = dock_vz.x_min + buffer + dims_a[1] - 1
		else
			rx = dock_vz.x_min + buffer + dims_b[1]
	else
		rx = dock_vz.x_min + buffer + (max(dims_a[1], dims_b[1]) >> 1)
		if(port_a.dir == NORTH)
			ry = dock_vz.y_min + buffer + dims_a[2] - 1
		else
			ry = dock_vz.y_min + buffer + dims_b[2]

	var/turf/rendezvous_a = locate(rx, ry, dock_vz.z())
	var/turf/rendezvous_b = get_step(rendezvous_a, port_a.dir)
	if(!rendezvous_a || !rendezvous_b)
		return

	// For each shuttle, compute where its linked_port lands when its dynamic
	// port is at the rendezvous turf, and place a destination port one step
	// further in the linked_port's direction (where get_docking_turf() lands).
	place_pair_destination_port(A, port_a, rendezvous_a, dock_vz, "[B.name] rendezvous")
	place_pair_destination_port(B, port_b, rendezvous_b, dock_vz, "[A.name] rendezvous")

/proc/place_pair_destination_port(datum/shuttle/S, obj/docking_port/shuttle/dynamic/port, turf/rendezvous, datum/virtual_z/dock_vz, areaname)
	// Offset of linked_port relative to dynamic port.
	var/dx = S.linked_port.x - port.x
	var/dy = S.linked_port.y - port.y
	var/lp_x = rendezvous.x + dx
	var/lp_y = rendezvous.y + dy
	var/turf/lp_turf = locate(lp_x, lp_y, dock_vz.z())
	if(!lp_turf)
		return
	// Destination port sits one step in linked_port.dir from where linked_port lands.
	var/turf/dest_turf = get_step(lp_turf, S.linked_port.dir)
	if(!dest_turf)
		return
	var/obj/docking_port/destination/dest = new(dest_turf)
	dest.dir = turn(S.linked_port.dir, 180)
	dest.areaname = areaname
	S.add_dock(dest)
