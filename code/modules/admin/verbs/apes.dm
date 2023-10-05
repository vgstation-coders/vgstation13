var/ape_mode = APE_MODE_OFF

/client/proc/apes()
	set category = "Fun"
	set name = "Configure Apes"

	switch(alert(usr, "Configure apes:", "Configure Apes", "Turn it off, no apes", "EVERYONE IS APE", "Only new players are apes"))
		if("Turn it off, no apes")
			ape_mode = APE_MODE_OFF
			message_admins("<span class='notice'>[key_name_admin(usr)] turned off ape mode.</span>")
		if("EVERYONE IS APE")
			ape_mode = APE_MODE_EVERYONE
			message_admins("<span class='notice'>[key_name_admin(usr)] turned on ape mode: EVERYONE IS APE.</span>")
		if("Only new players are apes")
			ape_mode = APE_MODE_NEW_PLAYERS
			message_admins("<span class='notice'>[key_name_admin(usr)] turned on ape mode: Only new players are apes.</span>")
	var/datum/persistence_task/task = SSpersistence_misc.tasks["/datum/persistence_task/ape_mode"]
	task.on_shutdown()

/mob/proc/apeify()
	if(ape_mode == APE_MODE_OFF)
		return
	ASSERT(client)
	if(ape_mode == APE_MODE_NEW_PLAYERS && client.player_age >= MINIMUM_NON_SUS_ACCOUNT_AGE)
		return
	var/mob/monke = monkeyize()
	ASSERT(monke)
	monke.name = monke.mind.name

/hook_handler/apes/proc/OnArrival(list/args)
	var/mob/living/dude = args["character"]
	ASSERT(dude)
	dude.apeify()
