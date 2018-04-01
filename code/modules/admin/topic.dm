/datum/admins/proc/CheckAdminHref(href, href_list)
	var/auth = href_list["admin_token"]
	. = auth && (auth == href_token || auth == GLOB.href_token)
	if(.)
		return
	var/msg = !auth ? "no" : "a bad"
	message_admins("[key_name_admin(usr)] clicked an href with [msg] authorization key!")
	if(CONFIG_GET(flag/debug_admin_hrefs))
		message_admins("Debug mode enabled, call not blocked. Please ask your coders to review this round's logs.")
		log_world("UAH: [href]")
		return TRUE
	log_admin_private("[key_name(usr)] clicked an href with [msg] authorization key! [href]")

/datum/admins/Topic(href, href_list)
	..()

	if(usr.client != src.owner || !check_rights(0))
		message_admins("[usr.key] has attempted to override the admin panel!")
		log_admin("[key_name(usr)] tried to use the admin panel without authorization.")
		return

	if(!CheckAdminHref(href, href_list))
		return

	if(href_list["ahelp"])
		if(!check_rights(R_ADMIN, TRUE))
			return

		var/ahelp_ref = href_list["ahelp"]
		var/datum/admin_help/AH = locate(ahelp_ref)
		if(AH)
			AH.Action(href_list["ahelp_action"])
		else
			to_chat(usr, "Ticket [ahelp_ref] has been deleted!")

	else if(href_list["ahelp_tickets"])
		GLOB.ahelp_tickets.BrowseTickets(text2num(href_list["ahelp_tickets"]))

	else if(href_list["stickyban"])
		stickyban(href_list["stickyban"],href_list)

	else if(href_list["getplaytimewindow"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["getplaytimewindow"]) in GLOB.mob_list
		if(!M)
			to_chat(usr, "<span class='danger'>ERROR: Mob not found.</span>")
			return
		cmd_show_exp_panel(M.client)

	else if(href_list["toggleexempt"])
		if(!check_rights(R_ADMIN))
			return
		var/client/C = locate(href_list["toggleexempt"]) in GLOB.clients
		if(!C)
			to_chat(usr, "<span class='danger'>ERROR: Client not found.</span>")
			return
		toggle_exempt_status(C)

	else if(href_list["makeAntag"])
		if(!check_rights(R_ADMIN))
			return
		if (!SSticker.mode)
			to_chat(usr, "<span class='danger'>Not until the round starts!</span>")
			return
		switch(href_list["makeAntag"])
			if("traitors")
				if(src.makeTraitors())
					message_admins("[key_name_admin(usr)] created traitors.")
					log_admin("[key_name(usr)] created traitors.")
				else
					message_admins("[key_name_admin(usr)] tried to create traitors. Unfortunately, there were no candidates available.")
					log_admin("[key_name(usr)] failed to create traitors.")
			if("changelings")
				if(src.makeChanglings())
					message_admins("[key_name(usr)] created changelings.")
					log_admin("[key_name(usr)] created changelings.")
				else
					message_admins("[key_name_admin(usr)] tried to create changelings. Unfortunately, there were no candidates available.")
					log_admin("[key_name(usr)] failed to create changelings.")
			if("revs")
				if(src.makeRevs())
					message_admins("[key_name(usr)] started a revolution.")
					log_admin("[key_name(usr)] started a revolution.")
				else
					message_admins("[key_name_admin(usr)] tried to start a revolution. Unfortunately, there were no candidates available.")
					log_admin("[key_name(usr)] failed to start a revolution.")
			if("cult")
				if(src.makeCult())
					message_admins("[key_name(usr)] started a cult.")
					log_admin("[key_name(usr)] started a cult.")
				else
					message_admins("[key_name_admin(usr)] tried to start a cult. Unfortunately, there were no candidates available.")
					log_admin("[key_name(usr)] failed to start a cult.")
			if("wizard")
				message_admins("[key_name(usr)] is creating a wizard...")
				if(src.makeWizard())
					message_admins("[key_name(usr)] created a wizard.")
					log_admin("[key_name(usr)] created a wizard.")
				else
					message_admins("[key_name_admin(usr)] tried to create a wizard. Unfortunately, there were no candidates available.")
					log_admin("[key_name(usr)] failed to create a wizard.")
			if("nukeops")
				message_admins("[key_name(usr)] is creating a nuke team...")
				if(src.makeNukeTeam())
					message_admins("[key_name(usr)] created a nuke team.")
					log_admin("[key_name(usr)] created a nuke team.")
				else
					message_admins("[key_name_admin(usr)] tried to create a nuke team. Unfortunately, there were not enough candidates available.")
					log_admin("[key_name(usr)] failed to create a nuke team.")
			if("ninja")
				message_admins("[key_name(usr)] spawned a ninja.")
				log_admin("[key_name(usr)] spawned a ninja.")
				src.makeSpaceNinja()
			if("aliens")
				message_admins("[key_name(usr)] started an alien infestation.")
				log_admin("[key_name(usr)] started an alien infestation.")
				src.makeAliens()
			if("deathsquad")
				message_admins("[key_name(usr)] is creating a death squad...")
				if(src.makeDeathsquad())
					message_admins("[key_name(usr)] created a death squad.")
					log_admin("[key_name(usr)] created a death squad.")
				else
					message_admins("[key_name_admin(usr)] tried to create a death squad. Unfortunately, there were not enough candidates available.")
					log_admin("[key_name(usr)] failed to create a death squad.")
			if("blob")
				var/strength = input("Set Blob Resource Gain Rate","Set Resource Rate",1) as num|null
				if(!strength)
					return
				message_admins("[key_name(usr)] spawned a blob with base resource gain [strength].")
				log_admin("[key_name(usr)] spawned a blob with base resource gain [strength].")
				new/datum/round_event/ghost_role/blob(TRUE, strength)
			if("centcom")
				message_admins("[key_name(usr)] is creating a CentCom response team...")
				if(src.makeEmergencyresponseteam())
					message_admins("[key_name(usr)] created a CentCom response team.")
					log_admin("[key_name(usr)] created a CentCom response team.")
				else
					message_admins("[key_name_admin(usr)] tried to create a CentCom response team. Unfortunately, there were not enough candidates available.")
					log_admin("[key_name(usr)] failed to create a CentCom response team.")
			if("abductors")
				message_admins("[key_name(usr)] is creating an abductor team...")
				if(src.makeAbductorTeam())
					message_admins("[key_name(usr)] created an abductor team.")
					log_admin("[key_name(usr)] created an abductor team.")
				else
					message_admins("[key_name_admin(usr)] tried to create an abductor team. Unfortunatly there were not enough candidates available.")
					log_admin("[key_name(usr)] failed to create an abductor team.")
			if("clockcult")
				if(src.makeClockCult())
					message_admins("[key_name(usr)] started a clockwork cult.")
					log_admin("[key_name(usr)] started a clockwork cult.")
				else
					message_admins("[key_name_admin(usr)] tried to start a clockwork cult. Unfortunately, there were no candidates available.")
					log_admin("[key_name(usr)] failed to start a clockwork cult.")
			if("revenant")
				if(src.makeRevenant())
					message_admins("[key_name(usr)] created a revenant.")
					log_admin("[key_name(usr)] created a revenant.")
				else
					message_admins("[key_name_admin(usr)] tried to create a revenant. Unfortunately, there were no candidates available.")
					log_admin("[key_name(usr)] failed to create a revenant.")

	else if(href_list["forceevent"])
		if(!check_rights(R_FUN))
			return
		var/datum/round_event_control/E = locate(href_list["forceevent"]) in SSevents.control
		if(E)
			E.admin_setup(usr)
			var/datum/round_event/event = E.runEvent()
			if(event.announceWhen>0)
				event.processing = FALSE
				var/prompt = alert(usr, "Would you like to alert the crew?", "Alert", "Yes", "No", "Cancel")
				switch(prompt)
					if("Cancel")
						event.kill()
						return
					if("No")
						event.announceWhen = -1
				event.processing = TRUE
			message_admins("[key_name_admin(usr)] has triggered an event. ([E.name])")
			log_admin("[key_name(usr)] has triggered an event. ([E.name])")
		return

	else if(href_list["dbsearchckey"] || href_list["dbsearchadmin"] || href_list["dbsearchip"] || href_list["dbsearchcid"])
		var/adminckey = href_list["dbsearchadmin"]
		var/playerckey = href_list["dbsearchckey"]
		var/ip = href_list["dbsearchip"]
		var/cid = href_list["dbsearchcid"]
		var/page = href_list["dbsearchpage"]

		DB_ban_panel(playerckey, adminckey, ip, cid, page)
		return

	else if(href_list["dbbanedit"])
		var/banedit = href_list["dbbanedit"]
		var/banid = text2num(href_list["dbbanid"])
		if(!banedit || !banid)
			return

		DB_ban_edit(banid, banedit)
		return

	else if(href_list["dbbanaddtype"])
		if(!check_rights(R_BAN))
			return
		var/bantype = text2num(href_list["dbbanaddtype"])
		var/banckey = href_list["dbbanaddckey"]
		var/banip = href_list["dbbanaddip"]
		var/bancid = href_list["dbbanaddcid"]
		var/banduration = text2num(href_list["dbbaddduration"])
		var/banjob = href_list["dbbanaddjob"]
		var/banreason = href_list["dbbanreason"]

		banckey = ckey(banckey)

		switch(bantype)
			if(BANTYPE_PERMA)
				if(!banckey || !banreason)
					to_chat(usr, "Not enough parameters (Requires ckey and reason).")
					return
				banduration = null
				banjob = null
			if(BANTYPE_TEMP)
				if(!banckey || !banreason || !banduration)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and duration).")
					return
				banjob = null
			if(BANTYPE_JOB_PERMA)
				if(!banckey || !banreason || !banjob)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and job).")
					return
				banduration = null
			if(BANTYPE_JOB_TEMP)
				if(!banckey || !banreason || !banjob || !banduration)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and job).")
					return
			if(BANTYPE_ADMIN_PERMA)
				if(!banckey || !banreason)
					to_chat(usr, "Not enough parameters (Requires ckey and reason).")
					return
				banduration = null
				banjob = null
			if(BANTYPE_ADMIN_TEMP)
				if(!banckey || !banreason || !banduration)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and duration).")
					return
				banjob = null

		var/mob/playermob

		for(var/mob/M in GLOB.player_list)
			if(M.ckey == banckey)
				playermob = M
				break


		banreason = "(MANUAL BAN) "+banreason

		if(!playermob)
			if(banip)
				banreason = "[banreason] (CUSTOM IP)"
			if(bancid)
				banreason = "[banreason] (CUSTOM CID)"
		else
			message_admins("Ban process: A mob matching [playermob.ckey] was found at location [playermob.x], [playermob.y], [playermob.z]. Custom ip and computer id fields replaced with the ip and computer id from the located mob.")

		if(!DB_ban_record(bantype, playermob, banduration, banreason, banjob, banckey, banip, bancid ))
			to_chat(usr, "<span class='danger'>Failed to apply ban.</span>")
			return
		create_message("note", banckey, null, banreason, null, null, 0, 0)

	else if(href_list["editrights"])
		edit_rights_topic(href_list)

	else if(href_list["call_shuttle"])
		if(!check_rights(R_ADMIN))
			return


		switch(href_list["call_shuttle"])
			if("1")
				if(EMERGENCY_AT_LEAST_DOCKED)
					return
				SSshuttle.emergency.request()
				log_admin("[key_name(usr)] called the Emergency Shuttle.")
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] called the Emergency Shuttle to the station.</span>")

			if("2")
				if(EMERGENCY_AT_LEAST_DOCKED)
					return
				switch(SSshuttle.emergency.mode)
					if(SHUTTLE_CALL)
						SSshuttle.emergency.cancel()
						log_admin("[key_name(usr)] sent the Emergency Shuttle back.")
						message_admins("<span class='adminnotice'>[key_name_admin(usr)] sent the Emergency Shuttle back.</span>")
					else
						SSshuttle.emergency.cancel()
						log_admin("[key_name(usr)] called the Emergency Shuttle.")
						message_admins("<span class='adminnotice'>[key_name_admin(usr)] called the Emergency Shuttle to the station.</span>")


		href_list["secrets"] = "check_antagonist"

	else if(href_list["edit_shuttle_time"])
		if(!check_rights(R_SERVER))
			return

		var/timer = input("Enter new shuttle duration (seconds):","Edit Shuttle Timeleft", SSshuttle.emergency.timeLeft() ) as num|null
		if(!timer)
			return
		SSshuttle.emergency.setTimer(timer*10)
		log_admin("[key_name(usr)] edited the Emergency Shuttle's timeleft to [timer] seconds.")
		minor_announce("The emergency shuttle will reach its destination in [round(SSshuttle.emergency.timeLeft(600))] minutes.")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] edited the Emergency Shuttle's timeleft to [timer] seconds.</span>")
		href_list["secrets"] = "check_antagonist"
	else if(href_list["trigger_centcom_recall"])
		if(!check_rights(R_ADMIN))
			return

		usr.client.trigger_centcom_recall()

	else if(href_list["toggle_continuous"])
		if(!check_rights(R_ADMIN))
			return
		var/list/continuous = CONFIG_GET(keyed_flag_list/continuous)
		if(!continuous[SSticker.mode.config_tag])
			continuous[SSticker.mode.config_tag] = TRUE
		else
			continuous[SSticker.mode.config_tag] = FALSE

		message_admins("<span class='adminnotice'>[key_name_admin(usr)] toggled the round to [continuous[SSticker.mode.config_tag] ? "continue if all antagonists die" : "end with the antagonists"].</span>")
		check_antagonists()

	else if(href_list["toggle_midround_antag"])
		if(!check_rights(R_ADMIN))
			return

		var/list/midround_antag = CONFIG_GET(keyed_flag_list/midround_antag)
		if(!midround_antag[SSticker.mode.config_tag])
			midround_antag[SSticker.mode.config_tag] = TRUE
		else
			midround_antag[SSticker.mode.config_tag] = FALSE

		message_admins("<span class='adminnotice'>[key_name_admin(usr)] toggled the round to [midround_antag[SSticker.mode.config_tag] ? "use" : "skip"] the midround antag system.</span>")
		check_antagonists()

	else if(href_list["alter_midround_time_limit"])
		if(!check_rights(R_ADMIN))
			return

		var/timer = input("Enter new maximum time",, CONFIG_GET(number/midround_antag_time_check)) as num|null
		if(!timer)
			return
		CONFIG_SET(number/midround_antag_time_check, timer)
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] edited the maximum midround antagonist time to [timer] minutes.</span>")
		check_antagonists()

	else if(href_list["alter_midround_life_limit"])
		if(!check_rights(R_ADMIN))
			return

		var/ratio = input("Enter new life ratio",, CONFIG_GET(number/midround_antag_life_check) * 100) as num
		if(!ratio)
			return
		CONFIG_SET(number/midround_antag_life_check, ratio / 100)

		message_admins("<span class='adminnotice'>[key_name_admin(usr)] edited the midround antagonist living crew ratio to [ratio]% alive.</span>")
		check_antagonists()

	else if(href_list["toggle_noncontinuous_behavior"])
		if(!check_rights(R_ADMIN))
			return

		if(!SSticker.mode.round_ends_with_antag_death)
			SSticker.mode.round_ends_with_antag_death = 1
		else
			SSticker.mode.round_ends_with_antag_death = 0

		message_admins("<span class='adminnotice'>[key_name_admin(usr)] edited the midround antagonist system to [SSticker.mode.round_ends_with_antag_death ? "end the round" : "continue as extended"] upon failure.</span>")
		check_antagonists()

	else if(href_list["delay_round_end"])
		if(!check_rights(R_SERVER))
			return
		if(!SSticker.delay_end)
			SSticker.admin_delay_notice = input(usr, "Enter a reason for delaying the round end", "Round Delay Reason") as null|text
			if(isnull(SSticker.admin_delay_notice))
				return
		else
			SSticker.admin_delay_notice = null
		SSticker.delay_end = !SSticker.delay_end
		var/reason = SSticker.delay_end ? "for reason: [SSticker.admin_delay_notice]" : "."//laziness
		var/msg = "[SSticker.delay_end ? "delayed" : "undelayed"] the round end [reason]"
		log_admin("[key_name(usr)] [msg]")
		message_admins("[key_name_admin(usr)] [msg]")
		href_list["secrets"] = "check_antagonist"
		if(SSticker.ready_for_reboot && !SSticker.delay_end) //we undelayed after standard reboot would occur
			SSticker.standard_reboot()

	else if(href_list["end_round"])
		if(!check_rights(R_ADMIN))
			return

		message_admins("<span class='adminnotice'>[key_name_admin(usr)] is considering ending the round.</span>")
		if(alert(usr, "This will end the round, are you SURE you want to do this?", "Confirmation", "Yes", "No") == "Yes")
			if(alert(usr, "Final Confirmation: End the round NOW?", "Confirmation", "Yes", "No") == "Yes")
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] has ended the round.</span>")
				SSticker.force_ending = 1 //Yeah there we go APC destroyed mission accomplished
				return
			else
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] decided against ending the round.</span>")
		else
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] decided against ending the round.</span>")

	else if(href_list["simplemake"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/M = locate(href_list["mob"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob.")
			return

		var/delmob = 0
		switch(alert("Delete old mob?","Message","Yes","No","Cancel"))
			if("Cancel")
				return
			if("Yes")
				delmob = 1

		switch(href_list["simplemake"])
			if("observer")
				M.change_mob_type( /mob/dead/observer , null, null, delmob )
			if("drone")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/drone , null, null, delmob )
			if("hunter")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/hunter , null, null, delmob )
			if("queen")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/royal/queen , null, null, delmob )
			if("praetorian")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/royal/praetorian , null, null, delmob )
			if("sentinel")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/sentinel , null, null, delmob )
			if("larva")
				M.change_mob_type( /mob/living/carbon/alien/larva , null, null, delmob )
			if("human")
				var/posttransformoutfit = usr.client.robust_dress_shop()
				var/mob/living/carbon/human/newmob = M.change_mob_type( /mob/living/carbon/human , null, null, delmob )
				if(posttransformoutfit && istype(newmob))
					newmob.equipOutfit(posttransformoutfit)
			if("slime")
				M.change_mob_type( /mob/living/simple_animal/slime , null, null, delmob )
			if("monkey")
				M.change_mob_type( /mob/living/carbon/monkey , null, null, delmob )
			if("robot")
				M.change_mob_type( /mob/living/silicon/robot , null, null, delmob )
			if("cat")
				M.change_mob_type( /mob/living/simple_animal/pet/cat , null, null, delmob )
			if("runtime")
				M.change_mob_type( /mob/living/simple_animal/pet/cat/Runtime , null, null, delmob )
			if("corgi")
				M.change_mob_type( /mob/living/simple_animal/pet/dog/corgi , null, null, delmob )
			if("ian")
				M.change_mob_type( /mob/living/simple_animal/pet/dog/corgi/Ian , null, null, delmob )
			if("pug")
				M.change_mob_type( /mob/living/simple_animal/pet/dog/pug , null, null, delmob )
			if("crab")
				M.change_mob_type( /mob/living/simple_animal/crab , null, null, delmob )
			if("coffee")
				M.change_mob_type( /mob/living/simple_animal/crab/Coffee , null, null, delmob )
			if("parrot")
				M.change_mob_type( /mob/living/simple_animal/parrot , null, null, delmob )
			if("polyparrot")
				M.change_mob_type( /mob/living/simple_animal/parrot/Poly , null, null, delmob )
			if("constructarmored")
				M.change_mob_type( /mob/living/simple_animal/hostile/construct/armored , null, null, delmob )
			if("constructbuilder")
				M.change_mob_type( /mob/living/simple_animal/hostile/construct/builder , null, null, delmob )
			if("constructwraith")
				M.change_mob_type( /mob/living/simple_animal/hostile/construct/wraith , null, null, delmob )
			if("shade")
				M.change_mob_type( /mob/living/simple_animal/shade , null, null, delmob )
		log_admin("[key_name(usr)] has used rudimentary transformation on [key_name(M)]. Transforming to [href_list["simplemake"]].; deletemob=[delmob]")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] has used rudimentary transformation on [key_name_admin(M)]. Transforming to [href_list["simplemake"]].; deletemob=[delmob]</span>")


	/////////////////////////////////////new ban stuff
	else if(href_list["unbanf"])
		if(!check_rights(R_BAN))
			return

		var/banfolder = href_list["unbanf"]
		GLOB.Banlist.cd = "/base/[banfolder]"
		var/key = GLOB.Banlist["key"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
			if(RemoveBan(banfolder))
				unbanpanel()
			else
				alert(usr, "This ban has already been lifted / does not exist.", "Error", "Ok")
				unbanpanel()

	else if(href_list["unbane"])
		if(!check_rights(R_BAN))
			return

		UpdateTime()
		var/reason

		var/banfolder = href_list["unbane"]
		GLOB.Banlist.cd = "/base/[banfolder]"
		var/reason2 = GLOB.Banlist["reason"]
		var/temp = GLOB.Banlist["temp"]

		var/minutes = GLOB.Banlist["minutes"]

		var/banned_key = GLOB.Banlist["key"]
		GLOB.Banlist.cd = "/base"

		var/duration

		switch(alert("Temporary Ban?",,"Yes","No"))
			if("Yes")
				temp = 1
				var/mins = 0
				if(minutes > GLOB.CMinutes)
					mins = minutes - GLOB.CMinutes
				mins = input(usr,"How long (in minutes)? (Default: 1440)","Ban time",mins ? mins : 1440) as num|null
				if(mins <= 0)
					to_chat(usr, "<span class='danger'>[mins] is not a valid duration.</span>")
					return
				minutes = GLOB.CMinutes + mins
				duration = GetExp(minutes)
				reason = input(usr,"Please State Reason.","Reason",reason2) as message|null
				if(!reason)
					return
			if("No")
				temp = 0
				duration = "Perma"
				reason = input(usr,"Please State Reason.","Reason",reason2) as message|null
				if(!reason)
					return

		log_admin_private("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		ban_unban_log_save("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]</span>")
		GLOB.Banlist.cd = "/base/[banfolder]"
		WRITE_FILE(GLOB.Banlist["reason"], reason)
		WRITE_FILE(GLOB.Banlist["temp"], temp)
		WRITE_FILE(GLOB.Banlist["minutes"], minutes)
		WRITE_FILE(GLOB.Banlist["bannedby"], usr.ckey)
		GLOB.Banlist.cd = "/base"
		unbanpanel()

	/////////////////////////////////////new ban stuff

	else if(href_list["appearanceban"])
		if(!check_rights(R_BAN))
			return
		var/mob/M = locate(href_list["appearanceban"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(!M.ckey)	//sanity
			to_chat(usr, "This mob has no ckey")
			return


		if(jobban_isbanned(M, "appearance"))
			switch(alert("Remove appearance ban?","Please Confirm","Yes","No"))
				if("Yes")
					ban_unban_log_save("[key_name(usr)] removed [key_name(M)]'s appearance ban.")
					log_admin_private("[key_name(usr)] removed [key_name(M)]'s appearance ban.")
					DB_ban_unban(M.ckey, BANTYPE_ANY_JOB, "appearance")
					if(M.client)
						jobban_buildcache(M.client)
					message_admins("<span class='adminnotice'>[key_name_admin(usr)] removed [key_name_admin(M)]'s appearance ban.</span>")
					to_chat(M, "<span class='boldannounce'><BIG>[usr.client.ckey] has removed your appearance ban.</BIG></span>")

		else switch(alert("Appearance ban [M.ckey]?",,"Yes","No", "Cancel"))
			if("Yes")
				var/reason = input(usr,"Please State Reason.","Reason") as message|null
				if(!reason)
					return
				if(!DB_ban_record(BANTYPE_JOB_PERMA, M, -1, reason, "appearance"))
					to_chat(usr, "<span class='danger'>Failed to apply ban.</span>")
					return
				if(M.client)
					jobban_buildcache(M.client)
				ban_unban_log_save("[key_name(usr)] appearance banned [key_name(M)]. reason: [reason]")
				log_admin_private("[key_name(usr)] appearance banned [key_name(M)]. \nReason: [reason]")
				create_message("note", M.ckey, null, "Appearance banned - [reason]", null, null, 0, 0)
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] appearance banned [key_name_admin(M)].</span>")
				to_chat(M, "<span class='boldannounce'><BIG>You have been appearance banned by [usr.client.ckey].</BIG></span>")
				to_chat(M, "<span class='boldannounce'>The reason is: [reason]</span>")
				to_chat(M, "<span class='danger'>Appearance ban can be lifted only upon request.</span>")
				var/bran = CONFIG_GET(string/banappeals)
				if(bran)
					to_chat(M, "<span class='danger'>To try to resolve this matter head to [bran]</span>")
				else
					to_chat(M, "<span class='danger'>No ban appeals URL has been set.</span>")
			if("No")
				return

	else if(href_list["jobban2"])
		if(!check_rights(R_BAN))
			return
		var/mob/M = locate(href_list["jobban2"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob.")
			return

		if(!M.ckey)	//sanity
			to_chat(usr, "This mob has no ckey.")
			return

		var/dat = "<head><title>Job-Ban Panel: [key_name(M)]</title></head>"

	/***********************************WARNING!************************************
				      The jobban stuff looks mangled and disgusting
						      But it looks beautiful in-game
						                -Nodrak
	************************************WARNING!***********************************/
		var/counter = 0
//Regular jobs
	//Command (Blue)
		dat += "<table cellpadding='1' cellspacing='0' width='100%'>"
		dat += "<tr align='center' bgcolor='ccccff'><th colspan='[length(GLOB.command_positions)]'><a href='?src=[REF(src)];[HrefToken()];jobban3=commanddept;jobban4=[REF(M)]'>Command Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.command_positions)
			if(!jobPos)
				continue
			if(jobban_isbanned(M, jobPos))
				dat += "<td width='15%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'><font color=red>[jobPos]</font></a></td>"
				counter++
			else
				dat += "<td width='15%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'>[jobPos]</a></td>"
				counter++

			if(counter >= 6) //So things dont get squiiiiished!
				dat += "</tr><tr>"
				counter = 0
		dat += "</tr></table>"

	//Security (Red)
		counter = 0
		dat += "<table cellpadding='1' cellspacing='0' width='100%'>"
		dat += "<tr bgcolor='ffddf0'><th colspan='[length(GLOB.security_positions)]'><a href='?src=[REF(src)];[HrefToken()];jobban3=securitydept;jobban4=[REF(M)]'>Security Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.security_positions)
			if(!jobPos)
				continue
			if(jobban_isbanned(M, jobPos))
				dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'><font color=red>[jobPos]</font></a></td>"
				counter++
			else
				dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'>[jobPos]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				dat += "</tr><tr align='center'>"
				counter = 0
		dat += "</tr></table>"

	//Engineering (Yellow)
		counter = 0
		dat += "<table cellpadding='1' cellspacing='0' width='100%'>"
		dat += "<tr bgcolor='fff5cc'><th colspan='[length(GLOB.engineering_positions)]'><a href='?src=[REF(src)];[HrefToken()];jobban3=engineeringdept;jobban4=[REF(M)]'>Engineering Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.engineering_positions)
			if(!jobPos)
				continue
			if(jobban_isbanned(M, jobPos))
				dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'><font color=red>[jobPos]</font></a></td>"
				counter++
			else
				dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'>[jobPos]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				dat += "</tr><tr align='center'>"
				counter = 0
		dat += "</tr></table>"

	//Medical (White)
		counter = 0
		dat += "<table cellpadding='1' cellspacing='0' width='100%'>"
		dat += "<tr bgcolor='ffeef0'><th colspan='[length(GLOB.medical_positions)]'><a href='?src=[REF(src)];[HrefToken()];jobban3=medicaldept;jobban4=[REF(M)]'>Medical Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.medical_positions)
			if(!jobPos)
				continue
			if(jobban_isbanned(M, jobPos))
				dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'><font color=red>[jobPos]</font></a></td>"
				counter++
			else
				dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'>[jobPos]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				dat += "</tr><tr align='center'>"
				counter = 0
		dat += "</tr></table>"

	//Science (Purple)
		counter = 0
		dat += "<table cellpadding='1' cellspacing='0' width='100%'>"
		dat += "<tr bgcolor='e79fff'><th colspan='[length(GLOB.science_positions)]'><a href='?src=[REF(src)];[HrefToken()];jobban3=sciencedept;jobban4=[REF(M)]'>Science Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.science_positions)
			if(!jobPos)
				continue
			if(jobban_isbanned(M, jobPos))
				dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'><font color=red>[jobPos]</font></a></td>"
				counter++
			else
				dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'>[jobPos]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				dat += "</tr><tr align='center'>"
				counter = 0
		dat += "</tr></table>"

	//Supply (Brown)
		counter = 0
		dat += "<table cellpadding='1' cellspacing='0' width='100%'>"
		dat += "<tr bgcolor='DDAA55'><th colspan='[length(GLOB.supply_positions)]'><a href='?src=[REF(src)];[HrefToken()];jobban3=supplydept;jobban4=[REF(M)]'>Supply Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.supply_positions)
			if(!jobPos)
				continue
			if(jobban_isbanned(M, jobPos))
				dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'><font color=red>[jobPos]</font></a></td>"
				counter++
			else
				dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'>[jobPos]</a></td>"
				counter++

			if(counter >= 5) //So things dont get COPYPASTE!
				dat += "</tr><tr align='center'>"
				counter = 0
		dat += "</tr></table>"

	//Civilian (Grey)
		counter = 0
		dat += "<table cellpadding='1' cellspacing='0' width='100%'>"
		dat += "<tr bgcolor='dddddd'><th colspan='[length(GLOB.civilian_positions)]'><a href='?src=[REF(src)];[HrefToken()];jobban3=civiliandept;jobban4=[REF(M)]'>Civilian Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.civilian_positions)
			if(!jobPos)
				continue
			if(jobban_isbanned(M, jobPos))
				dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'><font color=red>[jobPos]</font></a></td>"
				counter++
			else
				dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'>[jobPos]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				dat += "</tr><tr align='center'>"
				counter = 0
		dat += "</tr></table>"

	//Non-Human (Green)
		counter = 0
		dat += "<table cellpadding='1' cellspacing='0' width='100%'>"
		dat += "<tr bgcolor='ccffcc'><th colspan='[length(GLOB.nonhuman_positions)]'><a href='?src=[REF(src)];[HrefToken()];jobban3=nonhumandept;jobban4=[REF(M)]'>Non-human Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in GLOB.nonhuman_positions)
			if(!jobPos)
				continue
			if(jobban_isbanned(M, jobPos))
				dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'><font color=red>[jobPos]</font></a></td>"
				counter++
			else
				dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=[jobPos];jobban4=[REF(M)]'>[jobPos]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				dat += "</tr><tr align='center'>"
				counter = 0

		dat += "</tr></table>"

		//Ghost Roles (light light gray)
		dat += "<table cellpadding='1' cellspacing='0' width='100%'>"
		dat += "<tr bgcolor='eeeeee'><th colspan='5'><a href='?src=[REF(src)];[HrefToken()];jobban3=ghostroles;jobban4=[REF(M)]'>Ghost Roles</a></th></tr><tr align='center'>"

		//pAI
		if(jobban_isbanned(M, ROLE_PAI))
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=pAI;jobban4=[REF(M)]'><font color=red>pAI</font></a></td>"
		else
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=pAI;jobban4=[REF(M)]'>pAI</a></td>"


		//Drones
		if(jobban_isbanned(M, "drone"))
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=drone;jobban4=[REF(M)]'><font color=red>Drone</font></a></td>"
		else
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=drone;jobban4=[REF(M)]'>Drone</a></td>"


		//Positronic Brains
		if(jobban_isbanned(M, "posibrain"))
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=posibrain;jobban4=[REF(M)]'><font color=red>Posibrain</font></a></td>"
		else
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=posibrain;jobban4=[REF(M)]'>Posibrain</a></td>"


		//Deathsquad
		if(jobban_isbanned(M, "deathsquad"))
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=deathsquad;jobban4=[REF(M)]'><font color=red>Deathsquad</font></a></td>"
		else
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=deathsquad;jobban4=[REF(M)]'>Deathsquad</a></td>"

		//Lavaland roles
		if(jobban_isbanned(M, "lavaland"))
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=lavaland;jobban4=[REF(M)]'><font color=red>Lavaland</font></a></td>"
		else
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=lavaland;jobban4=[REF(M)]'>Lavaland</a></td>"

		dat += "</tr></table>"

	//Antagonist (Orange)
		var/isbanned_dept = jobban_isbanned(M, ROLE_SYNDICATE)
		dat += "<table cellpadding='1' cellspacing='0' width='100%'>"
		dat += "<tr bgcolor='ffeeaa'><th colspan='10'><a href='?src=[REF(src)];[HrefToken()];jobban3=Syndicate;jobban4=[REF(M)]'>Antagonist Positions</a> | "
		dat += "<a href='?src=[REF(src)];[HrefToken()];jobban3=teamantags;jobban4=[REF(M)]'>Team Antagonists</a></th>"
		dat += "<a href='?src=[REF(src)];[HrefToken()];jobban3=convertantags;jobban4=[REF(M)]'>Conversion Antagonists</a></th></tr><tr align='center'>"

		//Traitor
		if(jobban_isbanned(M, ROLE_TRAITOR) || isbanned_dept)
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=traitor;jobban4=[REF(M)]'><font color=red>Traitor</font></a></td>"
		else
			dat += "<td width='20%'><a href='?src=[REF(src)];jobban3=traitor;jobban4=[REF(M)]'>Traitor</a></td>"

		//Changeling
		if(jobban_isbanned(M, ROLE_CHANGELING) || isbanned_dept)
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=changeling;jobban4=[REF(M)]'><font color=red>Changeling</font></a></td>"
		else
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=changeling;jobban4=[REF(M)]'>Changeling</a></td>"

		//Nuke Operative
		if(jobban_isbanned(M, ROLE_OPERATIVE) || isbanned_dept)
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=operative;jobban4=[REF(M)]'><font color=red>Nuke Operative</font></a></td>"
		else
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=operative;jobban4=[REF(M)]'>Nuke Operative</a></td>"

		//Revolutionary
		if(jobban_isbanned(M, ROLE_REV) || isbanned_dept)
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=revolutionary;jobban4=[REF(M)]'><font color=red>Revolutionary</font></a></td>"
		else
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=revolutionary;jobban4=[REF(M)]'>Revolutionary</a></td>"

		//Cultist
		if(jobban_isbanned(M, ROLE_CULTIST) || isbanned_dept)
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=cultist;jobban4=[REF(M)]'><font color=red>Cultist</font></a></td>"
		else
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=cultist;jobban4=[REF(M)]'>Cultist</a></td>"

		dat += "</tr><tr align='center'>" //So things dont get squished.

		//Servant of Ratvar
		if(jobban_isbanned(M, ROLE_SERVANT_OF_RATVAR) || isbanned_dept)
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=servant of Ratvar;jobban4=[REF(M)]'><font color=red>Servant</font></a></td>"
		else
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=servant of Ratvar;jobban4=[REF(M)]'>Servant</a></td>"

		//Wizard
		if(jobban_isbanned(M, ROLE_WIZARD) || isbanned_dept)
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=wizard;jobban4=[REF(M)]'><font color=red>Wizard</font></a></td>"
		else
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=wizard;jobban4=[REF(M)]'>Wizard</a></td>"

		//Abductor
		if(jobban_isbanned(M, ROLE_ABDUCTOR) || isbanned_dept)
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=abductor;jobban4=[REF(M)]'><font color=red>Abductor</font></a></td>"
		else
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=abductor;jobban4=[REF(M)]'>Abductor</a></td>"

		//Alien
		if(jobban_isbanned(M, ROLE_ALIEN) || isbanned_dept)
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=alien;jobban4=[REF(M)]'><font color=red>Alien</font></a></td>"
		else
			dat += "<td width='20%'><a href='?src=[REF(src)];[HrefToken()];jobban3=alien;jobban4=[REF(M)]'>Alien</a></td>"

		dat += "</tr></table>"
		usr << browse(dat, "window=jobban2;size=800x450")
		return

	//JOBBAN'S INNARDS
	else if(href_list["jobban3"])
		if(!check_rights(R_BAN))
			return
		var/mob/M = locate(href_list["jobban4"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(!SSjob)
			to_chat(usr, "Jobs subsystem not initialized yet!")
			return
		//get jobs for department if specified, otherwise just return the one job in a list.
		var/list/joblist = list()
		switch(href_list["jobban3"])
			if("commanddept")
				for(var/jobPos in GLOB.command_positions)
					if(!jobPos)
						continue
					joblist += jobPos
			if("securitydept")
				for(var/jobPos in GLOB.security_positions)
					if(!jobPos)
						continue
					joblist += jobPos
			if("engineeringdept")
				for(var/jobPos in GLOB.engineering_positions)
					if(!jobPos)
						continue
					joblist += jobPos
			if("medicaldept")
				for(var/jobPos in GLOB.medical_positions)
					if(!jobPos)
						continue
					joblist += jobPos
			if("sciencedept")
				for(var/jobPos in GLOB.science_positions)
					if(!jobPos)
						continue
					joblist += jobPos
			if("supplydept")
				for(var/jobPos in GLOB.supply_positions)
					if(!jobPos)
						continue
					joblist += jobPos
			if("civiliandept")
				for(var/jobPos in GLOB.civilian_positions)
					if(!jobPos)
						continue
					joblist += jobPos
			if("nonhumandept")
				for(var/jobPos in GLOB.nonhuman_positions)
					if(!jobPos)
						continue
					joblist += jobPos
			if("ghostroles")
				joblist += list(ROLE_PAI, "posibrain", "drone", "deathsquad", "lavaland")
			if("teamantags")
				joblist += list(ROLE_OPERATIVE, ROLE_REV, ROLE_CULTIST, ROLE_SERVANT_OF_RATVAR, ROLE_ABDUCTOR, ROLE_ALIEN)
			if("convertantags")
				joblist += list(ROLE_REV, ROLE_CULTIST, ROLE_SERVANT_OF_RATVAR, ROLE_ALIEN)
			else
				joblist += href_list["jobban3"]

		//Create a list of unbanned jobs within joblist
		var/list/notbannedlist = list()
		for(var/job in joblist)
			if(!jobban_isbanned(M, job))
				notbannedlist += job

		//Banning comes first
		if(notbannedlist.len) //at least 1 unbanned job exists in joblist so we have stuff to ban.
			switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
				if("Yes")
					var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
					if(mins <= 0)
						to_chat(usr, "<span class='danger'>[mins] is not a valid duration.</span>")
						return
					var/reason = input(usr,"Please State Reason.","Reason") as message|null
					if(!reason)
						return

					var/msg
					for(var/job in notbannedlist)
						if(!DB_ban_record(BANTYPE_JOB_TEMP, M, mins, reason, job))
							to_chat(usr, "<span class='danger'>Failed to apply ban.</span>")
							return
						if(M.client)
							jobban_buildcache(M.client)
						ban_unban_log_save("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins] minutes. reason: [reason]")
						log_admin_private("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins] minutes.")
						if(!msg)
							msg = job
						else
							msg += ", [job]"
					create_message("note", M.ckey, null, "Banned  from [msg] - [reason]", null, null, 0, 0)
					message_admins("<span class='adminnotice'>[key_name_admin(usr)] banned [key_name_admin(M)] from [msg] for [mins] minutes.</span>")
					to_chat(M, "<span class='boldannounce'><BIG>You have been [(msg == ("ooc" || "appearance")) ? "banned" : "jobbanned"] by [usr.client.ckey] from: [msg].</BIG></span>")
					to_chat(M, "<span class='boldannounce'>The reason is: [reason]</span>")
					to_chat(M, "<span class='danger'>This jobban will be lifted in [mins] minutes.</span>")
					href_list["jobban2"] = 1 // lets it fall through and refresh
					return 1
				if("No")
					var/reason = input(usr,"Please State Reason","Reason") as message|null
					if(reason)
						var/msg
						for(var/job in notbannedlist)
							if(!DB_ban_record(BANTYPE_JOB_PERMA, M, -1, reason, job))
								to_chat(usr, "<span class='danger'>Failed to apply ban.</span>")
								return
							if(M.client)
								jobban_buildcache(M.client)
							ban_unban_log_save("[key_name(usr)] perma-jobbanned [key_name(M)] from [job]. reason: [reason]")
							log_admin_private("[key_name(usr)] perma-banned [key_name(M)] from [job]")
							if(!msg)
								msg = job
							else
								msg += ", [job]"
						create_message("note", M.ckey, null, "Banned  from [msg] - [reason]", null, null, 0, 0)
						message_admins("<span class='adminnotice'>[key_name_admin(usr)] banned [key_name_admin(M)] from [msg].</span>")
						to_chat(M, "<span class='boldannounce'><BIG>You have been [(msg == ("ooc" || "appearance")) ? "banned" : "jobbanned"] by [usr.client.ckey] from: [msg].</BIG></span>")
						to_chat(M, "<span class='boldannounce'>The reason is: [reason]</span>")
						to_chat(M, "<span class='danger'>Jobban can be lifted only upon request.</span>")
						href_list["jobban2"] = 1 // lets it fall through and refresh
						return 1
				if("Cancel")
					return

		//Unbanning joblist
		//all jobs in joblist are banned already OR we didn't give a reason (implying they shouldn't be banned)
		if(joblist.len) //at least 1 banned job exists in joblist so we have stuff to unban.
			var/msg
			for(var/job in joblist)
				var/reason = jobban_isbanned(M, job)
				if(!reason)
					continue //skip if it isn't jobbanned anyway
				switch(alert("Job: '[job]' Reason: '[reason]' Un-jobban?","Please Confirm","Yes","No"))
					if("Yes")
						ban_unban_log_save("[key_name(usr)] unjobbanned [key_name(M)] from [job]")
						log_admin_private("[key_name(usr)] unbanned [key_name(M)] from [job]")
						DB_ban_unban(M.ckey, BANTYPE_ANY_JOB, job)
						if(M.client)
							jobban_buildcache(M.client)
						if(!msg)
							msg = job
						else
							msg += ", [job]"
					else
						continue
			if(msg)
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] unbanned [key_name_admin(M)] from [msg].</span>")
				to_chat(M, "<span class='boldannounce'><BIG>You have been un-jobbanned by [usr.client.ckey] from [msg].</BIG></span>")
				href_list["jobban2"] = 1 // lets it fall through and refresh
			return 1
		return 0 //we didn't do anything!

	else if(href_list["boot2"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["boot2"])
		if (ismob(M))
			if(!check_if_greater_rights_than(M.client))
				to_chat(usr, "<span class='danger'>Error: They have more rights than you do.</span>")
				return
			to_chat(M, "<span class='danger'>You have been kicked from the server by [usr.client.holder.fakekey ? "an Administrator" : "[usr.client.ckey]"].</span>")
			log_admin("[key_name(usr)] kicked [key_name(M)].")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] kicked [key_name_admin(M)].</span>")
			//M.client = null
			qdel(M.client)

	else if(href_list["addmessage"])
		if(!check_rights(R_ADMIN))
			return
		var/target_ckey = href_list["addmessage"]
		create_message("message", target_ckey, secret = 0)

	else if(href_list["addnote"])
		if(!check_rights(R_ADMIN))
			return
		var/target_ckey = href_list["addnote"]
		create_message("note", target_ckey)

	else if(href_list["addwatch"])
		if(!check_rights(R_ADMIN))
			return
		var/target_ckey = href_list["addwatch"]
		create_message("watchlist entry", target_ckey, secret = 1)

	else if(href_list["addmemo"])
		if(!check_rights(R_ADMIN))
			return
		create_message("memo", secret = 0, browse = 1)

	else if(href_list["addmessageempty"])
		if(!check_rights(R_ADMIN))
			return
		create_message("message", secret = 0)

	else if(href_list["addnoteempty"])
		if(!check_rights(R_ADMIN))
			return
		create_message("note")

	else if(href_list["addwatchempty"])
		if(!check_rights(R_ADMIN))
			return
		create_message("watchlist entry", secret = 1)

	else if(href_list["deletemessage"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["deletemessage"]
		delete_message(message_id)

	else if(href_list["deletemessageempty"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["deletemessageempty"]
		delete_message(message_id, browse = 1)

	else if(href_list["editmessage"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["editmessage"]
		edit_message(message_id)

	else if(href_list["editmessageempty"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["editmessageempty"]
		edit_message(message_id, browse = 1)

	else if(href_list["secretmessage"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["secretmessage"]
		toggle_message_secrecy(message_id)

	else if(href_list["searchmessages"])
		if(!check_rights(R_ADMIN))
			return
		var/target = href_list["searchmessages"]
		browse_messages(index = target)

	else if(href_list["nonalpha"])
		if(!check_rights(R_ADMIN))
			return
		var/target = href_list["nonalpha"]
		target = text2num(target)
		browse_messages(index = target)

	else if(href_list["showmessages"])
		if(!check_rights(R_ADMIN))
			return
		var/target = href_list["showmessages"]
		browse_messages(index = target)

	else if(href_list["showmemo"])
		if(!check_rights(R_ADMIN))
			return
		browse_messages("memo")

	else if(href_list["showwatch"])
		if(!check_rights(R_ADMIN))
			return
		browse_messages("watchlist entry")

	else if(href_list["showwatchfilter"])
		if(!check_rights(R_ADMIN))
			return
		browse_messages("watchlist entry", filter = 1)

	else if(href_list["showmessageckey"])
		if(!check_rights(R_ADMIN))
			return
		var/target = href_list["showmessageckey"]
		var/agegate = TRUE
		if (href_list["showall"])
			agegate = FALSE
		browse_messages(target_ckey = target, agegate = agegate)

	else if(href_list["showmessageckeylinkless"])
		var/target = href_list["showmessageckeylinkless"]
		browse_messages(target_ckey = target, linkless = 1)

	else if(href_list["messageedits"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = sanitizeSQL("[href_list["messageedits"]]")
		var/datum/DBQuery/query_get_message_edits = SSdbcore.NewQuery("SELECT edits FROM [format_table_name("messages")] WHERE id = '[message_id]'")
		if(!query_get_message_edits.warn_execute())
			return
		if(query_get_message_edits.NextRow())
			var/edit_log = query_get_message_edits.item[1]
			usr << browse(edit_log,"window=noteedits")

	else if(href_list["newban"])
		if(!check_rights(R_BAN))
			return

		var/mob/M = locate(href_list["newban"])
		if(!ismob(M))
			return

		if(M.client && M.client.holder)
			return	//admins cannot be banned. Even if they could, the ban doesn't affect them anyway

		switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
			if("Yes")
				var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
				if(mins <= 0)
					to_chat(usr, "<span class='danger'>[mins] is not a valid duration.</span>")
					return
				var/reason = input(usr,"Please State Reason.","Reason") as message|null
				if(!reason)
					return
				if(!DB_ban_record(BANTYPE_TEMP, M, mins, reason))
					to_chat(usr, "<span class='danger'>Failed to apply ban.</span>")
					return
				AddBan(M.ckey, M.computer_id, reason, usr.ckey, 1, mins)
				ban_unban_log_save("[key_name(usr)] has banned [key_name(M)]. - Reason: [reason] - This will be removed in [mins] minutes.")
				to_chat(M, "<span class='boldannounce'><BIG>You have been banned by [usr.client.ckey].\nReason: [reason]</BIG></span>")
				to_chat(M, "<span class='danger'>This is a temporary ban, it will be removed in [mins] minutes.</span>")
				var/bran = CONFIG_GET(string/banappeals)
				if(bran)
					to_chat(M, "<span class='danger'>To try to resolve this matter head to [bran]</span>")
				else
					to_chat(M, "<span class='danger'>No ban appeals URL has been set.</span>")
				log_admin_private("[key_name(usr)] has banned [M.ckey].\nReason: [key_name(M)]\nThis will be removed in [mins] minutes.")
				var/msg = "<span class='adminnotice'>[key_name_admin(usr)] has banned [key_name_admin(M)].\nReason: [reason]\nThis will be removed in [mins] minutes.</span>"
				message_admins(msg)
				var/datum/admin_help/AH = M.client ? M.client.current_ticket : null
				if(AH)
					AH.Resolve()
				qdel(M.client)
			if("No")
				var/reason = input(usr,"Please State Reason.","Reason") as message|null
				if(!reason)
					return
				switch(alert(usr,"IP ban?",,"Yes","No","Cancel"))
					if("Cancel")
						return
					if("Yes")
						AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0, M.lastKnownIP)
					if("No")
						AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0)
				to_chat(M, "<span class='boldannounce'><BIG>You have been banned by [usr.client.ckey].\nReason: [reason]</BIG></span>")
				to_chat(M, "<span class='danger'>This is a permanent ban.</span>")
				var/bran = CONFIG_GET(string/banappeals)
				if(bran)
					to_chat(M, "<span class='danger'>To try to resolve this matter head to [bran]</span>")
				else
					to_chat(M, "<span class='danger'>No ban appeals URL has been set.</span>")
				if(!DB_ban_record(BANTYPE_PERMA, M, -1, reason))
					to_chat(usr, "<span class='danger'>Failed to apply ban.</span>")
					return
				ban_unban_log_save("[key_name(usr)] has permabanned [key_name(M)]. - Reason: [reason] - This is a permanent ban.")
				log_admin_private("[key_name(usr)] has banned [key_name(M)].\nReason: [reason]\nThis is a permanent ban.")
				var/msg = "<span class='adminnotice'>[key_name_admin(usr)] has banned [key_name_admin(M)].\nReason: [reason]\nThis is a permanent ban.</span>"
				message_admins(msg)
				var/datum/admin_help/AH = M.client ? M.client.current_ticket : null
				if(AH)
					AH.Resolve()
				qdel(M.client)
			if("Cancel")
				return

	else if(href_list["mute"])
		if(!check_rights(R_ADMIN))
			return
		cmd_admin_mute(href_list["mute"], text2num(href_list["mute_type"]))

	else if(href_list["c_mode"])
		return HandleCMode()

	else if(href_list["f_secret"])
		return HandleFSecret()

	else if(href_list["c_mode2"])
		if(!check_rights(R_ADMIN|R_SERVER))
			return

		if (SSticker.HasRoundStarted())
			return alert(usr, "The game has already started.", null, null, null, null)
		GLOB.master_mode = href_list["c_mode2"]
		log_admin("[key_name(usr)] set the mode as [GLOB.master_mode].")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] set the mode as [GLOB.master_mode].</span>")
		to_chat(world, "<span class='adminnotice'><b>The mode is now: [GLOB.master_mode]</b></span>")
		Game() // updates the main game menu
		SSticker.save_mode(GLOB.master_mode)
		HandleCMode()

	else if(href_list["f_secret2"])
		if(!check_rights(R_ADMIN|R_SERVER))
			return

		if(SSticker.HasRoundStarted())
			return alert(usr, "The game has already started.", null, null, null, null)
		if(GLOB.master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		GLOB.secret_force_mode = href_list["f_secret2"]
		log_admin("[key_name(usr)] set the forced secret mode as [GLOB.secret_force_mode].")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] set the forced secret mode as [GLOB.secret_force_mode].</span>")
		Game() // updates the main game menu
		HandleFSecret()

	else if(href_list["monkeyone"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["monkeyone"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return

		log_admin("[key_name(usr)] attempting to monkeyize [key_name(H)].")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] attempting to monkeyize [key_name_admin(H)].</span>")
		H.monkeyize()

	else if(href_list["humanone"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/monkey/Mo = locate(href_list["humanone"])
		if(!istype(Mo))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/monkey.")
			return

		log_admin("[key_name(usr)] attempting to humanize [key_name(Mo)].")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] attempting to humanize [key_name_admin(Mo)].</span>")
		Mo.humanize()

	else if(href_list["corgione"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["corgione"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return

		log_admin("[key_name(usr)] attempting to corgize [key_name(H)].")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] attempting to corgize [key_name_admin(H)].</span>")
		H.corgize()


	else if(href_list["forcespeech"])
		if(!check_rights(R_FUN))
			return

		var/mob/M = locate(href_list["forcespeech"])
		if(!ismob(M))
			to_chat(usr, "this can only be used on instances of type /mob.")

		var/speech = input("What will [key_name(M)] say?.", "Force speech", "")// Don't need to sanitize, since it does that in say(), we also trust our admins.
		if(!speech)
			return
		M.say(speech)
		speech = sanitize(speech) // Nah, we don't trust them
		log_admin("[key_name(usr)] forced [key_name(M)] to say: [speech]")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] forced [key_name_admin(M)] to say: [speech]</span>")

	else if(href_list["sendtoprison"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["sendtoprison"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob.")
			return
		if(isAI(M))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai.")
			return

		if(alert(usr, "Send [key_name(M)] to Prison?", "Message", "Yes", "No") != "Yes")
			return

		M.forceMove(pick(GLOB.prisonwarp))
		to_chat(M, "<span class='adminnotice'>You have been sent to Prison!</span>")

		log_admin("[key_name(usr)] has sent [key_name(M)] to Prison!")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to Prison!")

	else if(href_list["sendbacktolobby"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["sendbacktolobby"])

		if(!isobserver(M))
			to_chat(usr, "<span class='notice'>You can only send ghost players back to the Lobby.</span>")
			return

		if(!M.client)
			to_chat(usr, "<span class='warning'>[M] doesn't seem to have an active client.</span>")
			return

		if(alert(usr, "Send [key_name(M)] back to Lobby?", "Message", "Yes", "No") != "Yes")
			return

		log_admin("[key_name(usr)] has sent [key_name(M)] back to the Lobby.")
		message_admins("[key_name(usr)] has sent [key_name(M)] back to the Lobby.")

		var/mob/dead/new_player/NP = new()
		NP.ckey = M.ckey
		qdel(M)

	else if(href_list["tdome1"])
		if(!check_rights(R_FUN))
			return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdome1"])
		if(!isliving(M))
			to_chat(usr, "This can only be used on instances of type /mob/living.")
			return
		if(isAI(M))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai.")
			return
		var/mob/living/L = M

		for(var/obj/item/I in L)
			L.dropItemToGround(I, TRUE)

		L.Unconscious(100)
		sleep(5)
		L.forceMove(pick(GLOB.tdome1))
		spawn(50)
			to_chat(L, "<span class='adminnotice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(L)] to the thunderdome. (Team 1)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(L)] to the thunderdome. (Team 1)")

	else if(href_list["tdome2"])
		if(!check_rights(R_FUN))
			return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdome2"])
		if(!isliving(M))
			to_chat(usr, "This can only be used on instances of type /mob/living.")
			return
		if(isAI(M))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai.")
			return
		var/mob/living/L = M

		for(var/obj/item/I in L)
			L.dropItemToGround(I, TRUE)

		L.Unconscious(100)
		sleep(5)
		L.forceMove(pick(GLOB.tdome2))
		spawn(50)
			to_chat(L, "<span class='adminnotice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(L)] to the thunderdome. (Team 2)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(L)] to the thunderdome. (Team 2)")

	else if(href_list["tdomeadmin"])
		if(!check_rights(R_FUN))
			return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdomeadmin"])
		if(!isliving(M))
			to_chat(usr, "This can only be used on instances of type /mob/living.")
			return
		if(isAI(M))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai.")
			return
		var/mob/living/L = M

		L.Unconscious(100)
		sleep(5)
		L.forceMove(pick(GLOB.tdomeadmin))
		spawn(50)
			to_chat(L, "<span class='adminnotice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(L)] to the thunderdome. (Admin.)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(L)] to the thunderdome. (Admin.)")

	else if(href_list["tdomeobserve"])
		if(!check_rights(R_FUN))
			return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdomeobserve"])
		if(!isliving(M))
			to_chat(usr, "This can only be used on instances of type /mob/living.")
			return
		if(isAI(M))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai.")
			return
		var/mob/living/L = M

		for(var/obj/item/I in L)
			L.dropItemToGround(I, TRUE)

		if(ishuman(L))
			var/mob/living/carbon/human/observer = L
			observer.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket(observer), slot_w_uniform)
			observer.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(observer), slot_shoes)
		L.Unconscious(100)
		sleep(5)
		L.forceMove(pick(GLOB.tdomeobserve))
		spawn(50)
			to_chat(L, "<span class='adminnotice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(L)] to the thunderdome. (Observer.)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(L)] to the thunderdome. (Observer.)")

	else if(href_list["revive"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/living/L = locate(href_list["revive"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /mob/living.")
			return

		L.revive(full_heal = 1, admin_revive = 1)
		message_admins("<span class='danger'>Admin [key_name_admin(usr)] healed / revived [key_name_admin(L)]!</span>")
		log_admin("[key_name(usr)] healed / Revived [key_name(L)].")

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return

		message_admins("<span class='danger'>Admin [key_name_admin(usr)] AIized [key_name_admin(H)]!</span>")
		log_admin("[key_name(usr)] AIized [key_name(H)].")
		H.AIize()

	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makealien"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return

		usr.client.cmd_admin_alienize(H)

	else if(href_list["makeslime"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makeslime"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return

		usr.client.cmd_admin_slimeize(H)

	else if(href_list["makeblob"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makeblob"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return

		usr.client.cmd_admin_blobize(H)


	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return

		usr.client.cmd_admin_robotize(H)

	else if(href_list["makeanimal"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/M = locate(href_list["makeanimal"])
		if(isnewplayer(M))
			to_chat(usr, "This cannot be used on instances of type /mob/dead/new_player.")
			return

		usr.client.cmd_admin_animalize(M)

	else if(href_list["adminplayeropts"])
		var/mob/M = locate(href_list["adminplayeropts"])
		show_player_panel(M)

	else if(href_list["adminplayerobservefollow"])
		if(!isobserver(usr) && !check_rights(R_ADMIN))
			return

		var/atom/movable/AM = locate(href_list["adminplayerobservefollow"])

		var/client/C = usr.client
		if(!isobserver(usr))
			C.admin_ghost()
		var/mob/dead/observer/A = C.mob
		A.ManualFollow(AM)

	else if(href_list["admingetmovable"])
		if(!check_rights(R_ADMIN))
			return

		var/atom/movable/AM = locate(href_list["admingetmovable"])
		if(QDELETED(AM))
			return
		AM.forceMove(get_turf(usr))

	else if(href_list["adminplayerobservecoodjump"])
		if(!isobserver(usr) && !check_rights(R_ADMIN))
			return

		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		var/client/C = usr.client
		if(!isobserver(usr))
			C.admin_ghost()
		sleep(2)
		C.jumptocoord(x,y,z)

	else if(href_list["adminchecklaws"])
		if(!check_rights(R_ADMIN))
			return
		output_ai_laws()

	else if(href_list["admincheckdevilinfo"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["admincheckdevilinfo"])
		output_devil_info(M)

	else if(href_list["adminmoreinfo"])
		var/mob/M = locate(href_list["adminmoreinfo"]) in GLOB.mob_list
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob.")
			return

		var/location_description = ""
		var/special_role_description = ""
		var/health_description = ""
		var/gender_description = ""
		var/turf/T = get_turf(M)

		//Location
		if(isturf(T))
			if(isarea(T.loc))
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
			else
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z])"

		//Job + antagonist
		if(M.mind)
			special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <font color='red'><b>[M.mind.special_role]</b></font>"
		else
			special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>"

		//Health
		if(isliving(M))
			var/mob/living/L = M
			var/status
			switch (M.stat)
				if(CONSCIOUS)
					status = "Alive"
				if(SOFT_CRIT)
					status = "<font color='orange'><b>Dying</b></font>"
				if(UNCONSCIOUS)
					status = "<font color='orange'><b>[L.InCritical() ? "Unconscious and Dying" : "Unconscious"]</b></font>"
				if(DEAD)
					status = "<font color='red'><b>Dead</b></font>"
			health_description = "Status = [status]"
			health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getBrainLoss()] - Stamina: [L.getStaminaLoss()]"
		else
			health_description = "This mob type has no health to speak of."

		//Gender
		switch(M.gender)
			if(MALE,FEMALE)
				gender_description = "[M.gender]"
			else
				gender_description = "<font color='red'><b>[M.gender]</b></font>"

		to_chat(src.owner, "<b>Info about [M.name]:</b> ")
		to_chat(src.owner, "Mob type = [M.type]; Gender = [gender_description] Damage = [health_description]")
		to_chat(src.owner, "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind?"[M.mind.name]":""]; Key = <b>[M.key]</b>;")
		to_chat(src.owner, "Location = [location_description];")
		to_chat(src.owner, "[special_role_description]")
		to_chat(src.owner, ADMIN_FULLMONTY_NONAME(M))

	else if(href_list["addjobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/Add = href_list["addjobslot"]

		for(var/datum/job/job in SSjob.occupations)
			if(job.title == Add)
				job.total_positions += 1
				break

		src.manage_free_slots()


	else if(href_list["customjobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/Add = href_list["customjobslot"]

		for(var/datum/job/job in SSjob.occupations)
			if(job.title == Add)
				var/newtime = null
				newtime = input(usr, "How many jebs do you want?", "Add wanted posters", "[newtime]") as num|null
				if(!newtime)
					to_chat(src.owner, "Setting to amount of positions filled for the job")
					job.total_positions = job.current_positions
					break
				job.total_positions = newtime

		src.manage_free_slots()

	else if(href_list["removejobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/Remove = href_list["removejobslot"]

		for(var/datum/job/job in SSjob.occupations)
			if(job.title == Remove && job.total_positions - job.current_positions > 0)
				job.total_positions -= 1
				break

		src.manage_free_slots()

	else if(href_list["unlimitjobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/Unlimit = href_list["unlimitjobslot"]

		for(var/datum/job/job in SSjob.occupations)
			if(job.title == Unlimit)
				job.total_positions = -1
				break

		src.manage_free_slots()

	else if(href_list["limitjobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/Limit = href_list["limitjobslot"]

		for(var/datum/job/job in SSjob.occupations)
			if(job.title == Limit)
				job.total_positions = job.current_positions
				break

		src.manage_free_slots()


	else if(href_list["adminspawncookie"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["adminspawncookie"])
		if(!ishuman(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return

		var/obj/item/reagent_containers/food/snacks/cookie/cookie = new(H)
		if(H.put_in_hands(cookie))
			H.update_inv_hands()
		else
			qdel(cookie)
			log_admin("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
			message_admins("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
			return

		log_admin("[key_name(H)] got their cookie, spawned by [key_name(src.owner)].")
		message_admins("[key_name(H)] got their cookie, spawned by [key_name(src.owner)].")
		SSblackbox.record_feedback("amount", "admin_cookies_spawned", 1)
		to_chat(H, "<span class='adminnotice'>Your prayers have been answered!! You received the <b>best cookie</b>!</span>")
		SEND_SOUND(H, sound('sound/effects/pray_chaplain.ogg'))

	else if(href_list["adminsmite"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["adminsmite"]) in GLOB.mob_list
		if(!H || !istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		usr.client.smite(H)

	else if(href_list["CentComReply"])
		var/mob/living/carbon/human/H = locate(href_list["CentComReply"]) in GLOB.mob_list
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return
		if(!istype(H.ears, /obj/item/device/radio/headset))
			to_chat(usr, "The person you are trying to contact is not wearing a headset.")
			return

		message_admins("[src.owner] has started answering [key_name(H)]'s CentCom request.")
		var/input = input(src.owner, "Please enter a message to reply to [key_name(H)] via their headset.","Outgoing message from CentCom", "")
		if(!input)
			message_admins("[src.owner] decided not to answer [key_name(H)]'s CentCom request.")
			return

		log_admin("[src.owner] replied to [key_name(H)]'s CentCom message with the message [input].")
		message_admins("[src.owner] replied to [key_name(H)]'s CentCom message with: \"[input]\"")
		to_chat(H, "You hear something crackle in your ears for a moment before a voice speaks.  \"Please stand by for a message from Central Command.  Message as follows. [input].  Message ends.\"")

	else if(href_list["SyndicateReply"])
		var/mob/living/carbon/human/H = locate(href_list["SyndicateReply"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return
		if(!istype(H.ears, /obj/item/device/radio/headset))
			to_chat(usr, "The person you are trying to contact is not wearing a headset.")
			return

		message_admins("[src.owner] has started answering [key_name(H)]'s syndicate request.")
		var/input = input(src.owner, "Please enter a message to reply to [key_name(H)] via their headset.","Outgoing message from The Syndicate", "")
		if(!input)
			message_admins("[src.owner] decided not to answer [key_name(H)]'s syndicate request.")
			return

		to_chat(src.owner, "You sent [input] to [H] via a secure channel.")
		log_admin("[src.owner] replied to [key_name(H)]'s Syndicate message with the message [input].")
		message_admins("[src.owner] replied to [key_name(H)]'s Syndicate message with: \"[input]\"")
		to_chat(H, "You hear something crackle in your ears for a moment before a voice speaks.  \"Please stand by for a message from your benefactor.  Message as follows, agent. [input].  Message ends.\"")

	else if(href_list["reject_custom_name"])
		if(!check_rights(R_ADMIN))
			return
		var/obj/item/station_charter/charter = locate(href_list["reject_custom_name"])
		if(istype(charter))
			charter.reject_proposed(usr)
	else if(href_list["jumpto"])
		if(!isobserver(usr) && !check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["jumpto"])
		usr.client.jumptomob(M)

	else if(href_list["getmob"])
		if(!check_rights(R_ADMIN))
			return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return
		var/mob/M = locate(href_list["getmob"])
		usr.client.Getmob(M)

	else if(href_list["sendmob"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["sendmob"])
		usr.client.sendmob(M)

	else if(href_list["narrateto"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["narrateto"])
		usr.client.cmd_admin_direct_narrate(M)

	else if(href_list["subtlemessage"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["subtlemessage"])
		usr.client.cmd_admin_subtle_message(M)

	else if(href_list["individuallog"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["individuallog"]) in GLOB.mob_list
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob.")
			return

		show_individual_logging_panel(M, href_list["log_type"])
	else if(href_list["languagemenu"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["languagemenu"]) in GLOB.mob_list
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob.")
			return
		var/datum/language_holder/H = M.get_language_holder()
		H.open_language_menu(usr)

	else if(href_list["traitor"])
		if(!check_rights(R_ADMIN))
			return

		if(!SSticker.HasRoundStarted())
			alert("The game hasn't started yet!")
			return

		var/mob/M = locate(href_list["traitor"])
		if(!ismob(M))
			var/datum/mind/D = M
			if(!istype(D))
				to_chat(usr, "This can only be used on instances of type /mob and /mind")
				return
			else
				D.traitor_panel()
		else
			show_traitor_panel(M)

	else if(href_list["initmind"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["initmind"])
		if(!ismob(M) || M.mind)
			to_chat(usr, "This can only be used on instances on mindless mobs")
			return
		M.mind_initialize()

	else if(href_list["create_object"])
		if(!check_rights(R_SPAWN))
			return
		return create_object(usr)

	else if(href_list["quick_create_object"])
		if(!check_rights(R_SPAWN))
			return
		return quick_create_object(usr)

	else if(href_list["create_turf"])
		if(!check_rights(R_SPAWN))
			return
		return create_turf(usr)

	else if(href_list["create_mob"])
		if(!check_rights(R_SPAWN))
			return
		return create_mob(usr)

	else if(href_list["dupe_marked_datum"])
		if(!check_rights(R_SPAWN))
			return
		return DuplicateObject(marked_datum, perfectcopy=1, newloc=get_turf(usr))

	else if(href_list["object_list"])			//this is the laggiest thing ever
		if(!check_rights(R_SPAWN))
			return

		var/atom/loc = usr.loc

		var/dirty_paths
		if (istext(href_list["object_list"]))
			dirty_paths = list(href_list["object_list"])
		else if (istype(href_list["object_list"], /list))
			dirty_paths = href_list["object_list"]

		var/paths = list()

		for(var/dirty_path in dirty_paths)
			var/path = text2path(dirty_path)
			if(!path)
				continue
			else if(!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
				continue
			paths += path

		if(!paths)
			alert("The path list you sent is empty.")
			return
		if(length(paths) > 5)
			alert("Select fewer object types, (max 5).")
			return

		var/list/offset = splittext(href_list["offset"],",")
		var/number = CLAMP(text2num(href_list["object_count"]), 1, 100)
		var/X = offset.len > 0 ? text2num(offset[1]) : 0
		var/Y = offset.len > 1 ? text2num(offset[2]) : 0
		var/Z = offset.len > 2 ? text2num(offset[3]) : 0
		var/tmp_dir = href_list["object_dir"]
		var/obj_dir = tmp_dir ? text2num(tmp_dir) : 2
		if(!obj_dir || !(obj_dir in list(1,2,4,8,5,6,9,10)))
			obj_dir = 2
		var/obj_name = sanitize(href_list["object_name"])


		var/atom/target //Where the object will be spawned
		var/where = href_list["object_where"]
		if (!( where in list("onfloor","inhand","inmarked") ))
			where = "onfloor"


		switch(where)
			if("inhand")
				if (!iscarbon(usr) && !iscyborg(usr))
					to_chat(usr, "Can only spawn in hand when you're a carbon mob or cyborg.")
					where = "onfloor"
				target = usr

			if("onfloor")
				switch(href_list["offset_type"])
					if ("absolute")
						target = locate(0 + X,0 + Y,0 + Z)
					if ("relative")
						target = locate(loc.x + X,loc.y + Y,loc.z + Z)
			if("inmarked")
				if(!marked_datum)
					to_chat(usr, "You don't have any object marked. Abandoning spawn.")
					return
				else if(!istype(marked_datum, /atom))
					to_chat(usr, "The object you have marked cannot be used as a target. Target must be of type /atom. Abandoning spawn.")
					return
				else
					target = marked_datum

		if(target)
			for (var/path in paths)
				for (var/i = 0; i < number; i++)
					if(path in typesof(/turf))
						var/turf/O = target
						var/turf/N = O.ChangeTurf(path)
						if(N && obj_name)
							N.name = obj_name
					else
						var/atom/O = new path(target)
						if(O)
							O.admin_spawned = TRUE
							O.setDir(obj_dir)
							if(obj_name)
								O.name = obj_name
								if(ismob(O))
									var/mob/M = O
									M.real_name = obj_name
							if(where == "inhand" && isliving(usr) && isitem(O))
								var/mob/living/L = usr
								var/obj/item/I = O
								L.put_in_hands(I)
								if(iscyborg(L))
									var/mob/living/silicon/robot/R = L
									if(R.module)
										R.module.add_module(I, TRUE, TRUE)
										R.activate_module(I)


		if (number == 1)
			log_admin("[key_name(usr)] created a [english_list(paths)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created a [english_list(paths)]")
					break
		else
			log_admin("[key_name(usr)] created [number]ea [english_list(paths)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created [number]ea [english_list(paths)]")
					break
		return

	else if(href_list["secrets"])
		Secrets_topic(href_list["secrets"],href_list)

	else if(href_list["ac_view_wanted"])            //Admin newscaster Topic() stuff be here
		if(!check_rights(R_ADMIN))
			return
		src.admincaster_screen = 18                 //The ac_ prefix before the hrefs stands for AdminCaster.
		src.access_news_network()

	else if(href_list["ac_set_channel_name"])
		if(!check_rights(R_ADMIN))
			return
		src.admincaster_feed_channel.channel_name = stripped_input(usr, "Provide a Feed Channel Name.", "Network Channel Handler", "")
		while (findtext(src.admincaster_feed_channel.channel_name," ") == 1)
			src.admincaster_feed_channel.channel_name = copytext(src.admincaster_feed_channel.channel_name,2,lentext(src.admincaster_feed_channel.channel_name)+1)
		src.access_news_network()

	else if(href_list["ac_set_channel_lock"])
		if(!check_rights(R_ADMIN))
			return
		src.admincaster_feed_channel.locked = !src.admincaster_feed_channel.locked
		src.access_news_network()

	else if(href_list["ac_submit_new_channel"])
		if(!check_rights(R_ADMIN))
			return
		var/check = 0
		for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
			if(FC.channel_name == src.admincaster_feed_channel.channel_name)
				check = 1
				break
		if(src.admincaster_feed_channel.channel_name == "" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]" || check )
			src.admincaster_screen=7
		else
			var/choice = alert("Please confirm Feed channel creation.","Network Channel Handler","Confirm","Cancel")
			if(choice=="Confirm")
				GLOB.news_network.CreateFeedChannel(src.admincaster_feed_channel.channel_name, src.admin_signature, src.admincaster_feed_channel.locked, 1)
				SSblackbox.record_feedback("tally", "newscaster_channels", 1, src.admincaster_feed_channel.channel_name)
				log_admin("[key_name(usr)] created command feed channel: [src.admincaster_feed_channel.channel_name]!")
				src.admincaster_screen=5
		src.access_news_network()

	else if(href_list["ac_set_channel_receiving"])
		if(!check_rights(R_ADMIN))
			return
		var/list/available_channels = list()
		for(var/datum/newscaster/feed_channel/F in GLOB.news_network.network_channels)
			available_channels += F.channel_name
		src.admincaster_feed_channel.channel_name = adminscrub(input(usr, "Choose receiving Feed Channel.", "Network Channel Handler") in available_channels )
		src.access_news_network()

	else if(href_list["ac_set_new_message"])
		if(!check_rights(R_ADMIN))
			return
		src.admincaster_feed_message.body = adminscrub(input(usr, "Write your Feed story.", "Network Channel Handler", ""))
		while (findtext(src.admincaster_feed_message.returnBody(-1)," ") == 1)
			src.admincaster_feed_message.body = copytext(src.admincaster_feed_message.returnBody(-1),2,lentext(src.admincaster_feed_message.returnBody(-1))+1)
		src.access_news_network()

	else if(href_list["ac_submit_new_message"])
		if(!check_rights(R_ADMIN))
			return
		if(src.admincaster_feed_message.returnBody(-1) =="" || src.admincaster_feed_message.returnBody(-1) =="\[REDACTED\]" || src.admincaster_feed_channel.channel_name == "" )
			src.admincaster_screen = 6
		else
			GLOB.news_network.SubmitArticle(src.admincaster_feed_message.returnBody(-1), src.admin_signature, src.admincaster_feed_channel.channel_name, null, 1)
			SSblackbox.record_feedback("amount", "newscaster_stories", 1)
			src.admincaster_screen=4

		for(var/obj/machinery/newscaster/NEWSCASTER in GLOB.allCasters)
			NEWSCASTER.newsAlert(src.admincaster_feed_channel.channel_name)

		log_admin("[key_name(usr)] submitted a feed story to channel: [src.admincaster_feed_channel.channel_name]!")
		src.access_news_network()

	else if(href_list["ac_create_channel"])
		if(!check_rights(R_ADMIN))
			return
		src.admincaster_screen=2
		src.access_news_network()

	else if(href_list["ac_create_feed_story"])
		if(!check_rights(R_ADMIN))
			return
		src.admincaster_screen=3
		src.access_news_network()

	else if(href_list["ac_menu_censor_story"])
		if(!check_rights(R_ADMIN))
			return
		src.admincaster_screen=10
		src.access_news_network()

	else if(href_list["ac_menu_censor_channel"])
		if(!check_rights(R_ADMIN))
			return
		src.admincaster_screen=11
		src.access_news_network()

	else if(href_list["ac_menu_wanted"])
		if(!check_rights(R_ADMIN))
			return
		var/already_wanted = 0
		if(GLOB.news_network.wanted_issue.active)
			already_wanted = 1

		if(already_wanted)
			src.admincaster_wanted_message.criminal  = GLOB.news_network.wanted_issue.criminal
			src.admincaster_wanted_message.body = GLOB.news_network.wanted_issue.body
		src.admincaster_screen = 14
		src.access_news_network()

	else if(href_list["ac_set_wanted_name"])
		if(!check_rights(R_ADMIN))
			return
		src.admincaster_wanted_message.criminal = adminscrub(input(usr, "Provide the name of the Wanted person.", "Network Security Handler", ""))
		while(findtext(src.admincaster_wanted_message.criminal," ") == 1)
			src.admincaster_wanted_message.criminal = copytext(admincaster_wanted_message.criminal,2,lentext(admincaster_wanted_message.criminal)+1)
		src.access_news_network()

	else if(href_list["ac_set_wanted_desc"])
		if(!check_rights(R_ADMIN))
			return
		src.admincaster_wanted_message.body = adminscrub(input(usr, "Provide the a description of the Wanted person and any other details you deem important.", "Network Security Handler", ""))
		while (findtext(src.admincaster_wanted_message.body," ") == 1)
			src.admincaster_wanted_message.body = copytext(src.admincaster_wanted_message.body,2,lentext(src.admincaster_wanted_message.body)+1)
		src.access_news_network()

	else if(href_list["ac_submit_wanted"])
		if(!check_rights(R_ADMIN))
			return
		var/input_param = text2num(href_list["ac_submit_wanted"])
		if(src.admincaster_wanted_message.criminal == "" || src.admincaster_wanted_message.body == "")
			src.admincaster_screen = 16
		else
			var/choice = alert("Please confirm Wanted Issue [(input_param==1) ? ("creation.") : ("edit.")]","Network Security Handler","Confirm","Cancel")
			if(choice=="Confirm")
				if(input_param==1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one. See the else below
					GLOB.news_network.submitWanted(admincaster_wanted_message.criminal, admincaster_wanted_message.body, admin_signature, null, 1, 1)
					src.admincaster_screen = 15
				else
					GLOB.news_network.submitWanted(admincaster_wanted_message.criminal, admincaster_wanted_message.body, admin_signature)
					src.admincaster_screen = 19
				log_admin("[key_name(usr)] issued a Station-wide Wanted Notification for [src.admincaster_wanted_message.criminal]!")
		src.access_news_network()

	else if(href_list["ac_cancel_wanted"])
		if(!check_rights(R_ADMIN))
			return
		var/choice = alert("Please confirm Wanted Issue removal.","Network Security Handler","Confirm","Cancel")
		if(choice=="Confirm")
			GLOB.news_network.deleteWanted()
			src.admincaster_screen=17
		src.access_news_network()

	else if(href_list["ac_censor_channel_author"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/newscaster/feed_channel/FC = locate(href_list["ac_censor_channel_author"])
		FC.toggleCensorAuthor()
		src.access_news_network()

	else if(href_list["ac_censor_channel_story_author"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/newscaster/feed_message/MSG = locate(href_list["ac_censor_channel_story_author"])
		MSG.toggleCensorAuthor()
		src.access_news_network()

	else if(href_list["ac_censor_channel_story_body"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/newscaster/feed_message/MSG = locate(href_list["ac_censor_channel_story_body"])
		MSG.toggleCensorBody()
		src.access_news_network()

	else if(href_list["ac_pick_d_notice"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/newscaster/feed_channel/FC = locate(href_list["ac_pick_d_notice"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen=13
		src.access_news_network()

	else if(href_list["ac_toggle_d_notice"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/newscaster/feed_channel/FC = locate(href_list["ac_toggle_d_notice"])
		FC.toggleCensorDclass()
		src.access_news_network()

	else if(href_list["ac_view"])
		if(!check_rights(R_ADMIN))
			return
		src.admincaster_screen=1
		src.access_news_network()

	else if(href_list["ac_setScreen"]) //Brings us to the main menu and resets all fields~
		if(!check_rights(R_ADMIN))
			return
		src.admincaster_screen = text2num(href_list["ac_setScreen"])
		if (src.admincaster_screen == 0)
			if(src.admincaster_feed_channel)
				src.admincaster_feed_channel = new /datum/newscaster/feed_channel
			if(src.admincaster_feed_message)
				src.admincaster_feed_message = new /datum/newscaster/feed_message
			if(admincaster_wanted_message)
				admincaster_wanted_message = new /datum/newscaster/wanted_message
		src.access_news_network()

	else if(href_list["ac_show_channel"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/newscaster/feed_channel/FC = locate(href_list["ac_show_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 9
		src.access_news_network()

	else if(href_list["ac_pick_censor_channel"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/newscaster/feed_channel/FC = locate(href_list["ac_pick_censor_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 12
		src.access_news_network()

	else if(href_list["ac_refresh"])
		if(!check_rights(R_ADMIN))
			return
		src.access_news_network()

	else if(href_list["ac_set_signature"])
		if(!check_rights(R_ADMIN))
			return
		src.admin_signature = adminscrub(input(usr, "Provide your desired signature.", "Network Identity Handler", ""))
		src.access_news_network()

	else if(href_list["ac_del_comment"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/newscaster/feed_comment/FC = locate(href_list["ac_del_comment"])
		var/datum/newscaster/feed_message/FM = locate(href_list["ac_del_comment_msg"])
		FM.comments -= FC
		qdel(FC)
		src.access_news_network()

	else if(href_list["ac_lock_comment"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/newscaster/feed_message/FM = locate(href_list["ac_lock_comment"])
		FM.locked ^= 1
		src.access_news_network()

	else if(href_list["check_antagonist"])
		if(!check_rights(R_ADMIN))
			return
		usr.client.check_antagonists()

	else if(href_list["kick_all_from_lobby"])
		if(!check_rights(R_ADMIN))
			return
		if(SSticker.IsRoundInProgress())
			var/afkonly = text2num(href_list["afkonly"])
			if(alert("Are you sure you want to kick all [afkonly ? "AFK" : ""] clients from the lobby??","Message","Yes","Cancel") != "Yes")
				to_chat(usr, "Kick clients from lobby aborted")
				return
			var/list/listkicked = kick_clients_in_lobby("<span class='danger'>You were kicked from the lobby by [usr.client.holder.fakekey ? "an Administrator" : "[usr.client.ckey]"].</span>", afkonly)

			var/strkicked = ""
			for(var/name in listkicked)
				strkicked += "[name], "
			message_admins("[key_name_admin(usr)] has kicked [afkonly ? "all AFK" : "all"] clients from the lobby. [length(listkicked)] clients kicked: [strkicked ? strkicked : "--"]")
			log_admin("[key_name(usr)] has kicked [afkonly ? "all AFK" : "all"] clients from the lobby. [length(listkicked)] clients kicked: [strkicked ? strkicked : "--"]")
		else
			to_chat(usr, "You may only use this when the game is running.")

	else if(href_list["create_outfit"])
		if(!check_rights(R_ADMIN))
			return

		var/datum/outfit/O = new /datum/outfit
		//swap this for js dropdowns sometime
		O.name = href_list["outfit_name"]
		O.uniform = text2path(href_list["outfit_uniform"])
		O.shoes = text2path(href_list["outfit_shoes"])
		O.gloves = text2path(href_list["outfit_gloves"])
		O.suit = text2path(href_list["outfit_suit"])
		O.head = text2path(href_list["outfit_head"])
		O.back = text2path(href_list["outfit_back"])
		O.mask = text2path(href_list["outfit_mask"])
		O.glasses = text2path(href_list["outfit_glasses"])
		O.r_hand = text2path(href_list["outfit_r_hand"])
		O.l_hand = text2path(href_list["outfit_l_hand"])
		O.suit_store = text2path(href_list["outfit_s_store"])
		O.l_pocket = text2path(href_list["outfit_l_pocket"])
		O.r_pocket = text2path(href_list["outfit_r_pocket"])
		O.id = text2path(href_list["outfit_id"])
		O.belt = text2path(href_list["outfit_belt"])
		O.ears = text2path(href_list["outfit_ears"])

		GLOB.custom_outfits.Add(O)
		message_admins("[key_name(usr)] created \"[O.name]\" outfit!")

	else if(href_list["set_selfdestruct_code"])
		if(!check_rights(R_ADMIN))
			return
		var/code = random_nukecode()
		for(var/obj/machinery/nuclearbomb/selfdestruct/SD in GLOB.nuke_list)
			SD.r_code = code
		message_admins("[key_name_admin(usr)] has set the self-destruct \
			code to \"[code]\".")

	else if(href_list["add_station_goal"])
		if(!check_rights(R_ADMIN))
			return
		var/list/type_choices = typesof(/datum/station_goal)
		var/picked = input("Choose goal type") in type_choices|null
		if(!picked)
			return
		var/datum/station_goal/G = new picked()
		if(picked == /datum/station_goal)
			var/newname = input("Enter goal name:") as text|null
			if(!newname)
				return
			G.name = newname
			var/description = input("Enter CentCom message contents:") as message|null
			if(!description)
				return
			G.report_message = description
		message_admins("[key_name(usr)] created \"[G.name]\" station goal.")
		SSticker.mode.station_goals += G
		modify_goals()

	else if(href_list["viewruntime"])
		var/datum/error_viewer/error_viewer = locate(href_list["viewruntime"])
		if(!istype(error_viewer))
			to_chat(usr, "<span class='warning'>That runtime viewer no longer exists.</span>")
			return

		if(href_list["viewruntime_backto"])
			error_viewer.show_to(owner, locate(href_list["viewruntime_backto"]), href_list["viewruntime_linear"])
		else
			error_viewer.show_to(owner, null, href_list["viewruntime_linear"])

	else if(href_list["showrelatedacc"])
		if(!check_rights(R_ADMIN))
			return
		var/client/C = locate(href_list["client"]) in GLOB.clients
		var/thing_to_check
		if(href_list["showrelatedacc"] == "cid")
			thing_to_check = C.related_accounts_cid
		else
			thing_to_check = C.related_accounts_ip
		thing_to_check = splittext(thing_to_check, ", ")


		var/list/dat = list("Related accounts by [uppertext(href_list["showrelatedacc"])]:")
		dat += thing_to_check

		usr << browse(dat.Join("<br>"), "window=related_[C];size=420x300")

	else if(href_list["modantagrep"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["mob"]) in GLOB.mob_list
		var/client/C = M.client
		usr.client.cmd_admin_mod_antag_rep(C, href_list["modantagrep"])
		show_player_panel(M)

/datum/admins/proc/HandleCMode()
	if(!check_rights(R_ADMIN))
		return

	if(SSticker.HasRoundStarted())
		return alert(usr, "The game has already started.", null, null, null, null)
	var/dat = {"<B>What mode do you wish to play?</B><HR>"}
	for(var/mode in config.modes)
		dat += {"<A href='?src=[REF(src)];[HrefToken()];c_mode2=[mode]'>[config.mode_names[mode]]</A><br>"}
	dat += {"<A href='?src=[REF(src)];[HrefToken()];c_mode2=secret'>Secret</A><br>"}
	dat += {"<A href='?src=[REF(src)];[HrefToken()];c_mode2=random'>Random</A><br>"}
	dat += {"Now: [GLOB.master_mode]"}
	usr << browse(dat, "window=c_mode")

/datum/admins/proc/HandleFSecret()
	if(!check_rights(R_ADMIN))
		return

	if(SSticker.HasRoundStarted())
		return alert(usr, "The game has already started.", null, null, null, null)
	if(GLOB.master_mode != "secret")
		return alert(usr, "The game mode has to be secret!", null, null, null, null)
	var/dat = {"<B>What game mode do you want to force secret to be? Use this if you want to change the game mode, but want the players to believe it's secret. This will only work if the current game mode is secret.</B><HR>"}
	for(var/mode in config.modes)
		dat += {"<A href='?src=[REF(src)];[HrefToken()];f_secret2=[mode]'>[config.mode_names[mode]]</A><br>"}
	dat += {"<A href='?src=[REF(src)];[HrefToken()];f_secret2=secret'>Random (default)</A><br>"}
	dat += {"Now: [GLOB.secret_force_mode]"}
	usr << browse(dat, "window=f_secret")
