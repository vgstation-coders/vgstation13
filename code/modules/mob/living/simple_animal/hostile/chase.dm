// Chase movement for hostile mobs. A mob charges its target with a cheap step_to beeline, and only
// when that stops making progress does it path around the obstruction for a few steps before
// resuming the charge. hostile.dm holds just the hooks: Goto() to aim it, stop_chase() to end it.

/mob/living/simple_animal/hostile/var/use_jps_chase = TRUE //FALSE on special movers (wall-phasers, pure-space) to keep walk_to
/mob/living/simple_animal/hostile/var/atom/chase_target
/mob/living/simple_animal/hostile/var/chase_min = 0
/mob/living/simple_animal/hostile/var/chase_active_until = 0 //world.time deadline, refreshed by Goto
/mob/living/simple_animal/hostile/var/list/chase_path
/mob/living/simple_animal/hostile/var/atom/chase_path_target
/mob/living/simple_animal/hostile/var/turf/chase_path_goal
/mob/living/simple_animal/hostile/var/chase_stuck = 0
/mob/living/simple_animal/hostile/var/chase_walking = FALSE
/mob/living/simple_animal/hostile/var/chase_heartbeat = 0 //world.time of the loop's last step, so a dead loop can be spotted
/mob/living/simple_animal/hostile/var/chase_jps_steps = 0 //>0 = routing mode: follow the path this many more steps
/mob/living/simple_animal/hostile/var/chase_smashing = FALSE //current path routes through smashables

/// Target drift from the pathed tile before we recompute.
#define CHASE_REPLAN_DRIFT 2
/// Failed steps tolerated before abandoning a route.
#define CHASE_STUCK_LIMIT 3
/// Keepalive after the last Goto(). Must exceed the AI tick (SSmobs.wait = 2s).
#define CHASE_KEEPALIVE (3 SECONDS)
/// No-progress charge steps before we decide the beeline is blocked.
#define CHASE_CHARGE_PATIENCE 2
/// Steps of JPS routing followed before dropping back to charging.
#define CHASE_JPS_BURST 8
/// Smash only if the clean route exceeds this multiple of the direct distance.
#define CHASE_SMASH_DETOUR_FACTOR 3
/// A loop whose heartbeat is older than this is assumed dead (killed by a runtime) and may be restarted.
#define CHASE_LOOP_TIMEOUT(delay) max(5 SECONDS, (delay) * 3)
/// Ticks waited at a barrier being smashed before re-routing.
#define CHASE_SMASH_PATIENCE 40

// Points the step loop at a target and keeps it alive; the loop below does the walking.
/mob/living/simple_animal/hostile/proc/Goto(var/target, var/delay, var/minimum_distance)
	if(!use_jps_chase)
		start_walk_to(target, minimum_distance, delay)
		return
	if(!target)
		return
	walk(src, 0)
	if(delay > 0)
		set_glide_size(DELAY2GLIDESIZE(delay))
	chase_target = target
	chase_min = minimum_distance
	chase_active_until = world.time + CHASE_KEEPALIVE
	if(!chase_loop_running(max(delay, 1)))
		chase_step_loop(max(delay, 1))

/// Abandon the current chase.
/mob/living/simple_animal/hostile/proc/stop_chase()
	chase_target = null
	chase_path = null
	chase_smashing = FALSE

// Prefers a clean route; smashes through breakables only as a costly last resort.
/mob/living/simple_animal/hostile/proc/compute_chase_path(turf/goal)
	var/reach = vision_range * 3
	var/direct = get_dist(src, goal)
	var/stop_at = (chase_min > 1) ? chase_min : 0
	// Clean route only.
	var/list/clean = get_path_to(src, chase_target, max_distance = reach, mintargetdist = stop_at, simulated_only = FALSE, diagonally = TRUE, best_effort = FALSE)
	jps_chase_searches++
	if(length(clean) && length(clean) <= max(direct * CHASE_SMASH_DETOUR_FACTOR, direct + 4))
		chase_smashing = FALSE
		return clean
	// No clean route worth taking - smash through, if we can.
	if(environment_smash_flags & (SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS))
		var/list/smashed = get_path_to(src, chase_target, max_distance = reach, mintargetdist = stop_at, simulated_only = FALSE, diagonally = TRUE, best_effort = TRUE, smash_flags = environment_smash_flags)
		jps_chase_searches++
		if(length(smashed))
			chase_smashing = TRUE
			return smashed
	// Nothing decisive: long clean route, else get as close as we can.
	chase_smashing = FALSE
	if(length(clean))
		return clean
	return get_path_to(src, chase_target, max_distance = reach, mintargetdist = stop_at, simulated_only = FALSE, diagonally = TRUE, best_effort = TRUE)

