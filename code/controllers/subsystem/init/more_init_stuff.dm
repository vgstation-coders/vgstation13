var/datum/subsystem/more_init/SSmore_init

/datum/subsystem/more_init
	name       = "Uncategorized Init"
	init_order = SS_INIT_MORE_INIT
	flags      = SS_NO_FIRE

/datum/subsystem/more_init/New()
	NEW_SS_GLOBAL(SSmore_init)

/datum/subsystem/more_init/Initialize(timeofday)
	initialize_rune_words()
	library_catalog.initialize()
	init_mind_ui()
	createPaiController()
	ticker.init_snake_leaderboard()
	ticker.init_minesweeper_leaderboard()
	pick_discounted_items()

	var/watch=start_watch()
	cachedamageicons()
	log_debug("  Finished caching damage icons in [stop_watch(watch)]s.", FALSE)

	watch=start_watch()
	create_global_parallax_icons()
	log_debug("  Finished caching space parallax simulation in [stop_watch(watch)]s.", FALSE)

	init_sensed_explosions_list()
	if (!config.skip_holominimap_generation)
		watch=start_watch()
		generateHoloMinimaps()
		log_debug("  Finished holominimaps in [stop_watch(watch)]s.", FALSE)
	else
		//holomaps_initialized = 1 //Assume holominimaps were prerendered, the worst thing that happens if they're missing is that the minimap consoles don't show a minimap - NO IT'S NOT YOU DUMBFUCK, THOSE VARS EXIST FOR A REASON
		log_startup_progress("Not generating holominimaps - SKIP_HOLOMINIMAP_GENERATION found in config/config.txt")

	if(config.media_base_url)
		watch = start_watch()
		load_juke_playlists()
		log_debug("  Finished caching jukebox playlists in [stop_watch(watch)]s.", FALSE)
	..()

	watch=start_watch()
	process_teleport_locs()				//Sets up the wizard teleport locations
	process_ghost_teleport_locs()		//Sets up ghost teleport locations.
	process_adminbus_teleport_locs()	//Sets up adminbus teleport locations.
	camera_sort(cameranet.cameras)
	create_global_diseases()
	init_wizard_apprentice_setups()
	machinery_rating_cache = cache_machinery_components_rating()
	typing_indicator = new
	CHECK_TICK
	centcomm_store = new
	create_randomized_reagents()
	log_debug("Finished doing the other misc. initializations in [stop_watch(watch)]s.", FALSE)

/proc/init_sensed_explosions_list()
	for (var/z = 1 to world.maxz)
		sensed_explosions["z[z]"] = list()

/proc/cache_machinery_components_rating()
	var/list/cache = list()
	for(var/obj/machinery/machine in all_machines)
		if(!cache[machine.type])
			var/rating = 0
			for(var/obj/item/weapon/stock_parts/SP in machine.component_parts)
				rating += SP.rating
			cache[machine.type] = rating
	return cache

/proc/init_wizard_apprentice_setups()
	for (var/setup_type in subtypesof(/datum/wizard_apprentice_setup))
		var/datum/wizard_apprentice_setup/setup_datum = new setup_type
		wizard_apprentice_setups_nanoui += list(list("name" = setup_datum.name, "desc" = setup_datum.generate_description()))
		wizard_apprentice_setups_by_name[setup_datum.name] = setup_datum


/datum/subsystem/more_init/proc/cachedamageicons()
	var/mob/living/carbon/human/H = new(locate(1,1,2))
	var/list/datum/species/slist = list(new /datum/species/human, new /datum/species/vox, new /datum/species/diona)
	var/icon/DI
	var/species_blood
	for(var/datum/species/S in slist)
		species_blood = (S.blood_color == DEFAULT_BLOOD ? "" : S.blood_color)
//		testing("Generating [S], Blood([species_blood])")
		for(var/datum/organ/external/O in H.organs)
			//testing("[O] part")
			for(var/brute = 0 to 3)
				for(var/burn = 0 to 3)
					var/damage_state = "[brute][burn]"
					if(species_blood)
						DI = icon('icons/mob/dam_human.dmi', "[brute]0-color")
						DI.Blend(S.blood_color, ICON_MULTIPLY)
						var/icon/DI_burn = icon('icons/mob/dam_human.dmi', "0[burn]")//we don't want burns to blend with the species' blood color
						DI.Blend(DI_burn, ICON_OVERLAY)
						DI.Blend(icon('icons/mob/dam_mask.dmi', O.icon_name), ICON_MULTIPLY)
					else
						DI = icon('icons/mob/dam_human.dmi', "[damage_state]")
						DI.Blend(icon('icons/mob/dam_mask.dmi', O.icon_name), ICON_MULTIPLY)

					damage_icon_parts["[damage_state]/[O.icon_name]/[species_blood]"] = DI
	qdel(H)
