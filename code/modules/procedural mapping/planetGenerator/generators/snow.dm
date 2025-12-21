/datum/planetGenerator/snow
	mountain_height = 0.45
	perlin_zoom = 55

	initial_closed_chance = 45
	smoothing_iterations = 20
	birth_limit = 4
	death_limit = 3

	primary_area_type = /area/planet/snow

/datum/planetGenerator/snow
	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/arctic/rocky,
			BIOME_LOW_HUMIDITY = /datum/biome/snow,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/iceberg,
			BIOME_HIGH_HUMIDITY = /datum/biome/iceberg,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/iceberg/lake
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/arctic,
			BIOME_LOW_HUMIDITY = /datum/biome/arctic/rocky,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/snow/lush,
			BIOME_HIGH_HUMIDITY = /datum/biome/snow,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/iceberg/lake
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/snow/thawed,
			BIOME_LOW_HUMIDITY = /datum/biome/snow/forest,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/snow,
			BIOME_HIGH_HUMIDITY = /datum/biome/snow/lush,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/iceberg
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/snow/lush,
			BIOME_LOW_HUMIDITY = /datum/biome/snow/forest/dense,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/snow/forest/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/snow/forest,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/snow/lush
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/snow,
			BIOME_LOW_HUMIDITY = /datum/biome/snow/forest,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/snow/thawed,
			BIOME_HIGH_HUMIDITY = /datum/biome/snow/lush,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/snow
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/snow/forest/dense,
			BIOME_LOW_HUMIDITY = /datum/biome/snow/forest,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/snow/thawed,
			BIOME_HIGH_HUMIDITY = /datum/biome/snow/forest/dense,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/snow/thawed
		)
	)

	cave_biome_table = list(
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/snow,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/snow,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/snow,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/snow,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/snow/ice
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/snow,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/snow,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/snow,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/snow/ice,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/snow/ice
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/snow,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/snow,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/snow/thawed,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/snow/thawed,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/snow
		),
		BIOME_HOT_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/snow/thawed,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/snow/thawed,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/snow,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/snow,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/volcanic/lava
		)
	)

/datum/biome/snow
	biome_temperature = T0C
	open_turf_types = list(
		/turf/unsimulated/floor/snow/spread = 10
	)
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 2,
		/obj/structure/flora/rock/pile/snow = 1,
		/obj/structure/flora/grass/brown = 3,
		/obj/structure/flora/grass/green = 3,
		/obj/structure/flora/grass/both = 3,
		/obj/structure/flora/grass/white = 3
	)
	flora_spawn_chance = 10
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/wolf = 20,
		/mob/living/simple_animal/hostile/wolf/alpha = 5,
		/mob/living/simple_animal/hostile/wolf/pliable = 3,
		/mob/living/simple_animal/hostile/deer = 15,
		/mob/living/simple_animal/hostile/bear/polarbear = 12,
		/mob/living/simple_animal/hostile/retaliate/snowman = 3,
		/mob/living/simple_animal/penguin = 10,
		/mob/living/simple_animal/penguin/chick = 5,
		/mob/living/simple_animal/hostile/wendigo/human = 8,
		/mob/living/simple_animal/hostile/wendigo = 3,
		/mob/living/simple_animal/hostile/wendigo/alpha = 1,
		/mob/living/simple_animal/mouse/common = 15,
		/mob/living/simple_animal/capybara = 2
	)
	loot_spawners = list(
		/obj/abstract/loot_spawner/bureaucracy = 1,
		/obj/abstract/loot_spawner/clothing = 1,
		/obj/abstract/loot_spawner/decoration = 1,
		/obj/abstract/loot_spawner/entertainment = 1,
		/obj/abstract/loot_spawner/food_or_drink = 2,
		/obj/abstract/loot_spawner/trash = 3,
	)

/datum/biome/snow/lush
	open_turf_types = list(
		/turf/unsimulated/floor/snow/spread = 1
	)
	flora_spawn_list = list(
		/obj/structure/flora/grass/both = 1
	)
	flora_spawn_chance = 30

/datum/biome/snow/thawed
	open_turf_types = list(
		/turf/unsimulated/floor/snow/dirt = 1
	)
	flora_spawn_chance = 40
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/flora/ausbushes/sparsegrass = 1,
		/obj/structure/flora/ausbushes = 1,
		/obj/structure/flora/ausbushes/ppflowers = 1,
		/obj/structure/flora/ausbushes/lavendergrass = 1,
	)

/datum/biome/snow/forest
	flora_spawn_chance = 15
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 10,
		/obj/structure/flora/tree/dead = 3,
		/obj/structure/flora/grass/both = 4,
	)

/datum/biome/snow/forest/dense
	flora_spawn_chance = 25
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 20,
		/obj/structure/flora/grass/both = 6,
		/obj/structure/flora/tree/dead = 3,
	)

