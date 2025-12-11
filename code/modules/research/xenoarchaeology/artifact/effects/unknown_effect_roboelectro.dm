
/datum/artifact_effect/roboelectro
	effecttype = "roboelectro"
	valid_artifact_styles = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_UNKNOWN)
	effect = list(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_hint = EFFECT_HINT_ELECTROMAGNETIC_ENERGY
	var/mod = 1
	copy_for_battery = list("mod")

/datum/artifact_effect/roboelectro/New()
	..()
	if (prob(50))
		mod = -1

/datum/artifact_effect/roboelectro/DoEffectTouch(var/mob/user)
	if(user)
		if (istype(user, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = user
			if (mod < 0)
				to_chat(R, "<span class='notice'>Your systems report damaged components mending by themselves!</span>")
			else
				to_chat(R, "<span class='warning'>Your systems report severe damage has been inflicted!</span>")
			R.adjustBruteLoss(rand(mod * 10,mod * 50))
			R.adjustFireLoss(rand(mod * 10,mod * 50))
			R.updatehealth()

/datum/artifact_effect/roboelectro/DoEffectAura()
	if(holder)
		for (var/mob/living/silicon/robot/M in range(src.effectrange,get_turf(holder)))
			if(prob(1))
				if (mod < 0)
					to_chat(M, "<span class='notice'>SYSTEM ALERT: Beneficial anomalous electromagnetic field detected!</span>")
				else
					to_chat(M, "<span class='warning'>SYSTEM ALERT: Harmful anomalous electromagnetic field detected!</span>")
			M.adjustBruteLoss(mod * 1)
			M.adjustFireLoss(mod * 1)
			M.updatehealth()

/datum/artifact_effect/roboelectro/DoEffectPulse()
	if(holder)
		for (var/mob/living/silicon/robot/M in range(src.effectrange,get_turf(holder)))
			if (mod < 0)
				to_chat(M, "<span class='notice'>SYSTEM ALERT: Structural damage has been repaired by anomalous electromagnetic pulse!</span>")
			else
				to_chat(M, "<span class='warning'>SYSTEM ALERT: Structural damage inflicted by anomalous electromagnetic pulse!</span>")
			M.adjustBruteLoss(mod * 10)
			M.adjustFireLoss(mod * 10)
			M.updatehealth()

