//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/mob/new_player
	var/ready = 0
	var/spawning = 0//Referenced when you want to delete the new_player later on in the code.
	var/totalPlayers = 0		 //Player counts for the Lobby tab
	var/totalPlayersReady = 0

	flags = NONE

	invisibility = 101

	density = 0
	stat = 2
	canmove = 0

	anchored = 1	//  don't get pushed around

/mob/new_player/verb/new_player_panel()
	set src = usr
	new_player_panel_proc()


/mob/new_player/proc/new_player_panel_proc()
	var/output = "<div align='center'>"

	output += {"<p><a href='byond://?src=\ref[src];show_preferences=1'>Setup Character</A></p>"}
	if(!ticker || ticker.current_state <= GAME_STATE_PREGAME)
		if(job_master)
			output += "<a href='byond://?src=\ref[src];predict=1'>Manifest Prediction (Unreliable)</A><br>"
		if(!ready)
			output += "<p><a href='byond://?src=\ref[src];ready=1'>Declare Ready</A></p>"
		else
			output += "<p><b>You are ready</b> (<a href='byond://?src=\ref[src];ready=2'>Cancel</A>)</p>"
	else
		ready = 0 // prevent setup character issues
		output += {"<a href='byond://?src=\ref[src];manifest=1'>View the Crew Manifest</A><br>
			<p><a href='byond://?src=\ref[src];late_join=1'>Join Game!</A></p>"}

	output += "<p><a href='byond://?src=\ref[src];observe=1'>Observe</A></p>"
	if(!IsGuestKey(src.key))
		establish_db_connection()

		if(dbcon.IsConnected())
			var/isadmin = 0
			if(src.client && src.client.holder)
				isadmin = 1
			var/DBQuery/query = dbcon.NewQuery("SELECT id FROM erro_poll_question WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM erro_poll_vote WHERE ckey = \"[ckey]\") AND id NOT IN (SELECT pollid FROM erro_poll_textreply WHERE ckey = \"[ckey]\")")
			query.Execute()
			var/newpoll = 0
			while(query.NextRow())
				newpoll = 1
				break

			if(newpoll)
				output += "<p><b><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A> (NEW!)</b></p>"
			else
				output += "<p><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A></p>"

	output += "</div>"

	var/datum/browser/popup = new(src, "playersetup", "<div align='center'>New Player Options</div>", 210, 250)
	popup.set_content(output)
	popup.set_window_options("focus=0;can_close=0;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;")
	popup.open()
	return

/mob/new_player/Stat()
	..()

	if(statpanel("Status") && ticker)
		if (ticker.current_state != GAME_STATE_PREGAME)
			stat("Station Time:", "[worldtime2text()]")
		if(ticker.hide_mode)
			stat("Game Mode:", "Secret")
		else
			stat("Game Mode:", "[master_mode]")

		if(SSticker.initialized)
			if((ticker.current_state == GAME_STATE_PREGAME) && going)
				stat("Time To Start:", (round(ticker.pregame_timeleft - world.timeofday) / 10)) //rounding because people freak out at decimals i guess
			if((ticker.current_state == GAME_STATE_PREGAME) && !going)
				stat("Time To Start:", "DELAYED")
		else
			stat("Time To Start:", "LOADING...")

		if(SSticker.initialized && ticker.current_state == GAME_STATE_PREGAME)
			stat("Players: [totalPlayers]", "Players Ready: [totalPlayersReady]")
			totalPlayers = 0
			totalPlayersReady = 0
			for(var/mob/new_player/player in player_list)
				stat("[player.key]", (player.ready)?("(Playing)"):(null))
				totalPlayers++
				if(player.ready)
					totalPlayersReady++

/mob/new_player/Topic(href, href_list[])
	//var/timestart = world.timeofday
	//testing("topic call for [usr] [href]")
	if(usr != src)
		return 0

	if(!client)
		return 0

	if(href_list["show_preferences"])
		if(!client.prefs.saveloaded)
			to_chat(usr, "<span class='warning'>Your character preferences have not yet loaded.</span>")
			return
		client.prefs.ShowChoices(src)
		return 1

	if(href_list["ready"])
		if(!client.prefs.saveloaded)
			to_chat(usr, "<span class='warning'>Your character preferences have not yet loaded.</span>")
			return
		switch(text2num(href_list["ready"]))
			if(1)
				ready = 1
			if(2)
				ready = 0
		to_chat(usr, "<span class='recruit'>You [ready ? "have declared ready" : "have unreadied"].</span>")
		new_player_panel_proc()
		//testing("[usr] topic call took [(world.timeofday - timestart)/10] seconds")
		return 1

	if(href_list["refresh"])
		src << browse(null, "window=playersetup") //closes the player setup window
		new_player_panel_proc()

	if(href_list["observe"])
		if(!client.prefs.saveloaded)
			to_chat(usr, "<span class='warning'>Your character preferences have not yet loaded.</span>")
			return
		if(alert(src,"Are you sure you wish to observe? You will not be able to play this round!","Player Setup","Yes","No") == "Yes")
			if(!client)
				return 1
			sleep(1)
			create_observer()

			return 1

	if(href_list["late_join"])
		if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
			to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished...</span>")
			return

		if(client.prefs.species != "Human")

			if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
				to_chat(src, alert("You are currently not whitelisted to play [client.prefs.species]."))
				return 0

		LateChoices()
	if(href_list["predict"])
		var/dat = {"<html><body>
		<h4>High Job Preferences</h4>"}
		dat += job_master.display_prediction()

		src << browse(dat, "window=manifest;size=400x420;can_close=1")
		return 1
	if(href_list["manifest"])
		ViewManifest()

	if(href_list["SelectedJob"])

		if(!enter_allowed)
			to_chat(usr, "<span class='notice'>There is an administrative lock on entering the game!</span>")
			return

		if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
			to_chat(src, alert("You are currently not whitelisted to play [client.prefs.species]."))
			return 0

		AttemptLateSpawn(href_list["SelectedJob"])
		return

	if(!ready && href_list["preference"])
		if(client)
			client.prefs.process_link(src, href_list)
	else if(!href_list["late_join"])
		new_player_panel()

	if(href_list["showpoll"])

		handle_player_polling()
		return

	if(href_list["pollid"])

		var/pollid = href_list["pollid"]
		if(istext(pollid))
			pollid = text2num(pollid)
		if(isnum(pollid))
			src.poll_player(pollid)
		return

	if(href_list["pollresult"])

		if(!config.poll_results_url)
			return
		if(alert("This will open the results page in your browser. Are you sure?",,"Yes","No")=="No")
			return
		var/pollid = href_list["pollresult"]
		var/link = "[config.poll_results_url]/[pollid]"
		src << link(link)

	if(href_list["votepollid"] && href_list["votetype"])
		var/pollid = text2num(href_list["votepollid"])
		var/votetype = href_list["votetype"]
		switch(votetype)
			if("OPTION")
				var/optionid = text2num(href_list["voteoptionid"])
				vote_on_poll(pollid, optionid)
			if("TEXT")
				var/replytext = href_list["replytext"]
				log_text_poll_reply(pollid, replytext)
			if("NUMVAL")
				var/id_min = text2num(href_list["minid"])
				var/id_max = text2num(href_list["maxid"])

				if( (id_max - id_min) > 100 )	//Basic exploit prevention
					to_chat(usr, "The option ID difference is too big. Please contact administration or the database admin.")
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["o[optionid]"]))	//Test if this optionid was replied to
						var/rating
						if(href_list["o[optionid]"] == "abstain")
							rating = null
						else
							rating = text2num(href_list["o[optionid]"])
							if(!isnum(rating))
								return

						vote_on_numval_poll(pollid, optionid, rating)
			if("MULTICHOICE")
				var/id_min = text2num(href_list["minoptionid"])
				var/id_max = text2num(href_list["maxoptionid"])

				if( (id_max - id_min) > 100 )	//Basic exploit prevention
					to_chat(usr, "The option ID difference is too big. Please contact administration or the database admin.")
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["option_[optionid]"]))	//Test if this optionid was selected
						vote_on_poll(pollid, optionid, 1)

