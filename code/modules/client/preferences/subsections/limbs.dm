#define LIMB_MODE_AFFECT_CHILD 1
#define LIMB_MODE_AFFECT_PARENT 2
#define LIMB_MODE_SPECIAL_SNOWFLAKE 3

/datum/preferences_subsection/limbs
	registered_paths = list("limbs")
	var/static/list/default_configurable_states = list(
		"Normal" = list(
			"internal_name" = null,
			"mode" = LIMB_MODE_AFFECT_PARENT,
		),
		"Amputated" = list(
			"internal_name" = "amputated",
			"mode" = LIMB_MODE_AFFECT_CHILD,
		),
		"Prosthesis" = list(
			"internal_name" = "cyborg",
			"mode" = LIMB_MODE_AFFECT_CHILD,
		)
	)

	var/static/list/peg_limb_data = list(
		"internal_name" = "peg",
		"mode" = LIMB_MODE_SPECIAL_SNOWFLAKE,
	)

	var/static/list/leg_configurable_states = list(
		"Peg leg" = peg_limb_data,
	)
	var/static/list/arm_configurable_states = list(
		"Wooden prosthesis" = peg_limb_data,
	)
	var/static/list/hand_configurable_states = list(
		"Hook prosthesis" = peg_limb_data,
	)
	var/static/list/configurable_limbs = list(
		"Left arm" = list(
			"internal_name" = LIMB_LEFT_ARM,
			"extra_states" = arm_configurable_states,
			"child_limb" = LIMB_LEFT_HAND,
		),
		"Left hand" = list(
			"internal_name" = LIMB_LEFT_HAND,
			"extra_states" = hand_configurable_states,
			"parent_limb" = LIMB_LEFT_ARM,
		),
		"Right arm" = list(
			"internal_name" = LIMB_RIGHT_ARM,
			"extra_states" = arm_configurable_states,
			"child_limb" = LIMB_RIGHT_HAND,
		),
		"Right hand" = list(
			"internal_name" = LIMB_RIGHT_HAND,
			"extra_states" = hand_configurable_states,
			"parent_limb" = LIMB_RIGHT_ARM,
		),
		"Left leg" = list(
			"internal_name" = LIMB_LEFT_LEG,
			"extra_states" = leg_configurable_states,
			"child_limb" = LIMB_LEFT_FOOT,
		),
		"Left foot" = list(
			"internal_name" = LIMB_LEFT_FOOT,
			"parent_limb" = LIMB_LEFT_ARM,
		),
		"Right leg" = list(
			"internal_name" = LIMB_RIGHT_LEG,
			"extra_states" = leg_configurable_states,
			"child_limb" = LIMB_RIGHT_FOOT,
		),
		"Right foot" = list(
			"internal_name" = LIMB_RIGHT_FOOT,
			"parent_limb" = LIMB_RIGHT_LEG,
		),
	)

/datum/preferences_subsection/limbs/proc/show_menu(var/mob/user, var/list/href_list)
	var/dat = list()
	for(var/limb_english_name in configurable_limbs)
		var/entry_data = configurable_limbs[limb_english_name]
		var/limb_internal_name = entry_data["internal_name"]
		var/list/extra_states = entry_data["extra_states"]
		var/list/states = extra_states ? default_configurable_states + extra_states : default_configurable_states
		dat += "<span style='display: inline-block; width: 100px;'>[limb_english_name]:</span>"
		for(var/english_state_name in states)
			dat += "&nbsp;"
			var/internal_state_name = states[english_state_name]["internal_name"]
			if(prefs.organ_data[limb_internal_name] == internal_state_name)
				dat += "[english_state_name]"
			else
				dat += "<a href='?_src_=prefs;subsection=limbs;task=input;target_limb=[limb_english_name];target_state=[english_state_name]'>[english_state_name]</a>"
		dat += "<br>"
	dat = jointext(dat, null)

	var/datum/browser/popup = new(user, "\ref[src]-limbs", "Limbs", 500, 220, src)
	popup.set_content(dat)
	popup.open()
	return TRUE

/datum/preferences_subsection/limbs/proc/handle_input(var/mob/user, var/list/href_list)
	var/target_limb = href_list["target_limb"]
	ASSERT(target_limb)
	var/target_state = href_list["target_state"]
	ASSERT(target_state)

	var/list/configurable_limb_data = configurable_limbs[target_limb]
	ASSERT(configurable_limb_data)

	var/limb_internal_name = configurable_limb_data["internal_name"]
	ASSERT(limb_internal_name)

	var/list/extra_states = configurable_limb_data["extra_states"]
	var/list/valid_states = extra_states ? default_configurable_states + extra_states : default_configurable_states

	var/state_data = valid_states[target_state]
	ASSERT(state_data)

	var/limb_internal_state = state_data["internal_name"]

	prefs.organ_data[limb_internal_name] = limb_internal_state

	switch(state_data["mode"])
		if(LIMB_MODE_AFFECT_CHILD)
			var/child_limb = configurable_limb_data["child_limb"]
			if(child_limb)
				prefs.organ_data[child_limb] = limb_internal_state
		if(LIMB_MODE_AFFECT_PARENT)
			var/parent_limb = configurable_limb_data["parent_limb"]
			if(parent_limb)
				prefs.organ_data[parent_limb] = limb_internal_state
		if(LIMB_MODE_SPECIAL_SNOWFLAKE) // this is so sad
			var/child_limb = configurable_limb_data["child_limb"]
			if(child_limb)
				if(limb_internal_name == LIMB_LEFT_ARM || limb_internal_name == LIMB_RIGHT_ARM)
					prefs.organ_data[child_limb] = "peg"
				else
					prefs.organ_data[child_limb] = "amputated"

	return TRUE

/datum/preferences_subsection/limbs/process_link(var/mob/user, var/list/href_list)
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

/datum/preferences_subsection/limbs/Topic(href, list/href_list)
	. = ..()
	if(href_list["close"])
		usr << browse(null, "window=\ref[src]-limbs")
		prefs.ShowChoices(usr)

#undef LIMB_MODE_AFFECT_CHILD
#undef LIMB_MODE_AFFECT_PARENT
#undef LIMB_MODE_SPECIAL_SNOWFLAKE
