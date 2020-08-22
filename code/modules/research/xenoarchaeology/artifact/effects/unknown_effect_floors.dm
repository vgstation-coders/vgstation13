/datum/artifact_effect/floors
	effecttype = "floors"
	valid_style_types = list(ARTIFACT_STYLE_WIZARD, ARTIFACT_STYLE_RELIQUARY, ARTIFACT_STYLE_PRECURSOR)
	effect = list(ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_type = 2
	var/blacklisted_floors = list(
		/turf/simulated/floor/mineral/gingerbread_dirt_tile,
		/turf/simulated/floor/mineral/gingerbread_nest,
		/turf/simulated/floor/plating/ironsand,
		/turf/simulated/floor/plating/foamedmetal
	)

/datum/artifact_effect/floors/DoEffectAura()
	make_floors(min(2, effectrange))

/datum/artifact_effect/floors/DoEffectPulse()
	make_floors(min(5, effectrange))

/datum/artifact_effect/floors/proc/make_floors(var/range)
	if(holder)
		for(var/turf/T in spiral_block(get_turf(holder), range))
			var/floortype = pick(typesof(/turf/simulated/floor) - blacklisted_floors - typesof(/turf/simulated/floor/holofloor) - typesof(/turf/simulated/floor/beach) - typesof(/turf/simulated/floor/plating) - typesof(/turf/simulated/floor/asteroid) - typesof(/turf/simulated/floor/inflatable))
			if(istype(T, /turf/space) || isfloor(T))
				shadow(T,holder.loc,"artificer_convert")
				T.ChangeTurf(floortype)
				sleep(1)