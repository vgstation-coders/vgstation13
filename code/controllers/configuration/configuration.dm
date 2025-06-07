/datum/configuration
	var/world_style_config = world_style

	var/nudge_script_path = "nudge.py"  // where the nudge.py script is located

	var/alist/config_flags = alist()

/datum/configuration/New()
	. = ..()
	for (var/flag_type in typesof(/datum/config_flag))
		var/datum/config_flag/flag = flag_type
		if (initial(flag.text_name) == "Abstract")
			continue
		// In 99% of case we could get away with just the value
		// However some flags require some operations on the config value
		// So we create an instance
		config_flags[flag_type] = new flag_type

/datum/configuration/proc/get_flag(var/flag_type)
	var/datum/config_flag/flag = config_flags[flag_type]
	if (!flag)
		CRASH("Invalid config setting requested: [flag_type]")
	return flag.value

/datum/configuration/proc/load(filename, category = "config") //the type can also be game_options, in which case it uses a different switch. not making it separate to not copypaste code - Urist
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

		var/found_match = 0
		for (var/flag_type in typesof(/datum/config_flag))
			var/datum/config_flag/flag = flag_type
			if (initial(flag.text_name) == "Abstract")
				continue
			if (initial(flag.category) != category)
				continue
			if (initial(flag.text_name) == name)
				var/datum/config_flag/actual_flag = config_flags[flag_type]

				// Load() allows the flag to do some code on the config value
				actual_flag.load(value)
				found_match = 1
				break
		if (!found_match)
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
				sqlport = text2num(value)
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

// Other modes aren't supported anymore
/datum/configuration/proc/get_runnable_modes()
	return list("Dynamic Mode", "Extended", "sandbox")
