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
   for(var/obj/machinery/door/airlock/A in T)
    A.clockify()
			for(var/obj/structure/door_assembly/DA in T)
				DA.clockify()
   for(var/obj/structure/girder/G1 in T)
    G1.clockify()
			for(var/obj/structure/grille/G2 in T)
				G2.clockify()
			for(var/obj/structure/window/W in T)
				W.clockify()
			sleep(1)