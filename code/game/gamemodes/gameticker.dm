var/datum/controller/gameticker/ticker

/datum/controller/gameticker
	var/remaining_time = 0
	var/const/restart_timeout = 60 SECONDS //Right now, this is padded out by the end credit's audio starting time (at the time of writing this, 10 seconds)
	var/current_state = GAME_STATE_PREGAME
	var/gamestart_time = -1 //In seconds. Set by ourselves in setup()
	var/shuttledocked_time = -1 //In seconds. Set by emergency_shuttle/proc/shuttle_phase()
	var/gameend_time = -1 //In seconds. Set by ourselves in process()

	var/pregame_timeleft = 0
	var/delay_end = 0	//if set to nonzero, the round will not restart on its own

	var/hide_mode = 0
	var/datum/gamemode/mode = null
	var/event_time = null
	var/event = 0

	var/list/achievements = list()

	var/login_music			// music played in pregame lobby

	var/list/datum/mind/minds = list()//The people in the game. Used for objective tracking.

	var/Bible_icon_state	// icon_state the OFFICIAL chaplain has chosen for his bible
	var/Bible_item_state	// item_state the OFFICIAL chaplain has chosen for his bible
	var/Bible_name			// name of the bible
	var/Bible_deity_name = "Space Jesus" 	// Default deity
	var/datum/religion/chap_rel 			// Official religion of chappy
	var/list/datum/religion/religions = list() // Religion(s) in the game

	var/list/runescape_skulls = list() // Keeping track of the runescape skulls that appear over mobs when enabled

	var/random_players = 0 	// if set to nonzero, ALL players who latejoin or declare-ready join will have random appearances/genders

	var/hardcore_mode = 0	//If set to nonzero, hardcore mode is enabled (current hardcore mode features: damage from hunger)
							//Use the hardcore_mode_on macro - if(hardcore_mode_on) to_chat(user,"You're hardcore!")
	var/datum/rune_controller/rune_controller

	var/triai = 0 //Global holder for Triumvirate

	var/explosion_in_progress
	var/station_was_nuked
	var/no_life_on_station
	var/revolutionary_victory //If on, Castle can be voted if the conditions are right
	var/malfunctioning_AI_victory //If on, will play a different credits song

	var/list/datum/role/antag_types = list() // Associative list of all the antag types in the round (List[id] = roleNumber1) //Seems to be totally unused?

	// Hack
	var/obj/machinery/media/jukebox/superjuke/thematic/theme = null

	// Tag mode!
	var/tag_mode_enabled = FALSE


