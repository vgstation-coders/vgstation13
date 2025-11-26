/datum/planetGenerator/jungle
	mountain_height = 0.75
	perlin_zoom = 55

	primary_area_type = /area/planet/jungle

	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle/sparse,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle/sparse,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle/temperate,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle/temperate,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/jungle/dense
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle/sparse,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle/temperate,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle/temperate,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle/dense,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/jungle/dense
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle/temperate,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle/dense,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle/lush,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/jungle/lush
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle/dense,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle/lush,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle/lush,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle/tropical,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/jungle/tropical
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle/lush,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle/tropical,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle/tropical,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle/rainforest,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/jungle/rainforest
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle/tropical,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle/rainforest,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle/rainforest,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle/swamp,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/jungle/swamp
		)
	)

	cave_biome_table = list(
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/jungle/dirt
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/jungle/lush
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/jungle/lush,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/jungle/lush,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/jungle/wet
		),
		BIOME_HOT_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/jungle/lush,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/jungle/wet,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/jungle/wet,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/jungle/underground_river
		)
	)

// Surface biomes
/datum/biome/jungle
	biome_temperature = T20C + 10
	loot_spawners = list(
		/obj/abstract/loot_spawner/bedsheet = 1,
		/obj/abstract/loot_spawner/bureaucracy = 1,
		/obj/abstract/loot_spawner/clothing = 1,
		/obj/abstract/loot_spawner/decoration = 1,
		/obj/abstract/loot_spawner/entertainment = 1,
		/obj/abstract/loot_spawner/food_or_drink = 2,
		/obj/abstract/loot_spawner/trash = 3,
	)

/datum/biome/jungle/sparse
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/sparsegrass = 20,
		/obj/structure/flora/ausbushes/grassybush = 15,
		/obj/structure/flora/ausbushes/genericbush = 10,
		/obj/structure/flora/ausbushes/leafybush = 8,
		/obj/structure/flora/tree/shitty = 3,
		/obj/structure/flora/rock = 5,
		/obj/structure/flora/rock/pile = 3,
		/obj/structure/flora/jungle_berries = 2,
	)
	flora_spawn_chance = 25
	mob_spawn_chance = 3
	mob_spawn_list = list(
		/mob/living/simple_animal/parrot = 20,
		/mob/living/simple_animal/capybara = 12,
		/mob/living/carbon/monkey = 25,
		/mob/living/simple_animal/hostile/lizard/frog = 25,
		/mob/living/simple_animal/hostile/frog = 15,
		/mob/living/simple_animal/cockroach = 20,
		/mob/living/simple_animal/cricket = 15,
		/mob/living/simple_animal/mouse/common = 15,
		/mob/living/simple_animal/snail = 12
	)

/datum/biome/jungle/temperate
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 20,
		/obj/structure/flora/ausbushes/grassybush = 15,
		/obj/structure/flora/ausbushes/leafybush = 15,
		/obj/structure/flora/ausbushes/fernybush = 12,
		/obj/structure/flora/ausbushes/genericbush = 10,
		/obj/structure/flora/tree/shitty = 5,
		/obj/structure/flora/tree/palm = 2,
		/obj/structure/flora/rock = 3,
		/obj/structure/flora/jungle_berries = 5,
	)
	flora_spawn_chance = 35
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/simple_animal/parrot = 25,
		/mob/living/simple_animal/capybara = 18,
		/mob/living/carbon/monkey = 30,
		/mob/living/simple_animal/hostile/lizard/frog = 20,
		/mob/living/simple_animal/hostile/frog = 18,
		/mob/living/simple_animal/cockroach = 18,
		/mob/living/simple_animal/cricket = 18,
		/mob/living/simple_animal/mouse/common = 15,
		/mob/living/simple_animal/snail = 15,
		/mob/living/simple_animal/hostile/bear/panda = 2
	)

