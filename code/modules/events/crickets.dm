/datum/event/cricketsbehindthefridge/start()
	for(var/obj/machinery/smartfridge/SF in machines)
		for(var/i = 1 to rand(3,4))
			var/mob/living/simple_animal/cricket/C = new (SF.loc)
			if(i==1)
				C.wander = FALSE //first cricket should stay put behind the fridge

/datum/event/cricketsbehindthefridge/can_start()
	return 30