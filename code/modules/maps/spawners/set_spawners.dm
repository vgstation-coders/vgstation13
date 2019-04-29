
//**************************************************************
//
// Set Spawners
// -----------------
// The path is strange because 'set' is a keyword.
//
//**************************************************************

/obj/abstract/map/spawner/set_spawner
	var/sub_chance = 100

/obj/abstract/map/spawner/set_spawner/perform_spawn()

	var/obj/spawned
	to_spawn = pick(to_spawn)
	for(var/i = 1, i <= amount, i++)
		for(spawned in to_spawn)
			if(sub_chance)
				new spawned(loc)
				if(jiggle)
					spawned.pixel_x = rand(-jiggle, jiggle) * PIXEL_MULTIPLIER
					spawned.pixel_y = rand(-jiggle, jiggle) * PIXEL_MULTIPLIER