/mob/new_player/proc/IsJobAvailable(rank)
	var/datum/job/job = job_master.GetJob(rank)
	if(!job)
		return 0
	if(job.current_positions >= job.get_total_positions())
		return 0
	if(jobban_isbanned(src,rank))
		return 0
	if(!job.player_old_enough(src.client))
		return 0
	. = 1
	return

/mob/new_player/proc/create_observer()
	var/mob/dead/observer/observer = new()
	spawning = 1
	src << sound(null, repeat = 0, wait = 0, volume = 85, channel = CHANNEL_LOBBY) // MAD JAMS cant last forever yo


	observer.started_as_observer = 1
	close_spawn_windows()
	var/obj/O = locate("landmark*Observer-Start")
	to_chat(src, "<span class='notice'>Now teleporting.</span>")
	observer.forceMove(O.loc)
	observer.timeofdeath = world.time // Set the time of death so that the respawn timer works correctly.

	// Has to be done here so we can get our random icon.
	if(client.prefs.be_random_body)
		client.prefs.randomize_appearance_for() // No argument means just the prefs are randomized.
	client.prefs.update_preview_icon(1)
	observer.icon = client.prefs.preview_icon
	observer.alpha = 127

	if(client.prefs.be_random_name)
		client.prefs.real_name = random_name(client.prefs.gender,client.prefs.species)
	observer.real_name = client.prefs.real_name
	observer.name = observer.real_name
	if(!client.holder && !config.antag_hud_allowed)           // For new ghosts we remove the verb from even showing up if it's not allowed.
		observer.verbs -= /mob/dead/observer/verb/toggle_antagHUD        // Poor guys, don't know what they are missing!
	mind.transfer_to(observer)
	qdel(src)

