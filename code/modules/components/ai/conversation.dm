/datum/component/ai/conversation
	var/list/messages = list()

/datum/component/ai/conversation/RecieveSignal(var/message_type, var/list/args)
	if(isliving(container.holder))
		var/mob/living/M=container.holder
		switch(message_type)
			if(COMSIG_SAY)
				M.say("[pick(messages)]")
			if(COMSIG_SAY_SPECIFIC)
				var/to_say = args["to_say"]
				M.say("[to_say]")



/datum/component/ai/conversation/auto
	var/speech_prob = 30
	var/last_speech
	var/speech_delay
	var/datum/component/ai/target_finder/finder = null

/datum/component/ai/conversation/auto/RecieveSignal(var/message_type, var/list/args)
	if(message_type == COMSIG_COMPONENT_ADDED && args["component"] == src) //We were just initialized
		GetComponent(/datum/component/ai/target_finder)
	if(message_type == COMSIG_LIFE && finder && prob(speech_prob) && last_speech < world.time+speech_delay)
		var/listener
		for(var/mob/living/M in finder.GetTargets())
			if(M.isDead()) //No speaking to the dead
				continue
			listener = TRUE
			break
		if(listener)
			last_speech = world.time
			SendSignal(COMSIG_SAY)
	..()