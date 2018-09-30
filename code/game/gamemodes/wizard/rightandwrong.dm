

/mob/proc/rightandwrong(var/summon_type) //0 = Summon Guns, 1 = Summon Magic, 2 = Summon Swords
	to_chat(usr, "<B>You summoned [summon_type]!</B>")
	message_admins("[key_name_admin(usr, 1)] summoned [summon_type]!")
	log_game("[key_name(usr)] summoned [summon_type]!")

	var/datum/role/survivor_type

	switch (summon_type)
		if ("swords")
			survivor_type = /datum/role/traitor/survivor/crusader/
		if ("magic")
			survivor_type = /datum/role/wizard/summon_magic/
		else
			survivor_type = /datum/role/traitor/survivor/

	for(var/mob/living/carbon/human/H in player_list)
		if (prob(65) || iswizard(H))
			continue
		if(H.stat == DEAD || !(H.client))
			continue
		
		var/datum/role/R = new survivor_type()

		if (!(isrole(R.id, H)))
			R.AssignToRole(H.mind)
			R.Greet()
			R.OnPostSetup()
			R.ForgeObjectives()
			R.AnnounceObjectives()
		else
			R = H.mind.GetRole(R.id)
			R.OnPostSetup()