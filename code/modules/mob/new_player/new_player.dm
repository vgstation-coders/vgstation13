//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/mob/new_player
	var/ready = 0
	var/spawning = 0//Referenced when you want to delete the new_player later on in the code.
	var/totalPlayers = 0		 //Player counts for the Lobby tab
	var/totalPlayersReady = 0
	var/pinghop_cd = 0 //last pinged HOP

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
		if(SSdbcore.Connect())
			var/isadmin = 0
			if(src.client && src.client.holder)
				isadmin = 1
			var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT id FROM erro_poll_question WHERE [(isadmin ? "" : "adminonly = false AND")] hidden IS NULL AND Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM erro_poll_vote WHERE ckey = \":ckey\") AND id NOT IN (SELECT pollid FROM erro_poll_textreply WHERE ckey = :ckey)", list("ckey" = "\"[ckey]\""))
			if(!query.Execute())
				log_sql("Error fetching poll question: [query.ErrorMsg()]")
				qdel(query)
				return
			var/newpoll = 0
			while(query.NextRow())
				newpoll = 1
				break
			qdel(query)
			if(newpoll)
				output += "<p><b><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A> (NEW!)</b></p>"
			else
				output += "<p><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A></p>"

	output += "</div>"

	//dumb but doesn't require rewriting this menu
	if(iscluwnebanned(src))
		output = "<div align='center'><p><a href='byond://?src=\ref[src];cluwnebanned=1'>cluwne</a></p></div>"

	var/datum/browser/popup = new(src, "playersetup", "<div align='center'>New Player Options</div>", 210, 250)
	popup.set_content(output)
	popup.set_window_options("focus=0;can_close=0;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;")
	popup.open()
	return

/mob/new_player/Stat()
	..()

	if(statpanel("Status") && ticker)
		if (ticker.current_state != GAME_STATE_PREGAME)
			timeStatEntry()
		if(ticker.hide_mode)
			stat("Game Mode:", "Secret")
		else
			stat("Game Mode:", "[master_mode]")

		if(SSticker.initialized)
			if(ticker.current_state == GAME_STATE_PREGAME)
				if(going)
					stat("Time To Start:", (round(ticker.pregame_timeleft - world.timeofday) / 10)) //rounding because people freak out at decimals i guess
				else
					stat("Time To Start:", "DELAYED")
				stat("Players: [totalPlayers]", "Players Ready: [totalPlayersReady]")
				totalPlayers = 0
				totalPlayersReady = 0
				for(var/mob/new_player/player in player_list)
					stat("[player.key]", (player.ready)?("(Playing)"):(null))
					totalPlayers++
					if(player.ready)
						totalPlayersReady++
		else
			stat("Time To Start:", "LOADING...")

