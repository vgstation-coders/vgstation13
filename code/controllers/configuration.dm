/datum/configuration
	var/server_name = null				// server name (for world name / status)
	var/server_suffix = 0				// generate numeric suffix based on server port
	var/world_style_config = world_style

	var/nudge_script_path = "nudge.py"  // where the nudge.py script is located

	var/localhost_autoadmin = 0			// Give local host clients +HOST upon joining

	var/log_ooc = 0						// log OOC channel
	var/tts_server = ""					// TTS Server
	var/log_access = 0					// log login/logout
	var/log_say = 0						// log client say
	var/log_admin = 0					// log admin actions
	var/log_admin_only = FALSE
	var/log_debug = 1					// log debug output
	var/log_game = 0					// log game events
	var/log_vote = 0					// log voting
	var/log_whisper = 0					// log client whisper
	var/log_emote = 0					// log emotes
	var/log_attack = 0					// log attack messages
	var/log_adminchat = 0				// log admin chat messages
	var/log_adminwarn = 0				// log warnings admins get about bomb construction and such
	var/log_adminghost = 1				// log warnings admins get about bomb construction and such
	var/log_pda = 0						// log pda messages
	var/log_rc = 0						// log requests consoles
	var/log_hrefs = 0					// logs all links clicked in-game. Could be used for debugging and tracking down exploits
	var/log_runtimes = 0                // Logs all runtimes.
	var/sql_enabled = 1					// for sql switching
	var/allow_admin_ooccolor = 0		// Allows admins with relevant permissions to have their own ooc colour
	var/allow_vote_restart = 0 			// allow votes to restart
	var/allow_vote_mode = 0				// allow votes to change mode
	var/allow_admin_jump = 1			// allows admin jumping
	var/allow_admin_spawning = 1		// allows admin item spawning
	var/allow_admin_rev = 1				// allows admin revives
	var/vote_delay = 6000				// minimum time between voting sessions (deciseconds, 10 minute default)
	var/vote_period = 600				// length of voting period (deciseconds, default 1 minute)
	var/vote_no_default = 0				// vote does not default to nochange/norestart (tbi)
	var/vote_no_dead = 0				// dead people can't vote (tbi)
