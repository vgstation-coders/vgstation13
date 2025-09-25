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
	open_turf_types = list(/turf/unsimulated/floor/planetary/desert = 1)

	flora_spawn_list = list(
		/obj/structure/flora/rock = 10,
		/obj/structure/flora/rock/pile = 10,
		/obj/structure/flora/desert/barrelcactus = 20,
		/obj/structure/flora/desert/saguaro = 20,
		/obj/structure/flora/desert/tumbleweed = 5,
	)
	flora_spawn_chance = 4
	mob_spawn_chance = 1

	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 10,
		/mob/living/simple_animal/rabbit = 50,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 20,
		/mob/living/simple_animal/hostile/asteroid/magmaw = 20,
		/mob/living/simple_animal/hostile/lizard = 50,
	)
	loot_tables_list = list(
		/datum/loot_table/bedsheet = 10,
		/datum/loot_table/bureaucracy = 5,
		/datum/loot_table/clothing = 5,
		/datum/loot_table/combat = 1,
		/datum/loot_table/decoration = 5,
		/datum/loot_table/engineering = 5,
		/datum/loot_table/entertainment = 10,
		/datum/loot_table/food_or_drink = 10,
		/datum/loot_table/medical = 5,
		/datum/loot_table/module = 5,
		/datum/loot_table/structure = 1,
		/datum/loot_table/trash = 20,
	)
	loot_spawn_chance = 0.5

/datum/biome/dry_seafloor
	open_turf_types = list(/turf/unsimulated/floor/planetary/desert/dry = 1)

	flora_spawn_list = list(
		/obj/structure/flora/rock = 10,
		/obj/structure/flora/rock/pile = 10,
		/obj/structure/flora/ausbushes/stalkybush = 5,
	)
	flora_spawn_chance = 1
	loot_tables_list = list(
		/datum/loot_table/bedsheet = 10,
		/datum/loot_table/bureaucracy = 5,
		/datum/loot_table/clothing = 5,
		/datum/loot_table/combat = 1,
		/datum/loot_table/decoration = 5,
		/datum/loot_table/engineering = 5,
		/datum/loot_table/entertainment = 10,
		/datum/loot_table/food_or_drink = 10,
		/datum/loot_table/medical = 5,
		/datum/loot_table/module = 5,
		/datum/loot_table/structure = 1,
		/datum/loot_table/trash = 20,
	)
	loot_spawn_chance = 0.25

/datum/biome/cave/desert
	open_turf_types = list(/turf/simulated/floor/asteroid/air = 1)
	closed_turf_types = list(/turf/unsimulated/mineral/random = 1)
	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/flora/rock = 5,
		/obj/structure/flora/rock/pile = 1,
		)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 10,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 20,
		/mob/living/simple_animal/hostile/asteroid/goliath = 20,
		/mob/living/simple_animal/hostile/asteroid/rockernaut = 20,
		/mob/living/simple_animal/hostile/monster/skrite = 1,
	)