/mob/new_player/Topic(href, href_list[])
	//var/timestart = world.timeofday
	//testing("topic call for [usr] [href]")
	if(usr != src)
		return 0

	if(!client)
		return 0

	if(secret_check_one(src,href_list))
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

		LateChoices()
	if(href_list["cluwnebanned"])
		if(!iscluwnebanned(usr))
			to_chat(usr, "<span class='warning'>honk</span>")
			return
		if(!ticker || ticker.current_state <= GAME_STATE_PREGAME)
			to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished...</span>")
			return
		if(!client)
			return 1
		sleep(1)
		create_cluwne()

	if(href_list["predict"])
		ViewPrediction()
		return 1

	if(href_list["manifest"])
		ViewManifest()

	if(href_list["SelectedJob"])

		if(!enter_allowed)
			to_chat(usr, "<span class='notice'>There is an administrative lock on entering the game!</span>")
			return

		AttemptLateSpawn(href_list["SelectedJob"])
		return

	if(href_list["RequestPrio"])
		if(world.time <= pinghop_cd + 60 SECONDS)
			to_chat(src, "<span class='warning'>You have recently requested for heads of staff to open priority roles.</span>")
			return
		var/count_pings = 0
		var/list/priority_jobs = job_master.GetPrioritizedJobs()
		if (priority_jobs.len)
			to_chat(src, "<span class='warning'>Slots for priority roles are already opened.</span>")
			return
		to_chat(src, "<span class='bnotice'>You have requested for heads of staff to open priority roles. Please stand by.</span>")
		for(var/obj/item/device/pda/pingme in PDAs)
			if(pingme.cartridge && pingme.cartridge.fax_pings && (locate(/datum/pda_app/cart/status_display) in pingme.applications))
				//This may seem like a strange check, but it's excluding the IAA for only HOP/Cap
				playsound(pingme, "sound/effects/kirakrik.ogg", 50, 1)
				var/mob/living/L = get_holder_of_type(pingme,/mob/living)
				if(L && L.key && L.client)
					to_chat(L,"[bicon(pingme)] <span class='info'><B>Central Command is requesting guidance on job applications.</B> Please update high priority jobs at labor console.</span>")
					count_pings++
				else
					pingme.visible_message("[bicon(pingme)] *Labor Request*")
				pinghop_cd = world.time
		message_admins("[src] ([src.key]) requested high priority jobs. [count_pings ? "[count_pings]" : "<span class='danger'>No</span>"] players heard the request.")
		return

	if(href_list["preference"])
		if(client)
			client.prefs.process_link(src, href_list)

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
			if("SELECT_ALL_THAT_APPLY")
				var/id_min = text2num(href_list["minoptionid"])
				var/id_max = text2num(href_list["maxoptionid"])

				if( (id_max - id_min) > 100 )	//Basic exploit prevention
					to_chat(usr, "The option ID difference is too big. Please contact administration or the database admin.")
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["option_[optionid]"]))	//Test if this optionid was selected
						vote_on_poll(pollid, optionid, 1)

		to_chat(src, "<span class='notice'>Thank you for voting!</span>")
		client.ivoted = TRUE

/mob/new_player/proc/IsJobAvailable(rank)
	var/datum/job/job = job_master.GetJob(rank)
	if(!job)
		return 0
	if(job.current_positions >= job.get_total_positions())
		return 0
	if(jobban_isbanned(src,rank))
		return 0
	if(jobban_isbanned(src,"cluwne")) //not totally necessary but prevents someone from joining if they were cluwnebanned in the lobby
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
	log_admin("([observer.ckey]/[observer]) started the game as a ghost.")
	qdel(src)