#define LOBBY_TICKING 1
#define LOBBY_TICKING_RESTARTED 2
/datum/controller/gameticker/proc/pregame()
	var/path = "sound/music/login/"
	if(Holiday == APRIL_FOOLS_DAY)
		path = "sound/music/aprilfools/"
	else if(SNOW_THEME)
		path = "sound/music/xmas/"
	else if(map.nameShort == "castle")
		path = "sound/music/castle/"
	var/list/filenames = flist(path)
	for(var/filename in filenames)
		if(copytext(filename, length(filename)) == "/")
			filenames -= filename
	if (map.nameShort == "lamprey")
		login_music = file("sound/music/lampreytheme.ogg")
	else if (map.nameShort == "dorf")
		login_music = file("sound/music/b12_combined_start.ogg")
	else
		login_music = file("[path][pick(filenames)]")

	send2maindiscord("**Server is loaded** and in pre-game lobby at `[config.server? "byond://[config.server]" : "byond://[world.address]:[world.port]"]`", TRUE)
	do
#ifdef GAMETICKER_LOBBY_DURATION
		var/delay_timetotal = GAMETICKER_LOBBY_DURATION
#else
		var/delay_timetotal = DEFAULT_LOBBY_TIME
#endif
		if(current_state <= GAME_STATE_PREGAME)
			pregame_timeleft = world.timeofday + delay_timetotal
			to_chat(world, "<B><span class='notice'>Welcome to the pre-game lobby!</span></B>")
			to_chat(world, "Please, setup your character and select ready. Game will start in [(delay_timetotal) / 10] seconds.")
		while(current_state <= GAME_STATE_PREGAME)
			for(var/i=0, i<10, i++)
				sleep(1)
				vote.process()
				watchdog.check_for_update()
			if (world.timeofday < (863800 -  delay_timetotal) &&  pregame_timeleft > 863950) // having a remaining time > the max of time of day is bad....
				pregame_timeleft -= 864000
			if(!going && !remaining_time)
				remaining_time = pregame_timeleft - world.timeofday
			if(going == LOBBY_TICKING_RESTARTED)
				pregame_timeleft = world.timeofday + remaining_time
				going = LOBBY_TICKING
				remaining_time = 0
			if(going && world.timeofday >= pregame_timeleft)
				current_state = GAME_STATE_SETTING_UP
	while (!setup())
#undef LOBBY_TICKING
#undef LOBBY_TICKING_RESTARTED

/datum/controller/gameticker/proc/IsThematic(var/playlist)
	if(!theme)
		return 0
	if(theme.playlist_id == playlist)
		return 1
	return 0

/datum/controller/gameticker/proc/StartThematic(var/playlist)
	if(!theme)
		theme = new(locate(1,1,map.zCentcomm))
	theme.playlist_id=playlist
	theme.playing=1
	theme.update_music()
	theme.update_icon()

/datum/controller/gameticker/proc/StopThematic()
	if(!theme)
		return
	theme.playing=0
	theme.update_music()
	theme.update_icon()

/datum/controller/gameticker/proc/setup()
	//Create and announce mode
	if(master_mode=="secret")
		hide_mode = 1
	var/list/datum/gamemode/runnable_modes
	if((master_mode=="random"))
		runnable_modes = config.get_runnable_modes()
		if (runnable_modes.len==0)
			current_state = GAME_STATE_PREGAME
			to_chat(world, "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
			return 0
		if(secret_force_mode != "secret")
			var/datum/gamemode/M = config.pick_mode(secret_force_mode)
			if(M.can_start())
				mode = config.pick_mode(secret_force_mode)
		job_master.ResetOccupations()
		if(!mode)
			mode = pickweight(runnable_modes)
		if(mode)
			var/mtype = mode.type
			mode = new mtype
	else if (master_mode=="secret")
		mode = config.pick_mode("Dynamic Mode") //Huzzah
	else
		mode = config.pick_mode(master_mode)

	//log_startup_progress("gameticker.mode is [src.mode.name].")
	mode = new mode.type
	if (!mode.can_start())
		to_chat(world, "<B>Unable to start [mode.name].</B> Not enough players, [mode.minimum_player_count] players needed. Reverting to pre-game lobby.")
		del(mode)
		current_state = GAME_STATE_PREGAME
		job_master.ResetOccupations()
		return 0

	//Configure mode and assign player to special mode stuff
	job_master.DivideOccupations() //Distribute jobs

	var/can_continue = mode.Setup()//Setup special modes
	if(!can_continue)
		current_state = GAME_STATE_PREGAME
		to_chat(world, "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby.")
		log_admin("The gamemode setup for [mode.name] errored out.")
		world.log << "The gamemode setup for [mode.name] errored out."
		del(mode)
		job_master.ResetOccupations()
		return 0

	//After antagonists have been removed from new_players in player_list, create crew
	var/list/new_characters = list()	//list of created crew for transferring
	var/list/new_players_ready = list() //unique list of people who have readied up, so we can delete mob/new_player later (ready is lost on mind transfer)
	for(var/mob/M in player_list)
		if(!istype(M, /mob/new_player/))
			var/mob/living/L = M
			L.store_position()
			M.close_spawn_windows()
			continue
		var/mob/new_player/np = M
		if(!(np.ready && np.mind && np.mind.assigned_role))
			//If they aren't ready, update new player panels so they say join instead of ready up.
			np.new_player_panel()
			continue
		var/datum/preferences/prefs = M.client.prefs
		var/key = M.key
		new_players_ready |= M
		//Create player characters
		switch(np.mind.assigned_role)
			if("Cyborg", "Mobile MMI", "AI")
				var/mob/living/silicon/S = np.create_roundstart_silicon(prefs)
				S.store_position()
				log_admin("([key]) started the game as a [S.mind.assigned_role].")
				new_characters[key] = S
			if("MODE")
				//antags aren't new players
			else
				var/mob/living/carbon/human/H = np.create_human(prefs)
				H.store_position()
				EquipCustomItems(H)
				H.update_icons()
				new_characters[key] = H
		CHECK_TICK

	var/list/clowns = list()
	var/already_an_ai = FALSE
	//Transfer characters to players
	for(var/i = 1, i <= new_characters.len, i++)
		var/mob/M = new_characters[new_characters[i]]
		var/key = new_characters[i]
		M.key = key
		if(istype(M, /mob/living/carbon/human/))
			var/mob/living/carbon/human/H = M
			job_master.PostJobSetup(H)
		//minds are linked to accounts... And accounts are linked to jobs.
		var/rank = M.mind.assigned_role
		if(rank == "Clown")
			clowns += M
		if(rank == "AI" || isAI(M))
			already_an_ai = TRUE
		var/datum/job/job = job_master.GetJob(rank)
		if(job)
			job.equip(M, job.priority) // Outfit datum.

	handle_lights()

	//delete the new_player mob for those who readied
	for(var/mob/np in new_players_ready)
		qdel(np)

	if(!already_an_ai && clowns.len >= 2 && prob(1))
		var/mob/living/carbon/human/H = pick(clowns)
		if(istype(H))
			H.make_fake_ai()

	if(ape_mode == APE_MODE_EVERYONE)	//this likely doesn't work properly, why does it only apply to humans?
		for(var/mob/living/carbon/human/player in player_list)
			player.apeify()

	if(hide_mode)
		var/list/modes = new
		for (var/datum/gamemode/M in runnable_modes)
			modes+=M.name
		modes = sortList(modes)
		if(Holiday == APRIL_FOOLS_DAY)
			to_chat(world, "<B>The current game mode is - [pick("Chivalry","Crab Battle","Bay Transfer","Dwarf Fortress","Ian Says","Admins Funhouse","Meteor","Xenoarchaeology Appreciation","Clowns versus [pick("Mimes","Assistants","the Universe")]","Dino wars","Malcolm in the Middle","Six hours of extended where one person with all the access refuses to call the shuttle while everyone else goes braindead","Monkey Study","Nations","Nations by Hasbro","High roleplay Extended","DarkRP","Babies Day out","Ians Day out","Shortstaffed medical")]!</B>")
		else
			to_chat(world, "<B>The current game mode is - Secret!</B>")
			to_chat(world, "<B>Possibilities:</B> [english_list(modes)]")

	var/list/no_records = list("MODE","Mobile MMI","Trader","AI")
	for(var/mob/living/carbon/human/player in player_list)
		if(!(player.mind.assigned_role in no_records))
			data_core.manifest_inject(player)

	mode.PostSetup() //provides antag objectives
	gamestart_time = world.time / 10
	current_state = GAME_STATE_PLAYING

#if UNIT_TESTS_AUTORUN
	run_unit_tests()
#endif

	if(config.sql_enabled)
		spawn(3000)
		statistic_cycle() // Polls population totals regularly and stores them in an SQL DB -- TLE

	//mode.Clean_Antags()
	//start_events() //handles random events and space dust.
	//new random event system is handled from the MC.

	stat_collection.round_start_time = world.realtime
	Master.RoundStart()
	wageSetup()
	post_roundstart()
	return 1

/mob/living/carbon/human/proc/make_fake_ai()
	var/obj/effect/landmark/start/S = null
	for(var/obj/effect/landmark/start/S2 in landmarks_list)
		if(S2.name == "AI")
			S = S2
			break
	if(!S)
		message_admins("[formatJumpTo(key_name(src))] tried to become a fake AI but there was no AI spawn point to do it with!")
		return
	var/turf/T = get_turf(S)
	ASSERT(T)
	forceMove(T)
	mind.assigned_role = "AI"
	var/obj/structure/curtain/open/clownai/cc = new(T)
	cc.name = src.name
	qdel(head)
	head = null
	var/obj/item/clothing/head/cardborg/cb = new(T)
	if(iswizard(src))
		cb.wizard_garb = TRUE
	equip_to_slot_or_drop(cb, slot_head)
	var/obj/item/weapon/card/id/ID = null
	var/obj/item/I = get_item_by_slot(slot_wear_id)
	if(istype(I,/obj/item/weapon/card/id))
		ID = I
	else if(istype(I,/obj/item/device/pda))
		var/obj/item/device/pda/P = I
		ID = P.id
	if(!ID)
		ID = new(T)
		ID.registered_name = src.real_name
		equip_to_slot_or_drop(ID, slot_wear_id)
	ID.assignment = "AI"
	ID.UpdateName()
	var/obj/item/device/radio/headset/H = get_item_by_slot(slot_ears)
	if(!H)
		H = new(T)
		equip_to_slot_or_drop(H, slot_ears)
	if(!iswizard(src)) // make it less unfair i guess
		var/obj/item/device/encryptionkey/ai/EK
		if(!H.keyslot1)
			H.keyslot1 = new /obj/item/device/encryptionkey/ai(H)
			EK = H.keyslot1
		else
			if(H.keyslot2)
				EK = new /obj/item/device/encryptionkey/ai(T)
			else
				H.keyslot2 = new /obj/item/device/encryptionkey/ai(H)
				EK = H.keyslot2
		EK.translate_binary = TRUE // helps too
		H.recalculateChannels()
	var/turf_found = FALSE
	for(var/dir in cardinal)
		var/turf/T2 = get_step(src,dir)
		if(T2.Cross(src)) // something that this user can pass through gets the security console
			turf_found = TRUE
			var/obj/structure/curtain/open/clownai/floor/F = new(T2)
			F.closed_state = T2.icon_state // floor look consistency
			var/obj/machinery/computer/security/SC = new(T2)
			SC.density = 0 // makes exposing them a bit easier
			break
	if(!turf_found)
		message_admins("[formatJumpTo(key_name(src))] tried to spawn a security cameras console nearby while becoming a fake AI but there was no room for one!")
	to_chat(src,"<b>You [!iswizard(src) ? "have been assigned to be" : "are now"] the station's \"AI\"!</b>")
	to_chat(src,"<b>You can open doors through the security cameras console in front of you by clicking on them. The curtains near you will also disguise you as the AI core itself. Alt-click the one on you to change the core appearance.</b>")
	if(!iswizard(src))
		to_chat(src,"<b>Since you are imitating a station AI, you are now more important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>")

/datum/controller/gameticker
	//station_explosion used to be a variable for every mob's hud. Which was a waste!
	//Now we have a general cinematic centrally held within the gameticker....far more efficient!
	var/obj/abstract/screen/cinematic = null

	//Plus it provides an easy way to make cinematics for other events. Just use this as a template :)
/datum/controller/gameticker/proc/station_explosion_cinematic(var/station_missed=0, var/override = null)
	if( cinematic )
		return	//already a cinematic in progress!

	for (var/datum/html_interface/hi in html_interfaces)
		hi.closeAll()

	//initialise our cinematic screen object
	cinematic = new(src)
	cinematic.icon = 'icons/effects/station_explosion.dmi'
	cinematic.icon_state = "station_intact"
	cinematic.plane = HUD_PLANE
	cinematic.mouse_opacity = 0
	cinematic.screen_loc = "1,0"

	for(var/mob/M in player_list)
		if(M.client)
			M.client.screen += cinematic	//show every client the cinematic
		if (istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/C = M
			C.apply_radiation(rand(50, 250),RAD_EXTERNAL)

	//Now animate the cinematic
	switch(station_missed)
		if(1)	//nuke was nearby but (mostly) missed
			if( mode && !override )
				override = mode.name
			switch( override )
				if("nuclear emergency") //Nuke wasn't on station when it blew up
					flick("intro_nuke",cinematic)
					sleep(35)
					world << sound('sound/effects/explosionfar.ogg')
					flick("station_intact_fade_red",cinematic)
					cinematic.icon_state = "summary_nukefail"
				else
					flick("intro_nuke",cinematic)
					sleep(35)
					world << sound('sound/effects/explosionfar.ogg')
					//flick("end",cinematic)


		if(2)	//nuke was nowhere nearby	//TODO: a really distant explosion animation
			world << sound('sound/effects/explosionfar.ogg')
		else	//station was destroyed
			if( mode && !override )
				override = mode.name
			switch( override )
				if("nuclear emergency") //Nuke Ops successfully bombed the station
					flick("intro_nuke",cinematic)
					sleep(35)
					flick("station_explode_fade_red",cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_nukewin"
				if("AI malfunction") //Malf (screen,explosion,summary)
					flick("intro_malf",cinematic)
					sleep(76)
					flick("station_explode_fade_red",cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_malf"
				else //Station nuked (nuke,explosion,summary)
					flick("intro_nuke",cinematic)
					sleep(35)
					flick("station_explode_fade_red", cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_selfdes"

	if(cinematic)
		qdel(cinematic)		//end the cinematic

/datum/controller/gameticker/proc/station_nolife_cinematic(var/override = null)
	if( cinematic )
		return	//already a cinematic in progress!

	for (var/datum/html_interface/hi in html_interfaces)
		hi.closeAll()

	//initialise our cinematic screen object
	cinematic = new(src)
	cinematic.icon = 'icons/effects/station_explosion.dmi'
	cinematic.icon_state = "station_nolife"
	cinematic.plane = HUD_PLANE
	cinematic.mouse_opacity = 0
	cinematic.screen_loc = "1,0"

	//actually turn everything off
	power_failure(0)

	//If its actually the end of the round, wait for it to end.
	//Otherwise if its a verb it will continue on afterwards.
	sleep(300)

	if(cinematic)
		qdel(cinematic)		//end the cinematic

	no_life_on_station = TRUE

/datum/controller/gameticker/proc/process()
	if(current_state != GAME_STATE_PLAYING)
		return 0

	mode.process()

	if(world.time > nanocoins_lastchange)
		nanocoins_lastchange = world.time + rand(3000,15000)
		nanocoins_rates = (rand(1,30))/10

	//runescape skull updates
	if (runescape_skull_display)
		for (var/entry in runescape_skulls)
			var/datum/runescape_skull_data/the_data = runescape_skulls[entry]
			the_data.process()

	/*emergency_shuttle.process()*/
	watchdog.check_for_update()

	var/force_round_end=0

	// If server's empty, force round end.
	if(watchdog.waiting && player_list.len == 0)
		force_round_end=1

	var/mode_finished = mode.check_finished() || (emergency_shuttle.location == 2 && emergency_shuttle.alert == 1) || force_round_end
	if(!explosion_in_progress && mode_finished)
		current_state = GAME_STATE_FINISHED

		spawn
			declare_completion()
			gameend_time = world.time / 10
			if(!vote.map_paths)
				vote.initiate_vote("map","The Server", popup = 1)
				var/options = jointext(vote.choices, " ")
				feedback_set("map vote choices", options)

			if (station_was_nuked)
				feedback_set_details("end_proper","nuke")
				if(!delay_end && !watchdog.waiting)
					to_chat(world, "<span class='notice'><B>Rebooting due to destruction of station in [restart_timeout/10] seconds</B></span>")
			else
				feedback_set_details("end_proper","\proper completion")
				if(!delay_end && !watchdog.waiting)
					to_chat(world, "<span class='notice'><B>Restarting in [restart_timeout/10] seconds</B></span>")

			end_credits.on_round_end()

			if(blackbox)
				if(player_list.len)
					spawn(restart_timeout + 1)
						blackbox.save_all_data_to_sql()
				else
					blackbox.save_all_data_to_sql()

			//stat_collection.Process()

			if (watchdog.waiting)
				to_chat(world, "<span class='notice'><B>Server will shut down for an automatic update in [player_list.len ? "[(restart_timeout/10)] seconds." : "a few seconds."]</B></span>")
				if(player_list.len)
					sleep(restart_timeout) //waiting for a mapvote to end
				if(!delay_end)
					watchdog.signal_ready()
				else
					to_chat(world, "<span class='notice'><B>An admin has delayed the round end</B></span>")
					delay_end = 2
			else if(!delay_end)
				sleep(restart_timeout)
				if(!delay_end)
					CallHook("Reboot",list())
					world.Reboot()
				else
					to_chat(world, "<span class='notice'><B>An admin has delayed the round end</B></span>")
					delay_end = 2
			else
				to_chat(world, "<span class='notice'><B>An admin has delayed the round end</B></span>")
				delay_end = 2
	return 1

/datum/controller/gameticker/proc/init_snake_leaderboard()
	for(var/x=1;x<=PDA_APP_SNAKEII_MAXSPEED;x++)
		snake_station_highscores += x
		snake_station_highscores[x] = list()
		snake_best_players += x
		snake_best_players[x] = list()
		var/list/templist1 = snake_station_highscores[x]
		var/list/templist2 = snake_best_players[x]
		for(var/y=1;y<=PDA_APP_SNAKEII_MAXLABYRINTH;y++)
			templist1 += y
			templist1[y] = 0
			templist2 += y
			templist2[y] = "none"

/datum/controller/gameticker/proc/init_minesweeper_leaderboard()
	minesweeper_station_highscores["beginner"] = 999
	minesweeper_station_highscores["intermediate"] = 999
	minesweeper_station_highscores["expert"] = 999
	minesweeper_best_players["beginner"] = "none"
	minesweeper_best_players["intermediate"] = "none"
	minesweeper_best_players["expert"] = "none"

/datum/controller/gameticker/proc/declare_completion()
	if(!ooc_allowed)
		to_chat(world, "<B>The OOC channel has been automatically re-enabled!</B>")
		ooc_allowed = TRUE
	score.main()
	return 1

/datum/controller/gameticker/proc/bomberman_declare_completion()
	var/icon/bomberhead = icon('icons/obj/clothing/hats.dmi', "bomberman")
	var/icon/bronze = icon('icons/obj/bomberman.dmi', "bronze")
	var/icon/silver = icon('icons/obj/bomberman.dmi', "silver")
	var/icon/gold = icon('icons/obj/bomberman.dmi', "gold")
	var/icon/platinum = icon('icons/obj/bomberman.dmi', "platinum")

	var/list/bronze_tier = list()
	for (var/mob/living/carbon/M in player_list)
		if(locate(/obj/item/weapon/bomberman/) in M)
			bronze_tier += M
	var/list/silver_tier = list()
	for (var/mob/M in bronze_tier)
		if(M.z == map.zCentcomm)
			silver_tier += M
			bronze_tier -= M
	var/list/gold_tier = list()
	for (var/mob/M in silver_tier)
		var/turf/T = get_turf(M)
		if(istype(T.loc, /area/shuttle/escape/centcom))
			gold_tier += M
			silver_tier -= M
	var/list/platinum_tier = list()
	for (var/mob/living/carbon/human/M in gold_tier)
		if(istype(M.wear_suit, /obj/item/clothing/suit/space/bomberman) && istype(M.head, /obj/item/clothing/head/helmet/space/bomberman))
			var/obj/item/clothing/suit/space/bomberman/C1 = M.wear_suit
			var/obj/item/clothing/head/helmet/space/bomberman/C2 = M.head
			if(C1.never_removed && C2.never_removed)
				platinum_tier += M
				gold_tier -= M

	var/list/special_tier = list()
	for (var/mob/living/silicon/robot/mommi/M in player_list)
		if(istype(M.head_state, /obj/item/clothing/head/helmet/space/bomberman) && istype(M.tool_state, /obj/item/weapon/bomberman/))
			special_tier += M

	var/text = {"<img class='icon' src='data:image/png;base64,[iconsouth2base64(bomberhead)]'> <font size=5><b>Bomberman Mode Results</b></font> <img class='icon' src='data:image/png;base64,[iconsouth2base64(bomberhead)]'>"}
	if(!platinum_tier.len && !gold_tier.len && !silver_tier.len && !bronze_tier.len)
		text += "<br><span class='danger'>DRAW!</span>"
	if(platinum_tier.len)
		text += {"<br><img class='icon' src='data:image/png;base64,[iconsouth2base64(platinum)]'> <b>Platinum Trophy</b> (never removed his clothes, kept his bomb dispenser until the end, and escaped on the shuttle):"}
		for (var/mob/M in platinum_tier)
			var/icon/flat = getFlatIcon(M, SOUTH, 1, 1)
			text += {"<br><img class='icon' src='data:image/png;base64,[iconsouth2base64(flat)]'> <b>[M.key]</b> as <b>[M.real_name]</b>"}
	if(gold_tier.len)
		text += {"<br><img class='icon' src='data:image/png;base64,[iconsouth2base64(gold)]'> <b>Gold Trophy</b> (kept his bomb dispenser until the end, and escaped on the shuttle):"}
		for (var/mob/M in gold_tier)
			var/icon/flat = getFlatIcon(M, SOUTH, 1, 1)
			text += {"<br><img class='icon' src='data:image/png;base64,[iconsouth2base64(flat)]'> <b>[M.key]</b> as <b>[M.real_name]</b>"}
	if(silver_tier.len)
		text += {"<br><img class='icon' src='data:image/png;base64,[iconsouth2base64(silver)]'> <b>Silver Trophy</b> (kept his bomb dispenser until the end, and escaped in a pod):"}
		for (var/mob/M in silver_tier)
			var/icon/flat = getFlatIcon(M, SOUTH, 1, 1)
			text += {"<br><img class='icon' src='data:image/png;base64,[iconsouth2base64(flat)]'> <b>[M.key]</b> as <b>[M.real_name]</b>"}
	if(bronze_tier.len)
		text += {"<br><img class='icon' src='data:image/png;base64,[iconsouth2base64(bronze)]'> <b>Bronze Trophy</b> (kept his bomb dispenser until the end):"}
		for (var/mob/M in bronze_tier)
			var/icon/flat = getFlatIcon(M, SOUTH, 1, 1)
			text += {"<br><img class='icon' src='data:image/png;base64,[iconsouth2base64(flat)]'> <b>[M.key]</b> as <b>[M.real_name]</b>"}
	if(special_tier.len)
		text += "<br><b>Special Mention</b> to those adorable MoMMis:"
		for (var/mob/M in special_tier)
			var/icon/flat = getFlatIcon(M, SOUTH, 1, 1)
			text += {"<br><img class='icon' src='data:image/png;base64,[iconsouth2base64(flat)]'> <b>[M.key]</b> as <b>[M.name]</b>"}

	return text

/datum/controller/gameticker/proc/achievement_declare_completion()
	if(!ticker.achievements.len)
		return
	var/text = "<br><FONT size = 5><b>Additionally, the following players earned achievements:</b></FONT>"
	for(var/datum/achievement/achievement in ticker.achievements)
		text += {"<br>[bicon(achievement.item)] <b>[achievement.ckey]</b> as <b>[achievement.mob_name]</b> won <b>[achievement.award_name]</b>, <b>[achievement.award_desc]!</b>"}
	return text

/datum/controller/gameticker/proc/get_all_heads()
	var/list/heads = list()
	for(var/mob/player in mob_list)
		if(player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads

/datum/controller/gameticker/proc/get_assigned_head_roles()
	var/list/roles = list()
	for(var/mob/player in mob_list)
		if(player.mind && (player.mind.assigned_role in command_positions))
			roles += player.mind.assigned_role
	return roles

/datum/controller/gameticker/proc/handle_lights()
	var/list/discrete_areas = areas.Copy()
	//Get department areas where there is a crewmember. This is used to turn on lights in occupied departments
	for(var/mob/living/player in player_list)
		discrete_areas -= get_department_areas(player)
	//Toggle lightswitches and lamps on in occupied departments
	for(var/area/DA in discrete_areas)
		for(var/obj/machinery/light_switch/LS in DA)
			LS.toggle_switch(0, playsound = FALSE)
			break
		for(var/obj/item/device/flashlight/lamp/L in DA)
			L.toggle_onoff(0)

/datum/controller/gameticker/proc/post_roundstart()
	//Handle all the cyborg syncing
	var/list/active_ais = active_ais()
	if(active_ais.len)
		for(var/mob/living/silicon/robot/R in cyborg_list)
			if(!R.connected_ai)
				R.connect_AI(select_active_ai_with_fewest_borgs())
				to_chat(R, R.connected_ai?"<b>You have synchronized with an AI. Their name will be stated shortly. Other AIs can be ignored.</b>":"<b>You are not synchronized with an AI, and therefore are not required to heed the instructions of any unless you are synced to them.</b>")
			R.lawsync()

	spawn (ROUNDSTART_LOGOUT_REPORT_TIME)
		display_roundstart_logout_report()

	spawn (rand(INTERCEPT_TIME_LOW , INTERCEPT_TIME_HIGH))
		mode.send_intercept()

	spawn()
		feedback_set_details("round_start","[time2text(world.realtime)]")
		if(ticker && ticker.mode)
			feedback_set_details("game_mode","[ticker.mode]")
		feedback_set_details("server_ip","[world.internet_address]:[world.port]")

		//Cleanup some stuff
		for(var/obj/effect/landmark/start/S in landmarks_list)
			//Deleting Startpoints but we need the ai point to AI-ize people later and the Trader point to throw new ones
			if (S.name != "AI" && S.name != "Trader")
				qdel(S)
		var/list/obj/effect/landmark/spacepod/random/L = list()
		for(var/obj/effect/landmark/spacepod/random/SS in landmarks_list)
			if(istype(SS))
				L += SS
		if(L.len)
			var/obj/effect/landmark/spacepod/random/S = pick(L)
			new /obj/spacepod/random(S.loc)
			for(var/obj in L)
				if(istype(obj, /obj/effect/landmark/spacepod/random))
					qdel(obj)

		to_chat(world, "<span class='notice'><B>Enjoy the game!</B></span>")
		//Holiday Round-start stuff	~Carn
		Holiday_Game_Start()

		if(0 == admins.len)
			send2adminirc("Round has started with no admins online.")
			send2admindiscord("**Round has started with no admins online.**", TRUE)
		send2maindiscord("**The game has started**")

		//		world << sound('sound/AI/welcome.ogg')// Skie //Out with the old, in with the new. - N3X15

	if(!config.shut_up_automatic_diagnostic_and_announcement_system)
		var/welcome_sentence=list('sound/AI/vox_login.ogg')
		welcome_sentence += pick(
			'sound/AI/vox_reminder1.ogg',
			'sound/AI/vox_reminder2.ogg',
			'sound/AI/vox_reminder3.ogg',
			'sound/AI/vox_reminder4.ogg',
			'sound/AI/vox_reminder5.ogg',
			'sound/AI/vox_reminder6.ogg',
			'sound/AI/vox_reminder7.ogg',
			'sound/AI/vox_reminder8.ogg',
			'sound/AI/vox_reminder9.ogg',
			'sound/AI/vox_reminder10.ogg',
			'sound/AI/vox_reminder11.ogg',
			'sound/AI/vox_reminder12.ogg',
			'sound/AI/vox_reminder13.ogg',
			'sound/AI/vox_reminder14.ogg',
			'sound/AI/vox_reminder15.ogg')
		for(var/sound in welcome_sentence)
			play_vox_sound(sound,map.zMainStation,null)

	create_random_orders(3) //Populate the order system so cargo has something to do

// -- Tag mode!
/datum/controller/gameticker/proc/tag_mode(var/mob/user)
	tag_mode_enabled = TRUE
	to_chat(world, "<h1>Tag mode enabled!<h1>")
	to_chat(world, "<span class='notice'>Tag mode is a 'gamemode' about a changeling clown infiltrated in a station populated by Mimes. His goal is to destroy it. Any mime killing the clown will in turn become the changeling.</span>")
	to_chat(world, "<span class='notice'>The game ends when all mimes are dead, or when the shuttle is called.</span>")
	to_chat(world, "<span class='notice'>Have fun!</span>")

	// This is /datum/forced_ruleset thing. This shit exists ONLY for pre-roundstart rulesets. Yes. This is a thing.
	var/datum/forced_ruleset/tag_mode = new
	tag_mode.name = "Tag mode"
	tag_mode.calledBy = "[key_name(user)]"
	forced_roundstart_ruleset += tag_mode
	admin_disable_rulesets = TRUE
	log_admin("Dynamic rulesets are disabled in Tag Mode.")
	message_admins("Dynamic rulesets are disabled in Tag Mode.")

/datum/controller/gameticker/proc/cancel_tag_mode(var/mob/user)
	tag_mode_enabled = FALSE
	to_chat(world, "<h1>Tag mode has been cancelled.<h1>")
	admin_disable_rulesets = FALSE
	log_admin("Dynamic rulesets have been re-enabled.")
	message_admins("Dynamic rulesets have been re-enabled.")
	forced_roundstart_ruleset = list()

/world/proc/has_round_started()
	return ticker && ticker.current_state >= GAME_STATE_PLAYING
