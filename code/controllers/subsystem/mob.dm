var/datum/subsystem/mob/SSmob


/datum/subsystem/mob
	name          = "Mob"
	wait          = 2 SECONDS
	flags         = SS_NO_INIT | SS_KEEP_TIMING
	priority      = SS_PRIORITY_MOB
	display_order = SS_DISPLAY_MOB

	var/list/currentrun
	var/list/paused_z = list()
	var/paused = 0 // Count of mobs skipped due to empty z/planet mob pausing


/datum/subsystem/mob/New()
	NEW_SS_GLOBAL(SSmob)

/datum/subsystem/mob/stat_entry()
	..("Processing:[mob_list.len - paused] | Paused:[paused]")

/// Called at roundstart to initialize z-level pause states based on player presence
/datum/subsystem/mob/proc/initialize_z_pause()
	for(var/datum/zLevel/level in map.zLevels)
		if(!level)
			continue
		var/list/players = mobs_in_zlevel(level.z, client_needed = TRUE)
		paused_z[level] = !length(players)

/datum/subsystem/mob/proc/z_pause_check(mob/living/user, to_z, from_z)
	if(!istype(user) || !user.client)
		return

	// Mark the new z-level as having players
	if(to_z)
		var/datum/zLevel/new_level = map.zLevels[to_z]
		paused_z[new_level] = FALSE

	// Check if the old z-level still has any players
	if(from_z)
		var/list/players = mobs_in_zlevel(from_z, client_needed = TRUE)
		if(!length(players))
			var/datum/zLevel/oldlevel = map.zLevels[from_z]
			paused_z[oldlevel] = TRUE

/datum/subsystem/mob/fire(resumed = FALSE)
	if (!resumed)
		currentrun = mob_list.Copy()
		paused = 0

	if(!paused_z.len)
		for(var/datum/zLevel/Z in map.zLevels)
			paused_z += list(Z = TRUE)

	while (currentrun.len)
		var/mob/M = currentrun[currentrun.len]
		currentrun.len--

		if (!M || M.gcDestroyed || M.timestopped)
			continue

		// Skip processing non-player mobs on paused z-levels or planets
		if (!M.client && istype(M, /mob/living))
			var/z_to_check
			var/mob/living/L = M
			if(!L.z)
				var/turf/T = get_turf(L)
				if(!T || !T.z)
					qdel(L) // Hiding in nullspace
					continue
				else
					z_to_check = T.z
			else
				z_to_check = L.z
			var/datum/zLevel/level = map.zLevels[z_to_check]
			if (paused_z[level])
				paused++
				continue
			else if (L.planet)
				if (!L.planet.process_mobs)
					paused++
					continue

		M.Life()

		if (MC_TICK_CHECK)
			return
