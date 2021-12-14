/datum/component/ai
	var/datum/component/controller/controller

	var/state=0 // AI_STATE_* of the AI.

/datum/component/ai/RecieveSignal(var/message_type, var/list/args)
	switch(message_type)
		if(COMSIG_STATE) // list("name"="statename")
			state = args["name"]

/datum/component/ai/New(var/datum/component_container/CC)
	..(CC)
	controller=GetComponent(/datum/component/controller)
