var/datum/subsystem/timer/runechat/SSrunechat

/datum/subsystem/timer/runechat
	name = "Runechat"
	priority = FIRE_PRIORITY_RUNECHAT
	var/list/callback/message_queue = list()

/datum/subsystem/timer/runechat/New()
	NEW_SS_GLOBAL(SSrunechat)

/datum/subsystem/timer/runechat/fire(resumed)
	. = ..() //poggers
	while(message_queue.len)
		var/callback/queued_message = message_queue[message_queue.len]
		queued_message.invoke()
		message_queue.len--
		if(MC_TICK_CHECK)
			return
