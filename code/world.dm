#define WORLD_ICON_SIZE 32
#define PIXEL_MULTIPLIER WORLD_ICON_SIZE/32
/world
	mob = /mob/new_player
	turf = /turf/space
	view = "15x15"
	cache_lifespan = 0	//stops player uploaded stuff from being kept in the rsc past the current session
	//loop_checks = 0
	icon_size = WORLD_ICON_SIZE
#define RECOMMENDED_VERSION 511


var/savefile/panicfile
/world/New()
	//populate_seed_list()
	plant_controller = new()

	// Honk honk, fuck you science
	for(var/i=1, i<=map.zLevels.len, i++)
		WORLD_X_OFFSET += rand(-50,50)
		WORLD_Y_OFFSET += rand(-50,50)

	// Initialize world events as early as possible.
	on_login = new ()
	on_ban   = new ()
	on_unban = new ()


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
	if(byond_version < 510)
		warning("Your server's byond version does not meet the recommended requirements for this code. Please update BYOND to atleast 507.1248 or comment BORDER_USE_TURF_EXIT in global.dm")
#elif
	if(byond_version < RECOMMENDED_VERSION)
		world.log << "Your server's byond version does not meet the recommended requirements for this code. Please update BYOND"
#endif
	make_datum_references_lists()	//initialises global lists for referencing frequently used datums (so that we only ever do it once)

	load_configuration()
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

	//sun = new /datum/sun()
	radio_controller = new /datum/controller/radio()
	data_core = new /obj/effect/datacore()
	paiController = new /datum/paiController()

	if(!setup_database_connection())
		world.log << "Your server failed to establish a connection with the feedback database."
	else
		world.log << "Feedback database connection established."
	migration_controller_mysql = new
	migration_controller_sqlite = new ("players2.sqlite", "players2_empty.sqlite")

	if(!setup_old_database_connection())
		world.log << "Your server failed to establish a connection with the tgstation database."
	else
		world.log << "Tgstation database connection established."

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

	sleep_offline = 1

	send2mainirc("Server starting up on [config.server? "byond://[config.server]" : "byond://[world.address]:[world.port]"]")
	send2maindiscord("**Server starting up** on `[config.server? "byond://[config.server]" : "byond://[world.address]:[world.port]"]`. Map is **[map.nameLong]**")

	spawn(10)
		Master.Setup()

	for(var/plugin_type in typesof(/plugin))
		var/plugin/P = new plugin_type()
		plugins[P.name] = P
		P.on_world_loaded()

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

		if(revdata)
			s["revision"] = revdata.revision
		s["admins"] = admins

		return list2params(s)
	else if (findtext(T,"notes:"))
		if (!config || addr != config.vgws_ip)
			return "Denied"

		var/notekey = copytext(T, 7)
		return list2params(exportnotes(notekey))


/world/Reboot(reason)
	if(reason == 1)
		if(usr && usr.client)
			if(!usr.client.holder)
				return 0
	for(var/datum/html_interface/D in html_interfaces)
		D.closeAll()
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

	Master.Shutdown()
	paperwork_stop()

	spawn()
		world << sound(pick(
			'sound/AI/newroundsexy.ogg',
			'sound/misc/RoundEndSounds/apcdestroyed.ogg',
			'sound/misc/RoundEndSounds/bangindonk.ogg',
			'sound/misc/RoundEndSounds/slugmissioncomplete.ogg',
			'sound/misc/RoundEndSounds/bayojingle.ogg',
			'sound/misc/RoundEndSounds/gameoveryeah.ogg',
			'sound/misc/RoundEndSounds/rayman.ogg',
			'sound/misc/RoundEndSounds/marioworld.ogg',
			'sound/misc/RoundEndSounds/soniclevelcomplete.ogg',
			'sound/misc/RoundEndSounds/calamitytrigger.ogg',
			'sound/misc/RoundEndSounds/duckgame.ogg',
			'sound/misc/RoundEndSounds/FTLvictory.ogg',
			'sound/misc/RoundEndSounds/tfvictory.ogg',
			'sound/misc/RoundEndSounds/megamanX.ogg',
			'sound/misc/RoundEndSounds/castlevania.ogg',
			)) // random end sounds!! - LastyBatsy

	sleep(5)//should fix the issue of players not hearing the restart sound.

	for(var/client/C in clients)
		if(config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")

		else
			C << link("byond://[world.address]:[world.port]")


	..()


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

#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0
var/failed_old_db_connections = 0

proc/setup_database_connection()


	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0

	if(!dbcon)
		dbcon = new()

	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon.IsConnected()
	if ( . )
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		world.log << "Database Error: [dbcon.ErrorMsg()]"
		failed_db_connections++		//If it failed, increase the failed connections counter.

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
proc/establish_db_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	var/DBQuery/q
	if(dbcon)
		q = dbcon.NewQuery("show global variables like 'wait_timeout'")
		q.Execute()
		if(q && q.ErrorMsg())
			dbcon.Disconnect()
	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return 1




//These two procs are for the old database, while it's being phased out. See the tgstation.sql file in the SQL folder for more information.
proc/setup_old_database_connection()


	if(failed_old_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0

	if(!dbcon_old)
		dbcon_old = new()

	var/user = sqllogin
	var/pass = sqlpass
	var/db = sqldb
	var/address = sqladdress
	var/port = sqlport

	dbcon_old.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon_old.IsConnected()
	if ( . )
		failed_old_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_old_db_connections++		//If it failed, increase the failed connections counter.
		world.log << dbcon_old.ErrorMsg()

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
proc/establish_old_db_connection()
	if(failed_old_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon_old || !dbcon_old.IsConnected())
		return setup_old_database_connection()
	else
		return 1

#undef FAILED_DB_CONNECTION_CUTOFF
