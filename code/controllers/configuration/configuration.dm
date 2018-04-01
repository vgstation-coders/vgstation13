/datum/controller/configuration
	name = "Configuration"

	var/directory = "config"

	var/hiding_entries_by_type = TRUE	//Set for readability, admins can set this to FALSE if they want to debug it
	var/list/entries
	var/list/entries_by_type

	var/list/maplist
	var/datum/map_config/defaultmap

	var/list/modes			// allowed modes
	var/list/gamemode_cache
	var/list/votable_modes		// votable modes
	var/list/mode_names
	var/list/mode_reports
	var/list/mode_false_report_weight

	var/motd

/datum/controller/configuration/proc/Load()
	if(entries)
		CRASH("[THIS_PROC_TYPE_WEIRD] called more than once!")
	InitEntries()
	LoadModes()
	if(fexists("[directory]/config.txt") && LoadEntries("config.txt") <= 1)
		log_config("No $include directives found in config.txt! Loading legacy game_options/dbconfig/comms files...")
		LoadEntries("game_options.txt")
		LoadEntries("dbconfig.txt")
		LoadEntries("comms.txt")
	loadmaplist(CONFIG_MAPS_FILE)
	LoadMOTD()

/datum/controller/configuration/Destroy()
	entries_by_type.Cut()
	QDEL_LIST_ASSOC_VAL(entries)
	QDEL_LIST_ASSOC_VAL(maplist)
	QDEL_NULL(defaultmap)

	config = null

	return ..()

/datum/controller/configuration/proc/InitEntries()
	var/list/_entries = list()
	entries = _entries
	var/list/_entries_by_type = list()
	entries_by_type = _entries_by_type

	for(var/I in typesof(/datum/config_entry))	//typesof is faster in this case
		var/datum/config_entry/E = I
		if(initial(E.abstract_type) == I)
			continue
		E = new I
		var/esname = E.name
		var/datum/config_entry/test = _entries[esname]
		if(test)
			log_config("Error: [test.type] has the same name as [E.type]: [esname]! Not initializing [E.type]!")
			qdel(E)
			continue
		_entries[esname] = E
		_entries_by_type[I] = E

/datum/controller/configuration/proc/RemoveEntry(datum/config_entry/CE)
	entries -= CE.name
	entries_by_type -= CE.type

/datum/controller/configuration/proc/LoadEntries(filename, list/stack = list())
	if(IsAdminAdvancedProcCall())
		return

	var/filename_to_test = world.system_type == MS_WINDOWS ? lowertext(filename) : filename
	if(filename_to_test in stack)
		log_config("Warning: Config recursion detected ([english_list(stack)]), breaking!")
		return
	stack = stack + filename_to_test

	log_config("Loading config file [filename]...")
	var/list/lines = world.file2list("[directory]/[filename]")
	var/list/_entries = entries
	for(var/L in lines)
		if(!L)
			continue
		
		var/firstchar = copytext(L, 1, 2)
		if(firstchar == "#")
			continue

		var/lockthis = firstchar == "@"
		if(lockthis)
			L = copytext(L, 2)

		var/pos = findtext(L, " ")
		var/entry = null
		var/value = null

		if(pos)
			entry = lowertext(copytext(L, 1, pos))
			value = copytext(L, pos + 1)
		else
			entry = lowertext(L)

		if(!entry)
			continue
		
		if(entry == "$include")
			if(!value)
				log_config("Warning: Invalid $include directive: [value]")
			else
				LoadEntries(value, stack)
				++.
			continue
		
		var/datum/config_entry/E = _entries[entry]
		if(!E)
			log_config("Unknown setting in configuration: '[entry]'")
			continue

		if(lockthis)
			E.protection |= CONFIG_ENTRY_LOCKED

		var/validated = E.ValidateAndSet(value)
		if(!validated)
			log_config("Failed to validate setting \"[value]\" for [entry]")
		else if(E.modified && !E.dupes_allowed)
			log_config("Duplicate setting for [entry] ([value], [E.resident_file]) detected! Using latest.")

		E.resident_file = filename
		
		if(validated)
			E.modified = TRUE
	
	++.

