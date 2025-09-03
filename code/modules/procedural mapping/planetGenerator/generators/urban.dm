/datum/planetGenerator/urban
	mountain_height = 0.85
	perlin_zoom = 60

	primary_area_type = /area/planetoid/urban

	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/urban/ruins,
			BIOME_LOW_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_HIGH_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/urban/wasteland/dense
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_LOW_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_HIGH_HUMIDITY = /datum/biome/urban/wasteland/dense,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/urban/wasteland/dense
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_LOW_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/urban/wasteland/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/urban/wasteland/dense,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/urban/wasteland/dense
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_LOW_HUMIDITY = /datum/biome/urban/wasteland/dense,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/urban/wasteland/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/urban/wasteland/dense,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/urban/toxic
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_LOW_HUMIDITY = /datum/biome/urban/wasteland/dense,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/urban/wasteland/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/urban/toxic,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/urban/toxic
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/urban/wasteland/dense,
			BIOME_LOW_HUMIDITY = /datum/biome/urban/wasteland/dense,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/urban/wasteland/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/urban/toxic,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/urban/toxic
		)
	)

	cave_biome_table = list(
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/urban,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/urban,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/urban,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/urban,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/urban
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/urban,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/urban,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/urban,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/urban,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/urban
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/urban,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/urban,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/urban,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/urban,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/urban
		),
		BIOME_HOT_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/urban,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/urban,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/urban,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/urban,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/urban
		)
	)

// Surface biomes
/datum/biome/urban/ruins
	open_turf_types = list(/turf/unsimulated/wasteland = 1)
	flora_spawn_list = list(
		/obj/structure/flora/rock = 15,
		/obj/structure/flora/rock/pile = 10,
		/obj/structure/grille/broken = 3,
		/obj/item/weapon/shard = 2,
	)
	flora_spawn_chance = 15
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 25,
		/mob/living/simple_animal/mouse = 15,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 10,
		/mob/living/simple_animal/hostile/lizard = 20,
		/mob/living/simple_animal/rabbit = 10,
	)
	loot_tables_list = list(
		/datum/loot_table/bedsheet = 5,
		/datum/loot_table/bureaucracy = 15,
		/datum/loot_table/clothing = 10,
		/datum/loot_table/combat = 3,
		/datum/loot_table/decoration = 8,
		/datum/loot_table/engineering = 12,
		/datum/loot_table/entertainment = 8,
		/datum/loot_table/food_or_drink = 5,
		/datum/loot_table/medical = 8,
		/datum/loot_table/module = 3,
		/datum/loot_table/structure = 2,
		/datum/loot_table/trash = 30,
	)
	loot_spawn_chance = 1.2

/datum/biome/urban/wasteland
	open_turf_types = list(/turf/unsimulated/wasteland = 1)
	flora_spawn_list = list(
		/obj/structure/flora/rock = 20,
		/obj/structure/flora/rock/pile = 15,
		/obj/structure/grille/broken = 5,
		/obj/item/weapon/shard = 3,
		/obj/structure/flora/ausbushes/sparsegrass = 5,
	)
	flora_spawn_chance = 25
	mob_spawn_chance = 3
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 30,
		/mob/living/simple_animal/mouse = 20,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 15,
		/mob/living/simple_animal/hostile/lizard = 25,
		/mob/living/simple_animal/rabbit = 5,
		/mob/living/simple_animal/hostile/asteroid/magmaw = 5,
	)
	loot_spawn_chance = 1.5

/datum/biome/urban/wasteland/dense
	flora_spawn_list = list(
		/obj/structure/flora/rock = 25,
		/obj/structure/flora/rock/pile = 20,
		/obj/structure/grille/broken = 8,
		/obj/item/weapon/shard = 5,
		/obj/structure/flora/ausbushes/sparsegrass = 8,
		/obj/structure/flora/ausbushes/grassybush = 3,
	)
	flora_spawn_chance = 35
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 35,
		/mob/living/simple_animal/mouse = 15,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 20,
		/mob/living/simple_animal/hostile/lizard = 20,
		/mob/living/simple_animal/hostile/asteroid/magmaw = 10,
	)
	loot_spawn_chance = 1.8

/datum/biome/urban/toxic
	open_turf_types = list(/turf/unsimulated/toxic = 1)
	flora_spawn_list = list(
		/obj/structure/flora/rock = 15,
		/obj/structure/flora/rock/pile = 10,
		/obj/structure/grille/broken = 6,
		/obj/item/weapon/shard = 4,
	)
	flora_spawn_chance = 1
	mob_spawn_chance = 5
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 40,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 25,
		/mob/living/simple_animal/hostile/lizard = 15,
		/mob/living/simple_animal/hostile/asteroid/magmaw = 15,
		/mob/living/simple_animal/hostile/asteroid/goliath = 5,
	)
	loot_spawn_chance = 1.0

/datum/biome/urban/toxic/dense
	flora_spawn_list = list(
		/obj/structure/flora/rock = 20,
		/obj/structure/flora/rock/pile = 15,
		/obj/structure/grille/broken = 10,
		/obj/item/weapon/shard = 6,
	)
	flora_spawn_chance = 5
	mob_spawn_chance = 6
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 45,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 30,
		/mob/living/simple_animal/hostile/lizard = 10,
		/mob/living/simple_animal/hostile/asteroid/magmaw = 20,
		/mob/living/simple_animal/hostile/asteroid/goliath = 10,
	)
	loot_spawn_chance = 0.8

// Cave biomes
/datum/biome/cave/urban
	open_turf_types = list(/turf/unsimulated/floor/cave = 1)
	closed_turf_types = list(/turf/unsimulated/mineral/random/cave = 3, /turf/unsimulated/mineral/random/high_chance/cave = 1)
	flora_spawn_chance = 8
	flora_spawn_list = list(
		/obj/structure/flora/rock = 15,
		/obj/structure/flora/rock/pile = 10,
	)
	mob_spawn_chance = 3
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 30,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 25,
		/mob/living/simple_animal/hostile/asteroid/goliath = 20,
		/mob/living/simple_animal/hostile/asteroid/rockernaut = 15,
		/mob/living/simple_animal/hostile/monster/skrite = 2,
	)
