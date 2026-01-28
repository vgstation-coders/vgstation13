/datum/planetGenerator/urban
	mountain_height = 0.85
	perlin_zoom = 60
	primary_area_type = /area/planet/urban
	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_LOW_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/urban/ruins,
			BIOME_HIGH_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/urban/wasteland/dense
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_LOW_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/urban/ruins,
			BIOME_HIGH_HUMIDITY = /datum/biome/urban/wasteland/dense,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/urban/wasteland/dense
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/urban/wasteland,
			BIOME_LOW_HUMIDITY = /datum/biome/urban/ruins,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/urban/ruins,
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

/datum/planetGenerator/urban/post_process(datum/allocation/allocation)
	..()
	if(!allocation || !allocation.turfs)
		return

	var/decay_chance = 20 // Chance for road tiles to be decayed/missing (reduced from 35)
	var/num_road_segments = rand(8, 15) // Number of road segments to generate

	// Find bounds of the allocation
	var/min_x = 999999
	var/max_x = 0
	var/min_y = 999999
	var/max_y = 0

	for(var/turf/T in allocation.turfs)
		if(T.x < min_x)
			min_x = T.x
		if(T.x > max_x)
			max_x = T.x
		if(T.y < min_y)
			min_y = T.y
		if(T.y > max_y)
			max_y = T.y

	var/list/road_turfs = list()

	// random walk roads
	for(var/i = 1; i <= num_road_segments; i++)
		var/start_x = rand(min_x + 5, max_x - 5)
		var/start_y = rand(min_y + 5, max_y - 5)

		var/is_horizontal = prob(50)
		var/segment_length = rand(20, 50)
		var/road_width = rand(2, 4)

		// Add random curve/bend to the road
		var/curve_chance = rand(10, 30)

		// horizontal roads
		if(is_horizontal)
			var/current_y = start_y
			for(var/x = start_x; x < start_x + segment_length && x <= max_x; x++)
				if(prob(curve_chance))
					current_y += pick(-1, 1)
					current_y = clamp(current_y, min_y, max_y)

				for(var/w = 0; w < road_width; w++)
					var/turf/T = locate(x, current_y + w, allocation.turfs[1].z)
					if(T && (T in allocation.turfs))
						var/area/A = get_area(T)
						if(!istype(A, /area/planet/urban))
							continue
						if(istype(T, /turf/unsimulated/floor/planetary/cave) || istype(T, /turf/unsimulated/mineral))
							continue
						if(!prob(decay_chance))
							T.ChangeTurf(/turf/unsimulated/floor/planetary/concrete/jungle)
							road_turfs += T

							// lane markers
							if(road_width >= 3 && w == round(road_width / 2))
								if(prob(70))
									new /obj/effect/decal/warning_stripes/pathmarkers/horizontal(T)
		else
			// vertical roads
			var/current_x = start_x
			for(var/y = start_y; y < start_y + segment_length && y <= max_y; y++)
				if(prob(curve_chance))
					current_x += pick(-1, 1)
					current_x = clamp(current_x, min_x, max_x)

				for(var/w = 0; w < road_width; w++)
					var/turf/T = locate(current_x + w, y, allocation.turfs[1].z)
					if(T && (T in allocation.turfs))
						var/area/A = get_area(T)
						if(!istype(A, /area/planet/urban))
							continue
						if(istype(T, /turf/unsimulated/floor/planetary/cave) || istype(T, /turf/unsimulated/mineral))
							continue
						if(!prob(decay_chance))
							T.ChangeTurf(/turf/unsimulated/floor/planetary/concrete/jungle)
							road_turfs += T
							if(road_width >= 3 && w == round(road_width / 2))
								if(prob(70))
									new /obj/effect/decal/warning_stripes/pathmarkers(T, EAST)

	// potholes (midwest reference)
	for(var/turf/unsimulated/floor/planetary/concrete/jungle/C in allocation.turfs)
		if(prob(12)) // the most magical of all numbers
			var/decay_options = list(
				/turf/unsimulated/floor/planetary/wasteland,
				/turf/unsimulated/floor/planetary/toxic
			)
			C.ChangeTurf(pick(decay_options))

	// decayed buildings
	var/num_buildings = rand(5, 12)
	var/list/building_floor_types = list(
		/turf/unsimulated/floor/planetary/dirt,
		/turf/unsimulated/floor/planetary/wasteland
	)

	for(var/i = 1; i <= num_buildings; i++)
		var/building_width = rand(4, 10)
		var/building_height = rand(4, 10)

		var/building_x = rand(min_x + 10, max_x - building_width - 10)
		var/building_y = rand(min_y + 10, max_y - building_height - 10)

		var/can_place = TRUE
		for(var/check_x = building_x - 1; check_x <= building_x + building_width + 1; check_x++)
			for(var/check_y = building_y - 1; check_y <= building_y + building_height + 1; check_y++)
				var/turf/check_turf = locate(check_x, check_y, allocation.turfs[1].z)
				if(!check_turf || !(check_turf in allocation.turfs))
					can_place = FALSE
					break
				var/area/check_area = get_area(check_turf)
				if(!istype(check_area, /area/planet/urban))
					can_place = FALSE
					break
				if(istype(check_turf, /turf/unsimulated/floor/planetary/concrete/jungle) || istype(check_turf, /turf/unsimulated/floor/planetary/cave) || istype(check_turf, /turf/unsimulated/mineral))
					can_place = FALSE
					break
			if(!can_place)
				break

		if(!can_place)
			continue

		// Place building
		for(var/bx = building_x; bx < building_x + building_width; bx++)
			for(var/by = building_y; by < building_y + building_height; by++)
				var/turf/build_turf = locate(bx, by, allocation.turfs[1].z)
				if(!build_turf || !(build_turf in allocation.turfs))
					continue

				// Outer walls (with decay)
				if(bx == building_x || bx == building_x + building_width - 1 || by == building_y || by == building_y + building_height - 1)
					if(prob(60)) // Some walls are missing
						if(prob(40)) // Mix of girders and walls
							new /obj/structure/girder(build_turf)
						else
							build_turf.ChangeTurf(/turf/simulated/wall)
						for(var/obj/thing in build_turf.contents)
							qdel(thing) // no things in walls
				else
					build_turf.ChangeTurf(pick(building_floor_types))

	return ..()

