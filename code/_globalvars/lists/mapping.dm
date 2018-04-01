GLOBAL_LIST_INIT(cardinals, list(NORTH, SOUTH, EAST, WEST))
GLOBAL_LIST_INIT(alldirs, list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
GLOBAL_LIST_INIT(diagonals, list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))

GLOBAL_LIST_EMPTY(landmarks_list)				//list of all landmarks created
GLOBAL_LIST_EMPTY(start_landmarks_list)			//list of all spawn points created
GLOBAL_LIST_EMPTY(department_security_spawns)	//list of all department security spawns
GLOBAL_LIST_EMPTY(generic_event_spawns)			//list of all spawns for events
GLOBAL_LIST_EMPTY(jobspawn_overrides)					//These will take precedence over normal spawnpoints if created.

GLOBAL_LIST_EMPTY(wizardstart)
GLOBAL_LIST_EMPTY(nukeop_start)
GLOBAL_LIST_EMPTY(nukeop_leader_start)
GLOBAL_LIST_EMPTY(newplayer_start)
GLOBAL_LIST_EMPTY(prisonwarp)	//prisoners go to these
GLOBAL_LIST_EMPTY(holdingfacility)	//captured people go here
GLOBAL_LIST_EMPTY(xeno_spawn)//Aliens spawn at these.
GLOBAL_LIST_EMPTY(tdome1)
GLOBAL_LIST_EMPTY(tdome2)
GLOBAL_LIST_EMPTY(tdomeobserve)
GLOBAL_LIST_EMPTY(tdomeadmin)
GLOBAL_LIST_EMPTY(prisonwarped)	//list of players already warped
GLOBAL_LIST_EMPTY(blobstart)
GLOBAL_LIST_EMPTY(secequipment)
GLOBAL_LIST_EMPTY(deathsquadspawn)
GLOBAL_LIST_EMPTY(emergencyresponseteamspawn)
GLOBAL_LIST_EMPTY(servant_spawns) //Servants of Ratvar spawn here
GLOBAL_LIST_EMPTY(city_of_cogs_spawns) //Anyone entering the City of Cogs spawns here
GLOBAL_LIST_EMPTY(ruin_landmarks)

	//away missions
GLOBAL_LIST_EMPTY(awaydestinations)	//a list of landmarks that the warpgate can take you to

	//used by jump-to-area etc. Updated by area/updateName()
GLOBAL_LIST_EMPTY(sortedAreas)

GLOBAL_LIST_EMPTY(all_abstract_markers)
