/datum/planetGenerator/xeno
	mountain_height = 0.4
	perlin_zoom = 65

	primary_area_type = /area/planet/xeno

	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/xeno,
			BIOME_LOW_HUMIDITY = /datum/biome/xeno,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGH_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/xeno
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/xeno,
			BIOME_LOW_HUMIDITY = /datum/biome/xeno,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGH_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/xeno
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/xeno/desert,
			BIOME_LOW_HUMIDITY = /datum/biome/xeno,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGH_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/xeno
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/xeno/desert,
			BIOME_LOW_HUMIDITY = /datum/biome/xeno/desert,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGH_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/xeno
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/xeno/desert,
			BIOME_LOW_HUMIDITY = /datum/biome/xeno/desert,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/xeno/desert,
			BIOME_HIGH_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/xeno
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/xeno/desert,
			BIOME_LOW_HUMIDITY = /datum/biome/xeno/desert,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/xeno/desert,
			BIOME_HIGH_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/xeno
		)
	)

	cave_biome_table = list(
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/xeno/living,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/xeno/living,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/xeno/living
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/xeno/living
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/xeno/nest
		),
		BIOME_HOT_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/xeno/nest,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/xeno/nest,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/xeno/nest
		)
	)

/datum/biome/xeno
	open_turf_types = list(/turf/unsimulated/floor/grey_sand = 1)
	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/flora/xeno_flora = 10,
		/obj/structure/flora/xeno_flora/blue = 10,
		/obj/structure/flora/xeno_flora/red = 10,
		/obj/structure/flora/xeno_flora/orange = 10,
		/obj/structure/acid_puddle = 5
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/alien/drone = 1,
		/mob/living/simple_animal/hostile/alien = 1,
		/mob/living/simple_animal/hostile/alien/sentinel = 1,
		/mob/living/carbon/alien/larva = 5
	)
	loot_spawners = list(
		/obj/abstract/loot_spawner/exotic = 1
	)

/datum/biome/xeno/desert
	open_turf_types = list(/turf/unsimulated/floor/planetary/xeno/desert = 1)
	flora_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/acid_puddle = 1,
		/obj/structure/flora/rock = 1,
		/obj/structure/flora/rock/pile = 1,
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/alien/drone = 1,
		/mob/living/simple_animal/hostile/alien = 1,
		/mob/living/simple_animal/hostile/alien/sentinel = 1,
		/mob/living/carbon/alien/larva = 5
	)
	loot_spawners = list(
		/obj/abstract/loot_spawner/exotic = 1
	)

/datum/biome/cave/xeno
	open_turf_types = list(/turf/unsimulated/floor/planetary/cave = 1)
	closed_turf_types = list(
		/turf/unsimulated/mineral/random/xeno = 3,
		/turf/unsimulated/mineral/random/high_chance/xeno = 1,
	)

	mob_spawn_chance = 3
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/alien/drone = 10,
		/mob/living/simple_animal/hostile/alien = 10,
		/mob/living/simple_animal/hostile/alien/queen = 1,
		/mob/living/simple_animal/hostile/alien/sentinel = 10,
	)

	flora_spawn_chance = 0.4
	flora_spawn_list = list(
		/obj/item/clothing/mask/facehugger = 1,
		/obj/structure/acid_puddle = 5
	)
	loot_spawners = list(
		/obj/abstract/loot_spawner/combat = 1,
		/obj/abstract/loot_spawner/exotic = 2
	)

/datum/biome/cave/xeno/nest
	open_turf_types = list(/turf/unsimulated/floor/planetary/cave = 1)
	closed_turf_types = list(
		/turf/unsimulated/mineral/random/xeno = 3,
		/turf/unsimulated/mineral/random/high_chance/xeno = 1,
	)

	mob_spawn_chance = 3
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/alien/drone = 10,
		/mob/living/simple_animal/hostile/alien = 10,
		/mob/living/simple_animal/hostile/alien/queen = 1,
		/mob/living/simple_animal/hostile/alien/sentinel = 10,
	)

	flora_spawn_chance = 1
	flora_spawn_list = list(
		/obj/item/clothing/mask/facehugger = 1,
		/obj/effect/alien/weeds/node = 3,
		/obj/effect/alien/egg = 5,
		/obj/effect/alien/resin = 1,
		/obj/effect/alien/resin/membrane = 1,
		/obj/effect/alien/resin/wall = 1,
	)
	loot_spawners = list(
		/obj/abstract/loot_spawner/combat = 1,
		/obj/abstract/loot_spawner/exotic = 2
	)

/datum/biome/cave/xeno/living
	open_turf_types = list(/turf/unsimulated/floor/asteroid/hive/living = 1)
	closed_turf_types = list(
		/turf/unsimulated/mineral/random/xeno = 3,
		/turf/unsimulated/mineral/random/high_chance/xeno = 1,
	)

	mob_spawn_chance = 3
	mob_spawn_list = list()

	flora_spawn_chance = 0.4
	flora_spawn_list = list(
		/obj/structure/acid_puddle = 5
	)
	loot_spawners = list(
		/obj/abstract/loot_spawner/combat = 1,
		/obj/abstract/loot_spawner/exotic = 2
	)