/mob/new_player/proc/FuckUpGenes(var/mob/living/carbon/human/H)
	// 20% of players have bad genetic mutations.
	if(prob(20))
		H.dna.GiveRandomSE(notflags = GENE_UNNATURAL,genetype = GENETYPE_BAD)
		if(prob(10)) // 10% of those have a good mut.
			H.dna.GiveRandomSE(notflags = GENE_UNNATURAL,genetype = GENETYPE_GOOD)

/mob/new_player/proc/DiseaseCarrierCheck(var/mob/living/carbon/human/H)
	// 5% of players are joining the station with some minor disease
	if(prob(5))
		var/virus_choice = pick(subtypesof(/datum/disease2/disease))
		var/datum/disease2/disease/D = new virus_choice

		var/list/anti = list(
			ANTIGEN_BLOOD	= 1,
			ANTIGEN_COMMON	= 1,
			ANTIGEN_RARE	= 0,
			ANTIGEN_ALIEN	= 0,
			)
		var/list/bad = list(
			EFFECT_DANGER_HELPFUL	= 1,
			EFFECT_DANGER_FLAVOR	= 8,
			EFFECT_DANGER_ANNOYING	= 1,
			EFFECT_DANGER_HINDRANCE	= 0,
			EFFECT_DANGER_HARMFUL	= 0,
			EFFECT_DANGER_DEADLY	= 0,
			)
		D.origin = "New Player"

		D.makerandom(list(30,50),list(0,50),anti,bad,null)

		D.log += "<br />[timestamp()] Infected [key_name(H)]"
		H.virus2["[D.uniqueID]-[D.subID]"] = D

		D.AddToGoggleView(H)

