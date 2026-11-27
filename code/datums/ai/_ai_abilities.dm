// AI abilities for the WIP behavior tree port.
//
// An ability is a reusable action a tree can trigger through the use_ability
// leaf, keeping the decision tree free of mob-specific combat code. Abilities
// own their own cooldown and must not sleep; anything slower belongs in a
// behavior leaf with AI_BEHAVIOR_DELAY.

/datum/ai_ability
	var/name = "ability"
	/// Deciseconds between uses. 0 means every tick is allowed.
	var/cooldown = 0
	/// world.time before which can_use() returns FALSE.
	var/next_use_time = 0

/// Returns TRUE when the ability is ready for this controller.
/datum/ai_ability/proc/can_use(datum/ai_controller/controller)
	return world.time >= next_use_time

/// Runs the ability against target. Returns AI_BEHAVIOR_* flags.
/datum/ai_ability/proc/perform(datum/ai_controller/controller, atom/target)
	SHOULD_NOT_SLEEP(TRUE)
	return AI_BEHAVIOR_FAILED

/// Starts the ability cooldown; called by the leaf on success.
/datum/ai_ability/proc/start_cooldown(datum/ai_controller/controller)
	if(cooldown > 0)
		next_use_time = world.time + cooldown

/// Fires the pawn's legacy ranged attack (hostile projectiletype/ranged_mode).
/// The mob keeps its own ranged_cooldown, so the ability respects both timers.
/datum/ai_ability/ranged_attack
	name = "ranged attack"
	cooldown = 3 SECONDS

/datum/ai_ability/ranged_attack/can_use(datum/ai_controller/controller)
	if(!..())
		return FALSE
	var/mob/living/simple_animal/hostile/hostile = controller.pawn
	// projectiletype is optional: mobs like the mummy priests override Shoot()
	// with a spell instead of firing a projectile.
	if(!istype(hostile) || !hostile.ranged_mode())
		return FALSE
	return hostile.ranged_cooldown <= 0

/datum/ai_ability/ranged_attack/perform(datum/ai_controller/controller, atom/target)
	var/mob/living/simple_animal/hostile/hostile = controller.pawn
	if(!target || QDELETED(target) || !hostile || QDELETED(hostile))
		return AI_BEHAVIOR_FAILED
	// Some legacy Shoot() overrides (mummy priests, jackal firebreathers) ignore
	// their arguments and read src.target. Point it at the blackboard target for
	// the shot; the legacy Life() GiveTarget(null) clears it again on its next
	// idle tick, which also keeps rapid multi-shot spawns working.
	hostile.target = target
	hostile.OpenFire(target)
	return AI_BEHAVIOR_SUCCEEDED

/// Closes the distance to the target by up to two tiles in one use.
/datum/ai_ability/charge
	name = "charge"
	cooldown = 2 SECONDS

/datum/ai_ability/charge/perform(datum/ai_controller/controller, atom/target)
	var/mob/living/pawn = controller.pawn
	if(!target || QDELETED(target) || !pawn || QDELETED(pawn))
		return AI_BEHAVIOR_FAILED

	var/turf/next_step = get_step_towards(pawn, target)
	if(!next_step || !pawn.Move(next_step))
		return AI_BEHAVIOR_FAILED

	next_step = get_step_towards(pawn, target)
	if(next_step)
		pawn.Move(next_step)
	return AI_BEHAVIOR_SUCCEEDED
