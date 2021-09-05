/datum/artifact_effect/gravity
	effecttype = "gravity"
	valid_style_types = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_ANCIENT, ARTIFACT_STYLE_PRECURSOR, ARTIFACT_STYLE_RELIQUARY)
	effect = list(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_type = 1

	var/pull_strength
	var/touch_pull_cooldown = FALSE
	copy_for_battery = list("pull_strength")

/datum/artifact_effect/gravity/New()
	..()
	effectrange = rand(3,12)
	pull_strength = pick(STAGE_ONE,STAGE_TWO,STAGE_THREE,STAGE_FOUR,10;STAGE_FIVE)

/datum/artifact_effect/gravity/DoEffectTouch()
	if (!touch_pull_cooldown)
		touch_pull_cooldown = TRUE
		gravitypull(effectrange)
		spawn(10)
			touch_pull_cooldown = FALSE

/datum/artifact_effect/gravity/DoEffectAura()
	gravitypull(round(effectrange/3))

/datum/artifact_effect/gravity/DoEffectPulse()
	gravitypull(effectrange)

/datum/artifact_effect/gravity/proc/gravitypull(range)
	for(var/atom/X in orange(effectrange, get_turf(holder)))
		if(X.type == /atom/movable/light)
			continue
		if(istype(X, /mob/living) && X.Adjacent(holder))
			var/mob/living/L = X
			to_chat(L, "<span class='warning'>You are [pull_strength >= STAGE_FOUR ? "painfully crushed onto" : "pulled against"] \the [holder]!</span>")
			if(pull_strength >= STAGE_FOUR)
				L.take_overall_damage(10)
			continue
		X.singularity_pull(holder, pull_strength, 0)
