//
// PICK_SPAWNERS
//
// These work the same as regular map spawners, except that you place many of them and only ONE will be picked to spawn.
// They have a required category field (which is a string). By default, only one successful spawn is allowed per category.
//
// Example: You want to spawn 1 pair of insulated gloves in a room, but you want to randomize in which tile they will spawn.
// For this purpose, you would create a pickspawner that spawns 1 pair of insulated gloves, and give it a new, unique category like "yellowgloves_myroomname".
// You then place that same pickspawner 5 times in 5 different tiles. When the game loads, the gloves will randomly spawn in 1 out of those 5 possible locations.
// If you want to add a second pair of insulated gloves in a DIFFERENT room, you need a new pickspawner with a fresh category, like "yellowgloves_myotherroom".
//
// Technically, you can have multiple subtypes of pickspawner with different functionality but the same category.
// For example, you can make a "maint bear" pickspawner, a "space carp" pickspawner, and a "morgue spider" pickspawner, and give them all the same category.
// In that case, even though they do very different things and are in different places, only 1 will spawn regardless.
// This is OK, just make sure that's what you actually want to do (and make sure all pickspawners sharing an category have the same number for var/spawners_to_pick)

/obj/abstract/map/spawner/pick_spawner
	var/category = "" //required
	var/spawners_to_pick = 1 //how many spawners to spawn per our category. if adding multiply types of spawner to an category, ensure this number is consistent between all of them
	var/weight = 100 //set this higher to prioritize a certain spawner over others in the same category

/obj/abstract/map/spawner/pick_spawner/New()
	//deliberately not calling parent, because our parent would perform_spawn() us
	ASSERT(category)
	if(!map_pickspawners[category])
		map_pickspawners[category] = list()
	map_pickspawners[category] += src

/obj/abstract/map/spawner/pick_spawner/Destroy()
	if(category && map_pickspawners[category])
		map_pickspawners[category] -= src
	..()

//This is called in /datum/subsystem/map/Initialize().
/proc/spawn_map_pickspawners()
	for(var/category in map_pickspawners)
		var/amount_to_spawn
		var/possible_spawners = list() //Formatted for pickweight()
		for(var/obj/abstract/map/spawner/pick_spawner/candidate in map_pickspawners[category])
			if(!amount_to_spawn) //We are just taking the value for the first spawner we find since we assume it's consistent between all spawners in the category
				amount_to_spawn = candidate.spawners_to_pick
			possible_spawners[candidate] = candidate.weight

		for(amount_to_spawn, amount_to_spawn, amount_to_spawn--)
			var/obj/abstract/map/spawner/pick_spawner/winner = pickweight(possible_spawners)
			winner.perform_spawn() //It automatically removes itself from the list when spawning.
		for(var/obj/abstract/map/spawner/pick_spawner/loser in map_pickspawners[category])
			qdel(loser) //They automatically remove themselves from the list in their Destroy().



//**************************************************************
// Subtypes ////////////////////////////////////////////////////
//**************************************************************

/obj/abstract/map/spawner/pick_spawner/yellowgloves
	category = "yellowgloves_maint"
	name = "insulated gloves pickspawner"
	icon_state = "glubb_rand"
	to_spawn = list(
		/obj/item/clothing/gloves/yellow
		)
