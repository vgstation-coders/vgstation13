/*
	This file contains the logic for the State Laws verb.
*/
/mob/living/silicon/verb/state_laws()
	set name = "State Laws"
	set category = "Robot Commands"
	ui_interact(usr, "state_laws")

/mob/living/silicon/proc/speak_laws(var/list/to_state, var/radiokey)
    say("[radiokey]Current Active Laws:")
    sleep(10)
    for(var/law in to_state)
        if(!law["enabled"])
            continue
        say("[radiokey][law["text"]]")
        sleep(10)

//Smelly UI code below

//Datum to hold the UI state
/datum/state_laws_ui
	var/freeform = FALSE //whether the UI is in freeform mode
	var/list/selected_laws = null //list of currently selected laws
	var/laws_hash = null //a hash of the last laws used to form our default laws, to keep track of law changes
	var/freeform_editing_unlocked = FALSE //whether the freeform editing textarea is active
	var/list/preset_laws = null //list of preset lawsets
	var/radio_key = ";" //string prefixed to our say() messages to send them on radio channels, sanity checked
	var/has_linked_ai = FALSE //whether whoever's stating the laws has a linked AI
	var/use_laws_from_ai = FALSE

/datum/state_laws_ui/New()
	//Build the list of preset laws
	preset_laws = new/list()
	var/list/law_datums = list(
		new /datum/ai_laws/asimov,
		new /datum/ai_laws/nanotrasen,
		new /datum/ai_laws/robocop,
		new /datum/ai_laws/corporate,
		new /datum/ai_laws/paladin,
		new /datum/ai_laws/tyrant,
		new /datum/ai_laws/antimov,
		new /datum/ai_laws/keeper,
		new /datum/ai_laws/syndicate_override,
	)
	for(var/datum/ai_laws/law in law_datums) //again having to deal with nanoui shitcode
		var/list/tmplist = list()
		tmplist["name"] = law.name
		var/list/laws_list = list()
		for(var/i = 1; i <= law.inherent.len; i++)
			var/clause = law.inherent[i]
			laws_list.Add("[i]. [clause]")
		if(istype(law, /datum/ai_laws/syndicate_override)) //shitcode
			laws_list.Insert(1, "0. Only (Name of Agent) and people they designate as being such are Syndicate Agents.")
		tmplist["laws"] = laws_list
		preset_laws[++preset_laws.len] = tmplist

/datum/state_laws_ui/proc/compute_hash(var/datum/ai_laws/laws)
	return md5("[laws.zeroth][laws.ion.Join("")][laws.inherent.Join("")][laws.supplied.Join("")]")

/mob/living/silicon/proc/state_laws_Topic(href, href_list)
	if(href_list["toggle_mode"])
		state_laws_ui.freeform = !state_laws_ui.freeform
		state_laws_ui.selected_laws = null
		return 1
	if(href_list["freeform_edit_toggle"])
		state_laws_ui.freeform_editing_unlocked = !state_laws_ui.freeform_editing_unlocked
		return 1
	if(href_list["reset_laws"])
		state_laws_ui.selected_laws = null
		return 1
	if(href_list["edited_laws"])
		state_laws_ui.freeform_editing_unlocked = FALSE
		var/edited_laws = href_list["edited_laws"]
		var/regex/emptylines = new(@"(?:\n(?:[^\S\n]*(?=\n))?){2,}", "mg") //thanks stackexchange
		edited_laws = emptylines.Replace(edited_laws, "\n")
		edited_laws = replacetext(edited_laws, "\n", "", length(edited_laws)) //remove trailing newline
		var/list/split_laws = splittext(edited_laws, "\n")
		split_laws = split_laws.Copy(1, min(split_laws.len + 1, 51)) //no more than 50 laws permitted
		var/list/tmplist = new/list()
		for(var/str in split_laws)
			tmplist[++tmplist.len] = list("text" = copytext(str, 1, MAX_MESSAGE_LEN), "enabled" = TRUE) //no bee movie for you, buddy
		state_laws_ui.selected_laws = tmplist
		nanomanager.update_user_uis(usr, null, "state_laws")
		return 1
	if(href_list["reset_to_ai_laws"])
		state_laws_ui.use_laws_from_ai = TRUE
		state_laws_ui.selected_laws = null
		return 1
	if(href_list["preset_law_select"])
		var/index = text2num(href_list["preset_law_select"])
		var/list/tmplist = new/list()
		for(var/law in state_laws_ui.preset_laws[index]["laws"])
			tmplist[++tmplist.len] = list("text" = law, "enabled" = TRUE)
		state_laws_ui.selected_laws = tmplist
		return 1
	if(href_list["toggle_law_enable"])
		var/index = text2num(href_list["toggle_law_enable"])
		state_laws_ui.selected_laws[index]["enabled"] = !state_laws_ui.selected_laws[index]["enabled"]
		return 1
	if(href_list["speak_laws"])
		nanomanager.close_user_uis(usr, null, "state_laws")
		var/key = href_list["radio_key"]
		var/regex/onlykey = new(@":[0\-abcdeimnpstuw]|;") //find a valid key in the input, if there is one, stopping at first match
		var/index = onlykey.Find(key)
		//shitcode
		if(index && key[index] == ";")
			key = ";"
		else if(index && key[index] == ":")
			key = copytext(key, index, index+2)
		else
			key = ""
		state_laws_ui.radio_key = key
		if(state_laws_ui.freeform)
			log_admin("[usr]/[ckey(usr.key)] freeform-stated its silicon laws.")
		speak_laws(state_laws_ui.selected_laws, key)
		return 1

