/datum/component/ai/conversation
	var/list/messages = list()

/datum/component/ai/conversation/initialize()
	parent.register_event(/event/comp_ai_cmd_say, src, .proc/cmd_say)
	parent.register_event(/event/comp_ai_cmd_specific_say, src, .proc/cmd_specific_say)
	parent.register_event(/event/comp_ai_cmd_hear, src, .proc/cmd_hear)
	return TRUE

/datum/component/ai/conversation/Destroy()
	parent.unregister_event(/event/comp_ai_cmd_say, src, .proc/cmd_say)
	parent.unregister_event(/event/comp_ai_cmd_specific_say, src, .proc/cmd_specific_say)
	parent.unregister_event(/event/comp_ai_cmd_hear, src, .proc/cmd_hear)
	..()

/datum/component/ai/conversation/proc/cmd_say()
	if(isliving(parent))
		var/mob/living/M=parent
		M.say("[pick(messages)]")

/datum/component/ai/conversation/proc/cmd_specific_say(var/to_say)
	if(isliving(parent))
		var/mob/living/M=parent
		M.say("[to_say]")

/datum/component/ai/conversation/proc/cmd_hear()
	INVOKE_EVENT(src, /event/comp_ai_cmd_say)

/datum/component/ai/conversation/auto
	var/speech_prob = 30
	var/next_speech
	var/speech_delay
	var/datum/component/ai/target_finder/finder = null

/*/datum/component/ai/conversation/auto/RecieveSignal(var/message_type, var/list/args)
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
			INVOKE_EVENT(src, /event/comp_ai_cmd_say)
	..()*/