/datum/artifact_effect/plantkiller
	effecttype = "plantkiller"
	effect = list(ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_type = 5

/datum/artifact_effect/plantkiller/DoEffectAura()
	if(holder)
		for (var/obj/machinery/portable_atmospherics/hydroponics/H in range(src.effectrange,holder))
			if(H.seed && !H.dead)
				switch(rand(1,3))
					if(1)
						if(H.waterlevel >= 5)
							H.waterlevel -= rand(1,5)
						H.nutrilevel--
					if(2)
						H.weed_coefficient++
						H.weedlevel++
					if(3)
						H.age++
		return 1

/datum/artifact_effect/plantkiller/DoEffectPulse()
	if(holder)
		for(var/obj/machinery/portable_atmospherics/hydroponics/H in range(src.effectrange,holder))
			if(H.seed && !H.dead) // Get your xenobotanist/vox trader/hydroponist mad with you in less than 1 minute with this simple trick.
				switch(rand(1,3))
					if(1)
						if(H.waterlevel >= 10)
							H.waterlevel -= rand(1,10)
						if(H.nutrilevel >= 5)
							H.nutrilevel -= rand(1,5)
					if(2)
						if(H.toxins <= 50)
							H.toxins += rand(1,50)
					if(3)
						H.weed_coefficient++
						H.weedlevel++
						H.pestlevel++
						if(prob(5))
							H.dead = 1
			return 1
