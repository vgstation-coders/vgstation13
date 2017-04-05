//map elements: areas loaded into the game during runtime
//see: vaults, away missions
var/list/datum/map_element/map_elements = list()

/datum/map_element
	var/name //Name of the map element. Optional
	var/desc //Short description. Optional
	var/type_abbreviation //Very short string that determines the map element's type (whether it's an away mission, a small vault, or something else)

	var/file_path = "maps/randomvaults/new.dmm"

	var/turf/location //Lower left turf of the map element

	var/width //Width of the map element, in turfs
	var/height //Height of the map element, in turfs

/datum/map_element/proc/pre_load() //Called before loading the element
	return

/datum/map_element/proc/initialize(list/objects) //Called after loading the element. The "objects" list contains all spawned atoms
	map_elements.Add(src)

	if(!location && objects.len)
		location = locate(/turf) in objects

	for(var/atom/A in objects)
		A.spawned_by_map_element(src, objects)

/datum/map_element/proc/load(x, y, z)
	pre_load()

	if(file_path)
		var/file = file(file_path)
		if(isfile(file))
			var/list/L = maploader.load_map(file, z, x, y, src)
			initialize(L)
			return L
	else //No file specified - empty map element
		//These variables are usually set by the map loader. Here we have to set them manually
		location = locate(x+1, y+1, z) //Location is always lower left corner
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

//Return a list with strings associated with points
//For example: list("Discovered a vault!" = 500) will add 500 points to the crew's score for discovering a vault
/datum/map_element/proc/process_scoreboard()
	return

//Proc for statskeeping and tracking objects. Cleans references afterwards - very safe to use. Use it to assign objects as values to variables
//Example use:
//  boss_enemy = track_atom(new /mob/living/simple_animal/corgi)

/datum/map_element/proc/track_atom(atom/A)
	if(!istype(A))
		return

	A.on_destroyed.Add(src, "clear_references")

	return A


/datum/map_element/proc/clear_references(list/params)
	var/atom/A = locate(/atom) in params

	//Remove instances by brute force (there aren't that many vars in map element datums)
	for(var/key in vars)
		if(vars[key] == A)
			vars[key] = null
		else if(istype(vars[key], /list))
			var/list/L = vars[key]

			//Remove all instances from the list
			while(L.Remove(A))
				continue

