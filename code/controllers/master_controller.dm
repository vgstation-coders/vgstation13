//simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
//It ensures master_controller.process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)
//WIP, needs lots of work still

var/global/datum/controller/game_controller/master_controller //Set in world.New()

var/global/last_tick_duration = 0

var/global/air_processing_killed = 0
var/global/pipe_processing_killed = 0

#ifdef PROFILE_MACHINES
// /type = time this tick
var/list/machine_profiling=list()
#endif

/datum/controller/game_controller
	var/breather_ticks = 2		//a somewhat crude attempt to iron over the 'bumps' caused by high-cpu use by letting the MC have a breather for this many ticks after every loop
	var/minimum_ticks = 20		//The minimum length of time between MC ticks

	var/air_cost 		= 0
	var/sun_cost		= 0
	var/mobs_cost		= 0
	var/diseases_cost	= 0
	var/machines_cost	= 0
	var/objects_cost	= 0
	var/networks_cost	= 0
	var/powernets_cost	= 0
	var/nano_cost		= 0
	var/events_cost		= 0
	var/ticker_cost		= 0
	var/garbageCollectorCost = 0
	var/total_cost		= 0

	var/last_thing_processed
	var/mob/list/expensive_mobs = list()
	var/rebuild_active_areas = 0

	var/initialized = 0 // Everything initialized? (Delays game start timer until shit is actually loaded)

	var/global/datum/garbage_collector/garbageCollector

datum/controller/game_controller/New()
	. = ..()

	// There can be only one master_controller. Out with the old and in with the new.
	if (master_controller != src)
		log_debug("Rebuilding Master Controller")

		if (istype(master_controller))
			recover()
			qdel(master_controller)

		master_controller = src

	var/watch=0
	if (isnull(job_master))
		watch = start_watch()
		job_master = new /datum/controller/occupations()
		job_master.SetupOccupations()
		job_master.LoadJobs("config/jobs.txt")
//		to_chat(world, "<span class='danger'>Job setup complete in </span>")
		log_startup_progress("Job setup complete in [stop_watch(watch)]s.")

	if(!syndicate_code_phrase)		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)	syndicate_code_response	= generate_code_phrase()
	/*if(!emergency_shuttle)			emergency_shuttle = new /datum/shuttle_controller/emergency_shuttle()*/
/*
	if(global.garbageCollector)
		garbageCollector = global.garbageCollector
*/
datum/controller/game_controller/proc/setup()
	world.tick_lag = config.Ticklag

	// notify the other process that we started up
	socket_talk = new /datum/socket_talk()
	socket_talk.send_raw("type=startup")

	if(config.enable_roundstart_away_missions)
		log_startup_progress("Attempting to generate an away mission...")
		createRandomZlevel()
/*
	if(!air_master)
		air_master = new /datum/controller/air_system()
		air_master.Setup()

	if(!ticker)
		ticker = new /datum/controller/gameticker()

	if(!global.garbageCollector)
		global.garbageCollector = new
		garbageCollector = global.garbageCollector
*/

	setupgenetics()
	setup_objects() // Most log_startup spam happens here
	setupfactions()
	setup_economy()
	SetupXenoarch()
	var/watch=start_watch()
	log_startup_progress("Caching damage icons...")
	cachedamageicons()
	log_startup_progress("  Finished caching damage icons in [stop_watch(watch)]s.")

	log_startup_progress("Caching space parallax simulation...")
	create_global_parallax_icons()
	log_startup_progress("  Finished caching space parallax simulation in [stop_watch(watch)]s.")

	buildcamlist()

	if(config.media_base_url)
		watch = start_watch()
		log_startup_progress("Caching jukebox playlists...")
		load_juke_playlists()
		log_startup_progress("  Finished caching jukebox playlists in [stop_watch(watch)]s.")

	//if(map && map.dorf)
		//mining_surprises = typesof(/mining_surprise/dorf) - /mining_surprise/dorf
		//max_secret_rooms += 2
	for(var/i=0, i<max_secret_rooms, i++)
		//if(map && map.dorf)
			//make_dorf_secret()
		//else
		make_mining_asteroid_secret()

	//if(config.socket_talk)
	//	keepalive()
/*
	spawn(0)
		if(ticker)
			ticker.pregame()

	lighting_controller.Initialize()
*/
	initialized=1

datum/controller/game_controller/proc/buildcamlist()
	adv_camera.camerasbyzlevel = list()
	for(var/key in adv_camera.zlevels)
		adv_camera.camerasbyzlevel["[key]"] = list()
	//camerasbyzlevel = list("1" = list(), "5" = list())
	if(!istype(cameranet) || !istype(cameranet.cameras) || !cameranet.cameras.len)
		world.log << "cameranet has not been initialized before us, finding cameras manually."
		for(var/obj/machinery/camera/C in world) //can't use machines list because cameras are removed from it.
			if(C.z == 1 || C.z == 5)
				var/list/ourlist = adv_camera.camerasbyzlevel["[C.z]"]
				ourlist += C
	else
		for(var/obj/machinery/camera/C in cameranet.cameras) //can't use machines list because cameras are removed from it.
			if(C.z == 1 || C.z == 5)
				var/list/ourlist = adv_camera.camerasbyzlevel["[C.z]"]
				ourlist += C
	for(var/key in adv_camera.camerasbyzlevel)
		var/list/keylist = adv_camera.camerasbyzlevel[key]
		world.log << "[key] has [keylist.len] entries"

	adv_camera.initialized = 1

