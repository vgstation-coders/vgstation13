/datum/planetGenerator/grass
	mountain_height = 0.7
	perlin_zoom = 60

	primary_area_type = /area/planet/grass

	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/grass/sparse,
			BIOME_LOW_HUMIDITY = /datum/biome/grass,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/grass,
			BIOME_HIGH_HUMIDITY = /datum/biome/grass/dense,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/grass/forest
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/grass/sparse,
			BIOME_LOW_HUMIDITY = /datum/biome/grass,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/grass/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/grass/forest,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/grass/lush
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/grass,
			BIOME_LOW_HUMIDITY = /datum/biome/grass/dense,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/grass/forest,
			BIOME_HIGH_HUMIDITY = /datum/biome/grass/lush,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/grass/meadow
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/grass/dense,
			BIOME_LOW_HUMIDITY = /datum/biome/grass/forest,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/grass/lush,
			BIOME_HIGH_HUMIDITY = /datum/biome/grass/meadow,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/grass/jungle
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/grass/forest,
			BIOME_LOW_HUMIDITY = /datum/biome/grass/lush,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/grass/meadow,
			BIOME_HIGH_HUMIDITY = /datum/biome/grass/jungle,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/grass/tropical
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/grass/lush,
			BIOME_LOW_HUMIDITY = /datum/biome/grass/meadow,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/grass/jungle,
			BIOME_HIGH_HUMIDITY = /datum/biome/grass/tropical,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/grass/tropical
		)
	)

	cave_biome_table = list(
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/grass,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/grass,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/grass,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/grass,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/grass/lush
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/grass,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/grass,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/grass,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/grass/lush,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/grass/fungi
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/grass,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/grass,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/grass/lush,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/grass/fungi,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/grass/wet
		),
		BIOME_HOT_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/grass,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/grass/lush,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/grass/fungi,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/grass/wet,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/grass/wet
		)
	)

// Surface biomes
/datum/biome/grass
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 15,
		/obj/structure/flora/ausbushes/grassybush = 10,
		/obj/structure/flora/ausbushes/sparsegrass = 8,
		/obj/structure/flora/ausbushes/genericbush = 5,
		/obj/structure/flora/rock = 3,
		/obj/structure/flora/rock/pile = 2,
	)
	flora_spawn_chance = 25
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/simple_animal/mouse/common = 50,
		/mob/living/simple_animal/rabbit/bunny = 50,
		/mob/living/simple_animal/hostile/deer = 10,
		/mob/living/simple_animal/cockroach = 10,
		/mob/living/simple_animal/cricket = 10,
		/mob/living/simple_animal/chicken = 50,
		/mob/living/simple_animal/chick = 10,
		/mob/living/simple_animal/snail = 10,
		/mob/living/simple_animal/cow = 25,
		/mob/living/simple_animal/cow/chocolate = 1,
		/mob/living/simple_animal/cat = 15,
		/mob/living/simple_animal/cat/kitten = 5,
		/mob/living/simple_animal/corgi = 15,
		/mob/living/simple_animal/corgi/puppy = 5,
		/mob/living/simple_animal/hamster = 10,
		/mob/living/simple_animal/hostile/pitbull = 5,
		/mob/living/simple_animal/hostile/retaliate/cockatrice = 5,
		/mob/living/simple_animal/hostile/retaliate/cockatrice/chick = 5,
		/mob/living/simple_animal/hostile/retaliate/goat = 25,
		/mob/living/simple_animal/hostile/wendigo = 5,
		/mob/living/simple_animal/hostile/wendigo/alpha = 1,
		/mob/living/simple_animal/hostile/wendigo/evolved = 2,
		/mob/living/simple_animal/hostile/wendigo/human = 5,
	)
	loot_spawners = list(
		/obj/abstract/loot_spawner/bedsheet = 1,
		/obj/abstract/loot_spawner/bureaucracy = 1,
		/obj/abstract/loot_spawner/clothing = 1,
		/obj/abstract/loot_spawner/decoration = 1,
		/obj/abstract/loot_spawner/entertainment = 1,
		/obj/abstract/loot_spawner/food_or_drink = 2,
		/obj/abstract/loot_spawner/trash = 3,
	)

/datum/biome/grass/dense
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 25,
		/obj/structure/flora/ausbushes/grassybush = 20,
		/obj/structure/flora/ausbushes/sparsegrass = 15,
		/obj/structure/flora/ausbushes/genericbush = 10,
		/obj/structure/flora/ausbushes/leafybush = 8,
		/obj/structure/flora/rock = 2,
	)
	flora_spawn_chance = 40
	mob_spawn_chance = 3

/datum/biome/grass/sparse
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/sparsegrass = 20,
		/obj/structure/flora/ausbushes/fullgrass = 10,
		/obj/structure/flora/ausbushes/grassybush = 5,
		/obj/structure/flora/ausbushes/genericbush = 3,
		/obj/structure/flora/rock = 5,
		/obj/structure/flora/rock/pile = 3,
	)
	flora_spawn_chance = 1
	mob_spawn_chance = 1