/mob/new_player/proc/AttemptLateSpawn(rank)
	if (src != usr)
		return 0
	if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished...</span>")
		return 0
	if(!enter_allowed)
		to_chat(usr, "<span class='notice'>There is an administrative lock on entering the game!</span>")
		return 0
	if(!IsJobAvailable(rank))
		to_chat(src, alert("[rank] is not available. Please try another."))
		return 0
	var/datum/job/job = job_master.GetJob(rank)
	if(job.species_whitelist.len)
		if(!job.species_whitelist.Find(client.prefs.species))
			to_chat(src, alert("[rank] is not available for [client.prefs.species]."))
			return 0

	job_master.AssignRole(src, rank, 1)

	ticker.mode.latespawn(src)//can we make them a latejoin antag?

	var/mob/living/carbon/human/character = create_character()	//creates the human and transfers vars and mind
	if(character.client.prefs.randomslot)
		character.client.prefs.random_character_sqlite(character, character.ckey)

	if(character.mind.assigned_role != "MODE")
		job_master.EquipRank(character, rank, 1) //Must come before OnPostSetup for uplinks

	job_master.CheckPriorityFulfilled(rank)

	var/turf/T = character.loc
	for(var/role in character.mind.antag_roles)
		var/datum/role/R = character.mind.antag_roles[role]
		R.OnPostSetup()
		R.ForgeObjectives()
		R.AnnounceObjectives()

	if (character.loc != T) //Offstation antag. Continue no further, as there will be no announcement or manifest injection.
		//Removal of job slot is in role/role.dm
		character.store_position()
		qdel(src)
		return


	EquipCustomItems(character)

	var/atom/movable/what_to_move = character.locked_to || character

	var/datum/job/J = job_master.GetJob(rank)
	if(J.spawns_from_edge)
		Meteortype_Latejoin(what_to_move, rank)
	else
		// TODO:  Job-specific latejoin overrides.
		what_to_move.forceMove(pick((assistant_latejoin.len > 0 && rank == "Assistant") ? assistant_latejoin : latejoin))

	character.store_position()

	// WHY THE FUCK IS THIS HERE
	// FOR GOD'S SAKE USE EVENTS	TODO: use latejoin dynamic rulesets to deal with that
	if(bomberman_mode)
		character.client << sound('sound/bomberman/start.ogg')
		if(character.wear_suit)
			var/obj/item/O = character.wear_suit
			character.u_equip(O,1)
			O.forceMove(character.loc)
			//O.dropped(character)
		if(character.head)
			var/obj/item/O = character.head
			character.u_equip(O,1)
			O.forceMove(character.loc)
			//O.dropped(character)
		character.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/bomberman(character), slot_head)
		character.equip_to_slot_or_del(new /obj/item/clothing/suit/space/bomberman(character), slot_wear_suit)
		character.equip_to_slot_or_del(new /obj/item/weapon/bomberman/(character), slot_s_store)
		character.update_icons()
		to_chat(character, "<span class='notice'>Tip: Use the BBD in your suit's pocket to place bombs.</span>")
		to_chat(character, "<span class='notice'>Try to keep your BBD and escape this hell hole alive!</span>")

	if(character.mind.assigned_role != "MODE")
		if(character.mind.assigned_role != "Cyborg")
			data_core.manifest_inject(character)
			ticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
			if(character.mind.assigned_role == "Trader")
				//If we're a trader, instead send a message to PDAs with the trader cartridge
				for (var/obj/item/device/pda/P in PDAs)
					if(istype(P.cartridge,/obj/item/weapon/cartridge/trader))
						var/mob/living/L = get_holder_of_type(P,/mob/living)
						if(L)
							L.show_message("[bicon(P)] <b>Message from U*{*,*;8AYE1*;*;*a;1 (0x034ac15e), </b>\"Caw. Cousin [character.real_name] detected in sector.\".", 2)
				for(var/mob/dead/observer/M in player_list)
					if(M.stat == DEAD && M.client)
						handle_render(M,"<span class='game say'>PDA Message - <span class='name'>Trader [character.real_name] has arrived in the sector from space.</span></span>",character) //handle_render generates a Follow link
			else
				AnnounceArrival(character, rank)
				CallHook("Arrival", list("character" = character, "rank" = rank))
			FuckUpGenes(character)
			DiseaseCarrierCheck(character)
		else
			character.Robotize()
	qdel(src)

/proc/Meteortype_Latejoin(var/atom/movable/target, var/rank)
	var/obj/effect/landmark/start/endpoint = null
	for(var/obj/effect/landmark/start/S in landmarks_list)
		if(S.name == rank)
			endpoint = S
			break
	if(!endpoint)
		message_admins("ERROR - NO VALID TRADER SPAWN. Here's what I've got: [json_encode(landmarks_list)]")
		//Error! We have no targetable spawn!
		return
	var/turf/start_point = locate(TRANSITIONEDGE + 2, rand((TRANSITIONEDGE + 2), world.maxy - (TRANSITIONEDGE + 2)), endpoint.z)
	target.forceMove(start_point)
	target.throw_at(endpoint)


