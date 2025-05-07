/datum/biome/desert
	name = "Desert"
	desc = "Hot and dry."
	generation_weight = 100
	floor_turfs = list(
		/turf/simulated/floor/plating/ironsand
	)
	wall_turfs = list(
		/turf/unsimulated/wall/evil
	)
	flora_spawn_chance = 0.2
	flora = list(
		/obj/structure/flora/rock = 10,
		/obj/structure/flora/rock/pile = 10,
		/obj/structure/flora/tree = 5,
		/obj/structure/flora/ausbushes/stalkybush = 20,
		/obj/structure/flora/desert/barrelcactus = 10,
		/obj/structure/flora/desert/saguaro = 10,
		/obj/structure/flora/desert/tumbleweed = 1,
	)
	fauna_spawn_chance = 0.2
	fauna = list(
		/mob/living/simple_animal/cockroach = 10,
		/mob/living/simple_animal/rabbit = 50,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 20,
		/mob/living/simple_animal/hostile/asteroid/goliath = 20,
		/mob/living/simple_animal/hostile/asteroid/magmaw = 20,
		/mob/living/simple_animal/hostile/asteroid/rockernaut = 20,
		/mob/living/simple_animal/hostile/lizard = 50,
		/mob/living/simple_animal/hostile/monster/skrite = 1,
	)
	ore_spawn_chance = 0.5
	ores = list(
		/turf/unsimulated/mineral/uranium/hive = 20,
		/turf/unsimulated/mineral/iron/hive = 40,
		/turf/unsimulated/mineral/diamond/hive = 10,
		/turf/unsimulated/mineral/gold/hive = 20,
		/turf/unsimulated/mineral/silver/hive = 20,
		/turf/unsimulated/mineral/plasma/hive = 30,
		/turf/unsimulated/mineral/clown/hive = 5,
		/turf/unsimulated/mineral/phazon/hive = 5,
		/turf/unsimulated/mineral/telecrystal/hive = 1
	)