/mob/new_player/proc/create_cluwne()
	var/mob/living/simple_animal/hostile/retaliate/cluwne/cluwne = new()
	spawning = 1
	src << sound(null, repeat = 0, wait = 0, volume = 85, channel = CHANNEL_LOBBY)
	close_spawn_windows()
	cluwne.forceMove(pick(latejoin))
	mind.transfer_to(cluwne)
	qdel(src)

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
	if(job.species_blacklist.len)
		if(job.species_blacklist.Find(client.prefs.species))
			to_chat(src, alert("[rank] is not available for [client.prefs.species]."))
			return 0

	job_master.AssignRole(src, rank, 1)

	var/mob/living/carbon/human/character = create_human(client.prefs)	//creates the human and transfers vars and mind
	if(character.client.prefs.randomslot)
		character.client.prefs.random_character_sqlite(character, character.ckey)

	var/atom/movable/what_to_move = character.locked_to || character

	var/datum/job/J = job_master.GetJob(rank)
	if(J.spawns_from_edge)
		Meteortype_Latejoin(what_to_move, rank)
	else
		// TODO:  Job-specific latejoin overrides.
		what_to_move.forceMove(pick((assistant_latejoin.len > 0 && rank == "Assistant") ? assistant_latejoin : latejoin))

	ticker.mode.latespawn(character)//can we make them a latejoin antag?

	if (!character || !character.mind) //Character got transformed in a latejoin ruleset
		if(character)
			qdel(character)
		qdel(src)
		return

	// Very hacky. Sorry about that
	if(ticker.tag_mode_enabled == TRUE)
		character.mind.assigned_role = "MODE"
		var/datum/outfit/mime/mime_outfit = new
		mime_outfit.equip(character, strip = TRUE, delete = TRUE)
		var/datum/role/tag_mode_mime/mime = new
		mime.AssignToRole(character.mind,1)
		mime.Greet(GREET_ROUNDSTART)


	if(job && character.mind.assigned_role != "MODE")
		job_master.PostJobSetup(character)
		if(job.department_prioritized) // If Department is Prioritized, equip them with priority equipment.
			job.equip(character, TRUE)
		else
			job.equip(character, job.priority) // Outfit datum.

	for(var/role in character.mind.antag_roles)
		var/datum/role/R = character.mind.antag_roles[role]
		R.OnPostSetup(TRUE) // Latejoiner post-setup.
		R.ForgeObjectives()
		R.AnnounceObjectives()

	job_master.CheckPriorityFulfilled(rank)

	var/turf/T = character.loc
	if (character.loc != T) //Offstation antag. Continue no further, as there will be no announcement or manifest injection.
		//Removal of job slot is in role/role.dm
		character.store_position()
		qdel(src)
		return

	EquipCustomItems(character)

	character.store_position()

	// WHY THE FUCK IS THIS HERE
	// FOR GOD'S SAKE USE EVENTS	TODO: use latejoin dynamic rulesets to deal with that // (they did not do that)
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

	for(var/datum/faction/F in ticker.mode.factions) /* Ensure all existing factions receive notice of the latejoin to handle what they need to. */
		register_event(/event/late_arrival, F, nameof(F::OnLateArrival())) //Wrapped in nameof() to ensure that the parent proc doesn't get called. Possibly a BYOND bug?

	if(character.mind.assigned_role != "MODE")
		if(character.mind.assigned_role != "Cyborg")
			data_core.manifest_inject(character)
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
				INVOKE_EVENT(src, /event/late_arrival, "character" = character, "rank" = rank)
			character.DormantGenes(20,10,0,0) // 20% chance of getting a dormant bad gene, in which case they also get 10% chance of getting a dormant good gene
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
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/airbag/A = new(start_point, TRUE)
		A.deploy(H)
		target = A
	else
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
		qdel(speech)