// Surface biomes
/datum/biome/urban
	loot_spawn_chance = 2
	loot_spawners = list(
		/obj/abstract/loot_spawner/bureaucracy = 2,
		/obj/abstract/loot_spawner/clothing = 2,
		/obj/abstract/loot_spawner/combat = 1,
		/obj/abstract/loot_spawner/engineering = 1,
		/obj/abstract/loot_spawner/medical = 1,
		/obj/abstract/loot_spawner/structure = 1,
		/obj/abstract/loot_spawner/trash = 3,
	)
	mob_spawn_chance = 3

/datum/biome/urban/ruins
	open_turf_types = list(/turf/unsimulated/floor/planetary/wasteland = 1)
	flora_spawn_list = list(
		/obj/structure/flora/rock = 15,
		/obj/structure/flora/rock/pile = 10,
		/obj/structure/grille/broken = 3,
		/obj/item/weapon/shard = 2,
	)
	flora_spawn_chance = 10
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 100,
		/mob/living/simple_animal/hostile/lizard = 50,
		/mob/living/simple_animal/hostile/necro/zombie = 25,
		/mob/living/simple_animal/hostile/necro/skeleton = 25,
		/mob/living/simple_animal/hostile/creature = 10,
		/mob/living/simple_animal/hostile/monster/cyber_horror = 5,
		/mob/living/simple_animal/hostile/necro/necromorph = 5,
		/mob/living/simple_animal/hostile/necro/skeleton = 25,
		/mob/living/simple_animal/hostile/necro/zombie = 25,
	)

