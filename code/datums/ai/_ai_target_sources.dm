// Target sources for the WIP behavior tree port.
//
// A target source splits "who could I attack" from "which one do I pick", so the
// acquire_target leaf stays generic and a mob only declares its priority by
// setting target_source_type (as a typepath or through a descriptor).
//
// Ported from the intent of tgstation's basic mob target sources; vg has no
// DCS signals, so sources are polled by the leaf each time it runs.

/datum/target_source

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

/datum/target_source/enemies/find_targets(datum/ai_controller/controller, mob/living/pawn, search_range)
	var/list/candidates = list()
	var/mob/living/simple_animal/hostile/hostile_pawn = istype(pawn, /mob/living/simple_animal/hostile) ? pawn : null
	for(var/atom/candidate in oview(search_range, pawn))
		if(candidate == pawn)
			continue
		if(isliving(candidate))
			var/mob/living/living_candidate = candidate
			// CanAttack() is vg's "would I attack this" contract: hostile mobs
			// override it with faction and stat_attack rules (embalmers and nurse
			// spiders target dead bodies), while the base simple_animal version
			// only allows targets already in crit. isValidTarget() holds the
			// per-mob filters (cultist hexes, poisonous animals, pacify auras).
			if(istype(pawn, /mob/living/simple_animal))
				var/mob/living/simple_animal/animal = pawn
				var/mob/living/simple_animal/hostile/hostile_animal = istype(pawn, /mob/living/simple_animal/hostile) ? pawn : null
				if(hostile_animal && !hostile_animal.isValidTarget(candidate))
					continue
				if(!animal.CanAttack(candidate))
					continue
			else if(living_candidate.stat == DEAD)
				continue
			candidates += candidate
			continue
		// Objects (lights, bots, mechas) only while the pawn still searches for
		// them; hostile/adjustBruteLoss drops search_objects when a mob fights back.
		if(hostile_pawn && hostile_pawn.search_objects && hostile_pawn.CanAttack(candidate))
			candidates += candidate
	return candidates

/datum/target_source/enemies/is_valid_target(datum/ai_controller/controller, mob/living/pawn, atom/existing)
	if(istype(pawn, /mob/living/simple_animal))
		var/mob/living/simple_animal/animal = pawn
		if(istype(pawn, /mob/living/simple_animal/hostile))
			var/mob/living/simple_animal/hostile/hostile_animal = pawn
			if(!hostile_animal.isValidTarget(existing))
				return FALSE
		return animal.CanAttack(existing)
	return TRUE

/// Like enemies, but prefers the candidate with the lowest health fraction so
/// pack hunters finish wounded prey instead of scattering damage.
/datum/target_source/enemies/wounded
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

/// Like enemies, but only once the mimic has been angered (opened, pulled or
/// hit). Keeps mimics disguised and passive until something disturbs them.
/datum/target_source/enemies/mimic

/datum/target_source/enemies/mimic/find_targets(datum/ai_controller/controller, mob/living/pawn, search_range)
	var/mob/living/simple_animal/hostile/mimic/mimic_pawn = pawn
	if(!istype(mimic_pawn) || !mimic_pawn.angry)
		return list()
	return ..()

/// Hunts a specific mob type (the cat's mice, future falconry, etc). Deliberately
/// does not use CanAttack(): a friendly mob still needs prey it is not allowed to
/// "attack". Only mobs standing on a turf are considered, so caged or held prey
/// is ignored like the legacy cat did.
/datum/target_source/prey
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

/// Snacks a pet wants to eat: loose snacks on a turf and snacks held by a human.
/// Only active while the pawn reports hunger through ai_wants_food().
/datum/target_source/food
	/// Include snacks held by humans (the corgi begs for those).
	var/include_held = TRUE

/datum/target_source/food/find_targets(datum/ai_controller/controller, mob/living/pawn, search_range)
	var/list/candidates = list()
	if(!pawn || !pawn.ai_wants_food())
		return candidates
	for(var/obj/item/weapon/reagent_containers/food/snacks/snack in view(search_range, pawn))
		if(isturf(snack.loc))
			candidates += snack
	if(include_held)
		for(var/mob/living/carbon/holder in view(search_range, pawn))
			for(var/obj/item/held in holder.held_items)
				if(istype(held, /obj/item/weapon/reagent_containers/food/snacks))
					candidates += held
	return candidates

/datum/target_source/food/is_valid_target(datum/ai_controller/controller, mob/living/pawn, atom/existing)
	return istype(existing, /obj/item/weapon/reagent_containers/food/snacks) && !QDELETED(existing)

/// Follows someone's point emote. The pointer target is picked and the pointing
/// mob is stored back on a corgi pawn so the reaction can tell friend from foe.
/datum/target_source/pointer
	/// Percent chance to actually react on a poll; the owner always gets through.
	var/follow_chance = 35
	/// target -> pointing mob for the candidates found this poll.
	var/list/callers = list()

/datum/target_source/pointer/find_targets(datum/ai_controller/controller, mob/living/pawn, search_range)
	callers = list()
	var/list/candidates = list()
	var/mob/living/simple_animal/corgi/corgi = istype(pawn, /mob/living/simple_animal/corgi) ? pawn : null
	for(var/obj/effect/decal/point/pointer in view(search_range, pawn))
		var/atom/pointer_target = pointer.target
		if(!pointer_target || pointer_target == pawn || QDELETED(pointer_target))
			continue
		if(callers[pointer_target])
			continue
		// The owner always gets the corgi's attention; strangers only sometimes.
		if(corgi && corgi.master && pointer.pointer != corgi.master && !prob(follow_chance))
			continue
		if(!corgi && !prob(follow_chance))
			continue
		callers[pointer_target] = pointer.pointer
		candidates += pointer_target
	return candidates

/datum/target_source/pointer/pick_target(datum/ai_controller/controller, mob/living/pawn, list/candidates)
	var/atom/best = ..()
	if(best)
		var/mob/living/simple_animal/corgi/corgi = istype(pawn, /mob/living/simple_animal/corgi) ? pawn : null
		if(corgi)
			corgi.pointer_caller = callers[best]
	return best

/// Chewable cables for wire-chewing mice. Gated by a per-poll chance so the mouse
/// does not spend every tick hunting cables.
/datum/target_source/wires
	/// Percent chance a poll yields any cable at all.
	var/chew_chance = 10

/datum/target_source/wires/find_targets(datum/ai_controller/controller, mob/living/pawn, search_range)
	var/list/candidates = list()
	var/mob/living/simple_animal/mouse/mouse = istype(pawn, /mob/living/simple_animal/mouse) ? pawn : null
	if(mouse && !mouse.can_chew_wires)
		return candidates
	if(!prob(chew_chance))
		return candidates
	for(var/obj/structure/cable/wire in view(search_range, pawn))
		candidates += wire
	return candidates

/datum/target_source/wires/is_valid_target(datum/ai_controller/controller, mob/living/pawn, atom/existing)
	return istype(existing, /obj/structure/cable) && !QDELETED(existing)
