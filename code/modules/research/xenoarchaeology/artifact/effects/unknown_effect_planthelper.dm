/datum/artifact_effect/planthelper
	effecttype = "planthelper"
	valid_style_types = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_UNKNOWN)
	effect = list(ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_type = 5

/datum/artifact_effect/planthelper/DoEffectAura()
	if(holder)
		for (var/obj/machinery/portable_atmospherics/hydroponics/H in range(src.effectrange,get_turf(holder)))
			switch(rand(1,4))
				if(1)
					H.add_waterlevel(25)
				if(2)
					H.add_nutrientlevel(50)
				if(3)
					H.add_weedlevel(-10)
				if(4)
					H.add_pestlevel(-10)
		return 1

/datum/artifact_effect/planthelper/DoEffectPulse()
	if(holder)
		for(var/obj/machinery/portable_atmospherics/hydroponics/H in range(src.effectrange,get_turf(holder)))
			if(H.seed && !H.dead)
				switch(rand(1,3))
					if(1)
						H.add_waterlevel(10)
						H.add_nutrientlevel(10)
					if(2)
						H.age--
					if(3)
						H.add_weedlevel(-10)
						H.add_pestlevel(-10)
						H.add_toxinlevel(-10)
	return 1
