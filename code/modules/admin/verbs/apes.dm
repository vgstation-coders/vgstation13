var/ape_mode = APE_MODE_OFF

/client/proc/apes()
	set category = "Fun"
	set name = "Configure Apes"

	var/datum/faction/apes/A = find_active_faction_by_type(/datum/faction/apes)

	switch(alert(usr, "Configure apes:", "Configure Apes", "Turn it off, no apes", "EVERYONE IS APE", "Only new players are apes"))
		if("Turn it off, no apes")
			ape_mode = APE_MODE_OFF
			message_admins("<span class='notice'>[key_name_admin(usr)] turned off ape mode.</span>")
			if(A)
				for(var/datum/role/apes/R in A.members)
					R.Drop()
				A.Dismantle() //it's over
			else
				to_chat(usr, "<span class='warning'> Error: No apes faction found!</span>")

		if("EVERYONE IS APE")
			ape_mode = APE_MODE_EVERYONE
			message_admins("<span class='notice'>[key_name_admin(usr)] turned on ape mode: EVERYONE IS APE.</span>")
			for(var/mob/living/carbon/human/H in player_list)
				H.apeify()

		if("Only new players are apes")
			ape_mode = APE_MODE_NEW_PLAYERS
			message_admins("<span class='notice'>[key_name_admin(usr)] turned on ape mode: Only new players are apes.</span>")
			for(var/mob/living/carbon/human/H in player_list)
				H.apeify()
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
	var/datum/role/apes/R = new
	R.AssignToRole(monke.mind, 1, 0)
	R.OnPostSetup()