/datum/biome/arctic
	open_turf_types = list(
		/turf/unsimulated/floor/snow/spread = 4
	)
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/wolf = 25,
		/mob/living/simple_animal/hostile/wolf/alpha = 8,
		/mob/living/simple_animal/hostile/deer = 15,
		/mob/living/simple_animal/hostile/bear/polarbear = 18,
		/mob/living/simple_animal/hostile/retaliate/snowman = 3,
		/mob/living/simple_animal/penguin = 8,
		/mob/living/simple_animal/hostile/wendigo/human = 10,
		/mob/living/simple_animal/hostile/wendigo = 5,
		/mob/living/simple_animal/hostile/wendigo/skifree = 4,
		/mob/living/simple_animal/mouse/common = 10
	)
	mob_spawn_chance = 2

/datum/biome/arctic/rocky
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/rock = 2,
		/obj/structure/flora/rock/pile = 2,
	)

/datum/biome/iceberg
	open_turf_types = list(
		/turf/unsimulated/floor/noblizz_permafrost/icecore = 1
	)
	mob_spawn_chance = 3
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/wolf = 25,
		/mob/living/simple_animal/hostile/wolf/alpha = 10,
		/mob/living/simple_animal/hostile/bear/polarbear = 25,
		/mob/living/simple_animal/hostile/retaliate/snowman = 3,
		/mob/living/simple_animal/penguin = 15,
		/mob/living/simple_animal/hostile/wendigo = 8,
		/mob/living/simple_animal/hostile/wendigo/evolved = 3,
		/mob/living/simple_animal/hostile/wendigo/skifree = 5
	)


/datum/biome/iceberg/lake
	open_turf_types = list(
//		/turf/unsimulated/floor/snow/glacier = 1, //this causes an infinite loop and crashes the MC
		/turf/unsimulated/floor/snow/spread = 1,
	)

/datum/biome/cave/snow
	biome_temperature = T0C
	open_turf_types = list(
		/turf/unsimulated/floor/snow/cave/spread = 1
	)
	flora_spawn_chance = 6
	flora_spawn_list = list(
		/obj/structure/flora/grass/both = 5,
		/obj/structure/flora/rock/pile/snow = 1,
	)
	closed_turf_types = list(
		/turf/unsimulated/mineral/random/snow = 10,
		/turf/unsimulated/mineral/random/high_chance/snow = 1,
	)
	mob_spawn_chance = 3
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/wolf = 25,
		/mob/living/simple_animal/hostile/wolf/alpha = 8,
		/mob/living/simple_animal/hostile/bear/polarbear = 15,
		/mob/living/simple_animal/hostile/decoy/snowman/frostgolem/knight = 5,
		/mob/living/simple_animal/hostile/decoy/snowman/frostgolem/wizard = 5,
		/mob/living/simple_animal/hostile/scarybat/cave = 20,
		/mob/living/simple_animal/hostile/wendigo = 8,
		/mob/living/simple_animal/hostile/wendigo/evolved = 2,
		/mob/living/simple_animal/cockroach = 15,
		/mob/living/simple_animal/mouse/common = 15,
		/mob/living/simple_animal/hostile/mushroom = 12,
		/mob/living/simple_animal/hostile/tree = 8
	)

/datum/biome/cave/snow/thawed
	open_turf_types = list(
		/turf/unsimulated/floor/snow/cave/rock = 1
	)
	closed_turf_types = list(
		/turf/unsimulated/mineral/random/snow = 10,
		/turf/unsimulated/mineral/random/high_chance/snow = 1,
	)

/datum/biome/cave/snow/ice
	open_turf_types = list(
		/turf/unsimulated/floor/snow/cave/spread = 1
	)
	closed_turf_types = list(
		/turf/unsimulated/wall/rock/ice = 1
	)

/datum/biome/cave/volcanic
	open_turf_types = list(
		/turf/unsimulated/floor/planetary/basalt = 1
	)
	closed_turf_types = list(
		/turf/unsimulated/mineral/random/snow = 5,
		/turf/unsimulated/mineral/random/high_chance/snow = 1,
		)
	mob_spawn_chance = 3
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/wolf = 20,
		/mob/living/simple_animal/hostile/wolf/alpha = 6,
		/mob/living/simple_animal/hostile/bear/polarbear = 12,
		/mob/living/simple_animal/hostile/decoy/snowman/frostgolem/knight = 5,
		/mob/living/simple_animal/hostile/decoy/snowman/frostgolem/wizard = 5,
		/mob/living/simple_animal/hostile/scarybat/cave = 18,
		/mob/living/simple_animal/hostile/wendigo = 10,
		/mob/living/simple_animal/hostile/wendigo/evolved = 3,
		/mob/living/simple_animal/hostile/asteroid/magmaw = 15,
		/mob/living/simple_animal/hostile/asteroid/goliath = 10,
		/mob/living/simple_animal/cockroach = 12,
		/mob/living/simple_animal/mouse/common = 12,
		/mob/living/simple_animal/hostile/mushroom = 10
	)
	flora_spawn_chance = 3
	flora_spawn_list = list(
		/obj/structure/flora/rock = 1,
		/obj/structure/flora/rock/pile = 1,
	)
	feature_spawn_chance = 0.2

/datum/biome/cave/volcanic/lava
	open_turf_types = list(
		/turf/unsimulated/floor/planetary/lava = 1
	)