/proc/AnnounceArrival(var/mob/living/carbon/human/character, var/rank)
	if (ticker.current_state == GAME_STATE_PLAYING)
		if(character.mind.role_alt_title)
			rank = character.mind.role_alt_title
		var/datum/speech/speech = announcement_intercom.create_speech("[character.real_name],[rank ? " [rank]," : " visitor," ] has arrived on the station.", transmitter=announcement_intercom)
		speech.speaker = character
		speech.name = "Arrivals Announcement Computer"
		speech.job = "Automated Announcement"
		speech.as_name = "Arrivals Announcement Computer"
		speech.frequency = COMMON_FREQ

		Broadcast_Message(speech, vmask=null, data=0, compression=0, level=list(0,1))
		returnToPool(speech)

/mob/new_player/proc/LateChoices()
	var/mills = world.time // 1/10 of a second, not real milliseconds but whatever
	//var/secs = ((mills % 36000) % 600) / 10 //Not really needed, but I'll leave it here for refrence.. or something
	var/mins = (mills % 36000) / 600
	var/hours = mills / 36000


	var/dat = {"<html><body><center>
Round Duration: [round(hours)]h [round(mins)]m<br>"}
	if(emergency_shuttle) //In case Nanotrasen decides reposess CentComm's shuttles.
		if(emergency_shuttle.direction == 2) //Shuttle is going to centcomm, not recalled
			dat += "<font color='red'><b>The station has been evacuated.</b></font><br>"
		if(emergency_shuttle.direction == 1 && emergency_shuttle.timeleft() < 300 && emergency_shuttle.alert == 0) // Emergency shuttle is past the point of no recall
			dat += "<font color='red'>The station is currently undergoing evacuation procedures.</font><br>"
		if(emergency_shuttle.direction == 1 && emergency_shuttle.alert == 1) // Crew transfer initiated
			dat += "<font color='red'>The station is currently undergoing crew transfer procedures.</font><br>"

	dat += "Choose from the following open positions:<br>"
	for(var/datum/job/job in (job_master.GetPrioritizedJobs() + job_master.GetUnprioritizedJobs()))
		if(job && IsJobAvailable(job.title))
			var/active = 0
			// Only players with the job assigned and AFK for less than 10 minutes count as active
			for(var/mob/M in player_list) if(M.mind && M.client && M.mind.assigned_role == job.title && M.client.inactivity <= 10 * 60 * 10)
				active++
			if(job.species_whitelist.len)
				if(!job.species_whitelist.Find(client.prefs.species))
					dat += "<s>[job.title] ([job.current_positions]) (Active: [active])</s><br>"
					continue

			if(job.priority)
				dat += "<a style='color:red' href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions]) (Active: [active]) (Requested!)</a><br>"
			else
				dat += "<a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions]) (Active: [active])</a><br>"

	dat += "</center>"
	src << browse(dat, "window=latechoices;size=350x640;can_close=1")


/mob/new_player/proc/create_character()
	spawning = 1
	close_spawn_windows()

	var/mob/living/carbon/human/new_character = new(loc)

	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]
	if(chosen_species)
		if(is_alien_whitelisted(src, client.prefs.species) || !config.usealienwhitelist || !(chosen_species.flags & WHITELISTED) || (client && client.holder && (client.holder.rights & R_ADMIN)) )// Have to recheck admin due to no usr at roundstart. Latejoins are fine though.
			new_character.set_species(client.prefs.species)
			//if(chosen_species.language)
				//new_character.add_language(chosen_species.language)

	var/datum/language/chosen_language
	if(client.prefs.language)
		chosen_language = all_languages["[client.prefs.language]"]
	if(chosen_language)
		if(is_alien_whitelisted(src, client.prefs.language) || !config.usealienwhitelist || !(chosen_language.flags & WHITELISTED) )
			new_character.add_language("[client.prefs.language]")
	if(ticker.random_players || appearance_isbanned(src)) //disabling ident bans for now
		new_character.setGender(pick(MALE, FEMALE))
		client.prefs.real_name = random_name(new_character.gender, new_character.species.name)
		client.prefs.randomize_appearance_for(new_character)
		client.prefs.flavor_text = ""
	else
		client.prefs.copy_to(new_character)

	src << sound(null, repeat = 0, wait = 0, volume = 85, channel = CHANNEL_LOBBY)// MAD JAMS cant last forever yo


	if (mind)
		mind.active = 0 // we wish to transfer the key manually
		mind.original = new_character
		mind.transfer_to(new_character) // won't transfer key since the mind is not active

	new_character.name = real_name
	new_character.dna.ready_dna(new_character)

	if(new_character.mind)
		new_character.mind.store_memory("<b>Your blood type is:</b> [new_character.dna.b_type]<br>")

	if(client.prefs.disabilities & DISABILITY_FLAG_NEARSIGHTED)
		new_character.dna.SetSEState(GLASSESBLOCK,1,1)
		new_character.disabilities |= NEARSIGHTED

	if(client.prefs.disabilities & DISABILITY_FLAG_VEGAN)
		new_character.dna.SetSEState(VEGANBLOCK, 1, 1)

	if(client.prefs.disabilities & DISABILITY_FLAG_ASTHMA)
		new_character.dna.SetSEState(ASTHMABLOCK, 1, 1)

	chosen_species = all_species[client.prefs.species]
	if( (client.prefs.disabilities & DISABILITY_FLAG_FAT) && (chosen_species.anatomy_flags & CAN_BE_FAT) )
		new_character.mutations += M_FAT
		new_character.mutations += M_OBESITY
		new_character.overeatduration = 600

	if(client.prefs.disabilities & DISABILITY_FLAG_EPILEPTIC)
		new_character.dna.SetSEState(EPILEPSYBLOCK,1,1)
		new_character.disabilities |= EPILEPSY

	if(client.prefs.disabilities & DISABILITY_FLAG_DEAF)
		new_character.dna.SetSEState(DEAFBLOCK,1,1)
		new_character.sdisabilities |= DEAF

	if(client.prefs.disabilities & DISABILITY_FLAG_MUTE)
		new_character.dna.SetSEState(MUTEBLOCK,1,1)
		new_character.sdisabilities |= MUTE

	new_character.dna.UpdateSE()
	domutcheck(new_character, null, MUTCHK_FORCED)

	new_character.key = key		//Manually transfer the key to log them in

	for(var/datum/religion/R in ticker.religions)
		if(R.converts_everyone && new_character.mind.assigned_role != "Chaplain")
			R.convert(new_character,null,TRUE,TRUE)
			break //Only autoconvert them once, and only if they aren't leading their own faith.

	return new_character

