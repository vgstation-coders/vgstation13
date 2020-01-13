/datum/artifact_effect/planthelper
	effecttype = "planthelper"
	effect = list(ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_type = 5

/datum/artifact_effect/planthelper/DoEffectAura()
	if(holder)
		for (var/obj/machinery/portable_atmospherics/hydroponics/H in range(src.effectrange,holder))
			if(H.seed && !H.dead)
				switch(rand(1,4))
					if(1)
						if(H.waterlevel <= 75)
							H.waterlevel += rand(5,15)
					if(2)
						if(H.nutrilevel <= 5)
							H.nutrilevel += rand(1,5)
					if(3)
						H.weedlevel--
					if(4)
						H.pestlevel--
		return 1

/datum/artifact_effect/planthelper/DoEffectPulse()
	if(holder)
		for(var/obj/machinery/portable_atmospherics/hydroponics/H in range(src.effectrange,holder))
			if(H.seed && !H.dead)
				switch(rand(1,3))
					if(1)
						if(H.waterlevel <= 90)
							H.waterlevel += 10
						if(H.nutrilevel <= 9)
							H.nutrilevel++
					if(2)
						H.age--
					if(3)
						H.weedlevel--
						H.pestlevel--
						H.toxins--
			return 1
