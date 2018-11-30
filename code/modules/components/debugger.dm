/datum/component/debugger //Exists to shout 'HEY, WE'RE USING THIS SIGNAL'
	var/spam = 1

/datum/component/debugger/RecieveSignal(var/message_type, var/list/args)
	if(spam)
		to_chat(world, "===================================")
		to_chat(world, "[container.holder] received [message_type], args are")
		for(var/i in args)
			to_chat(world, "[i]: [args[i]]")
		to_chat(world, "<a HREF='?src=\ref[src];pause=1'>\[Press here to stop and start the spam\]</a>")

/datum/component/debugger/Topic(href, href_list)
	.=..()
	if(href_list["pause"])
		spam = !spam