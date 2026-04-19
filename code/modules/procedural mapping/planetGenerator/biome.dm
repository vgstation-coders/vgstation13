/// Minimum distance between features of the same type (square radius)
#define FEATURE_SPAWN_DISTANCE 7
/// Minimum distance between hostile mobs and spawners (square radius)
#define HOSTILE_MOB_SPAWN_DISTANCE 12
/// Minimum distance between mob spawners (square radius)
#define SPAWNER_SPAWN_DISTANCE 2

/**
 * Biome datum for procedural planet generation
 *
 * Defines the types of turfs, flora, features, and mobs that can spawn in a given biome,
 * along with their spawn chances and distribution rules.
 */
/datum/biome
	/// WEIGHTED list of open turfs that this biome can place
	var/list/open_turf_types = list(/turf/unsimulated/floor/planetary/cave = 1)
	/// EXPANDED (no values) list of open turfs that this biome can place
	var/list/open_turf_types_expanded
	/// WEIGHTED list of flora that this biome can spawn. Flora do not have any local keep-away logic; all spawns are independent.
	var/list/flora_spawn_list
	/// EXPANDED (no values) list of flora that this biome can spawn
	var/list/flora_spawn_list_expanded
	/// WEIGHTED list of features that this biome can spawn. Features will not spawn within [FEATURE_SPAWN_DISTANCE] tiles of other features of the same type.
	var/list/feature_spawn_list
	/// EXPANDED (no values) list of features that this biome can spawn
	var/list/feature_spawn_list_expanded
	/// WEIGHTED list of mobs that this biome can spawn. Mobs have multi-layered logic for determining if they can be spawned on a given tile. Mob spawners should go HERE, not in features, despite them not being mobs.
	var/list/mob_spawn_list
	/// EXPANDED (no values) list of mobs that this biome can spawn
	var/list/mob_spawn_list_expanded
	// Loot tables that can spawn in this biome
	var/list/loot_spawners

	/// Percentage chance that an open turf will attempt a flora spawn
	var/flora_spawn_chance = 2
	/// Base percentage chance that an open turf will attempt a feature spawn
	var/feature_spawn_chance = 1
	/// Base percentage chance that an open turf will attempt a mob spawn
	var/mob_spawn_chance = 6
	/// Base percentage chance that an open turf will attempt a loot spawn
	var/loot_spawn_chance = 1
	// Biome temperature
	var/biome_temperature = T20C

/**
 * Initializes the biome by expanding all weighted spawn lists
 *
 * Called on datum creation to convert weighted lists into expanded lists for efficient random selection.
 */
/datum/biome/New()
	open_turf_types_expanded = expand_weights(open_turf_types)
	if(length(flora_spawn_list))
		flora_spawn_list_expanded = expand_weights(flora_spawn_list)
	if(length(feature_spawn_list))
		feature_spawn_list_expanded = expand_weights(feature_spawn_list)
	if(length(mob_spawn_list))
		mob_spawn_list_expanded = expand_weights(mob_spawn_list)

/**
 * Changes the passed turf according to the biome's internal logic and adds it to the passed area
 *
 * Reassigns the turf to a new area, determines the appropriate turf type, and performs the turf change
 * while preserving certain flags like NO_RUINS.
 * Arguments:
 * * gen_turf - The turf to generate
 * * new_area - The area to assign the turf to
 * * cave_data - Optional list of numeric cave automaton data (0 = open, 1 = closed)
 */
/datum/biome/proc/generate_turf(turf/gen_turf, area/new_area, list/cave_data, size, x_offset = 0, y_offset = 0)
	var/area/current_area = gen_turf.loc
	if(!(current_area.flags & CAVES_ALLOWED))
		return FALSE

	// Reassign turf to new area (skip change_area — it only does name replacetext,
	// which is pointless since ChangeTurfPlanetGen creates a new turf instance)
	new_area.contents += gen_turf

	// Preserve NO_RUINS flag through turf change
	var/stored_flags = gen_turf.turf_flags & NO_RUINS
	var/turf/new_turf_type = get_turf_type(gen_turf, cave_data, size, x_offset, y_offset)
	var/turf/new_turf = gen_turf.ChangeTurfPlanetGen(new_turf_type)
	if(!new_turf)
		return FALSE
	// Restore the preserved flag
	new_turf.turf_flags |= stored_flags
	new_turf.oxygen = MOLES_O2STANDARD
	new_turf.nitrogen = MOLES_N2STANDARD
	new_turf.temperature = biome_temperature
	return TRUE