/datum/controller/configuration/can_vv_get(var_name)
	return (var_name != NAMEOF(src, entries_by_type) || !hiding_entries_by_type) && ..()

/datum/controller/configuration/vv_edit_var(var_name, var_value)
	var/list/banned_edits = list(NAMEOF(src, entries_by_type), NAMEOF(src, entries), NAMEOF(src, directory))
	return !(var_name in banned_edits) && ..()

/datum/controller/configuration/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug(null, "Edit", src)
	stat("[name]:", statclick)

/datum/controller/configuration/proc/Get(entry_type)
	if(IsAdminAdvancedProcCall() && GLOB.LastAdminCalledProc == "Get" && GLOB.LastAdminCalledTargetRef == "[REF(src)]")
		log_admin_private("Config access of [entry_type] attempted by [key_name(usr)]")
		return
	var/datum/config_entry/E = entry_type
	var/entry_is_abstract = initial(E.abstract_type) == entry_type
	if(entry_is_abstract)
		CRASH("Tried to retrieve an abstract config_entry: [entry_type]")
	E = entries_by_type[entry_type]
	if(!E)
		CRASH("Missing config entry for [entry_type]!")
	return E.config_entry_value

/datum/controller/configuration/proc/Set(entry_type, new_val)
	if(IsAdminAdvancedProcCall() && GLOB.LastAdminCalledProc == "Set" && GLOB.LastAdminCalledTargetRef == "[REF(src)]")
		log_admin_private("Config rewrite of [entry_type] to [new_val] attempted by [key_name(usr)]")
		return
	var/datum/config_entry/E = entry_type
	var/entry_is_abstract = initial(E.abstract_type) == entry_type
	if(entry_is_abstract)
		CRASH("Tried to retrieve an abstract config_entry: [entry_type]")
	E = entries_by_type[entry_type]
	if(!E)
		CRASH("Missing config entry for [entry_type]!")
	return E.ValidateAndSet("[new_val]")

/datum/controller/configuration/proc/LoadModes()
	gamemode_cache = typecacheof(/datum/game_mode, TRUE)
	modes = list()
	mode_names = list()
	mode_reports = list()
	mode_false_report_weight = list()
	votable_modes = list()
	var/list/probabilities = Get(/datum/config_entry/keyed_number_list/probability)
	for(var/T in gamemode_cache)
		// I wish I didn't have to instance the game modes in order to look up
		// their information, but it is the only way (at least that I know of).
		var/datum/game_mode/M = new T()

		if(M.config_tag)
			if(!(M.config_tag in modes))		// ensure each mode is added only once
				modes += M.config_tag
				mode_names[M.config_tag] = M.name
				probabilities[M.config_tag] = M.probability
				mode_reports[M.config_tag] = M.generate_report()
				if(probabilities[M.config_tag]>0)
					mode_false_report_weight[M.config_tag] = M.false_report_weight
				else
					mode_false_report_weight[M.config_tag] = 1
				if(M.votable)
					votable_modes += M.config_tag
		qdel(M)
	votable_modes += "secret"

/datum/controller/configuration/proc/LoadMOTD()
	motd = file2text("[directory]/motd.txt")
	var/tm_info = GLOB.revdata.GetTestMergeInfo()
	if(motd || tm_info)
		motd = motd ? "[motd]<br>[tm_info]" : tm_info