datum/controller/game_controller/proc/cachedamageicons()
	var/mob/living/carbon/human/H = new(locate(1,1,2))
	var/datum/species/list/slist = list(new /datum/species/human, new /datum/species/vox, new /datum/species/diona)
	var/icon/DI
	var/species_blood
	for(var/datum/species/S in slist)
		species_blood = (S.blood_color == "#A10808" ? "" : S.blood_color)
		testing("Generating [S], Blood([species_blood])")
		for(var/datum/organ/external/O in H.organs)
			//testing("[O] part")
			for(var/brute = 1 to 3)
				for(var/burn = 1 to 3)
					var/damage_state = "[brute][burn]"
					DI = icon('icons/mob/dam_human.dmi', "[damage_state]")			// the damage icon for whole human
					DI.Blend(icon('icons/mob/dam_mask.dmi', O.icon_name), ICON_MULTIPLY)
					if(species_blood)
						DI.Blend(S.blood_color, ICON_MULTIPLY)
					//testing("Completed [damage_state]/[O.icon_name]/[species_blood]")
					damage_icon_parts["[damage_state]/[O.icon_name]/[species_blood]"] = DI
	del(H)

/datum/controller/game_controller/proc/setup_objects()
	var/watch = start_watch()
	var/overwatch = start_watch() // Overall.

	log_startup_progress("Populating asset cache...")
	populate_asset_cache()
	log_startup_progress("  Populated [asset_cache.len] assets in [stop_watch(watch)]s.")

	if(!config.skip_vault_generation)
		watch = start_watch()
		log_startup_progress("Placing random space structures...")
		generate_vaults()
		log_startup_progress("  Finished placing structures in [stop_watch(watch)]s.")
	else
		log_startup_progress("Not generating vaults - SKIP_VAULT_GENERATION found in config/config.txt")

	watch = start_watch()
	log_startup_progress("Building powernets...")
	makepowernets()
	log_startup_progress("  Finished building powernets in [stop_watch(watch)]s.")

	watch = start_watch()
	log_startup_progress("Initializing objects...")
	//sleep(-1) // Why
	//var/last_init_type = null
	var/count=0
	for(var/atom/movable/object in world)
		//if(last_init_type != object.type)
		//	testing("Initializing [object.type]")
		//	last_init_type = object.type
		object.initialize()
		count++
	log_startup_progress("  Initialized [count] objects in [stop_watch(watch)]s.")

	watch = start_watch()
	count=0
	log_startup_progress("Initializing pipe networks...")
	//sleep(-1)
	for(var/obj/machinery/atmospherics/machine in atmos_machines)
		machine.build_network()
		count++
	log_startup_progress("  Initialized [count] pipe networks in [stop_watch(watch)]s.")

	watch = start_watch()
	count=0
	log_startup_progress("Initializing atmos machinery...")
	//sleep(-1)
	for(var/obj/machinery/atmospherics/unary/U in atmos_machines)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()
			count++
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()
			count++
	log_startup_progress("  Initialized [count] atmos devices in [stop_watch(watch)]s.")

	if(!config.skip_minimap_generation)
		spawn()
			watch = start_watch()
			log_startup_progress("Generating in-game minimaps...")
			generateMiniMaps()
			log_startup_progress("  Finished minimaps in [stop_watch(watch)]s.")
	else
		log_startup_progress("Not generating minimaps - SKIP_MINIMAP_GENERATION found in config/config.txt")

	log_startup_progress("Finished initializations in [stop_watch(overwatch)]s.")



