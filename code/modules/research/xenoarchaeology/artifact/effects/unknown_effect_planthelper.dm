/datum/artifact_effect/planthelper
	effecttype = "planthelper"
	effect_type = 5

/datum/artifact_effect/planthelper/New()
	..()
	effect = pick(EFFECT_AURA, EFFECT_PULSE)

/datum/artifact_effect/planthelper/DoEffectAura()
	if(holder)
		for (var/obj/machinery/portable_atmospherics/hydroponics/H in range(src.effectrange,holder))
			if(H.seed && !H.dead && prob(rand(6,12)))
				switch(rand(1,4))
					if(1)
						H.waterlevel += rand(2,8)
					if(2)
						H.nutrilevel++
					if(3)
						H.weedlevel--
					if(4)
						H.pestlevel--
		return 1

/datum/artifact_effect/planthelper/DoEffectPulse()
	if(holder)
		for(var/obj/machinery/portable_atmospherics/hydroponics/H in range(src.effectrange,holder))
			if(H.seed && !H.dead && prob(rand(8,36)))
				switch(rand(1,4))
					if(1)
						H.waterlevel += rand(5,15)
						H.nutrilevel += rand(1,10)
					if(2) // This will totally end fine.
						H.mutation_level++
						H.mutation_mod++
						H.yield_mod++
					if(3)
						H.age--
					if(4)
						H.weedlevel--
						H.pestlevel--
						H.toxins--
			return 1
