/datum/artifact_effect/floors
	effecttype = "floors"
	valid_style_types = list(ARTIFACT_STYLE_WIZARD, ARTIFACT_STYLE_RELIQUARY, ARTIFACT_STYLE_PRECURSOR)
	effect = list(ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_type = 2
	var/available_floors = list(			
		/turf/simulated/floor/carpet, 
		/turf/simulated/floor/arcade,
		/turf/simulated/floor/damaged,
		/turf/simulated/floor,
		/turf/simulated/floor/grass,
		/turf/simulated/floor/engine/cult,
		/turf/simulated/floor/engine,
		/turf/simulated/floor/wood,
		/turf/simulated/floor/dark,
	)
	var/blacklisted_floors = list(
		/turf/simulated/floor/mineral/gingerbread_dirt_tile,
		/turf/simulated/floor/mineral/gingerbread_nest,
		/turf/simulated/floor/mineral/gingerbread_tile,
		/turf/simulated/floor/mineral/gingerbread_floor, //Gingerbread floors are fucky
		/turf/simulated/floor/mineral/gingerbread,
	)

/datum/artifact_effect/floors/DoEffectAura()
	make_floors(min(1, effectrange))

/datum/artifact_effect/floors/DoEffectPulse()
	make_floors(min(5, effectrange))

/datum/artifact_effect/floors/proc/make_floors(var/range)
	available_floors += typesof(/turf/simulated/floor/mineral) + typesof(/turf/simulated/floor/glass)
	if(holder)
		for(var/turf/T in spiral_block(get_turf(holder), range))
			if(istype(T, /turf/space) || isfloor(T))
				var/floortype = pick(available_floors)
				if(is_type_in_list(floortype, blacklisted_floors))
					floortype = /turf/simulated/floor	//default to normal floors if it rolls a blacklisted one
				shadow(T,holder.loc,"artificer_convert")
				T.ChangeTurf(floortype)
				sleep(3)