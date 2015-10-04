
/datum/artifact_effect/teleport
	effecttype = "teleport"
	effect_type = 6

/datum/artifact_effect/teleport/DoEffectTouch(var/mob/user)
	var/weakness = GetAnomalySusceptibility(user)
	if(prob(100 * weakness))
		var/list/randomturfs = new/list()
		for(var/turf/simulated/floor/T in orange(user, 50))
			randomturfs.Add(T)
		if(randomturfs.len > 0)
			user << "<span class='warning'>You are suddenly zapped away elsewhere!</span>"
			if (user.locked_to)
				user.locked_to.unlock_atom(user)

			var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
			sparks.set_up(3, 0, get_turf(user))
			sparks.start()
			user.forceMove(pick(randomturfs))
			sparks = new /datum/effect/effect/system/spark_spread()
			sparks.set_up(3, 0, get_turf(user))
			sparks.start()

/datum/artifact_effect/teleport/DoEffectAura()
	if(holder)
		for (var/mob/living/M in range(src.effectrange,holder))
			var/weakness = GetAnomalySusceptibility(M)
			if(prob(100 * weakness))
				var/list/randomturfs = new/list()
				for(var/turf/simulated/floor/T in orange(M, 30))
					randomturfs.Add(T)
				if(randomturfs.len > 0)
					M << "<span class='warning'>You are displaced by a strange force!</span>"
					if(M.locked_to)
						M.locked_to.unlock_atom(M)

					var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
					sparks.set_up(3, 0, get_turf(M))
					sparks.start()
					M.loc = pick(randomturfs)
					sparks = new /datum/effect/effect/system/spark_spread()
					sparks.set_up(3, 0, get_turf(M))
					sparks.start()

/datum/artifact_effect/teleport/DoEffectPulse()
	if(holder)
		for (var/mob/living/M in range(src.effectrange, holder))
			var/weakness = GetAnomalySusceptibility(M)
			if(prob(100 * weakness))
				var/list/randomturfs = new/list()
				for(var/turf/simulated/floor/T in orange(M, 15))
					randomturfs.Add(T)
				if(randomturfs.len > 0)
					M << "<span class='warning'>You are displaced by a strange force!</span>"

					var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
					sparks.set_up(3, 0, get_turf(M))
					sparks.start()
					if(M.locked_to)
						M.locked_to.unlock_atom(M)
					M.loc = pick(randomturfs)
					sparks = new /datum/effect/effect/system/spark_spread()
					sparks.set_up(3, 0, get_turf(M))
					sparks.start()