/mob/living/simple_animal/hostile/proc/path_barrier()
	if(!chase_smashing || !length(chase_path))
		return null
	var/turf/here = get_turf(src)
	var/turf/next_step = chase_path[1]
	if(!here || !next_step)
		return null
	for(var/obj/O in here)
		if((O.flow_flags & ON_BORDER) && !O.CanPathPass(null, get_dir(here, next_step), src) && O.is_smashable_barrier(environment_smash_flags) && Adjacent(O))
			return O
	for(var/obj/O in next_step)
		if(!O.CanPathPass(null, get_dir(next_step, here), src) && O.is_smashable_barrier(environment_smash_flags) && Adjacent(O))
			return O
	return null

/mob/living/simple_animal/hostile/proc/step_diagonal(turf/next_step)
	var/turf/here = get_turf(src)
	var/heading = get_dir(here, next_step)
	if(!here || !(heading & (heading - 1)))
		return Move(next_step, heading)
	var/turf/vertical = get_step(here, heading & (NORTH|SOUTH))
	if(vertical && !vertical.density && !here.LinkBlockedWithAccess(vertical, src, null) && !vertical.LinkBlockedWithAccess(next_step, src, null))
		return Move(next_step, heading)
	var/turf/horizontal = get_step(here, heading & (EAST|WEST))
	if(horizontal && !horizontal.density && !here.LinkBlockedWithAccess(horizontal, src, null) && !horizontal.LinkBlockedWithAccess(next_step, src, null))
		if(Move(horizontal, heading & (EAST|WEST)))
			return Move(next_step, heading & (NORTH|SOUTH))
		return FALSE
	return Move(next_step, heading)

// Self-scheduling walker: charge by beeline, fall back to a short JPS burst when blocked.
// A runtime anywhere in the step loop kills the proc outright, so the `chase_walking = FALSE` at the
// end never runs. Without this check that mob would be latched as "already walking" and would never
// chase again. The loop stamps a heartbeat each step; a stale one means it died and can be restarted.
/mob/living/simple_animal/hostile/proc/chase_loop_running(delay)
	return chase_walking && (world.time - chase_heartbeat) <= CHASE_LOOP_TIMEOUT(delay)

/mob/living/simple_animal/hostile/proc/chase_step_loop(delay)
	set waitfor = FALSE
	if(chase_loop_running(delay))
		return
	chase_walking = TRUE
	while(!gcDestroyed && !stat && chase_target && world.time < chase_active_until)
		chase_heartbeat = world.time
		set_glide_size(DELAY2GLIDESIZE(delay))
		var/turf/goal = get_turf(chase_target)
		if(!goal)
			break

		if(get_dist(src, goal) <= chase_min)
			if(chase_min > 1 || chase_target.Adjacent(src))
				chase_stuck = 0
				chase_jps_steps = 0
				chase_path = null
				sleep(delay)
				continue
			if(chase_jps_steps <= 0)
				chase_jps_steps = CHASE_JPS_BURST
				chase_path = null

		if(chase_jps_steps > 0)
			// Routing mode.
			if(!length(chase_path) || chase_path_target != chase_target || (chase_path_goal && get_dist(chase_path_goal, goal) > CHASE_REPLAN_DRIFT))
				chase_path = compute_chase_path(goal)
				chase_path_target = chase_target
				chase_path_goal = goal
				if(length(chase_path))
					chase_jps_steps = max(chase_jps_steps, length(chase_path))
			if(!length(chase_path))
				chase_jps_steps = 0
			else
				var/turf/next_step = chase_path[1]
				var/turf/before_step = get_turf(src)
				step_diagonal(next_step)
				var/turf/after_step = get_turf(src)
				if(after_step == next_step)
					chase_path.Cut(1, 2)
					chase_jps_steps--
					chase_stuck = 0
				else if(after_step != before_step)
					chase_path = null
					chase_stuck = 0
				else
					chase_stuck++
					if(chase_stuck >= (chase_smashing ? CHASE_SMASH_PATIENCE : CHASE_STUCK_LIMIT))
						chase_path = null
						chase_jps_steps = 0
						chase_stuck = 0
		else
			// ---- CHARGE MODE: dumb, fast, cheap beeline straight at the target ----
			var/olddist = get_dist(src, goal)
			step_to(src, chase_target, chase_min, delay)
			var/newdist = get_dist(src, goal)
			if(newdist < olddist)
				chase_stuck = 0 // gaining ground - keep barreling
			else
				chase_stuck++
				if(chase_stuck >= CHASE_CHARGE_PATIENCE)
					// the beeline is stuck on geometry - switch to a JPS burst to get around it
					chase_jps_steps = CHASE_JPS_BURST
					chase_path = null
					chase_stuck = 0
		sleep(delay)
	chase_walking = FALSE

#undef CHASE_REPLAN_DRIFT
#undef CHASE_STUCK_LIMIT
#undef CHASE_KEEPALIVE
#undef CHASE_CHARGE_PATIENCE
#undef CHASE_JPS_BURST
#undef CHASE_SMASH_DETOUR_FACTOR
#undef CHASE_SMASH_PATIENCE
#undef CHASE_LOOP_TIMEOUT
