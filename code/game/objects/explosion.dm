//TODO: Flash range does nothing currently

/proc/trange(var/Dist = 0, var/turf/Center = null) //Alternative to range (ONLY processes turfs and thus less intensive)

	if(isnull(Center))
		return

	//var/x1 = ((Center.x-Dist) < 1 ? 1 : Center.x-Dist)
	//var/y1 = ((Center.y-Dist) < 1 ? 1 : Center.y-Dist)
	//var/x2 = ((Center.x+Dist) > world.maxx ? world.maxx : Center.x+Dist)
	//var/y2 = ((Center.y+Dist) > world.maxy ? world.maxy : Center.y+Dist)

	var/turf/x1y1 = locate(((Center.x - Dist) < 1 ? 1 : Center.x-Dist), ((Center.y-Dist) < 1 ? 1 : Center.y-Dist), Center.z)
	var/turf/x2y2 = locate(((Center.x + Dist) > world.maxx ? world.maxx : Center.x+Dist), ((Center.y+Dist) > world.maxy ? world.maxy : Center.y+Dist), Center.z)
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
 * @param squelch            Do not notify explosion listeners
 */

//This proc is fairly important, so let's go through a thorough explanation of what is happening here
//Important note : The "damage ranges" are obsolete in theory. In practice, they provide an easy way of calculating bomb power, when creating or detonating them
//We now use a raw, precise damage output based on those three ranges and the absolute distance from epicenter, with the last tile of light impact being the last point of potential damage (1 raw damage)
/proc/explosion(turf/epicenter, const/devastation_range, const/heavy_impact_range, const/light_impact_range, const/flash_range, adminlog = 1, squelch = 0)

	src = null	//So we don't abort once src is deleted

	spawn() //Make sure we do all of this after src is set to null
		if(config.use_recursive_explosions) //Do we use whatever the fuck that is ?
			var/power = devastation_range * 2 + heavy_impact_range + light_impact_range //The ranges add up, ie light 14 includes both heavy 7 and devestation 3. So this calculation means devestation counts for 4, heavy for 2 and light for 1 power, giving us a cap of 27 power.
			explosion_rec(epicenter, power)
			return

		var/start = world.timeofday //Get the time of explosion for logging (needed for bhangometer)
		epicenter = get_turf(epicenter) //Get the epicenter, and make sure we're dealing with a turf
		if(!epicenter) //Is that not a turf ?
			return //You've failed us, proc caller

		var/max_range = max(devastation_range, heavy_impact_range, light_impact_range, flash_range) //Save up the real, maximum yield before bombcap and other shenanigans for logging and sound

//Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
//Stereo users will also hear the direction of the explosion!
//Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
//3/7/14 will calculate to 80 + 35

		var/far_dist = (devastation_range * 20) + (heavy_impact_range * 5) //Find how far is far enough to hear distant sounds (20 times devastation plus 5 times heavy, arbitrary)
		var/frequency = get_rand_frequency() //Generate a random sound frequency

		for(var/mob/M in player_list) //Run through the players
			if(M && M.client) //Double check for client
				var/turf/M_turf = get_turf(M) //Find the mob's turf for calculation
				if(M_turf && M_turf.z == epicenter.z) //Let's make sure we found it, and that it is on the same Z-level
					var/dist = get_dist(M_turf, epicenter) //Simple distance calculation, let's hand it over to helper procs
					if(dist <= round(max_range + world.view - 2, 1)) //If inside the blast radius + world.view - 2
						M.playsound_local(epicenter, get_sfx("explosion"), 100, 1, frequency, falloff = 5) //get_sfx() is so that everyone gets the same sound

					else if(dist <= far_dist) //You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.
						var/far_volume = Clamp(far_dist, 30, 50) //Volume is based on explosion size and dist
						far_volume += (dist <= far_dist * 0.5 ? 50 : 0) //Add 50 volume if the mob is pretty close to the explosion
						M.playsound_local(epicenter, 'sound/effects/explosionfar.ogg', far_volume, 1, frequency, falloff = 5)

		var/close = trange(world.view + round(devastation_range, 1), epicenter) //Let's find mobs that are dangerously close, in view of the devastation, so that they don't get a far explosion sound
		for(var/mob/M in mob_list) //To all distanced mobs play a different sound
			if(M.z == epicenter.z && !(M in close) && (M.ear_deaf <= 0 || !M.ear_deaf) && !istype(M.loc,/turf/space)) //Whole lot of checks so that people who shouldn't hear explosions, don't
				M << 'sound/effects/explosionfar.ogg'
		if(adminlog)
			message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[epicenter.x];Y=[epicenter.y];Z=[epicenter.z]'>JMP</A>)")
			log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ")

		//Pause the lighting updates while we get through the destruction shenanigans
		var/datum/controller/process/lighting = processScheduler.getProcess("lighting")
		lighting.disable()

		//Defer the powernet's rebuild too, while we destroy shit
		var/powernet_rebuild_was_deferred_already = defer_powernet_rebuild
		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 1

		if(heavy_impact_range > 1) //Is the explosion significant ?
			var/datum/effect/system/explosion/E = new/datum/effect/system/explosion() //Throw in an explosion effect
			E.set_up(epicenter) //At the epicenter
			E.start()

		//Locate the epicenter, and output it in values we can work with
		var/x0 = epicenter.x
		var/y0 = epicenter.y
		var/z0 = epicenter.z

		/*
		//We can finally begin exploding, get a list of all turfs in maximum range
		for(var/turf/T in trange(max_range, epicenter))
			var/dist = cheap_pythag(T.x - x0, T.y - y0) //Use more helper procs to quickly slash through this list of turfs

			if(dist < devastation_range)
				dist = 1
			else if(dist < heavy_impact_range)
				dist = 2
			else if(dist < light_impact_range)
				dist = 3
			else
				continue

			//And finally, here it is. Find all atoms that can receive an ex_act instruction by definition, and let's explode some shit
			for(var/atom/movable/A in T.contents)
				A.ex_act(dist) //Boom

			T.ex_act(dist) //Don't forget the turfs, now that'd be silly

		*/

		//New, improved explosion proc that accounts for blocking the explosion with bomb-proof material, without using A*
		//Note that see-through tiles do NOT block explosions since we use oview. Yes, looking at you, plasma windows. This is the only downside of this
		//This also causes a significant hang if the explosion is REALLY big (over a few dozen tiles), especially if it triggers more explosions along the way, so watch those 50 dev !
		//Explanations on multiplier values : 1 point of ex_output = 1 % probability of destruction or one point of health damage
		//Stacks quickly if you're very close to a strong explosion, but decreases quickly from there, especially once you're out of the devastation_range
		var/ex_damage //Allows us to send one exact damage output through ex_act to other atoms
		var/ex_output = (40 * devastation_range + 15 * heavy_impact_range + 5 * light_impact_range) //First helper, this is a constant for this particular explosion, the energy at the epicenter
		var/ex_output_loss //Second helper, this will be useful below
		for(var/i = 0; i <= max_range; i++) //Let's set up a basic index list to loop through
			for(var/turf/T in view(epicenter, i) - view(epicenter, i-1)) //Then, let's loop through tiles in view, while making sure we only deal with the maximum external "tile in view circle"
				var/dist = cheap_pythag(T.x - x0, T.y - y0) //Use more helper procs to quickly slash through this list of turfs

				//We now calculate damage. It is now longer a step system, but instead a decreasing linear progression from epicenter to last light damage tile
				//Since we now know what tile we are dealing with, let's figure out what the explosive loss will be
				//We need to account for the fact each damage range has a hard cap ! In this case, the minimum is the correct value, and the damage values stack !
				ex_output_loss = min(40 * dist, 40 * devastation_range) + min(15 * dist, 15 * heavy_impact_range) + min(5 * dist, 5 *  light_impact_range)

				//And now, we put it together
				//Values : Welder Tank (1, 2, 4) = 34
				ex_damage = ex_output - ex_output_loss

				//And finally, here it is. Find all atoms that can receive an ex_act instruction by definition, and let's explode some shit
				for(var/atom/movable/A in T.contents)
					A.ex_act(severity = ex_damage) //Boom

				T.ex_act(severity = ex_damage) //Don't forget the turfs, now that'd be silly

		//Extra notes. This, in theory, works as a "bomb-proof material blocks explosions" (which doesn't work for transparent bomb-proof material, henk)
		//The idea is that the explosion progresses through every "ring of tiles" and fires ex_act
		//If the turf can be seen through when we move to the next ring of tiles, then continue. Otherwise the explosion got stopped here for everything it "shields" (sight-wise)
		//It also has strange behavior with large explosions (especially ones with lucridious devastation ranges), and relies completely on coded ex_act behavior

		var/took = (world.timeofday - start)/10 //Let's see how much lag that generated, for debug and logging
		//You need to press the DebugGame verb to see these now....they were getting annoying and we've collected a fair bit of data. Just -test- changes  to explosion code using this please so we can compare
		if(Debug2)
			world.log << "## DEBUG: Explosion([x0],[y0],[z0])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [took] seconds."

		//Machines which report explosions.
		if(!squelch)
			for(var/obj/machinery/computer/bhangmeter/bhangmeter in doppler_arrays)
				if(bhangmeter)
					bhangmeter.sense_explosion(x0, y0, z0, devastation_range, heavy_impact_range, light_impact_range, took)

		spawn() //Once all of that is done, the "new lighting and power equipment" should be set

			lighting.enable() //Re-enable the lighting so that it recalculates

			if(!powernet_rebuild_was_deferred_already) //Let the powernet rebuild
				if(defer_powernet_rebuild != 2)
					defer_powernet_rebuild = 0

	return 1 //And that is a job well done

//Dumb proc, don't use
proc/secondaryexplosion(turf/epicenter, range)
	for(var/turf/tile in trange(range, epicenter))
		tile.ex_act(2)