/datum/controller/configuration/proc/loadmaplist(filename)
	log_config("Loading config file [filename]...")
	filename = "[directory]/[filename]"
	var/list/Lines = world.file2list(filename)

	var/datum/map_config/currentmap = null
	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/command = null
		var/data = null

		if(pos)
			command = lowertext(copytext(t, 1, pos))
			data = copytext(t, pos + 1)
		else
			command = lowertext(t)

		if(!command)
			continue

		if (!currentmap && command != "map")
			continue

		switch (command)
			if ("map")
				currentmap = load_map_config("_maps/[data].json")
				if(currentmap.defaulted)
					log_config("Failed to load map config for [data]!")
					currentmap = null
			if ("minplayers","minplayer")
				currentmap.config_min_users = text2num(data)
			if ("maxplayers","maxplayer")
				currentmap.config_max_users = text2num(data)
			if ("weight","voteweight")
				currentmap.voteweight = text2num(data)
			if ("default","defaultmap")
				defaultmap = currentmap
			if ("endmap")
				LAZYINITLIST(maplist)
				maplist[currentmap.map_name] = currentmap
				currentmap = null
			if ("disabled")
				currentmap = null
			else
				WRITE_FILE(GLOB.config_error_log, "Unknown command in map vote config: '[command]'")


/datum/controller/configuration/proc/pick_mode(mode_name)
	// I wish I didn't have to instance the game modes in order to look up
	// their information, but it is the only way (at least that I know of).
	// ^ This guy didn't try hard enough
	for(var/T in gamemode_cache)
		var/datum/game_mode/M = T
		var/ct = initial(M.config_tag)
		if(ct && ct == mode_name)
			return new T
	return new /datum/game_mode/extended()

/datum/controller/configuration/proc/get_runnable_modes()
	var/list/datum/game_mode/runnable_modes = new
	var/list/probabilities = Get(/datum/config_entry/keyed_number_list/probability)
	var/list/min_pop = Get(/datum/config_entry/keyed_number_list/min_pop)
	var/list/max_pop = Get(/datum/config_entry/keyed_number_list/max_pop)
	var/list/repeated_mode_adjust = Get(/datum/config_entry/number_list/repeated_mode_adjust)
	for(var/T in gamemode_cache)
		var/datum/game_mode/M = new T()
		if(!(M.config_tag in modes))
			qdel(M)
			continue
		if(probabilities[M.config_tag]<=0)
			qdel(M)
			continue
		if(min_pop[M.config_tag])
			M.required_players = min_pop[M.config_tag]
		if(max_pop[M.config_tag])
			M.maximum_players = max_pop[M.config_tag]
		if(M.can_start())
			var/final_weight = probabilities[M.config_tag]
			if(SSpersistence.saved_modes.len == 3 && repeated_mode_adjust.len == 3)
				var/recent_round = min(SSpersistence.saved_modes.Find(M.config_tag),3)
				var/adjustment = 0
				while(recent_round)
					adjustment += repeated_mode_adjust[recent_round]
					recent_round = SSpersistence.saved_modes.Find(M.config_tag,recent_round+1,0)
				final_weight *= ((100-adjustment)/100)
			runnable_modes[M] = final_weight
	return runnable_modes

/datum/controller/configuration/proc/get_runnable_midround_modes(crew)
	var/list/datum/game_mode/runnable_modes = new
	var/list/probabilities = Get(/datum/config_entry/keyed_number_list/probability)
	var/list/min_pop = Get(/datum/config_entry/keyed_number_list/min_pop)
	var/list/max_pop = Get(/datum/config_entry/keyed_number_list/max_pop)
	for(var/T in (gamemode_cache - SSticker.mode.type))
		var/datum/game_mode/M = new T()
		if(!(M.config_tag in modes))
			qdel(M)
			continue
		if(probabilities[M.config_tag]<=0)
			qdel(M)
			continue
		if(min_pop[M.config_tag])
			M.required_players = min_pop[M.config_tag]
		if(max_pop[M.config_tag])
			M.maximum_players = max_pop[M.config_tag]
		if(M.required_players <= crew)
			if(M.maximum_players >= 0 && M.maximum_players < crew)
				continue
			runnable_modes[M] = probabilities[M.config_tag]
	return runnable_modes