/datum/biome/jungle/dense
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 25,
		/obj/structure/flora/ausbushes/leafybush = 20,
		/obj/structure/flora/ausbushes/fernybush = 18,
		/obj/structure/flora/ausbushes/pointybush = 15,
		/obj/structure/flora/ausbushes/stalkybush = 12,
		/obj/structure/flora/tree/shitty = 8,
		/obj/structure/flora/tree/palm = 4,
		/obj/structure/flora/tree/dead_acacia = 2,
		/obj/structure/flora/jungle_berries = 8,
	)
	flora_spawn_chance = 50
	mob_spawn_chance = 5
	mob_spawn_list = list(
		/mob/living/simple_animal/parrot = 30,
		/mob/living/simple_animal/capybara = 20,
		/mob/living/carbon/monkey = 35,
		/mob/living/simple_animal/hostile/lizard/frog = 12,
		/mob/living/simple_animal/hostile/frog = 15,
		/mob/living/simple_animal/hostile/frog/centurion = 8,
		/mob/living/simple_animal/hostile/lizard/frog/poison = 10,
		/mob/living/simple_animal/cockroach = 20,
		/mob/living/complex_animal/panther = 8,
		/mob/living/simple_animal/cricket = 20,
		/mob/living/simple_animal/mouse/common = 12,
		/mob/living/simple_animal/snail = 15,
		/mob/living/simple_animal/hostile/bear/panda = 3
	)

/datum/biome/jungle/lush
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 30,
		/obj/structure/flora/ausbushes/leafybush = 25,
		/obj/structure/flora/ausbushes/fernybush = 20,
		/obj/structure/flora/ausbushes/pointybush = 18,
		/obj/structure/flora/ausbushes/stalkybush = 15,
		/obj/structure/flora/ausbushes/brflowers = 8,
		/obj/structure/flora/ausbushes/ppflowers = 8,
		/obj/structure/flora/ausbushes/ywflowers = 6,
		/obj/structure/flora/tree/palm = 8,
		/obj/structure/flora/tree/shitty = 6,
		/obj/structure/flora/tree/dead_acacia = 3,
		/obj/structure/flora/jungle_berries = 12,
	)
	flora_spawn_chance = 65
	mob_spawn_chance = 6
	mob_spawn_list = list(
		/mob/living/simple_animal/parrot = 35,
		/mob/living/simple_animal/capybara = 25,
		/mob/living/carbon/monkey = 40,
		/mob/living/simple_animal/hostile/lizard/frog = 10,
		/mob/living/simple_animal/hostile/frog = 12,
		/mob/living/simple_animal/hostile/frog/centurion = 10,
		/mob/living/simple_animal/hostile/frog/javelineer = 5,
		/mob/living/simple_animal/hostile/lizard/frog/poison = 15,
		/mob/living/simple_animal/cockroach = 25,
		/mob/living/complex_animal/panther = 10,
		/mob/living/simple_animal/hostile/giant_spider = 8,
		/mob/living/simple_animal/cricket = 20,
		/mob/living/simple_animal/mouse/common = 10,
		/mob/living/simple_animal/snail = 18,
		/mob/living/simple_animal/hostile/bear/panda = 4
	)

/datum/biome/jungle/tropical
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 35,
		/obj/structure/flora/ausbushes/leafybush = 30,
		/obj/structure/flora/ausbushes/fernybush = 25,
		/obj/structure/flora/ausbushes/pointybush = 20,
		/obj/structure/flora/ausbushes/stalkybush = 18,
		/obj/structure/flora/ausbushes/brflowers = 10,
		/obj/structure/flora/ausbushes/ppflowers = 10,
		/obj/structure/flora/ausbushes/ywflowers = 8,
		/obj/structure/flora/ausbushes/sunnybush = 6,
		/obj/structure/flora/tree/palm = 12,
		/obj/structure/flora/tree/shitty = 8,
		/obj/structure/flora/tree/dead_acacia = 4,
		/obj/structure/flora/jungle_berries = 15,
	)
	flora_spawn_chance = 75
	mob_spawn_chance = 7
	mob_spawn_list = list(
		/mob/living/simple_animal/parrot = 40,
		/mob/living/simple_animal/capybara = 20,
		/mob/living/carbon/monkey = 45,
		/mob/living/simple_animal/hostile/lizard/frog = 8,
		/mob/living/simple_animal/hostile/frog = 10,
		/mob/living/simple_animal/hostile/frog/centurion = 12,
		/mob/living/simple_animal/hostile/frog/javelineer = 8,
		/mob/living/simple_animal/hostile/lizard/frog/poison = 18,
		/mob/living/simple_animal/cockroach = 30,
		/mob/living/complex_animal/panther = 15,
		/mob/living/simple_animal/hostile/giant_spider = 10,
		/mob/living/complex_animal/dinosaur = 5,
		/mob/living/simple_animal/cricket = 20,
		/mob/living/simple_animal/mouse/common = 10,
		/mob/living/simple_animal/snail = 20,
		/mob/living/simple_animal/hostile/bear/panda = 5
	)