//	var/enable_authentication = 0		// goon authentication
	var/del_new_on_log = 1				// del's new players if they log before they spawn in
	var/feature_object_spell_system = 0 //spawns a spellbook which gives object-type spells instead of verb-type spells for the wizard
	var/traitor_scaling = 0 			//if amount of traitors scales based on amount of players
	var/protect_roles_from_antagonist = 0// If security and such can be tratior/cult/other
	var/continous_rounds = 0			// Gamemodes which end instantly will instead keep on going until the round ends by escape shuttle or nuke.
	var/allow_Metadata = 0				// Metadata is supported.
	var/popup_admin_pm = 0				//adminPMs to non-admins show in a pop-up 'reply' window when set to 1.
	var/Ticklag = 0.9
	var/socket_talk	= 0					// use socket_talk to communicate with other processes
	var/list/resource_urls = null
	var/antag_hud_allowed = 0			// Ghosts can turn on Antagovision to see a HUD of who is the bad guys this round.
	var/antag_hud_restricted = 0                    // Ghosts that turn on Antagovision cannot rejoin the round.
	var/list/mode_names = list()
	var/list/modes = list()				// allowed modes
	var/list/votable_modes = list()		// votable modes
	var/list/probabilities = list()		// relative probability of each mode
	var/humans_need_surnames = 0
	var/allow_random_events = 0			// enables random events mid-round when set to 1
	var/allow_ai = 1					// allow ai job
	var/hostedby = null
	var/respawn = 1
	var/respawn_delay=30
	var/respawn_as_mommi = 0
	var/respawn_as_mouse = 1
	var/guest_jobban = 1
	var/usewhitelist = 0
	var/kick_inactive = 0				//force disconnect for inactive players
	var/load_jobs_from_txt = 0
	var/ToRban = 0
	var/automute_on = 0					//enables automuting/spam prevention
	var/jobs_have_minimal_access = 0	//determines whether jobs use minimal access or expanded access.
	var/copy_logs = null

	var/cult_ghostwriter = 1               //Allows ghosts to write in blood in cult rounds...
	var/cult_ghostwriter_req_cultists = 10 //...so long as this many cultists are active.

	var/borer_takeover_immediately = 0

	var/disable_player_mice = 0
	var/uneducated_mice = 0 //Set to 1 to prevent newly-spawned mice from understanding human speech

	var/usealienwhitelist = 0
	var/limitalienplayers = 0
	var/alien_to_human_ratio = 0.5

	//used to determine if cyborgs/AI can speak
	var/silent_ai = 0
	var/silent_borg = 0

	var/server
	var/banappeals
	var/wikiurl = "http://baystation12.net/wiki/index.php?title=Main_Page"
	var/vgws_base_url = "http://ss13.moe" // No hanging slashes.
	var/vgws_ip = "198.245.63.50" // IP address in the `world.Topic()` call when the vgws sends a request over TCP.
	var/forumurl = "http://baystation12.net/forums/"
	var/poll_results_url

	var/media_base_url = "" // http://ss13.nexisonline.net/media
	var/media_secret_key = "" // Random string

	//Alert level description
	var/alert_desc_green = "All threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced."
	var/alert_desc_blue_upto = "The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible, random searches are permitted."
	var/alert_desc_blue_downto = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."
	var/alert_desc_red_upto = "There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."
	var/alert_desc_red_downto = "The self-destruct mechanism has been deactivated, there is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised."
	var/alert_desc_delta = "The station's self-destruct mechanism has been engaged. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill."

	var/forbid_singulo_possession = 0

	//game_options.txt configs

	var/health_threshold_softcrit = 0
	var/health_threshold_crit = 0
	var/health_threshold_dead = -100
	var/burn_damage_ash = 0

	var/organ_health_multiplier = 1
	var/organ_regeneration_multiplier = 1

	var/bones_can_break = 0
	var/limbs_can_break = 0

	var/voice_noises = 0

	var/revival_pod_plants = 1
	var/revival_cloning = 1
	var/revival_brain_life = -1

	//Used for modifying movement speed for mobs.
	//Unversal modifiers
	var/run_speed = 0
	var/walk_speed = 0

	var/admin_legacy_system = 0	//Defines whether the server uses the legacy admin system with admins.txt or the SQL system. Config option in config.txt
	var/ban_legacy_system = 0	//Defines whether the server uses the legacy banning system with the files in /data or the SQL system. Config option in config.txt
	var/use_age_restriction_for_jobs = 0 //Do jobs use account age restrictions? --requires database

	var/simultaneous_pm_warning_timeout = 100

	var/use_recursive_explosions //Defines whether the server uses recursive or circular explosions.

	var/assistant_maint = 0 //Do assistants get maint access?
	var/gateway_delay = 18000 //How long the gateway takes before it activates. Default is half an hour.
	var/ghost_interaction = 0

	var/comms_password = ""
	var/paperwork_library = 0 //use the library DLL.

	var/use_irc_bot = 0
	var/irc_bot_host = "localhost"
	var/irc_bot_port = 45678
	var/irc_bot_server_id = 45678
	var/python_path = "" //Path to the python executable.  Defaults to "python" on windows and "/usr/bin/env python2" on unix

	var/assistantlimit = 0 //enables assistant limiting
	var/assistantratio = 2 //how many assistants to security members

	var/emag_energy = -1
	var/emag_starts_charged = 1
	var/emag_recharge_rate = 0
	var/emag_recharge_ticks = 0

	var/map_voting = 0
	var/renders_url = ""

	var/default_ooc_color = "#002eb8"

	var/mommi_static = 0 //Scrambling mobs for mommis or not

	var/skip_minimap_generation = 0 //If 1, don't generate minimaps
	var/skip_holominimap_generation = 0 //If 1, don't generate holominimaps
	var/skip_vault_generation = 0 //If 1, don't generate vaults
	var/shut_up_automatic_diagnostic_and_announcement_system = 0 //If 1, don't play the vox sounds at the start of every shift.
	var/no_lobby_music = 0 //If 1, don't play lobby music, regardless of client preferences.
	var/no_ambience = 0 //If 1, don't play ambience, regardless of client preferences.

	var/enable_roundstart_away_missions = 0

	// Error handler config options.
	var/error_cooldown = 600 // The "cooldown" time for each occurrence of a unique error
	var/error_limit = 9 // How many occurrences before the next will silence them
	var/error_silence_time = 6000 // How long a unique error will be silenced for
	var/error_msg_delay = 50 // How long to wait between messaging admins about occurrences of a unique error

	// Discord crap.
	var/discord_url
	var/discord_password

	// Weighted Votes
	var/weighted_votes = 0

	// Dynamic Mode
	var/high_population_override = 1//If 1, what rulesets can or cannot be called depend on the threat level only

