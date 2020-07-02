/datum/artifact_effect/clockwork
	effecttype = "clockworkify"
	valid_style_types = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_ANCIENT, ARTIFACT_STYLE_PRECURSOR, ARTIFACT_STYLE_RELIQUARY)
	effect = list(ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_type = 2

/datum/artifact_effect/clockwork/DoEffectAura()
	make_clockworky(min(3, effectrange))

/datum/artifact_effect/clockwork/DoEffectPulse()
	make_clockworky(min(20, effectrange))

/datum/artifact_effect/clockwork/proc/make_clockworky(var/range)
	if(holder)
		playsound(holder, 'sound/misc/timesuit_activate.ogg', 50)
		for(var/turf/T in spiral_block(get_turf(holder), range))
			T.clockworkify()
			for(var/obj/O in T)
				O.clockworkify()
			for(var/mob/M in T)
				M.clockworkify()
			sleep(1)
