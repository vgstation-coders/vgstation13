#define WORLD_ICON_SIZE 32
#define PIXEL_MULTIPLIER WORLD_ICON_SIZE/32

var/world_startup_time

/world
	mob = /mob/new_player
	turf = /turf/space
	view = "15x15"
	cache_lifespan = 0	//stops player uploaded stuff from being kept in the rsc past the current session
	//loop_checks = 0
	icon_size = WORLD_ICON_SIZE

#define RECOMMENDED_VERSION 513

var/savefile/panicfile

var/datum/early_init/early_init_datum = new

/datum/early_init/New()
	..()
	var/extools_path = world.system_type == MS_WINDOWS ? "byond-extools.dll" : "libbyond-extools.so"
	if(fexists(extools_path))
		#if EXTOOLS_DEBUGGER
		call(extools_path, "debug_initialize")()
		#endif
		call(extools_path, "maptick_initialize")()
		#if EXTOOLS_REFERENCE_TRACKING
		call(extools_path, "ref_tracking_initialize")()
		#endif
	else
		// warn on missing library
		// extools on linux does not exist and is not in the repository as of yet
		warning("There is no extools library for this system included with this build. Performance may differ significantly than if it were present. This warning will not show if [extools_path] is added to the root of the game directory.")

/world/New()
	world_startup_time = world.timeofday
	Profile(world_startup_time)
	// Honk honk, fuck you science
	for(var/i=1, i<=map.zLevels.len, i++)
		WORLD_X_OFFSET += rand(-50,50)
		WORLD_Y_OFFSET += rand(-50,50)

	/*Runtimes, not sure if i need it still so commenting out for now
	starticon = rotate_icon('icons/obj/lightning.dmi', "lightningstart")
	midicon = rotate_icon('icons/obj/lightning.dmi', "lightning")
	endicon = rotate_icon('icons/obj/lightning.dmi', "lightningend")
	*/

	// logs
	var/date_string = time2text(world.realtime, "YYYY/MM-Month/DD-Day")

	investigations[I_HREFS] = new /datum/log_controller(I_HREFS, filename="data/logs/[date_string] hrefs.htm", persist=TRUE)
	investigations[I_ATMOS] = new /datum/log_controller(I_ATMOS, filename="data/logs/[date_string] atmos.htm", persist=TRUE)
	investigations[I_CHEMS] = new /datum/log_controller(I_CHEMS, filename="data/logs/[date_string] chemistry.htm", persist=TRUE)
	investigations[I_WIRES] = new /datum/log_controller(I_WIRES, filename="data/logs/[date_string] wires.htm", persist=TRUE)
	investigations[I_GHOST] = new /datum/log_controller(I_GHOST, filename="data/logs/[date_string] poltergeist.htm", persist=TRUE)
	investigations[I_ARTIFACT] = new /datum/log_controller(I_ARTIFACT, filename="data/logs/[date_string] artifact.htm", persist=TRUE)

	diary = file("data/logs/[date_string].log")
	panicfile = new/savefile("data/logs/profiling/proclogs/[date_string].sav")
	diaryofmeanpeople = file("data/logs/[date_string] Attack.log")
	admin_diary = file("data/logs/[date_string] admin only.log")

	var/log_start = "---------------------\n\[[time_stamp()]\]WORLD: starting up..."

	diary << log_start
	diaryofmeanpeople << log_start
	admin_diary << log_start
	var/ourround = time_stamp()
	panicfile.cd = ourround


	changelog_hash = md5('html/changelog.html')					//used for telling if the changelog has changed recently
/*
 * IF YOU HAVE BYOND VERSION BELOW 507.1248 OR ARE ABLE TO WALK THROUGH WINDOORS/BORDER WINDOWS COMMENT OUT
 * #define BORDER_USE_TURF_EXIT
 * FOR MORE INFORMATION SEE: http://www.byond.com/forum/?post=1666940
 */
#ifdef BORDER_USE_TURF_EXIT
	if(byond_version < RECOMMENDED_VERSION)
		warning("Your server's byond version does not meet the recommended requirements for this code. Please update BYOND to atleast 513.")
