/datum/component/ai/conversation
	var/list/messages = list()

/datum/component/ai/conversation/initialize()
	parent.register_event(/event/comp_ai_cmd_say, src, nameof(src::cmd_say()))
	parent.register_event(/event/comp_ai_cmd_specific_say, src, nameof(src::cmd_specific_say()))
	return TRUE

/datum/component/ai/conversation/Destroy()
	parent.unregister_event(/event/comp_ai_cmd_say, src, nameof(src::cmd_say()))
	parent.unregister_event(/event/comp_ai_cmd_specific_say, src, nameof(src::cmd_specific_say()))
	..()

/datum/component/ai/conversation/proc/cmd_say()
	if(isliving(parent))
		var/mob/living/M=parent
		if(!M.isDead())
			M.say("[pick(messages)]")

/datum/component/ai/conversation/proc/cmd_specific_say(var/list/to_say)
	if(isliving(parent))
		var/mob/living/M=parent
		if(!M.isDead())
			M.say("[pick(to_say)]")

/datum/component/ai/conversation/auto
	var/speech_prob = 30
	var/next_speech
	var/speech_delay

/datum/component/ai/conversation/auto/initialize()
	if(..())
		active_components += src
		return TRUE

/datum/component/ai/conversation/auto/Destroy()
	active_components -= src
	..()

/datum/component/ai/conversation/auto/process()
	if(next_speech < world.time && prob(speech_prob))
		var/list/targets = INVOKE_EVENT(parent, /event/comp_ai_cmd_find_targets)
		for(var/mob/living/M in targets)
			if(istype(M,/mob/living/simple_animal))
				continue
			if(M == parent)
				continue
			if(M.isDead()) //No speaking to the dead
				continue
			next_speech = world.time + speech_delay
			cmd_say()
			break
