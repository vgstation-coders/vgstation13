//Carn: Spacevines random event.
/proc/spacevine_infestation(var/potency_min=70, var/potency_max=100, var/maturation_min=2, var/maturation_max=6)
	spawn() //to stop the secrets panel hanging
		var/list/turf/simulated/floor/turfs = list() //list of all the empty floor turfs in the hallway areas
		for(var/areapath in typesof(/area/maintenance))
			var/area/A = locate(areapath)
			for(var/turf/simulated/floor/F in A.contents)
				if(!is_blocked_turf(F) && !(locate(/obj/effect/plantsegment) in F))
					turfs += F

		if(turfs.len) //Pick a turf to spawn at if we can
			var/turf/simulated/floor/T = pick(turfs)
			var/datum/seed/seed = SSplant.create_random_seed(1)
			seed.spread = 2 // So it will function properly as vines.
			seed.potency = rand(potency_min, potency_max) // 70-100 potency will help guarantee a wide spread and powerful effects.
			seed.maturation = rand(maturation_min, maturation_max)
			seed.chems = list()

			var/strength = rand(1,100)
			if (strength > 20)
				seed.hematophage = 1//suck blood off entangled individuals
			if (strength > 50)
				seed.chems[FORMIC_ACID] = list(rand(1,5),rand(5,10))//let's burn entangled individuals
			if (strength > 70)
				seed.voracious = 2//brutalize entangled individuals
			if (strength > 80)
				seed.ligneous = 1//and on top of that we're hard to cut
			if (strength > 90)
				seed.thorny = 1//ok now this is overkill
				seed.stinging = 1

			var/obj/effect/plantsegment/vine = new(T,seed,start_fully_mature = 1)
			vine.process()

			message_admins("<span class='notice'>Event: Spacevines ([strength]% Strength) spawned at [T.loc] <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a></span>")
			return
		message_admins("<span class='notice'>Event: Spacevines failed to find a viable turf.</span>")