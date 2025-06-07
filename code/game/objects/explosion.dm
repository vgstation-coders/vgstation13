//TODO: Flash range does nothing currently

/proc/trange(var/Dist = 0, var/turf/Center = null)//alternative to range (ONLY processes turfs and thus less intensive)
	if (isnull(Center))
		return

	//var/x1 = ((Center.x-Dist) < 1 ? 1 : Center.x - Dist)
	//var/y1 = ((Center.y-Dist) < 1 ? 1 : Center.y - Dist)
	//var/x2 = ((Center.x+Dist) > world.maxx ? world.maxx : Center.x + Dist)
	//var/y2 = ((Center.y+Dist) > world.maxy ? world.maxy : Center.y + Dist)

	var/turf/x1y1 = locate(((Center.x - Dist) < 1 ? 1 : Center.x - Dist), ((Center.y - Dist) < 1 ? 1 : Center.y - Dist), Center.z)
	var/turf/x2y2 = locate(((Center.x + Dist) > world.maxx ? world.maxx : Center.x + Dist), ((Center.y + Dist) > world.maxy ? world.maxy : Center.y + Dist), Center.z)
	return block(x1y1, x2y2)

/**
 * Make boom
 *
 * @param epicenter          Where explosion is centered
 * @param devastation_range
 * @param heavy_impact_range
 * @param light_impact_range
 * @param flash_range        Unused
 * @param adminlog           Log to admins
 * @param ignored            Do not notify explosion listeners
 * @param verbose            Explosion listeners will treat as an important explosion worth reporting on radio
 */

var/explosion_shake_message_cooldown = 0

/proc/explosion(turf/epicenter, const/devastation_range, const/heavy_impact_range, const/light_impact_range, const/flash_range, adminlog = 1, ignored = 0, verbose = 1, var/mob/whodunnit, var/list/whitelist, var/true_range, var/list/shrapnel_whitelist)
	var/explosion_time = world.time

	spawn()
		var/watch = start_watch()
		epicenter = get_turf(epicenter)
		if(!epicenter)
			return

		if(devastation_range > 1)
			score.largeexplosions++ //For the scoreboard
		if(istype(get_area(epicenter),/area/shuttle/escape/centcom))
			score.shuttlebombed += devastation_range //For the scoreboard
		score.explosions++ //For the scoreboard

		stat_collection.add_explosion_stat(epicenter, devastation_range, heavy_impact_range, light_impact_range)

		explosion_effect(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
		if(adminlog)
			message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ([formatJumpTo(epicenter,"JMP")]) [whodunnit ? " caused by [whodunnit] [whodunnit.ckey ? "([whodunnit.ckey])" : "(no key)"] ([formatJumpTo(whodunnit,"JMP")])" : ""]")
			log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] [whodunnit ? " caused by [whodunnit] [whodunnit.ckey ? "([whodunnit.ckey])" : "(no key)"]" : ""]")
			if (true_range)
				message_admins("If uncapped, its size would have been ([round(true_range*0.25)], [round(true_range*0.5)], [round(true_range)])")
				log_game("If uncapped, its size would have been ([round(true_range*0.25)], [round(true_range*0.5)], [round(true_range)])")

		//Pause the lighting updates for a bit.
		var/postponeCycles = max(round(devastation_range/8),1)
		SSlighting.postpone(postponeCycles)

		var/x0 = epicenter.x
		var/y0 = epicenter.y
		var/z0 = epicenter.z

		var/datum/sensed_explosion/explosion_datum = explosion_destroy(epicenter,epicenter,devastation_range,heavy_impact_range,light_impact_range,flash_range,explosion_time,whodunnit,whitelist,true_range,shrapnel_whitelist)

		var/took = stop_watch(watch)

		if (explosion_datum)
			explosion_datum.ready(took)

		//You need to press the DebugGame verb to see these now....they were getting annoying and we've collected a fair bit of data. Just -test- changes  to explosion code using this please so we can compare
		if(Debug2)
			world.log << "## DEBUG: Explosion([x0],[y0],[z0])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [took] seconds."

		sleep(8)

	return 1

//Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
//Stereo users will also hear the direction of the explosion!
//Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
//3/7/14 will calculate to 80 + 35
/proc/explosion_effect(turf/epicenter, const/devastation_range, const/heavy_impact_range, const/light_impact_range, const/flash_range)
	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range)

	var/far_dist = (devastation_range * 20) + (heavy_impact_range * 5)
	var/frequency = get_rand_frequency()
	var/skip_shake = 0 //Will not display shaking-related messages

	for (var/mob/M in player_list)
		//Double check for client
		if(M && M.client)
			var/turf/M_turf = get_turf(M)
			if(M_turf && (M_turf.z == epicenter.z || AreConnectedZLevels(M_turf.z,epicenter.z)) && (M_turf.z - epicenter.z <= max_range) && (epicenter.z - M_turf.z <= max_range))
				var/dist = get_dist(M_turf, epicenter)
				//If inside the blast radius + world.view - 2
				if((dist <= round(max_range + world.view - 2, 1)) && (M_turf.z == epicenter.z))
					if(devastation_range > 0)
						M.playsound_local(epicenter, get_sfx("explosion"), 100, 1, frequency, falloff = 5) // get_sfx() is so that everyone gets the same sound
						shake_camera(M, clamp(devastation_range, 3, 10), 2)
					else
						M.playsound_local(epicenter, get_sfx("explosion_small"), 100, 1, frequency, falloff = 5)
						shake_camera(M, 3, 1)

					//You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.

				else if(dist <= far_dist)
					var/far_volume = clamp(far_dist, 30, 50) // Volume is based on explosion size and dist
					far_volume += (dist <= far_dist * 0.5 ? 50 : 0) // add 50 volume if the mob is pretty close to the explosion
					if(devastation_range > 0)
						M.playsound_local(epicenter, 'sound/effects/explosionfar.ogg', far_volume, 1, frequency, falloff = 5)
						shake_camera(M, 3, 1)
					else
						M.playsound_local(epicenter, 'sound/effects/explosionsmallfar.ogg', far_volume, 1, frequency, falloff = 5)
						skip_shake = 1

				if(!explosion_shake_message_cooldown && !skip_shake)
					to_chat(M, "<span class='danger'>You feel the station's structure shaking all around you.</span>")
					explosion_shake_message_cooldown = 1
					spawn(50)
						explosion_shake_message_cooldown = 0

	var/close = trange(world.view+round(devastation_range,1), epicenter)
	//To all distanced mobs play a different sound
	for(var/mob/M in mob_list) if(M.z == epicenter.z) if(!(M in close))
		//Check if the mob can hear
		if(M.ear_deaf <= 0 || !M.ear_deaf)
			if(!istype(M.loc,/turf/space))
				M << 'sound/effects/explosionfar.ogg'

	if(heavy_impact_range > 1)
		var/datum/effect/system/explosion/E = new/datum/effect/system/explosion()
		E.set_up(epicenter)
		E.start()
	else
		epicenter.turf_animation('icons/effects/96x96.dmi',"explosion_small",-WORLD_ICON_SIZE, -WORLD_ICON_SIZE, 13)