/datum/biome/urban/wasteland
	open_turf_types = list(/turf/unsimulated/floor/planetary/wasteland = 1)
	flora_spawn_list = list(
		/obj/structure/flora/rock = 20,
		/obj/structure/flora/rock/pile = 15,
		/obj/structure/grille/broken = 5,
		/obj/item/weapon/shard = 3,
		/obj/structure/flora/ausbushes/sparsegrass = 5,
	)
	flora_spawn_chance = 5
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 100,
		/mob/living/simple_animal/hostile/lizard = 50,
		/mob/living/simple_animal/hostile/bigroach = 25,
		/mob/living/simple_animal/hostile/bigroach/queen = 10,
		/mob/living/simple_animal/hostile/necro/zombie = 25,
		/mob/living/simple_animal/hostile/necro/skeleton = 25,
		/mob/living/simple_animal/borer = 10,
		/mob/living/simple_animal/hostile/creature = 10,
		/mob/living/simple_animal/hostile/necro/necromorph = 5,
		/mob/living/simple_animal/hostile/necro/skeleton = 25,
		/mob/living/simple_animal/hostile/necro/zombie = 25,
		/mob/living/simple_animal/hostile/mushroom = 50
	)

/datum/biome/urban/wasteland/dense
	flora_spawn_list = list(
		/obj/structure/flora/rock = 25,
		/obj/structure/flora/rock/pile = 20,
		/obj/structure/grille/broken = 8,
		/obj/item/weapon/shard = 5,
		/obj/structure/flora/ausbushes/sparsegrass = 8,
		/obj/structure/flora/ausbushes/grassybush = 3,
	)
	flora_spawn_chance = 25
	mob_spawn_chance = 5

/datum/biome/urban/toxic
	open_turf_types = list(/turf/unsimulated/floor/planetary/toxic = 1)
	flora_spawn_list = list(
		/obj/structure/flora/rock = 15,
		/obj/structure/flora/rock/pile = 10,
		/obj/structure/grille/broken = 6,
		/obj/item/weapon/shard = 4,
	)
	flora_spawn_chance = 1
	mob_spawn_chance = 6
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 100,
		/mob/living/simple_animal/hostile/bigroach = 10,
		/mob/living/simple_animal/hostile/bigroach/queen = 1,
		/mob/living/simple_animal/hostile/necro/animal_ghoul = 25,
		/mob/living/simple_animal/hostile/necro/meat_ghoul = 10,
		/mob/living/simple_animal/hostile/necro/zombie/ghoul = 10,
		/mob/living/simple_animal/hostile/necro/zombie/ghoul/glowing_one = 5,
		/mob/living/simple_animal/hostile/mushroom = 50
	)

/datum/biome/urban/toxic/dense
	flora_spawn_list = list(
		/obj/structure/flora/rock = 20,
		/obj/structure/flora/rock/pile = 15,
		/obj/structure/grille/broken = 10,
		/obj/item/weapon/shard = 6,
	)
	flora_spawn_chance = 5
	mob_spawn_chance = 7
	loot_spawn_chance = 3

// Cave biomes
/datum/biome/cave/urban
	open_turf_types = list(/turf/unsimulated/floor/planetary/cave = 1)
	closed_turf_types = list(/turf/unsimulated/mineral/random/cave = 3, /turf/unsimulated/mineral/random/high_chance/cave = 1)
	flora_spawn_chance = 8
	flora_spawn_list = list(
		/obj/structure/flora/rock = 15,
		/obj/structure/flora/rock/pile = 10,
		/obj/effect/glowshroom = 15
	)
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/simple_animal/cockroach = 100,
		/mob/living/simple_animal/hostile/lizard = 50,
		/mob/living/simple_animal/hostile/bigroach = 25,
		/mob/living/simple_animal/hostile/bigroach/queen = 10,
		/mob/living/simple_animal/hostile/necro/zombie = 25,
		/mob/living/simple_animal/hostile/necro/skeleton = 25,
		/mob/living/simple_animal/borer = 10,
		/mob/living/simple_animal/hostile/creature = 10,
		/mob/living/simple_animal/hostile/necro/necromorph = 5,
		/mob/living/simple_animal/hostile/necro/skeleton = 25,
		/mob/living/simple_animal/hostile/necro/zombie = 25,
		/mob/living/simple_animal/hostile/mushroom = 50,
		/mob/living/simple_animal/scp_173 = 1
	)
