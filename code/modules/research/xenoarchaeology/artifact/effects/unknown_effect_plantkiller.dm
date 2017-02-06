/datum/artifact_effect/plantkiller
	effecttype = "plantkiller"
	effect_type = 5

/datum/artifact_effect/plantkiller/New()
	..()
	effect = pick(EFFECT_AURA, EFFECT_PULSE)

/datum/artifact_effect/plantkiller/DoEffectAura()
	if(holder)
		for (var/obj/machinery/portable_atmospherics/hydroponics/H in range(src.effectrange,holder))
			if(H.seed && !H.dead && prob(rand(5,25)))
				switch(rand(1,3))
					if(1)
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
			if(H.seed && !H.dead && prob(rand(20,50))) // Get your xenobotanist/vox trader/hydroponist mad with you in less than 1 minute with this simple trick.
				switch(rand(1,3))
					if(1)
						H.waterlevel -= rand(1,10)
						H.nutrilevel -= rand(1,10)
					if(2)
						H.yield_mod--
						H.toxins += rand(1,10)
					if(3)
						H.weed_coefficient++
						H.weedlevel++
						H.pestlevel++
						if(prob(1))
							H.dead = 1
			return 1