/**
 * Returns a turf type to use for generation
 *
 * Base implementation simply picks from the biome's open turf types. Override in subtypes for custom logic.
 * Arguments:
 * * gen_turf - The turf being generated
 * * cave_data - Optional list of numeric cave automaton data
 */
/datum/biome/proc/get_turf_type(turf/gen_turf, list/cave_data, size, x_offset = 0, y_offset = 0)
	return pick(open_turf_types_expanded)

/**
 * Checks if a turf is eligible for population with flora, features, and mobs
 *
 * Arguments:
 * * gen_turf - The turf to check
 */
/datum/biome/proc/can_populate_turf(turf/gen_turf)
	return !iswall(gen_turf) && !istype(gen_turf, /turf/unsimulated/mineral)

/**
 * Attempts to spawn flora on the given turf
 *
 * Arguments:
 * * floor_turf - The floor turf to spawn flora on
 * * area_flags - The flags from the turf's area
 * * ignore_no_flora_flag - If TRUE, ignores the NO_FLORA turf flag
 */
/datum/biome/proc/try_spawn_flora(turf/simulated/floor/floor_turf, area_flags, ignore_no_flora_flag = FALSE)
	if(!length(flora_spawn_list_expanded))
		return null
	if(!prob(flora_spawn_chance))
		return null
	if(!(area_flags & FLORA_ALLOWED))
		return null
	if(!ignore_no_flora_flag && (floor_turf.turf_flags & NO_FLORA))
		return null

	var/atom/flora_type = pick(flora_spawn_list_expanded)
	var/atom/spawned = new flora_type(floor_turf)
	floor_turf.turf_flags |= NO_LAVA_GEN
	spawned.planet = floor_turf.planet
	return spawned

/**
 * Attempts to spawn a feature on the given turf
 *
 * Features use distance checking to prevent spawning too close to other features of the same type.
 * Arguments:
 * * floor_turf - The floor turf to spawn the feature on
 * * area_flags - The flags from the turf's area
 * * feature_list - List of existing features (for distance checking)
 */
/datum/biome/proc/try_spawn_feature(turf/simulated/floor/floor_turf, area_flags, list/feature_list)
	if(!length(feature_spawn_list_expanded))
		return null
	if(!prob(feature_spawn_chance))
		return null
	if(!(area_flags & FLORA_ALLOWED)) // Uses FLORA_ALLOWED flag
		return null

	var/atom/feature_type = pick(feature_spawn_list_expanded)

	if(SSmapping.generating)
		if(!SSmapping.can_spawn_feature_at(floor_turf.x, floor_turf.y, feature_type))
			return null
		var/atom/spawned = new feature_type(floor_turf)
		SSmapping.add_feature_to_bucket(spawned)
		floor_turf.turf_flags |= NO_LAVA_GEN
		spawned.planet = floor_turf.planet
		return spawned

/datum/biome/proc/spawn_loot(turf/simulated/floor/floor_turf, area_flags)
	return

/datum/biome/cave/spawn_loot(turf/simulated/floor/floor_turf, area_flags)
	if(!length(loot_spawners))
		return null
	if(!prob(loot_spawn_chance))
		return null
	if(floor_turf.turf_flags & NO_LOOT)
		return null
	if(!(area_flags & FLORA_ALLOWED)) // Uses FLORA_ALLOWED flag
		return null

	var/spawner_type = pickweight(loot_spawners)
	var/obj/abstract/loot_spawner/spawned = new spawner_type(floor_turf, cave = TRUE)
	floor_turf.turf_flags |= NO_LAVA_GEN
	spawned.planet = floor_turf.planet
	return spawned

/**
 * Attempts to spawn a mob on the given turf
 *
 * Mobs use complex distance checking to prevent spawning too close to other mobs or spawners.
 * Arguments:
 * * floor_turf - The floor turf to spawn the mob on
 * * area_flags - The flags from the turf's area
 * * mob_list - List of existing mobs (for distance checking)
 * * planet_faction - Optional faction to assign to spawned mobs
 */
/datum/biome/proc/try_spawn_mob(turf/simulated/floor/floor_turf, area_flags, list/mob_list, planet_faction = null)
	if(!length(mob_spawn_list_expanded))
		return null
	if(!prob(mob_spawn_chance))
		return null
	if(!(area_flags & MOB_SPAWN_ALLOWED))
		return null

	var/atom/picked_mob = pick(mob_spawn_list_expanded)

	if(SSmapping.generating)
		if(!SSmapping.can_spawn_mob_at(floor_turf.x, floor_turf.y, picked_mob))
			return null
		var/atom/spawned = new picked_mob(floor_turf)
		if(planet_faction && ismob(spawned))
			var/mob/M = spawned
			M.faction = planet_faction
		SSmapping.add_mob_to_bucket(spawned)
		floor_turf.turf_flags |= NO_LAVA_GEN
		spawned.planet = floor_turf.planet
		return spawned

