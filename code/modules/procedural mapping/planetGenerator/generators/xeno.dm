/datum/planetGenerator/xeno
	mountain_height = 0.5
	perlin_zoom = 80

	primary_area_type = /area/planet/xeno

	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/xeno,
			BIOME_LOW_HUMIDITY = /datum/biome/xeno,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGH_HUMIDITY = /datum/biome/xeno/vox,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/xeno/vox
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/xeno,
			BIOME_LOW_HUMIDITY = /datum/biome/xeno,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGH_HUMIDITY = /datum/biome/xeno/vox,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/xeno/vox
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/xeno,
			BIOME_LOW_HUMIDITY = /datum/biome/xeno,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGH_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/xeno/vox
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/xeno/desert,
			BIOME_LOW_HUMIDITY = /datum/biome/xeno,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGH_HUMIDITY = /datum/biome/xeno,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/xeno
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/xeno/desert,
			BIOME_LOW_HUMIDITY = /datum/biome/xeno/desert,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/xeno,
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
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/xeno/living,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/xeno
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/xeno,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/xeno
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
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/xeno,
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
	mob_spawn_chance = 20
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/mothership_saucerdrone = 50,
		/mob/living/simple_animal/hostile/mothership_hoverdisc = 50,
		/mob/living/simple_animal/hostile/retaliate/polyp = 100,
		/mob/living/simple_animal/hostile/retaliate/cattle_specimen = 50,
		/mob/living/simple_animal/hostile/humanoid/grey = 25,
		/mob/living/simple_animal/hostile/humanoid/grey/prisoner = 25,
		/mob/living/simple_animal/hostile/humanoid/grey/prisoner/melee = 25,
		/mob/living/simple_animal/hostile/humanoid/grey/prisoner/ranged = 25,
		/mob/living/simple_animal/hostile/humanoid/grey/explorer = 25,
		/mob/living/simple_animal/hostile/humanoid/grey/soldier/sentry = 10,
		/mob/living/simple_animal/hostile/humanoid/grey/soldier/regular = 10,
		/mob/living/simple_animal/hostile/humanoid/grey/soldier/pacifier = 10,
		/mob/living/simple_animal/hostile/humanoid/grey/soldier/pacifier/explorer = 10,
		/mob/living/simple_animal/hostile/humanoid/grey/soldier/grenadier = 5,
		/mob/living/simple_animal/hostile/humanoid/grey/soldier/heavy = 5,
		/mob/living/simple_animal/hostile/humanoid/grey/researcher = 15,
		/mob/living/simple_animal/hostile/humanoid/grey/researcher/laser = 15,
		/mob/living/simple_animal/hostile/humanoid/grey/researcher/chemist = 15,
		/mob/living/simple_animal/hostile/humanoid/grey/researcher/surgeon = 15,
		/mob/living/simple_animal/hostile/humanoid/grey/leader = 1,
	)
	loot_spawn_chance = 1
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
		/mob/living/simple_animal/hostile/humanoid/grey = 1,
		/mob/living/simple_animal/hostile/humanoid/grey/explorer = 1,
		/mob/living/simple_animal/hostile/humanoid/grey/soldier/pacifier/explorer = 1,
		/mob/living/simple_animal/hostile/humanoid/grey/researcher = 1,
	)
	loot_spawn_chance = 1

/datum/biome/xeno/vox
	open_turf_types = list(/turf/unsimulated/floor/planetary/xeno/desert/white = 1)
	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/flora/xeno_flora = 10,
		/obj/structure/flora/xeno_flora/blue = 10,
		/obj/structure/flora/xeno_flora/red = 10,
		/obj/structure/flora/xeno_flora/orange = 10,
	)
	mob_spawn_list = list(
		/mob/living/simple_animal/vox/armalis = 20,
		/mob/living/simple_animal/hostile/retaliate/box = 100,
		/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/medic = 5,
		/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/assassin = 5,
		/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/breacher = 5,
		/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/deadeye = 5,
		/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/leader = 1,
		/mob/living/simple_animal/hostile/humanoid/vox/crossbow/spacesuit = 10,
		/mob/living/simple_animal/hostile/humanoid/vox/ion/spacesuit = 10,
	)

/datum/biome/cave/xeno
	open_turf_types = list(/turf/unsimulated/floor/planetary/cave = 1)
	closed_turf_types = list(
		/turf/unsimulated/mineral/random/xeno = 3,
		/turf/unsimulated/mineral/random/high_chance/xeno = 1,
	)
	mob_spawn_chance = 20
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/humanoid/grey = 25,
		/mob/living/simple_animal/hostile/humanoid/grey/prisoner = 25,
		/mob/living/simple_animal/hostile/humanoid/grey/prisoner/melee = 25,
		/mob/living/simple_animal/hostile/humanoid/grey/prisoner/ranged = 25,
		/mob/living/simple_animal/hostile/humanoid/grey/explorer = 25,
		/mob/living/simple_animal/hostile/humanoid/grey/soldier/sentry = 10,
		/mob/living/simple_animal/hostile/humanoid/grey/soldier/regular = 10,
		/mob/living/simple_animal/hostile/humanoid/grey/soldier/pacifier = 10,
		/mob/living/simple_animal/hostile/humanoid/grey/soldier/pacifier/explorer = 10,
		/mob/living/simple_animal/hostile/humanoid/grey/soldier/grenadier = 5,
		/mob/living/simple_animal/hostile/humanoid/grey/soldier/heavy = 5,
		/mob/living/simple_animal/hostile/humanoid/grey/researcher = 15,
		/mob/living/simple_animal/hostile/humanoid/grey/researcher/laser = 15,
		/mob/living/simple_animal/hostile/humanoid/grey/researcher/chemist = 15,
		/mob/living/simple_animal/hostile/humanoid/grey/researcher/surgeon = 15,
		/mob/living/simple_animal/hostile/humanoid/grey/leader = 1,
	)

	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/acid_puddle = 25,
		/obj/effect/glowshroom = 100
	)
	loot_spawn_chance = 1
	loot_spawners = list(
		/obj/abstract/loot_spawner/combat = 1,
		/obj/abstract/loot_spawner/exotic = 2
	)

/datum/biome/cave/xeno/nest
	open_turf_types = list(/turf/unsimulated/floor/planetary/cave/xeno = 1)
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/alien/drone = 30,
		/mob/living/simple_animal/hostile/alien = 30,
		/mob/living/simple_animal/hostile/alien/queen = 5,
		/mob/living/simple_animal/hostile/alien/sentinel = 25,
	)
	flora_spawn_list = list(
		/obj/item/clothing/mask/facehugger = 100,
		/obj/effect/alien/weeds/node = 25,
		/obj/effect/alien/egg = 75,
		/obj/effect/alien/resin = 20,
		/obj/effect/alien/resin/membrane = 20,
		/obj/effect/alien/resin/wall = 10,
	)

/datum/biome/cave/xeno/living
	open_turf_types = list(/turf/unsimulated/floor/asteroid/hive/living = 1)
	closed_turf_types = list(
		/turf/unsimulated/mineral/random/xeno = 1,
	)
	mob_spawn_chance = 0
	flora_spawn_list = list(
		/obj/structure/acid_puddle = 10,
		/obj/effect/glowshroom = 100
	)
	loot_spawn_chance = 0
