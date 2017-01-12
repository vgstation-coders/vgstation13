var/datum/subsystem/more_init/SSmore_init

/datum/subsystem/more_init
	name       = "Uncategorized Init"
	init_order = SS_INIT_MORE_INIT
	flags      = SS_NO_FIRE

/datum/subsystem/more_init/New()
	NEW_SS_GLOBAL(SSmore_init)

/datum/subsystem/more_init/Initialize(timeofday)
	setupfactions()
	setup_economy()
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


/datum/subsystem/more_init/proc/buildcamlist()
	adv_camera.camerasbyzlevel = list()
	for(var/key in adv_camera.zlevels)
		adv_camera.camerasbyzlevel["[key]"] = list()
	//camerasbyzlevel = list("1" = list(), "5" = list())
	if(!istype(cameranet) || !istype(cameranet.cameras) || !cameranet.cameras.len)
		world.log << "cameranet has not been initialized before us, finding cameras manually."
		for(var/obj/machinery/camera/C in world) //can't use machines list because cameras are removed from it.
			if(C.z == map.zMainStation || C.z == map.zAsteroid)
				var/list/ourlist = adv_camera.camerasbyzlevel["[C.z]"]
				ourlist += C
	else
		for(var/obj/machinery/camera/C in cameranet.cameras) //can't use machines list because cameras are removed from it.
			if(C.z == map.zMainStation || C.z == map.zAsteroid)
				var/list/ourlist = adv_camera.camerasbyzlevel["[C.z]"]
				ourlist += C
	for(var/key in adv_camera.camerasbyzlevel)
		var/list/keylist = adv_camera.camerasbyzlevel[key]
		world.log << "[key] has [keylist.len] entries"

	adv_camera.initialized = 1


/datum/subsystem/more_init/proc/cachedamageicons()
	var/mob/living/carbon/human/H = new(locate(1,1,2))
	var/datum/species/list/slist = list(new /datum/species/human, new /datum/species/vox, new /datum/species/diona)
	var/icon/DI
	var/species_blood
	for(var/datum/species/S in slist)
		species_blood = (S.blood_color == DEFAULT_BLOOD ? "" : S.blood_color)
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