/datum/biome/jungle/rainforest
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 40,
		/obj/structure/flora/ausbushes/leafybush = 35,
		/obj/structure/flora/ausbushes/fernybush = 30,
		/obj/structure/flora/ausbushes/pointybush = 25,
		/obj/structure/flora/ausbushes/stalkybush = 22,
		/obj/structure/flora/ausbushes/brflowers = 12,
		/obj/structure/flora/ausbushes/ppflowers = 12,
		/obj/structure/flora/ausbushes/ywflowers = 10,
		/obj/structure/flora/ausbushes/sunnybush = 8,
		/obj/structure/flora/ausbushes/lavendergrass = 6,
		/obj/structure/flora/tree/palm = 15,
		/obj/structure/flora/tree/shitty = 10,
		/obj/structure/flora/tree/dead_acacia = 5,
		/obj/structure/flora/jungle_berries = 18,
	)
	flora_spawn_chance = 85
	mob_spawn_chance = 8
	mob_spawn_list = list(
		/mob/living/simple_animal/parrot = 45,
		/mob/living/simple_animal/capybara = 18,
		/mob/living/carbon/monkey = 50,
		/mob/living/simple_animal/hostile/lizard/frog = 5,
		/mob/living/simple_animal/hostile/frog = 10,
		/mob/living/simple_animal/hostile/frog/centurion = 15,
		/mob/living/simple_animal/hostile/frog/javelineer = 10,
		/mob/living/simple_animal/hostile/lizard/frog/poison = 20,
		/mob/living/simple_animal/cockroach = 35,
		/mob/living/complex_animal/panther = 18,
		/mob/living/simple_animal/hostile/giant_spider = 15,
		/mob/living/complex_animal/dinosaur = 8,
		/mob/living/simple_animal/hostile/bear/brownbear = 8,
		/mob/living/simple_animal/cricket = 25,
		/mob/living/simple_animal/snail = 22,
		/mob/living/simple_animal/hostile/mushroom = 10,
		/mob/living/simple_animal/hostile/bear/panda = 6
	)

/datum/biome/jungle/swamp
	open_turf_types = list(
		/turf/unsimulated/floor/planetary/grass = 7,
		/turf/unsimulated/floor/jungle/mud = 2,
		/turf/unsimulated/floor/jungle/water = 1
	)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 25,
		/obj/structure/flora/ausbushes/leafybush = 20,
		/obj/structure/flora/ausbushes/fernybush = 18,
		/obj/structure/flora/ausbushes/stalkybush = 20,
		/obj/structure/flora/ausbushes/reedbush = 15,
		/obj/structure/flora/ausbushes/sparsegrass = 10,
		/obj/structure/flora/tree/palm = 8,
		/obj/structure/flora/tree/dead_acacia = 6,
		/obj/structure/flora/tree/dead/tall = 4,
		/obj/structure/flora/jungle_berries = 10,
		/obj/structure/flora/rock = 3,
	)
	flora_spawn_chance = 60
	mob_spawn_chance = 9
	mob_spawn_list = list(
		/mob/living/simple_animal/parrot = 25,
		/mob/living/simple_animal/capybara = 30,
		/mob/living/carbon/monkey = 30,
		/mob/living/simple_animal/hostile/lizard/frog = 8,
		/mob/living/simple_animal/hostile/frog = 12,
		/mob/living/simple_animal/hostile/frog/centurion = 15,
		/mob/living/simple_animal/hostile/frog/javelineer = 12,
		/mob/living/simple_animal/hostile/lizard/frog/poison = 25,
		/mob/living/simple_animal/cockroach = 40,
		/mob/living/complex_animal/panther = 15,
		/mob/living/simple_animal/hostile/giant_spider = 18,
		/mob/living/complex_animal/dinosaur = 10,
		/mob/living/simple_animal/hostile/bear/brownbear = 10,
		/mob/living/simple_animal/cricket = 25,
		/mob/living/simple_animal/snail = 25,
		/mob/living/simple_animal/snail/greasy = 10,
		/mob/living/simple_animal/crab = 15,
		/mob/living/simple_animal/hostile/mushroom = 12
	)