/mob/new_player/proc/LateChoices()
	var/mills = world.time // 1/10 of a second, not real milliseconds but whatever
	//var/secs = ((mills % 36000) % 600) / 10 //Not really needed, but I'll leave it here for refrence.. or something
	var/mins = (mills % 36000) / 600
	var/hours = mills / 36000

	var/list/highprior = new()
	var/list/heads = new()
	var/list/sec = new()
	var/list/eng = new()
	var/list/med = new()
	var/list/sci = new()
	var/list/cgo = new()
	var/list/civ = new()
	var/list/misc = new()

	var/dat = {"<html><head><style>
		.manifest {border-collapse:collapse;}
		.manifest td, th {border:1px solid #DEF; background-color:white; color:black; padding:.25em}
		.manifest th {height: 2em; background-color: #48C; color:white}
		.manifest tr.head th {background-color: #488}
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {background-color: #DEF}
		.manifest tr.striked td {background-color: #999}
		.manifest tr.request td {background-color: #F99}
		.manifest tr.requested_department td {background-color: #00FF00}
		.manifest th.reqhead td {background-color: #844}
		.manifest tr.reqalt td {background-color: #FCC}
		</style></head><body><center>Round Duration: [round(hours)]h [round(mins)]m<br>"}
	if(emergency_shuttle) //In case Nanotrasen decides reposess CentComm's shuttles.
		if(emergency_shuttle.direction == 2) //Shuttle is going to centcomm, not recalled
			dat += "<font color='red'><b>The station has been evacuated.</b></font><br>"
		if(emergency_shuttle.direction == 1 && emergency_shuttle.timeleft() < 300 && emergency_shuttle.alert == 0) // Emergency shuttle is past the point of no recall
			dat += "<font color='red'>The station is currently undergoing evacuation procedures.</font><br>"
		if(emergency_shuttle.direction == 1 && emergency_shuttle.alert == 1) // Crew transfer initiated
			dat += "<font color='red'>The station is currently undergoing crew transfer procedures.</font><br>"

	dat += "Choose from the following open positions:<br><table class='manifest' width='320px'><tr class='head'><th>Rank</th><th>Quantity</th><th>Active</th></tr>"
	var/color = 0
	for(var/datum/job/job in (job_master.GetPrioritizedJobs() + job_master.GetUnprioritizedJobs()))
		if(job && IsJobAvailable(job.title))
			var/active = 0
			// Only players with the job assigned and AFK for less than 10 minutes count as active
			for(var/mob/M in player_list) if(M.mind && M.client && M.mind.assigned_role == job.title && M.client.inactivity <= 10 * 60 * 10)
				active++
			if(job.priority)
				highprior[job] = active
			else if(job.title in command_positions)
				heads[job] = active
			else if(job.title in security_positions)
				sec[job] = active
			else if(job.title in engineering_positions)
				eng[job] = active
			else if(job.title in medical_positions)
				med[job] = active
			else if(job.title in science_positions)
				sci[job] = active
			else if(job.title in cargo_positions)
				cgo[job] = active
			else if(job.title in civilian_positions)
				civ[job] = active
			else
				misc[job] = active

	if(highprior.len > 0)
		dat += "<tr><th class='reqhead' colspan=3>High Priority Jobs</th></tr>"
		for(var/datum/job/job in highprior)
			if((job.species_whitelist.len && !job.species_whitelist.Find(client.prefs.species)) || (job.species_blacklist.len && job.species_blacklist.Find(client.prefs.species)))
				dat += "<tr class='striked'><td><s>[job.title]</s></td><td><s>[job.current_positions]</s></td><td><s>[highprior[job]]</s></td></tr>"
				continue

			dat += "<tr[color ? " class='reqalt'" : " class='request'"]><td><a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title]</a></td><td>[job.current_positions]</td><td>[highprior[job]]</td></tr>"
			color = !color
	else
		dat += "<tr><th class='reqhead' colspan=3><a style='color:white' href='byond://?src=\ref[src];RequestPrio=1'>Request High Priority Jobs</a></th></tr>"

	if(heads.len > 0)
		dat += "<tr><th colspan=3>Heads</th></tr>"
		for(var/datum/job/job in heads)
			if((job.species_whitelist.len && !job.species_whitelist.Find(client.prefs.species)) || (job.species_blacklist.len && job.species_blacklist.Find(client.prefs.species)))
				dat += "<tr class='striked'><td><s>[job.title]</s></td><td><s>[job.current_positions]</s></td><td><s>[highprior[job]]</s></td></tr>"
				continue
			if(job.department_prioritized)
				dat += "<tr class='requested_department'><td><a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title]</a></td><td>[job.current_positions]</td><td>[heads[job]]</td></tr>"
				continue
			dat += "<tr[color ? " class='alt'" : ""]><td><a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title]</a></td><td>[job.current_positions]</td><td>[heads[job]]</td></tr>"
			color = !color

	if(sec.len > 0)
		dat += "<tr><th colspan=3>Security</th></tr>"
		for(var/datum/job/job in sec)
			if((job.species_whitelist.len && !job.species_whitelist.Find(client.prefs.species)) || (job.species_blacklist.len && job.species_blacklist.Find(client.prefs.species)))
				dat += "<tr class='striked'><td><s>[job.title]</s></td><td><s>[job.current_positions]</s></td><td><s>[highprior[job]]</s></td></tr>"
				continue

			dat += "<tr[color ? " class='alt'" : ""]><td><a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title]</a></td><td>[job.current_positions]</td><td>[sec[job]]</td></tr>"
			color = !color

	if(eng.len > 0)
		dat += "<tr><th colspan=3>Engineering</th></tr>"
		for(var/datum/job/job in eng)
			if((job.species_whitelist.len && !job.species_whitelist.Find(client.prefs.species)) || (job.species_blacklist.len && job.species_blacklist.Find(client.prefs.species)))
				dat += "<tr class='striked'><td><s>[job.title]</s></td><td><s>[job.current_positions]</s></td><td><s>[highprior[job]]</s></td></tr>"
				continue

			dat += "<tr[color ? " class='alt'" : ""]><td><a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title]</a></td><td>[job.current_positions]</td><td>[eng[job]]</td></tr>"
			color = !color

	if(med.len > 0)
		dat += "<tr><th colspan=3>Medical</th></tr>"
		for(var/datum/job/job in med)
			if((job.species_whitelist.len && !job.species_whitelist.Find(client.prefs.species)) || (job.species_blacklist.len && job.species_blacklist.Find(client.prefs.species)))
				dat += "<tr class='striked'><td><s>[job.title]</s></td><td><s>[job.current_positions]</s></td><td><s>[highprior[job]]</s></td></tr>"
				continue

			dat += "<tr[color ? " class='alt'" : ""]><td><a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title]</a></td><td>[job.current_positions]</td><td>[med[job]]</td></tr>"
			color = !color

	if(sci.len > 0)
		dat += "<tr><th colspan=3>Science</th></tr>"
		for(var/datum/job/job in sci)
			if((job.species_whitelist.len && !job.species_whitelist.Find(client.prefs.species)) || (job.species_blacklist.len && job.species_blacklist.Find(client.prefs.species)))
				dat += "<tr class='striked'><td><s>[job.title]</s></td><td><s>[job.current_positions]</s></td><td><s>[highprior[job]]</s></td></tr>"
				continue

			dat += "<tr[color ? " class='alt'" : ""]><td><a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title]</a></td><td>[job.current_positions]</td><td>[sci[job]]</td></tr>"
			color = !color

	if(cgo.len > 0)
		dat += "<tr><th colspan=3>Cargo</th></tr>"
		for(var/datum/job/job in cgo)
			if((job.species_whitelist.len && !job.species_whitelist.Find(client.prefs.species)) || (job.species_blacklist.len && job.species_blacklist.Find(client.prefs.species)))
				dat += "<tr class='striked'><td><s>[job.title]</s></td><td><s>[job.current_positions]</s></td><td><s>[highprior[job]]</s></td></tr>"
				continue
			if(job.department_prioritized)
				dat += "<tr class='requested_department'><td><a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title]</a></td><td>[job.current_positions]</td><td>[cgo[job]]</td></tr>"
				continue
			dat += "<tr[color ? " class='alt'" : ""]><td><a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title]</a></td><td>[job.current_positions]</td><td>[cgo[job]]</td></tr>"
			color = !color

	if(civ.len > 0)
		dat += "<tr><th colspan=3>Civilian</th></tr>"
		for(var/datum/job/job in civ)
			if((job.species_whitelist.len && !job.species_whitelist.Find(client.prefs.species)) || (job.species_blacklist.len && job.species_blacklist.Find(client.prefs.species)))
				dat += "<tr class='striked'><td><s>[job.title]</s></td><td><s>[job.current_positions]</s></td><td><s>[highprior[job]]</s></td></tr>"
				continue

			dat += "<tr[color ? " class='alt'" : ""]><td><a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title]</a></td><td>[job.current_positions]</td><td>[civ[job]]</td></tr>"
			color = !color

	// misc guys
	if(misc.len > 0)
		dat += "<tr><th colspan=3>Miscellaneous</th></tr>"
		for(var/datum/job/job in misc)
			if((job.species_whitelist.len && !job.species_whitelist.Find(client.prefs.species)) || (job.species_blacklist.len && job.species_blacklist.Find(client.prefs.species)))
				dat += "<tr class='striked'><td><s>[job.title]</s></td><td><s>[job.current_positions]</s></td><td><s>[highprior[job]]</s></td></tr>"
				continue

			dat += "<tr[color ? " class='alt'" : ""]><td><a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title]</a></td><td>[job.current_positions]</td><td>[misc[job]]</td></tr>"
			color = !color

	dat += "</table>"
	dat += "</center>"
	src << browse(dat, "window=latechoices;size=360x640;can_close=1")


/mob/new_player/proc/create_human(var/datum/preferences/prefs)
	spawning = TRUE
	close_spawn_windows()

	var/mob/living/carbon/human/new_character = new(loc)
	var/datum/species/chosen_species
	var/late_join = ticker.current_state == GAME_STATE_PLAYING ? TRUE : FALSE

	if(prefs.species)
		chosen_species = all_species[prefs.species]
	if(chosen_species && (check_rights(R_ADMIN, 0) || chosen_species.flags & PLAYABLE || chosen_species.conditional_playable()))
		new_character.set_species(prefs.species)
	else
		to_chat(usr, "Your preferences had a non-playable species, so you were reverted to the default species.")

	var/datum/language/chosen_language
	if(prefs.language)
		chosen_language = all_languages["[prefs.language]"]
	if(chosen_language)
		new_character.add_language("[prefs.language]")
	if(ticker.random_players || appearance_isbanned(src)) //disabling ident bans for now
		new_character.setGender(pick(MALE, FEMALE))
		prefs.real_name = random_name(new_character.gender, new_character.species.name)
		prefs.randomize_appearance_for(new_character)
		prefs.flavor_text = ""
	else
		prefs.copy_to(new_character)

	src << sound(null, repeat = 0, wait = 0, volume = 85, channel = CHANNEL_LOBBY)// MAD JAMS cant last forever yo


	if (mind)
		mind.active = 0 // we wish to transfer the key manually
		mind.transfer_to(new_character) // won't transfer key since the mind is not active

	new_character.name = prefs.real_name
	new_character.dna.ready_dna(new_character)

	if(new_character.mind)
		new_character.mind.store_memory("<b>Your blood type is:</b> [new_character.dna.b_type]<br>")

	if(prefs.disabilities & DISABILITY_FLAG_NEARSIGHTED)
		new_character.dna.SetSEState(GLASSESBLOCK,1,1)
		new_character.disabilities |= NEARSIGHTED

	if(prefs.disabilities & DISABILITY_FLAG_VEGAN)
		new_character.dna.SetSEState(VEGANBLOCK, 1, 1)

	if(prefs.disabilities & DISABILITY_FLAG_ASTHMA)
		new_character.dna.SetSEState(ASTHMABLOCK, 1, 1)

	chosen_species = all_species[prefs.species]
	if( (prefs.disabilities & DISABILITY_FLAG_FAT) && (chosen_species.anatomy_flags & CAN_BE_FAT) )
		new_character.mutations += M_FAT
		new_character.overeatduration = 600

	if(prefs.disabilities & DISABILITY_FLAG_EPILEPTIC)
		new_character.dna.SetSEState(EPILEPSYBLOCK,1,1)
		new_character.disabilities |= EPILEPSY

	if(prefs.disabilities & DISABILITY_FLAG_DEAF)
		new_character.dna.SetSEState(DEAFBLOCK,1,1)
		new_character.sdisabilities |= DEAF

	if(prefs.disabilities & DISABILITY_FLAG_MUTE)
		new_character.dna.SetSEState(MUTEBLOCK,1,1)
		new_character.sdisabilities |= MUTE

	if(prefs.disabilities & DISABILITY_FLAG_LISP)
		new_character.dna.SetSEState(LISPBLOCK, 1, 1)

	if(prefs.disabilities & DISABILITY_FLAG_ANEMIA)
		new_character.dna.SetSEState(ANEMIABLOCK, 1, 1)

	new_character.dna.UpdateSE()
	domutcheck(new_character, null, MUTCHK_FORCED)

	var/rank = new_character.mind.assigned_role
	if(!late_join && rank != "MODE")
		var/obj/S = null
		// Find a spawn point that wasn't given to anyone
		for(var/obj/effect/landmark/start/sloc in landmarks_list)
			if(sloc.name != rank)
				continue
			if(locate(/mob/living) in sloc.loc)
				continue
			S = sloc
			break
		if(!S)
			// Find a spawn point that was already given to someone else
			for(var/obj/effect/landmark/start/sloc in landmarks_list)
				if(sloc.name != rank)
					continue
				S = sloc
				stack_trace("not enough spawn points for [rank]")
				break
		if(S)
			// Use the given spawn point
			new_character.forceMove(S.loc)
		else
			// Use the arrivals shuttle spawn point
			stack_trace("no spawn points for [rank]")
			new_character.forceMove(pick(latejoin))
		// 20% chance of getting a dormant bad gene, in which case they also get 10% chance of getting a dormant good gene
		new_character.DormantGenes(20,10,0,0)

	for(var/datum/religion/R in ticker.religions)
		if(R.converts_everyone && new_character.mind.assigned_role != "Chaplain")
			R.convert(new_character,null,TRUE,TRUE)
			break //Only autoconvert them once, and only if they aren't leading their own faith.

	if(late_join)
		new_character.key = key

	return new_character

//Basically, a stripped down version of create_human(). We don't care about DNA, prefs, species, etc. and we skip some rather lengthy setup for each step.
/mob/new_player/proc/create_roundstart_silicon(var/datum/preferences/prefs)
	var/type = mind.assigned_role
	if(type != "Cyborg" && type != "AI" && type != "Mobile MMI")
		return

	spawning = TRUE
	close_spawn_windows()
	src << sound(null, repeat = 0, wait = 0, volume = 85, channel = CHANNEL_LOBBY)

	//Find a spawnloc
	var/turf/spawn_loc
	for(var/obj/effect/landmark/start/sloc in landmarks_list)
		if (sloc.name != type)
			continue
		if (locate(/mob/living) in sloc.loc)
			if(!spawn_loc)
				spawn_loc = sloc.loc //Occupied is better than nothing
			continue
		spawn_loc = sloc.loc
		break
	if(!spawn_loc)
		spawn_loc = pick(latejoin) //If we absolutely can't find spawns
		message_admins("WARNING! Couldn't find a spawn location for a [type]. They will spawn at the arrival shuttle.")

	//Create the robot and move over prefs

	if(type == "AI")
		var/mob/living/silicon/new_character
		new_character = AIize()
		return new_character
	else
		var/mob/living/silicon/robot/new_character
		forceMove(spawn_loc)
		if(type == "Mobile MMI")
			new_character = MoMMIfy()
		else
			new_character = Robotize()
		new_character.mmi.create_identity(prefs) //Uses prefs to create a brain mob

		return new_character

/mob/new_player/proc/ViewPrediction()
	var/dat = {"<html><body>
	<h4>High Job Preferences</h4>"}
	dat += job_master.display_prediction()

	src << browse(dat, "window=manifest;size=370x420;can_close=1")

/mob/new_player/proc/ViewManifest()
	var/dat = {"<html><body>
<h4>Crew Manifest</h4>"}
	dat += data_core.get_manifest(OOC = 1)

	src << browse(dat, "window=manifest;size=370x420;can_close=1")

/mob/new_player/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	return 0


/mob/proc/close_spawn_windows()
	src << browse(null, "window=latechoices") //closes late choices window
	src << browse(null, "window=playersetup") //closes the player setup window

/mob/new_player/cultify()
	return

/mob/new_player/say(message, datum/language/speaking, atom/movable/radio, class)
	if(client)
		client.ooc(message)