//Basically, a stripped down version of create_character(). We don't care about DNA, prefs, species, etc. and we skip some rather lengthy setup for each step.
/mob/new_player/proc/create_roundstart_cyborg()
	//End lobby
	spawning = 1
	close_spawn_windows()
	src << sound(null, repeat = 0, wait = 0, volume = 85, channel = CHANNEL_LOBBY)

	//Find a spawnloc
	var/turf/spawn_loc
	for(var/obj/effect/landmark/start/sloc in landmarks_list)
		if (sloc.name != "Cyborg")
			continue
		if (locate(/mob/living) in sloc.loc)
			if(!spawn_loc)
				spawn_loc = sloc.loc //Occupied is better than nothing
			continue
		spawn_loc = sloc.loc
		break
	if(!spawn_loc)
		spawn_loc = pick(latejoin) //If we absolutely can't find spawns
		message_admins("WARNING! Couldn't find a spawn location for a cyborg. They will spawn at the arrival shuttle.")

	//Create the robot and move over prefs
	var/mob/living/silicon/robot/new_character = new(spawn_loc)
	new_character.mmi = new /obj/item/device/mmi(new_character)
	new_character.mmi.create_identity(client.prefs) //Uses prefs to create a brain mob

	//Handles transferring the mind and key manually.
	if (mind)
		mind.active = 0 //This prevents mind.transfer_to from setting new_character.key = key
		mind.original = new_character
		mind.transfer_to(new_character)
	new_character.key = key //Do this after. For reasons known only to oldcoders.
	spawn()
		new_character.Namepick()
	return new_character

/mob/new_player/proc/ViewManifest()


	var/dat = {"<html><body>
<h4>Crew Manifest</h4>"}
	dat += data_core.get_manifest(OOC = 1)

	src << browse(dat, "window=manifest;size=370x420;can_close=1")

/mob/new_player/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	return 0


/mob/new_player/proc/close_spawn_windows()
	src << browse(null, "window=latechoices") //closes late choices window
	src << browse(null, "window=playersetup") //closes the player setup window

/mob/new_player/cultify()
	return