/datum/configuration/New()
	. = ..()
	var/list/L = subtypesof(/datum/gamemode)-/datum/gamemode/cult

	for (var/T in L)
		// I wish I didn't have to instance the game modes in order to look up
		// their information, but it is the only way (at least that I know of).
		var/datum/gamemode/M = T

		if (initial(M.name))
			if (!(initial(M.name) in modes)) // Ensure each mode is added only once.
				src.modes += initial(M.name)
				src.mode_names[initial(M.name)] = initial(M.name)
				src.probabilities[initial(M.name)] = initial(M.probability)

				if (initial(M.votable))
					votable_modes += initial(M.name)

	votable_modes += "secret"

/datum/configuration/proc/load(filename, type = "config") //the type can also be game_options, in which case it uses a different switch. not making it separate to not copypaste code - Urist
	var/list/Lines = file2list(filename)

	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if (!name)
			continue

		if(type == "config")
			switch (name)
				if ("resource_urls")
					config.resource_urls = splittext(value, " ")

				if("tts_server")
					config.tts_server = value

				if ("admin_legacy_system")
					config.admin_legacy_system = 1

				if ("ban_legacy_system")
					config.ban_legacy_system = 1

				if ("use_age_restriction_for_jobs")
					config.use_age_restriction_for_jobs = 1

				if ("jobs_have_minimal_access")
					config.jobs_have_minimal_access = 1

				if ("use_recursive_explosions")
					use_recursive_explosions = 1

				if ("localhost_autoadmin")
					localhost_autoadmin = 1

				if ("log_ooc")
					config.log_ooc = 1

				if ("log_access")
					config.log_access = 1

				if ("sql_enabled")
					config.sql_enabled = text2num(value)

				if ("log_say")
					config.log_say = 1

				if ("log_admin")
					config.log_admin = 1

				if("log_admin_only")
					config.log_admin_only = TRUE

				if ("log_debug")
					config.log_debug = text2num(value)

				if ("log_game")
					config.log_game = 1

				if ("log_vote")
					config.log_vote = 1

				if ("log_whisper")
					config.log_whisper = 1

				if ("log_attack")
					config.log_attack = 1

				if ("log_emote")
					config.log_emote = 1

				if ("log_adminchat")
					config.log_adminchat = 1

				if ("log_adminwarn")
					config.log_adminwarn = 1

				if ("log_adminghost")
					config.log_adminghost = 1

				if ("log_runtimes")
					config.log_runtimes = 1

				if ("log_pda")
					config.log_pda = 1

				if ("log_rc")
					config.log_rc = 1

				if ("log_hrefs")
					config.log_hrefs = 1

				if("allow_admin_ooccolor")
					config.allow_admin_ooccolor = 1

				if ("allow_vote_restart")
					config.allow_vote_restart = 1

				if ("allow_vote_mode")
					config.allow_vote_mode = 1

				if ("allow_admin_jump")
					config.allow_admin_jump = 1

				if("allow_admin_rev")
					config.allow_admin_rev = 1

				if ("allow_admin_spawning")
					config.allow_admin_spawning = 1

				if ("no_dead_vote")
					config.vote_no_dead = 1

				if ("default_no_vote")
					config.vote_no_default = 1

				if ("vote_delay")
					config.vote_delay = text2num(value)

				if ("vote_period")
					config.vote_period = text2num(value)

				if ("allow_ai")
					config.allow_ai = 1

