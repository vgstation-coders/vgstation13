//map elements: areas loaded into the game during runtime
//see: vaults, away missions
var/list/datum/map_element/map_elements = list()

/datum/map_element
	var/name //Name of the map element. Optional
	var/desc //Short description. Optional
	var/type_abbreviation //Very short string that determines the map element's type (whether it's an away mission, a small vault, or something else)

	var/file_path = "maps/randomvaults/new.dmm"
	var/load_at_once = TRUE //If true, lag reduction methods will not be applied when this is loaded, freezing atmos and mob simulations until the map element is loaded.

	var/turf/location //Lower left turf of the map element
	var/list/spawned_atoms = list()

	var/width //Width of the map element, in turfs
	var/height //Height of the map element, in turfs
	var/can_rotate = FALSE //Can this be rotated?
	var/rotation = 0 //The map's rotation value

/datum/map_element/proc/pre_load() //Called before loading the element
	return

/datum/map_element/proc/can_load(x, y)
	if(map.can_enlarge)
		return TRUE
	if(x + width > world.maxx || y + height > world.maxy)
		WARNING("Cancelled loading [src]. Map enlargement is forbidden.")
		return FALSE
	return TRUE

/datum/map_element/initialize(list/objects) //Called after loading the element. The "objects" list contains all spawned atoms
	map_elements.Add(src)

	if(!location && objects.len)
		location = locate(/turf) in objects

	for(var/atom/A in objects)
		A.spawned_by_map_element(src, objects)


/datum/map_element/proc/load(x, y, z, rotate=0, overwrite = FALSE, override_can_rotate = FALSE, clipmin_x=0, clipmax_x=INFINITY, clipmin_y=0, clipmax_y=INFINITY, clipmin_z=0, clipmax_z=INFINITY)
	//Location is always lower left corner.
	//In some cases, location is set to null (when creating a new z-level, for example)
	//To account for that, location is set again in maploader's load_map() proc
	location = locate(x+1, y+1, z)
	if(can_rotate || override_can_rotate) //Only if enabled on map element
		rotation = rotate

	if(!can_load(x,y))
		return 0

	pre_load()

	if(file_path)
		var/file = file(file_path)
		if(isfile(file))
			spawned_atoms = maploader.load_map(file, z, x, y, src, rotation, overwrite, clipmin_x, clipmax_x, clipmin_y, clipmax_y, clipmin_z, clipmax_z)
			initialize(spawned_atoms)
			return spawned_atoms
	else //No file specified - empty map element
		//These variables are usually set by the map loader. Here we have to set them manually
		initialize(list()) //Initialize with an empty list
		return 1

	return 0

//Returns a list with two numbers
//First number is width, second number is height
/datum/map_element/proc/get_dimensions()
	var/file = file(file_path)
	if(isfile(file))
		return maploader.get_map_dimensions(file)

	return list(width, height)

/datum/map_element/proc/assign_dimensions()
	var/list/dimensions = get_dimensions()

	width = dimensions[1]
	height = dimensions[2]

//Return a list with strings associated with points
//For example: list("Discovered a vault!" = 500) will add 500 points to the crew's score for discovering a vault
/datum/map_element/proc/process_scoreboard()
	return

//Proc for statskeeping and tracking objects. Cleans references afterwards - very safe to use. Use it to assign objects as values to variables
//Example use:
//  boss_enemy = track_atom(new /mob/living/simple_animal/corgi)

/datum/map_element/proc/track_atom(atom/movable/A)
	if(!istype(A))
		return

	A.register_event(/event/destroyed, src, nameof(src::clear_references()))
	return A


/datum/map_element/proc/clear_references(datum/thing)
	if(!thing)
		return

	//Remove instances by brute force (there aren't that many vars in map element datums)
	for(var/key in vars)
		if(key == "vars")
			continue

		if(vars[key] == thing)
			vars[key] = null
		else if(istype(vars[key], /list))
			var/list/L = vars[key]

			//Remove all instances from the list
			while(L.Remove(thing))
				continue
