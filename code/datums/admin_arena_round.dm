// A single 1v1 tournament round inside the admin arena.

// Starting a round doesn't immediately teleport them into the arena. Instead, COPIES
// of their bodies are teleported to a prep room.

// Only one arena is supported at a time right now, so only one round
var/global/datum/admin_arena_round/current_admin_arena_round



/datum/admin_arena_round
	var/list/datum/admin_arena_contestant/contestants = list()
	// Creation of this datum implies the teleportation of contestants into their prep rooms.
	var/in_arena = FALSE		// TRUE once the contestants have been moved out of their prep rooms into the arena
	var/combat_started = FALSE	// TRUE once the combat has started and barriers lifted
	var/finished = FALSE		// TRUE once someone dies in combat

/datum/admin_arena_round/New(client/red_client, turf/red_prep_turf, client/green_client, turf/green_prep_turf)
	src.contestants += new /datum/admin_arena_contestant(red_client, red_prep_turf, /datum/outfit/special/robust_tournament_red)
	src.contestants += new /datum/admin_arena_contestant(green_client, green_prep_turf, /datum/outfit/special/robust_tournament_green)

/datum/admin_arena_round/Destroy()
	QDEL_LIST_NULL(src.contestants)
	if(current_admin_arena_round == src)
		current_admin_arena_round = null
	return ..()

// Builds a "CKEY:CLIENT" map for all possible candidates. Candidates must have a body that can be found in the body archive.
/proc/get_arena_contestant_candidates()
	var/list/candidates = list()
	for(var/client/C in clients)
		if(!C.mob || !C.mob.mind || !C.mob.mind.body_archive)
			continue
		var/display_name = C.mob.real_name ? C.mob.real_name : C.mob.name
		candidates["[display_name] ([C.ckey])"] = C
	return candidates

/datum/admin_arena_round/proc/get_contestant_by_body(mob/body)
	for(var/datum/admin_arena_contestant/C in src.contestants)
		if(C.arena_body == body)
			return C
	return null

/datum/admin_arena_round/proc/announce(message)
	to_chat(world, "<font size='12' color='red'><b>[message]</b></font>")



// Telports fighting bodies to the arena. Returns whether it was successful; should always be unless something got deleted.
/datum/admin_arena_round/proc/send_contestants_to_arena()
	if(!current_admin_arena || src.contestants.len < 2)
		return FALSE
	var/obj/effect/admin_arena_spawn/spawn_one = current_admin_arena.find_spawn_marker(/obj/effect/admin_arena_spawn/one)
	var/obj/effect/admin_arena_spawn/spawn_two = current_admin_arena.find_spawn_marker(/obj/effect/admin_arena_spawn/two)
	if(!spawn_one || !spawn_two)
		return FALSE
	var/datum/admin_arena_contestant/red = src.contestants[1]
	var/datum/admin_arena_contestant/green = src.contestants[2]
	red.send_to_arena(get_turf(spawn_one))
	green.send_to_arena(get_turf(spawn_two))
	src.in_arena = TRUE
	return TRUE

// Server-wide countdown, then drops barrier and listens for deaths.
/datum/admin_arena_round/proc/begin_combat()
	set waitfor = FALSE
	if(src.combat_started || src.finished)
		return
	src.combat_started = TRUE
	world << sound('sound/effects/three two one go.mp3')
	sleep(0.5 SECONDS)
	src.announce("Three...")
	sleep(1 SECONDS)
	src.announce("Two...")
	sleep(1 SECONDS)
	src.announce("One...")
	sleep(1 SECONDS)
	if(!src.in_arena || !src.combat_started || src.finished)
		src.announce("Nevermind!")
		return
	src.announce("Go!")
	src.delete_barriers()
	src.begin_life_tracking()

/datum/admin_arena_round/proc/delete_barriers()
	if(!current_admin_arena)
		return
	for(var/turf/T in current_admin_arena.get_arena_turfs())
		for(var/obj/effect/admin_arena_barrier/barrier in T)
			qdel(barrier)

/datum/admin_arena_round/proc/begin_life_tracking()
	for(var/datum/admin_arena_contestant/C in src.contestants)
		if(C.arena_body)
			C.arena_body.register_event(/event/death, src, nameof(src::on_contestant_death()))

/datum/admin_arena_round/proc/stop_life_tracking()
	for(var/datum/admin_arena_contestant/C in src.contestants)
		if(!C.arena_body)
			continue
		C.arena_body.unregister_event(/event/death, src, nameof(src::on_contestant_death()))

/datum/admin_arena_round/proc/on_contestant_death(mob/user, body_destroyed)
	if(src.finished)
		return
	var/datum/admin_arena_contestant/loser = src.get_contestant_by_body(user)
	if(loser)
		src.end_combat(loser)