//				if ("authentication")
//					config.enable_authentication = 1

				if ("norespawn")
					config.respawn = 0

				if ("respawn_as_mommi")
					config.respawn_as_mommi = 1

				if ("no_respawn_as_mouse")
					config.respawn_as_mouse = 0

				if ("servername")
					config.server_name = value

				if ("serversuffix")
					config.server_suffix = 1

				if ("nudge_script_path")
					config.nudge_script_path = value

				if ("hostedby")
					config.hostedby = value

				if ("server")
					config.server = value

				if ("banappeals")
					config.banappeals = value

				if ("wikiurl")
					config.wikiurl = value

				if ("forumurl")
					config.forumurl = value

				if ("guest_jobban")
					config.guest_jobban = 1

				if ("guest_ban")
					guests_allowed = 0

				if ("usewhitelist")
					config.usewhitelist = 1

				if ("feature_object_spell_system")
					config.feature_object_spell_system = 1

				if ("allow_metadata")
					config.allow_Metadata = 1

				if ("traitor_scaling")
					config.traitor_scaling = 1

				if("protect_roles_from_antagonist")
					config.protect_roles_from_antagonist = 1

				if ("probability")
					var/prob_pos = findtext(value, " ")
					var/prob_name = null
					var/prob_value = null

					if (prob_pos)
						prob_name = lowertext(copytext(value, 1, prob_pos))
						prob_value = copytext(value, prob_pos + 1)
						if (prob_name in config.modes)
							config.probabilities[prob_name] = text2num(prob_value)
						else
							diary << "Unknown game mode probability configuration definition: [prob_name]."
					else
						diary << "Incorrect probability configuration definition: [prob_name]  [prob_value]."

				if("allow_random_events")
					config.allow_random_events = 1

				if("kick_inactive")
					config.kick_inactive = 1

				if("load_jobs_from_txt")
					load_jobs_from_txt = 1

				if("alert_red_upto")
					config.alert_desc_red_upto = value

				if("alert_red_downto")
					config.alert_desc_red_downto = value

				if("alert_blue_downto")
					config.alert_desc_blue_downto = value

				if("alert_blue_upto")
					config.alert_desc_blue_upto = value

				if("alert_green")
					config.alert_desc_green = value

				if("alert_delta")
					config.alert_desc_delta = value

				if("forbid_singulo_possession")
					forbid_singulo_possession = 1

				if("popup_admin_pm")
					config.popup_admin_pm = 1

				if("allow_holidays")
					Holiday = 1

				if("use_irc_bot")
					use_irc_bot = 1

				if("ticklag")
					Ticklag = text2num(value)

				if("allow_antag_hud")
					config.antag_hud_allowed = 1
				if("antag_hud_restricted")
					config.antag_hud_restricted = 1

				if("socket_talk")
					socket_talk = text2num(value)

				if("humans_need_surnames")
					humans_need_surnames = 1

				if("tor_ban")
					ToRban = 1

				if("automute_on")
					automute_on = 1

				if("usealienwhitelist")
					usealienwhitelist = 1

				if("alien_player_ratio")
					limitalienplayers = 1
					alien_to_human_ratio = text2num(value)

				if("assistant_maint")
					config.assistant_maint = 1

				if("gateway_delay")
					config.gateway_delay = text2num(value)

				if("continuous_rounds")
					config.continous_rounds = 1

				if("ghost_interaction")
					config.ghost_interaction = 1

				if("disable_player_mice")
					config.disable_player_mice = 1

				if("uneducated_mice")
					config.uneducated_mice = 1

				if("comms_password")
					config.comms_password = value

				if("paperwork_library")
					config.paperwork_library = 1

				if("irc_bot_host")
					config.irc_bot_host = value

				if("irc_bot_port")
					config.irc_bot_port = text2num(value)

				if("irc_bot_server_id")
					config.irc_bot_server_id = value

				if("python_path")
					if(value)
						config.python_path = value
					else
						if(world.system_type == UNIX)
							config.python_path = "/usr/bin/env python2"
						else //probably windows, if not this should work anyway
							config.python_path = "python"

				if("allow_cult_ghostwriter")
					config.cult_ghostwriter = 1

				if("req_cult_ghostwriter")
					config.cult_ghostwriter_req_cultists = value
				if("assistant_limit")
					config.assistantlimit = 1
				if("assistant_ratio")
					config.assistantratio = text2num(value)
				if("copy_logs")
					copy_logs = value
				if("media_base_url")
					media_base_url = value
				if("media_secret_key")
					media_secret_key = value
				if("vgws_base_url")
					vgws_base_url = value
				if("vgws_ip")
					vgws_ip = value
				if("poll_results_url")
					poll_results_url = value
				if("map_voting")
					map_voting = 1
				if("renders_url")
					renders_url = value
				if("mommi_static")
					mommi_static = 1
				if("skip_minimap_generation")
					skip_minimap_generation = 1
				if("skip_holominimap_generation")
					skip_holominimap_generation = 1
				if("skip_vault_generation")
					skip_vault_generation = 1
				if("shut_up_automatic_diagnostic_and_announcement_system")
					shut_up_automatic_diagnostic_and_announcement_system = 1
				if("no_lobby_music")
					no_lobby_music = 1
				if("no_ambience")
					no_ambience = 1
				if("enable_roundstart_away_missions")
					enable_roundstart_away_missions = 1
				if("enable_wages")
					roundstart_enable_wages = 1
				if("error_cooldown")
					error_cooldown = text2num(value)
				if("error_limit")
					error_limit = text2num(value)
				if("error_silence_time")
					error_silence_time = text2num(value)
				if("error_msg_delay")
					error_msg_delay = text2num(value)
				if("discord_url")
					discord_url = value
				if("discord_password")
					discord_password = value
				if("weighted_votes")
					weighted_votes = TRUE

				else
					diary << "Unknown setting in configuration: '[name]'"

		else if(type == "game_options")
			if(!value)
				diary << "Unknown value for setting [name] in [filename]."
			value = text2num(value)

			switch(name)
				if("max_explosion_range")
					MAX_EXPLOSION_RANGE = value
				if("health_threshold_crit")
					config.health_threshold_crit = value
				if("health_threshold_softcrit")
					config.health_threshold_softcrit = value
				if("health_threshold_dead")
					config.health_threshold_dead = value
				if("burn_damage_ash")
					config.burn_damage_ash = value
				if("revival_pod_plants")
					config.revival_pod_plants = value
				if("revival_cloning")
					config.revival_cloning = value
				if("revival_brain_life")
					config.revival_brain_life = value
				if("run_speed")
					config.run_speed = value
				if("walk_speed")
					config.walk_speed = value
				if("organ_health_multiplier")
					config.organ_health_multiplier = value / 100
				if("organ_regeneration_multiplier")
					config.organ_regeneration_multiplier = value / 100
				if("bones_can_break")
					config.bones_can_break = value
				if("limbs_can_break")
					config.limbs_can_break = value
				if("respawn_delay")
					config.respawn_delay = value
				if("emag_energy")
					config.emag_energy = value
				if("emag_starts_charged")
					config.emag_starts_charged = value
				if("emag_recharge_rate")
					config.emag_recharge_rate = value
				if("emag_recharge_ticks")
					config.emag_recharge_ticks = value
				if("silent_ai")
					config.silent_ai = 1
				if("silent_borg")
					config.silent_borg = 1
				if("borer_takeover_immediately")
					config.borer_takeover_immediately = 1
				if("hardcore_mode")
					hardcore_mode = value
				if("humans_speak")
					voice_noises = 1
				else
					diary << "Unknown setting in configuration: '[name]'"

