
/datum/artifact_effect/stun
	effecttype = "stun"
	effect = list(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)

/datum/artifact_effect/stun/New()
	..()
	effect_type = pick(2,5)

/datum/artifact_effect/stun/DoEffectTouch(var/mob/toucher)
	if(toucher && iscarbon(toucher))
		var/mob/living/carbon/C = toucher
		var/weakness = GetAnomalySusceptibility(C)
		if(prob(weakness * 100))
			to_chat(C, "<span class='warning'>A powerful force overwhelms your consciousness.</span>")
			C.AdjustKnockdown(45 * weakness)
			C.stuttering += 45 * weakness
			C.AdjustStunned(rand(1,10) * weakness)

/datum/artifact_effect/stun/DoEffectAura()
	if(holder)
		for (var/mob/living/carbon/C in range(src.effectrange,holder))
			var/weakness = GetAnomalySusceptibility(C)
			if(prob(10 * weakness))
				to_chat(C, "<span class='warning'>Your body goes numb for a moment.</span>")
				C.AdjustKnockdown(2)
				C.stuttering += 2
				if(prob(10))
					C.AdjustStunned(1)
			else if(prob(10))
				to_chat(C, "<span class='warning'>You feel numb.</span>")

/datum/artifact_effect/stun/DoEffectPulse()
	if(holder)
		for (var/mob/living/carbon/C in range(src.effectrange,holder))
			var/weakness = GetAnomalySusceptibility(C)
			if(prob(100 * weakness))
				to_chat(C, "<span class='warning'>A wave of energy overwhelms your senses!</span>")
				C.AdjustKnockdown(4 * weakness)
				C.stuttering += 4 * weakness
				if(prob(10))
					C.AdjustStunned(1 * weakness)
