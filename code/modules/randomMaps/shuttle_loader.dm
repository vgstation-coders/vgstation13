// Shuttle loading via map element. Used by maps that declare load_shuttles.
//
// Each entry in /datum/map/load_shuttles is a /datum/map_element/shuttle subtype.
// At map init time (after fixedvaults), each one loads its DMM into a fresh
// VZ_PARKING vlevel, places a parking destination port at the shuttle's docking
// turf, and back-fills the global shuttle datum so setup_shuttles() picks it
// up like any other shuttle.

// Registry of /datum/shuttle datums by type, populated in /datum/shuttle/New.
// Lets the shuttle loader resolve a shuttle datum even if its area doesn't
// exist yet (and so it isn't in the global shuttles list).
var/global/list/shuttle_datums_by_path = list()

// Loaded shuttle map elements, in load order.
var/global/list/datum/map_element/shuttle/loaded_shuttle_map_elements = list()

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

	// If non-zero, the parking vlevel will be exactly this wide/tall instead of
	// being sized dynamically from the shuttle dimensions + parking_buffer.
	var/parking_width = 0
	var/parking_height = 0

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
			shuttle_port = P
			break
		if(shuttle_port)
			break

	if(!shuttle_port)
		warning("/datum/map_element/shuttle [type]: loaded shuttle has no /obj/docking_port/shuttle")
		return

	var/turf/dest_turf = get_step(get_turf(shuttle_port), shuttle_port.dir)
	if(!dest_turf)
		warning("/datum/map_element/shuttle [type]: shuttle docking turf is off-map")
		return

	var/obj/docking_port/destination/parking = new(dest_turf)
	parking.dir = turn(shuttle_port.dir, 180)
	parking.areaname = "[S.name] parking"
	S.parking_port = parking

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
		var/vlevel_w = ME.parking_width ? ME.parking_width : ME.width + ME.parking_buffer * 2
		var/vlevel_h = ME.parking_height ? ME.parking_height : ME.height + ME.parking_buffer * 2
		var/datum/virtual_z/parking_vz = map.addVLevel(vlevel_w, vlevel_h)
		parking_vz.level_type = ME.vz_type
		parking_vz.name = "[ME.name] parking"
		// Centre the shuttle within its parking vlevel so visiting shuttles
		// have room to dock on every side. With no explicit parking_width/_height
		// this still produces parking_buffer turfs of margin on each side.
		var/x_offset = round((vlevel_w - ME.width) / 2)
		var/y_offset = round((vlevel_h - ME.height) / 2)
		ME.load(parking_vz.x_min - 1 + x_offset, parking_vz.y_min - 1 + y_offset, parking_vz.parent_z.z, ME.rotation)

		// Tie the parking vlevel to the shuttle datum once we know which one
		// ended up linked to the loaded areas.
		var/datum/shuttle/S = shuttle_datums_by_path[ME.shuttle_datum_path]
		if(S)
			parking_vz.linked_shuttle = S

// After setup_shuttles() has run, give each loaded shuttle a transit vlevel
// (if it doesn't have one yet) and fire its post_setup() hook.
/proc/setup_loaded_shuttle_transits()
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
