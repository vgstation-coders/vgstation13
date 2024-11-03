/datum/admins/Topic(href, href_list)
	..()

	if(usr.client != src.owner || !check_rights(0))
		log_admin("[key_name(usr)] tried to use the admin panel without authorization.")
		message_admins("[usr.key] has attempted to override the admin panel!")
		return

	var/client/CLIENT = usr.client
	if(href_list["makeAntag"])
		if(!ticker.mode)
			to_chat(usr, "The round has not started yet,")
			return
		var/count = input("How many antags would you like to create?","Create Antagonists") as num|null
		if(!count)
			return
		switch(href_list["makeAntag"])
			if("1")
				message_admins("[key_name(usr)] has attempted to spawn [count] traitors.")
				var/success = makeAntag(/datum/role/traitor, null, count, FROM_PLAYERS)
				message_admins("[success] traitors made.")
			if("2")
				message_admins("[key_name(usr)] has attempted to spawn [count] changelings.")
				var/success = makeAntag(/datum/role/changeling, null, count, FROM_PLAYERS)
				message_admins("[success] changelings made.")
			if("3")
				message_admins("[key_name(usr)] has attempted to spawn [count] revolutionaries.")
				var/success = makeAntag(null, /datum/faction/revolution, count, FROM_PLAYERS)
				message_admins("[success] revolutionaries made.")
			if("4")
				message_admins("[key_name(usr)] has attempted to spawn [count] cultists.")
				var/success = makeAntag(null, /datum/faction/bloodcult, count , FROM_PLAYERS)
				message_admins("[success] cultists made.")
			if("5")
				message_admins("[key_name(usr)] has attempted to spawn [count] malfunctioning AI.")
				var/success = makeAntag(null, /datum/faction/malf, count, FROM_PLAYERS)
				message_admins("[success] angry computer screens made.")
			if("6")
				message_admins("[key_name(usr)] has attempted to spawn [count] wizards.")
				var/success = makeAntag(null, /datum/faction/wizard, count, FROM_GHOSTS)
				message_admins("[success] wizards made.")
			if("7")
				message_admins("[key_name(usr)] has attempted to spawn [count] vampires.")
				var/success = makeAntag(/datum/role/vampire, null, count, FROM_PLAYERS)
				message_admins("[success] vampires made.")
			if("8")
				message_admins("[key_name(usr)] has spawned aliens.")
				if(!src.makeAliens())
					message_admins("Unfortunately, there were no candidates available.")

	if("announce_laws" in href_list)
		var/mob/living/silicon/S = locate(href_list["mob"])

		log_admin("[key_name(usr)] has notified [key_name(S)] of a change to their laws.")
		message_admins("[usr.key] has notified [key_name(S)] of a change to their laws.")

		S << sound('sound/machines/lawsync.ogg')
		if(isrobot(S))
			S.throw_alert(SCREEN_ALARM_ROBOT_LAW, /obj/abstract/screen/alert/robot/newlaw)
		to_chat(S, "____________________________________")
		to_chat(S, "<span class='danger'>LAW CHANGE NOTICE</span>")
		if(S.laws)
			to_chat(S, "<b>Your new laws are as follows:</b>")
			S.laws.show_laws(S)
		else
			to_chat(S, "<b>Your laws are null.</b> Contact a coder immediately.")
		to_chat(S, "____________________________________")
		if(isAI(S))
			var/mob/living/silicon/ai/AI=S
			AI.notify_slaved(force_sync=1)

	else if("add_law" in href_list)
		var/mob/living/silicon/S = locate(href_list["mob"])
		var/lawtypes = list(
			"Law Zero"= LAW_ZERO,
			"Ion"     = LAW_IONIC,
			"Core"    = LAW_INHERENT,
			"Standard"= 1
		)
		var/lawtype = input("Select a law type.","Law Type",1) as anything in lawtypes
		lawtype=lawtypes[lawtype]
		if(lawtype == null)
			return
		//testing("Lawtype: [lawtype]")
		if(lawtype==1)
			lawtype=text2num(input("Enter desired law priority. (15-50)","Priority", 15) as num)
			lawtype=clamp(lawtype,15,50)
		var/newlaw = copytext(sanitize(input(usr, "Please enter a new law for the AI.", "Freeform Law Entry", "")),1,MAX_MESSAGE_LEN)
		if(newlaw=="")
			return
		S.laws.add_law(lawtype,newlaw)

		log_admin("[key_name(usr)] has added a law to [key_name(S)]: \"[newlaw]\"")
		message_admins("[usr.key] has added a law to [key_name(S)]: \"[newlaw]\"")
		lawchanges.Add("[key_name(usr)] has added a law to [key_name(S)]: \"[newlaw]\"")

	else if("reset_laws" in href_list)
		var/mob/living/silicon/S = locate(href_list["mob"])
		var/lawtypes = typesof(/datum/ai_laws) - /datum/ai_laws
		var/lawtype = input("Select a lawset.","Law Type",1) as null|anything in lawtypes
		if(lawtype == null)
			return
		//testing("Lawtype: [lawtype]")

		var/law_zeroth = ""
		var/law_zeroth_borg = ""
		if(S.laws.zeroth || S.laws.zeroth_borg)
			if(alert(src,"Do you also wish to clear law zero?","Yes","No") == "No")
				law_zeroth = S.laws.zeroth
				law_zeroth_borg = S.laws.zeroth
			else
				S.laws.zeroth_lock = FALSE

		S.laws = new lawtype
		S.laws.zeroth = law_zeroth
		S.laws.zeroth_borg = law_zeroth_borg

		log_admin("[key_name(usr)] has reset [key_name(S)]: [lawtype]")
		message_admins("[usr.key] has reset [key_name(S)]: [lawtype]")
		lawchanges.Add("[key_name(usr)] has reset [key_name(S)]: [lawtype]")

	else if("clear_laws" in href_list)
		var/mob/living/silicon/S = locate(href_list["mob"])
		S.laws.clear_inherent_laws()
		S.laws.clear_supplied_laws()
		S.laws.clear_ion_laws()

		if(S.laws.zeroth || S.laws.zeroth_borg)
			if(alert(src,"Do you also wish to clear law zero?","Yes","No") == "Yes")
				S.laws.set_zeroth_law("","")

		log_admin("[key_name(usr)] has purged [key_name(S)]")
		message_admins("[usr.key] has purged [key_name(S)]")
		lawchanges.Add("[key_name(usr)] has purged [key_name(S)]")

	else if(href_list["dbsearchckey"] || href_list["dbsearchadmin"])
		var/adminckey = href_list["dbsearchadmin"]
		var/playerckey = href_list["dbsearchckey"]

		DB_ban_panel(playerckey, adminckey)
		return

	else if(href_list["dbbanedit"])
		var/banedit = href_list["dbbanedit"]
		var/banid = text2num(href_list["dbbanid"])
		if(!banedit || !banid)
			return

		DB_ban_edit(banid, banedit)
		return

	else if(href_list["dbbanaddtype"])

		var/bantype = text2num(href_list["dbbanaddtype"])
		var/banckey = href_list["dbbanaddckey"]
		var/banduration = text2num(href_list["dbbaddduration"])
		var/banjob = href_list["dbbanaddjob"]
		var/banreason = href_list["dbbanreason"]

		banckey = ckey(banckey)

		switch(bantype)
			if(BANTYPE_PERMA)
				if(!banckey || !banreason)
					to_chat(usr, "Not enough parameters (Requires ckey and reason)")
					return
				banduration = null
				banjob = null
			if(BANTYPE_TEMP)
				if(!banckey || !banreason || !banduration)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and duration)")
					return
				banjob = null
			if(BANTYPE_JOB_PERMA)
				if(!banckey || !banreason || !banjob)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and job)")
					return
				banduration = null
			if(BANTYPE_JOB_TEMP)
				if(!banckey || !banreason || !banjob || !banduration)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and job)")
					return
			if(BANTYPE_APPEARANCE)
				if(!banckey || !banreason)
					to_chat(usr, "Not enough parameters (Requires ckey and reason)")
					return
				banduration = null
				banjob = null
			if(BANTYPE_OOC_PERMA,  BANTYPE_PAX_PERMA)
				if(!banckey || !banreason)
					to_chat(usr, "Not enough parameters (Requires ckey and reason)")
					return
				banduration = null
			if(BANTYPE_OOC_TEMP, BANTYPE_PAX_TEMP)
				if(!banckey || !banreason || !banduration)
					to_chat(usr, "Not enough parameters (Requires ckey, reason, and duration)")
					return

		var/mob/playermob

		for(var/mob/M in player_list)
			if(M.ckey == banckey)
				playermob = M
				break

		banreason = "(MANUAL BAN) "+banreason

		DB_ban_record(bantype, playermob, banduration, banreason, banjob, null, banckey)

	else if(href_list["editrights"])
		if(!check_rights(R_PERMISSIONS))
			message_admins("[key_name_admin(usr)] attempted to edit the admin permissions without sufficient rights.")
			log_admin("[key_name(usr)] attempted to edit the admin permissions without sufficient rights.")
			return

		var/adm_ckey

		var/task = href_list["editrights"]
		if(task == "add")
			var/new_ckey = ckey(input(usr,"New admin's ckey","Admin ckey", null) as text|null)
			if(!new_ckey)
				return
			if(new_ckey in admin_datums)
				to_chat(usr, "<span class='red'>Error: Topic 'editrights': [new_ckey] is already an admin</span>")
				return
			adm_ckey = new_ckey
			task = "rank"
		else if(task != "show")
			adm_ckey = ckey(href_list["ckey"])
			if(!adm_ckey)
				to_chat(usr, "<span class='red'>Error: Topic 'editrights': No valid ckey</span>")
				return

		var/datum/admins/D = admin_datums[adm_ckey]

		if(task == "remove")
			if(alert("Are you sure you want to remove [adm_ckey]?","Message","Yes","Cancel") == "Yes")
				if(!D)
					return
				admin_datums -= adm_ckey
				D.disassociate()
				update_byond_admin(adm_ckey)

				message_admins("[key_name_admin(usr)] removed [adm_ckey] from the admins list")
				log_admin("[key_name(usr)] removed [adm_ckey] from the admins list")
				log_admin_rank_modification(adm_ckey, "Removed")

		else if(task == "rank")
			var/new_rank
			if(admin_ranks.len)
				new_rank = input("Please select a rank", "New rank", null, null) as null|anything in (admin_ranks|"*New Rank*")
			else
				new_rank = input("Please select a rank", "New rank", null, null) as null|anything in list("Game Master","Game Admin", "Trial Admin", "Admin Observer","*New Rank*")

			var/rights = 0
			if(D)
				rights = D.rights
			switch(new_rank)
				if(null,"")
					return
				if("*New Rank*")
					new_rank = input("Please input a new rank", "New custom rank", null, null) as null|text
					if(config.admin_legacy_system)
						new_rank = ckeyEx(new_rank)
					if(!new_rank)
						to_chat(usr, "<span class='red'>Error: Topic 'editrights': Invalid rank</span>")
						return
					if(config.admin_legacy_system)
						if(admin_ranks.len)
							if(new_rank in admin_ranks)
								rights = admin_ranks[new_rank]		//we typed a rank which already exists, use its rights
							else
								admin_ranks[new_rank] = 0			//add the new rank to admin_ranks
				else
					if(config.admin_legacy_system)
						new_rank = ckeyEx(new_rank)
						rights = admin_ranks[new_rank]				//we input an existing rank, use its rights

			if(D)
				D.disassociate()								//remove adminverbs and unlink from client
				D.rank = new_rank								//update the rank
				D.rights = rights								//update the rights based on admin_ranks (default: 0)
			else
				D = new /datum/admins(new_rank, rights, adm_ckey)

			var/client/C = directory[adm_ckey]						//find the client with the specified ckey (if they are logged in)
			D.associate(C)											//link up with the client and add verbs
			update_byond_admin(adm_ckey)

			message_admins("[key_name_admin(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
			log_admin("[key_name(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
			log_admin_rank_modification(adm_ckey, new_rank)

		else if(task == "permissions")
			if(!D)
				return
			var/list/permissionlist = list()
			for(var/i=1, i<=R_MAXPERMISSION, i<<=1)		//that <<= is shorthand for i = i << 1. Which is a left bitshift
				permissionlist[rights2text(i)] = i
			var/new_permission = input("Select a permission to turn on/off", "Permission toggle", null, null) as null|anything in permissionlist
			if(!new_permission)
				return
			D.rights ^= permissionlist[new_permission]

			update_byond_admin(adm_ckey)
			D.update_menu_items()

			message_admins("[key_name_admin(usr)] toggled the [new_permission] permission of [adm_ckey]")
			log_admin("[key_name(usr)] toggled the [new_permission] permission of [adm_ckey]")
			log_admin_permission_modification(adm_ckey, permissionlist[new_permission])

		edit_admin_permissions()

	else if(href_list["call_shuttle"])
		if(!check_rights(R_ADMIN))
			return

		if( ticker.mode.name == "blob" )
			alert("You can't call the shuttle during blob!")
			return

		switch(href_list["call_shuttle"])
			if("1")
				if ((!( ticker ) || emergency_shuttle.location))
					return
				var/justification = stripped_input(usr, "Please input a reason for the shuttle call. You may leave it blank to not have one.", "Justification")
				emergency_shuttle.incall()
				var/datum/command_alert/emergency_shuttle_called/CA = new /datum/command_alert/emergency_shuttle_called
				CA.justification = justification
				command_alert(CA)
				log_admin("[key_name(usr)] called the Emergency Shuttle")
				message_admins("<span class='notice'>[key_name_admin(usr)] called the Emergency Shuttle to the station</span>", 1)

			if("2")
				if ((!( ticker ) || emergency_shuttle.location || emergency_shuttle.direction == 0))
					return
				switch(emergency_shuttle.direction)
					if(-1)
						emergency_shuttle.incall()
						command_alert(/datum/command_alert/emergency_shuttle_called)
						log_admin("[key_name(usr)] called the Emergency Shuttle")
						message_admins("<span class='notice'>[key_name_admin(usr)] called the Emergency Shuttle to the station</span>", 1)
					if(1)
						emergency_shuttle.recall()
						log_admin("[key_name(usr)] sent the Emergency Shuttle back")
						message_admins("<span class='notice'>[key_name_admin(usr)] sent the Emergency Shuttle back</span>", 1)

		href_list["secretsadmin"] = "emergency_shuttle_panel"

	else if(href_list["edit_shuttle_time"])
		if(!check_rights(R_SERVER))
			return

		var/new_timeleft = input("Enter new shuttle duration (seconds):","Edit Shuttle Timeleft", emergency_shuttle.timeleft() ) as num | null
		if(!new_timeleft)
			return

		var/reason
		var/should_announce = alert("Do you want this to be announced?",,"Yes","No","Cancel" )
		switch(should_announce)
			if("Yes")
				if(new_timeleft < emergency_shuttle.timeleft())
					reason = pick("is arriving ahead of schedule", \
								"hit the turbo", \
								"has engaged nitro afterburners")
					captain_announce("The emergency shuttle [reason]. It will arrive in [round(new_timeleft/60)] minutes.")
				else
					reason = pick("has been delayed", \
								"decided to stop for pizza")
					captain_announce("The emergency shuttle [reason]. It will arrive in [round(new_timeleft/60)] minutes.")
			if("Cancel")
				return

		emergency_shuttle.settimeleft( new_timeleft )
		log_admin("[key_name(usr)] edited the Emergency Shuttle's timeleft to [emergency_shuttle.timeleft()]")
		message_admins("<span class='notice'>[key_name_admin(usr)] edited the Emergency Shuttle's timeleft to [emergency_shuttle.timeleft()]</span>", 1)

		href_list["secretsadmin"] = "emergency_shuttle_panel"

	else if(href_list["move_emergency_shuttle"])
		if(!check_rights(R_ADMIN) || !check_rights(R_DEBUG))
			return
		var/casual = 1
		switch (href_list["move_emergency_shuttle"])
			if ("station")
				switch(alert("Trigger departure countdown and announcement?","Emergency Shuttle Panel","Yes","No","Cancel"))
					if("Cancel")
						return
					if("Yes")
						emergency_shuttle.online = 1
						emergency_shuttle.shuttle_phase("station",0)
						casual = 0
					if("No")
						emergency_shuttle.online = 0
						emergency_shuttle.direction = 0
						emergency_shuttle.endtime = null
						emergency_shuttle.shuttle_phase("station",1)

			if ("transit")
				switch(alert("Trigger arrival countdown and announcement?","Emergency Shuttle Panel","Yes","No","Cancel"))
					if("Cancel")
						return
					if("Yes")
						emergency_shuttle.online = 1
						emergency_shuttle.shuttle_phase("transit",0)
						casual = 0
					if("No")
						emergency_shuttle.online = 0
						emergency_shuttle.direction = 1
						emergency_shuttle.endtime = null
						emergency_shuttle.shuttle_phase("transit",1)
			if ("centcom")
				switch(alert("Trigger round end?","Emergency Shuttle Panel","Yes","No","Cancel"))
					if("Cancel")
						return
					if("Yes")
						emergency_shuttle.shuttle_phase("centcom",0)
						casual = 0
					if("No")
						emergency_shuttle.shuttle_phase("centcom",1)
		var/obj/docking_port/shuttle/P = emergency_shuttle.shuttle.linked_port
		log_admin("[key_name(usr)] moved the emergency shuttle to [href_list["move_emergency_shuttle"]][casual?" (no round triggers)":""].</span>")
		message_admins("<span class='notice'>[key_name_admin(usr)] moved the emergency shuttle to <a href='?_src_=holder;adminplayerobservecoodjump=1;X=[P.x];Y=[P.y];Z=[P.z]'>[href_list["move_emergency_shuttle"]]</a>[casual?" (no round triggers)":""].</span>", 1)
		href_list["secretsadmin"] = "emergency_shuttle_panel"

	else if(href_list["move_emergency_dock"])
		if(!check_rights(R_ADMIN) || !check_rights(R_DEBUG))
			return
		var/obj/docking_port/destination/port
		var/datum/shuttle/escape/E = emergency_shuttle.shuttle
		switch (href_list["move_emergency_dock"])
			if ("station")
				port = E.dock_station
			if ("transit")
				port = E.transit_port
			if ("centcom")
				port = E.dock_centcom
		if (!port) return
		port.forceMove(get_turf(usr.loc))
		log_admin("[key_name(usr)] moved the emergency shuttle's [href_list["move_emergency_dock"]] port.</span>")
		message_admins("<span class='notice'>[key_name_admin(usr)] moved the emergency shuttle's <a href='?_src_=holder;adminplayerobservecoodjump=1;X=[port.x];Y=[port.y];Z=[port.z]'>[href_list["move_emergency_dock"]] port</a>.</span>", 1)
		href_list["secretsadmin"] = "emergency_shuttle_panel"

	else if(href_list["reset_emergency_dock"])
		if(!check_rights(R_ADMIN) || !check_rights(R_DEBUG))
			return
		var/obj/docking_port/destination/port
		var/datum/shuttle/escape/E = emergency_shuttle.shuttle
		switch (href_list["reset_emergency_dock"])
			if ("station")
				port = E.dock_station
			if ("transit")
				port = E.transit_port
			if ("centcom")
				port = E.dock_centcom
		if (!port) return
		port.forceMove(port.origin_turf)
		log_admin("[key_name(usr)] reset the emergency shuttle's [href_list["reset_emergency_dock"]] port's position.</span>")
		message_admins("<span class='notice'>[key_name_admin(usr)] reset the emergency shuttle's <a href='?_src_=holder;adminplayerobservecoodjump=1;X=[port.x];Y=[port.y];Z=[port.z]'>[href_list["reset_emergency_dock"]] port's position</a>.</span>", 1)
		href_list["secretsadmin"] = "emergency_shuttle_panel"

	else if(href_list["move_escape_pod"])
		if(!check_rights(R_ADMIN) || !check_rights(R_DEBUG))
			return

		if (href_list["move_escape_pod"] == "all")
			for (var/pod in emergency_shuttle.escape_pods)
				emergency_shuttle.move_pod(pod,href_list["move_destination"])
			log_admin("[key_name(usr)] moved all escape pods to [href_list["move_destination"]]")
			message_admins("<span class='notice'>[key_name_admin(usr)] moved all escape pods to [href_list["move_destination"]]</span>", 1)
		else
			var/datum/shuttle/escape/S = locate(href_list["move_escape_pod"])
			if(!emergency_shuttle.escape_pods.Find(S))
				return
			var/obj/docking_port/destination/D = S.current_port
			emergency_shuttle.move_pod(S,href_list["move_destination"])
			var/turf/T = get_turf(D)
			log_admin("[key_name(usr)] moved [S.name] from [D.areaname] to [href_list["move_destination"]]")
			message_admins("<span class='notice'>[key_name_admin(usr)] moved <a href='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[S.name]</a> from [D.areaname] to [href_list["move_destination"]]</span>", 1)
		href_list["secretsadmin"] = "emergency_shuttle_panel"




	else if(href_list["diseasepanel_examine"])
		if(!check_rights(R_ADMIN))
			return

		var/datum/disease2/disease/D = locate(href_list["diseasepanel_examine"])

		var/datum/browser/popup = new(usr, "\ref[D]", "[D.form] #[add_zero("[D.uniqueID]", 4)]-[add_zero("[D.subID]", 4)]", 600, 300, src)
		popup.set_content(D.get_info(TRUE))
		popup.open()

	else if(href_list["diseasepanel_toggledb"])
		if(!check_rights(R_ADMIN))
			return

		var/datum/disease2/disease/D = locate(href_list["diseasepanel_toggledb"])

		if ("[D.uniqueID]-[D.subID]" in virusDB)
			virusDB -= "[D.uniqueID]-[D.subID]"
		else
			D.addToDB()

		var/client/C = usr.client
		if(C.holder)
			C.holder.diseases_panel()

	else if(href_list["diseasepanel_infectedmobs"])
		if(!check_rights(R_ADMIN))
			return

		var/datum/disease2/disease/D = locate(href_list["diseasepanel_infectedmobs"])

		var/list/infctd_mobs = list()
		for (var/mob/living/L in mob_list)
			if ("[D.uniqueID]-[D.subID]" in L.virus2)
				infctd_mobs.Add(L)

		if (!infctd_mobs)
			return

		var/mob/living/L = input(usr, "Choose an infected mob to check", "Disease Panel") as null | anything in infctd_mobs
		if (!L)
			return
		if (!L.loc)
			to_chat(usr,"<span class='warning'>Mob is in nullspace!</span>")
			return
		SendAdminGhostTo(null,L)

	else if(href_list["diseasepanel_infecteditems"])
		if(!check_rights(R_ADMIN))
			return

		var/datum/disease2/disease/D = locate(href_list["diseasepanel_infecteditems"])

		var/list/infctd_items = list()
		for (var/obj/item/I in infected_items)
			if ("[D.uniqueID]-[D.subID]" in I.virus2)
				infctd_items.Add(I)

		if (!infctd_items)
			return

		var/obj/item/I = input(usr, "Choose an infected item to check", "Disease Panel") as null | anything in infctd_items
		if (!I)
			return
		if (!I.loc)
			to_chat(usr,"<span class='warning'>Item is in nullspace!</span>")
			return
		SendAdminGhostTo(get_turf(I),null)

	else if(href_list["diseasepanel_dishes"])
		if(!check_rights(R_ADMIN))
			return

		var/datum/disease2/disease/D = locate(href_list["diseasepanel_dishes"])

		var/list/dishes = list()
		for (var/obj/item/weapon/virusdish/dish in virusdishes)
			if (dish.contained_virus)
				if ("[D.uniqueID]-[D.subID]" == "[dish.contained_virus.uniqueID]-[dish.contained_virus.subID]")
					dishes.Add(dish)

		if (!dishes)
			return

		var/obj/item/weapon/virusdish/dish = input(usr, "Choose a growth dish to check", "Disease Panel") as null | anything in dishes
		if (!dish)
			return
		if (!dish.loc)
			to_chat(usr,"<span class='warning'>Dish is in nullspace!</span>")
			return
		SendAdminGhostTo(get_turf(dish),null)

	else if(href_list["artifactpanel_jumpto"])
		if(!check_rights(R_ADMIN))
			return

		var/turf/T = locate(href_list["artifactpanel_jumpto"])

		SendAdminGhostTo(T,null)

	else if(href_list["bodyarchivepanel_focus"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M
		var/datum/body_archive/archive = locate(href_list["bodyarchivepanel_focus"])
		if (archive.mind)
			if (archive.mind.current)
				M = archive.mind.current
			else
				to_chat(usr, "This archive's mind somehow has no current mob.")
				return
		else
			to_chat(usr, "This archive somehow lost the pointer to its mind.")
			return

		if (!M)
			return

		SendAdminGhostTo(null,M)

	else if(href_list["bodyarchivepanel_spawnnaked"])
		if(!check_rights(R_ADMIN))
			return

		var/datum/body_archive/archive = locate(href_list["bodyarchivepanel_spawnnaked"])

		archive.spawn_naked(get_turf(usr))

	else if(href_list["bodyarchivepanel_spawnclothed"])
		if(!check_rights(R_ADMIN))
			return

		var/datum/body_archive/archive = locate(href_list["bodyarchivepanel_spawnclothed"])

		archive.spawn_clothed(get_turf(usr))

	else if(href_list["bodyarchivepanel_transfer"])
		if(!check_rights(R_ADMIN))
			return

		var/datum/body_archive/archive = locate(href_list["bodyarchivepanel_transfer"])

		var/mob/M = archive.transfer(get_turf(usr))
		if (M)
			to_chat(usr, "Mind of [archive.name] sent inside \the [M].")
		else
			to_chat(usr, "Stand above the mindless mob into which you want to transfer this mind.")
			//beware of trying to assign two minds to the same body.

	else if(href_list["climate_timeleft"])
		if(!check_rights(R_ADMIN))
			return
		if(!map.climate)
			return
		var/datum/weather/W = map.climate.current_weather
		var/nu = input(usr, "Enter remaining time (nearest 2 seconds)", "Adjust Timeleft", W.timeleft / (1 SECONDS)) as null|num
		if(!nu)
			return
		W.timeleft = round(nu SECONDS,SS_WAIT_WEATHER)
		log_admin("[key_name(usr)] adjusted weather time.")
		message_admins("<span class='notice'>[key_name(usr)] adjusted weather time.</span>", 1)
		climate_panel()

	else if(href_list["climate_weather"])
		if(!check_rights(R_ADMIN))
			return
		if(!map.climate)
			return
		var/datum/climate/C = map.climate
		var/nu = input(usr, "Select New Weather", "Adjust Weather", C.current_weather.type) as null|anything in typesof(/datum/weather)
		if(!nu || nu == C.current_weather.type)
			return
		if(!ispath(nu))
			return
		C.change_weather(nu)
		C.forecast()
		log_admin("[key_name(usr)] adjusted weather type.")
		message_admins("<span class='notice'>[key_name(usr)] adjusted weather type.</span>", 1)
		climate_panel()

	else if(href_list["delay_round_end"])
		if(!check_rights(R_SERVER))
			return
		var/response = alert("Toggle round end delay? It is currently [ticker.delay_end?"delayed":"not delayed"]","Toggle round end delay","Yes","No")
		if(response != "Yes")
			return
		ticker.delay_end = !ticker.delay_end
		log_admin("[key_name(usr)] [ticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		message_admins("<span class='notice'>[key_name(usr)] [ticker.delay_end ? "delayed the round end" : "has made the round end normally"].</span>", 1)
		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["edit_hub"])
		if(!check_rights(R_SERVER))
			return
		var/choice = href_list["edit_hub"]
		switch(choice)
			if("toggle")
				byond_hub_open = !byond_hub_open
				message_admins("<span class='notice'>[key_name(usr)] has turned byond hub availability [byond_hub_open ? "ON" : "OFF"]</span>")
				log_admin("[key_name(usr)] has turned byond hub availability [byond_hub_open ? "ON" : "OFF"]")
			if("playercount")
				var/tempcount = input("Hub access closes at how many players?", "Hub Playercount", byond_hub_playercount) as null|num
				if(tempcount)
					var/oldcount = byond_hub_playercount
					byond_hub_playercount = tempcount
					message_admins("<span class='notice'>[key_name(usr)] has set the max hub playercount to [byond_hub_playercount]</span>")
					log_admin("[key_name(usr)] has set the max hub playercount from [oldcount] to [byond_hub_playercount]")
			if("name")
				var/newname = input(usr, "Specify the new Server Name", "Server Name", byond_server_name) as null|text
				var/oldname = byond_server_name
				byond_server_name = newname ?  newname : DEFAULT_SERVER_NAME
				message_admins("<span class='notice'>[key_name(usr)] changed the hub name to [byond_server_name]</span>")
				log_admin("[key_name(usr)] changed the hub name from [oldname] to [byond_server_name]")
			if("desc")
				var/temp_desc = input(usr, "Specify the new Server Description", "Server Desc", byond_server_desc) as null|message
				if(temp_desc)
					var/old_desc = byond_server_desc
					byond_server_desc = temp_desc
					message_admins("<span class='notice'>[key_name(usr)] edited the hub description.</span>")
					log_admin("[key_name(usr)] edited the hub description from [old_desc] to [temp_desc]")

		var/datum/persistence_task/task = SSpersistence_misc.tasks["/datum/persistence_task/hub_settings"]
		task.on_shutdown()
		world.update_status()
		HubPanel()


	else if(href_list["simplemake"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/M = locate(href_list["mob"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/delmob = 0
		switch(alert("Delete old mob?","Message","Yes","No","Cancel"))
			if("Cancel")
				return
			if("Yes")
				delmob = 1

		log_admin("[key_name(usr)] has used rudimentary transformation on [key_name(M)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]")
		message_admins("<span class='notice'>[key_name_admin(usr)] has used rudimentary transformation on [key_name_admin(M)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]</span>", 1)
		var/mob/new_mob
		switch(href_list["simplemake"])
			if("observer")
				new_mob = M.change_mob_type( /mob/dead/observer , null, null, delmob )
			if("drone")
				new_mob = M.change_mob_type( /mob/living/carbon/alien/humanoid/drone , null, null, delmob )
			if("hunter")
				new_mob = M.change_mob_type( /mob/living/carbon/alien/humanoid/hunter , null, null, delmob )
			if("queen")
				new_mob = M.change_mob_type( /mob/living/carbon/alien/humanoid/queen , null, null, delmob )
			if("sentinel")
				new_mob = M.change_mob_type( /mob/living/carbon/alien/humanoid/sentinel , null, null, delmob )
			if("larva")
				new_mob = M.change_mob_type( /mob/living/carbon/alien/larva , null, null, delmob )
			if("human")
				new_mob = M.change_mob_type( /mob/living/carbon/human , null, null, delmob )
			if("slime")
				new_mob = M.change_mob_type( /mob/living/carbon/slime , null, null, delmob )
			if("adultslime")
				new_mob = M.change_mob_type( /mob/living/carbon/slime/adult , null, null, delmob )
			if("monkey")
				new_mob = M.change_mob_type( /mob/living/carbon/monkey , null, null, delmob )
			if("robot")
				new_mob = M.change_mob_type( /mob/living/silicon/robot , null, null, delmob )
			if("cat")
				new_mob = M.change_mob_type( /mob/living/simple_animal/cat , null, null, delmob )
			if("runtime")
				new_mob = M.change_mob_type( /mob/living/simple_animal/cat/Runtime , null, null, delmob )
			if("corgi")
				new_mob = M.change_mob_type( /mob/living/simple_animal/corgi , null, null, delmob )
			if("ian")
				new_mob = M.change_mob_type( /mob/living/simple_animal/corgi/Ian , null, null, delmob )
			if("crab")
				new_mob = M.change_mob_type( /mob/living/simple_animal/crab , null, null, delmob )
			if("coffee")
				new_mob = M.change_mob_type( /mob/living/simple_animal/crab/Coffee , null, null, delmob )
			if("parrot")
				new_mob = M.change_mob_type( /mob/living/simple_animal/parrot , null, null, delmob )
			if("polyparrot")
				new_mob = M.change_mob_type( /mob/living/simple_animal/parrot/Poly , null, null, delmob )
			if("constructarmoured")
				new_mob = M.change_mob_type( /mob/living/simple_animal/construct/armoured , null, null, delmob )
			if("constructbuilder")
				new_mob = M.change_mob_type( /mob/living/simple_animal/construct/builder , null, null, delmob )
			if("constructwraith")
				new_mob = M.change_mob_type( /mob/living/simple_animal/construct/wraith , null, null, delmob )
			if("shade")
				new_mob = M.change_mob_type( /mob/living/simple_animal/shade , null, null, delmob )
			if("soulblade")
				var/mob/living/simple_animal/shade/new_shade = M.change_mob_type( /mob/living/simple_animal/shade , null, null, delmob )
				var/obj/item/weapon/melee/soulblade/blade = new(get_turf(M))
				blade.blood = blade.maxblood
				new_shade.forceMove(blade)
				blade.update_icon()
				new_shade.status_flags |= GODMODE
				new_shade.canmove = 0
				new_shade.name = "[M.real_name] the Shade"
				new_shade.real_name = "[M.real_name]"
				new_shade.give_blade_powers()
			if("blob")
				var/obj/effect/blob/core/core = new(loc = get_turf(M), new_overmind = M.client)
				new_mob = core.overmind
				if(delmob)
					qdel(M)
			if("ai")
				new_mob = M.AIize(spawn_here = 1, del_mob = delmob)
//		to_chat(world, "Made a [new_mob] [usr ? "usr still exists" : "usr does not exist"]")
		if(new_mob && new_mob != M)
//			to_chat(world, "[new_mob.client] vs [CLIENT] they [new_mob.client == CLIENT ? "match" : "don't match"]")
			if(new_mob.client == CLIENT)
//				to_chat(world, "setting usr to new_mob")
				usr = new_mob //We probably transformed ourselves
			show_player_panel(new_mob)


	/////////////////////////////////////new ban stuff
	else if(href_list["unbanf"])
		if(!check_rights(R_BAN))
			return

		var/banfolder = href_list["unbanf"]
		Banlist.cd = "/base/[banfolder]"
		var/key = Banlist["key"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
			if(RemoveBan(banfolder))
				unbanpanel()
			else
				alert(usr, "This ban has already been lifted / does not exist.", "Error", "Ok")
				unbanpanel()

	else if(href_list["warn"])
		usr.client.warn(href_list["warn"])

	else if(href_list["unwarn"])
		usr.client.unwarn(href_list["unwarn"])

	else if(href_list["unbane"])
		if(!check_rights(R_BAN))
			return

		UpdateTime()
		var/reason

		var/banfolder = href_list["unbane"]
		Banlist.cd = "/base/[banfolder]"
		var/reason2 = Banlist["reason"]
		var/temp = Banlist["temp"]

		var/minutes = Banlist["minutes"]

		var/banned_key = Banlist["key"]
		Banlist.cd = "/base"

		var/duration

		switch(alert("Temporary Ban?",,"Yes","No"))
			if("Yes")
				temp = 1
				var/mins = 0
				if(minutes > CMinutes)
					mins = minutes - CMinutes
				mins = input(usr,"How long (in minutes)? (Default: 1440)","Ban time",mins ? mins : 1440) as num|null
				if(!mins)
					return
				mins = min(525599,mins)
				minutes = CMinutes + mins
				duration = GetExp(minutes)
				reason = input(usr,"Reason?","reason",reason2) as text|null
				if(!reason)
					return
			if("No")
				temp = 0
				duration = "Perma"
				reason = input(usr,"Reason?","reason",reason2) as text|null
				if(!reason)
					return

		log_admin("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		ban_unban_log_save("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		message_admins("<span class='notice'>[key_name_admin(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]</span>", 1)
		Banlist.cd = "/base/[banfolder]"
		to_chat(Banlist["reason"], reason)
		to_chat(Banlist["temp"], temp)
		to_chat(Banlist["minutes"], minutes)
		to_chat(Banlist["bannedby"], usr.ckey)
		Banlist.cd = "/base"
		feedback_inc("ban_edit",1)
		unbanpanel()

	/////////////////////////////////////new ban stuff
	else if(href_list["oocban"])
		if(!check_rights(R_BAN))
			return
		var/mob/M = locate(href_list["oocban"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(!M.ckey)	//sanity
			to_chat(usr, "This mob has no ckey")
			return
		var/oocbanned = oocban_isbanned("[M.ckey]")
		if(oocbanned)
			switch(alert("Reason: Remove OOC ban?","Please Confirm","Yes","No"))
				if("Yes")
					ban_unban_log_save("[key_name(usr)] removed [key_name(M)]'s OOC ban")
					log_admin("[key_name(usr)] removed [key_name(M)]'s OOC ban")
					feedback_inc("ban_ooc_unban", 1)
					DB_ban_unban(M.ckey, BANTYPE_OOC_PERMA)
					ooc_unban(M)
					message_admins("<span class='notice'>[key_name_admin(usr)] removed [key_name_admin(M)]'s OOC ban</span>", 1)
					to_chat(M, "<span class='warning'><BIG><B>[usr.client.ckey] has removed your OOC ban.</B></BIG></span>")
		else
			switch(alert("OOC ban [M.ckey]?",,"Yes","No"))
				if("Yes")
					switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
						if("Yes")
							var/mins = input(usr,"How long (in minutes)?","OOC Ban time",1440) as num|null
							if(!mins)
								return
							if(mins >= 525600)
								mins = 525599
							var/reason = input(usr,"Reason?","reason","Shinposting") as text|null
							if(!reason)
								return
							ban_unban_log_save("[usr.client.ckey] has banned [M.ckey]. - Reason: [reason] - This will be removed in [mins] minutes.")
							to_chat(M, "<span class='warning'><BIG><B>You have been OOC banned by [usr.client.ckey].\nReason: [reason].</B></BIG></span>")
							to_chat(M, "<span class='warning'>This is a temporary ooc ban, it will be removed in [mins] minutes.</span>")
							feedback_inc("ban_ooc_tmp",1)
							DB_ban_record(BANTYPE_OOC_TEMP, M, mins, reason)
							feedback_inc("ban_ooc_tmp_mins",mins)
							if(config.banappeals)
								to_chat(M, "<span class='warning'>To try to resolve this matter head to [config.banappeals] or consider not being a shithead in OOC</span>")
							else
								to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>")
							log_admin("[usr.client.ckey] has ooc banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
							message_admins("<span class='warning'>[usr.client.ckey] has ooc banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.</span>")

						if("No")
							var/reason = input(usr,"Reason?","reason","Shinposting") as text|null
							if(!reason)
								return
							to_chat(M, "<span class='warning'><BIG><B>You have been ooc banned by [usr.client.ckey].\nReason: [reason].</B></BIG></span>")
							to_chat(M, "<span class='warning'>This is a permanent ooc ban.</span>")
							if(config.banappeals)
								to_chat(M, "<span class='warning'>To try to resolve this matter head to [config.banappeals] or consider not being a shithead in OOC</span>")
							else
								to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>")
							ban_unban_log_save("[usr.client.ckey] has perma-ooc-banned [M.ckey]. - Reason: [reason] - This is a permanent ooc ban.")
							log_admin("[usr.client.ckey] has ooc banned [M.ckey].\nReason: [reason]\nThis is a permanent ooc ban.")
							message_admins("<span class='warning'>[usr.client.ckey] has ooc banned [M.ckey].\nReason: [reason]\nThis is a permanent ooc ban.</span>")
							feedback_inc("ban_ooc_perma",1)
							DB_ban_record(BANTYPE_OOC_PERMA, M, -1, reason)

						if("Cancel")
							return
					ooc_ban(M)
					return
				if("No")
					return
				else
					return
	else if(href_list["paxban"])
		if(!check_rights(R_BAN))
			return
		var/mob/M = locate(href_list["paxban"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(!M.ckey)	//sanity
			to_chat(usr, "This mob has no ckey")
			return
		var/paxbanned = paxban_isbanned("[M.ckey]")
		if(paxbanned && alert("Remove pax ban?","Please Confirm","Yes","No") == "Yes")
			ban_unban_log_save("[key_name(usr)] removed [key_name(M)]'s pax ban")
			log_admin("[key_name(usr)] removed [key_name(M)]'s pax ban")
			feedback_inc("ban_pax_unban", 1)
			DB_ban_unban(M.ckey, BANTYPE_PAX_PERMA)
			pax_unban(M)
			message_admins("<span class='notice'>[key_name_admin(usr)] removed [key_name_admin(M)]'s PAX ban</span>", 1)
			to_chat(M, "<span class='warning'><BIG><B>[usr.client.ckey] has removed your PAX ban.</B></BIG></span>")
		else if(alert("Pax ban [M.ckey]?","Please Confirm","Yes","No") == "Yes")
			var/temp = alert("Temporary Ban?",,"Yes","No", "Cancel")
			var/mins = 0
			switch(temp)
				if("Yes")
					mins = input(usr,"How long (in minutes)?","PAX Ban time",1440) as num|null
					if(!mins)
						return
					if(mins >= 525600)
						mins = 525599
				if("Cancel")
					return
			var/istemp = temp == "Yes"
			var/reason = input(usr,"Reason?","reason","Greytider") as text|null
			if(!reason)
				return
			to_chat(M, "<span class='warning'><BIG><B>You have been PAX banned by [usr.client.ckey].\nReason: [reason].</B></BIG></span>")
			to_chat(M, "<span class='warning'>This is a [istemp ? "temporary" : "permanent"] pax ban[istemp ? ", it will be removed in [mins] minutes" : ""].</span>")
			if(config.banappeals)
				to_chat(M, "<span class='warning'>To try to resolve this matter head to [config.banappeals]</span>")
			else
				to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>")
			var/resolvetext = istemp ? "This will be removed in [mins] minutes." : "This is a permanent pax ban."
			ban_unban_log_save("[usr.client.ckey] has [istemp ? "temp-" : "perma-"]pax banned [M.ckey]. - Reason: [reason] - [resolvetext]")
			feedback_inc(istemp ? "ban_pax_tmp" : "ban_pax_perma",1)
			DB_ban_record(istemp ? BANTYPE_PAX_TEMP : BANTYPE_PAX_PERMA, M, istemp ? mins : -1, reason)
			if(istemp)
				feedback_inc("ban_pax_tmp_mins",mins)
			log_admin("[usr.client.ckey] has pax banned [M.ckey].\nReason: [reason]\n[resolvetext]")
			message_admins("<span class='warning'>[usr.client.ckey] has pax banned [M.ckey].\nReason: [reason]\n[resolvetext]</span>")
			pax_ban(M)
		else
			return

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

		var/banreason = appearance_isbanned(M)
		if(banreason)
	/*		if(!config.ban_legacy_system)
				to_chat(usr, "Unfortunately, database based unbanning cannot be done through this panel")
				DB_ban_panel(M.ckey)
				return	*/
			switch(alert("Reason: '[banreason]' Remove appearance ban?","Please Confirm","Yes","No"))
				if("Yes")
					ban_unban_log_save("[key_name(usr)] removed [key_name(M)]'s appearance ban")
					log_admin("[key_name(usr)] removed [key_name(M)]'s appearance ban")
					feedback_inc("ban_appearance_unban", 1)
					DB_ban_unban(M.ckey, BANTYPE_APPEARANCE)
					appearance_unban(M)
					message_admins("<span class='notice'>[key_name_admin(usr)] removed [key_name_admin(M)]'s appearance ban</span>", 1)
					to_chat(M, "<span class='warning'><BIG><B>[usr.client.ckey] has removed your appearance ban.</B></BIG></span>")

		else
			switch(alert("Appearance ban [M.ckey]?",,"Yes","No", "Cancel"))
				if("Yes")
					var/reason = input(usr,"Reason?","reason","Metafriender") as text|null
					if(!reason)
						return
					ban_unban_log_save("[key_name(usr)] appearance banned [key_name(M)]. reason: [reason]")
					log_admin("[key_name(usr)] appearance banned [key_name(M)]. \nReason: [reason]")
					feedback_inc("ban_appearance",1)
					DB_ban_record(BANTYPE_APPEARANCE, M, -1, reason)
					appearance_fullban(M, "[reason]; By [usr.ckey] on [time2text(world.realtime)]")
					notes_add(M.ckey, "Appearance banned - [reason]")
					message_admins("<span class='notice'>[key_name_admin(usr)] appearance banned [key_name_admin(M)]</span>", 1)
					to_chat(M, "<span class='warning'><BIG><B>You have been appearance banned by [usr.client.ckey].</B></BIG></span>")
					to_chat(M, "<span class='danger'>The reason is: [reason]</span>")
					to_chat(M, "<span class='warning'>Appearance ban can be lifted only upon request.</span>")
					if(config.banappeals)
						to_chat(M, "<span class='warning'>To try to resolve this matter head to [config.banappeals]</span>")
					else
						to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>")
				if("No")
					return

	else if(href_list["jobban2"])
//		if(!check_rights(R_BAN))	return

		var/mob/M = locate(href_list["jobban2"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(!M.ckey)	//sanity
			to_chat(usr, "This mob has no ckey")
			return
		if(!job_master)
			to_chat(usr, "Job Master has not been setup!")
			return

		var/dat = ""
		var/header = "<head><title>Job-Ban Panel: [M.name]</title></head>"
		var/body
		var/jobs = ""

	/***********************************WARNING!************************************
					  The jobban stuff looks mangled and disgusting
							  But it looks beautiful in-game
										-Nodrak
	************************************WARNING!***********************************/
		var/counter = 0
//Regular jobs
	//Command (Blue)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr align='center' bgcolor='ccccff'><th colspan='[length(command_positions)]'><a href='?src=\ref[src];jobban3=commanddept;jobban4=\ref[M]'>Command Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in command_positions)
			if(!jobPos)
				continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job)
				continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 6) //So things dont get squiiiiished!
				jobs += "</tr><tr>"
				counter = 0
		jobs += "</tr></table>"

	//Security (Red)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffddf0'><th colspan='[length(security_positions)]'><a href='?src=\ref[src];jobban3=securitydept;jobban4=\ref[M]'>Security Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in security_positions)
			if(!jobPos)
				continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job)
				continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Engineering (Yellow)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='fff5cc'><th colspan='[length(engineering_positions)]'><a href='?src=\ref[src];jobban3=engineeringdept;jobban4=\ref[M]'>Engineering Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in engineering_positions)
			if(!jobPos)
				continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job)
				continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Medical (White)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeef0'><th colspan='[length(medical_positions)]'><a href='?src=\ref[src];jobban3=medicaldept;jobban4=\ref[M]'>Medical Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in medical_positions)
			if(!jobPos)
				continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job)
				continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Science (Purple)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='e79fff'><th colspan='[length(science_positions)]'><a href='?src=\ref[src];jobban3=sciencedept;jobban4=\ref[M]'>Science Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in science_positions)
			if(!jobPos)
				continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job)
				continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Civilian (Grey)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='dddddd'><th colspan='[length(civilian_positions)]'><a href='?src=\ref[src];jobban3=civiliandept;jobban4=\ref[M]'>Civilian Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in civilian_positions)
			if(!jobPos)
				continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job)
				continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0

		jobs += "</tr></table>"

	//Cargo (Brown)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='b3a292'><th colspan='[length(cargo_positions)]'><a href='?src=\ref[src];jobban3=cargodept;jobban4=\ref[M]'>Cargo Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in cargo_positions)
			if(!jobPos)
				continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job)
				continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0

		jobs += "</tr></table>"

	//Non-Human (Green)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ccffcc'><th colspan='[length(nonhuman_positions)+1]'><a href='?src=\ref[src];jobban3=nonhumandept;jobban4=\ref[M]'>Non-human Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in nonhuman_positions)
			if(!jobPos)
				continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job)
				continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0

		//pAI isn't technically a job, but it goes in here.

		if(jobban_isbanned(M, "pAI"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=pAI;jobban4=\ref[M]'><font color=red>pAI</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=pAI;jobban4=\ref[M]'>pAI</a></td>"
		if(jobban_isbanned(M, "AntagHUD"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=AntagHUD;jobban4=\ref[M]'><font color=red>AntagHUD</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=AntagHUD;jobban4=\ref[M]'>AntagHUD</a></td>"
		jobs += "</tr></table>"

	//Antagonist (Orange)
		var/isbanned_dept = isantagbanned(M)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeeaa'><th colspan='10'><a href='?src=\ref[src];jobban3=Syndicate;jobban4=\ref[M]'>Antagonist Positions</a></th></tr><tr align='center'>"

		//Traitor
		if(jobban_isbanned(M, "traitor") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=traitor;jobban4=\ref[M]'><font color=red>[replacetext("Traitor", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=traitor;jobban4=\ref[M]'>[replacetext("Traitor", " ", "&nbsp")]</a></td>"

		//Changeling
		if(jobban_isbanned(M, "changeling") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=changeling;jobban4=\ref[M]'><font color=red>[replacetext("Changeling", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=changeling;jobban4=\ref[M]'>[replacetext("Changeling", " ", "&nbsp")]</a></td>"

		//Nuke Operative
		if(jobban_isbanned(M, "operative") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=operative;jobban4=\ref[M]'><font color=red>[replacetext("Nuke Operative", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=operative;jobban4=\ref[M]'>[replacetext("Nuke Operative", " ", "&nbsp")]</a></td>"

		//Revolutionary
		if(jobban_isbanned(M, "revolutionary") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=revolutionary;jobban4=\ref[M]'><font color=red>[replacetext("Revolutionary", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=revolutionary;jobban4=\ref[M]'>[replacetext("Revolutionary", " ", "&nbsp")]</a></td>"

		jobs += "</tr><tr align='center'>" //Breaking it up so it fits nicer on the screen every 5 entries

		//Cultist
		if(jobban_isbanned(M, "cultist") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=cultist;jobban4=\ref[M]'><font color=red>[replacetext("Cultist", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=cultist;jobban4=\ref[M]'>[replacetext("Cultist", " ", "&nbsp")]</a></td>"

		//Wizard
		if(jobban_isbanned(M, "wizard") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=wizard;jobban4=\ref[M]'><font color=red>[replacetext("Wizard", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=wizard;jobban4=\ref[M]'>[replacetext("Wizard", " ", "&nbsp")]</a></td>"

		//Strike Team
		if(jobban_isbanned(M, ROLE_STRIKE) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Strike Team;jobban4=\ref[M]'><font color=red>Strike Team</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Strike Team;jobban4=\ref[M]'>Strike Team</a></td>"


		//Vox Raider
		if(jobban_isbanned(M, "Vox Raider") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Vox Raider;jobban4=\ref[M]'><font color=red>Vox&nbsp;Raider</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Vox Raider;jobban4=\ref[M]'>Vox&nbsp;Raider</a></td>"

/*		//Malfunctioning AI	//Removed Malf-bans because they're a pain to impliment
		if(jobban_isbanned(M, "malf AI") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=malf AI;jobban4=\ref[M]'><font color=red>[replacetext("Malf AI", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=malf AI;jobban4=\ref[M]'>[replacetext("Malf AI", " ", "&nbsp")]</a></td>"

		//Alien
		if(jobban_isbanned(M, "alien candidate") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=alien candidate;jobban4=\ref[M]'><font color=red>[replacetext("Alien", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=alien candidate;jobban4=\ref[M]'>[replacetext("Alien", " ", "&nbsp")]</a></td>"

		//Infested Monkey
		if(jobban_isbanned(M, "infested monkey") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=infested monkey;jobban4=\ref[M]'><font color=red>[replacetext("Infested Monkey", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=infested monkey;jobban4=\ref[M]'>[replacetext("Infested Monkey", " ", "&nbsp")]</a></td>"
*/

		jobs += "</tr></table>"

		//Other races  (BLUE, because I have no idea what other color to make this)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ccccff'><th colspan='10'>Other Races</th></tr><tr align='center'>"

		if(jobban_isbanned(M, "Dionaea"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Dionaea;jobban4=\ref[M]'><font color=red>Dionaea</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Dionaea;jobban4=\ref[M]'>Dionaea</a></td>"

		if(jobban_isbanned(M, "Trader"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Trader;jobban4=\ref[M]'><font color=red>Vox&nbsp;Trader</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Trader;jobban4=\ref[M]'>Vox&nbsp;Trader</font></a></td>"


		jobs += "</tr></table>"

		// Special job bans (Cluwne)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='87ceeb'><th colspan='10'>Special Bans</th></tr><tr align='center'>"

		if(jobban_isbanned(M, "Cluwne"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Cluwne;jobban4=\ref[M]'><font color=red>Cluwne</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Cluwne;jobban4=\ref[M]'>Cluwne</a></td>"

		if(jobban_isbanned(M, "artist")) //so people can't make paintings
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=artist;jobban4=\ref[M]'><font color=red>Artist</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=artist;jobban4=\ref[M]'>Artist</a></td>"

		jobs += "</tr></table>"

		body = "<body>[jobs]</body>"
		dat = "<tt>[header][body]</tt>"
		usr << browse(dat, "window=jobban2;size=800x490")
		return

	//JOBBAN'S INNARDS
	else if(href_list["jobban3"])
		if(!check_rights(R_BAN))
			return

		var/mob/M = locate(href_list["jobban4"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(M != usr)																//we can jobban ourselves
			if(M.client && M.client.holder && (M.client.holder.rights & R_BAN))		//they can ban too. So we can't ban them
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return

		if(!job_master)
			to_chat(usr, "Job Master has not been setup!")
			return

		//get jobs for department if specified, otherwise just returnt he one job in a list.
		var/list/joblist = list()
		switch(href_list["jobban3"])
			if("commanddept")
				for(var/jobPos in command_positions)
					if(!jobPos)
						continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp)
						continue
					joblist += temp.title
			if("securitydept")
				for(var/jobPos in security_positions)
					if(!jobPos)
						continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp)
						continue
					joblist += temp.title
			if("engineeringdept")
				for(var/jobPos in engineering_positions)
					if(!jobPos)
						continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp)
						continue
					joblist += temp.title
			if("medicaldept")
				for(var/jobPos in medical_positions)
					if(!jobPos)
						continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp)
						continue
					joblist += temp.title
			if("sciencedept")
				for(var/jobPos in science_positions)
					if(!jobPos)
						continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp)
						continue
					joblist += temp.title
			if("civiliandept")
				for(var/jobPos in civilian_positions)
					if(!jobPos)
						continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp)
						continue
					joblist += temp.title
			if("cargodept")
				for(var/jobPos in cargo_positions)
					if(!jobPos)
						continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp)
						continue
					joblist += temp.title
			if("nonhumandept")
				joblist += "pAI"
				for(var/jobPos in nonhuman_positions)
					if(!jobPos)
						continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp)
						continue
					joblist += temp.title
			if("misc")
				for(var/jobPos in misc_positions)
					if(!jobPos)
						continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp)
						continue
					joblist += temp.title
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
					if(config.ban_legacy_system)
						to_chat(usr, "<span class='warning'>Your server is using the legacy banning system, which does not support temporary job bans. Consider upgrading. Aborting ban.</span>")
						return
					var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
					if(!mins)
						return
					var/reason = input(usr,"Reason?","Please State Reason","") as text|null
					if(!reason)
						return

					var/msg
					for(var/job in notbannedlist)
						ban_unban_log_save("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins] minutes. reason: [reason]")
						log_admin("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins] minutes")
						feedback_inc("ban_job_tmp",1)
						DB_ban_record(BANTYPE_JOB_TEMP, M, mins, reason, job)
						feedback_add_details("ban_job_tmp","- [job]")
						jobban_fullban(M, job, "[reason]; By [usr.ckey] on [time2text(world.realtime)]") //Legacy banning does not support temporary jobbans.
						if(!msg)
							msg = job
						else
							msg += ", [job]"
					notes_add(M.ckey, "Banned  from [msg] - [reason]")
					message_admins("<span class='notice'>[key_name_admin(usr)] banned [key_name_admin(M)] from [msg] for [mins] minutes</span>", 1)
					to_chat(M, "<span class='warning'><BIG><B>You have been jobbanned by [usr.client.ckey] from: [msg].</B></BIG></span>")
					to_chat(M, "<span class='danger'>The reason is: [reason]</span>")
					to_chat(M, "<span class='warning'>This jobban will be lifted in [mins] minutes.</span>")
					href_list["jobban2"] = 1 // lets it fall through and refresh
					return 1
				if("No")
					var/reason = input(usr,"Reason?","Please State Reason","") as text|null
					if(reason)
						var/msg
						for(var/job in notbannedlist)
							ban_unban_log_save("[key_name(usr)] perma-jobbanned [key_name(M)] from [job]. reason: [reason]")
							log_admin("[key_name(usr)] perma-banned [key_name(M)] from [job]")
							feedback_inc("ban_job",1)
							DB_ban_record(BANTYPE_JOB_PERMA, M, -1, reason, job)
							feedback_add_details("ban_job","- [job]")
							jobban_fullban(M, job, "[reason]; By [usr.ckey] on [time2text(world.realtime)]")
							if(!msg)
								msg = job
							else
								msg += ", [job]"
						notes_add(M.ckey, "Banned  from [msg] - [reason]")
						message_admins("<span class='notice'>[key_name_admin(usr)] banned [key_name_admin(M)] from [msg]</span>", 1)
						to_chat(M, "<span class='warning'><BIG><B>You have been jobbanned by [usr.client.ckey] from: [msg].</B></BIG></span>")
						to_chat(M, "<span class='danger'>The reason is: [reason]</span>")
						to_chat(M, "<span class='warning'>Jobban can be lifted only upon request.</span>")
						href_list["jobban2"] = 1 // lets it fall through and refresh
						return 1
				if("Cancel")
					return

		//Unbanning joblist
		//all jobs in joblist are banned already OR we didn't give a reason (implying they shouldn't be banned)
		if(joblist.len) //at least 1 banned job exists in joblist so we have stuff to unban.
			if(!config.ban_legacy_system)
				to_chat(usr, "Unfortunately, database based unbanning cannot be done through this panel")
				DB_ban_panel(M.ckey)
				return
			var/msg
			for(var/job in joblist)
				var/reason = jobban_isbanned(M, job)
				if(!reason)
					continue //skip if it isn't jobbanned anyway
				switch(alert("Job: '[job]' Reason: '[reason]' Un-jobban?","Please Confirm","Yes","No"))
					if("Yes")
						ban_unban_log_save("[key_name(usr)] unjobbanned [key_name(M)] from [job]")
						log_admin("[key_name(usr)] unbanned [key_name(M)] from [job]")
						DB_ban_unban(M.ckey, BANTYPE_JOB_PERMA, job)
						feedback_inc("ban_job_unban",1)
						feedback_add_details("ban_job_unban","- [job]")
						jobban_unban(M, job)
						if(!msg)
							msg = job
						else
							msg += ", [job]"
					else
						continue
			if(msg)
				message_admins("<span class='notice'>[key_name_admin(usr)] unbanned [key_name_admin(M)] from [msg]</span>", 1)
				to_chat(M, "<span class='warning'><BIG><B>You have been un-jobbanned by [usr.client.ckey] from [msg].</B></BIG></span>")
				href_list["jobban2"] = 1 // lets it fall through and refresh
			return 1
		return 0 //we didn't do anything!

	else if(href_list["boot2"])
		var/mob/M = locate(href_list["boot2"])
		if (ismob(M))
			if(!check_rights(R_PERMISSIONS,0))
				if(!check_if_greater_rights_than(M.client))
					return
			if(alert("Do you want to kick [M]?","Kick confirmation", "Yes", "No") != "Yes")
				return
			to_chat(M, "<span class='userdanger'>You have been kicked from the server</span>")
			log_admin("[key_name(usr)] booted [key_name(M)].")
			message_admins("<span class='notice'>[key_name_admin(usr)] booted [key_name_admin(M)].</span>", 1)
			//M.client = null
			del(M.client)
	else if(href_list["removejobban"])
		if(!check_rights(R_BAN))
			return

		var/t = href_list["removejobban"]
		if(t)
			if((alert("Do you want to unjobban [t]?","Unjobban confirmation", "Yes", "No") == "Yes") && t) //No more misclicks! Unless you do it twice.
				log_admin("[key_name(usr)] removed [t]")
				message_admins("<span class='notice'>[key_name_admin(usr)] removed [t]</span>", 1)
				jobban_remove(t)
				href_list["ban"] = 1 // lets it fall through and refresh
				var/t_split = splittext(t, " - ")
				var/key = t_split[1]
				var/job = t_split[2]
				DB_ban_unban(ckey(key), BANTYPE_JOB_PERMA, job)

	else if(href_list["newban"])
		if(!check_rights(R_BAN))
			return

		var/mob/M = locate(href_list["newban"])
		if(!ismob(M) || !M.ckey)
			to_chat(usr, "<span class='notice'>There is no mob, or no ckey, to ban. Perhaps the player has ghosted?</span>")
			return

		// now you can! if(M.client && M.client.holder)	return	//admins cannot be banned. Even if they could, the ban doesn't affect them anyway

		var/istemp = alert("Temporary Ban?",,"Yes","No", "Cancel")
		var/mins = 0
		switch(istemp)
			if("Yes")
				mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
				if(!mins)
					return
				if(mins >= 525600)
					mins = 525599
			if("Cancel")
				return
		var/reason = input(usr,"Reason?","reason","Griefer") as text|null
		if(!reason)
			return
		var/ipban = alert(usr,"IP ban?",,"Yes","No","Cancel")
		if(ipban == "Cancel")
			return
		var/sticky = FALSE
		if(istemp == "No")
			sticky = alert(usr,"Sticky Ban [M.ckey]? Use this only if you never intend to unban the player.","Sticky Icky","Yes", "No") == "Yes"
		M.GetBanned(reason, usr.ckey, istemp == "Yes", mins, ipban == "Yes", sticky)
		feedback_inc(istemp == "Yes" ? "ban_tmp_mins" : "ban_perma", istemp == "Yes" ? mins : 1)

	else if(href_list["stickyunban"])
		if(!check_rights(R_BAN))
			return
		var/key = href_list["stickyunban"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
			world.SetConfig("SYSTEM/keyban",key,null)
	else if(href_list["unjobbanf"])
		if(!check_rights(R_BAN))
			return

		var/banfolder = href_list["unjobbanf"]
		Banlist.cd = "/base/[banfolder]"
		var/key = Banlist["key"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
			if (RemoveBanjob(banfolder))
				unjobbanpanel()
			else
				alert(usr,"This ban has already been lifted / does not exist.","Error","Ok")
				unjobbanpanel()

	else if(href_list["mute"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["mute"])
		if(!ismob(M))
			return
		if(!M.client)
			return

		var/mute_type = href_list["mute_type"]
		if(istext(mute_type))
			mute_type = text2num(mute_type)
		if(!isnum(mute_type))
			return

		cmd_admin_mute(M, mute_type)

	else if(href_list["c_mode"])
		if(!check_rights(R_ADMIN))
			return
		var/dat = {"<B>What mode do you wish to play?</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A href='?src=\ref[src];c_mode2=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"<A href='?src=\ref[src];c_mode2=secret'>Secret</A><br>"}
		dat += {"<A href='?src=\ref[src];c_mode2=random'>Random</A><br>"}
		dat += {"Now: [master_mode]"}
		usr << browse(dat, "window=c_mode")

	else if(href_list["f_secret"])
		if(!check_rights(R_ADMIN))
			return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		var/dat = {"<B>What game mode do you want to force secret to be? Use this if you want to change the game mode, but want the players to believe it's secret. This will only work if the current game mode is secret.</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A href='?src=\ref[src];f_secret2=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"<A href='?src=\ref[src];f_secret2=secret'>Random (default)</A><br>"}
		dat += {"Now: [secret_force_mode]"}
		usr << browse(dat, "window=f_secret")

	else if(href_list["f_dynamic_roundstart"])
		if(!check_rights(R_ADMIN))
			return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(master_mode != "Dynamic Mode")
			return alert(usr, "The game mode has to be Dynamic Mode!", null, null, null, null)
		if (forced_roundstart_ruleset.len > 30)
			return alert(usr, "Haven't you already forced enough rulesets?", null, null, null, null)
		var/list/datum/dynamic_ruleset/roundstart/roundstart_rules = list()
		for (var/rule in subtypesof(/datum/dynamic_ruleset/roundstart))
			var/datum/dynamic_ruleset/roundstart/newrule = rule
			roundstart_rules += initial(newrule.name)
		var/added_rule = input(usr,"What ruleset do you want to force? This will bypass threat level and population restrictions.", "Rigging Roundstart", null) as null|anything in roundstart_rules
		if (added_rule)
			var/datum/forced_ruleset/forcedrule = new
			forcedrule.name = added_rule
			forcedrule.calledBy = "[key_name(usr)]"
			forced_roundstart_ruleset += forcedrule
			log_admin("[key_name(usr)] set [added_rule] to be a forced roundstart ruleset.")
			message_admins("[key_name(usr)] set [added_rule] to be a forced roundstart ruleset.", 1)
			Game()

	else if(href_list["f_dynamic_roundstart_clear"])
		if(!check_rights(R_ADMIN))
			return

		for (var/datum/forced_ruleset/rule in forced_roundstart_ruleset)
			qdel(rule)
		forced_roundstart_ruleset = list()
		Game()
		log_admin("[key_name(usr)] cleared the rigged roundstart rulesets. The mode will pick them as normal.")
		message_admins("[key_name(usr)] cleared the rigged roundstart rulesets. The mode will pick them as normal.", 1)


	else if(href_list["f_dynamic_roundstart_remove"])
		if(!check_rights(R_ADMIN))
			return

		var/datum/forced_ruleset/rule = locate(href_list["f_dynamic_roundstart_remove"])
		forced_roundstart_ruleset -= rule
		qdel(rule)
		Game()
		log_admin("[key_name(usr)] removed [rule] from the forced roundstart rulesets.")
		message_admins("[key_name(usr)] removed [rule] from the forced roundstart rulesets.", 1)


	else if(href_list["f_dynamic_latejoin"])
		if(!check_rights(R_ADMIN))
			return

		if(!ticker || !ticker.mode)
			return alert(usr, "The game must start first.", null, null, null, null)
		if(master_mode != "Dynamic Mode")
			return alert(usr, "The game mode has to be Dynamic Mode!", null, null, null, null)
		var/list/datum/dynamic_ruleset/latejoin/latejoin_rules = list()
		for (var/rule in subtypesof(/datum/dynamic_ruleset/latejoin))
			var/datum/dynamic_ruleset/latejoin/newrule = new rule()
			latejoin_rules[newrule.name] = newrule
		var/added_rule = input(usr,"What ruleset do you want to force upon the next latejoiner? This will bypass threat level and population restrictions.", "Rigging Latejoin", null) as null|anything in latejoin_rules
		if (added_rule)
			var/datum/gamemode/dynamic/mode = ticker.mode
			latejoin_rules[added_rule].calledBy = "[key_name(usr)]"
			mode.forced_latejoin_rule = latejoin_rules[added_rule]
			log_admin("[key_name(usr)] set [added_rule] to proc on the next latejoin.")
			message_admins("[key_name(usr)] set [added_rule] to proc on the next latejoin.", 1)
			Game()

	else if(href_list["f_dynamic_latejoin_clear"])
		if(!check_rights(R_ADMIN))
			return

		if (ticker && ticker.mode && istype(ticker.mode,/datum/gamemode/dynamic))
			var/datum/gamemode/dynamic/mode = ticker.mode
			mode.forced_latejoin_rule = null
			Game()
			log_admin("[key_name(usr)] cleared the forced latejoin ruleset.")
			message_admins("[key_name(usr)] cleared the forced latejoin ruleset.", 1)

	else if(href_list["f_dynamic_midround"])
		if(!check_rights(R_ADMIN))
			return

		if(!ticker || !ticker.mode)
			return alert(usr, "The game must start first.", null, null, null, null)
		if(master_mode != "Dynamic Mode")
			return alert(usr, "The game mode has to be Dynamic Mode!", null, null, null, null)
		var/midround_rules = list()
		for (var/rule in subtypesof(/datum/dynamic_ruleset/midround))
			var/datum/dynamic_ruleset/midround/newrule = new rule()
			midround_rules[newrule.name] = rule
		var/added_rule = input(usr,"What ruleset do you want to force right now? This will bypass threat level and population restrictions.", "Execute Ruleset", null) as null|anything in midround_rules
		if (added_rule)
			var/datum/gamemode/dynamic/mode = ticker.mode
			log_admin("[key_name(usr)] executed the [added_rule] ruleset.")
			message_admins("[key_name(usr)] executed the [added_rule] ruleset.", 1)
			mode.picking_specific_rule(midround_rules[added_rule],1,"[key_name(usr)]")

	// -- Opens up the option window --
	else if (href_list["f_dynamic_options"])
		if(!check_rights(R_ADMIN))
			return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(master_mode != "Dynamic Mode")
			return alert(usr, "The game mode has to be Dynamic Mode!", null, null, null, null)

		dynamic_mode_options(usr)

	else if(href_list["f_dynamic_roundstart_centre"])
		if(!check_rights(R_ADMIN))
			return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(master_mode != "Dynamic Mode")
			return alert(usr, "The game mode has to be Dynamic Mode!", null, null, null, null)

		var/new_centre

		if (dynamic_chosen_mode == DIRAC)
			new_centre = input(usr,"Change the threat level this round will have.", "Change threat level.", null) as num
			if (new_centre <= 0 || new_centre >= 100)
				return alert(usr, "Only values between 0 and 100 are allowed.", null, null, null, null)
		else if (dynamic_chosen_mode == EXPONENTIAL)
			new_centre = input(usr,"Change the centre of the dynamic mode threat curve. A lower value will give a more peaceful round ; a higher value, a round with higher threat. Any number between 0 and +5 is allowed.", "Change curve centre", null) as num
			if (new_centre < 0 || new_centre > 5)
				return alert(usr, "Only values between 0 and +5 are allowed.", null, null, null, null)
		else
			new_centre = input(usr,"Change the centre of the dynamic mode threat curve. A negative value will give a more peaceful round ; a positive value, a round with higher threat. Any number between -5 and +5 is allowed.", "Change curve centre", null) as num
			if (new_centre < -5 || new_centre > 5)
				return alert(usr, "Only values between -5 and +5 are allowed.", null, null, null, null)

		log_admin("[key_name(usr)] changed the distribution curve center to [new_centre].")
		message_admins("[key_name(usr)] changed the distribution curve center to [new_centre]", 1)
		dynamic_curve_centre = new_centre
		dynamic_mode_options(usr)

	else if(href_list["f_dynamic_roundstart_width"])
		if(!check_rights(R_ADMIN))
			return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(master_mode != "Dynamic Mode")
			return alert(usr, "The game mode has to be Dynamic Mode!", null, null, null, null)

		var/new_width = input(usr,"Change the width of the dynamic mode threat curve. A higher value will favour extreme rounds ; a lower value, a round closer to the average. Any Number between 0.5 and 4 are allowed.", "Change curve width", null) as num
		if (new_width < 0.5 || new_width > 4)
			return alert(usr, "Only values between 0.5 and +2.5 are allowed.", null, null, null, null)

		log_admin("[key_name(usr)] changed the distribution curve width to [new_width].")
		message_admins("[key_name(usr)] changed the distribution curve width to [new_width]", 1)
		dynamic_curve_width = new_width
		dynamic_mode_options(usr)

	else if(href_list["toggle_rulesets"])
		if(!check_rights(R_ADMIN))
			return

		if(master_mode != "Dynamic Mode")
			return alert(usr, "The game mode has to be Dynamic Mode!", null, null, null, null)

		admin_disable_rulesets = !admin_disable_rulesets
		log_admin("[key_name(usr)] toggled Dynamic rulesets <b>[admin_disable_rulesets ? "OFF" : "ON"]</b>.")
		message_admins("[key_name(usr)] toggled Dynamic rulesets <b>[admin_disable_rulesets ? "OFF" : "ON"]</b>.")
		Game()

	else if(href_list["toggle_events"])
		if(!check_rights(R_ADMIN))
			return

		admin_disable_events = !admin_disable_events
		log_admin("[key_name(usr)] toggled random events <b>[admin_disable_events ? "OFF" : "ON"]</b>.")
		message_admins("[key_name(usr)] toggled random events <b>[admin_disable_events ? "OFF" : "ON"]</b>.")
		Game()

	else if(href_list["no_stacking"])
		if(!check_rights(R_ADMIN))
			return

		if(master_mode != "Dynamic Mode")
			return alert(usr, "The game mode has to be Dynamic Mode!", null, null, null, null)

		dynamic_no_stacking = !dynamic_no_stacking
		log_admin("[key_name(usr)] set 'no_stacking' to [dynamic_no_stacking].")
		message_admins("[key_name(usr)] set 'no_stacking' to [dynamic_no_stacking].")
		dynamic_mode_options(usr)

	else if(href_list["classic_secret"])
		if(!check_rights(R_ADMIN))
			return

		if(master_mode != "Dynamic Mode")
			return alert(usr, "The game mode has to be Dynamic Mode!", null, null, null, null)

		dynamic_classic_secret = !dynamic_classic_secret
		log_admin("[key_name(usr)] set 'classic_secret' to [dynamic_classic_secret].")
		message_admins("[key_name(usr)] set 'classic_secret' to [dynamic_classic_secret].")
		dynamic_mode_options(usr)

	else if(href_list["stacking_limit"])
		if(!check_rights(R_ADMIN))
			return

		if(master_mode != "Dynamic Mode")
			return alert(usr, "The game mode has to be Dynamic Mode!", null, null, null, null)

		stacking_limit = input(usr,"Change the threat limit at which round-endings rulesets will start to stack.", "Change stacking limit", null) as num
		log_admin("[key_name(usr)] set 'stacking_limit' to [stacking_limit].")
		message_admins("[key_name(usr)] set 'stacking_limit' to [stacking_limit].")
		dynamic_mode_options(usr)

	else if(href_list["high_pop_limit"])
		if(!check_rights(R_ADMIN))
			return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)

		if(master_mode != "Dynamic Mode")
			return alert(usr, "The game mode has to be Dynamic Mode!", null, null, null, null)

		var/new_value = input(usr, "Enter the high-pop override threshold for dynamic mode.", "High pop override") as num
		if (new_value < 0)
			return alert(usr, "Only positive values allowed!", null, null, null, null)
		dynamic_high_pop_limit = new_value

		log_admin("[key_name(usr)] set 'dynamic_high_pop_limit' to [dynamic_high_pop_limit].")
		message_admins("[key_name(usr)] set 'dynamic_high_pop_limit' to [dynamic_high_pop_limit].")
		dynamic_mode_options(usr)

	else if(href_list["change_distrib"])
		if(!check_rights(R_ADMIN))
			return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)

		if(master_mode != "Dynamic Mode")
			return alert(usr, "The game mode has to be Dynamic Mode!", null, null, null, null)

		var/list/possible_choices = list(
			"[LORENTZ]",
			"[GAUSS]",
			"[DIRAC]",
			"[EXPONENTIAL]",
			"[UNIFORM]",
		)

		var/new_mode = input("Select a new distribution mode. BE SURE TO READ THE GLOSSARY BEFORE.") as null|anything in possible_choices
		if (!new_mode)
			return
		dynamic_chosen_mode = new_mode
		if (new_mode == DIRAC) // Rigged threat mode.
			dynamic_curve_centre = 50
			to_chat(usr, "<span class='notice'>You've chosen to rig the starting threat level. Remember to set the 'curve center' to the desire threat level. The default value is 50.</span>")
		else if (new_mode == EXPONENTIAL)
			dynamic_curve_centre = 1
		else
			dynamic_curve_centre = 0
		log_admin("[key_name(usr)] set the distribution mode to [dynamic_chosen_mode].")
		message_admins("[key_name(usr)] set the distribution mode to [dynamic_chosen_mode].")
		dynamic_mode_options(usr)

	else if(href_list["c_mode2"])
		if(!check_rights(R_ADMIN|R_SERVER))
			return

		if (ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		master_mode = href_list["c_mode2"]
		if((master_mode != "mixed") || alert("Do you wish to specify which game modes to be mixed?","Specify Mixed","Yes","No")=="No")
			mixed_modes = list()
			log_admin("[key_name(usr)] set the mode as [master_mode].")
			message_admins("<span class='notice'>[key_name_admin(usr)] set the mode as [master_mode].</span>", 1)
			to_chat(world, "<span class='notice'><b>The mode is now: [master_mode]</b></span>")
			Game() // updates the main game menu
			world.save_mode(master_mode)
			.(href, list("c_mode"=1))
		else
			var/list/possible = list()
			possible += mixed_factions_allowed
			possible += "DONE"
			possible += "CANCEL"
			if(possible.len < 3)
				return alert(usr, "Not enough possible game modes.", null, null, null, null)
			var/mixed_mode_added = null
			while(possible.len >= 3)
				var/mixed_mode_add = input("Pick game modes to add to the mix. ([mixed_mode_added])", "Specify Mixed") in possible
				possible -= mixed_mode_add
				if(mixed_mode_add == "CANCEL")
					return
				else if(mixed_mode_add == "DONE")
					break
				else
					mixed_modes += mixed_mode_add
					possible -= mixed_mode_add
					if(!mixed_mode_added)
						mixed_mode_added = mixed_mode_add
					else
						mixed_mode_added = "[mixed_mode_added], [mixed_mode_add]"

			log_admin("[key_name(usr)] set the mode as [master_mode] with the following modes: [mixed_mode_added].")
			message_admins("<span class='notice'>[key_name_admin(usr)] set the mode as [master_mode] with the following modes: [mixed_mode_added].</span>", 1)
			to_chat(world, "<span class='notice'><b>The mode is now: [master_mode] ([mixed_mode_added])</b></span>")
			Game() // updates the main game menu
			world.save_mode(master_mode)
			.(href, list("c_mode"=1))

	else if(href_list["f_secret2"])
		if(!check_rights(R_ADMIN|R_SERVER))
			return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		secret_force_mode = href_list["f_secret2"]

		if((secret_force_mode != "mixed") || alert("Do you wish to specify which game modes to be mixed?","Specify Secret Mixed","Yes","No")=="No")
			mixed_modes = list()
			log_admin("[key_name(usr)] set the forced secret mode as [secret_force_mode].")
			message_admins("<span class='notice'>[key_name_admin(usr)] set the forced secret mode as [secret_force_mode].</span>", 1)
			Game() // updates the main game menu
			.(href, list("f_secret"=1))
		else
			var/list/possible = list()
			possible += mixed_factions_allowed
			possible += "DONE"
			possible += "CANCEL"
			if(possible.len < 3)
				return alert(usr, "Not enough possible game modes.", null, null, null, null)
			var/mixed_mode_added = null
			while(possible.len >= 3)
				var/mixed_mode_add = input("Pick game modes to add to the secret mix. ([mixed_mode_added])", "Specify Secret Mixed") in possible
				possible -= mixed_mode_add
				if(mixed_mode_add == "CANCEL")
					return
				else if(mixed_mode_add == "DONE")
					break
				else
					mixed_modes += mixed_mode_add
					possible -= mixed_mode_add
					if(!mixed_mode_added)
						mixed_mode_added = mixed_mode_add
					else
						mixed_mode_added = "[mixed_mode_added], [mixed_mode_add]"

			log_admin("[key_name(usr)] set the mode as [secret_force_mode] with the following modes: [mixed_mode_added].")
			message_admins("<span class='notice'>[key_name_admin(usr)] set the forced secret mode as [secret_force_mode] with the following modes: [mixed_mode_added].</span>", 1)
			Game() // updates the main game menu
			.(href, list("f_secret"=1))

	else if(href_list["monkeyone"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["monkeyone"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		log_admin("[key_name(usr)] attempting to monkeyize [key_name(H)]")
		message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize [key_name_admin(H)]</span>", 1)
		var/mob/M = H.monkeyize()
		if(M)
			if(M.client == CLIENT)
				usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["corgione"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["corgione"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		log_admin("[key_name(usr)] attempting to corgize [key_name(H)]")
		message_admins("<span class='notice'>[key_name_admin(usr)] attempting to corgize [key_name_admin(H)]</span>", 1)
		var/mob/M = H.corgize()
		if(M)
			if(M.client == CLIENT)
				usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["forcespeech"])
		if(!check_rights(R_FUN))
			return

		var/mob/M = locate(href_list["forcespeech"])
		if(!ismob(M))
			to_chat(usr, "this can only be used on instances of type /mob")

		var/speech = input("What will [key_name(M)] say?.", "Force speech", "")// Don't need to sanitize, since it does that in say(), we also trust our admins.
		if(!speech)
			return
		M.say(speech)
		speech = sanitize(speech) // Nah, we don't trust them
		log_admin("[key_name(usr)] forced [key_name(M)] to say: [speech]")
		message_admins("<span class='notice'>[key_name_admin(usr)] forced [key_name_admin(M)] to say: [speech]</span>")

	else if(href_list["sendtoprison"])
		// Reworked to be useful for investigating shit.
		if(!check_rights(R_ADMIN))
			return

		if(alert(usr, "Warp to prison?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["sendtoprison"])

		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		var/turf/prison_cell = pick(prisonwarp)

		if(!prison_cell)
			return

		/*
		var/obj/structure/closet/secure_closet/brig/locker = new /obj/structure/closet/secure_closet/brig(prison_cell)
		locker.opened = 0
		locker.locked = 1

		//strip their stuff and stick it in the crate
		for(var/obj/item/I in M)
			M.u_equip(I,1)
			if(I)
				I.forceMove(locker)
				I.reset_plane_and_layer()
				//I.dropped(M)

		M.update_icons()
		*/

		//so they black out before warping
		M.Paralyse(5)
		M.visible_message(
			"<span class=\"sinister\">You hear the sound of cell doors slamming shut, and [M.name] suddenly vanishes!</span>",
			"<span class=\"sinister\">You hear the sound of cell doors slamming shut!</span>")

		sleep(5)

		if(!M)
			return

		// TODO: play sound here.  Thinking of using Wolfenstein 3D's cell door closing sound.

		M.forceMove(prison_cell)

		/*
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/prisoner = M
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(prisoner), slot_w_uniform)
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(prisoner), slot_shoes)
		*/

		to_chat(M, "<span class='warning'>You have been sent to the prison station!</span>")
		log_admin("[key_name(usr)] sent [key_name(M)] to the prison station.")
		message_admins("<span class='notice'>[key_name_admin(usr)] sent [key_name_admin(M)] to the prison station.</span>", 1)
	else if(href_list["sendbacktolobby"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/player_to_send = locate(href_list["sendbacktolobby"])
		if(!isobserver(player_to_send))
			to_chat(usr, span_notice("You can only send ghost players back to the Lobby."))
			return
		if(!player_to_send.client)
			to_chat(usr, span_warning("[player_to_send] doesn't seem to have an active client."))
			return
		if(alert(usr, "Send [key_name(player_to_send)] back to Lobby?", "Message", "Yes", "No") != "Yes")
			return
		log_admin("[key_name(usr)] has sent [key_name(player_to_send)] back to the Lobby.")
		message_admins("[key_name(usr)] has sent [key_name(player_to_send)] back to the Lobby.")
		var/mob/new_player/new_lobby_player = new()
		new_lobby_player.ckey = player_to_send.ckey
		qdel(player_to_send)
	else if(href_list["tdome1"] || href_list["tdome2"])
		if(!check_rights(R_FUN))
			return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = null
		var/team = ""

		if(href_list["tdome1"])
			team = "Green"
			M = locate(href_list["tdome1"])
		else if (href_list["tdome2"])
			team = "Red"
			M = locate(href_list["tdome2"])

		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		var/obj/item/packobelongings/pack = null
		var/obj/effect/landmark/packmark = pick(tdomepacks)
		var/turf/packspawn = tdomepacks.len ? get_turf(packmark) : get_turf(M) //the players' belongings are stored there, in the Thunderdome Admin lodge.
		switch(team)
			if("Green")
				pack = new /obj/item/packobelongings/green(get_step(get_step(packspawn,EAST),EAST))
			if("Red")
				pack = new /obj/item/packobelongings/red(get_step(get_step(packspawn,WEST),WEST))

		pack.name = "[M.real_name]'s belongings"

		var/might_need_glasses = FALSE
		for(var/obj/item/I in M)
			if(istype(I,/obj/item/clothing/glasses))
				var/obj/item/clothing/glasses/G = I
				if(G.nearsighted_modifier != 0)
					might_need_glasses = TRUE
			M.u_equip(I,1)
			if(I)
				I.forceMove(M.loc)
				I.reset_plane_and_layer()
				//I.dropped(M)
				I.forceMove(pack)

		if (might_need_glasses && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/regular(H), slot_glasses)

		var/obj/item/weapon/card/id/thunderdome/ident = null

		switch(team)
			if("Green")
				ident = new /obj/item/weapon/card/id/thunderdome/green(M)
				ident.name = "[M.real_name]'s Thunderdome Green ID"
			if("Red")
				ident = new /obj/item/weapon/card/id/thunderdome/red(M)
				ident.name = "[M.real_name]'s Thunderdome Red ID"

		if(!iscarbon(M))
			qdel(ident)

		switch(team)
			if("Green")
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					H.equip_to_slot_or_del(new /obj/item/clothing/under/color/green(H), slot_w_uniform)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
					H.equip_to_slot_or_del(ident, slot_wear_id)
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/thunderdome/green(H), slot_belt)
					H.regenerate_icons()
				else if(ismonkey(M))
					var/mob/living/carbon/monkey/K = M
					var/obj/item/clothing/monkeyclothes/jumpsuit_green/JS = new /obj/item/clothing/monkeyclothes/jumpsuit_green(K)
					var/obj/item/clothing/monkeyclothes/olduniform = null
					var/obj/item/clothing/monkeyclothes/oldhat = null
					if(K.uniform)
						olduniform = K.uniform
						K.uniform = null
						olduniform.forceMove(pack)
					K.uniform = JS
					K.uniform.forceMove(K)
					if(K.hat)
						oldhat = K.hat
						K.hat = null
						oldhat.forceMove(pack)
					K.put_in_hands(ident)
					K.put_in_hands(new /obj/item/weapon/storage/belt/thunderdome/green(K))
					K.regenerate_icons()

			if("Red")
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					H.equip_to_slot_or_del(new /obj/item/clothing/under/color/red(H), slot_w_uniform)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
					H.equip_to_slot_or_del(ident, slot_wear_id)
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/thunderdome/red(H), slot_belt)
					H.regenerate_icons()
				else if(ismonkey(M))
					var/mob/living/carbon/monkey/K = M
					var/obj/item/clothing/monkeyclothes/jumpsuit_red/JS = new /obj/item/clothing/monkeyclothes/jumpsuit_red(K)
					var/obj/item/clothing/monkeyclothes/olduniform = null
					var/obj/item/clothing/monkeyclothes/oldhat = null
					if(K.uniform)
						olduniform = K.uniform
						K.uniform = null
						olduniform.forceMove(pack)
					K.uniform = JS
					K.uniform.forceMove(K)
					if(K.hat)
						oldhat = K.hat
						K.hat = null
						oldhat.forceMove(pack)
					K.put_in_hands(ident)
					K.put_in_hands(new /obj/item/weapon/storage/belt/thunderdome/red(K))
					K.regenerate_icons()

		if(pack.contents.len == 0)
			qdel(pack)

		switch(team)
			if("Green")
				log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team Green)")
				message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team Green)", 1)
				M.forceMove(pick(tdome1))
			if("Red")
				log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team Red)")
				message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team Red)", 1)
				M.forceMove(pick(tdome2))

		to_chat(M, "<span class='danger'>You have been chosen to fight for the [team] Team. [pick(\
		"The wheel of fate is turning!",\
		"Heaven or Hell!",\
		"Set Spell Card!",\
		"Hologram Summer Again!",\
		"Get ready for the next battle!",\
		"Fight for your life!",\
		)]</span>")

	else if(href_list["tdomeadmin"])
		if(!check_rights(R_FUN))
			return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdomeadmin"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		M.Paralyse(5)
		sleep(5)
		M.forceMove(pick(tdomeadmin))
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Admin.)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Admin.)", 1)

	else if(href_list["tdomeobserve"])
		if(!check_rights(R_FUN))
			return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdomeobserve"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		for(var/obj/item/I in M)
			M.u_equip(I,1)
			if(I)
				I.forceMove(M.loc)
				I.reset_plane_and_layer()
				//I.dropped(M)

		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/observer = M
			observer.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket(observer), slot_w_uniform)
			observer.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(observer), slot_shoes)
		M.Paralyse(5)
		sleep(5)
		M.forceMove(pick(tdomeobserve))
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Observer.)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Observer.)", 1)

	else if(href_list["revive"])
		if(!check_rights(R_REJUVENATE))
			return

		var/mob/living/L = locate(href_list["revive"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /mob/living")
			return

		if(config.allow_admin_rev)
			L.revive(0)
			message_admins("<span class='warning'>Admin [key_name_admin(usr)] healed / revived [key_name_admin(L)]!</span>", 1)
			log_admin("[key_name(usr)] healed / revived [key_name(L)]")
		else
			to_chat(usr, "Admin Rejuvenates have been disabled")

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		var/spawn_here = alert("Spawn AI at your location?", "Spawn Location", "Yes", "No")

		message_admins("<span class='warning'>Admin [key_name_admin(usr)] AIized [key_name_admin(H)]!</span>", 1)
		log_admin("[key_name(usr)] AIized [key_name(H)]")
		var/mob/M = H.AIize(spawn_here == "Yes"? 1 : 0)
		if(M)
			if(M.client == CLIENT)
				usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makealien"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		var/mob/M = usr.client.cmd_admin_alienize(H)
		if(M)
			if(M.client == CLIENT)
				usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["makeslime"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makeslime"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		var/mob/M = usr.client.cmd_admin_slimeize(H)
		if(M)
			if(M.client == CLIENT)
				usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["makecluwne"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makecluwne"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		var/mob/M = usr.client.cmd_admin_cluwneize(H)
		if(M)
			if(M.client == CLIENT)
				usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["makebox"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/C = locate(href_list["makebox"])
		if(!istype(C))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon")
			return

		var/mob/M = usr.client.cmd_admin_boxify(C)
		if(M)
			if(M.client == CLIENT)
				usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["makecatbeast"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makecatbeast"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		if(alert(src.owner, "Are you sure you wish to catbeast [key_name(H)]?",  "Catbeast?" , "Yes" , "No") != "Yes")
			return

		if(H)
			H.set_species("Tajaran", force_organs=1)
			H.regenerate_icons()
			add_gamelogs(usr, "turned [key_name(H)] into a catbeast", tp_link = FALSE)
		else
			to_chat(usr, "Failed! Something went wrong.")

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		var/mob/M = usr.client.cmd_admin_robotize(H)
		if(M)
			if(M.client == CLIENT)
				usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["makemommi"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makemommi"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		var/mob/M = usr.client.cmd_admin_mommify(H)
		if(M)
			if(M.client == CLIENT)
				usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["makeanimal"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/M = locate(href_list["makeanimal"])
		if(istype(M, /mob/new_player))
			to_chat(usr, "This cannot be used on instances of type /mob/new_player")
			return

		var/mob/new_mob = usr.client.cmd_admin_animalize(M)
		if(new_mob && new_mob != M)
			if(new_mob.client == CLIENT)
				usr = new_mob //We probably transformed ourselves
			show_player_panel(new_mob)

	else if(href_list["changehands"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/M = locate(href_list["changehands"])
		if(!istype(M))
			return

		var/max_hands = 40 //This number is randomly chosen

		var/new_amount = input(usr, "Input a new amount of hands for [M] (current: [M.held_items.len]). WARNING: values larger than 4 may significantly clutter the UI. Maximum amount is [max_hands].", "Hands", M.held_items.len) as num
		if(new_amount == null)
			return

		new_amount = clamp(new_amount, 0, max_hands)

		M.set_hand_amount(new_amount)
		to_chat(usr, "<span class='info'>Changed [M]'s amount of hands to [new_amount].</span>")

	else if(href_list["togmutate"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["togmutate"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return
		var/block=text2num(href_list["block"])
		//testing("togmutate([href_list["block"]] -> [block])")
		usr.client.cmd_admin_toggle_block(H,block)
		show_player_panel(H)
		//H.regenerate_icons()

/***************** BEFORE**************

	if (href_list["l_players"])
		var/dat = "<B>Name/Real Name/Key/IP:</B><HR>"
		for(var/mob/M in world)
			var/foo = ""
			if (ismob(M) && M.client)
				if(!M.client.authenticated && !M.client.authenticating)
					foo += text("\[ <A HREF='?src=\ref[];adminauth=\ref[]'>Authorize</A> | ", src, M)
				else
					foo += text("\[ <B>Authorized</B> | ")
				if(M.start)
					if(!istype(M, /mob/living/carbon/monkey))
						foo += text("<A HREF='?src=\ref[];monkeyone=\ref[]'>Monkeyize</A> | ", src, M)
					else
						foo += text("<B>Monkeyized</B> | ")
					if(istype(M, /mob/living/silicon/ai))
						foo += text("<B>Is an AI</B> | ")
					else
						foo += text("<A HREF='?src=\ref[];makeai=\ref[]'>Make AI</A> | ", src, M)
					if(M.z != map.zCentcomm)
						foo += text("<A HREF='?src=\ref[];sendtoprison=\ref[]'>Prison</A> | ", src, M)
						foo += text("<A HREF='?src=\ref[];sendtomaze=\ref[]'>Maze</A> | ", src, M)
					else
						foo += text("<B>On Z = 2</B> | ")
				else
					foo += text("<B>Hasn't Entered Game</B> | ")
				foo += text("<A HREF='?src=\ref[];revive=\ref[]'>Heal/Revive</A> | ", src, M)

				foo += text("<A HREF='?src=\ref[];forcespeech=\ref[]'>Say</A> \]", src, M)
			dat += text("N: [] R: [] (K: []) (IP: []) []<BR>", M.name, M.real_name, (M.client ? M.client : "No client"), M.lastKnownIP, foo)

		usr << browse(dat, "window=players;size=900x480")

*****************AFTER******************/

// Now isn't that much better? IT IS NOW A PROC, i.e. kinda like a big panel like unstable

	else if(href_list["adminplayeropts"])
		var/mob/M = locate(href_list["adminplayeropts"])
		show_player_panel(M)

	else if(href_list["adminplayerobservejump"])
		if(!check_rights(R_MOD,0) && !check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["adminplayerobservejump"])

		SendAdminGhostTo(null,M)

	else if(href_list["emergency_shuttle_panel"])
		emergency_shuttle_panel()

	else if(href_list["check_antagonist"])
		check_antagonists()

	else if(href_list["adjustthreat"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/gamemode/dynamic/D = ticker.mode
		if(!istype(D))
			return
		var/threatadd = input("Specify how much threat to add (negative to subtract). This can inflate the threat level.", "Adjust Threat", 0) as null|num
		if(!threatadd)
			return
		if(threatadd>0)
			D.create_midround_threat(threatadd)
		else
			D.spend_midround_threat(-threatadd) //Spend a positive value. Negative the negative.
		D.threat_log += "[worldtime2text()]: Admin [key_name(usr)] adjusted threat by [threatadd]."
		message_admins("[key_name(usr)] adjusted threat by [threatadd].")
		check_antagonists()

	else if(href_list["injectnow"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/gamemode/dynamic/D = ticker.mode
		if(!istype(D))
			return
		switch(href_list["injectnow"])
			if("1")
				D.latejoin_injection_cooldown = 0
				message_admins("[key_name(usr)] set the latejoin injection timer to 0.")
			if("2")
				D.midround_injection_cooldown = 0
				message_admins("[key_name(usr)] set the midround injection timer to 0.")
			else
				message_admins("[key_name(usr)] attempted to set an unknown timer to 0.")
		check_antagonists()

	else if(href_list["adminplayerobservecoodjump"])
		if(!check_rights(R_ADMIN))
			return

		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		var/client/C = usr.client
		if(!isobserver(usr) && isliving(usr))
			var/mob/living/L = usr
			L.ghost()
		sleep(2)
		C.jumptocoord(x,y,z)

	else if(href_list["shuttlepermission"])
		if(!check_rights(R_ADMIN))
			return

		var/datum/shuttle/shuttle = locate(href_list["shuttle"])
		var/obj/docking_port/D = locate(href_list["docking_port"])
		var/obj/machinery/computer/shuttle_control/broadcast = locate(href_list["broadcast"])
		var/mob/user = locate(href_list["user"])
		var/answer = text2num(href_list["answer"])

		var/reason = input(user, "State the reasons for your choice (optional).", "Request Answer", "")

		if (answer)
			if(broadcast)
				broadcast.announce( "Permission Granted. [reason]" )
			else if(user)
				to_chat(user, "Permission Granted. [reason]")
			shuttle.actually_travel_to(D,broadcast,user)
			log_admin("[key_name_admin(usr)] granted permission to [key_name(user)] to fly their [shuttle.name] to [D.areaname]")
			message_admins("[key_name_admin(usr)] granted permission to [key_name(user)] to fly their [shuttle.name] to [D.areaname]")
		else
			if(broadcast)
				broadcast.announce( "Permission Denied. [reason]" )
			else if(user)
				to_chat(user, "Permission Denied. [reason]")
			log_admin("[key_name_admin(usr)] denied permission to [key_name(user)] to fly their [shuttle.name] to [D.areaname]")
			message_admins("[key_name_admin(usr)] denied permission to [key_name(user)] to fly their [shuttle.name] to [D.areaname]")


	else if(href_list["syndbeaconpermission"])
		if(!check_rights(R_ADMIN))
			return

		var/obj/machinery/syndicate_beacon/syndbeacon = locate(href_list["syndbeacon"])
		var/mob/user = locate(href_list["user"])
		var/answer = text2num(href_list["answer"])

		if (!syndbeacon || !user)
			return

		switch (answer)
			if (1)
				syndbeacon.ready_up()
				log_admin("[key_name_admin(usr)] granted permission to [key_name(user)] to make use of an already used syndicate beacon")
				message_admins("[key_name_admin(usr)] granted permission to [key_name(user)] to make use of an already used syndicate beacon")
			if (2)
				syndbeacon.temptext = "<i>We have no need for you at this time. Have a pleasant day.</i><br>"
				syndbeacon.updateUsrDialog()
				log_admin("[key_name_admin(usr)] denied permission to [key_name(user)] to make use of an already used syndicate beacon")
				message_admins("[key_name_admin(usr)] denied permission to [key_name(user)] to make use of an already used syndicate beacon")
			if (3)
				syndbeacon.temptext = "<i>The Syndicate has grown tired of you.</i><br>"
				syndbeacon.updateUsrDialog()
				syndbeacon.selfdestruct()
				log_admin("[key_name_admin(usr)] denied permission to [key_name(user)] to make use of an already used syndicate beacon and destroyed it.")
				message_admins("[key_name_admin(usr)] denied permission to [key_name(user)] to make use of an already used syndicate beacon and destroyed it.")

	else if(href_list["adminchecklaws"])
		output_ai_laws()

	else if(href_list["adminmoreinfo"])
		var/mob/M = locate(href_list["adminmoreinfo"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/location_description = ""
		var/special_role_description = ""
		var/health_description = ""
		var/gender_description = ""
		var/species_description = "Not A Human"
		var/turf/T = get_turf(M)

		//Location
		if(isturf(T))
			if(isarea(T.loc))
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
			else
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z])"

		/*Job + antagonist
		if(M.mind)
			special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <span class='red'><b>[M.mind.special_role]</b></span>; Has been rev: [(M.mind.has_been_rev)?"Yes":"No"]"
		else
			special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>; Has been rev: <i>Mind datum missing</i>;"
		*/
		//Health
		if(isliving(M))
			var/mob/living/L = M
			var/status
			switch (M.stat)
				if (0)
					status = "Alive"
				if (1)
					status = "<font color='orange'><b>Unconscious</b></font>"
				if (2)
					status = "<font color='red'><b>Dead</b></font>"
			health_description = "Status = [status]"
			health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getBrainLoss()]"
		else
			health_description = "This mob type has no health to speak of."

		//Gener
		switch(M.gender)
			if(MALE,FEMALE)
				gender_description = "[M.gender]"
			else
				gender_description = "<font color='red'><b>[M.gender]</b></font>"

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			species_description = "[H.species ? H.species.name : "<span class='danger'><b>No Species</b></span>"]"
		to_chat(src.owner, "<b>Info about [M.name]:</b> ")
		to_chat(src.owner, "Mob type = [M.type]; Species = [species_description]; Gender = [gender_description]; Damage = [health_description];")
		to_chat(src.owner, "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind?"[M.mind.name]":""]; Key = <b>[M.key]</b>;")
		to_chat(src.owner, "Location = [location_description];")
		to_chat(src.owner, "[special_role_description]")
		to_chat(src.owner, "(<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a>) (<A HREF='?src=\ref[src];adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[M]'>VV</A>) (<A HREF='?src=\ref[src];subtlemessage=\ref[M]'>SM</A>) (<A HREF='?src=\ref[src];adminplayerobservejump=\ref[M]'>JMP</A>) (<A HREF='?src=\ref[src];secretsadmin=check_antagonist'>CA</A>)")

	else if(href_list["adminspawncookie"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/living/carbon/H = locate(href_list["adminspawncookie"])
		if(!iscarbon(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon")
			return

		var/answer = alert("Give them a Cookie? A Pomf Coin? Or a Pumf Coin?","Spawn Cookie","Cookie","Pomf","Pumf")
		var/spawntype = /obj/item/weapon/reagent_containers/food/snacks/cookie
		var/feedback = "You received the <b>best cookie</b>!"
		if (answer == "Pomf")
			spawntype = /obj/item/weapon/coin/pomf
			feedback = "You were rewarded with a most precious pomf coin. Keep it preciously, or use it wisely."
		else if (answer == "Pumf")
			spawntype = /obj/item/weapon/coin/pumf
			feedback = "You have greatly angered the gods, and their grudge toward you has been crystalized into a damned pumf coin."

		var/obj/item/reward = new spawntype(H)
		if (answer == "Cookie")
			var/obj/item/weapon/reagent_containers/food/snacks/cookie/C = reward
			C.thermal_variation_modifier = 0

		if(!H.put_in_hands(reward))
			log_admin("[key_name(H)] has their hands full, so they did not receive their [answer], spawned by [key_name(src.owner)].")
			message_admins("[key_name(H)] has their hands full, so they did not receive their [answer], spawned by [key_name(src.owner)].")
			return

		log_admin("[key_name(H)] got their [answer], spawned by [key_name(src.owner)]")
		message_admins("[key_name(H)] got their [answer], spawned by [key_name(src.owner)]")
		feedback_inc("admin_cookies_spawned",1)

		to_chat(H, "<span class='notice'>Your prayers have been answered!! [feedback]</span>")

	else if(href_list["addcancer"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["addcancer"])
		if(!ishuman(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		if(alert(src.owner, "Are you sure you wish to inflict cancer upon [key_name(H)]?",  "Confirm Cancer?" , "Yes" , "No") != "Yes")
			return

		log_admin("[key_name(H)] was inflicted with cancer, courtesy of [key_name(src.owner)]")
		message_admins("[key_name(H)] was inflicted with cancer, courtesy of [key_name(src.owner)]")
		H.add_cancer()

	else if(href_list["BlueSpaceArtillery"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/living/M = locate(href_list["BlueSpaceArtillery"])
		if(!isliving(M))
			to_chat(usr, "This can only be used on instances of type /mob/living")
			return

		if(alert(src.owner, "Are you sure you wish to hit [key_name(M)] with Blue Space Artillery?",  "Confirm Firing?" , "Yes" , "No") != "Yes")
			return

		if(BSACooldown)
			to_chat(src.owner, "Standby!  Reload cycle in progress!  Gunnery crews ready in five seconds!")
			return

		BSACooldown = 1
		spawn(50)
			BSACooldown = 0

		to_chat(M, "<span class='danger'>You've been hit by bluespace artillery!</span>")

		log_admin("[key_name(M)] has been hit by Bluespace Artillery fired by [src.owner]")
		message_admins("[key_name(M)] has been hit by Bluespace Artillery fired by [src.owner]")

		var/obj/effect/stop/S
		S = new /obj/effect/stop
		S.victim = M
		S.forceMove(M.loc)
		spawn(20)
			qdel(S)

		var/turf/simulated/floor/T = get_turf(M)
		if(istype(T))
			if(prob(80))
				T.break_tile_to_plating()
			else
				T.break_tile()

		playsound(T, 'sound/effects/yamato_fire.ogg', 75, 1, gas_modified = 0)

		if(M.health == 1)
			M.gib()
		else
			M.adjustBruteLoss( min( 99 , (M.health - 1) )    )
			M.Stun(20)
			M.Knockdown(20)
			M.stuttering = 20

	else if(href_list["NarSieDevour"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/living/M = locate(href_list["NarSieDevour"])
		if(!isliving(M))
			to_chat(usr, "This can only be used on instances of type /mob/living")
			return

		if(alert(src.owner, "Are you sure you wish to gib [key_name(M)]?",  "Confirm Gibbing?" , "Yes" , "No") != "Yes")
			return

		to_chat(M, "<span class='danger'>You have angered the gods!</span>")

		log_admin("[key_name(M)] has been Devoured (gibbed) by [src.owner]")
		message_admins("[key_name(M)] has been Devoured (gibbed) by [src.owner]")

		M.Stun(10)
		anim(target = M, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_sac", lay = ABOVE_SINGULO_LAYER, plane = EFFECTS_PLANE)
		sleep(4)
		M.gib()


	else if(href_list["Assplode"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["Assplode"])
		if(!ishuman(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		if(H.op_stage.butt != 4) // does the target have an ass
			H.butt_blast()
			to_chat(H, "<span class='warning'>Your ass was just blown off by an unknown force!</span>")
			log_admin("[key_name(H)] was buttblasted by [src.owner]")
			message_admins("[key_name(H)] was buttblasted by [src.owner]")
			H.Knockdown(8)
			H.Stun(8)
		else
			to_chat(usr, "This target has already lost their butt in some unfortunate circumstance.")

	else if(href_list["DealBrainDam"])
		if(!check_rights(R_ADMIN|R_FUN))
			return
		var/mob/living/M = locate(href_list["DealBrainDam"])
		if(!isliving(M))
			to_chat(usr, "<span class = 'warning'>\The [M] is not of type /mob/living.</span>")
			return
		var/choice = input("How much brain damage would you like to deal to the subject?", "Instant Lobotomy", 1) as null|num
		if(choice)
			log_admin("[key_name(M)] was dealt [choice] amount of brain damage by [src.owner]")
			message_admins("[key_name(M)] was dealt [choice] amount of brain damage by [src.owner]")
			M.adjustBrainLoss(choice)

	else if (href_list["PrayerReply"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["PrayerReply"])
		output_to_msay("<span class = 'bold'>[key_name_admin(src.owner)] is replying to a prayer from [key_name_admin(M)]</span>.")

		usr.client.cmd_admin_subtle_message(M)

	else if(href_list["CentcommReply"])
		var/mob/M = locate(href_list["CentcommReply"])

		output_to_msay("<span class = 'bold'>[key_name_admin(src.owner)] is replying to a Centcomm message from [key_name_admin(M)]</span>.")

		var/receive_type
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(!istype(H.ears, /obj/item/device/radio/headset))
				to_chat(usr, "<span class='warning'>The person you are trying to contact is not wearing a headset.</span>")
				return
			receive_type = "headset"
		else if(istype(M, /mob/living/silicon))
			receive_type = "official communication channel"
		if(!receive_type)
			to_chat(usr, "<span class='warning'>This mob type cannot be replied to.</span>")
			return

		var/input = input(src.owner, "Please enter a message to reply to [key_name(M)] via their [receive_type].","Outgoing message from Central Command", "")
		if(!input)
			return

		to_chat(src.owner, "You sent <span class = 'bold'>\"[input]\"</span> to <span class = 'bold'>[M]</span> via a secure channel.")
		log_admin("[src.owner] replied to [key_name(M)]'s Centcomm message with the message [input].")
		output_to_msay("<span class = 'bold'>[key_name_admin(src.owner)] replied to [key_name_admin(M)]'s Centcom message with:</span> \"[input]\"")
		to_chat(M, "<span class='notice'>You hear something crackle from your [receive_type] for a moment before a voice speaks:</span>\n\"Please stand by for a message from Central Command. Message as follows.\"\n<span class = 'bold'>\"[input]\"</span>")

	else if(href_list["NarSieReply"])
		var/mob/M = locate(href_list["NarSieReply"])
		if (!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		output_to_msay("<span class = 'bold'>[key_name_admin(src.owner)] is replying to a communion to Nar-Sie from [key_name_admin(M)]</span>.")

		var/datum/role/cultist/C = iscultist(M)
		if (!C)
			to_chat(usr, "<span class='warning'>Non-cultists cannot be replied to.</span>") // should only happen if they get deconverted in the meantime
			return

		var/message = input("What message shall Nar-Sie respond with?",
                    "Nar-Sie Reply",
                    "")
		if (!message)
			return

		if (M)
			to_chat(M, "<b><span class='danger'>Nar-Sie</span></b> murmurs... <span class='sinister'>[message]</span>")

		for(var/mob/dead/observer/O in player_list)
			to_chat(O, "<span class='game say'><b><span class='danger'>Nar-Sie</span></b> replies to [M]... <span class='sinister'>[message]</span></span>")

		message_admins("Admin [key_name_admin(usr)] has replied to a communion from [key_name(M)].")
		log_admin("[src.owner] replied to [key_name(M)]'s communion to Nar-Sie with the message: [message].")
		output_to_msay("<span class = 'bold'>[key_name_admin(src.owner)] replied to [key_name_admin(M)]'s communion to Nar-Sie with:</span> \"[message]\"")

	else if(href_list["SyndicateReply"])
		var/mob/M = locate(href_list["SyndicateReply"])

		output_to_msay("<span class = 'bold'>[key_name_admin(src.owner)] is replying to a Syndicate message from [key_name_admin(M)]</span>.")

		var/receive_type
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(!istype(H.ears, /obj/item/device/radio/headset))
				to_chat(usr, "<span class='warning'>The person you are trying to contact is not wearing a headset.</span>")
				return
			receive_type = "headset"
		else if(istype(M, /mob/living/silicon))
			receive_type = "undetectable communications channel"
		if(!receive_type)
			to_chat(usr, "<span class='warning'>This mob type cannot be replied to.</span>")
			return

		var/input = input(src.owner, "Please enter a message to reply to [key_name(M)] via their [receive_type].","Outgoing message from The Syndicate", "")
		if(!input)
			return

		to_chat(src.owner, "You sent <span class = 'bold'>\"[input]\"</span> to <span class = 'bold'>[M]</span> via a secure channel.")
		log_admin("[src.owner] replied to [key_name(M)]'s Syndicate message with the message [input].")
		output_to_msay("<span class = 'bold'>[key_name_admin(src.owner)] replied to [key_name_admin(M)]'s Syndicate message with:</span> \"[input]\"")
		to_chat(M, "<span class='notice'>You hear something crackle from your [receive_type] for a moment before a voice speaks:</span>\n\"Please stand by for a message from your benefactor, agent. Message as follows.\"\n<span class = 'bold'>\"[input]\"</span>")

	else if(href_list["CentcommFaxView"])
		var/obj/item/weapon/paper/P = locate(href_list["CentcommFaxView"])
		var/info_2 = ""
		if(P.img)
			usr << browse_rsc(P.img.img, "tmp_photo.png")
			info_2 = "<img src='tmp_photo.png' width='192' style='-ms-interpolation-mode:nearest-neighbor' /><br>"
		usr << browse("<HTML><HEAD><TITLE>Centcomm Fax Message</TITLE></HEAD><BODY>[info_2][P.info][P.stamps]</BODY></HTML>", "window=Centcomm Fax Message")

	else if(href_list["CentcommFaxReply"])
		var/mob/living/carbon/human/H = locate(href_list["CentcommFaxReply"])

		output_to_msay("<span class = 'bold'>[key_name_admin(src.owner)] is replying to a fax message from [key_name_admin(H)].</span>")

		var/sent = input(src.owner, "Please enter a message to reply to [key_name(H)] via secure connection. NOTE: BBCode does not work, but HTML tags do! Use <br> for line breaks.", "Outgoing message from Centcomm", "") as message|null
		if(!sent)
			return

		var/sentname = input(src.owner, "Pick a title for the report", "Title") as text|null

		var/obj/item/weapon/paper/replyfax = SendFax(sent, sentname, centcomm = 1)
		if(!istype(replyfax))
			to_chat(src.owner, "<span class='warning'>Message reply to [key_name(H)] failed.</span>")
			return

		to_chat(src.owner, "<span class='notice'>Message reply to [key_name(H)] transmitted successfully.</span>")
		log_admin("[key_name(src.owner)] replied to a fax message from [key_name(H)]: [sent]")
		output_to_msay("<span class = 'bold'>[key_name_admin(src.owner)] replied to a fax message from [key_name_admin(H)]:</span> <a href='?_src_=holder;CentcommFaxView=\ref[replyfax]'>View Message</a>")


	else if(href_list["jumpto"])
		if(!check_rights(R_ADMIN))
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

	else if(href_list["sound_reply"])
		if(!check_rights(R_SOUNDS))
			return

		var/mob/M = locate(href_list["sound_reply"])
		usr.client.play_direct_sound(M)

	else if(href_list["rapsheet"])
		usr << link(getVGPanel("rapsheet", admin = 1, query = list("ckey" = href_list["rsckey"])))
		return

	else if(href_list["bansheet"])
		usr << link(getVGPanel("rapsheet", admin = 1))
		return

	else if(href_list["traitor"])
		if(!check_rights(R_ADMIN|R_MOD))
			return

		if(!ticker || !ticker.mode)
			alert("The game hasn't started yet!")
			return

		var/mob/M = locate(href_list["traitor"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob.")
			return
		show_role_panel(M)

	else if(href_list["threatlog"])
		if(!check_rights(R_ADMIN))
			return

		if(!ticker || !ticker.mode)
			alert("The game hasn't started yet!")
			return

		var/datum/gamemode/dynamic/D = ticker.mode
		if(!istype(D))
			alert("It's not dynamic!")
			return
		D.show_threatlog(usr)

	// /vg/
	else if(href_list["set_base_laws"])
		if(!check_rights(R_FUN))
			to_chat(usr, "<span class='warning'>You don't have +FUN. Go away.</span>")
			return
		var/lawtypes = typesof(/datum/ai_laws) - /datum/ai_laws
		var/selected_law = input("Select the default lawset desired.","Lawset Selection",null) as null|anything in lawtypes
		if(!selected_law)
			return
		var/subject="Unknown"
		switch(href_list["set_base_laws"])
			if("ai")
				base_law_type = selected_law
				subject = "AIs and Cyborgs"
			if("mommi")
				mommi_laws["Default"] = selected_law
				subject = "MoMMIs"
		to_chat(usr, "<span class='notice'>New [subject] will spawn with the [selected_law] lawset.</span>")
		log_admin("[key_name(src.owner)] set the default laws of [subject] to: [selected_law]")
		message_admins("[key_name_admin(src.owner)] set the default laws of [subject] to: [selected_law]", 1)
		lawchanges.Add("[key_name_admin(src.owner)] set the default laws of [subject] to: [selected_law]")

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

	else if(href_list["object_list"])			//this is the laggiest thing ever
		if(!check_rights(R_SPAWN))
			return

		if(!config.allow_admin_spawning)
			to_chat(usr, "Spawning of items is not allowed.")
			return

		var/atom/loc = usr.loc

		var/dirty_paths
		if (istext(href_list["object_list"]))
			dirty_paths = list(href_list["object_list"])
		else if (istype(href_list["object_list"], /list))
			dirty_paths = href_list["object_list"]

		var/paths = list()
		var/removed_paths = list()

		for(var/dirty_path in dirty_paths)
			var/path = text2path(dirty_path)
			if(!path)
				removed_paths += dirty_path
				continue
			else if(!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
				removed_paths += dirty_path
				continue
			else if(ispath(path, /obj/item/weapon/gun/energy/pulse_rifle))
				if(!check_rights(R_FUN,0))
					removed_paths += dirty_path
					continue
			else if(ispath(path, /obj/effect/bhole))
				if(!check_rights(R_FUN,0))
					removed_paths += dirty_path
					continue
			paths += path

		if(!paths)
			alert("The path list you sent is empty")
			return
		if(length(paths) > 5)
			alert("Select fewer object types, (max 5)")
			return
		else if(length(removed_paths))
			alert("Removed:\n" + jointext(removed_paths, "\n"))

		var/list/offset = splittext(href_list["offset"],",")
		var/number = clamp(text2num(href_list["object_count"]), 1, 100)
		var/X = offset.len > 0 ? text2num(offset[1]) : 0
		var/Y = offset.len > 1 ? text2num(offset[2]) : 0
		var/Z = offset.len > 2 ? text2num(offset[3]) : 0
		var/tmp_dir = href_list["object_dir"]
		var/obj_dir = tmp_dir ? text2num(tmp_dir) : 2
		if(!obj_dir || !(obj_dir in alldirs))
			obj_dir = 2
		var/obj_name = sanitize(href_list["object_name"])
		var/where = href_list["object_where"]
		if (!( where in list("onfloor","inhand","inmarked") ))
			where = "onfloor"

		if( where == "inhand" )
			to_chat(usr, "Support for inhand not available yet. Will spawn on floor.")
			where = "onfloor"

		if ( where == "inhand" )	//Can only give when human or monkey
			if ( !( ishuman(usr) || ismonkey(usr) ) )
				to_chat(usr, "Can only spawn in hand when you're a human or a monkey.")
				where = "onfloor"
			else if ( usr.get_active_hand() )
				to_chat(usr, "Your active hand is full. Spawning on floor.")
				where = "onfloor"

		if ( where == "inmarked" )
			if ( !marked_datum )
				to_chat(usr, "You don't have any object marked. Abandoning spawn.")
				return
			else
				if ( !istype(marked_datum,/atom) )
					to_chat(usr, "The object you have marked cannot be used as a target. Target must be of type /atom. Abandoning spawn.")
					return

		var/atom/target //Where the object will be spawned
		switch ( where )
			if ( "onfloor" )
				switch (href_list["offset_type"])
					if ("absolute")
						target = locate(0 + X,0 + Y,0 + Z)
					if ("relative")
						target = locate(loc.x + X,loc.y + Y,loc.z + Z)
			if ( "inmarked" )
				target = marked_datum

		if(target)
			for (var/path in paths)
				for (var/i = 0; i < number; i++)
					if(path in typesof(/turf))
						var/turf/O = target
						var/turf/N = O.ChangeTurf(path)
						if(N)
							if(obj_name)
								N.name = obj_name
					else
						var/atom/O = new path(target)
						if(O)
							O.dir = obj_dir
							if(obj_name)
								O.name = obj_name
								if(istype(O,/mob))
									var/mob/M = O
									M.real_name = obj_name

		if (number == 1)
			log_admin("[key_name(usr)] created a [english_list(paths)] at [formatJumpTo(get_turf(usr))]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created a [english_list(paths)] at [formatJumpTo(get_turf(usr))]", 1)
					break
		else
			log_admin("[key_name(usr)] created [number]ea [english_list(paths)] at [formatJumpTo(get_turf(usr))]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created [number]ea [english_list(paths)] at [formatJumpTo(get_turf(usr))]", 1)
					break
		return

	else if(href_list["secretsfun"])
		if(!check_rights(R_FUN))
			return

		switch(href_list["secretsfun"])
			if("sec_all_clothes")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SAC")
				for(var/obj/item/clothing/O in world)
					qdel(O)
			if("monkey")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","M")
				for(var/mob/living/carbon/human/H in mob_list)
					spawn(0)
						H.monkeyize()
			if("corgi")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","M")
				for(var/mob/living/carbon/human/H in mob_list)
					spawn(0)
						H.corgize()
			if("striketeam-deathsquad")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","DeathQuad")
				var/datum/striketeam/deathsquad/team = new /datum/striketeam/deathsquad()
				team.trigger_strike(usr)
			if("striketeam-ert")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","ERT")
				var/datum/striketeam/ert/team = new /datum/striketeam/ert()
				team.trigger_strike(usr)
			if("striketeam-syndi")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SyndiStrikeTeam")
				var/datum/striketeam/syndicate/team = new /datum/striketeam/syndicate()
				team.trigger_strike(usr)
			if("striketeam-custom")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","CustomStrikeTeam")
				custom_strike_team(usr)
			if("tripleAI")
				usr.client.triple_ai()
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","TriAI")
			if("RandomizedLawset")
				for(var/mob/living/silicon/ai/target in mob_list)
					to_chat(target,"<span class='danger'>[Gibberish("ERROR! BACKUP FILE CORRUPTED: PLEASE VERIFY INTEGRITY OF LAWSET.",10)]</span>")
					var/datum/ai_laws/randomize/RLS = new
					target.laws.inherent = RLS.inherent
					target.show_laws()
			if("gravity")
				if(!(ticker && ticker.mode))
					to_chat(usr, "Please wait until the game starts!  Not sure how it will work otherwise.")
					return
				gravity_is_on = !gravity_is_on
				for(var/area/A in areas)
					A.gravitychange(gravity_is_on,A)
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","Grav")
				if(gravity_is_on)
					log_admin("[key_name(usr)] toggled gravity on.", 1)
					message_admins("<span class='notice'>[key_name_admin(usr)] toggled gravity on.</span>", 1)
					command_alert(/datum/command_alert/gravity_enabled)
				else
					log_admin("[key_name(usr)] toggled gravity off.", 1)
					message_admins("<span class='notice'>[key_name_admin(usr)] toggled gravity off.</span>", 1)
					command_alert(/datum/command_alert/gravity_disabled)

			if("power")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","P")
				log_admin("[key_name(usr)] made all areas powered", 1)
				message_admins("<span class='notice'>[key_name_admin(usr)] made all areas powered</span>", 1)
				power_restore()
			if("unpower")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","UP")
				log_admin("[key_name(usr)] made all areas unpowered", 1)
				message_admins("<span class='notice'>[key_name_admin(usr)] made all areas unpowered</span>", 1)
				power_failure()
			if("quickpower")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","QP")
				log_admin("[key_name(usr)] made all SMESs powered", 1)
				message_admins("<span class='notice'>[key_name_admin(usr)] made all SMESs powered</span>", 1)
				power_restore_quick()
			if("breaklink")
				log_admin("[key_name(usr)] broke the link with central command", 1)
				message_admins("<span class='notice'>[key_name_admin(usr)] broke the link with central command</span>", 1)
				unlink_from_centcomm()
			if("makelink")
				log_admin("[key_name(usr)] created a link with central command", 1)
				message_admins("<span class='notice'>[key_name_admin(usr)] created a link with central command</span>", 1)
				link_to_centcomm()
			if("traitor_all")
				if(!ticker)
					alert("The game hasn't started yet!")
					return
				var/objective = copytext(sanitize(input("Enter an objective")),1,MAX_MESSAGE_LEN)
				if(!objective)
					return
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","TA([objective])")
				for(var/mob/living/carbon/human/H in player_list)
					if(H.isDead() || !H.client || !H.mind)
						continue
					if(is_special_character(H))
						continue
					//traitorize(H, objective, 0)
					var/datum/objective/new_objective = new
					new_objective.explanation_text = objective
					var/datum/role/traitor/T = new(H.mind, override = TRUE)
					if (T)
						T.AppendObjective(new_objective)
						T.Greet(GREET_AUTOTATOR) // Mission specifications etc
						T.OnPostSetup()
						T.AnnounceObjectives()
				for(var/mob/living/silicon/A in player_list)
					if(A.isDead() || !A.client || !A.mind)
						continue
					var/datum/objective/new_objective = new
					new_objective.explanation_text = objective
					var/datum/role/traitor/T = new(A.mind, override = TRUE)
					if (T)
						T.AppendObjective(new_objective)
						T.Greet(GREET_AUTOTATOR)
						T.OnPostSetup()
						T.AnnounceObjectives()

				message_admins("<span class='notice'>[key_name_admin(usr)] used everyone is a traitor secret. Objective is [objective]</span>", 1)
				log_admin("[key_name(usr)] used everyone is a traitor secret. Objective is [objective]")
			if("moveadminshuttle")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","ShA")
				move_admin_shuttle()
				message_admins("<span class='notice'>[key_name_admin(usr)] moved the centcom administration shuttle</span>", 1)
				log_admin("[key_name(usr)] moved the centcom administration shuttle")
			if("moveferry")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","ShF")
				if(!transport_shuttle || !transport_shuttle.linked_area)
					to_chat(usr, "There is no transport shuttle!")
					return

				transport_shuttle.move(usr)

				message_admins("<span class='notice'>[key_name_admin(usr)] moved the centcom ferry</span>", 1)
				log_admin("[key_name(usr)] moved the centcom ferry")
			if("togglebombcap")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BC")
				switch(MAX_EXPLOSION_RANGE)
					if(14)
						MAX_EXPLOSION_RANGE = 16
					if(16)
						MAX_EXPLOSION_RANGE = 20
					if(20)
						MAX_EXPLOSION_RANGE = 28
					if(28)
						MAX_EXPLOSION_RANGE = 56
					if(56)
						MAX_EXPLOSION_RANGE = 128
					else
						MAX_EXPLOSION_RANGE = 14
				var/range_dev = MAX_EXPLOSION_RANGE *0.25
				var/range_high = MAX_EXPLOSION_RANGE *0.5
				var/range_low = MAX_EXPLOSION_RANGE
				message_admins("<span class='danger'> [key_name_admin(usr)] changed the bomb cap to [range_dev], [range_high], [range_low]</span>", 1)
				log_admin("[key_name_admin(usr)] changed the bomb cap to [MAX_EXPLOSION_RANGE]")

			if("flicklights")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","FL")
				while(!usr.stat)
//knock yourself out to stop the ghosts
					for(var/mob/M in player_list)
						if(M.stat != 2 && prob(25))
							var/area/AffectedArea = get_area(M)
							if(AffectedArea.name != "Space" && AffectedArea.name != "Engine Walls" && AffectedArea.name != "Chemical Lab Test Chamber" && AffectedArea.name != "Escape Shuttle" && AffectedArea.name != "Arrival Area" && AffectedArea.name != "Arrival Shuttle" && AffectedArea.name != "start area" && AffectedArea.name != "Engine Combustion Chamber")
								AffectedArea.power_light = 0
								AffectedArea.power_change()
								spawn(rand(55,185))
									AffectedArea.power_light = 1
									AffectedArea.power_change()
								var/Message = rand(1,4)
								switch(Message)
									if(1)
										M.show_message(text("<span class='notice'>You shudder as if cold...</span>"), 1)
									if(2)
										M.show_message(text("<span class='notice'>You feel something gliding across your back...</span>"), 1)
									if(3)
										M.show_message(text("<span class='notice'>Your eyes twitch, you feel like something you can't see is here...</span>"), 1)
									if(4)
										M.show_message(text("<span class='notice'>You notice something moving out of the corner of your eye, but nothing is there...</span>"), 1)
								for(var/obj/W in orange(5,M))
									if(prob(25) && !W.anchored)
										step_rand(W)
					sleep(rand(100,1000))
				for(var/mob/M in player_list)
					if(M.stat != 2)
						M.show_message(text("<span class='notice'>The chilling wind suddenly stops...</span>"), 1)

			if("gravanomalies")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","GA")
				command_alert(/datum/command_alert/wormholes)
				var/turf/T = pick(blobstart)
				var/obj/effect/bhole/bh = new /obj/effect/bhole( T.loc, 30 )
				spawn(rand(100, 600))
					qdel(bh)
			if("timeanomalies")	//dear god this code was awful :P Still needs further optimisation
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","STA")
				//moved to its own dm so I could split it up and prevent the spawns copying variables over and over
				//can be found in code\game\game_modes\events\wormholes.dm
				wormhole_event()
			if("comms_blackout")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","CB")
				var/answer = alert(usr, "Would you like to alert the crew?", "Alert", "Yes", "No")
				if(answer == "Yes")
					communications_blackout(0)
				else
					communications_blackout(1)
				message_admins("[key_name_admin(usr)] triggered a communications blackout.", 1)
			if("blackout")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BO")
				message_admins("[key_name_admin(usr)] broke all lights", 1)
				for(var/obj/machinery/power/apc/apc in power_machines)
					apc.overload_lighting()
			if("whiteout")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","WO")
				for(var/obj/machinery/light/L in alllights)
					L.fix()
				message_admins("[key_name_admin(usr)] fixed all lights", 1)
			if("switchoff")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","WO")
				for(var/obj/machinery/light_switch/LS in lightswitches)
					LS.toggle_switch(0)
				message_admins("[key_name_admin(usr)] switched off all lights", 1)
			if("switchon")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","WO")
				for(var/obj/machinery/light_switch/LS in lightswitches)
					LS.toggle_switch(1)
				message_admins("[key_name_admin(usr)] switched on all lights", 1)
			if("floorlava")
				if(floorIsLava)
					to_chat(usr, "The floor is lava already.")
					return
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","LF")

				//Options
				var/length = input(usr, "How long will the lava last? (in seconds)", "Length", 180) as num
				length = min(abs(length), 1200)

				var/damage = input(usr, "How deadly will the lava be?", "Damage", 2) as num
				damage = min(abs(damage), 100)

				var/sure = alert(usr, "Are you sure you want to do this?", "Confirmation", "YES!", "Nah")
				if(sure == "Nah")
					return
				floorIsLava = 1

				message_admins("[key_name_admin(usr)] made the floor LAVA! It'll last [length] seconds and it will deal [damage] damage to everyone.", 1)
				var/count = 0
				var/list/lavaturfs = list()
				for(var/turf/simulated/floor/F in world)
					count++
					if(!(count % 50000))
						stoplag()
					if(F.z == map.zMainStation)
						F.name = "lava"
						F.desc = "The floor is LAVA!"
						F.overlays += image(icon = F.icon, icon_state = "lava")
						F.lava = 1
						lavaturfs += F

				spawn(0)
					for(var/i = 0, i < length, i++) // 180 = 3 minutes
						if(damage)
							for(var/mob/living/carbon/L in living_mob_list)
								if(istype(L.loc, /turf/simulated/floor)) // Are they on LAVA?!
									var/turf/simulated/floor/F = L.loc
									if(F.lava)
										var/safe = 0
										for(var/obj/structure/O in F.contents)
											if(O.level > 1 && !istype(O, /obj/structure/window)) // Something to stand on and it isn't under the floor!
												safe = 1
												break
										if(!safe)
											L.adjustFireLoss(damage)


						sleep(10)

					for(var/turf/simulated/floor/F in lavaturfs) // Reset everything.
						if(F.z == map.zMainStation)
							F.name = initial(F.name)
							F.desc = initial(F.desc)
							F.overlays.len = 0
							F.lava = 0
							F.update_icon()
					floorIsLava = 0
				return
			if("thebees")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BEE")
				var/answer = alert("What's this? A Space Station woefully underpopulated by bees?",,"Let's fix it!","On second thought, let's not.")
				if(answer=="Let's fix it!")
					message_admins("[key_name_admin(usr)] unleashed the bees onto the crew.", 1)
					to_chat(world, "<font size='10' color='red'><b>NOT THE BEES!</b></font>")
					world << sound('sound/effects/bees.ogg')
					for(var/mob/living/M in player_list)
						var/mob/living/simple_animal/bee/swarm/BEE = new(get_turf(M))
						BEE.target = M
						BEE.AttackTarget()

			if("virus")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","V")
				var/answer = alert("Do you want this to be a greater disease or a lesser one?","Pathogen Outbreak","Greater","Lesser","Custom")
				switch (answer)
					if ("Lesser")
						new /datum/event/viral_infection
						message_admins("[key_name_admin(usr)] has triggered a lesser virus outbreak.", 1)
					if ("Greater")
						new /datum/event/viral_outbreak
						message_admins("[key_name_admin(usr)] has triggered a greater virus outbreak.", 1)
					if ("Custom")
						var/list/existing_pathogen = list()
						for (var/pathogen in disease2_list)
							var/datum/disease2/disease/dis = disease2_list[pathogen]
							existing_pathogen["[dis.real_name()]"] = pathogen
						var/chosen_pathogen = input(usr, "Choose a pathogen", "Choose a pathogen") as null | anything in existing_pathogen
						if (chosen_pathogen)
							var/datum/disease2/disease/dis = disease2_list[existing_pathogen[chosen_pathogen]]
							spread_disease_among_crew(dis,"Custom Outbreak")
							message_admins("[key_name_admin(usr)] has triggered a custom virus outbreak.", 1)
							var/dis_level = clamp(round((dis.get_total_badness()+1)/2),1,8)
							spawn(rand(0,3000))
								biohazard_alert(dis_level)
			if("mass_equip_outfit")
				var/const/yes_choice = "Yeah!"
				var/const/no_choice = "Nah."
				var/const/cancel_choice = "Cancel"
				var/choice = input("Do you want to delete existing clothing instead of drop?") in list(yes_choice, no_choice, cancel_choice)
				if(choice == cancel_choice)
					return
				var/outfit_type = select_loadout()
				if(!outfit_type || !ispath(outfit_type))
					return
				var/delete_items = choice == yes_choice ? TRUE : FALSE
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","EQU")
				for(var/mob/living/carbon/human/H in player_list)
					var/datum/outfit/concrete_outfit = new outfit_type
					concrete_outfit.equip(H, TRUE, strip = delete_items, delete = delete_items)
				message_admins("[key_name_admin(usr)] has mass equipped a loadout of type [outfit_type] to everyone.")
			if("retardify")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","RET")
				for(var/mob/living/carbon/human/H in player_list)
					to_chat(H, "<span class='danger'>You suddenly feel stupid.</span>")
					H.setBrainLoss(60)
				message_admins("[key_name_admin(usr)] made everybody retarded")
			if("fakeguns")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","FG")
				for(var/obj/item/W in world)
					if(istype(W, /obj/item/clothing) || istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/weapon/disk) || istype(W, /obj/item/weapon/tank))
						continue
					W.icon = 'icons/obj/fakegun.dmi'
					W.item_state = "gun"
				message_admins("[key_name_admin(usr)] made every item look like a gun")
			if("experimentalguns")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","GUN")
				for(var/mob/living/carbon/C in player_list)
					var/list/turflist = list()
					for(var/turf/T in orange(src,1))
						turflist += T
					if(!turflist.len)
						turflist += get_turf(C)
					var/turf/U = pick(turflist)
					var/obj/structure/closet/crate/secure/weapon/experimental/E = new(U)
					to_chat(C, "<span class='danger'>A crate appears next to you. You think you can read \"[E.chosen_set]\" scribbled on it</span>")
					U.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',anim_plane = MOB_PLANE)
				message_admins("[key_name_admin(usr)] distributed experimental guns to the entire crew")
			if("create_artifact")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","CA")
				var/answer = alert("Are you sure you want to create a custom artifact?",,"Yes","No")

				if(answer == "Yes")
					//Either have them as all random, or have custom artifacts
					var/list/effects = typesof(/datum/artifact_effect)
					var/list/triggers = typesof(/datum/artifact_trigger)
					effects.Remove(/datum/artifact_effect)
					triggers.Remove(/datum/artifact_trigger)

					var/answer1 = alert("Just a primary, or primary and secondary effects?",,"Primary only","Primary and Secondary")
					var/answer2 = alert("Randomly generated triggers (safer), or manually picked (might break certain effects)?",,"Random","Manual")

					var/custom_primary_effect = input(usr, "Which primary effect would you like?", "Primary effect") as null|anything in effects
					var/custom_primary_trigger
					if(answer2 == "Manual")
						custom_primary_trigger = input(usr, "Which trigger would you like for the primary effect?", "Primary trigger") as null|anything in triggers

					var/custom_secondary_effect
					var/custom_secondary_trigger
					if(answer1 == "Primary and Secondary")
						custom_secondary_effect = input(usr, "Which secondary effect would you like?", "Secondary effect") as null|anything in effects
						if(answer2 == "Manual")
							custom_secondary_trigger = input(usr, "Which trigger would you like for the secondary effect?", "Secondary trigger") as null|anything in triggers

					var/obj/machinery/artifact/custom = new /obj/machinery/artifact(get_turf(usr), null, 0)
					custom.primary_effect = new custom_primary_effect(custom)
					custom.primary_effect.artifact_id = "[custom.artifact_id]a"
					if(answer2 == "Random")
						custom.primary_effect.GenerateTrigger()
					else
						custom.primary_effect.trigger = new custom_primary_trigger(custom.primary_effect)

					custom.investigation_log(I_ARTIFACT, "|| admin-spawned by [key_name_admin(usr)] with a primary effect [custom.primary_effect.artifact_id]: [custom.primary_effect] || range: [custom.primary_effect.effectrange] || charge time: [custom.primary_effect.chargelevelmax] || trigger: [custom.primary_effect.trigger].")

					if(custom_secondary_effect)
						custom.secondary_effect = new custom_secondary_effect(custom)
						custom.secondary_effect.artifact_id = "[custom.artifact_id]b"
						if(answer2 == "Random")
							custom.secondary_effect.GenerateTrigger()
						else
							custom.secondary_effect.trigger = new custom_secondary_trigger(custom.secondary_effect)
						custom.investigation_log(I_ARTIFACT, "|| admin-spawned by [key_name_admin(usr)] with a secondary effect [custom.secondary_effect.artifact_id]: [custom.secondary_effect] || range: [custom.secondary_effect.effectrange] || charge time: [custom.secondary_effect.chargelevelmax] || trigger: [custom.secondary_effect.trigger].")

					custom.generate_icon()

					message_admins("[key_name_admin(usr)] has created a custom artifact")
			if("naturify")
				var/choice = input("Are you sure you want to return the station to nature? This will irreversibly break most of the station!") in list("Yeah!", "Cancel")
				if(choice != "Cancel")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","NA")
					naturify_station()
					message_admins("[key_name_admin(usr)] turned the station into wilderness.")
			if("schoolgirl")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SG")
				for(var/obj/item/clothing/under/W in world)
					W.icon_state = "schoolgirl"
					W.item_state = "w_suit"
					W._color = "schoolgirl"
					if(ismob(W.loc))
						var/mob/M = W.loc
						M.update_inv_w_uniform()
				message_admins("[key_name_admin(usr)] activated Japanese Animes mode")
				world << sound('sound/AI/animes.ogg')
			if("eagles")//SCRAW
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","EgL")
				var/list/no_eagle_access = list(access_security,access_brig,access_armory,access_forensics_lockers,access_change_ids,
access_ai_upload,access_teleporter,access_heads,access_captain,access_all_personal_lockers,access_rd,access_cmo,
access_heads_vault,access_ce,access_hop,access_hos,access_RC_announce,access_keycard_auth,access_tcomsat,access_gateway,
access_sec_doors,access_salvage_captain,access_cent_ert,access_syndicate,access_trade)
				var/list/filter = get_all_accesses() - no_eagle_access
				for(var/obj/machinery/door/W in all_doors)
					if(!W.req_access)
						W.set_up_access()
					if(W.z == map.zMainStation)
						if(W.req_access && W.req_access.len)
							W.req_access = W.req_access - filter
						if(W.req_one_access && W.req_one_access.len)
							W.req_one_access = W.req_one_access - filter
				message_admins("[key_name_admin(usr)] activated Egalitarian Station mode")
				command_alert(/datum/command_alert/eagles)
			if("dorf")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","DF")
				for(var/mob/living/carbon/human/B in mob_list)
					B.my_appearance.f_style = "Dward Beard"
					B.update_hair()
				message_admins("[key_name_admin(usr)] activated dorf mode")
			if("ionstorm")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","I")
				generate_ion_law()
				message_admins("[key_name_admin(usr)] triggered an ion storm")
				var/show_log = alert(usr, "Show ion message?", "Message", "Yes", "No")
				if(show_log == "Yes")
					command_alert(/datum/command_alert/ion_storm)
			if("onlyone")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","OO")
				usr.client.only_one(usr)
//				message_admins("[key_name_admin(usr)] has triggered a battle to the death (only one)")
			if("togglenarsie")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","NA")
				var/choice = input("How do you wish for narsie to interact with her surroundings?") in list("CultStation13", "Nar-Singulo")
				if(choice == "CultStation13")
					message_admins("[key_name_admin(usr)] has set narsie's behaviour to \"CultStation13\".")
					narsie_behaviour = "CultStation13"
				if(choice == "Nar-Singulo")
					message_admins("[key_name_admin(usr)] has set narsie's behaviour to \"Nar-Singulo\".")
					narsie_behaviour = "Nar-Singulo"
			if("athfthrowing")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","TE")
				objects_thrown_when_explode = !objects_thrown_when_explode
				message_admins("[key_name_admin(usr)] has toggled items exploding when thrown [objects_thrown_when_explode ? "ON" : "OFF"].")
			if("hellonearth")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","NS")
				var/choice = input("You sure you want to end the round and summon narsie at your location? Misuse of this could result in removal of flags or hilarity.") in list("PRAISE SATAN", "Cancel")
				if(choice == "PRAISE SATAN")
					new /obj/machinery/singularity/narsie/large(get_turf(usr))
					message_admins("[key_name_admin(usr)] has summoned narsie and brought about a new realm of suffering.")
			if("supermattercascade")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SC")
				var/choice = input("You sure you want to destroy the universe and create a large explosion at your location? Misuse of this could result in removal of flags or hilarity.") in list("NO TIME TO EXPLAIN", "Cancel")
				if(choice == "NO TIME TO EXPLAIN")
					explosion(get_turf(usr), 8, 16, 24, 32, 1, whodunnit = usr)
					new /turf/unsimulated/wall/supermatter(get_turf(usr))
					SetUniversalState(/datum/universal_state/supermatter_cascade)
					message_admins("[key_name_admin(usr)] has managed to destroy the universe with a supermatter cascade. Good job, [key_name_admin(usr)]")
			if("meteorstorm")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","MS")
				var/choice = input("Are you sure you want to summon an unending hail of meteors and force station evacuation? This will only work properly if the shuttle is not in use. Misuse of this could result in removal of flags or hilarity.") in list("BRING ME MY FRIDGE", "Cancel")
				if(choice == "BRING ME MY FRIDGE")
					SetUniversalState(/datum/universal_state/meteor_storm, 1, 1)
					message_admins("[key_name_admin(usr)] has summoned an unending meteor storm upon the station. Go ahead and ask him for the details, don't forget to scream at him.")
			if("halloween")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","HW")
				var/choice = input("Are you sure you want to wake up the space indian burial ground?. Misuse of this could result in removal of flags or hilarity.") in list("Get our spook on", "Cancel")
				if(choice != "Cancel")
					var/list/given_args = list()
					var/number = input("How many mobs do you want per area?", 10) as num
					if(number)
						given_args["mobs"] = number
					SetUniversalState(/datum/universal_state/halloween, 1, 1, given_args)
					message_admins("[key_name_admin(usr)] has pressed the halloween fun button with [number] amount of mobs per area. Truly [key_name_admin(usr)] is the spookiest.")
			if("christmas_vic")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","XMS")
				var/choice = input("Are you sure you want to do time-related shenanigans and send the station back to the victorian era?") in list("What's the worst that could happen?", "Cancel")
				if(choice != "Cancel")
					SetUniversalState(/datum/universal_state/auldlangsyne, 1, 1)
					message_admins("[key_name_admin(usr)] has pressed the \"Other\" Christmas button. Go ahead and ask him why the station's got wood.")
			if("mobswarm")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","MS")
				var/choice = input("Are you sure you want to fill the station with a bunch of unnecessary mobs?") in list("Of course!", "No, I hate timespace anomalies involving fun")
				if(choice == "Of course!")
					var/amt = input("How many would you like to spawn?", 10) as num
					var/mobtype = input("What mob would you like?", "Mob Swarm") as null|anything in typesof(/mob/living)
					message_admins("[key_name_admin(usr)] triggered a mob swarm.")
					new /datum/event/mob_swarm(mobtype, amt)
			if("pick_event")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","ALL")
				var/choice = input("Which event do you want to trigger?") in subtypesof(/datum/event)+"Cancel"
				if(choice != "Cancel")
					new choice
					message_admins("[key_name_admin(usr)] spawned a custom event of type [choice].")
			if("roll_event")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","RE")
				spawn_dynamic_event(TRUE)
				message_admins("[key_name_admin(usr)] spawned random dynamic event.")
			if("spawnadminbus")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","AB")
				var/obj/structure/bed/chair/vehicle/adminbus/A = new /obj/structure/bed/chair/vehicle/adminbus(get_turf(usr))
				A.dir = EAST
				A.update_lightsource()
				A.busjuke.dir = EAST
				message_admins("[key_name_admin(usr)] has spawned an Adminbus. Who gave him the keys?")
				log_admin("[key_name_admin(usr)] has spawned an Adminbus.")
			if("spawnselfdummy")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","TD")
				var/newname = ""
				newname = copytext(sanitize(input("Before you step out as an embodied god, what name do you wish for?", "Choose your name.", "Admin") as null|text),1,MAX_NAME_LEN)
				if (!newname)
					newname = "Admin"
				var/turf/T = get_turf(usr)
				var/mob/living/carbon/human/dummy/D = new /mob/living/carbon/human/dummy(T)
				var/obj/item/weapon/card/id/admin/admin_id = new(D)
				admin_id.registered_name = newname
				D.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(D), slot_w_uniform)
				D.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(D), slot_shoes)
				D.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(D), slot_ears)
				D.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(D), slot_back)
				D.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival/engineer(D.back), slot_in_backpack)
				D.equip_to_slot_or_del(admin_id, slot_wear_id)
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/misc/adminspawn.ogg',anim_plane = MOB_PLANE)
				D.name = newname
				D.real_name = newname
				message_admins("[key_name_admin(usr)] spawned themself as a Test Dummy.")
				log_admin("[key_name_admin(usr)] spawned themself as a Test Dummy.")
				usr.client.cmd_assume_direct_control(D)
			if("spawnselfdummyoutfit")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","TDO")
				var/newname = ""
				newname = copytext(sanitize(input("Before you step out as an embodied god, what name do you wish for?", "Choose your name.", "Admin") as null|text),1,MAX_NAME_LEN)
				if (!newname)
					newname = "Admin"
				var/choice = alert("Edit appearance on spawn?", "Admin", "Yes", "No")
				var/outfit_type = select_loadout()
				if(!outfit_type || !ispath(outfit_type))
					return
				var/turf/T = get_turf(usr)
				var/mob/living/carbon/human/dummy/D = new /mob/living/carbon/human/dummy(T)
				var/obj/item/weapon/card/id/admin/admin_id = new(D)
				admin_id.registered_name = newname
				var/datum/outfit/concrete_outfit = new outfit_type
				concrete_outfit.equip(D, TRUE)
				var/obj/item/I = D.get_item_by_slot(slot_wear_id)
				qdel(I)
				var/obj/item/IT = D.get_item_by_slot(slot_ears)
				qdel(IT)
				D.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(D), slot_ears)
				D.equip_to_slot_or_del(admin_id, slot_wear_id)
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-WORLD_ICON_SIZE,0,MOB_LAYER+1,'sound/misc/adminspawn.ogg',anim_plane = MOB_PLANE)
				D.name = newname
				D.real_name = newname
				if(choice == "Yes")
					D.pick_gender(usr)
					D.pick_appearance(usr)
				message_admins("[key_name_admin(usr)] spawned themself as a Test Dummy wearing \a [concrete_outfit.outfit_name] outfit.")
				log_admin("[key_name_admin(usr)] spawned themself as a Test Dummy wearing \a [concrete_outfit.outfit_name] outfit.")
				usr.client.cmd_assume_direct_control(D)

			//False flags and bait below. May cause mild hilarity or extreme pain. Now in one button
			if("fakealerts")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","FAKEA")
				var/choice = input("Choose the type of fake alert you wish to trigger","False Flag and Bait Panel") as null|anything in list("Biohazard", "Lifesigns", "Malfunction", "Ion", "Meteor Wave", "Carp Migration", "Revs")
				//Big fat lists of effects, not very modular but at least there's less buttons
				switch (choice)
					if("Biohazard") //GUISE WE HAVE A BLOB
						var/levelchoice = input("Set the level of the biohazard alert (1 to 7 supported only)", "Space FEMA Readiness Program", 1) as num
						if(isnull(levelchoice) || levelchoice > 7 || levelchoice < 1)
							to_chat(usr, "<span class='warning'>Invalid input range (1 to 7 only)</span>")
							return
						var/datum/command_alert/biohazard_alert/admin_alert = new
						admin_alert.level_min = levelchoice
						admin_alert.level_max = levelchoice
						command_alert(admin_alert)
						message_admins("[key_name_admin(usr)] triggered a FAKE Biohzard Alert.")
						log_admin("[key_name_admin(usr)] triggered a FAKE Biohzard Alert.")
						return
					if("Lifesigns") //MUH ALIUMS
						command_alert(/datum/command_alert/xenomorphs)
						message_admins("[key_name_admin(usr)] triggered a FAKE Lifesign Alert.")
						log_admin("[key_name_admin(usr)] triggered a FAKE Lifesign Alert.")
						return
					if("Malfunction") //BLOW EVERYTHING
						var/salertchoice = input("Do you wish to include the Hostile Runtimes warning to have an authentic Malfunction Takeover Alert?", "Nanotrasen Alert Level Monitor") in list("Yes", "No")
						if(salertchoice == "Yes")
							command_alert(/datum/command_alert/malf_announce)
						to_chat(world, "<font size=4 color='red'>Attention! Delta security level reached!</font>")//Don't ACTUALLY set station alert to Delta to avoid fucking shit up for real

						to_chat(world, "<span class='red'>[config.alert_desc_delta]</span>")

						message_admins("[key_name_admin(usr)] triggered a FAKE Malfunction Takeover Alert (Hostile Runtimes alert [salertchoice == "Yes" ? "included":"excluded"])")
						log_admin("[key_name_admin(usr)] triggered a FAKE Malfunction Takeover Alert (Hostile Runtimes alert [salertchoice == "Yes" ? "included":"excluded"])")
						return
					if("Ion")
						command_alert(/datum/command_alert/ion_storm)
						message_admins("[key_name_admin(usr)] triggered a FAKE Ion Alert.")
						log_admin("[key_name_admin(usr)] triggered a FAKE Ion Alert.")
						return
					if("Meteor Wave")
						command_alert(/datum/command_alert/meteor_wave)
						message_admins("[key_name_admin(usr)] triggered a FAKE Meteor Alert.")
						log_admin("[key_name_admin(usr)] triggered a FAKE Meteor Alert.")
						return
					if("Carp Migration")
						command_alert(/datum/command_alert/carp)
						message_admins("[key_name_admin(usr)] triggered a FAKE Carp Migration Alert.")
						log_admin("[key_name_admin(usr)] triggered a FAKE Carp Migration Alert.")
						return
					if("Revs")
						command_alert(/datum/command_alert/revolution)
						message_admins("[key_name_admin(usr)] triggered a FAKE revolution alert.")
						log_admin("[key_name_admin(usr)] triggered a FAKE revolution alert.")
						return

			if("fakebooms") //Michael Bay is in the house !
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","FAKEE")
				var/amount = input("How many fake explosions do you want?", "Fake Explosions", 1) as num
				if(amount < 1) //No negative or null explosion amounts here math genius
					to_chat(usr, "<span class='warning'>Invalid input range (null or negative)</span>")
					return
				var/realeffect = alert(usr,"Use visible explosions?", "Fake Explosions", "Yes", "No") == "Yes"
				message_admins("[key_name_admin(usr)] triggered [round(amount)] fake explosions.")
				log_admin("[key_name_admin(usr)] triggered [round(amount)] fake explosions.")
				for(var/i = 1 to amount)
					if(realeffect)
						var/turf/epicenter = locate(rand(1,world.maxx),rand(1,world.maxy),map.zMainStation)
						explosion_effect(epicenter,7,14,28)
					else
						world << sound('sound/effects/explosionfar.ogg')
					sleep(rand(2, 10)) //Sleep 0.2 to 1 second
			if("fakenews")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","FAKEN")
				var/type
				var/datum/feed_message/news/newspost
				var/dest
				var/datum/trade_destination/newsdest
				if(alert(usr,"Generate news specifically from a location or not?","Location","Yes","No") == "Yes")
					dest = input("Where will it happen?") in subtypesof(/datum/trade_destination)
					newsdest = new dest()
					var/list/typelist = newsdest.viable_mundane_events.len || newsdest.viable_random_events.len ? newsdest.viable_mundane_events + newsdest.viable_random_events : subtypesof(/datum/feed_message/news)
					type = input("Select a news message to broadcast!") in typelist
					newspost = new type(newsdest)
				else
					type = input("Select a news message to broadcast!") in subtypesof(/datum/feed_message/news)
					dest = input("Where will it happen, if applicable?") in subtypesof(/datum/trade_destination)
					newsdest = new dest()
					newspost = new type(newsdest)
				if(newsdest.get_custom_eventstring(type))
					newspost.body = newsdest.get_custom_eventstring(type)
				announce_newscaster_news(newspost)
			if("togglerunescapepvp")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","RSPVP")
				runescape_pvp = !runescape_pvp
				if(runescape_pvp)
					message_admins("[key_name_admin(usr)] has enabled Maint-Only PvP.")
					log_admin("[key_name_admin(usr)] has enabled Maint-Only PvP.")
					for (var/mob/player in player_list)
						to_chat(player, "<span class='userdanger'>WARNING: Wilderness mode is now enabled; players can only harm one another in maintenance areas!</span>")
				else
					message_admins("[key_name_admin(usr)] has disabled  Maint-Only PvP.")
					log_admin("[key_name_admin(usr)] has disabled Maint-Only PvP.")
					for (var/mob/player in player_list)
						to_chat(player, "<span class='userdanger'>WARNING: Wilderness mode is now disabled; players can only harm one another anywhere!</span>")
			if("togglerunescapeskull")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","RSSKL")
				runescape_skull_display = !runescape_skull_display
				if(runescape_skull_display)
					message_admins("[key_name_admin(usr)] has enabled Skull icons appearing over aggressors.")
					log_admin("[key_name_admin(usr)] has enabled Skull icon appearing over aggressors.")
				else
					message_admins("[key_name_admin(usr)] has disabled Skull icon appearing over aggressors.")
					log_admin("[key_name_admin(usr)] has disabled Skull icon appearing over aggressors.")
					if (ticker)
						for (var/entry in ticker.runescape_skulls)
							var/datum/runescape_skull_data/the_data = ticker.runescape_skulls[entry]
							ticker.runescape_skulls -= entry
							qdel(the_data)
			if("massbomber")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BBM")
				var/choice = alert("Dress every player like Bomberman and give them BBDs?","Bomberman Mode Activation","Confirm","Cancel")
				if(choice=="Confirm")
					bomberman_mode = 1
					world << sound('sound/bomberman/start.ogg')
					for(var/mob/living/carbon/human/M in player_list)
						if(M.wear_suit)
							var/obj/item/O = M.wear_suit
							M.u_equip(O,1)
							O.forceMove(M.loc)
							//O.dropped(M)
						if(M.head)
							var/obj/item/O = M.head
							M.u_equip(O,1)
							O.forceMove(M.loc)
							//O.dropped(M)
						M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/bomberman(M), slot_head)
						M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/bomberman(M), slot_wear_suit)
						M.equip_to_slot_or_del(new /obj/item/weapon/bomberman/(M), slot_s_store)
						M.update_icons()
						M.mind.special_role = BOMBERMAN // CHEAT CHECKS
						to_chat(M, "Wait...what?")
						spawn(50)
							to_chat(M, "<span class='notice'>Tip: Use the BBD in your suit's pocket to place bombs.</span>")
							to_chat(M, "<span class='notice'>Try to keep your BBD and escape this hell hole alive!</span>")

				message_admins("[key_name_admin(usr)] turned everyone into Bomberman!")
				log_admin("[key_name_admin(usr)] turned everyone into Bomberman!")
			if("bomberhurt")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BBH")
				var/choice = alert("Activate Cuban Pete mode? Note that newly spawned BBD will still have player damage deactivated.","Activating Bomberman Bombs Player Damage","Confirm","Cancel")
				if(choice=="Confirm")
					bomberman_hurt = 1
					for(var/obj/item/weapon/bomberman/B in bombermangear)
						if(!B.arena)
							B.hurt_players = 1
				message_admins("[key_name_admin(usr)] enabled the player damage of the Bomberman Bomb Dispensers currently in the world. Cuban Pete approves.")
				log_admin("[key_name_admin(usr)] enabled the player damage of the Bomberman Bomb Dispensers currently in the world. Cuban Pete approves.")
			if("bomberdestroy")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BBD")
				var/choice = alert("Activate Michael Bay mode? Note that newly spawned BBD will still have environnement damage deactivated.","Activating Bomberman Bombs Environnement Damage","Confirm","Cancel")
				if(choice=="Confirm")
					bomberman_destroy = 1
					for(var/obj/item/weapon/bomberman/B in bombermangear)
						if(!B.arena)
							B.destroy_environnement = 1
				message_admins("[key_name_admin(usr)] enabled the environnement damage of the Bomberman Bomb Dispensers currently in the world. Michael Bay approves.")
				log_admin("[key_name_admin(usr)] enabled the environnement damage of the Bomberman Bomb Dispensers currently in the world. Michael Bay approves.")
			if("bombernohurt")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BBNH")
				var/choice = alert("Disable Cuban Pete mode.","Disable Bomberman Bombs Player Damage","Confirm","Cancel")
				if(choice=="Confirm")
					bomberman_hurt = 0
					for(var/obj/item/weapon/bomberman/B in bombermangear)
						if(!B.arena)
							B.hurt_players = 0
				message_admins("[key_name_admin(usr)] disabled the player damage of the Bomberman Bomb Dispensers currently in the world.")
				log_admin("[key_name_admin(usr)] disabled the player damage of the Bomberman Bomb Dispensers currently in the world.")
			if("bombernodestroy")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BBND")
				var/choice = alert("Disable Michael Bay mode?","Disable Bomberman Bombs Environnement Damage","Confirm","Cancel")
				if(choice=="Confirm")
					bomberman_destroy = 0
					for(var/obj/item/weapon/bomberman/B in bombermangear)
						if(!B.arena)
							B.destroy_environnement = 0
				message_admins("[key_name_admin(usr)] disabled the environnement damage of the Bomberman Bomb Dispensers currently in the world.")
				log_admin("[key_name_admin(usr)] disabled the environnement damage of the Bomberman Bomb Dispensers currently in the world.")
			if("mechanics_motivator")
				if(!world.has_round_started())
					to_chat(usr, "The round has not started yet,")
					return
				var/equipped_count = 0
				for(var/mob/living/dude in player_list)
					if(dude.mind?.assigned_role != "Mechanic")
						continue
					var/obj/item/current_mask = dude.get_item_by_slot(slot_wear_mask)
					if(current_mask)
						if(istype(current_mask, /obj/item/clothing/mask/explosive_collar/mechanic))
							continue
						dude.drop_item(current_mask, dude.loc, TRUE)
					var/obj/item/clothing/mask/explosive_collar/mechanic/cool_necklace = new
					dude.equip_to_slot(cool_necklace, slot_wear_mask)
					equipped_count++
				to_chat(usr, "<span class='notice'>Equipped [equipped_count] mechanics with cool necklaces.</span>")
				log_admin("[key_name(usr)] equipped [equipped_count] Mechanics with cool necklaces.")
			if("placeturret")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","TUR")
				var/list/possible_guns = list()
				for(var/path in typesof(/obj/item/weapon/gun/energy))
					possible_guns += path
				var/choice = input("What energy gun do you want inside the turret?") in possible_guns
				if(!choice)
					return
				var/obj/item/weapon/gun/energy/gun = new choice()
				var/obj/machinery/turret/portable/Turret = new(get_turf(usr))
				Turret.installed = gun
				gun.forceMove(Turret)
				Turret.update_gun()
				var/emag = input("Emag the turret?") in list("No", "Yes")
				if(emag=="Yes")
					Turret.emag_act(usr)
			if("virusdish")
				virus2_make_custom(usr.client,null)
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","VIR")
			if("bloodstone")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BS")
				var/choice = alert("Flashy spawn and surroundings cultification?","Blood Stone Spawning","Yes","No")
				if (!choice)
					return
				var/turf/T = get_turf(usr)
				var/obj/structure/cult/bloodstone/admin/blood_stone = new(T)
				if(choice == "Yes")
					blood_stone.flashy_entrance()
				if(choice == "No")
					blood_stone.ready = TRUE
					blood_stone.overlays_pre()
					blood_stone.set_animate()
				message_admins("[key_name_admin(usr)] spawned a blood stone at [formatJumpTo(get_turf(usr))].")


			if("hardcore_mode")
				var/choice = input("Are you sure you want to [ticker.hardcore_mode ? "disable" : "enable"] hardcore mode? Starvation will [ticker.hardcore_mode ? "no longer":""]slowly kill player-controlled humans.", "Admin Abuse") in list("Yes", "No!")

				if(choice == "Yes")
					if(!hardcore_mode_on)
						log_admin("[key_name(usr)] has ENABLED hardcore mode!")
						hardcore_mode = 1
						to_chat(world, "<h5><span class='danger'>Hardcore mode has been enabled</span></h5>")
						to_chat(world, "<span class='info'>Not eating for a prolonged period of time will slowly kill player-controlled characters (braindead and catatonic characters are not affected).</span>")
						to_chat(world, "<span class='info'>If your hunger indicator starts flashing red and black, your character is starving and may die soon!</span>")
					else
						log_admin("[key_name(usr)] has DISABLED hardcore mode!")
						hardcore_mode = 0
						to_chat(world, "<h5><span class='danger'>Hardcore mode has been disabled</span></h5>")
						to_chat(world, "<span class='info'>Starvation will no longer kill player-controlled characters.</span>")

			if("buddha_mode_everyone")
				if(!buddha_mode_everyone)
					if(alert("This will prevent every carbon mob from ever entering crit / dying. Are you sure?", "Warning", "Yes", "Cancel") == "Cancel")
						return
					buddha_mode_everyone = !buddha_mode_everyone
					log_admin("[key_name(usr)] has ENABLED buddha mode for everyone!")
					message_admins("[key_name(usr)] has ENABLED buddha mode for everyone!")
					for(var/mob/living/carbon/human/H in mob_list)
						if(H.mind || H.client)
							if(!(H.status_flags & BUDDHAMODE))
								H.status_flags ^= BUDDHAMODE
								if(H.client)
									to_chat(H, "<span class='notice'>An incredible sense of tranquility overtakes you. You have let go of your worldly desires.</span>")
				else
					if(alert("This will disable buddha mode for everyone. Are you sure?", "Warning", "Yes", "Cancel") == "Cancel")
						return
					buddha_mode_everyone = !buddha_mode_everyone
					log_admin("[key_name(usr)] has DISABLED buddha mode for everyone!")
					message_admins("[key_name(usr)] has DISABLED buddha mode for everyone!")
					for(var/mob/living/carbon/human/H in mob_list)
						if((H.mind || H.client) || (H.attack_log.len)) //attack_log included in case someone got beheaded and the mob lost its client/mind (to unset the flag for corpses, basically)
							if(H.status_flags & BUDDHAMODE)
								H.status_flags ^= BUDDHAMODE
								if(H.client)
									to_chat(H, "<span class='warning'>The tranquility that once filled your soul has vanished. You are once again a slave to your worldly desires.</span>")

			if("spawn_custom_turret")
				if(alert("Are you sure you'd like to spawn a custom turret at your location?", "Confirmation", "Yes", "Cancel") == "Cancel")
					return
				new /obj/structure/turret/gun_turret/admin(get_turf(usr))
				log_admin("[key_name(usr)] has spawned a customizable turret at [get_coordinates_string(usr)].")
				message_admins("[key_name(usr)] has spawned a customizable turret at [get_coordinates_string(usr)].")

			if("spawn_meat_blob")
				var/datum/meat_blob/new_blob = new()
				new_blob.instantiate(get_turf(usr))
				log_admin("[key_name(usr)] has spawned a meat blob at [get_coordinates_string(usr)].")
				message_admins("[key_name(usr)] has spawned a meat blob at [get_coordinates_string(usr)].")

			if("vermin_infestation")
				var/list/locations = list(
					"RANDOM" = null,
					"kitchen" = LOC_KITCHEN,
					"atmospherics" = LOC_ATMOS,
					"incinerator" = LOC_INCIN,
					"chapel" = LOC_CHAPEL,
					"library" = LOC_LIBRARY,
					"hydroponics" = LOC_HYDRO,
					"vault" = LOC_VAULT,
					"technical storage" = LOC_TECH,
					)
				var/list/vermins = list(
					"RANDOM" = null,
					"mice" = VERM_MICE,
					"lizards" = VERM_LIZARDS,
					"spiders" = VERM_SPIDERS,
					"slimes" = VERM_SLIMES,
					"bats" = VERM_BATS,
					"borers" = VERM_BORERS,
					"mimics" = VERM_MIMICS,
					"roaches" = VERM_ROACHES,
					"gremlins" = VERM_GREMLINS,
					"bees" = VERM_BEES,
					"hornets" = VERM_HORNETS,
					"syphoners" = VERM_SYPHONER,
					"greytide gremlins" = VERM_GREMTIDE,
					"crabs" = VERM_CRABS,
					"diona nymphs" = VERM_DIONA,
					"mushman pinheads" = VERM_MUSHMEN,
					"frogs" = VERM_FROGS,
					"snails" = VERM_SNAILS
					)
				var/ov = vermins[input("What vermin should infest the station?", "Vermin Infestation") in vermins]
				var/ol = locations[input("Where should they spawn?", "Vermin Infestation") in locations]
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","VI")
				message_admins("[key_name_admin(usr)] has triggered an infestation of vermins.", 1)
				var/datum/event/infestation/infestation_event = new()
				infestation_event.override_location = ol
				infestation_event.override_vermin = ov
			if("hostile_infestation")
				var/list/locations = list(
					"RANDOM" = null,
					"kitchen" = LOC_KITCHEN,
					"atmospherics" = LOC_ATMOS,
					"incinerator" = LOC_INCIN,
					"chapel" = LOC_CHAPEL,
					"library" = LOC_LIBRARY,
					"hydroponics" = LOC_HYDRO,
					"vault" = LOC_VAULT,
					"technical storage" = LOC_TECH,
					)
				var/list/hostiles = list(
					"RANDOM" = null,
					"space bears" = MONSTER_BEAR,
					"creatures" = MONSTER_CREATURE,
					"xenos" = MONSTER_XENO,
					"hivebots" = MONSTER_HIVEBOT,
					"zombies" = MONSTER_ZOMBIE,
					"skrites" = MONSTER_SKRITE,
					"xeno empress" = MONSTER_SQUEEN,
					"frogs" = MONSTER_FROG,
					"goliaths" = MONSTER_GOLIATH,
					"davids" = MONSTER_DAVID,
					"megamadcrabs" = MONSTER_MADCRAB,
					"spaghetti monster" = MONSTER_MEATBALLER,
					"mutated cockroaches" = MONSTER_BIG_ROACH,
					"cockroach queen" = MONSTER_ROACH_QUEEN,
					)
				var/om = hostiles[input("What hostile mob should infest the station?", "Hostile Infestation") in hostiles]
				var/ol = locations[input("Where should they spawn?", "Hostile Infestation") in locations]
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","HI")
				message_admins("[key_name_admin(usr)] has triggered an infestation of hostile creatures.", 1)
				var/datum/event/hostile_infestation/hostile_infestation_event = new()
				hostile_infestation_event.override_location = ol
				hostile_infestation_event.override_monster = om

			if("maint_access_brig")
				for(var/obj/machinery/door/airlock/maintenance/M in all_doors)
					if (access_maint_tunnels in M.req_access)
						M.req_access = list(access_brig)
				message_admins("[key_name_admin(usr)] made all maint doors brig access-only.")
			if("maint_access_engiebrig")
				for(var/obj/machinery/door/airlock/maintenance/M in all_doors)
					if (access_maint_tunnels in M.req_access)
						M.req_access = list()
						M.req_one_access = list(access_brig,access_engine_major)
				message_admins("[key_name_admin(usr)] made all maint doors engineering and brig access-only.")
			if("infinite_sec")
				var/datum/job/J = job_master.GetJob("Security Officer")
				if(!J)
					return
				J.set_total_positions(99)
				J.spawn_positions = -1
				message_admins("[key_name_admin(usr)] has removed the cap on security officers.")
		if(usr)
			log_admin("[key_name(usr)] used secret [href_list["secretsfun"]]")

	if(href_list["secretsadmin"])
		if(!check_rights(R_ADMIN))
			return

		switch(href_list["secretsadmin"])
			if("clear_bombs")
				var/num=0
				for(var/obj/item/device/transfer_valve/TV in world)
					if(TV.tank_one||TV.tank_two)
						qdel(TV)
						num++
				message_admins("[key_name_admin(usr)] has removed [num] bombs", 1)
			if("detonate_bombs")
				var/num=0
				for(var/obj/item/device/transfer_valve/TV in world)
					if(TV.tank_one||TV.tank_two)
						TV.toggle_valve()
				message_admins("[key_name_admin(usr)] has toggled valves on [num] bombs", 1)

			if("list_bombers")
				var/dat = "<B>Bombing List<HR>"
				for(var/l in bombers)
					dat += text("[l]<BR>")
				usr << browse(dat, "window=bombers")
			if("list_lawchanges")
				var/dat = "<B>Showing last [length(lawchanges)] law changes.</B><HR>"
				for(var/sig in lawchanges)
					dat += "[sig]<BR>"
				usr << browse(dat, "window=lawchanges;size=800x500")
			if("list_job_debug")
				var/dat = "<B>Job Debug info.</B><HR>"
				if(job_master)
					for(var/line in job_master.job_debug)
						dat += "[line]<BR>"
					dat+= "*******<BR><BR>"
					for(var/datum/job/job in job_master.occupations)
						if(!job)
							continue
						dat += "job: [job.title], current_positions: [job.current_positions], total_positions: [job.get_total_positions()] <BR>"
					usr << browse(dat, "window=jobdebug;size=600x500")
			if("showailaws")
				output_ai_laws()
			if("showgm")
				if(!ticker)
					alert("The game hasn't started yet!")
				else if (ticker.mode)
					alert("The game mode is [ticker.mode.name]")
				else
					alert("For some reason there's a ticker, but not a game mode")
			if("manifest")
				var/dat = "<B>Showing Crew Manifest.</B><HR>"
				dat += "<table cellspacing=5><tr><th>Name</th><th>Position</th></tr>"
				for(var/mob/living/carbon/human/H in mob_list)
					if(H.ckey)
						dat += text("<tr><td>[]</td><td>[]</td></tr>", H.name, H.get_assignment())
				dat += "</table>"
				usr << browse(dat, "window=manifest;size=440x410")
			// if("check_antagonist")
			// 	check_antagonists()
			if("emergency_shuttle_panel")
				emergency_shuttle_panel()
			if("DNA")
				var/dat = "<B>Showing DNA from blood.</B><HR>"
				dat += "<table cellspacing=5><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
				for(var/mob/living/carbon/human/H in mob_list)
					if(H.dna && H.ckey)
						dat += "<tr><td>[H]</td><td>[H.dna.unique_enzymes]</td><td>[H.dna.b_type]</td></tr>"
				dat += "</table>"
				usr << browse(dat, "window=DNA;size=440x410")
			if("fingerprints")
				var/dat = "<B>Showing Fingerprints.</B><HR>"
				dat += "<table cellspacing=5><tr><th>Name</th><th>Fingerprints</th></tr>"
				for(var/mob/living/carbon/human/H in mob_list)
					if(H.ckey)
						if(H.dna && H.dna.uni_identity)
							dat += "<tr><td>[H]</td><td>[md5(H.dna.uni_identity)]</td></tr>"
						else if(H.dna && !H.dna.uni_identity)
							dat += "<tr><td>[H]</td><td>H.dna.uni_identity = null</td></tr>"
						else if(!H.dna)
							dat += "<tr><td>[H]</td><td>H.dna = null</td></tr>"
				dat += "</table>"
				usr << browse(dat, "window=fingerprints;size=440x410")
			if("show_admin_log")
				var/dat = "<B>Admin Log<HR></B>"
				for(var/l in admin_log)
					dat += "<li>[l]</li>"
				if(!admin_log.len)
					dat += "No-one has done anything this round!"
				usr << browse(dat, "window=admin_log")

		if (usr)
			log_admin("[key_name(usr)] used secret [href_list["secretsadmin"]]")

	else if(href_list["ac_view_wanted"])            //Admin newscaster Topic() stuff be here
		src.admincaster_screen = 18                 //The ac_ prefix before the hrefs stands for AdminCaster.
		src.access_news_network()

	else if(href_list["ac_set_channel_name"])
		src.admincaster_feed_channel.channel_name = stripped_input(usr, "Provide a Feed Channel Name", "Network Channel Handler", "")
		while (findtext(src.admincaster_feed_channel.channel_name," ") == 1)
			src.admincaster_feed_channel.channel_name = copytext(src.admincaster_feed_channel.channel_name,2,length(src.admincaster_feed_channel.channel_name)+1)
		src.access_news_network()

	else if(href_list["ac_set_channel_lock"])
		src.admincaster_feed_channel.locked = !src.admincaster_feed_channel.locked
		src.access_news_network()

	else if(href_list["ac_submit_new_channel"])
		var/check = 0
		for(var/datum/feed_channel/FC in news_network.network_channels)
			if(FC.channel_name == src.admincaster_feed_channel.channel_name)
				check = 1
				break
		if(src.admincaster_feed_channel.channel_name == "" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]" || check )
			src.admincaster_screen=7
		else
			var/choice = alert("Please confirm Feed channel creation","Network Channel Handler","Confirm","Cancel")
			if(choice=="Confirm")
				var/datum/feed_channel/newChannel = new /datum/feed_channel
				newChannel.channel_name = src.admincaster_feed_channel.channel_name
				newChannel.author = src.admincaster_signature
				newChannel.locked = src.admincaster_feed_channel.locked
				newChannel.is_admin_channel = 1
				feedback_inc("newscaster_channels",1)
				news_network.network_channels += newChannel                        //Adding channel to the global network
				log_admin("[key_name_admin(usr)] created command feed channel: [src.admincaster_feed_channel.channel_name]!")
				src.admincaster_screen=5
		src.access_news_network()

	else if(href_list["ac_set_channel_receiving"])
		var/list/available_channels = list()
		for(var/datum/feed_channel/F in news_network.network_channels)
			available_channels += F.channel_name
		src.admincaster_feed_channel.channel_name = adminscrub(input(usr, "Choose receiving Feed Channel", "Network Channel Handler") in available_channels )
		src.access_news_network()

	else if(href_list["ac_set_new_message"])
		src.admincaster_feed_message.body = adminscrub(input(usr, "Write your Feed story", "Network Channel Handler", ""))
		while (findtext(src.admincaster_feed_message.body," ") == 1)
			src.admincaster_feed_message.body = copytext(src.admincaster_feed_message.body,2,length(src.admincaster_feed_message.body)+1)
		src.access_news_network()

	else if(href_list["ac_submit_new_message"])
		if(src.admincaster_feed_message.body =="" || src.admincaster_feed_message.body =="\[REDACTED\]" || src.admincaster_feed_channel.channel_name == "" )
			src.admincaster_screen = 6
		else
			var/datum/feed_message/newMsg = new /datum/feed_message
			newMsg.author = src.admincaster_signature
			newMsg.body = src.admincaster_feed_message.body
			newMsg.is_admin_message = 1
			feedback_inc("newscaster_stories",1)
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == src.admincaster_feed_channel.channel_name)
					FC.messages += newMsg                  //Adding message to the network's appropriate feed_channel
					break
			src.admincaster_screen=4

		for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
			NEWSCASTER.newsAlert(src.admincaster_feed_channel.channel_name)

		for(var/obj/item/device/pda/PDA in PDAs)
			var/datum/pda_app/newsreader/reader = locate(/datum/pda_app/newsreader) in PDA.applications
			if(reader)
				reader.newsAlert(src.admincaster_feed_channel.channel_name)

		log_admin("[key_name_admin(usr)] submitted a feed story to channel: [src.admincaster_feed_channel.channel_name]!")
		src.access_news_network()

	else if(href_list["ac_create_channel"])
		src.admincaster_screen=2
		src.access_news_network()

	else if(href_list["ac_create_feed_story"])
		src.admincaster_screen=3
		src.access_news_network()

	else if(href_list["ac_menu_censor_story"])
		src.admincaster_screen=10
		src.access_news_network()

	else if(href_list["ac_menu_censor_channel"])
		src.admincaster_screen=11
		src.access_news_network()

	else if(href_list["ac_menu_wanted"])
		var/already_wanted = 0
		if(news_network.wanted_issue)
			already_wanted = 1

		if(already_wanted)
			src.admincaster_feed_message.author = news_network.wanted_issue.author
			src.admincaster_feed_message.body = news_network.wanted_issue.body
		src.admincaster_screen = 14
		src.access_news_network()

	else if(href_list["ac_set_wanted_name"])
		src.admincaster_feed_message.author = adminscrub(input(usr, "Provide the name of the Wanted person", "Network Security Handler", ""))
		while (findtext(src.admincaster_feed_message.author," ") == 1)
			src.admincaster_feed_message.author = copytext(admincaster_feed_message.author,2,length(admincaster_feed_message.author)+1)
		src.access_news_network()

	else if(href_list["ac_set_wanted_desc"])
		src.admincaster_feed_message.body = adminscrub(input(usr, "Provide the a description of the Wanted person and any other details you deem important", "Network Security Handler", ""))
		while (findtext(src.admincaster_feed_message.body," ") == 1)
			src.admincaster_feed_message.body = copytext(src.admincaster_feed_message.body,2,length(src.admincaster_feed_message.body)+1)
		src.access_news_network()

	else if(href_list["ac_submit_wanted"])
		var/input_param = text2num(href_list["ac_submit_wanted"])
		if(src.admincaster_feed_message.author == "" || src.admincaster_feed_message.body == "")
			src.admincaster_screen = 16
		else
			var/choice = alert("Please confirm Wanted Issue [(input_param==1) ? ("creation.") : ("edit.")]","Network Security Handler","Confirm","Cancel")
			if(choice=="Confirm")
				if(input_param==1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one. See the else below
					var/datum/feed_message/WANTED = new /datum/feed_message
					WANTED.author = src.admincaster_feed_message.author               //Wanted name
					WANTED.body = src.admincaster_feed_message.body                   //Wanted desc
					WANTED.backup_author = src.admincaster_signature                  //Submitted by
					WANTED.is_admin_message = 1
					news_network.wanted_issue = WANTED
					for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
						NEWSCASTER.newsAlert()
						NEWSCASTER.update_icon()
					for(var/obj/item/device/pda/PDA in PDAs)
						var/datum/pda_app/newsreader/reader = locate(/datum/pda_app/newsreader) in PDA.applications
						if(reader)
							reader.newsAlert()
					src.admincaster_screen = 15
				else
					news_network.wanted_issue.author = src.admincaster_feed_message.author
					news_network.wanted_issue.body = src.admincaster_feed_message.body
					news_network.wanted_issue.backup_author = src.admincaster_feed_message.backup_author
					src.admincaster_screen = 19
				log_admin("[key_name_admin(usr)] issued a Station-wide Wanted Notification for [src.admincaster_feed_message.author]!")
		src.access_news_network()

	else if(href_list["ac_cancel_wanted"])
		var/choice = alert("Please confirm Wanted Issue removal","Network Security Handler","Confirm","Cancel")
		if(choice=="Confirm")
			news_network.wanted_issue = null
			for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
				NEWSCASTER.update_icon()
			src.admincaster_screen=17
		src.access_news_network()

	else if(href_list["ac_censor_channel_author"])
		var/datum/feed_channel/FC = locate(href_list["ac_censor_channel_author"])
		if(FC.author != "<B>\[REDACTED\]</B>")
			FC.backup_author = FC.author
			FC.author = "<B>\[REDACTED\]</B>"
		else
			FC.author = FC.backup_author
		src.access_news_network()

	else if(href_list["ac_censor_channel_story_author"])
		var/datum/feed_message/MSG = locate(href_list["ac_censor_channel_story_author"])
		if(MSG.author != "<B>\[REDACTED\]</B>")
			MSG.backup_author = MSG.author
			MSG.author = "<B>\[REDACTED\]</B>"
		else
			MSG.author = MSG.backup_author
		src.access_news_network()

	else if(href_list["ac_censor_channel_story_body"])
		var/datum/feed_message/MSG = locate(href_list["ac_censor_channel_story_body"])
		if(MSG.body != "<B>\[REDACTED\]</B>")
			MSG.backup_body = MSG.body
			MSG.body = "<B>\[REDACTED\]</B>"
		else
			MSG.body = MSG.backup_body
		src.access_news_network()

	else if(href_list["ac_pick_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["ac_pick_d_notice"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen=13
		src.access_news_network()

	else if(href_list["ac_toggle_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["ac_toggle_d_notice"])
		FC.censored = !FC.censored
		src.access_news_network()

	else if(href_list["ac_view"])
		src.admincaster_screen=1
		src.access_news_network()

	else if(href_list["ac_setScreen"]) //Brings us to the main menu and resets all fields~
		src.admincaster_screen = text2num(href_list["ac_setScreen"])
		if (src.admincaster_screen == 0)
			if(src.admincaster_feed_channel)
				src.admincaster_feed_channel = new /datum/feed_channel
			if(src.admincaster_feed_message)
				src.admincaster_feed_message = new /datum/feed_message
		src.access_news_network()

	else if(href_list["ac_show_channel"])
		var/datum/feed_channel/FC = locate(href_list["ac_show_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 9
		src.access_news_network()

	else if(href_list["ac_pick_censor_channel"])
		var/datum/feed_channel/FC = locate(href_list["ac_pick_censor_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 12
		src.access_news_network()

	else if(href_list["ac_refresh"])
		src.access_news_network()

	else if(href_list["ac_set_signature"])
		src.admincaster_signature = adminscrub(input(usr, "Provide your desired signature", "Network Identity Handler", ""))
		src.access_news_network()

	else if(href_list["populate_inactive_customitems"])
		if(check_rights(R_ADMIN|R_SERVER))
			populate_inactive_customitems_list(src.owner)

	else if(href_list["vsc"])
		if(check_rights(R_ADMIN|R_SERVER))
			if(href_list["vsc"] == "airflow")
				zas_settings.ChangeSettingsDialog(usr,zas_settings.settings)
			if(href_list["vsc"] == "default")
				zas_settings.SetDefault(usr)

	else if(href_list["xgm_panel"])
		XGM.ui_interact(usr)

	else if(href_list["toggle_light"])
		if(!SSticker.initialized)
			to_chat(usr, "<span class = 'notice'>Please wait for initialization to complete.</span>")
			return
		SSlighting.flags = SS_FIRE_IN_LOBBY //Purges the treat wait as ticks rather than DC
		SSlighting.wait = 5
		Master.make_runtime = TRUE


	else if(href_list["toglang"])
		if(check_rights(R_SPAWN))
			var/mob/M = locate(href_list["toglang"])
			if(!istype(M))
				to_chat(usr, "[M] is illegal type, must be /mob!")
				return
			var/lang2toggle = href_list["lang"]
			var/datum/language/L = all_languages[lang2toggle]

			if(L in M.languages)
				if(!M.remove_language(lang2toggle))
					to_chat(usr, "Failed to remove language '[lang2toggle]' from \the [M]!")
			else
				if(!M.add_language(lang2toggle))
					to_chat(usr, "Failed to add language '[lang2toggle]' from \the [M]!")

			show_player_panel(M)

	// player info stuff

	if(href_list["add_player_info"])
		var/key = href_list["add_player_info"]
		var/add = input("Add Player Info") as null|message
		if(!add)
			return

		notes_add(key, add)
		show_player_info(key)

	if(href_list["remove_player_info"])
		var/key = href_list["remove_player_info"]
		var/index = text2num(href_list["remove_index"])

		notes_del(key, index)
		show_player_info(key)

	if(href_list["notes"])
		var/ckey = href_list["ckey"]
		if(!ckey)
			var/mob/M = locate(href_list["mob"])
			if(ismob(M))
				ckey = M.ckey

		switch(href_list["notes"])
			if("show")
				show_player_info(ckey)
			if("list")
				PlayerNotesPage(text2num(href_list["index"]))
		return

//-------------------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------Shuttle stuff-----------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------

	if(href_list["shuttle_select"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","SS")

		var/datum/shuttle/S = select_shuttle_from_all(usr,"Please select a shuttle","Admin abuse")

		if(istype(S))
			selected_shuttle = S
			to_chat(usr, "[S] ([S.type]) selected!")

		shuttle_magic() //Update the window!
	if(href_list["shuttle_add_docking_port"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","CD")

		var/area/A = get_area(get_turf(usr))
		var/datum/shuttle/shuttle_to_add_to = A.get_shuttle()

		if(istype(shuttle_to_add_to))
			if(alert(usr, "Would you like the new shuttle docking port to be assigned to [shuttle_to_add_to.name]? [shuttle_to_add_to.linked_port ? "NOTE: It already has a shuttle docking port." : ""]", "Admin abuse", "Yes", "No") != "Yes")
				shuttle_to_add_to = null

		var/obj/docking_port/shuttle/D = new( get_turf(usr) )
		D.dir = usr.dir

		if(istype(shuttle_to_add_to))
			D.link_to_shuttle(shuttle_to_add_to)
			to_chat(usr, "Assigned the [D] to [shuttle_to_add_to.name]")

		message_admins("<span class='notice'>[key_name_admin(usr)] has created a new shuttle docking port in [get_area(D)] [formatJumpTo(get_turf(D))][shuttle_to_add_to ? " and assigned it to [shuttle_to_add_to.name]" : ""]</span>", 1)
		log_admin("[key_name_admin(usr)] has created a new destination docking port ([D.areaname]) at [D.x];[D.y];[D.z][shuttle_to_add_to ? " and assigned it to [shuttle_to_add_to.name]" : ""]")

	if(href_list["shuttle_create_destination"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","DC")

		var/area/A = get_area(get_turf(usr))

		var/name = input(usr,"What would you like to name this docking port?","Admin abuse","[A ? "[A.name]" : "Space [rand(100,999)]"]") as text|null
		if(!name)
			return

		var/obj/docking_port/destination/D = new( get_turf(usr) )
		D.dir = usr.dir
		D.areaname = name

		A = get_area(D)
		if(A)
			var/datum/shuttle/S = A.get_shuttle()
			if(S)
				if(alert(usr,"Would you like the new docking port to be a part of [S.name] ([S.type])? Any shuttles docked to it will be moved together with [S.name].","Admin abuse","Yes","No") == "Yes")
					if(get_area(D) == A) //If the shuttle moved, abort -- as that would lead to weird shittu
						S.docking_ports_aboard |= D
						to_chat(usr, "[D] is now considered a part of [S.name] ([S.type]).")

		if(istype(selected_shuttle))
			if(alert(usr,"Would you like to add [D.areaname] to the list of [selected_shuttle.name]'s destinations?","Admin abuse","Yes","No") == "Yes")
				selected_shuttle.docking_ports |= D
				to_chat(usr, "Added [D] to the list of [selected_shuttle.name]'s destinations")

		message_admins("<span class='notice'>[key_name_admin(usr)] has created a new destination docking port ([D.areaname]) in [get_area(D)] [formatJumpTo(get_turf(D))]</span>", 1)
		log_admin("[key_name_admin(usr)] has created a new destination docking port ([D.areaname]) at [D.x];[D.y];[D.z]")

	if(href_list["shuttle_modify_destination"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","MD")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S))
			return

		var/list/docking_ports_to_pick_from = all_docking_ports.Copy()
		var/list/options = list()
		for(var/obj/docking_port/destination/D in (docking_ports_to_pick_from - S.docking_ports))
			var/name = D.areaname
			options += name
			options[name] = D

		var/obj/docking_port/destination/choice = options[(input(usr,"Select a docking port to add to [S.name]","Admin abuse") as null|anything in options)]
		if(!istype(choice))
			return

		S.docking_ports |= choice
		to_chat(usr, "Added [choice.areaname] to [S.name]!")

	if(href_list["shuttle_set_transit"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","AT")

		var/list/L = list()
		for(var/obj/docking_port/destination/D in get_turf(usr) )
			var/name = "[D.name] ([D.areaname])"
			L += name
			L[name]=D

		if(!L.len)
			to_chat(usr, "Please stand on the docking port you wish to make a transit area.")

		var/obj/docking_port/port_to_link = L[ (input(usr,"Select a new transit area for the shuttle","Admin abuse") as null|anything in (L + list("Cancel"))) ]
		if(!istype(port_to_link))
			return

		var/datum/shuttle/shuttle_to_link = selected_shuttle
		if(!istype(shuttle_to_link))
			return

		var/choice = input(usr,"Please confirm that you want to make [port_to_link] ([port_to_link.areaname]) a transit area for [shuttle_to_link.name] ([shuttle_to_link.type])?","Admin abuse") in list("Yes","No")

		if(choice == "Yes")
			shuttle_to_link.set_transit_dock(port_to_link)
		else
			return

		message_admins("[key_name_admin(usr)] has set a destination docking port ([port_to_link.areaname]) at [port_to_link.x];[port_to_link.y];[port_to_link.z] to be [shuttle_to_link.name] ([shuttle_to_link.type])'s transit area [formatJumpTo(get_turf(port_to_link))]", 1)
		log_admin("[key_name_admin(usr)] has set a destination docking port ([port_to_link.areaname]) at [port_to_link.x];[port_to_link.y];[port_to_link.z] to be [shuttle_to_link.name] ([shuttle_to_link.type])'s transit area")

	if(href_list["shuttle_create_shuttleport"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","SC")

		var/obj/docking_port/shuttle/D = new(get_turf(usr.loc))
		D.dir = usr.dir

		var/area/A = get_area(D)
		var/datum/shuttle/S = A.get_shuttle()
		if(S && !S.linked_port)
			if(alert(usr,"Would you like to make [S.name] ([S.type]) use this docking port?","Admin abuse","Yes","No") == "Yes")
				if(!S || S.linked_port)
					to_chat(usr, "Either the shuttle was deleted, or somebody already linked a shuttle docking port to it. Sorry!")
					return
				if(!D)
					return

				S.linked_port = D
				to_chat(usr, "The shuttle docking port will now be used by [S.name]!")

		message_admins("<span class='notice'>[key_name_admin(usr)] has created a new shuttle docking port in [get_area(D)] [formatJumpTo(get_turf(D))]</span>", 1)
		log_admin("[key_name_admin(usr)] has created a new shuttle docking port at [D.x];[D.y];[D.z]</span>")

	if(href_list["shuttle_toggle_lockdown"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","LD")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S))
			return

		if(S.lockdown)
			S.lockdown = 0
			to_chat(usr, "The lockdown from [S.name] has been lifted.")
			message_admins("<span class='notice'>[key_name_admin(usr)] has lifted [capitalize(S.name)]'s lockdown.</span>", 1)
			log_admin("[key_name(usr)] has locked [capitalize(S.name)] down. [(length(S.lockdown)>=1) ? "Reason: [S.lockdown]" : ""]")
		else
			S.lockdown = 1
			to_chat(usr, "[S.name] has been locked down.")
			var/reason = input(usr,"Would you like to provide additional information, which will be shown on [capitalize(S.name)]'s control consoles?","Shuttle lockdown") in list("Yes","No")
			if(reason == "Yes")
				reason = input(usr,"Please type additional information about the lockdown of [capitalize(S.name)].","Shuttle lockdown")
				if(length(reason)>=1)
					S.lockdown = reason
			message_admins("<span class='notice'>[key_name_admin(usr)] has locked [capitalize(S.name)] down. [(length(S.lockdown)>=1) ? "Reason: [S.lockdown]" : ""]</span>", 1)
			log_admin("[key_name(usr)] has locked [capitalize(S.name)] down. [(length(S.lockdown)>=1) ? "Reason: [S.lockdown]" : ""]")

	if(href_list["shuttle_move_to"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","MV")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S))
			return

		var/list/possible_ports = list()
		for(var/obj/docking_port/destination/D in S.docking_ports)
			var/name = D.areaname
			possible_ports += name
			possible_ports[name] = D

		var/choice = input(usr, "Select a docking port for [capitalize(S.name)] to travel to", "Shuttle movement") in (possible_ports + list("Cancel"))
		var/obj/docking_port/destination/target_port = possible_ports[choice]

		if(!target_port)
			return

		S.travel_to(target_port,,usr)

		message_admins("[key_name_admin(usr)] has moved [capitalize(S.name)] to [target_port.areaname] ([target_port.x];[target_port.y];[target_port.z])")
		log_admin("[key_name(usr)] has moved [capitalize(S.name)] to [target_port.areaname] ([target_port.x];[target_port.y];[target_port.z])")

	if(href_list["shuttle_edit"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","SE")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S))
			return

		var/list/options = list("Cancel","cooldown","pre-flight delay","transit delay","use transit","can link to computer","innacuracy","name","destroy areas","can rotate")
		if(S.is_special())
			options += "DEFINED LOCATIONS"
		var/choice = input(usr,"What to edit in [capitalize(S.name)]?","Shuttle editing") in options

		var/new_value
		switch(choice)
			if("cooldown")
				new_value = input(usr,"Input new cooldown for [capitalize(S.name)] (in 1/10s of a second)","Shuttle editing",S.cooldown) as num
				S.cooldown = new_value
			if("pre-flight delay")
				new_value = input(usr,"Input new pre-flight delay for [capitalize(S.name)] (in 1/10s of a second)","Shuttle editing",S.pre_flight_delay) as num
				S.pre_flight_delay = new_value
			if("transit delay")
				new_value = input(usr,"Input new transit delay for [capitalize(S.name)] (in 1/10s of a second)","Shuttle editing",S.transit_delay) as num
				S.transit_delay = new_value
			if("use transit")
				new_value = input(usr,"[NO_TRANSIT] -  no transit, [TRANSIT_ACROSS_Z_LEVELS] - only across z levels, [TRANSIT_ALWAYS] - always","Shuttle editing ([capitalize(S.name)])",S.use_transit) as num
				if(new_value in list(NO_TRANSIT,TRANSIT_ACROSS_Z_LEVELS,TRANSIT_ALWAYS))
					S.use_transit = new_value
				else
					to_chat(usr, "Not valid!")
					return
			if("can link to computer")
				new_value = input(usr,"[LINK_FREE] - can always link, [LINK_PASSWORD_ONLY] - can only link with password ([S.password]), [LINK_FORBIDDEN] - can't link at all","Shuttle editing ([capitalize(S.name)])",S.can_link_to_computer) as num
				S.pre_flight_delay = new_value
			if("direction")
				new_value = input(usr,"[NORTH] - north, [SOUTH] - south, [WEST] - west, [EAST] - east","Shuttle editing ([capitalize(S.name)])",S.dir) as num
				if(new_value in cardinal)
					S.dir = new_value
				else
					to_chat(usr, "Not valid!")
					return
			if("innacuracy")
				new_value = input(usr,"Input new innacuracy value for [capitalize(S.name)] (when a shuttle moves, its final location is randomly offset by this value)","Shuttle editing",S.innacuracy) as num
				S.innacuracy = new_value
			if("name")
				new_value = input(usr,"Input new name for [capitalize(S.name)]","Shuttle editing",S.innacuracy) as text
				S.name = new_value
			if("can rotate")
				new_value = input(usr,"0 - rotation disabled, 1 - rotation enabled","Shuttle editing",S.can_rotate) as num
				S.can_rotate = new_value
			if("destroy areas")
				new_value = input(usr,"Allow this shuttle to crush into areas? Currently set to: [S.destroy_everything ? "True" : "False"]","Shuttle editing") as null|anything in list("CRUSH","No crush")
				if(new_value == "CRUSH")
					S.destroy_everything = TRUE
				else if(new_value == "No crush")
					S.destroy_everything = FALSE
				else
					return
			if("DEFINED LOCATIONS")
				to_chat(usr, "To prevent accidental mistakes, you can only set these locations to docking ports in the shuttle's memory (use the \"Add a destination docking port to a shuttle\" command)")

				var/list/locations = list("--Cancel--")
				switch(S.type)
					if(/datum/shuttle/vox)
						locations += list("Vox home (MOVING TO IT WILL END THE ROUND)" = "dock_home")
					if(/datum/shuttle/escape)
						locations += list("Escape shuttle home" = "dock_station","Escape shuttle centcom" = "dock_centcom")
					if(/datum/shuttle/supply)
						locations += list("Centcom loading bay" = "dock_centcom", "Station cargo bay" = "dock_station")

				var/choice2 = input(usr,"Select a location to modify","Shuttle editing") in locations
				var/variable_to_edit = locations[choice2]

				var/obj/docking_port/destination/D = select_port_from_list(usr,"Select a new [choice2] location for [S.name] ([S.type])","Shuttle editing",S.docking_ports)
				if(istype(D))
					S.vars[variable_to_edit] = D
					to_chat(usr, "[S.name]'s [variable_to_edit] has been changed to [D.areaname]")
					message_admins("<span class='notice'>[key_name_admin(usr)] has changed [capitalize(S.name)]'s [choice2] to [D.areaname]!</span>", 1)
					log_admin("[key_name_admin(usr)] has changed [capitalize(S.name)]'s [choice2] to [D.areaname]!")
				else
					return


		message_admins("<span class='notice'>[key_name_admin(usr)] has set [capitalize(S.name)]'s [choice] to [new_value]!</span>", 1)
		log_admin("[key_name_admin(usr)] has set [capitalize(S.name)]'s [choice] to [new_value]!")

		shuttle_magic() //Update the window!

	if(href_list["shuttle_delete"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","DEL")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S))
			return

		var/killed_objs = 0

		if( (input(usr,"Please type \"Yes\" to confirm that you want to delete [capitalize(S)]. This process can't be reverted!","Shuttle deletion","No") as text) != "Yes" )
			return

		if(S.is_special())
			to_chat(usr, "This shuttle can't be deleted. Use the lockdown function instead.")
			return

		var/choice = (input(usr,"Would you like to delete all turfs and objects in the shuttle's current area? Mobs will not be affected.") in list("Yes","No","Cancel") )
		if(choice == "Cancel")
			return
		else if(choice == "Yes")
			killed_objs = 1

		if(S.linked_area)
			if(killed_objs == 1)
				for(var/turf/T in S.linked_area)
					if(istype(T, /turf/simulated))
						qdel(T)
				for(var/obj/O in S.linked_area)
					if(istype(O, /obj/item) || istype(O, /obj/machinery) || istype(O, /obj/structure))
						qdel(O)
				to_chat(usr, "All turfs and objects deleted from [S.linked_area].")

		message_admins("<span class='notice'>[key_name_admin(usr)] has deleted [capitalize(S.name)] ([S.type]). Objects and turfs [(killed_objs) ? "deleted" : "not deleted"].</span>")
		log_admin("[key_name(usr)]  has deleted [capitalize(S.name)]! Objects and turfs [(killed_objs) ? "deleted" : "not deleted"].")

		QDEL_NULL(S)

		shuttle_magic() //Update the window!

	if(href_list["shuttle_teleport_to"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","TP")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S))
			return

		if(!S.linked_area || !istype(S.linked_area, /area/))
			to_chat(usr, "The shuttle is in the middle of nowhere! (The 'linked_area' variable is either null or not an area, please report this)")
			return

		var/turf/T = locate(/turf/) in S.linked_area
		usr.forceMove(T)
		to_chat(usr, "You have teleported to [capitalize(S.name)]")

	if(href_list["shuttle_teleport_to_dock"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","TP2")

		var/list/destinations = list()
		for(var/obj/docking_port/destination/D in all_docking_ports)
			var/name = "[D.areaname][D.docked_with ? " (docked to [D.docked_with.areaname])" : ""]"
			destinations += name
			destinations[name]=D

		var/choice = input(usr,"Select a docking port to teleport to","Finding a docking port") in destinations

		var/obj/docking_port/destination/target = destinations[choice]
		if(!target)
			return

		usr.forceMove(get_turf(target))
		to_chat(usr, "You have teleported to [choice]")

	if(href_list["shuttle_get_console"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","GC")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S))
			return

		if(!S.control_consoles.len)

			var/choice = input(usr,"There is no control console linked to [capitalize(S.name)]. Would you like to create one at your current location?","Shuttle control access") in list("Yes","No")
			if(choice == "Yes")
				var/turf/usr_loc = get_turf(usr)
				var/obj/machinery/computer/shuttle_control/C = new(usr_loc)
				if(C)
					C.link_to(S)
					to_chat(usr, "A new shuttle control console has been created.")
					message_admins("[key_name_admin(usr)] has created a new shuttle control console connected to [capitalize(S.name)] in [get_area(usr_loc)].")
					log_admin("[key_name(usr)] has created a new shuttle control console connected to [capitalize(S.name)] in [get_area(usr_loc)].")
			else
				return

		else

			var/obj/machinery/computer/shuttle_control/C = pick(S.control_consoles)
			if(C)
				usr.forceMove(C.loc)

	if(href_list["shuttle_shuttlify"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","SHH")

		var/area/A = get_area(usr)
		if(!A)
			to_chat(usr, "You must be standing on an area!")
			return
		if(isspace(A))
			to_chat(usr, "You can't turn space into a shuttle.")
			return

		var/datum/shuttle/conflict = A.get_shuttle()
		if(conflict)
			var/choice = input(usr,"This area is already used by [conflict]. Type \"Yes\" to continue and bring on the unintended features","Shuttlify","NO") as text
			if(choice != "Yes")
				return

		if( !(locate(/obj/docking_port/shuttle) in A) )
			to_chat(usr, "Please create a shuttle docking port (/obj/docking_port/shuttle) in this area!")
			return

		var/name = input(usr, "Please name the new shuttle", "Shuttlify", A.name) as text|null

		if(!name)
			to_chat(usr, "Shuttlifying cancelled.")
			return

		var/datum/shuttle/custom/S = new(starting_area = A)
		S.initialize()
		S.name = name

		to_chat(usr, "Shuttle created!")

		selected_shuttle = S
		shuttle_magic() //Update the window!

		message_admins("<span class='notice'>[key_name_admin(usr)] has turned [A.name] into a shuttle named [S.name]. [formatJumpTo(get_turf(usr))]</span>")
		log_admin("[key_name(usr)]  has turned [A.name] into a shuttle named [S.name].")

	if(href_list["shuttle_forcemove"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","FM")

		var/list/L = list("Cancel","YOUR CURRENT LOCATION")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S))
			return

		for(var/obj/docking_port/destination/D in S.docking_ports)
			var/name = "[D.name] [D.areaname]"
			L+=name
			L[name]=D

		L += "---other destinations---"

		for(var/obj/docking_port/destination/D in all_docking_ports - S.docking_ports)
			var/name = D.areaname
			L+=name
			L[name]=D

		var/choice = input(usr, "Select a location to teleport [S.name] to!", "Shuttle teleporting") in L

		if(choice == "YOUR CURRENT LOCATION")
			var/area/A = get_area(usr)
			var/turf/T = get_turf(usr)
			if(!A)
				return
			if(!T)
				return

			var/obj/docking_port/destination/temp = new(T)
			temp.invisibility = 101
			temp.areaname = A.name
			temp.dir = usr.dir

			S.move_to_dock(temp)

			message_admins("[key_name_admin(usr)] has teleported [capitalize(S.name)] to himself ([A.name], [temp.x];[temp.y];[temp.z])!")
			log_admin("[key_name(usr)] has teleported [capitalize(S.name)] to himself by ([A.name], [temp.x];[temp.y];[temp.z])")

			qdel(temp)
			return
		else
			var/obj/docking_port/destination/D = L[choice]
			if(!D)
				return

			S.move_to_dock(D)

			message_admins("<span class='notice'>[key_name_admin(usr)] has teleported [capitalize(S.name)] to [choice] ([D.x];[D.y];[D.z])</span>")
			log_admin("[key_name(usr)] has teleported [capitalize(S.name)] to [choice] ([D.x];[D.y];[D.z])")

			return

	if(href_list["shuttle_reset"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","SR")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S))
			return

		if(alert(usr,"ARE YOU SURE YOU WANT TO RESET [S.name] ([S.type])?","HELP","Yes","No")=="No")
			return

		S.name = initial(S.name)
		S.cooldown = initial(S.cooldown)
		S.innacuracy = initial(S.innacuracy)
		S.transit_delay = initial(S.transit_delay)
		S.pre_flight_delay = initial(S.pre_flight_delay)
		S.use_transit = initial(S.use_transit)
		S.dir = initial(S.dir)

		S.initialize()

		message_admins("[key_name_admin(usr)] has reset [capitalize(S.name)]'s variables")
		log_admin("[key_name(usr)] has reset [capitalize(S.name)]'s variables")

	if(href_list["shuttle_supercharge"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","SUP")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S))
			return

		S.supercharge()

	if(href_list["shuttle_mass_lockdown"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","ML")

		if( !(input(usr,"Please type \"Yes\" to confirm that you want to lockdown all shuttles.","IS IT LOOSE?","NO") == "Yes") )
			return

		for(var/datum/shuttle/S in shuttles)
			S.lockdown = 1

		to_chat(usr, "All shuttles were locked down.")

		message_admins("<span class='notice'>[key_name_admin(usr)] has locked all shuttles down!</span>")
		log_admin("[key_name(usr)] has locked all shuttles down!")

	if(href_list["shuttle_show_overlay"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","SO")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S))
			return

		if(!S.linked_port)
			to_chat(usr, "The shuttle must have a shuttle docking port!")
			return

		if(usr.dir != S.dir)
			to_chat(usr, "WARNING: You're not facing [dir2text(S.dir)]! The result may be <i>slightly</i> innacurate.")

		S.show_outline(usr)

	if(href_list["shuttle_generate_transit"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","SO")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S))
			return

		var/transit_dir = NORTH
		var/list/dirs = list("north"=NORTH, "west"=WEST, "east"=EAST, "south"=SOUTH)
		var/choice = input(usr, "Select a direction for the transit area (this should be the direction in which the shuttle is currently facing)", "Transit") as null|anything in dirs

		if(!choice)
			return

		transit_dir = dirs[choice]

		var/obj/docking_port/destination/D = generate_transit_area(S, transit_dir)
		if(!istype(D))
			to_chat(usr, "<span class='notice'>Transit area generation failed!</span>")
			return

		S.transit_port = D
		to_chat(usr, "<span class='info'>Transit area generated successfully.</span>")
		if(S.use_transit == NO_TRANSIT)
			S.use_transit = TRANSIT_ACROSS_Z_LEVELS
			to_chat(usr, "<span class='info'>The [S.name] will now use the transit area when traveling across z-levels. Set its use_transit to 2 to make it always use transit, or 0 to disable transit.</span>")


	//------------------------------------------------------------------Shuttle stuff end---------------------------------


	if (href_list["obj_add"])
		var/datum/objective_holder/obj_holder = locate(href_list["obj_holder"])

		var/list/available_objectives = list()

		for(var/objective_type in subtypesof(/datum/objective))
			var/datum/objective/O = objective_type
			available_objectives.Add(initial(O.name))
			available_objectives[initial(O.name)] = O

		var/new_obj = input("Select a new objective", "New Objective", null) as null|anything in available_objectives
		var/obj_type = available_objectives[new_obj]

		var/datum/objective/new_objective = new obj_type(usr, obj_holder.faction)

		if (new_objective.flags & FACTION_OBJECTIVE)
			var/datum/faction/fac = input("To which faction shall we give this?", "Faction-wide objective", null) as null|anything in ticker.mode.factions
			fac.handleNewObjective(new_objective)
			message_admins("[key_name_admin(usr)] gave \the [new_objective.faction.ID] the objective: [new_objective.explanation_text]")
			log_admin("[key_name(usr)] gave \the [new_objective.faction.ID] the objective: [new_objective.explanation_text]")
			check_antagonists()
			return TRUE // It's a faction objective, let's not move any further.

		if (obj_holder.owner)//so objectives won't target their owners.
			new_objective.owner = obj_holder.owner

		var/setup = TRUE
		if (istype(new_objective,/datum/objective/target))
			var/datum/objective/target/new_O = new_objective
			if (alert("Do you want to specify a target?", "New Objective", "Yes", "No") == "Yes")
				setup = new_O.select_target()
				new_O.auto_target = FALSE
			else
				setup = TRUE //Let it sort itself out

		if(!setup)
			alert("Couldn't set-up a proper target.", "New Objective")
			return

		if (new_objective.faction && istype(new_objective, /datum/objective/custom)) //is it a custom objective with a faction modifier?
			new_objective.faction.AppendObjective(new_objective)
			message_admins("[key_name_admin(usr)] gave \the [new_objective.faction.ID] the objective: [new_objective.explanation_text]")
			log_admin("[key_name(usr)] gave \the [new_objective.faction.ID] the objective: [new_objective.explanation_text]")
		else if (obj_holder.faction) //or is it just an explicit faction obj?
			obj_holder.faction.AppendObjective(new_objective)
			message_admins("[key_name_admin(usr)] gave \the [obj_holder.faction.ID] the objective: [new_objective.explanation_text]")
			log_admin("[key_name(usr)] gave \the [obj_holder.faction.ID] the objective: [new_objective.explanation_text]")
		check_antagonists()

	if (href_list["obj_delete"])
		var/datum/objective/objective = locate(href_list["obj_delete"])
		var/datum/objective_holder/obj_holder = locate(href_list["obj_holder"])

		ASSERT(istype(objective) && istype(obj_holder))
		if (obj_holder.faction)
			log_admin("[usr.key]/([usr.name]) removed \the [obj_holder.faction.ID]'s objective ([objective.explanation_text])")
			objective.faction.handleRemovedObjective(objective)

		obj_holder.objectives.Remove(objective)
		check_antagonists()

	if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])
		var/datum/objective_holder/obj_holder = locate(href_list["obj_holder"])

		ASSERT(istype(objective))

		if (objective.faction)
			objective.faction.handleForcedCompletedObjective(objective)

		objective.force_success = !objective.force_success
		check_antagonists()
		message_admins("[usr.key]/([usr.name]) toggled [obj_holder.faction.ID] [objective.explanation_text] to [objective.force_success ? "completed" : "incomplete"]")
		log_admin("[usr.key]/([usr.name]) toggled [obj_holder.faction.ID] [objective.explanation_text] to [objective.force_success ? "completed" : "incomplete"]")

	if (href_list["obj_announce"])
		var/text = ""
		var/owner = locate(href_list["obj_owner"])
		if (istype(owner, /datum/faction))
			var/datum/faction/F = owner
			for (var/datum/role/member in F.members)
				to_chat(member.antag.current, "<span class='notice'>Your faction objectives are:</span>")
				if (length(member.faction.objective_holder.GetObjectives()))
					var/obj_count = 1
					for(var/datum/objective/O in member.faction.GetObjectives())
						text += "<b>Objective #[obj_count++]</b>: [O.explanation_text]<br>"
					text += "</ul>"
				to_chat(member.antag.current, text)


	if(href_list["obj_gen"])
		var/owner = locate(href_list["obj_owner"])
		var/datum/faction/F = owner
		var/list/faction_objectives = F.GetObjectives()
		var/list/prev_objectives = faction_objectives.Copy()
		F.forgeObjectives()
		var/list/unique_objectives = find_unique_objectives(F.GetObjectives(), prev_objectives)
		if (!unique_objectives.len)
			alert(usr, "No new objectives generated.", "", "OK")
		else
			for (var/datum/objective/objective in unique_objectives)
				message_admins("[key_name_admin(usr)] gave \the [F.ID] the objective: [objective.explanation_text]")
				log_admin("[key_name(usr)] gave \the [F.ID] the objective: [objective.explanation_text]")
		check_antagonists()

	if(href_list["wages_enabled"])
		if(check_rights(R_ADMIN))
			if(ticker.current_state == 1)
				to_chat(usr, "Round hasn't started yet!")
				return
			if(href_list["wages_enabled"] == "enable")
				if(wages_enabled)
					to_chat(usr, "Wages are already enabled!")
				else
					wages_enabled = 1
					message_admins("<span class='notice'>[key_name_admin(usr)] has enabled wages!")
			else if(href_list["wages_enabled"] == "disable")
				if(!wages_enabled)
					to_chat(usr, "Wages are already disabled!")
				else
					wages_enabled = 0
					message_admins("<span class='notice'>[key_name_admin(usr)] has disabled wages!")
		return

	if(href_list["econ_panel"])
		var/choice = href_list["econ_panel"]
		EconomyPanel(choice, href_list)


	else if (href_list["viewruntime"])
		var/datum/error_viewer/error_viewer = locate(href_list["viewruntime"])
		if (!istype(error_viewer))
			to_chat(owner, "<span class='warning'>That runtime viewer no longer exists.</span>")
			return

		if (href_list["viewruntime_backto"])
			error_viewer.show_to(owner, locate(href_list["viewruntime_backto"]), href_list["viewruntime_linear"])
		else
			error_viewer.show_to(owner, null, href_list["viewruntime_linear"])

	else if (href_list["role_panel"])
		var/mob/M = locate(href_list["role_panel"])
		if (!istype(M))
			return
		var/datum/mind/mind = M.mind
		if (!istype(mind))
			return
		mind.role_panel()

	else if(href_list["credits"])
		switch(href_list["credits"])
			if("resetstar")
				if(!end_credits.drafted) //Just in case the button somehow gets clicked when it shouldn't
					end_credits.customized_star = ""
					log_admin("[key_name(usr)] reset the current round's featured star. A new one will automatically generate later.")
					message_admins("[key_name_admin(usr)] reset the current round's featured star. A new one will automatically generate later.")
			if("setstartext")
				var/newstar = thebigstar(input(usr,"Write the new star. In the final credits, it will be displayed as: 'Starring\[linebreak\]\[whatever you type here\]'. Mind your capitalization! You may also use HTML. Do not include the characters '%<splashbreak>' anywhere unless you know what you're doing, please.","in my dream, i am the star. its me", end_credits.star) as text|null)
				if(newstar)
					end_credits.customized_star = newstar
					log_admin("[key_name(usr)] forced the current round's featured star to be '[newstar]'")
					message_admins("[key_name_admin(usr)] forced the current round's featured star to be '[newstar]'")
			if("setstarmob")
				var/newstar = thebigstar(input(usr, "Who should be the featured star of this episode? WARNING: Only tested with humans.", "New star from moblist...") as null|anything in sortmobs())
				if(newstar)
					end_credits.customized_star = newstar
					log_admin("[key_name(usr)] forced the current round's featured star to be '[newstar]'")
					message_admins("[key_name_admin(usr)] forced the current round's featured star to be '[newstar]'")

			if("resetss")
				if(!end_credits.drafted) //Just in case the button somehow gets clicked when it shouldn't
					end_credits.customized_ss = ""
					log_admin("[key_name(usr)] reset the current round's screenshot.")
					message_admins("[key_name_admin(usr)] reset the current round's featured screenshot.")
			if("setss")
				var/newss = input(usr,"Please insert a direct image link. The maximum size is 600x600.") as text|null
				if(newss)
					end_credits.customized_ss = newss
					log_admin("[key_name(usr)] forced the current round's featured screenshot to be '[newss]'")
					message_admins("[key_name_admin(usr)] forced the current round's featured screenshot to be '[newss]'")

			if("resetname")
				if(!end_credits.drafted) //Just in case the button somehow gets clicked when it shouldn't
					end_credits.customized_name = ""
					log_admin("[key_name(usr)] reset the current round's episode name. A new one will automatically generate later.")
					message_admins("[key_name_admin(usr)] reset the current round's episode name. A new one will automatically generate later.")
			if("rerollname")
				end_credits.customized_name = ""
				end_credits.finalize_name()
				log_admin("[key_name(usr)] re-rolled the current round's episode name. New name: '[end_credits.episode_name]'")
				message_admins("[key_name_admin(usr)] re-rolled the current round's episode name. New name: '[end_credits.episode_name]'")
			if("setname")
				var/newname = input(usr,"Write the super original name of this masterpiece...","New Episode Name") as text|null
				if(newname)
					end_credits.customized_name = uppertext(newname)
					log_admin("[key_name(usr)] forced the current round's episode name to '[newname]'")
					message_admins("[key_name_admin(usr)] forced the current round's episode name to '[newname]'")

			if("namedatumedit")
				var/datum/episode_name/N = locate(href_list["nameref"])
				if(N)
					var/newname = input(usr,"Write a new possible episode name. This is NOT guaranteed to be picked as the final name, unless you modified the weight to 99999% or something.","Edit Name",N.thename) as text|null
					if(newname)
						N.thename = newname
						N.rare = TRUE
			if("namedatumweight")
				var/datum/episode_name/N = locate(href_list["nameref"])
				if(N)
					var/newweight = input(usr,"Write the new possibility that '[N.thename]' will be selected as the final episode name. Default is 100.","Edit Weight",N.weight) as num|null
					if(newweight)
						N.weight = newweight
			if("namedatumremove")
				var/datum/episode_name/N = locate(href_list["nameref"])
				if(N && alert("Are you sure you want to remove the name '[N.thename]' from the possible episode names to be picked?", "Removing possible name", "Yes", "No") == "Yes")
					end_credits.episode_names -= N
					qdel(N)

			if("newdisclaimer")
				var/newdisclaimer = input(usr,"Write a new rolling disclaimer. Probably something stupid like 'Sponsored by Toxins-R-Us'. This will show up at the top, right after the crew names. Add '\<br>' at the end if you want extra spacing.","New Disclaimer") as message|null
				if(newdisclaimer)
					newdisclaimer += "<br>"
					end_credits.disclaimers.Insert(1,newdisclaimer)
					log_admin("[key_name(usr)] added a new disclaimer to the current round's credits: '[html_encode(newdisclaimer)]'")
					message_admins("[key_name_admin(usr)] added a new disclaimer to the current round's credits: '[html_encode(newdisclaimer)]'")
			if("editdisclaimer")
				var/i = text2num(href_list["disclaimerindex"])
				var/olddisclaimer = end_credits.disclaimers[i]
				var/newdisclaimer = input(usr,"Write a new rolling disclaimer.","Edit Disclaimer",olddisclaimer) as message|null
				if(newdisclaimer)
					log_admin("[key_name(usr)] edited a rolling credits disclaimer. New disclaimer: '[html_encode(newdisclaimer)]'")
					message_admins("[key_name_admin(usr)] edited a rolling credits disclaimer. New disclaimer: '[html_encode(newdisclaimer)]'")
					end_credits.disclaimers[i] = newdisclaimer
			if("disclaimerup")
				var/i = text2num(href_list["disclaimerindex"])
				if(i > 1)
					end_credits.disclaimers.Swap(i,i-1)
			if("disclaimerdown")
				var/i = text2num(href_list["disclaimerindex"])
				if(i < end_credits.disclaimers.len)
					end_credits.disclaimers.Swap(i,i+1)

		CreditsPanel() //refresh!

	if(href_list["persistenceaction"])
		switch(href_list["persistenceaction"])
			if("qdelall")
				if(href_list["persistencedatum"])
					var/datum/map_persistence_type/T = locate(href_list["persistencedatum"])
					T.qdelAllTrackedItems(usr)
				else
					SSpersistence_map.qdelAllFilth(usr)
			if("togglesaving")
				SSpersistence_map.setSavingFilth(!SSpersistence_map.savingFilth, usr)


		PersistencePanel() //refresh!

	// --- Rod tracking

	else if (href_list["rod_to_untrack"])
		if(!check_rights(R_FUN))
			return
		var/obj/item/projectile/P = locate(href_list["rod_to_untrack"])

		if (!P)
			return

		P.tracking = FALSE
		P.tracker_datum = null
		qdel(P.tracker_datum)

		var/log_data = "[P.original]"
		if (ismob(P.original))
			var/mob/M = P.original
			if (M.client)
				log_data += " (M.client.ckey)"

		log_admin("[key_name(usr)] stopped a rod thrown at [log_data].")
		message_admins("<span class='notice'>[key_name(usr)]  stopped a rod thrown at [log_data].</span>")

		ViewAllRods()

	// ----- Religion and stuff
	else if(href_list["ashpaper"])
		if(!check_rights(R_ADMIN))
			return
		var/obj/item/weapon/paper/P = locate(href_list["ashpaper"])
		if(!istype(P))
			message_admins("The target doesn't exist.")
			return
		if(!is_type_in_list(/obj/item/weapon/stamp/chaplain,P.stamped))
			message_admins("That reference isn't for a paper with a chaplain stamp.")
			return
		var/ash_type = P.ashtype()
		new ash_type(get_turf(P))
		if(iscarbon(P.loc))
			var/mob/living/carbon/C = P.loc
			C.apply_damage(10,BURN,(pick(LIMB_LEFT_HAND, LIMB_RIGHT_HAND)))
			P.visible_message("<span class='sinister'>\The [P] catches fire, burning [C]!</span>")
		else
			P.visible_message("<span class='sinister'>\The [P] catches fire and smolders into ash!</span>")

		var/obj/item/weapon/storage/bag/clipboard/CB = P.loc
		if(istype(CB))
			CB.remove_from_storage(P, get_turf(CB), force = 1, refresh = 1)

		message_admins("Smote [P]!")
		qdel(P)

	if (href_list["religions"])
		#define MAX_MSG_LENGTH 200
		#define NUMBER_MAX_REL 4
		if (href_list["display"])
			updateRelWindow()

		switch (href_list["religions"])
			if ("global_subtle_pm")
				if (!href_list["rel"])
					return FALSE

				var/datum/religion/R = locate(href_list["rel"])

				if (!istype(R, /datum/religion))
					return FALSE

				var/deity = sanitize(stripped_input(usr, "Which deity addresses this group of believers?", "Deity Name", R.deity_name), 1, MAX_NAME_LEN)
				var/message = sanitize(stripped_input(usr, "Which message do you want to send?", "Message", ""), 1, MAX_MSG_LENGTH)

				if (!deity || !message)
					to_chat(usr, "<span class='warning'>Error: no deity or message selected.</span>")

				for (var/datum/mind/M in R.adepts)
					if (M.current)
						to_chat(M.current, "You hear [deity]'s voice in your head... <i>[message]</i>")

				var/msg = "[key_name(usr)] sent message [message] to [R.name]'s adepts as [deity]"
				message_admins(msg)


			if ("new") // --- Busing in a new rel ---
				// This is copypasted from chaplain code, with adaptations

				if (ticker.religions.len >= NUMBER_MAX_REL)
					to_chat(usr, "<span class='warning'>Maximum number of religions reached.</span>")
					return FALSE // Just in case a href exploit allows someone to create a gazillion religions with no purpose.

				var/new_religion = sanitize(stripped_input(usr, "Enter the key to the new religion (leave empty to abort)", "New religion", "Adminbus"), 0, MAX_NAME_LEN)

				if (!new_religion)
					return FALSE

				var/datum/religion/rel_added

				var/choice = FALSE
				for (var/R in typesof(/datum/religion))
					rel_added = new R
					for (var/key in rel_added.keys)
						if (lowertext(new_religion) == key)
							rel_added.holy_book = new rel_added.bible_type
							rel_added.holy_book.name = rel_added.bible_name
							rel_added.holy_book.my_rel = rel_added
							choice = TRUE
							break // Religion found - time to abort
					if (choice)
						break

				if (!choice) // No religion found
					rel_added = new /datum/religion
					rel_added.name = "[new_religion]"
					rel_added.deity_name = "[new_religion]"
					rel_added.bible_name = "The Holy Book of [new_religion]"
					rel_added.holy_book = new rel_added.bible_type
					rel_added.holy_book.name = rel_added.bible_name
					rel_added.holy_book.my_rel = rel_added

				var/new_deity = copytext(sanitize(input(usr, "Would you like to change the deity? The deity currently is [rel_added.deity_name] (Leave empty or unchanged to keep deity name)", "Name of Deity", rel_added.deity_name)), 1, MAX_NAME_LEN)
				if(length(new_deity))
					rel_added.deity_name = new_deity

				// Bible chosing - without preview this time
				chooseBible(rel_added, usr)

				var/msg = "[key_name(usr)] created a religion: [rel_added.name]."
				message_admins(msg)

				ticker.religions += rel_added
				updateRelWindow()
			if ("delete")
				if (!href_list["rel"])
					return FALSE

				var/datum/religion/R = locate(href_list["rel"])

				if (!istype(R, /datum/religion))
					return FALSE

				if (R.adepts.len)
					to_chat(usr, "<span class='warning'>You can't delete a religion which has adepts.</span>")
					return FALSE

				var/msg = "[key_name(usr)] deleted a religion: [R.name]."
				ticker.religions -= R
				qdel(R.holy_book)
				qdel(R)
				message_admins(msg)
				updateRelWindow()

			if ("activate")
				if (!href_list["rel"])
					return FALSE

				var/datum/religion/R = locate(href_list["rel"])

				if (!istype(R, /datum/religion))
					return FALSE

				if (R.adepts.len)
					to_chat(usr, "<span class='warning'>The religion already has adepts!</span>")
					return FALSE

				if (alert("Do you wish to activate this religion? You will have to pick a player as its guide. Make sure the player is aware your plans!", "Activating a religion", "Yes", "No") != "Yes")
					return FALSE

				var/list/mob/moblist = list()

				for (var/client/c in clients)
					if (!c.mob.isDead() && !c.mob.mind.faith) // Can't use dead guys, nor people with already a religion
						moblist += c.mob

				var/mob/living/carbon/human/preacher = input(usr, "Who should be the leader of this new religion?", "Activating a religion") as null|anything in moblist

				if (alert("Do you want to make \the [preacher] the leader of [R.name]?", "Activating a religion", "Yes", "No") != "Yes")
					return FALSE

				if (!preacher)
					to_chat(usr, "<span class='warning'>No mob selected.</span>")
					return FALSE

				if (!preacher.mind)
					to_chat(usr, "<span class='warning'>This mob has no mind.</span>")
					return FALSE

				if (preacher.mind.faith)
					to_chat(usr, "<span class='warning'>This person already follows a religion.</span>")
					return FALSE

				R.activate(preacher)
				var/msg = "[key_name(usr)] activated religion [R.name], with preacher [key_name(preacher)]."
				message_admins(msg)
				updateRelWindow()

			if ("renounce")
				if (!href_list["mob"])
					return FALSE

				var/mob/living/M = locate(href_list["mob"])

				if (!isliving(M) || !M.mind.faith)
					return FALSE

				if (M.mind.faith.religiousLeader == M.mind)
					var/choice = alert("This mob is the leader of the religion. Are you sure you wish to remove him from his faith?", "Removing religion", "Yes", "No")
					if (choice != "Yes")
						return FALSE
				M.verbs -= /mob/proc/renounce_faith
				M.mind.faith.renounce(M) // Bypass checks

				var/msg = "[key_name(usr)] removed [key_name(M)] from his religion."
				message_admins(msg)
				updateRelWindow()

	if (href_list["change_zone_del"])
		switch (href_list["change_zone_del"])
			if ("x_min_del", "x_max_del", "y_min_del", "y_max_del")
				var/new_limit = input(usr, "Input the new boundary.", "Setting [href_list["change_zone_del"]]") as null|num
				if (new_limit < 0 || new_limit > world.maxx)
					to_chat(usr, "<span class='warning'>Please enter a number between 0 and [world.maxx].</span>")
					return FALSE
				vars[href_list["change_zone_del"]] = new_limit
			if ("z_del")
				var/new_limit = input(usr, "Input the new z-level.", "Setting [href_list["change_zone_del"]]") as null|num
				if (new_limit < 1 || new_limit > 6)
					to_chat(usr, "<span class='warning'>Please enter a number between 1 and 6.</span>")
					return FALSE
				z_del = new_limit
			if ("type") // Lifted from "spawn" code.
				var/object = input(usr, "Enter a typepath. It will be autocompleted.", "Setting the type to delete.") as null|text
				var/chosen = filter_typelist_input("Select an atom type", "Spawn Atom", get_matching_types(object, /atom))
				if(!chosen)
					to_chat(usr, "<span class='warning'>No type chosen.</span>")
					return

				type_del = chosen

			if ("exec")
				var/list/things = list()
				var/turf/T
				for (var/x_sel = x_min_del; x_sel <= x_max_del; x_sel++)
					for (var/y_sel = y_min_del; y_sel <= y_max_del; y_sel++)
						T = locate(x_sel, y_sel, z_del)
						things += T.contents
						CHECK_TICK
				var/time =  start_watch()
				var/list/to_del = list()
				for (var/thing in things)
					if (istype(thing, type_del))
						to_del += thing
				var/number = to_del.len
				for (var/thing in to_del)
					qdel(thing)
					CHECK_TICK
				var/total_time = stop_watch(time)
				log_admin("[key_name(usr)] deleted [number] [type_del] in a [x_max_del - x_min_del]x[y_max_del - y_min_del] square starting at ([x_min_del],[x_max_del],[z_del])")
				message_admins("[key_name(usr)] deleted [number] [type_del] in a [x_max_del - x_min_del]x[y_max_del - y_min_del] square starting at ([x_min_del],[x_max_del],[z_del])")
				x_min_del = 0
				x_max_del = 0
				y_min_del = 0
				y_max_del = 0
				z_del = 0
				type_del = null
				to_chat(usr, "<span class='notice'>Deleted [number] atoms in [total_time] seconds.</span>")

		mass_delete_in_zone() // Refreshes the window

	else if(href_list["tag_mode"])
		if (!check_rights(R_FUN))
			to_chat(usr, "You don't have the necessary permissions to do this.")
			return
		else
			toggle_tag_mode(usr)

/datum/admins/proc/SendAdminGhostTo(var/turf/T,var/mob/M)
	var/client/C = usr.client
	if(!isobserver(usr) && isliving(usr))
		var/mob/living/L = usr
		L.ghost()
	sleep(2)
	if(!isobserver(C.mob))
		return
	var/mob/dead/observer/O = C.mob
	if(O.locked_to)
		O.manual_stop_follow(O.locked_to)
	if (T)
		O.forceMove(T)
	else if (M)
		C.jumptomob(M)
		O.manual_follow(M)

/datum/admins/proc/updateRelWindow()
	var/text = list()
	text += "<h3>Religions in game</h3>"
	// --- Displaying of all religions ---
	for (var/datum/religion/R in ticker.religions)
		text += "<b>Name:</b> [R.name] <br/>"
		text += "<b>Deity name:</b> [R.deity_name]<br/>"
		if (!R.adepts.len) // Religion not activated yet
			text += "No adepts yet. "
			text += "(<A HREF='?_src_=holder;religions=delete&rel=\ref[R]'>Delete</A>) "
			text += "(<A HREF='?_src_=holder;religions=activate&rel=\ref[R]'>Activate</A>) <br/>"
			text += "<br/>"
		else
			text += "<b>Leader:</b> \the [R.religiousLeader.current] (<A HREF='?_src_=vars;Vars=\ref[R.religiousLeader.current]'>VV</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[R.religiousLeader.current]'>JMP</A>) \
					 (<A HREF='?_src_=holder;subtlemessage=\ref[R.religiousLeader.current]'>SM</A>)<br/>"
			text += "<b>Adepts:</b> <ul>"
			for (var/datum/mind/M in R.adepts)
				text += "<li>[M.name] (<A HREF='?_src_=vars;Vars=\ref[M.current]'>VV</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[M.current]&mob=\ref[M.current]'>JMP</A>) \
					 	  (<A HREF='?_src_=holder;subtlemessage=\ref[M.current]'>SM</A>) (<A HREF='?_src_=holder;religions=renounce&mob=\ref[M.current]'>Deconvert</A>)</li>"
			text +="</ul>"
			text += "<A HREF='?src=\ref[src];religions=global_subtle_pm&rel=\ref[R]'>Subtle PM all believers</a> <br/>"
	text += "<A HREF='?src=\ref[src];religions=new'>Bus in a new religion</a> <br/>"
	usr << browse(jointext(text, ""), "window=admin2;size=300x370")