#endif
	make_datum_references_lists()	//initialises global lists for referencing frequently used datums (so that we only ever do it once)

	load_configuration()
	SSdbcore.Initialize(world.timeofday) // Get a database running, first thing

	load_mode()
	load_motd()
	load_admins()
	load_mods()
	LoadBansjob()
	if(config.usewhitelist)
		load_whitelist()
	if(config.usealienwhitelist)
		load_alienwhitelist()
	jobban_loadbanfile()
	oocban_loadbanfile()
	jobban_updatelegacybans()
	appearance_loadbanfile()
	LoadBans()
	SetupHooks() // /vg/

	library_catalog.initialize()

	spawn() copy_logs() // Just copy the logs.
	if(config && config.log_runtimes)
		log = file("data/logs/runtime/[time2text(world.realtime,"YYYY-MM-DD")]-runtime.log")
	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	Get_Holiday()	//~Carn, needs to be here when the station is named so :P

	src.update_status()

	paperwork_setup()

	global_deadchat_listeners = list()

	initialize_runesets()

	initialize_beespecies()
	generate_radio_frequencies()
	//sun = new /datum/sun()
	data_core = new /obj/effect/datacore()
	paiController = new /datum/paiController()

	plmaster = new /obj/effect/overlay()
	plmaster.icon = 'icons/effects/tile_effects.dmi'
	plmaster.icon_state = "plasma"
	plmaster.layer = FLY_LAYER
	plmaster.plane = EFFECTS_PLANE
	plmaster.mouse_opacity = 0

	slmaster = new /obj/effect/overlay()
	slmaster.icon = 'icons/effects/tile_effects.dmi'
	slmaster.icon_state = "sleeping_agent"
	slmaster.layer = FLY_LAYER
	slmaster.plane = EFFECTS_PLANE
	slmaster.mouse_opacity = 0

	src.update_status()

	sleep_offline = 0

	send2mainirc("Server starting up on [config.server? "byond://[config.server]" : "byond://[world.address]:[world.port]"]")
	send2maindiscord("**Server starting up** on `[config.server? "byond://[config.server]" : "byond://[world.address]:[world.port]"]`. Map is **[map.nameLong]**")

	Master.Setup()

	process_teleport_locs()				//Sets up the wizard teleport locations
	process_ghost_teleport_locs()		//Sets up ghost teleport locations.
	process_adminbus_teleport_locs()	//Sets up adminbus teleport locations.
	SortAreas()							//Build the list of all existing areas and sort it alphabetically

	spawn(2000)		//so we aren't adding to the round-start lag
		if(config.ToRban)
			ToRban_autoupdate()
		/*if(config.kick_inactive)
			KickInactiveClients()*/

#undef RECOMMENDED_VERSION
	return ..()

//world/Topic(href, href_list[])
//		to_chat(world, "Received a Topic() call!")
//		to_chat(world, "[href]")
//		for(var/a in href_list)
//			to_chat(world, "[a]")
//		if(href_list["hello"])
//			to_chat(world, "Hello world!")
//			return "Hello world!"
//		to_chat(world, "End of Topic() call.")
//		..()

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
		s["vote"] = config.allow_vote_mode
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

		for(var/client/C in clients)
			if(C.holder)
				if(C.holder.fakekey)
					continue	//so stealthmins aren't revealed by the hub
				admins++
			s["player[n]"] = C.key
			n++
		s["players"] = n

		s["admins"] = admins

		return list2params(s)
	else if (findtext(T,"notes:"))
		if (!config || addr != config.vgws_ip)
			return "Denied"

		var/notekey = copytext(T, 7)
		return list2params(exportnotes(notekey))


/world/Reboot(reason)
	testing("[time_stamp()] - World is rebooting. Reason: [reason]")
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

	if(config.map_voting)
		//testing("we have done a map vote")
		if(fexists(vote.chosen_map))
			//testing("[vote.chosen_map] exists")
			var/start = 1
			var/pos = findtext(vote.chosen_map, "/", start)
			var/lastpos = pos
			//testing("First slash [lastpos]")
			while(pos > 0)
				lastpos = pos
				pos = findtext(vote.chosen_map, "/", start)
				start = pos + 1
				//testing("Next slash [pos]")
			var/filename = copytext(vote.chosen_map, lastpos + 1, 0)
			//testing("Found [filename]")

			if(!fcopy(vote.chosen_map, filename))
				//testing("Fcopy failed, deleting and copying")
				fdel(filename)
				fcopy(vote.chosen_map, filename)
			sleep(60)

	pre_shutdown()

	..()

/world/proc/pre_shutdown()
	for(var/datum/html_interface/D in html_interfaces)
		D.closeAll()

	Master.Shutdown()
	paperwork_stop()

	stop_all_media()

	end_credits.on_world_reboot_start()
	testing("[time_stamp()] - World reboot is now sleeping.")

	sleep(max(10, end_credits.audio_post_delay))

	testing("[time_stamp()] - World reboot is done sleeping.")
	end_credits.on_world_reboot_end()

	for(var/client/C in clients)
		if(config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")

		else
			C << link("byond://[world.address]:[world.port]")

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

/world/proc/update_status()
	var/s = ""

	if (config && config.server_name)
		s += "<b>[config.server_name]</b> &#8212; "


	s += {"<b>[station_name()]</b>"
		(
		<a href=\"http://\">" //Change this to wherever you want the hub to link to
		Default"  //Replace this with something else. Or ever better, delete it and uncomment the game version
		</a>
		)"}
	var/list/features = list()

	if(ticker)
		if(master_mode)
			features += master_mode
	else
		features += "<b>STARTING</b>"

	if (!enter_allowed)
		features += "closed"

	features += abandon_allowed ? "respawn" : "no respawn"

	if (config && config.allow_vote_mode)
		features += "vote"

	if (config && config.allow_ai)
		features += "AI allowed"

	var/n = 0
	for (var/mob/M in player_list)
		if (M.client)
			n++

	if (n > 1)
		features += "~[n] players"
	else if (n > 0)
		features += "~[n] player"

	/*
	is there a reason for this? the byond site shows 'hosted by X' when there is a proper host already.
	if (host)
		features += "hosted by <b>[host]</b>"
	*/

	if (!host && config && config.hostedby)
		features += "hosted by <b>[config.hostedby]</b>"

	if (features)
		s += ": [jointext(features, ", ")]"

	/* does this help? I do not know */
	if (src.status != s)
		src.status = s
