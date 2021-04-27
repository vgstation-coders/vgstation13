//
// PICK_SPAWNERS
//
// These work the same as regular map spawners, except that you place many of them and only ONE will be picked to spawn.
// They have a required ID field (which is a string). It should be unique per spawner type. Only one successful spawn is allowed per ID.
//
// Example: You want to spawn 1 pair of insulated gloves in a room, but you want to randomize in which tile they will spawn.
// For this purpose, you would create a normal map spawner that spawns 1 pair of insulated gloves, and give it a new, unique ID like "yellowgloves_myroomname".
// You then place that same pickspawner 5 times in 5 different tiles. When the game loads, the gloves will randomly spawn in 1 out of those 5 possible locations.
// If you want to add a second pair of insulated gloves in a DIFFERENT room, you need a new pickspawner with a fresh ID.

/obj/abstract/map/spawner/pick_spawner
	var/id = "" //required

/obj/abstract/map/spawner/pick_spawner/New()
	//deliberately not calling parent, because our parent would perform_spawn() us
	ASSERT(id)
	if(!map_pickspawners[id])
		map_pickspawners[id] = list()
	map_pickspawners[id] += src

/obj/abstract/map/spawner/pick_spawner/Destroy()
	if(id && map_pickspawners[id])
		map_pickspawners[id] -= src

//This is called in /datum/subsystem/map/Initialize().
/proc/spawn_map_pickspawners()
	for(var/id in map_pickspawners)
		var/obj/abstract/map/spawner/pick_spawner/winner = pick(map_pickspawners[id])
		winner.perform_spawn()
		for(var/obj/abstract/map/spawner/pick_spawner/loser in pick(map_pickspawners[id]))
			qdel(loser) //They automatically remove themselves from our list in their Destroy().



//**************************************************************
// Subtypes ////////////////////////////////////////////////////
//**************************************************************

/obj/abstract/map/spawner/pick_spawner/yellowgloves
	id = "yellowgloves_maint"
	name = "insulated gloves pickspawner"
	icon_state = "glubb_rand"
	to_spawn = list(
		/obj/item/clothing/gloves/yellow
		)
