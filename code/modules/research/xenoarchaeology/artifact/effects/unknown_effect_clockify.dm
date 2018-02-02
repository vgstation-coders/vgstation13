/datum/artifact_effect/clockify
	effecttype = "clockify"
	effect = list(EFFECT_AURA, EFFECT_PULSE)
	effect_type = 2

/datum/artifact_effect/clockify/DoEffectAura()
	make_clocky(min(3, effectrange))

/datum/artifact_effect/clockify/DoEffectPulse()
	make_clocky(min(20, effectrange))

/datum/artifact_effect/clockify/proc/make_clocky(var/range)
	if(holder)
		for(var/turf/T in spiral_block(get_turf(holder), range))
			T.clockify()
   for(var/obj/machinery/door/D in T)
    D.clockify()
			for(var/obj/structure/S in T)
				S.clockify()
			for(var/obj/item/weapon/table_parts/TP in T)
				TP.clockify()
			sleep(1)