var/datum/subsystem/more_init/SSmore_init

/datum/subsystem/more_init
	name = "Random Init Stuff"
	init_order = INIT_MORE_INIT
	flags = SS_NO_FIRE

/datum/subsystem/more_init/New()
	NEW_SS_GLOBAL(SSmore_init)

/datum/subsystem/more_init/Initialize(timeofday)
	setupfactions()
	setup_economy()
	SetupXenoarch()
	var/watch=start_watch()
	log_startup_progress("Caching damage icons...")
	cachedamageicons()
	log_startup_progress("  Finished caching damage icons in [stop_watch(watch)]s.")

	watch=start_watch()
	log_startup_progress("Caching space parallax simulation...")
	create_global_parallax_icons()
	log_startup_progress("  Finished caching space parallax simulation in [stop_watch(watch)]s.")

	watch=start_watch()
	log_startup_progress("Generating holominimaps...")
	generateHoloMinimaps()
	log_startup_progress("  Finished holominimaps in [stop_watch(watch)]s.")

	buildcamlist()

	if(config.media_base_url)
		watch = start_watch()
		log_startup_progress("Caching jukebox playlists...")
		load_juke_playlists()
		log_startup_progress("  Finished caching jukebox playlists in [stop_watch(watch)]s.")
	..()