// Cave biomes
/datum/biome/cave/jungle
	biome_temperature = T20C + 10
	open_turf_types = list(/turf/unsimulated/floor/jungle/wasteland = 1)
	closed_turf_types = list(
		/turf/unsimulated/mineral/random/cave = 5,
		/turf/unsimulated/mineral/random/high_chance/cave = 1,
		)
	flora_spawn_chance = 8
	flora_spawn_list = list(
		/obj/structure/flora/rock = 10,
		/obj/structure/flora/rock/pile = 5,
		/obj/structure/flora/ausbushes/sparsegrass = 5,
		/obj/structure/flora/ausbushes/grassybush = 3,
		/obj/effect/glowshroom = 5
	)
	mob_spawn_chance = 5
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 30,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 20,
		/mob/living/simple_animal/hostile/asteroid/goliath = 15,
		/mob/living/simple_animal/hostile/giant_spider = 20,
		/mob/living/simple_animal/hostile/bear/brownbear = 10,
		/mob/living/simple_animal/hostile/scarybat/cave = 25,
		/mob/living/simple_animal/hostile/mushroom = 18,
		/mob/living/simple_animal/mouse/common = 15
	)

/datum/biome/cave/jungle/dirt
	open_turf_types = list(/turf/unsimulated/floor/planetary/dirt = 1)
	flora_spawn_chance = 15
	flora_spawn_list = list(
		/obj/structure/flora/rock = 8,
		/obj/structure/flora/rock/pile = 4,
		/obj/structure/flora/ausbushes/sparsegrass = 8,
		/obj/structure/flora/ausbushes/grassybush = 6,
		/obj/structure/flora/ausbushes/leafybush = 4,
		/obj/effect/glowshroom = 5
	)
	mob_spawn_chance = 6
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 25,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 18,
		/mob/living/simple_animal/hostile/asteroid/goliath = 15,
		/mob/living/simple_animal/hostile/giant_spider = 20,
		/mob/living/simple_animal/hostile/bear/brownbear = 10,
		/mob/living/simple_animal/hostile/scarybat/cave = 22,
		/mob/living/simple_animal/hostile/mushroom = 20,
		/mob/living/simple_animal/snail = 15
	)

/datum/biome/cave/jungle/lush
	open_turf_types = list(/turf/unsimulated/floor/planetary/dirt = 1)
	flora_spawn_chance = 25
	flora_spawn_list = list(
		/obj/structure/flora/rock = 6,
		/obj/structure/flora/rock/pile = 3,
		/obj/structure/flora/ausbushes/sparsegrass = 10,
		/obj/structure/flora/ausbushes/grassybush = 8,
		/obj/structure/flora/ausbushes/leafybush = 8,
		/obj/structure/flora/ausbushes/fernybush = 6,
		/obj/structure/flora/jungle_berries = 3,
		/obj/effect/glowshroom = 5
	)
	mob_spawn_chance = 7
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 20,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 15,
		/mob/living/simple_animal/hostile/asteroid/goliath = 12,
		/mob/living/simple_animal/hostile/giant_spider = 25,
		/mob/living/simple_animal/hostile/bear/brownbear = 12,
		/mob/living/simple_animal/parrot = 10,
		/mob/living/simple_animal/hostile/scarybat/cave = 20,
		/mob/living/simple_animal/hostile/mushroom = 25,
		/mob/living/simple_animal/snail = 18
	)

