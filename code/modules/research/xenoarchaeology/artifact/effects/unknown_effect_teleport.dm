
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
			to_chat(user, "<span class='warning'>You are suddenly zapped away elsewhere!</span>")
			user.unlock_from()

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
					to_chat(M, "<span class='warning'>You are displaced by a strange force!</span>")
					M.unlock_from()

					var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
					sparks.set_up(3, 0, get_turf(M))
					sparks.start()
					M.forceMove(pick(randomturfs))
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
					to_chat(M, "<span class='warning'>You are displaced by a strange force!</span>")

					var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
					sparks.set_up(3, 0, get_turf(M))
					sparks.start()
					M.unlock_from()
					M.forceMove(pick(randomturfs))
					sparks = new /datum/effect/effect/system/spark_spread()
					sparks.set_up(3, 0, get_turf(M))
					sparks.start()