// Ends combat, but not the round. Ending/deleting the round is done manually.
/datum/admin_arena_round/proc/end_combat(datum/admin_arena_contestant/loser)
	if(src.finished)
		return
	src.finished = TRUE
	src.stop_life_tracking()
	var/datum/admin_arena_contestant/winner
	for(var/datum/admin_arena_contestant/C in src.contestants)
		if(C != loser)
			winner = C
			break
	src.announce("[winner.display_name] is your victor!")

// Immediately sends the contestants back to prep room, ready for more combat.
/datum/admin_arena_round/proc/reset_round()
	src.stop_life_tracking()
	for(var/datum/admin_arena_contestant/C in src.contestants)
		C.reset_to_prep_room()
	src.in_arena = FALSE
	src.combat_started = FALSE
	src.finished = FALSE

// Ends the round immediately, returning everyone to their original bodies and deletes this round datum.
/datum/admin_arena_round/proc/end_round()
	src.finished = TRUE
	src.stop_life_tracking()
	for(var/datum/admin_arena_contestant/C in src.contestants)
		C.restore_original_body()
	qdel(src)




/datum/admin_arena_contestant
	var/ckey
	var/display_name
	var/datum/mind/mind
	var/mob/original_body		// Real body, parked in nullspace until round is over
	var/turf/original_location	// Location to return real body to after round
	var/mob/arena_body			// Body copy that actually fights
	var/turf/prep_turf			// Prep room turf to (re)spawn the arena body at
	var/datum/outfit/outfit_type				// Team outfit to equip the arena body with

/datum/admin_arena_contestant/New(client/player, turf/destination, datum/outfit/outfit_type)
	src.ckey = player.ckey
	src.display_name = player.mob.real_name ? player.mob.real_name : player.mob.name
	src.mind = player.mob.mind
	src.original_body = src.mind.current
	src.prep_turf = destination
	src.outfit_type = outfit_type
	src.enter_prep_room()

/datum/admin_arena_contestant/Destroy()
	src.mind = null
	src.original_body = null
	src.original_location = null
	src.arena_body = null
	src.prep_turf = null
	return ..()

/datum/admin_arena_contestant/proc/enter_prep_room()
	var/datum/body_archive/archive = src.mind.body_archive
	if(!archive)
		log_admin("Admin Arena: [src.ckey] had no body archive. The round should be ended.")
		message_admins("Admin Arena: [src.ckey] had no body archive. You should end the round, things will break if you continue.")
		return FALSE
	src.stash_original_body()
	src.arena_body = src.spawn_arena_body(src.prep_turf, archive)
	src.equip_arena_outfit()
	return TRUE

// Moves OG body to nullspace and stores where it was moved from
/datum/admin_arena_contestant/proc/stash_original_body()
	src.original_location = get_turf(src.original_body)
	src.original_body.forceMove(null)

/datum/admin_arena_contestant/proc/restore_original_body()
	if(!QDELETED(src.original_body))
		if(src.original_location)
			src.original_body.forceMove(src.original_location)
		if(src.mind)
			// Usually redundant given the ckey transfer but let's do it anyways
			src.mind.transfer_to(src.original_body)
		if(src.ckey && src.original_body.ckey != src.ckey)
			src.original_body.ckey = src.ckey
	if(src.arena_body)
		qdel(src.arena_body)
		src.arena_body = null

// Uses body archive to spawn a temporary body for the fight.
/datum/admin_arena_contestant/proc/spawn_arena_body(turf/destination, datum/body_archive/archive)
	// Might be a better way than creating a temp mob to do this.
	var/mob/temp_mob = new archive.mob_type(destination)
	var/mob/copy = temp_mob.actually_reset_body(archive, FALSE, FALSE, null, src.mind)
	qdel(temp_mob)
	return copy

/datum/admin_arena_contestant/proc/equip_arena_outfit()
	if(!ishuman(src.arena_body))
		return
	var/datum/outfit/team_outfit = new src.outfit_type
	team_outfit.equip(src.arena_body, TRUE)

/datum/admin_arena_contestant/proc/send_to_arena(turf/destination)
	if(!src.arena_body || !destination)
		return
	src.arena_body.forceMove(destination)

/datum/admin_arena_contestant/proc/reset_to_prep_room()
	var/datum/body_archive/archive = src.mind.body_archive
	if(!archive)
		return FALSE
	var/mob/old_body = src.arena_body
	src.arena_body = src.spawn_arena_body(src.prep_turf, archive)
	src.equip_arena_outfit()
	if(old_body)
		qdel(old_body)
	return TRUE


