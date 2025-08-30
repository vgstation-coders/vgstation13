
/datum/biome
	/// WEIGHTED list of open turfs that this biome can place
	var/list/open_turf_types = list(/turf/unsimulated/floor/cave = 1)
	/// EXPANDED (no values) list of open turfs that this biome can place
	var/list/open_turf_types_expanded
	/// WEIGHTED list of flora that this biome can spawn.
	/// Flora do not have any local keep-away logic; all spawns are independent.
	var/list/flora_spawn_list
	/// EXPANDED (no values) list of flora that this biome can spawn.
	var/list/flora_spawn_list_expanded
	/// WEIGHTED list of features that this biome can spawn.
	/// Features will not spawn within 7 tiles of other features of the same type.
	var/list/feature_spawn_list
	/// EXPANDED (no values) list of features that this biome can spawn.
	var/list/feature_spawn_list_expanded
	/// WEIGHTED list of mobs that this biome can spawn.
	/// Mobs have multi-layered logic for determining if they can be spawned on a given tile.
	/// Necropolis spawners etc. should go HERE, not in features, despite them not being mobs.
	var/list/mob_spawn_list
	/// EXPANDED (no values) list of mobs that this biome can spawn.
	var/list/mob_spawn_list_expanded
	/// list of loot tables that this biome can spawn.
	var/list/loot_tables_list
	/// WEIGHTED list of loot objects that this biome can spawn.
	var/list/loot_spawn_list
	/// EXPANDED (no values) list of loot objects that this biome can spawn.
	var/list/loot_spawn_list_expanded

	/// Percentage chance that an open turf will attempt a flora spawn.
	var/flora_spawn_chance = 2
	/// Base percentage chance that an open turf will attempt a feature spawn.
	var/feature_spawn_chance = 1
	/// Base percentage chance that an open turf will attempt a flora spawn.
	var/mob_spawn_chance = 6
	/// Base percentage chance that an open turf will attempt a loot spawn.
	var/loot_spawn_chance = 1

/datum/biome/New()
	open_turf_types_expanded = expand_weights(open_turf_types)
	if(length(flora_spawn_list))
		flora_spawn_list_expanded = expand_weights(flora_spawn_list)
	if(length(feature_spawn_list))
		feature_spawn_list_expanded = expand_weights(feature_spawn_list)
	if(length(mob_spawn_list))
		mob_spawn_list_expanded = expand_weights(mob_spawn_list)
	for(var/datum/loot_table/LT in loot_spawn_list)
		for(var/entry in LT.loot)
			loot_spawn_list += entry
	if(length(loot_spawn_list))
		loot_spawn_list_expanded = expand_weights(loot_spawn_list)

/// Changes the passed turf according to the biome's internal logic, optionally using string_gen,
/// and adds it to the passed area.
/datum/biome/proc/generate_turf(turf/gen_turf, area/new_area, string_gen)
	var/area/A = get_area(gen_turf)
	if(!(A.flags & CAVES_ALLOWED))
		return FALSE

	// change the area
	new_area.contents += gen_turf
	gen_turf.change_area(A, new_area)

	// take NO_RUINS_1 from gen_turf.turf_flags, and save it
	var/stored_flags = gen_turf.turf_flags & NO_RUINS_1
	var/turf/new_turf = get_turf_type(gen_turf, string_gen)
	new_turf = gen_turf.ChangeTurf(new_turf)
	// readd the flag we saved
	new_turf?.turf_flags |= stored_flags
	return TRUE

/datum/biome/proc/get_turf_type(turf/gen_turf, string_gen)
	return pick(open_turf_types_expanded)

