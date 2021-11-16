/datum/component/ai/hearing
    var/hear_signal
    var/list/required_messages = list()
    var/list/hear_args

/datum/component/ai/hearing/initialize()
    parent.register_event(/event/comp_ai_cmd_hear, src, .proc/on_hear)
    return TRUE

/datum/component/ai/hearing/Destroy()
    parent.unregister_event(/event/comp_ai_cmd_hear, src, .proc/on_hear)
    ..()

/datum/component/ai/hearing/proc/on_hear(var/datum/speech/speech)
    var/filtered_message = speech.message
    filtered_message = replacetext(filtered_message , "?" , "") //Ignores punctuation.
    filtered_message = replacetext(filtered_message , "!" , "") //Ignores punctuation.
    filtered_message = replacetext(filtered_message , "." , "") //Ignores punctuation.
    filtered_message = replacetext(filtered_message , "," , "") //Ignores punctuation.
    if(speech.speaker != parent && (!required_messages.len || (lowertext(filtered_message) in required_messages)))
        INVOKE_EVENT(parent, hear_signal, hear_args)

/datum/component/ai/hearing/say
    hear_signal = /event/comp_ai_cmd_say

/datum/component/ai/hearing/say_response
    hear_signal = /event/comp_ai_cmd_specific_say

/datum/component/ai/hearing/say_response/time
    required_messages = list("What time is it","Whats the time","Do you have the time")

/datum/component/ai/hearing/say_response/time/on_hear(var/datum/speech/speech)
    hear_args = list("The current time is [worldtime2text()].")
    ..()