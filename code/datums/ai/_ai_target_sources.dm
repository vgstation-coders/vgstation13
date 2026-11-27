// Target sources for the WIP behavior tree port.
//
// A target source splits "who could I attack" from "which one do I pick", so the
// acquire_target leaf stays generic and a mob only declares its priority by
// setting target_source_type (as a typepath or through a descriptor).
//
// Ported from the intent of tgstation's basic mob target sources; vg has no
// DCS signals, so sources are polled by the leaf each time it runs.

/datum/target_source
	var/name = "target source"

/// Returns every candidate this source considers valid right now.
/datum/target_source/proc/find_targets(datum/ai_controller/controller, mob/living/pawn, search_range)
	return list()

/// Picks one candidate from find_targets(); null means "nothing worth chasing".
/// Defaults to the closest candidate.
/datum/target_source/proc/pick_target(datum/ai_controller/controller, mob/living/pawn, list/candidates)
	var/atom/best = null
	var/best_distance = INFINITY
	for(var/atom/candidate in candidates)
		var/distance = get_dist(pawn, candidate)
		if(distance < best_distance)
			best_distance = distance
			best = candidate
	return best

/// Applies descriptor config to the source (same convention as bt_node).
/datum/target_source/proc/configure(list/config)
	for(var/key in config)
		vars[key] = config[key]

/// Returns TRUE while this source still considers the stored target valid.
/datum/target_source/proc/is_valid_target(datum/ai_controller/controller, mob/living/pawn, atom/existing)
	return TRUE

/// Living mobs the pawn is able to attack. Picks the closest one, matching the
/// distance rule of the legacy hostile target selection.
/datum/target_source/enemies
	name = "enemies"

/datum/target_source/enemies/find_targets(datum/ai_controller/controller, mob/living/pawn, search_range)
	var/list/candidates = list()
	for(var/mob/living/candidate in oview(search_range, pawn))
		if(candidate == pawn || candidate.stat == DEAD)
			continue
		if(istype(pawn, /mob/living/simple_animal))
			var/mob/living/simple_animal/animal = pawn
			// CanAttack() is vg's "would I attack this" contract: hostile mobs
			// override it with faction rules, while the base simple_animal
			// version only allows targets already in crit.
			if(!animal.CanAttack(candidate))
				continue
		candidates += candidate
	return candidates

/datum/target_source/enemies/is_valid_target(datum/ai_controller/controller, mob/living/pawn, atom/existing)
	if(istype(pawn, /mob/living/simple_animal))
		var/mob/living/simple_animal/animal = pawn
		return animal.CanAttack(existing)
	return TRUE

/// Like enemies, but prefers the candidate with the lowest health fraction so
/// pack hunters finish wounded prey instead of scattering damage.
/datum/target_source/enemies/wounded
	name = "wounded enemies"
/datum/target_source/enemies/wounded/pick_target(datum/ai_controller/controller, mob/living/pawn, list/candidates)
	var/mob/living/best = null
	var/best_fraction = INFINITY
	for(var/mob/living/candidate in candidates)
		var/fraction = candidate.maxHealth > 0 ? candidate.health / candidate.maxHealth : 1
		if(fraction < best_fraction)
			best_fraction = fraction
			best = candidate
	return best

/// Only fights mobs the pawn already considers enemies. The legacy
/// /hostile/retaliate base keeps that list ("enemies") and fills it on damage;
/// a behavior-tree retaliator shares the same list, so it stays passive until
/// something attacks it.
/datum/target_source/enemies/retaliate
	name = "retaliating enemies"

/datum/target_source/enemies/retaliate/find_targets(datum/ai_controller/controller, mob/living/pawn, search_range)
	var/list/candidates = ..()
	if(!length(candidates))
		return candidates

	var/mob/living/simple_animal/hostile/retaliate/retaliator = pawn
	if(!istype(retaliator))
		return list()
	if(!length(retaliator.enemies))
		return list()

	for(var/candidate in candidates.Copy())
		if(!(candidate in retaliator.enemies))
			candidates -= candidate
	return candidates

/// Hunts a specific mob type (the cat's mice, future falconry, etc). Deliberately
/// does not use CanAttack(): a friendly mob still needs prey it is not allowed to
/// "attack". Only mobs standing on a turf are considered, so caged or held prey
/// is ignored like the legacy cat did.
/datum/target_source/prey
	name = "prey"
	/// Typepath every candidate must match.
	var/prey_type = null

/datum/target_source/prey/find_targets(datum/ai_controller/controller, mob/living/pawn, search_range)
	var/list/candidates = list()
	for(var/mob/living/candidate in oview(search_range, pawn))
		if(candidate == pawn || candidate.stat == DEAD)
			continue
		if(!isturf(candidate.loc))
			continue
		if(prey_type && !istype(candidate, prey_type))
			continue
		candidates += candidate
	return candidates

/datum/target_source/prey/is_valid_target(datum/ai_controller/controller, mob/living/pawn, atom/existing)
	if(prey_type && !istype(existing, prey_type))
		return FALSE
	return TRUE
