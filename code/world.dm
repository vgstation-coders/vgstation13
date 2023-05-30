#define WORLD_ICON_SIZE 32
#define PIXEL_MULTIPLIER WORLD_ICON_SIZE/32

var/world_startup_time
var/date_string

#if DM_VERSION < 515
#error You need at least version 515 to compile
#endif
/world
	mob = /mob/new_player
	turf = /turf/space
	view = "15x15"
	cache_lifespan = 0	//stops player uploaded stuff from being kept in the rsc past the current session
	//loop_checks = 0
	icon_size = WORLD_ICON_SIZE
	sleep_offline = FALSE
	movement_mode = PIXEL_MOVEMENT_MODE

var/savefile/panicfile

var/datum/early_init/early_init_datum = new

#if AUXTOOLS_DEBUGGER
var/auxtools_path

/proc/enable_debugging(mode, port) //Hooked by auxtools
	CRASH("auxtools not loaded")

/proc/auxtools_stack_trace(msg)
	CRASH(msg)

/proc/auxtools_expr_stub()
	CRASH("auxtools not loaded")
#endif

/datum/early_init/New()
	..()
	#if AUXTOOLS_DEBUGGER
	auxtools_path = world.GetConfig("env", "AUXTOOLS_DEBUG_DLL")
	if(fexists(auxtools_path))
		call_ext(auxtools_path, "auxtools_init")()
		enable_debugging()
	else
		// warn on missing library
		warning("There is no auxtools library for this system included with SpacemanDMM. Debugging will not work. Pester them to add one.")
	#endif
	world.Profile(PROFILE_START)

