/datum/artifact_effect/floors
	effecttype = "floors"
	valid_style_types = list(ARTIFACT_STYLE_WIZARD, ARTIFACT_STYLE_RELIQUARY, ARTIFACT_STYLE_PRECURSOR)
	effect = list(ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_type = 2
	var/randomize = 1 	//If set to 1 will create random floors. Always at 1 for the time being.
	var/available_floors = list(			
		/turf/simulated/floor/carpet, 
		/turf/simulated/floor/arcade,
		/turf/simulated/floor/damaged,
		/turf/simulated/floor/grass,
		/turf/simulated/floor/engine/cult,
		/turf/simulated/floor/engine,
		/turf/simulated/floor/wood,
		/turf/simulated/floor/dark,
		/turf/simulated/floor/mineral/plastic,
		/turf/simulated/floor/mineral/phazon,
		/turf/simulated/floor/mineral/clockwork,
		/turf/simulated/floor/mineral/uranium,
		/turf/simulated/floor/mineral/diamond,
		/turf/simulated/floor/mineral/clown,
		/turf/simulated/floor/mineral/silver,
		/turf/simulated/floor/mineral/gold,
		/turf/simulated/floor/mineral/plasma,
		/turf/simulated/floor/glass,
		/turf/simulated/floor/glass/plasma
	)

/datum/artifact_effect/floors/DoEffectAura()
	make_floors(min(1, effectrange))

/datum/artifact_effect/floors/DoEffectPulse()
	make_floors(min(5, effectrange))

/datum/artifact_effect/floors/proc/make_floors(var/range)
	if(holder)
		var/turf/floortype
		if(randomize)
			floortype = pick(available_floors)
		else
			floortype = /turf/simulated/floor
		for(var/turf/T in spiral_block(get_turf(holder), range))
			if(istype(T, /turf/space) || isfloor(T))
				T.ChangeTurf(floortype)
				sleep(2)