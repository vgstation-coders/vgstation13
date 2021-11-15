/datum/component/ai/hearing
    var/hear_signal
    var/list/hear_args
    var/datum/speech/last_speech

/datum/component/ai/hearing/initialize()
    parent.register_event(/event/comp_ai_cmd_hear, src, .proc/on_hear)
    return TRUE

/datum/component/ai/hearing/Destroy()
    parent.unregister_event(/event/comp_ai_cmd_hear, src, .proc/on_hear)
    ..()

/datum/component/ai/hearing/proc/on_hear(var/datum/speech/speech)
    if(speech.speaker != parent)
        INVOKE_EVENT(parent, hear_signal, hear_args)
        last_speech = speech