/datum/controller/game_controller/proc/process()
	processing = 1

	spawn (0)
		set background = BACKGROUND_ENABLED

		while (1) // Far more efficient than recursively calling ourself.
			if (isnull(failsafe))
				new /datum/controller/failsafe()

			if (processing)
				iteration++
				var/timer
				var/start_time = world.timeofday

				vote.process()
				//process_newscaster()

				//AIR

				if(!air_processing_killed)
					timer = world.timeofday
					last_thing_processed = air_master.type

					if(!air_master.Tick()) //Runtimed.
						air_master.failed_ticks++
						if(air_master.failed_ticks > 5)
							to_chat(world, "<font color='red'><b>RUNTIMES IN ATMOS TICKER.  Killing air simulation!</font></b>")
							world.log << "### ZAS SHUTDOWN"
							message_admins("ZASALERT: unable to run [air_master.tick_progress], shutting down!")
							log_admin("ZASALERT: unable run zone/process() -- [air_master.tick_progress]")
							air_processing_killed = 1
							air_master.failed_ticks = 0

					air_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//SUN
				timer = world.timeofday
				last_thing_processed = sun.type
				sun.calc_position()
				sun_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//MOBS
				timer = world.timeofday
				processMobs()
				mobs_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//DISEASES
				timer = world.timeofday
				processDiseases()
				diseases_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//MACHINES
				timer = world.timeofday
				processMachines()
				machines_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//OBJECTS
				timer = world.timeofday
				processObjects()
				objects_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//PIPENETS
				if(!pipe_processing_killed)
					timer = world.timeofday
					processPipenets()
					networks_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//POWERNETS
				timer = world.timeofday
				processPowernets()
				powernets_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//NANO UIS
				timer = world.timeofday
				processNano()
				nano_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//EVENTS
				timer = world.timeofday
				processEvents()
				events_cost = (world.timeofday - timer) / 10

				//TICKER
				timer = world.timeofday
				last_thing_processed = ticker.type
				ticker.process()
				ticker_cost = (world.timeofday - timer) / 10

				timer = world.timeofday
				last_thing_processed = garbageCollector.type
				garbageCollector.process()
				garbageCollectorCost = (world.timeofday - timer) / 10

				//TIMING
				total_cost = air_cost + sun_cost + mobs_cost + diseases_cost + machines_cost + objects_cost + networks_cost + powernets_cost + nano_cost + events_cost + ticker_cost + garbageCollectorCost

				var/end_time = world.timeofday
				if(end_time < start_time)
					start_time -= 864000    //deciseconds in a day
				sleep( round(minimum_ticks - (end_time - start_time),1) )
			else
				sleep(10)

datum/controller/game_controller/proc/processMobs()
	var/i = 1
	expensive_mobs.len = 0
	while(i<=mob_list.len)
		var/mob/M = mob_list[i]
		if(M)
			var/clock = world.timeofday
			last_thing_processed = M.type
			M.Life()
			if((world.timeofday - clock) > 1)
				expensive_mobs += M
			i++
			continue
		if(!mob_list.Remove(null))
			mob_list.Cut(i,i+1)

/datum/controller/game_controller/proc/processDiseases()
	for (var/datum/disease/Disease in active_diseases)
		if(Disease)
			last_thing_processed = Disease.type
			Disease.process()
			continue

		active_diseases -= Disease

/datum/controller/game_controller/proc/processMachines()
	#ifdef PROFILE_MACHINES
	machine_profiling.len = 0
	#endif

	for (var/obj/machinery/Machinery in machines)
		if (Machinery && Machinery.loc)
			last_thing_processed = Machinery.type

			#ifdef PROFILE_MACHINES
			var/start = world.timeofday
			#endif

			if(PROCESS_KILL == Machinery.process())
				Machinery.inMachineList = 0
				machines.Remove(Machinery)
				continue

			if (Machinery && Machinery.use_power)
				Machinery.auto_use_power()

			#ifdef PROFILE_MACHINES
			var/end = world.timeofday

			if (!(Machinery.type in machine_profiling))
				machine_profiling[Machinery.type] = 0

			machine_profiling[Machinery.type] += (end - start)
			#endif


/datum/controller/game_controller/proc/processObjects()
	for (var/obj/Object in processing_objects)
		if (Object && Object.loc)
			last_thing_processed = Object.type
			Object.process()
			continue

		processing_objects -= Object

	// Hack.
	for (var/turf/unsimulated/wall/supermatter/SM in processing_objects)
		if (SM)
			last_thing_processed = SM.type
			SM.process()
			continue

		processing_objects -= SM

/datum/controller/game_controller/proc/processPipenets()
	last_thing_processed = /datum/pipe_network

	for (var/datum/pipe_network/Pipe_Network in pipe_networks)
		if(Pipe_Network)
			Pipe_Network.process()
			continue

		pipe_networks -= Pipe_Network

/datum/controller/game_controller/proc/processPowernets()
	last_thing_processed = /datum/powernet

	for (var/datum/powernet/Powernet in powernets)
		if (Powernet)
			Powernet.reset()
			continue

		powernets -= Powernet

/datum/controller/game_controller/proc/processNano()
	for (var/datum/nanoui/Nanoui in nanomanager.processing_uis)
		if (Nanoui)
			Nanoui.process()
			continue

		nanomanager.processing_uis -= Nanoui

/datum/controller/game_controller/proc/processEvents()
	last_thing_processed = /datum/event

	for (var/datum/event/Event in events)
		if (Event)
			Event.process()
			continue

		events -= Event

	checkEvent()

datum/controller/game_controller/recover()		//Mostly a placeholder for now.
	. = ..()
	var/msg = "## DEBUG: [time2text(world.timeofday)] MC restarted. Reports:\n"
	for(var/varname in master_controller.vars)
		switch(varname)
			if("tag","type","parent_type","vars")	continue
			else
				var/varval = master_controller.vars[varname]
				if(istype(varval,/datum))
					var/datum/D = varval
					msg += "\t [varname] = [D.type]\n"
				else
					msg += "\t [varname] = [varval]\n"
	world.log << msg