/// Fills a turf with flora, features, and creatures based on the biome's variables.
/// The features and creatures compare against and add to the lists passed to determine
/// if they can spawn at the tested turf. This method of checking reduces the amount of
/// time spent populating a planet.
/datum/biome/proc/populate_turf(turf/gen_turf, list/feature_list, list/mob_list)
	if(iswall(gen_turf) || istype(gen_turf, /turf/unsimulated/mineral)) //make helper
		return
	var/turf/simulated/floor/floor_turf = gen_turf
	var/area/A = floor_turf.loc
	var/a_flags = A.flags
	// ruins should set this on all areas they don't want to be filled with mobs and decorations
	if(!(a_flags & CAVES_ALLOWED))
		return

	var/atom/spawned_flora
	var/atom/spawned_feature
	var/atom/spawned_mob

	//FLORA SPAWNING HERE
	if(length(flora_spawn_list_expanded) && prob(flora_spawn_chance) && (a_flags & FLORA_ALLOWED) && !(floor_turf.turf_flags & NO_FLORA))
		spawned_flora = pick(flora_spawn_list_expanded)
		spawned_flora = new spawned_flora(floor_turf)
		floor_turf.turf_flags |= NO_LAVA_GEN_1

	//FEATURE SPAWNING HERE
	if(length(feature_spawn_list_expanded) && prob(feature_spawn_chance) && (a_flags & FLORA_ALLOWED)) //checks the same flag because lol dunno
		var/atom/feature_type = pick(feature_spawn_list_expanded)

		var/can_spawn = TRUE
		for(var/other_feature in feature_list)
			if(get_dist(floor_turf, other_feature) <= 7 && istype(other_feature, feature_type))
				can_spawn = FALSE
				break

		if(can_spawn)
			spawned_feature = new feature_type(floor_turf)
			// insert at the head of the list, so the most recent features get checked first
			feature_list.Insert(1, spawned_feature)
			floor_turf.turf_flags |= NO_LAVA_GEN_1

	//MOB SPAWNING HERE
	if(length(mob_spawn_list_expanded) && !spawned_flora && !spawned_feature && prob(mob_spawn_chance) && (a_flags & MOB_SPAWN_ALLOWED))
		var/atom/picked_mob = pick(mob_spawn_list_expanded)

		var/can_spawn = TRUE
		for(var/thing in mob_list)
			if(!ishostile(thing) && !istype(thing, /obj/abstract/map/spawner/mobs))
				continue
			// hostile mobs have a 12-tile keep-away square radius from everything
			if(get_dist(floor_turf, thing) <= 12 && (ishostile(thing) || ispath(picked_mob, /mob/living/simple_animal/hostile)))
				can_spawn = FALSE
				break
			// spawners have a 2-tile keep-away square radius from everything
			if(get_dist(floor_turf, thing) <= 2 && (istype(thing, /obj/abstract/map/spawner/mobs) || ispath(picked_mob, /obj/abstract/map/spawner/mobs)))
				can_spawn = FALSE
				break

		if(can_spawn)
			spawned_mob = new picked_mob(floor_turf)
			// insert at the head of the list, so the most recent mobs get checked first
			mob_list.Insert(1, spawned_mob)
			floor_turf.turf_flags |= NO_LAVA_GEN_1

	//LOOT SPAWNING HERE
	if(length(flora_spawn_list_expanded) && prob(flora_spawn_chance) && (a_flags & FLORA_ALLOWED))
		spawned_flora = pick(flora_spawn_list_expanded)
		spawned_flora = new spawned_flora(floor_turf)
		floor_turf.turf_flags |= NO_LAVA_GEN_1

/datum/biome/cave
	/// WEIGHTED list of closed turfs that this biome can place
	var/list/closed_turf_types =  list(/turf/unsimulated/mineral/cave = 1)
	/// EXPANDED (no values) list of closed turfs that this biome can place
	var/list/closed_turf_types_expanded

/datum/biome/cave/New()
	closed_turf_types_expanded = expand_weights(closed_turf_types)
	return ..()

/datum/biome/cave/get_turf_type(turf/gen_turf, string_gen)
	// gets the character in string_gen corresponding to gen_turf's coords. if it is nonzero,
	// place a closed turf; otherwise place an open turf
	return pick(text2num(string_gen[100 * (gen_turf.y - 1) + gen_turf.x]) ? closed_turf_types_expanded : open_turf_types_expanded)
