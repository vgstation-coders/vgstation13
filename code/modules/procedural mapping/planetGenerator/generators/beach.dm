/datum/planetGenerator/beach
	mountain_height = 0.95
	perlin_zoom = 75

	primary_area_type = /area/planet/beach

	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/ocean/deep,
			BIOME_LOW_HUMIDITY = /datum/biome/ocean,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/beach/grass
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/ocean/deep,
			BIOME_LOW_HUMIDITY = /datum/biome/ocean,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/beach/grass/dense,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/jungle/beach
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/ocean/deep,
			BIOME_LOW_HUMIDITY = /datum/biome/ocean,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/beach/grass/dense,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/beach/grass
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/ocean/deep,
			BIOME_LOW_HUMIDITY = /datum/biome/ocean,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/beach/grass
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/ocean/deep,
			BIOME_LOW_HUMIDITY = /datum/biome/ocean,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/beach/grass,
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/ocean/deep,
			BIOME_LOW_HUMIDITY = /datum/biome/ocean,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/beach/grass
		)
	)

	cave_biome_table = list(
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/beach/cove,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/beach,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/beach
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/beach,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/beach,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/beach/cove
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/beach,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/beach,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/beach
		),
		BIOME_HOT_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/beach,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/beach,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/beach/cove,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/beach
		)
	)

/datum/biome/beach
	open_turf_types = list(/turf/unsimulated/beach/sand = 1)
	mob_spawn_list = list(/mob/living/simple_animal/crab = 7, /mob/living/simple_animal/capybara = 1, /mob/living/simple_animal/snail = 1)
	mob_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/flora/tree/palm = 1,
		/obj/structure/flora/rock = 1,
		/obj/structure/flora/rock/pile = 1,
		/obj/structure/flora/coconut = 1
	)
	flora_spawn_chance = 5
	loot_spawners = list(
		/obj/abstract/loot_spawner/bedsheet = 1,
		/obj/abstract/loot_spawner/bureaucracy = 1,
		/obj/abstract/loot_spawner/clothing = 1,
		/obj/abstract/loot_spawner/decoration = 1,
		/obj/abstract/loot_spawner/entertainment = 1,
		/obj/abstract/loot_spawner/food_or_drink = 2,
		/obj/abstract/loot_spawner/trash = 3,
	)

/datum/biome/beach/dense
	open_turf_types = list(/turf/unsimulated/beach/sand = 1)
	flora_spawn_list = list(
		/obj/structure/flora/tree/palm = 5,
		/obj/structure/flora/rock = 1,
		/obj/structure/flora/rock/pile = 1,
		/obj/structure/flora/coconut = 3
	)
	flora_spawn_chance = 2

/datum/biome/beach/grass
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/brflowers = 1,
		/obj/structure/flora/ausbushes/fernybush = 1,
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/flora/ausbushes/genericbush = 1,
		/obj/structure/flora/ausbushes/grassybush = 1,
		/obj/structure/flora/ausbushes/lavendergrass = 1,
		/obj/structure/flora/ausbushes/leafybush = 1,
		/obj/structure/flora/ausbushes/palebush = 1,
		/obj/structure/flora/ausbushes/pointybush = 1,
		/obj/structure/flora/ausbushes/ppflowers = 1,
		/obj/structure/flora/ausbushes/reedbush = 1,
		/obj/structure/flora/ausbushes/sparsegrass = 1,
		/obj/structure/flora/ausbushes/stalkybush = 1,
		/obj/structure/flora/ausbushes/stalkybush = 1,
		/obj/structure/flora/ausbushes/sunnybush = 1,
		/obj/structure/flora/ausbushes/ywflowers = 1,
		/obj/structure/flora/tree/palm = 1,
	)
	flora_spawn_chance = 25
	mob_spawn_list = list(
		/mob/living/simple_animal/mouse = 1,
		/mob/living/simple_animal/cow = 1,
		/mob/living/simple_animal/hostile/deer = 1,
		/mob/living/simple_animal/rabbit = 1
	)
	mob_spawn_chance = 1

/datum/biome/beach/grass/dense
	flora_spawn_chance = 70
	mob_spawn_list = list(
		/mob/living/simple_animal/mouse = 10,
		/mob/living/simple_animal/rabbit = 10,
		/mob/living/simple_animal/hostile/spacehog/piglet = 1
	)
	mob_spawn_chance = 2
	feature_spawn_chance = 1.2

/datum/biome/ocean
	open_turf_types = list(/turf/unsimulated/beach/shallows = 1)
	flora_spawn_list = list(
		/obj/structure/flora/rock = 1,
		/obj/structure/flora/rock/pile = 1,
	)
	flora_spawn_chance = 1

/datum/biome/ocean/deep
	open_turf_types = list(/turf/unsimulated/beach/water = 1)

/datum/biome/cave/beach
	open_turf_types = list(/turf/unsimulated/floor/planetary/cave = 1)
	closed_turf_types = list(/turf/unsimulated/mineral/random/cave = 1)
	flora_spawn_chance = 4
	flora_spawn_list = list(/obj/structure/flora/rock/pile = 1, /obj/structure/flora/rock = 6)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/bear/brownbear = 5,
		/mob/living/simple_animal/hostile/crab = 1,
	)

/datum/biome/cave/beach/cove
	open_turf_types = list(/turf/unsimulated/beach/sand = 1)
	flora_spawn_list = list(/obj/structure/geyser = 1, /obj/structure/flora/rock/pile = 3, /obj/structure/flora/rock = 2, /obj/structure/flora/coconut = 5)
	flora_spawn_chance = 6