/mob/living/silicon/proc/state_laws_ui_interact(mob/user, ui_key, datum/nanoui/ui = null, force_open = 1)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.connected_ai)
			state_laws_ui.has_linked_ai = TRUE
		else
			state_laws_ui.has_linked_ai = FALSE

	var/hash = state_laws_ui.compute_hash(laws)
	if(state_laws_ui.laws_hash != hash) //if our laws changed since last check
		state_laws_ui.selected_laws = null

	if(state_laws_ui.selected_laws == null)
		var/datum/ai_laws/temp_laws = laws //duplicate the laws so we don't edit them
		if(isrobot(user) && state_laws_ui.has_linked_ai && state_laws_ui.use_laws_from_ai)
			var/mob/living/silicon/robot/R = user
			temp_laws = R.connected_ai.laws
			state_laws_ui.use_laws_from_ai = FALSE
			hash = state_laws_ui.compute_hash(temp_laws) //use the AI's laws' hash instead
		var/list/tmplist = new/list()
		if(temp_laws.zeroth)
			tmplist[++tmplist.len] = list("text" = "0. [temp_laws.zeroth]", "enabled" = TRUE) //oh dear this syntax
		for(var/law in temp_laws.ion)
			if(law)
				var/num = ionnum()
				tmplist[++tmplist.len] = list("text" = "[num]. [law]", "enabled" = TRUE) //trust me, this is the Right Way
		var/lawnum = 1
		for(var/law in temp_laws.inherent)
			if(law)
				tmplist[++tmplist.len] = list("text" = "[lawnum]. [law]", "enabled" = TRUE)
				lawnum++
		for(var/law in temp_laws.supplied)
			if(law)
				tmplist[++tmplist.len] = list("text" = "[lawnum]. [law]", "enabled" = TRUE)
				lawnum++
		state_laws_ui.selected_laws = tmplist
		state_laws_ui.laws_hash = hash //update hash to match the reset laws

	if(state_laws_ui.freeform == null)
		state_laws_ui.freeform = FALSE
	if(state_laws_ui.freeform_editing_unlocked == null)
		state_laws_ui.freeform_editing_unlocked = FALSE
	
	if(state_laws_ui.freeform == FALSE)
		state_laws_ui.freeform_editing_unlocked = FALSE //can't edit if not in freeform mode
	
	if(state_laws_ui.radio_key == null)
		state_laws_ui.radio_key = ""

	var/list/data = list(
		"src" = "\ref[src]",
		"freeform" = state_laws_ui.freeform,
		"freeform_editing_unlocked" = state_laws_ui.freeform_editing_unlocked,
		"selected_laws" = state_laws_ui.selected_laws,
		"preset_laws" = state_laws_ui.preset_laws,
		"radio_key" = state_laws_ui.radio_key,
		"has_linked_ai" = state_laws_ui.has_linked_ai
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "state_laws.tmpl", "State Laws", 500, 600)
		ui.set_initial_data(data)
		ui.open()
