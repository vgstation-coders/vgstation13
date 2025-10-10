/datum/planetGenerator/snow
	mountain_height = 0.45
	perlin_zoom = 55

	initial_closed_chance = 45
	smoothing_iterations = 20
	birth_limit = 4
	death_limit = 3

	primary_area_type = /area/planet/snow

/datum/planetGenerator/snow/post_process(datum/allocation/allocation)
	if(!allocation || !allocation.turfs)
		return

	var/list/glacier_turfs = list()
	var/list/isolated_glaciers = list()

	// collect all glacier turfs
	for(var/turf/T in allocation.turfs)
		if(istype(T, /turf/unsimulated/floor/snow/glacier))
			glacier_turfs += T

	// identify isolated glaciers (5+ non-glacier neighbors)
	for(var/turf/unsimulated/floor/snow/glacier/G in glacier_turfs)
		var/non_glacier_neighbors = 0
		for(var/direction in alldirs)
			var/turf/neighbor = get_step(G, direction)
			if(!istype(neighbor, /turf/unsimulated/floor/snow/glacier))
				non_glacier_neighbors++

		// If surrounded by 5 or more non-glacier turfs, mark for conversion
		if(non_glacier_neighbors >= 5)
			isolated_glaciers += G

	// convert isolated glaciers to snow
	for(var/turf/unsimulated/floor/snow/glacier/G in isolated_glaciers)
		G.ChangeTurf(/turf/unsimulated/floor/snow)
		glacier_turfs -= G

	// create glacier objects on remaining glacier turfs
	for(var/turf/unsimulated/floor/snow/glacier/G in glacier_turfs)
		var/turf/unsimulated/floor/snow/glacier/GG = G
		if(!GG.glacier_processed)
			new /obj/glacier(G, icon_update_later = 1)
			GG.glacier_processed = TRUE
	return ..()

/datum/planetGenerator/snow
	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/arctic/rocky,
			BIOME_LOW_HUMIDITY = /datum/biome/snow,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/iceberg/lake,
			BIOME_HIGH_HUMIDITY = /datum/biome/iceberg,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/iceberg
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/arctic,
			BIOME_LOW_HUMIDITY = /datum/biome/arctic/rocky,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/snow/lush,
			BIOME_HIGH_HUMIDITY = /datum/biome/snow,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/iceberg
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
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/volcanic/lava,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/volcanic/lava,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/volcanic/lava
		)
	)

/datum/biome/snow
	open_turf_types = list(
		/turf/unsimulated/floor/snow = 10
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
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/wolf = 5,
		/mob/living/simple_animal/hostile/deer = 5,
		/mob/living/simple_animal/hostile/bear/polarbear = 2,
		/mob/living/simple_animal/rabbit = 3,
		/mob/living/simple_animal/hostile/decoy/snowman = 1,
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

/datum/biome/snow/lush
	open_turf_types = list(
		/turf/unsimulated/floor/snow = 1
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
		/turf/unsimulated/floor/snow = 4
	)
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/wolf = 10,
		/mob/living/simple_animal/hostile/deer = 10,
		/mob/living/simple_animal/hostile/bear/polarbear = 5,
		/mob/living/simple_animal/rabbit = 2,
		/mob/living/simple_animal/hostile/decoy/snowman = 1,
	)
	mob_spawn_chance = 1

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
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/wolf = 10,
		/mob/living/simple_animal/hostile/bear/polarbear = 10,
		/mob/living/simple_animal/hostile/decoy/snowman = 1,
	)


/datum/biome/iceberg/lake
	open_turf_types = list(
		/turf/unsimulated/floor/snow/glacier = 1,
	)

/datum/biome/cave/snow
	open_turf_types = list(
		/turf/unsimulated/floor/snow/cave = 1
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
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/wolf = 10,
		/mob/living/simple_animal/hostile/bear/polarbear = 5,
		/mob/living/simple_animal/hostile/decoy/snowman/frostgolem/knight = 1,
		/mob/living/simple_animal/hostile/decoy/snowman/frostgolem/wizard = 1,
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
		/turf/unsimulated/floor/snow/cave = 1
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
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/wolf = 10,
		/mob/living/simple_animal/hostile/bear/polarbear = 5,
		/mob/living/simple_animal/hostile/decoy/snowman/frostgolem/knight = 1,
		/mob/living/simple_animal/hostile/decoy/snowman/frostgolem/wizard = 1,
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