/datum/biome/grass/forest
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/tree/shitty = 8,
		/obj/structure/flora/tree/dead/tall/living = 4,
		/obj/structure/flora/tree/dead/tall = 2,
		/obj/structure/flora/ausbushes/fullgrass = 15,
		/obj/structure/flora/ausbushes/grassybush = 10,
		/obj/structure/flora/ausbushes/leafybush = 8,
		/obj/structure/flora/ausbushes/fernybush = 6,
		/obj/structure/flora/ausbushes/genericbush = 5,
	)
	flora_spawn_chance = 60
	mob_spawn_chance = 3
	mob_spawn_list = list(
		/mob/living/simple_animal/mouse/common = 15,
		/mob/living/simple_animal/rabbit/bunny = 25,
		/mob/living/simple_animal/hostile/deer = 20,
		/mob/living/simple_animal/hostile/deer/flesh = 1,
		/mob/living/simple_animal/hostile/bear/brownbear = 8,
		/mob/living/simple_animal/cockroach = 10,
		/mob/living/simple_animal/hostile/wolf = 5,
		/mob/living/simple_animal/hostile/mushroom = 10,
		/mob/living/simple_animal/cricket = 15,
		/mob/living/simple_animal/snail = 12,
	)

/datum/biome/grass/lush
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 25,
		/obj/structure/flora/ausbushes/grassybush = 20,
		/obj/structure/flora/ausbushes/brflowers = 8,
		/obj/structure/flora/ausbushes/ppflowers = 8,
		/obj/structure/flora/ausbushes/ywflowers = 8,
		/obj/structure/flora/ausbushes/leafybush = 10,
		/obj/structure/flora/ausbushes/fernybush = 10,
		/obj/structure/flora/ausbushes/lavendergrass = 8,
	)
	flora_spawn_chance = 50
	mob_spawn_chance = 3

/datum/biome/grass/meadow
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 30,
		/obj/structure/flora/ausbushes/brflowers = 15,
		/obj/structure/flora/ausbushes/ppflowers = 15,
		/obj/structure/flora/ausbushes/ywflowers = 15,
		/obj/structure/flora/ausbushes/lavendergrass = 20,
		/obj/structure/flora/ausbushes/sunnybush = 10,
		/obj/structure/flora/tree/shitty = 3,
		/obj/structure/flora/tree/palm = 1,
	)
	flora_spawn_chance = 5
	mob_spawn_chance = 4

/datum/biome/grass/jungle
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/tree/palm = 5,
		/obj/structure/flora/tree/shitty = 4,
		/obj/structure/flora/tree/dead_acacia = 2,
		/obj/structure/flora/ausbushes/fullgrass = 20,
		/obj/structure/flora/ausbushes/leafybush = 20,
		/obj/structure/flora/ausbushes/fernybush = 20,
		/obj/structure/flora/ausbushes/genericbush = 15,
		/obj/structure/flora/ausbushes/pointybush = 10,
		/obj/structure/flora/ausbushes/stalkybush = 10,
	)
	flora_spawn_chance = 80
	mob_spawn_chance = 5
	mob_spawn_list = list(
		/mob/living/simple_animal/mouse/common = 10,
		/mob/living/simple_animal/rabbit/bunny = 15,
		/mob/living/simple_animal/hostile/deer = 15,
		/mob/living/simple_animal/hostile/bear/brownbear = 10,
		/mob/living/simple_animal/cockroach = 20,
		/mob/living/simple_animal/bee = 15,
		/mob/living/simple_animal/hostile/lizard = 20,
		/mob/living/simple_animal/hostile/wolf = 8,
		/mob/living/simple_animal/hostile/mushroom = 12,
		/mob/living/simple_animal/cricket = 15,
		/mob/living/simple_animal/snail = 10,
		/mob/living/simple_animal/parrot = 5,
		/mob/living/simple_animal/hostile/spacehog/adult = 1,
		/mob/living/simple_animal/hostile/spacehog/adult/mama =1,
		/mob/living/simple_animal/hostile/spacehog/piglet = 1
	)