/datum/biome/cave/jungle/wet
	open_turf_types = list(
		/turf/unsimulated/floor/jungle/mud = 8,
		/turf/unsimulated/floor/jungle/water = 2
	)
	flora_spawn_chance = 35
	flora_spawn_list = list(
		/obj/structure/flora/rock = 4,
		/obj/structure/flora/rock/pile = 2,
		/obj/structure/flora/ausbushes/sparsegrass = 8,
		/obj/structure/flora/ausbushes/grassybush = 6,
		/obj/structure/flora/ausbushes/leafybush = 10,
		/obj/structure/flora/ausbushes/fernybush = 8,
		/obj/structure/flora/ausbushes/reedbush = 6,
		/obj/structure/flora/jungle_berries = 5,
		/obj/effect/glowshroom = 5
	)
	mob_spawn_chance = 8
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 18,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 12,
		/mob/living/simple_animal/hostile/asteroid/goliath = 10,
		/mob/living/simple_animal/hostile/giant_spider = 30,
		/mob/living/simple_animal/hostile/bear/brownbear = 15,
		/mob/living/simple_animal/parrot = 12,
		/mob/living/simple_animal/hostile/lizard/frog/poison = 18,
		/mob/living/simple_animal/hostile/frog = 8,
		/mob/living/simple_animal/hostile/scarybat/cave = 20,
		/mob/living/simple_animal/hostile/mushroom = 28,
		/mob/living/simple_animal/snail = 20,
		/mob/living/simple_animal/snail/greasy = 10
	)

/datum/biome/cave/jungle/underground_river
	open_turf_types = list(
		/turf/unsimulated/floor/jungle/mud = 6,
		/turf/unsimulated/floor/jungle/water = 3,
		/turf/unsimulated/floor/jungle/water_deep = 1
	)
	flora_spawn_chance = 20
	flora_spawn_list = list(
		/obj/structure/flora/rock = 5,
		/obj/structure/flora/ausbushes/reedbush = 10,
		/obj/structure/flora/ausbushes/fernybush = 8,
		/obj/structure/flora/ausbushes/leafybush = 6,
		/obj/structure/flora/jungle_berries = 3,
		/obj/effect/glowshroom = 5
	)
	mob_spawn_chance = 7
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 15,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 10,
		/mob/living/simple_animal/hostile/giant_spider = 25,
		/mob/living/simple_animal/hostile/bear/brownbear = 12,
		/mob/living/simple_animal/parrot = 10,
		/mob/living/simple_animal/hostile/lizard/frog/poison = 20,
		/mob/living/simple_animal/hostile/frog = 10,
		/mob/living/simple_animal/capybara = 12,
		/mob/living/simple_animal/hostile/scarybat/cave = 18,
		/mob/living/simple_animal/hostile/mushroom = 25,
		/mob/living/simple_animal/snail = 22,
		/mob/living/simple_animal/crab = 10
	)

/datum/biome/jungle/beach
	flora_spawn_chance = 25
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 25,
		/obj/structure/flora/ausbushes/leafybush = 20,
		/obj/structure/flora/ausbushes/fernybush = 15,
		/obj/structure/flora/ausbushes/pointybush = 15,
		/obj/structure/flora/ausbushes/stalkybush = 12,
		/obj/structure/flora/ausbushes/brflowers = 8,
		/obj/structure/flora/ausbushes/ppflowers = 8,
		/obj/structure/flora/ausbushes/ywflowers = 6,
		/obj/structure/flora/tree/palm = 15,
		/obj/structure/flora/tree/shitty = 8,
		/obj/structure/flora/tree/dead_acacia = 4,
		/obj/structure/flora/jungle_berries = 12,
		/obj/structure/flora/rock = 5,
		/obj/structure/flora/rock/pile = 3,
		/obj/structure/flora/ausbushes/reedbush = 4,
		/obj/structure/flora/coconut = 6,
	)
	mob_spawn_chance = 7
	mob_spawn_list = list(
		/mob/living/simple_animal/parrot = 30,
		/mob/living/simple_animal/capybara = 22,
		/mob/living/carbon/monkey = 30,
		/mob/living/simple_animal/hostile/lizard/frog = 12,
		/mob/living/simple_animal/hostile/frog = 15,
		/mob/living/simple_animal/hostile/frog/centurion = 10,
		/mob/living/simple_animal/hostile/lizard/frog/poison = 12,
		/mob/living/simple_animal/cockroach = 20,
		/mob/living/complex_animal/panther = 8,
		/mob/living/simple_animal/hostile/giant_spider = 10,
		/mob/living/simple_animal/crab = 15,
		/mob/living/simple_animal/cricket = 20,
		/mob/living/simple_animal/snail = 18,
		/mob/living/simple_animal/penguin = 5
	)
