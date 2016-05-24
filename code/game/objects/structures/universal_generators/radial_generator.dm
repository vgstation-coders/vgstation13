/*
 * Why have simple atom generation when you can have complex atom generation ?
 * Instead of placing individual items at random, we have a much smaller chance of placing "generation seeds"
 * Once that's down, tiles in a certain radius follow complex seeding rules
 * Can be used to make anything. Small forest zones, lakes, murder zones, debris, generic clutter, mob groups, etc
 * Supports objects and mobs (under movable) and turfs. Only one at a time, though (mobs and objects can be mixed, but should be mixed, carefully)
 * Note that it only supports random and radial generation. Anything more complex will need an even more complex and specific generator
 * While this generator supports all three types at once, it will try to spawn all three types at once
 */

//Base instance to define variables
//This will not spawn anything, so we need to go down one tier
/obj/structure/rng_generator

	name = "generator"
	desc = "The randomly generated seed of all things."
	icon = 'icons/obj/universal_generator/generators.dmi'
	icon_state = "generator_null"

	var/gen_min_radius = 0 //Radius from center before generation starts, 1 is equivalent to orange
	var/gen_soft_radius = 0 //Soft generator radius, different rules beyond this point. Starts after minimum but ends relative to center
	var/gen_hard_radius = 0 //Hard generator radius, nothing will generate past this, ever
	var/gen_prob_base = 0 //Base probability to plant something on a tile
	var/gen_prob_soft_fall = 0 //Probability reduction per tile after center
	var/gen_prob_hard_fall = 0	//Probability reduction per tile after last soft radius, overrides the former
	var/gen_empty_only = 0 //Generator will only work on tiles that are completely empty (!contents.len)
	var/gen_no_dense_only = 0 //Generator will only work on tiles without dense contents
	var/expected_turf //Will return if turf type is different, good to avoid generator collision with other terrain features

/obj/structure/rng_generator/New()

	..()

	deploy_generator()
	qdel(src) //This is exclusively used to generate other things, delete it once we're done

//Uses modular code structure, so you can define different behaviour
//We start by initializing shared behavior between all three generator sub-types, then we fire a spawn proc that they will modify
/obj/structure/rng_generator/proc/deploy_generator()

	for(var/turf/T in spiral_block(get_turf(src), gen_hard_radius, 0))

		if(expected_turf && !istype(T, expected_turf)) //We are expecting a specific turf type, and it is not this one
			continue

		if(gen_empty_only && T.has_contents()) //We are looking for empty turfs, this turf isn't empty
			continue

		if(gen_no_dense_only && T.has_dense_content()) //We are looking for turfs without dense contents, this turf has some
			continue

		var/dist = cheap_pythag(T.x - x, T.y - y)

		if(dist < gen_min_radius) //Distance is below the minimum radius, forget this one

			continue

		if(dist < gen_hard_radius) //Inside the soft radius, minimum falloff

			var/soft_prob = max(0, gen_prob_base - gen_prob_soft_fall * (dist - gen_min_radius))

			if(prob(soft_prob)) //If the prob roll happens, continue onto generation

				var/picked = perform_pick("soft", T)

				perform_spawn("soft", T, picked)

			continue

		if(dist > gen_hard_radius) //Inside the soft to hard radius, maximum falloff

			var/hard_prob = max(0, gen_prob_base - gen_prob_soft_fall * (gen_soft_radius - gen_min_radius) - gen_prob_hard_fall * (dist - gen_soft_radius))

			if(prob(hard_prob)) //If the prob roll happens, continue onto generation

				var/picked = perform_pick("soft", T)

				perform_spawn("hard", T, picked)

			continue

//We pick the thing we will possibly spawn, because we need that to roll out adjacency rules
/obj/structure/rng_generator/proc/perform_pick(var/gen_type = "soft", var/turf/T)

	return 0

//We now have all that shit out of the way, spawn the fucking thing
/obj/structure/rng_generator/proc/perform_spawn(var/gen_type = "soft", var/turf/T)

	return 0

/obj/structure/rng_generator/movable

	var/list/gen_types_movable_soft = list() //What types do we generate from this generator, array must contain individual probabilities for each movable. Only in soft radius
	var/list/gen_types_movable_hard = list() //Ditto above, but only in hard radius. Obviously, if you want it to spawn in both, add to both lists. OBVIOUSLY

/obj/structure/rng_generator/movable/perform_pick(var/gen_type = "soft", var/turf/T)

	switch(gen_type)

		if("soft")

			if(gen_types_movable_soft.len)

				var/picked_movable = pickweight(gen_types_movable_soft)

				return picked_movable

		if("hard")

			if(gen_types_movable_hard.len)

				var/picked_movable = pickweight(gen_types_movable_hard)

				return picked_movable

/obj/structure/rng_generator/movable/perform_spawn(var/gen_type = "soft", var/turf/T, var/atom/movable/picked)

	new picked(T)

/obj/structure/rng_generator/turf

	var/list/gen_types_turf_soft = list() //What types do we generate from this generator, array must contain individual probabilities for each turf. Only in soft radius
	var/list/gen_types_turf_hard = list() //Ditto above, but only in hard radius. Obviously, if you want it to spawn in both, add to both lists. OBVIOUSLY

/obj/structure/rng_generator/turf/perform_pick(var/gen_type = "soft", var/turf/T, var/turf/picked)

	switch(gen_type)

		if("soft")

			if(gen_types_turf_soft.len)

				var/picked_turf = pickweight(gen_types_turf_soft)

				return picked_turf

		if("hard")

			if(gen_types_turf_hard.len)

				var/picked_turf = pickweight(gen_types_turf_hard)

				return picked_turf

/obj/structure/rng_generator/turf/perform_spawn(var/gen_type = "soft", var/turf/T, var/turf/picked)

	T.ChangeTurf(picked)

//Well, it's finally time to test this
/obj/structure/rng_generator/movable/thisisatest

	gen_min_radius = 1 //Radius from center before generation starts, 1 is equivalent to orange
	gen_soft_radius = 3 //Soft generator radius, different rules beyond this point. Starts after minimum but ends relative to center
	gen_hard_radius = 3 //Hard generator radius, nothing will generate past this, ever
	gen_prob_base = 100 //Base probability to plant something on a tile
	gen_prob_soft_fall = 2 //Probability reduction per tile after center
	gen_prob_hard_fall = 5	//Probability reduction per tile after last soft radius, overrides the former
	gen_empty_only = 0 //Generator will only work on tiles that are completely empty (!contents.len)
	gen_no_dense_only = 1 //Generator will only work on tiles without dense contents
	expected_turf = /turf/simulated/floor //Will return if turf type is different, good to avoid generator collision with other terrain features

	//What types do we generate from this generator, array must contain individual probabilities for each turf. Only in soft radius
	gen_types_movable_soft = list(/obj/structure/window/full/reinforced/plasma = 10, \
								/obj/structure/window/full/plasma = 25, \
								/obj/structure/window/full/reinforced = 50)
	//Ditto above, but only in hard radius. Obviously, if you want it to spawn in both, add to both lists. OBVIOUSLY
	gen_types_movable_hard = list(/obj/structure/window/full = 25, \
								/obj/structure/window/full/reinforced = 75)

