/datum/preferences_subsection/organs
	registered_paths = list("organs")
	var/static/list/default_configurable_states = list(
		"Normal" = null,
		"Assisted" = "assisted",
		"Mechanical" = "mechanical",
	)
	var/static/list/configurable_organs = list(
		"Heart" = list(
			"internal_name" = "heart",
		),
		"Eyes" = list(
			"internal_name" = "eyes",
		),
		"Lungs" = list(
			"internal_name" = "lungs",
		),
		"Liver" = list(
			"internal_name" = "liver",
		),
		"Kidneys" = list(
			"internal_name" = "kidneys",
		)
	)

/datum/preferences_subsection/organs/proc/show_menu(var/mob/user, var/list/href_list)
	var/dat = list()
	for(var/english_organ_name in configurable_organs)
		var/entry_data = configurable_organs[english_organ_name]
		var/internal_organ_name = entry_data["internal_name"]
		var/states = entry_data["states"] || default_configurable_states
		dat += "<span style='display: inline-block; width: 100px;'>[english_organ_name]:</span>"
		for(var/english_state_name in states)
			dat += "&nbsp;"
			var/internal_state_name = states[english_state_name]
			if(prefs.organ_data[internal_organ_name] == internal_state_name)
				dat += "[english_state_name]"
			else
				dat += "<a href='?_src_=prefs;subsection=organs;task=input;target_organ=[english_organ_name];target_state=[english_state_name]'>[english_state_name]</a>"
		dat += "<br>"
	dat = jointext(dat, null)

	var/datum/browser/popup = new(user, "\ref[src]-organs", "Organs", 330, 200, src)
	popup.set_content(dat)
	popup.open()
	return TRUE

/datum/preferences_subsection/organs/proc/handle_input(var/mob/user, var/list/href_list)
	var/target_organ = href_list["target_organ"]
	ASSERT(target_organ)
	var/target_state = href_list["target_state"]
	ASSERT(target_state)

	var/list/configurable_organ_data = configurable_organs[target_organ]
	ASSERT(configurable_organ_data)

	var/organ_internal_name = configurable_organ_data["internal_name"]
	ASSERT(organ_internal_name)

	var/list/valid_states = configurable_organ_data["states"] || default_configurable_states
	ASSERT(target_state in valid_states)
	var/organ_internal_state = valid_states[target_state]

	prefs.organ_data[organ_internal_name] = organ_internal_state
	return TRUE

/datum/preferences_subsection/organs/process_link(var/mob/user, var/list/href_list)
	var/task = href_list["task"]
	switch(task)
		if("menu")
			user << browse(null, "window=preferences")
			return show_menu(arglist(args))
		if("input")
			. = handle_input(arglist(args))
			show_menu(arglist(args))
		else
			CRASH("Unknown task: [task]")

/datum/preferences_subsection/organs/Topic(href, list/href_list)
	. = ..()
	if(href_list["close"])
		usr << browse(null, "window=\ref[src]-organs")
		prefs.ShowChoices(usr)