/datum/configuration/proc/loadsql(filename)  // -- TLE
	var/list/Lines = file2list(filename)
	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if (!name)
			continue

		switch (name)
			if ("address")
				sqladdress = value
			if ("port")
				sqlport = value
			if ("database")
				sqldb = value
			if ("login")
				sqllogin = value
			if ("password")
				sqlpass = value
			if ("feedback_database")
				sqlfdbkdb = value
			if ("feedback_login")
				sqlfdbklogin = value
			if ("feedback_password")
				sqlfdbkpass = value
			if ("enable_stat_tracking")
				sqllogging = 1
			else
				diary << "Unknown setting in configuration: '[name]'"

/datum/configuration/proc/loadforumsql(filename)  // -- TLE
	var/list/Lines = file2list(filename)
	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if (!name)
			continue

		switch (name)
			if ("address")
				forumsqladdress = value
			if ("port")
				forumsqlport = value
			if ("database")
				forumsqldb = value
			if ("login")
				forumsqllogin = value
			if ("password")
				forumsqlpass = value
			if ("activatedgroup")
				forum_activated_group = value
			if ("authenticatedgroup")
				forum_authenticated_group = value
			else
				diary << "Unknown setting in configuration: '[name]'"

/datum/configuration/proc/pick_mode(mode_name)
	for (var/t in subtypesof(/datum/gamemode)-/datum/gamemode/cult)
		var/datum/gamemode/T = t
		if (initial(T.name) && initial(T.name) == mode_name)
			return new T
	return new /datum/gamemode/extended()

/datum/configuration/proc/get_runnable_modes()
	var/list/datum/gamemode/runnable_modes = new
	for (var/T in subtypesof(/datum/gamemode)-/datum/gamemode/cult)
		var/datum/gamemode/M = new T()
//		log_startup_progress("DEBUG: [T], tag=[M.name], prob=[probabilities[M.name]]")
		if (!(M.name in modes))
			del(M)
			continue
		if (probabilities[M.name]<=0)
			del(M)
			continue
		if (M.can_start())
			runnable_modes[M] = probabilities[M.name]
//			log_startup_progress("DEBUG: runnable_mode\[[runnable_modes.len]\] = [M.name]")
	return runnable_modes
