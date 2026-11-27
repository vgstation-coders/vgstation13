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
/datum/target_source/proc/pick_target(datum/ai_controller/controller, mob/living/pawn, list/candidates)
	if(!length(candidates))
		return null
	return candidates[1]

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

/datum/target_source/enemies/pick_target(datum/ai_controller/controller, mob/living/pawn, list/candidates)
	var/atom/best = null
	var/best_distance = INFINITY
	for(var/atom/candidate in candidates)
		var/distance = get_dist(pawn, candidate)
		if(distance < best_distance)
			best_distance = distance
			best = candidate
	return best

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
