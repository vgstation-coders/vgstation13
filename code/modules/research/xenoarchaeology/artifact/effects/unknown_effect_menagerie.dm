/datum/artifact_effect/menagerie
	effecttype = "menagerie"
	valid_style_types = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_WIZARD)
	effect = ARTIFACT_EFFECT_PULSE
	effect_type = 5
	var/static/list/possible_types = list()

/datum/artifact_effect/menagerie/New()
	..()
	possible_types = existing_typesof(/mob/living) - (existing_typesof_list(blacklisted_mobs) + (existing_typesof(/mob/living/silicon) + existing_typesof(/mob/living/component) + /mob/living/simple_animal/scp_173 + /mob/living/simple_animal/pollywog))

/datum/artifact_effect/menagerie/DoEffectPulse()
	if(holder)
		for(var/mob/living/M in range(effectrange, get_turf(holder)))
			if(issilicon(M))
				continue
			if(!M.transmogged_from)
				var/multiplier = GetAnomalySusceptibility(M)
				if(multiplier == 0)
					continue
				var/target_type = pick(possible_types)
				var/mob/new_mob = M.transmogrify(target_type)
				var/turf/T = get_turf(new_mob)
				if(T)
					playsound(T, 'sound/effects/phasein.ogg', 50, 1)
				var/transmog_time = rand(1 MINUTES, 5 MINUTES)
				transmog_time *= multiplier
				spawn(transmog_time)
					if (!new_mob.gcDestroyed)
						var/turf/T2 = get_turf(new_mob.completely_untransmogrify())
						if(T2)
							playsound(T2, 'sound/effects/phasein.ogg', 50, 1)
				return 1
		return 0