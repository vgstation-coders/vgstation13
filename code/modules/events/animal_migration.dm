/datum/event/animal_migration
	announceWhen	= 20
	endWhen = 450
	var/list/spawned_mob = list()
	var/spawn_type = /mob/living/simple_animal/

/datum/event/animal_migration/setup()
	announceWhen = rand(15, 30)
	endWhen = rand(600,1200)
	spawn_type = pick(/mob/living/simple_animal/hostile/carp, /mob/living/simple_animal/hostile/goose)

/datum/event/animal_migration/announce()
	command_alert(/datum/command_alert/animal_migration)

/datum/event/animal_migration/start()
	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			if(prob(90)) //Give it a sliver of randomness
				spawned_mob.Add(new spawn_type(C.loc))

/datum/event/animal_migration/end()
	for(var/mob/living/simple_animal/M in spawned_mob)
		if(!M.stat)
			var/turf/T = get_turf(M)
			if(istype(T, /turf/space))
				qdel(M)
				M = null