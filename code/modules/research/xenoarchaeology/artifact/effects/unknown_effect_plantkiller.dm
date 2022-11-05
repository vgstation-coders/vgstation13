/datum/artifact_effect/plantkiller
	effecttype = "plantkiller"
	valid_style_types = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_UNKNOWN)
	effect = list(ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_type = 5

/datum/artifact_effect/plantkiller/DoEffectAura()
	if(holder)
		for (var/obj/machinery/portable_atmospherics/hydroponics/H in range(src.effectrange,get_turf(holder)))
			switch(rand(1,3))
				if(1)
					H.add_waterlevel(-5)
					H.add_nutrientlevel(-10)
				if(2)
					H.weed_coefficient += WEEDLEVEL_MAX / 10
					H.add_weedlevel(10)
				if(3)
					H.age++
		return 1

/datum/artifact_effect/plantkiller/DoEffectPulse()
	if(holder)
		for(var/obj/machinery/portable_atmospherics/hydroponics/H in range(src.effectrange,get_turf(holder)))
			switch(rand(1,3))
				if(1)
					H.add_waterlevel(-rand(1,10))
					H.add_nutrientlevel(-rand(1,5))
				if(2)
					H.add_toxinlevel(rand(1,50))
				if(3)
					H.weed_coefficient += WEEDLEVEL_MAX / 10
					H.add_weedlevel(10)
					H.add_pestlevel(10)
					if(prob(5))
						H.die()
		return 1
