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
	var/next_speech
	var/speech_delay
	var/datum/component/ai/target_finder/finder = null

/datum/component/ai/conversation/auto/RecieveSignal(var/message_type, var/list/args)
	if(message_type == COMSIG_COMPONENT_ADDED && args["component"] == src) //We were just initialized
		finder = GetComponent(/datum/component/ai/target_finder)
	if(finder && next_speech < world.time && prob(speech_prob) && message_type == COMSIG_LIFE)
		var/listener
		for(var/mob/living/M in finder.GetTargets())
			if(M == src)
				continue
			if(M.isDead()) //No speaking to the dead
				continue
			listener = TRUE
			break
		if(listener)
			next_speech = world.time+speech_delay
			SendSignal(COMSIG_SAY)
	..() 