/proc/explosion_destroy(turf/epicenter, turf/offcenter, const/devastation_range, const/heavy_impact_range, const/light_impact_range, const/flash_range, var/explosion_time, var/mob/whodunnit, var/list/whitelist, var/cap = 0, var/list/shrapnel_whitelist)
	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range)

	var/x0 = offcenter.x
	var/y0 = offcenter.y
	//var/z0 = offcenter.z

	var/datum/sensed_explosion/explosion_datum = new(epicenter.x, epicenter.y, epicenter.z, devastation_range, heavy_impact_range, light_impact_range, cap)

	var/list/affected_turfs = spiral_block(offcenter,max_range)
	var/list/cached_exp_block = CalculateExplosionBlock(affected_turfs)

	for(var/turf/T in affected_turfs)
		if(whitelist && (T in whitelist))
			continue
		var/dist = cheap_pythag(T.x - x0, T.y - y0)
		var/_dist = dist
		var/pushback = 0
		var/turf/Trajectory = T
		while(Trajectory != offcenter)
			Trajectory = get_step_towards(Trajectory,offcenter)
			dist += cached_exp_block[Trajectory]

		if(dist < devastation_range)
			dist = 1
			pushback = 5
		else if(dist < heavy_impact_range)
			dist = 2
			pushback = 3
		else if(dist < light_impact_range)
			dist = 3
			pushback = 1
		else
			//invulnerable therefore no further explosion
			continue

		if (explosion_datum)
			explosion_datum.paint(T,dist)

		var/turftime = world.time
		for(var/atom/movable/A in T)
			var/atomtime = world.time
			if(whitelist && (A in whitelist))
				continue
			if(T != offcenter && !A.anchored && A.last_explosion_push != explosion_time)
				A.last_explosion_push = explosion_time

				var/max_dist = _dist+(pushback)
				var/max_count = pushback
				var/turf/throwT = get_step_away(A,offcenter,max_dist)
				for(var/i = 1 to max_count)
					var/turf/newT = get_step_away(throwT, offcenter, max_dist)
					if(!newT || newT == 0 || !isturf(newT))
						break
					throwT = newT
				if(!isturf(throwT))
					//world.log << "FUCK OUR TURF IS BAD"
					continue
				if(ismob(A))
					to_chat(A, "<span class='warning'>You are blown away by the explosion!</span>")
				A.throw_at(throwT,pushback+2,500,TRUE,0,shrapnel_whitelist)
			A.ex_act(dist,null,whodunnit)
			atomtime = world.time - atomtime
			if(atomtime > 0)
				log_debug("Slow explosion effect on [A]: Took [atomtime/10] seconds.")
		turftime = world.time - turftime
		if(turftime > 0)
			log_debug("Slow turf explosion processing at [formatJumpTo(T)]: Took [turftime/10] seconds.")

		T.ex_act(dist,null,whodunnit)

		CHECK_TICK

	explosion_destroy_multi_z(epicenter, offcenter, devastation_range / 2, heavy_impact_range / 2, light_impact_range / 2, flash_range / 2, explosion_time)
	explosion_destroy_multi_z(epicenter, offcenter, devastation_range / 2, heavy_impact_range / 2, light_impact_range / 2, flash_range / 2, explosion_time, whodunnit)

	return explosion_datum

/proc/CalculateExplosionBlock(list/affected_turfs)
	. = list()
	// we cache the explosion block rating of every turf in the explosion area
	//explosion block reduces explosion distance based on path from epicentre
	for(var/turf/T as anything in affected_turfs)
		var/current_exp_block = T.density ? T.explosion_block : 0
		for (var/obj/machinery/door/D in T)
			if(D.density && D.explosion_block)
				current_exp_block += D.explosion_block
				continue
		for (var/obj/effect/forcefield/F in T)
			current_exp_block += F.explosion_block
			continue
		for (var/obj/effect/energy_field/E in T)
			current_exp_block += E.explosion_block
			continue

		.[T] = current_exp_block

/proc/CalculateExplosionSingleBlock(var/turf/T)
	var/current_exp_block = T.density ? T.explosion_block : 0
	for (var/obj/machinery/door/D in T)
		if(D.density && D.explosion_block)
			current_exp_block += D.explosion_block
			continue
	for (var/obj/effect/forcefield/F in T)
		current_exp_block += F.explosion_block
		continue
	for (var/obj/effect/energy_field/E in T)
		current_exp_block += E.explosion_block
		continue

	return current_exp_block
