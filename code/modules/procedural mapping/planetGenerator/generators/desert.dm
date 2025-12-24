/datum/planetGenerator/desert
	mountain_height = 0.8
	perlin_zoom = 65

	primary_area_type = /area/planet/desert

	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/desert,
			BIOME_LOW_HUMIDITY = /datum/biome/desert,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/desert,
			BIOME_HIGH_HUMIDITY = /datum/biome/desert,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/desert
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/desert,
			BIOME_LOW_HUMIDITY = /datum/biome/desert,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/desert,
			BIOME_HIGH_HUMIDITY = /datum/biome/desert,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/desert
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/desert,
			BIOME_LOW_HUMIDITY = /datum/biome/desert,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/desert,
			BIOME_HIGH_HUMIDITY = /datum/biome/desert,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/desert
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/desert,
			BIOME_LOW_HUMIDITY = /datum/biome/desert,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/desert,
			BIOME_HIGH_HUMIDITY = /datum/biome/desert,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/desert
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/dry_seafloor,
			BIOME_LOW_HUMIDITY = /datum/biome/dry_seafloor,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/desert,
			BIOME_HIGH_HUMIDITY = /datum/biome/desert,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/desert,
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/dry_seafloor,
			BIOME_LOW_HUMIDITY = /datum/biome/dry_seafloor,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/dry_seafloor,
			BIOME_HIGH_HUMIDITY = /datum/biome/dry_seafloor,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/desert
		)
	)
	cave_biome_table = list(
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/desert,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/desert,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/desert,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/desert,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/desert
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/desert,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/desert,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/desert,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/desert,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/desert
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/desert,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/desert,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/desert,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/desert,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/desert
		),
		BIOME_HOT_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/desert,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/desert,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/desert,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/desert,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/desert
		)
	)

/datum/biome/desert
	biome_temperature = T20C + 10
	open_turf_types = list(/turf/unsimulated/floor/planetary/desert = 1)

	flora_spawn_list = list(
		/obj/structure/flora/rock = 10,
		/obj/structure/flora/rock/pile = 10,
		/obj/structure/flora/desert/barrelcactus = 20,
		/obj/structure/flora/desert/saguaro = 20,
		/obj/structure/flora/desert/tumbleweed = 5,
	)
	flora_spawn_chance = 4
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 20,
		/mob/living/simple_animal/hostile/lizard = 35,
		/mob/living/simple_animal/mouse/common = 25,
		/mob/living/simple_animal/cricket = 20,
		/mob/living/simple_animal/hostile/asteroid/goliath = 10,
		/mob/living/simple_animal/hostile/lizard/frog = 10,
		/mob/living/simple_animal/hostile/warriorbug = 1,
	)
	loot_spawners = list(
		/obj/abstract/loot_spawner/engineering = 1,
		/obj/abstract/loot_spawner/medical = 1,
		/obj/abstract/loot_spawner/trash = 2,
	)

/datum/biome/dry_seafloor
	biome_temperature = T20C + 10
	open_turf_types = list(/turf/unsimulated/floor/planetary/dry_basin = 1)

	flora_spawn_list = list(
		/obj/structure/flora/rock = 10,
		/obj/structure/flora/rock/pile = 10,
		/obj/structure/flora/ausbushes/stalkybush = 5,
	)
	flora_spawn_chance = 1
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 20,
		/mob/living/simple_animal/hostile/lizard = 35,
		/mob/living/simple_animal/hostile/asteroid/goliath = 10,
		/mob/living/simple_animal/hostile/lizard/frog = 10,
		/mob/living/simple_animal/hostile/warriorbug = 1,
	)
	loot_spawn_chance = 1
	loot_spawners = list(/obj/abstract/loot_spawner/trash/on_ground) //it's bleak

/datum/biome/cave/desert
	biome_temperature = T20C + 10
	open_turf_types = list(/turf/unsimulated/floor/planetary/desert = 1)
	closed_turf_types = list(/turf/unsimulated/mineral/random/cave = 1)
	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/flora/rock = 5,
		/obj/structure/flora/rock/pile = 1,
		/obj/effect/glowshroom = 5
		)
	mob_spawn_chance = 3
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 25,
		/mob/living/simple_animal/hostile/asteroid/goliath = 25,
		/mob/living/simple_animal/hostile/monster/skrite = 1,
		/mob/living/simple_animal/hostile/scarybat/cave = 20,
		/mob/living/simple_animal/hostile/asteroid/hivelord = 8,
		/mob/living/simple_animal/hostile/mushroom = 10,
		/mob/living/simple_animal/mouse/common = 15,
		/mob/living/simple_animal/hostile/warriorbug = 1
	)
