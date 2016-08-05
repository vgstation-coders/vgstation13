//DUNGEONS
//Map elements that can be loaded into the game with a single proc, without specifying coordinates or any arguments at all.
//They're loaded to z-level 2, and the code places them so that they don't overlap with each other

var/list/existing_dungeons = list()
var/turf/dungeon_area = null


//MARKER: put this on z-2, with plenty of space to the right and north
/obj/effect/landmark/dungeon_area
	name = "Dungeon marker - make sure there's nothing to the right or above this"
	desc = "All \"dungeons\" start spawning here."

/obj/effect/landmark/dungeon_area/New()
	dungeon_area = get_turf(src)

	..()

//Load a map element into a special area on z-2
//You can pass a map element object, or a map element path (like /datum/map_element/meme)

//NOTE: first dungeon spawns in the lower left corner. Next dungeons spawn to the right until there's no more space there.
//Then spawn above the first dungeon and continue to the right...

#define MAXIMUM_DUNGEON_WIDTH 80

proc/load_dungeon(dungeon_type)
	if(!dungeon_area)
		return 0

	var/datum/map_element/ME
	if(ispath(dungeon_type, /datum/map_element))
		ME = new dungeon_type
	else if(istype(dungeon_type, /datum/map_element))
		ME = dungeon_type
	else
		return 0

	var/spawn_x = dungeon_area.x
	var/spawn_y = dungeon_area.y
	//Where to spawn the dungeon

	var/tallest_dungeon_height = 0
	//Highest dungeon in the current row

	for(var/datum/map_element/dungeon in existing_dungeons) //Go through all dungeons in the order they were created
		if(!dungeon.location)
			continue

		if(dungeon.height > tallest_dungeon_height)
			tallest_dungeon_height = dungeon.height

		if(dungeon.location.y > spawn_y) //Start of the new row
			spawn_y = dungeon.location.y
			spawn_x = dungeon_area.x //Go to the beginning of the row
			tallest_dungeon_height = 0
		else //Still in our row
			if(dungeon.location.x + dungeon.width > spawn_x)
				spawn_x = dungeon.location.x + dungeon.width + 1

			if(spawn_x > world.maxx - MAXIMUM_DUNGEON_WIDTH) //No space for a new dungeon here!
				//Go to the next row
				spawn_y = spawn_y + tallest_dungeon_height + 1 //So that nothing in the new row overlaps with the previous one
				spawn_x = dungeon_area.x

	//Reduce X and Y by 1 because these arguments are actually offsets, and they're added to 1;1 in the map loader. Without this, spawning something at 1;1 would result in it getting spawned at 2;2
	var/result = ME.load(spawn_x - 1, spawn_y - 1, dungeon_area.z)
	existing_dungeons.Add(ME)

	return result
