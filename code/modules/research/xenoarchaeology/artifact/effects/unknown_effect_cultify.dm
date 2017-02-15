/datum/artifact_effect/cultify
	effecttype = "cultify"
	effect_type = 2

/datum/artifact_effect/cultify/New()
	..()
	effect = pick(EFFECT_AURA, EFFECT_PULSE)

/datum/artifact_effect/cultify/DoEffectAura()
	make_culty(min(3, effectrange))

/datum/artifact_effect/cultify/DoEffectPulse()
	make_culty(min(20, effectrange))

/datum/artifact_effect/cultify/proc/make_culty(var/range)
	if(holder)
		for(var/turf/simulated/T in spiral_block(get_turf(holder), range))
			T.cultify()
			for(var/obj/structure/grille/G in T)
				G.cultify()
			for(var/obj/structure/window/W in T)
				if(istype(W,/obj/structure/window/full))
					W.cultify()
				else
					W.color = "red"
			for(var/obj/structure/table/TB in T)
				if(TB.type == /obj/structure/table)
					TB.cultify()
			for(var/obj/structure/bed/chair/C in T)
				if(C.type == /obj/structure/bed/chair)
					C.cultify()
			sleep(1)