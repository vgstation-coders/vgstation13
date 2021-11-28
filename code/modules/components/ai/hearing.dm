/datum/component/ai/hearing
	var/hear_signal
	var/list/required_messages = list()
	var/list/hear_args
	var/response_delay = 10

/datum/component/ai/hearing/initialize()
	parent.register_event(/event/hear, src, .proc/on_hear)
	return TRUE

/datum/component/ai/hearing/Destroy()
	parent.unregister_event(/event/hear, src, .proc/on_hear)
	..()

/datum/component/ai/hearing/proc/on_hear(datum/speech/speech)
	set waitfor = FALSE
	var/filtered_message = speech.message
	filtered_message = replacetext(filtered_message , "?" , "") //Ignores punctuation.
	filtered_message = replacetext(filtered_message , "!" , "") //Ignores punctuation.
	filtered_message = replacetext(filtered_message , "." , "") //Ignores punctuation.
	filtered_message = replacetext(filtered_message , "," , "") //Ignores punctuation.
	if(speech.speaker != parent)
		if(!required_messages.len)
			sleep(response_delay)
			INVOKE_EVENT(parent, hear_signal, hear_args)
		else
			for(var/message in required_messages)
				if(findtext(filtered_message,message))
					sleep(response_delay)
					INVOKE_EVENT(parent, hear_signal, hear_args)
					return

/datum/component/ai/hearing/say
	hear_signal = /event/comp_ai_cmd_say

/datum/component/ai/hearing/say_response
	hear_signal = /event/comp_ai_cmd_specific_say

/datum/component/ai/hearing/say_response/time
	required_messages = list("what time is it","whats the time","do you have the time")

/datum/component/ai/hearing/say_response/time/on_hear(var/datum/speech/speech)
	hear_args = list("The current time is [worldtime2text()].")
	..()