/world/New()
	world_startup_time = world.timeofday

	for(var/i=1, i<=map.zLevels.len, i++)
		WORLD_X_OFFSET += rand(-50,50)
		WORLD_Y_OFFSET += rand(-50,50)

	// logs
	date_string = time2text(world.realtime, "YYYY/MM-Month/DD-Day")

	investigations[I_HREFS] = new /datum/log_controller(I_HREFS, filename="data/logs/[date_string] hrefs.htm", persist=TRUE)
	investigations[I_ATMOS] = new /datum/log_controller(I_ATMOS, filename="data/logs/[date_string] atmos.htm", persist=TRUE)
	investigations[I_CHEMS] = new /datum/log_controller(I_CHEMS, filename="data/logs/[date_string] chemistry.htm", persist=TRUE)
	investigations[I_WIRES] = new /datum/log_controller(I_WIRES, filename="data/logs/[date_string] wires.htm", persist=TRUE)
	investigations[I_GHOST] = new /datum/log_controller(I_GHOST, filename="data/logs/[date_string] poltergeist.htm", persist=TRUE)
	investigations[I_ARTIFACT] = new /datum/log_controller(I_ARTIFACT, filename="data/logs/[date_string] artifact.htm", persist=TRUE)
	investigations[I_RCD] = new /datum/log_controller(I_RCD, filename="data/logs/[date_string] rcd.htm", persist=TRUE)

	diary = file("data/logs/[date_string].log")
	panicfile = new/savefile("data/logs/profiling/proclogs/[date_string].sav")
	diaryofmeanpeople = file("data/logs/[date_string] Attack.log")
	admin_diary = file("data/logs/[date_string] admin only.log")

	var/now = time_stamp()
	var/log_start = "---------------------\n\[[now]\]WORLD: starting up..."

	diary << log_start
	diaryofmeanpeople << log_start
	admin_diary << log_start
	panicfile.cd = now

	changelog_hash = md5('html/changelog.html')					//used for telling if the changelog has changed recently

	load_configuration()
	SSdbcore.Initialize(world.timeofday) // Get a database running, first thing

	load_mode()
	load_motd()
	load_admins()
	load_mods()
	LoadBansjob()
	jobban_loadbanfile()
	oocban_loadbanfile()
	paxban_loadbanfile()
	jobban_updatelegacybans()
	appearance_loadbanfile()
	LoadBans()

	spawn() copy_logs() // Just copy the logs.
	if(config && config.log_runtimes)
		log = file("data/logs/runtime/[time2text(world.realtime,"YYYY-MM-DD")]-runtime.log")
	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	send2mainirc("Server starting up on [config.server? "byond://[config.server]" : "byond://[world.address]:[world.port]"]")
	send2maindiscord("**Server starting up** on `[config.server? "byond://[config.server]" : "byond://[world.address]:[world.port]"]`. Map is **[map.nameLong]**")

	Master.Setup()

	return ..()

/world/Topic(T, addr, master, key)
	diary << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key]"

	if (T == "ping")
		var/x = 1
		for (var/client/C)
			x++
		return x

	else if(T == "players")
		var/n = 0
		for(var/mob/M in player_list)
			if(M.client)
				n++
		return n

	else if (T == "status")
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = master_mode
		s["respawn"] = config ? abandon_allowed : 0
		s["enter"] = enter_allowed
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
		s["players"] = list()
		s["map_name"] = map.nameLong
		s["station_time"] = worldtime2text()
		s["gamestate"] = 1
		if(ticker)
			s["gamestate"] = ticker.current_state
		s["active_players"] = get_active_player_count()
		s["revision"] = return_revision()
		var/n = 0
		var/admins = 0
		var/afk_admins = 0

		for(var/client/C in clients)
			if(C.holder)
				if(C.holder.fakekey)
					continue	//so stealthmins aren't revealed by the hub
				if(C.is_afk())
					afk_admins++
				admins++
			s["player[n]"] = C.key
			n++
		s["players"] = n

		s["admins"] = admins - afk_admins
		s["afk_admins"] = afk_admins

		return list2params(s)
	else if (findtext(T,"notes:"))
		if (!config || addr != config.vgws_ip)
			return "Denied"

		var/notekey = copytext(T, 7)
		return list2params(exportnotes(notekey))


/world/Reboot(reason)
	if(reason == REBOOT_HOST)
		if(usr)
			if (!check_rights(R_SERVER))
				log_admin("[key_name(usr)] Attempted to reboot world via client debug tools, but they do not have +SERVER and were denied.")
				message_admins("[key_name_admin(usr)] Attempted to reboot world via client debug tools, but they do not have +SERVER and were denied.")
				return

			log_admin("[key_name(usr)] Has requested an immediate world restart via client side debugging tools.")
			message_admins("[key_name_admin(usr)] Has requested an immediate world restart via client side debugging tools.")
			// To prevent the server shutting down before logs get to the admins or some nonsense.
			sleep(1)

		to_chat(world, "<span class='danger big'>Rebooting World immediately due to host request!</span>")
		..()
		return

	if(vote.winner && vote.map_paths)
		//get filename
		var/filename = "vgstation13.dmb"
		var/map_path = "maps/voting/" + vote.map_paths[vote.winner] + "/" + filename
		if(fexists(map_path))
			//copy file to main folder
			if(!fcopy(map_path, filename))
				fdel(filename)
				fcopy(map_path, filename)

	pre_shutdown()
	..()

/world/proc/pre_shutdown()
	for(var/datum/html_interface/D in html_interfaces)
		D.closeAll()

	Master.Shutdown()

	stop_all_media()

	end_credits.on_world_reboot_start()
	sleep(max(10, end_credits.audio_post_delay))
	end_credits.on_world_reboot_end()

	for(var/client/C in clients)
		if(config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")

		else
			C << link("byond://[world.address]:[world.port]")

	#if AUXTOOLS_DEBUGGER
	call_ext(auxtools_path, "auxtools_shutdown")()
	#endif

#define INACTIVITY_KICK	6000	//10 minutes in ticks (approx.)
/world/proc/KickInactiveClients()
	spawn(-1)
		//set background = 1
		while(1)
			sleep(INACTIVITY_KICK)
			for(var/client/C in clients)
				if(C.is_afk(INACTIVITY_KICK))
					if(!istype(C.mob, /mob/dead))
						log_access("AFK: [key_name(C)]")
						to_chat(C, "<span class='warning'>You have been inactive for more than 10 minutes and have been disconnected.</span>")
						del(C)
//#undef INACTIVITY_KICK


/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			master_mode = Lines[1]
			diary << "Saved mode is '[master_mode]'"

/world/proc/save_mode(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")

/world/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.loadsql("config/dbconfig.txt")
	config.loadforumsql("config/forumdbconfig.txt")
	// apply some settings from config..
	abandon_allowed = config.respawn

/world/proc/load_mods()
	if(config.admin_legacy_system)
		var/text = file2text("config/moderators.txt")
		if (!text)
			diary << "Failed to load config/mods.txt\n"
		else
			var/list/lines = splittext(text, "\n")
			for(var/line in lines)
				if (!line)
					continue

				if (copytext(line, 1, 2) == ";")
					continue

				var/rights = admin_ranks["Moderator"]
				var/ckey = copytext(line, 1, length(line)+1)
				var/datum/admins/D = new /datum/admins("Moderator", rights, ckey)
				D.associate(directory[ckey])