/**
 * Fills a turf with flora, features, and creatures based on the biome's variables
 *
 * The features and creatures compare against and add to the lists passed to determine
 * if they can spawn at the tested turf. This method of checking reduces the amount of
 * time spent populating a planet.
 * Arguments:
 * * gen_turf - The turf to populate
 * * feature_list - List of existing features (used for distance checking)
 * * mob_list - List of existing mobs (used for distance checking)
 * * loot_to_spawn - Optional loot table datum (currently unused)
 * * planet_faction - Optional faction to assign to spawned mobs
 */
/datum/biome/proc/populate_turf(turf/gen_turf, list/feature_list, list/mob_list, var/datum/loot_table/loot_to_spawn, planet_faction = null)
	if(!can_populate_turf(gen_turf))
		return

	var/turf/simulated/floor/floor_turf = gen_turf
	var/area/current_area = floor_turf.loc
	var/area_flags = current_area.flags

	// Ruins should set this on all areas they don't want to be filled with mobs and decorations
	if(!(area_flags & CAVES_ALLOWED))
		return

	var/atom/spawned_flora
	var/atom/spawned_feature
	var/atom/spawned_mob
	var/atom/spawned_loot

	// First loot spawn attempt
	spawned_loot = spawn_loot(floor_turf, area_flags)

	// Flora & Feature spawning (only if no loot was spawned)
	if(!spawned_loot)
		spawned_flora = try_spawn_flora(floor_turf, area_flags)
		spawned_feature = try_spawn_feature(floor_turf, area_flags, feature_list)

	// Mob spawning (only if no flora, feature, or loot was spawned)
	if(!spawned_flora && !spawned_feature && !spawned_loot)
		spawned_mob = try_spawn_mob(floor_turf, area_flags, mob_list, planet_faction)

	// Second flora spawn attempt
	if(!spawned_mob && !spawned_loot)
		spawned_flora = try_spawn_flora(floor_turf, area_flags)

/**
 * Cave biome subtype
 *
 * Extends the base biome with support for closed turfs (walls), allowing generation of cave-like structures
 * using string generation data to determine open vs closed turf placement.
 */
/datum/biome/cave
	/// WEIGHTED list of closed turfs that this biome can place
	var/list/closed_turf_types = list(/turf/unsimulated/mineral/cave = 1)
	/// EXPANDED (no values) list of closed turfs that this biome can place
	var/list/closed_turf_types_expanded
	loot_spawn_chance = 2
	loot_spawners = list(
		/obj/abstract/loot_spawner/medical = 2,
		/obj/abstract/loot_spawner/combat = 1,
		/obj/abstract/loot_spawner/engineering = 2,
		/obj/abstract/loot_spawner/module = 1,
		/obj/abstract/loot_spawner/structure = 2,
	)

/**
 * Initializes the cave biome by expanding weighted lists for both open and closed turfs
 */
/datum/biome/cave/New()
	closed_turf_types_expanded = expand_weights(closed_turf_types)
	return ..()

/**
 * Returns a turf type based on cave automaton data
 *
 * Uses the cave_data value at the turf's coordinates to determine if a closed or open turf should be placed.
 * Arguments:
 * * gen_turf - The turf being generated
 * * cave_data - List of numeric cave automaton data (0 = open, 1 = closed)
 */
/datum/biome/cave/get_turf_type(turf/gen_turf, list/cave_data, size, x_offset = 0, y_offset = 0)
	// Look up the cave automaton value at gen_turf's coords. If nonzero,
	// place a closed turf; otherwise place an open turf
	if(!size || !length(cave_data))
		return pick(open_turf_types_expanded)
	// Calculate relative coordinates within the virtual_z
	var/rel_x = clamp(gen_turf.x - x_offset + 1, 1, size)
	var/rel_y = clamp(gen_turf.y - y_offset + 1, 1, size)
	var/list_index = size * (rel_y - 1) + rel_x
	if(list_index < 1 || list_index > length(cave_data))
		return pick(open_turf_types_expanded)
	return pick(cave_data[list_index] ? closed_turf_types_expanded : open_turf_types_expanded)


#undef FEATURE_SPAWN_DISTANCE
#undef HOSTILE_MOB_SPAWN_DISTANCE
#undef SPAWNER_SPAWN_DISTANCE
