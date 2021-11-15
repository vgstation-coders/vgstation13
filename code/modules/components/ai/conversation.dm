/datum/component/ai/conversation
	var/list/messages = list()

/datum/component/ai/conversation/initialize()
	parent.register_event(/event/comp_ai_cmd_say, src, .proc/cmd_say)
	parent.register_event(/event/comp_ai_cmd_specific_say, src, .proc/cmd_specific_say)
	return TRUE

/datum/component/ai/conversation/Destroy()
	parent.unregister_event(/event/comp_ai_cmd_say, src, .proc/cmd_say)
	parent.unregister_event(/event/comp_ai_cmd_specific_say, src, .proc/cmd_specific_say)
	..()

/datum/component/ai/conversation/proc/cmd_say()
	if(isliving(parent))
		var/mob/living/M=parent
		M.say("[pick(messages)]")

/datum/component/ai/conversation/proc/cmd_specific_say(var/to_say)
	if(isliving(parent))
		var/mob/living/M=parent
		M.say("[to_say]")

/datum/component/ai/conversation/auto
	var/speech_prob = 30
	var/next_speech
	var/speech_delay
	var/datum/component/ai/target_finder/finder = null

/datum/component/ai/conversation/auto/initialize()
	if(..())
		finder = parent.get_component(/datum/component/ai/target_finder/simple_view)
		active_components += src
		return TRUE

/datum/component/ai/conversation/auto/Destroy()
	active_components -= src
	..()

/datum/component/ai/conversation/auto/process()
	if(finder && next_speech < world.time && prob(speech_prob))
		var/listener
		for(var/mob/living/M in finder.cmd_find_targets())
			if(M == src)
				continue
			if(M.isDead()) //No speaking to the dead
				continue
			listener = TRUE
			break
		if(listener)
			next_speech = world.time+speech_delay
			cmd_say()