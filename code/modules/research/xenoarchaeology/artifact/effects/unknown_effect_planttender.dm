/datum/artifact_effect/planttender
	effecttype = "planttender"
	valid_artifact_styles = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_UNKNOWN)
	effect = list(ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_hint = EFFECT_HINT_ORGANICALLY_REACTIVE_EXOTIC_PARTICLES
	var/help = 1
	copy_for_battery = list("help")

/datum/artifact_effect/planttender/New()
	..()
	if (prob(50))
		help = -1

/datum/artifact_effect/planttender/DoEffectAura()
	if(holder)
		for (var/obj/machinery/portable_atmospherics/hydroponics/H in range(src.effectrange,get_turf(holder)))
			if (!H.seed || H.dead)
				H.add_weedlevel(10)//always adding weeds to empty trays to accelerate the appearance of new plants
			else
				switch(rand(1,3))
					if(1)
						H.add_waterlevel(10 * help)
						H.add_nutrientlevel(10 * help)
					if(2)
						H.add_weedlevel(-10 * help)
						H.add_pestlevel(-10 * help)
					if(3)
						H.add_toxinlevel(-10 * help)
						if ((help < 0) || (H.age < H.seed.maturation))
							H.age++//If the plant is young, age it up regardless
						else
							if (help > 0)
								//The helpful variant keeps the plant alive and allows for more frequent harvests
								if (H.harvest)
									H.skip_aging++
								else
									H.lastproduce--


/datum/artifact_effect/planttender/DoEffectPulse()
	if(holder)
		for(var/obj/machinery/portable_atmospherics/hydroponics/H in range(src.effectrange,get_turf(holder)))
			if (!H.seed || H.dead)
				H.add_weedlevel(50)
			else
				//No switch. Pulses are rarer so they give a bit of everything instead
				H.add_waterlevel(25 * help)
				H.add_nutrientlevel(25 * help)
				H.add_weedlevel(-10 * help)
				H.add_pestlevel(-10 * help)
				H.add_toxinlevel(-10 * help)

				if ((help < 0) || (H.age < H.seed.maturation))
					H.age += 3//If the plant is young, age it up regardless
				else
					if (help > 0)
						//The helpful variant keeps the plant alive and allows for more frequent harvests
						if (H.harvest)
							H.skip_aging += 5
						else
							H.lastproduce -= 5

				if((help < 0) && prob(5))
					H.die()
