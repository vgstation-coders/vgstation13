/datum/component/ai/get_def_zone/RecieveAndReturnSignal(var/message_type, var/list/args)
	if(message_type == COMSIG_GETDAMTYPE)
		return "melee"
		//var/mob/M = args["user"]