/datum/biome/grass/tropical
	open_turf_types = list(/turf/unsimulated/floor/planetary/grass = 1)
	flora_spawn_list = list(
		/obj/structure/flora/tree/palm = 15,
		/obj/structure/flora/tree/shitty = 3,
		/obj/structure/flora/ausbushes/fullgrass = 15,
		/obj/structure/flora/ausbushes/leafybush = 25,
		/obj/structure/flora/ausbushes/fernybush = 25,
		/obj/structure/flora/ausbushes/pointybush = 15,
		/obj/structure/flora/ausbushes/stalkybush = 15,
		/obj/structure/flora/ausbushes/brflowers = 5,
		/obj/structure/flora/ausbushes/sunnybush = 5,
	)
	flora_spawn_chance = 85
	mob_spawn_chance = 6
	mob_spawn_list = list(
		/mob/living/simple_animal/mouse/common = 10,
		/mob/living/simple_animal/rabbit/bunny = 12,
		/mob/living/simple_animal/cockroach = 25,
		/mob/living/simple_animal/bee = 30,
		/mob/living/simple_animal/hostile/lizard = 30,
		/mob/living/simple_animal/hostile/bear/brownbear = 8,
		/mob/living/simple_animal/hostile/lizard/frog = 15,
		/mob/living/simple_animal/cricket = 20,
		/mob/living/simple_animal/snail = 15,
		/mob/living/simple_animal/parrot = 10,
		/mob/living/simple_animal/capybara = 5
	)

// Cave biomes
/datum/biome/cave/grass
	open_turf_types = list(/turf/unsimulated/floor/planetary/cave = 1)
	closed_turf_types = list(/turf/unsimulated/mineral/random/cave = 1)
	flora_spawn_chance = 10
	flora_spawn_list = list(
		/obj/structure/flora/rock = 10,
		/obj/structure/flora/rock/pile = 5,
		/obj/structure/flora/ausbushes/sparsegrass = 8,
		/obj/structure/flora/ausbushes/grassybush = 5,
		/obj/effect/glowshroom = 5
	)
	mob_spawn_chance = 3
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 25,
		/mob/living/simple_animal/mouse/common = 20,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 15,
		/mob/living/simple_animal/hostile/scarybat/cave = 20,
		/mob/living/simple_animal/hostile/mushroom = 15,
		/mob/living/simple_animal/hostile/asteroid/pillow = 1,
		/mob/living/simple_animal/hostile/asteroid/hivelordbrood = 1,
	)

/datum/biome/cave/grass/lush
	open_turf_types = list(/turf/unsimulated/floor/planetary/dirt = 1)
	flora_spawn_chance = 35
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 20,
		/obj/structure/flora/ausbushes/grassybush = 15,
		/obj/structure/flora/ausbushes/leafybush = 10,
		/obj/structure/flora/ausbushes/fernybush = 10,
		/obj/structure/flora/ausbushes/genericbush = 8,
		/obj/effect/glowshroom = 10
	)
	mob_spawn_chance = 5
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 20,
		/mob/living/simple_animal/mouse/common = 25,
		/mob/living/simple_animal/rabbit/bunny = 15,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 12,
		/mob/living/simple_animal/hostile/scarybat/cave = 18,
		/mob/living/simple_animal/hostile/mushroom = 20,
		/mob/living/simple_animal/snail = 10
	)

/datum/biome/cave/grass/fungi
	open_turf_types = list(/turf/unsimulated/floor/planetary/cave = 1)
	flora_spawn_chance = 40
	flora_spawn_list = list(
		/obj/structure/flora/ash/leaf_shroom = 8,
		/obj/structure/flora/ash/cap_shroom = 10,
		/obj/structure/flora/ash/stem_shroom = 10,
		/obj/structure/flora/ash/tall_shroom = 8,
		/obj/structure/flora/ausbushes/sparsegrass = 10,
		/obj/structure/flora/ausbushes/fullgrass = 8,
		/obj/effect/glowshroom = 10
	)
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 30,
		/mob/living/simple_animal/mouse/common = 20,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 8,
		/mob/living/simple_animal/hostile/scarybat/cave = 15,
		/mob/living/simple_animal/hostile/mushroom = 35,
		/mob/living/simple_animal/snail = 12
	)

/datum/biome/cave/grass/wet
	open_turf_types = list(
		/turf/unsimulated/floor/jungle/mud = 3,
		/turf/unsimulated/floor/jungle/water = 2,
		/turf/unsimulated/floor/planetary/dirt = 20,
		)
	flora_spawn_chance = 50
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 25,
		/obj/structure/flora/ausbushes/fernybush = 20,
		/obj/structure/flora/ausbushes/leafybush = 15,
		/obj/structure/flora/ash/leaf_shroom = 10,
		/obj/structure/flora/ash/cap_shroom = 8,
		/obj/structure/flora/ausbushes/reedbush = 12,
		/obj/effect/glowshroom = 10
	)
	mob_spawn_chance = 6
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 25,
		/mob/living/simple_animal/mouse/common = 18,
		/mob/living/simple_animal/rabbit/bunny = 10,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 18,
		/mob/living/simple_animal/snail = 30,
		/mob/living/simple_animal/snail/greasy = 8,
		/mob/living/simple_animal/hostile/scarybat/cave = 20,
		/mob/living/simple_animal/hostile/mushroom = 25,
		/mob/living/simple_animal/hostile/lizard/frog = 15
	)
