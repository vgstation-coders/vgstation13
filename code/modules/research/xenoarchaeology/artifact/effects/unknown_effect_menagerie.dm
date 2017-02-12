/datum/artifact_effect/menagerie
	effecttype = "menagerie"
	effect_type = 5
	effect = EFFECT_PULSE
	var/static/list/possible_types = list()

/datum/artifact_effect/menagerie/New()
	..()
	possible_types = existing_typesof(/mob/living) - existing_typesof(/mob/living/silicon)

/datum/artifact_effect/menagerie/DoEffectPulse()
	if(holder)
		for(var/mob/living/M in range(effectrange,holder))
			if(istype(M, /mob/living/silicon))
				continue
			if(!M.transmogged_from)
				var/target_type = pick(possible_types)
				var/mob/new_mob = M.transmogrify(target_type)
				var/turf/T = get_turf(new_mob)
				if(T)
					playsound(T, 'sound/effects/phasein.ogg', 50, 1)
				spawn(5 MINUTES)
					var/mob/top_level = new_mob
					if(top_level.transmogged_to)
						while(top_level.transmogged_to)
							top_level = top_level.transmogged_to
					var/turf/T2 = get_turf(top_level)
					while(top_level)
						top_level = top_level.transmogrify()
					if(T2)
						playsound(T2, 'sound/effects/phasein.ogg', 50, 1)
			return 1