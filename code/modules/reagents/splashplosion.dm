
//Hits every turfs in view and their content with our reagents (provided they are not blocked by windows or other turfs)
//Can be set to inject hit mob with some of the reagents based on their permeability. False by default.
/datum/reagents/proc/splashplosion(var/range=3,var/allow_permeability=FALSE)
	if (reagent_list.len <= 0)
		return

	var/list/hit_turfs = list()
	var/turf/epicenter = get_turf(my_atom)

	var/datum/effect/system/steam_spread/steam = new /datum/effect/system/steam_spread()
	steam.set_up(max(range,1)*3, 0, epicenter, mix_color_from_reagents(reagent_list))
	steam.start()

	playsound(epicenter, 'sound/effects/bamf.ogg', max(10,15*range), 0, range-4)

	if (!range)
		hit_turfs = list(epicenter)
	else
		for(var/turf/T in dview(range, epicenter, INVISIBILITY_MAXIMUM))
			if (cheap_pythag(T.x - epicenter.x,T.y - epicenter.y) <= range + 0.5)
				if (test_reach(epicenter,T,PASSTABLE|PASSGRILLE|PASSMOB|PASSMACHINE|PASSGIRDER))
					hit_turfs += T

	for(var/datum/reagent/R in reagent_list)
		var/min_volume_per_tile = max(1,R.volume/hit_turfs.len)
		//the volume is affected by the number of turfs hit. The less turfs hit, the more concentrated the splashing.
		//and the closer to the epicenter, the more splashing as well

		for (var/turf/T in hit_turfs)
			var/volume_for_this_tile = round((R.volume - min_volume_per_tile) / max(1,get_dist(epicenter,T))) + min_volume_per_tile
			if (!T.density)
				for (var/atom/movable/AM in T.contents)
					if (ismob(AM))
						if (isanimal(AM))
							R.reaction_animal(AM, TOUCH, volume_for_this_tile,hit_turfs)
						else
							R.reaction_mob(AM, TOUCH, volume_for_this_tile, ALL_LIMBS, allow_permeability, hit_turfs)
					else if (isobj(AM) && !istype(AM,/atom/movable/lighting_overlay))
						R.reaction_obj(AM, volume_for_this_tile,hit_turfs)
			R.reaction_turf(T, volume_for_this_tile,hit_turfs)

	clear_reagents()

