// -- ACTUAL PREFS --

// non-prefs stuff

/datum/preference_setting/numerical/warns
	name = "Warns"
	sql_name = "warns"
	sql_table = "client"
	enabled = TRUE

	default_setting = 0

/datum/preference_setting/numerical/warnbans
	name = "Warn bans"
	sql_name = "warnbans"
	sql_table = "client"
	enabled = TRUE

	default_setting = 0

/datum/preference_setting/toggle/show_warning_next_time
	name = "Show warning next time"
	sql_name = "show_warning_next_time"
	sql_table = "client"
	enabled = TRUE

	default_setting = 0

/datum/preference_setting/string/last_warned_message
	name = "Last warned message"
	sql_name = "last_warned_message"

	sql_table = "client"

	enabled = TRUE

	default_setting = "Default warning message"

/datum/preference_setting/string/warning_admin
	name = "Warning admin"
	sql_name = "warning_admin"
	sql_table = "client"
	enabled = TRUE

	default_setting = "Admin"

/datum/preference_setting/numerical/default_slot
	name = "Default slot"
	sql_name = "default_slot"
	sql_table = "client"
	enabled = TRUE

	default_setting = 1
	min_value = 1
	max_value = MAX_SAVE_SLOTS

// game-preferences
//Saved changlog filesize to detect if there was a change
/datum/preference_setting/string/changelog
	name = "Last changelog"
	sql_name = "lastchangelog"
	sql_table = "client"
	enabled = TRUE

	default_setting = ""

/datum/preference_setting/string/ooc_color
	name = "OOC Color"
	sql_name = "ooc_color"
	sql_table = "client"
	enabled = TRUE

	default_setting = "#b82e00"

// For all that matters, this ISN'T in the pref UI for some reason?
/datum/preference_setting/string/ooc_color/choose_setting(var/mob/user)
	var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference") as color|null
	if(new_ooccolor)
		setting = new_ooccolor

/datum/preference_setting/string/UI_style
	name = "UI Style"
	sql_name = "UI_style"
	sql_table = "client"
	enabled = TRUE

	default_setting = "Midnight"

// This is just cycling
/datum/preference_setting/string/UI_style/choose_setting(mob/user)
	. = ..()
	switch(setting)
		if("Midnight")
			setting = "Orange"
		if("Orange")
			setting = "old"
		if("old")
			setting = "White"
		else
			setting = "Midnight"


/datum/preference_setting/binary_flag/toggles
	name = "Toggles"
	sql_name = "toggles"
	sql_table = "client"
	enabled = TRUE

	default_setting = TOGGLES_DEFAULT

// Annoying overwrite but I can't think of a more elegant way to do it.
/datum/preference_setting/binary_flag/toggles/process_link(var/task, var/mob/user, var/list/href_list)
	if (task == "input")
		var/toggle = text2num(href_list["toggle"])

		// I can't think of any other way to check this pre-toggling. Probably overloaded but I want to replicate it, just ion case.
		switch (toggle)
			// Admin toggle, do not pass if we're not admin
			if (SOUND_ADMINHELP, CHAT_PRAYER, CHAT_ATTACKLOGS, CHAT_DEBUGLOGS, AUTO_DEADMIN)
				if (!user.client.holder)
					return

		setting ^= toggle

		// Annoying but have to do it.
		switch (toggle)
			if (SOUND_MIDI)
				user << sound(null, repeat = 0, wait = 0, volume = 0, channel = CHANNEL_ADMINMUSIC)
			if (SOUND_AMBIENCE)
				if(config.no_ambience)
					to_chat(user, "DEBUG: Ambience is globally disabled via server config.")
				user << sound(null, repeat = 0, wait = 0, volume = 0, channel = CHANNEL_AMBIENCE)
			if (SOUND_LOBBY)
				if(config.no_lobby_music)
					to_chat(user, "DEBUG: Lobby music is globally disabled via server config.")
				if(istype(user,/mob/new_player))
					user << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = CHANNEL_LOBBY)

/datum/preference_setting/string/UI_style_color
	name = "UI Style Color"
	sql_name = "UI_style_color"
	sql_table = "client"
	enabled = TRUE

	default_setting = "#ffffff"

/datum/preference_setting/string/UI_style_color/choose_setting(var/mob/user)
	var/UI_style_color_new = input(user, "Choose your UI colour, dark colours are not recommended!") as color|null
	if(!UI_style_color_new)
		return
	setting = UI_style_color_new

/datum/preference_setting/numerical/UI_style_alpha
	name = "UI Style Alpha"
	sql_name = "UI_style_alpha"
	sql_table = "client"
	enabled = TRUE

	default_setting = 255
	min_value = 50
	max_value = 255

/datum/preference_setting/numerical/UI_style_alpha/choose_setting(var/mob/user)
	var/UI_style_alpha_new = input(user, "Select a new alpha(transparency) parameter for UI, between 50 and 255") as num
	if(!UI_style_alpha_new || !(UI_style_alpha_new <= max_value && UI_style_alpha_new >= min_value))
		return
	setting = UI_style_alpha_new

/datum/preference_setting/toggle/space_parallax
	name = "Space parallax"
	sql_name = "space_parallax"
	sql_table = "client"
	enabled = TRUE

	default_setting = TRUE

/datum/preference_setting/toggle/space_parallax/choose_setting(var/mob/user)
	. = ..()
	if(user && user.hud_used)
		user.hud_used.update_parallax_existence()

/datum/preference_setting/toggle/space_dust
	name = "Space dust"
	sql_name = "space_dust"
	sql_table = "client"
	enabled = TRUE

	default_setting = TRUE

/datum/preference_setting/toggle/space_dust/choose_setting(var/mob/user)
	. = ..()
	if(user && user.hud_used)
		user.hud_used.update_parallax_existence()

/datum/preference_setting/numerical/parallax_speed
	name = "Parallax speed"
	sql_name = "parallax_speed"
	sql_table = "client"
	enabled = TRUE

	default_setting = 2
	min_value = 0
	max_value = 5

/datum/preference_setting/numerical/parallax_speed/choose_setting(var/mob/user)
	var/p_speed = input(user, "Enter a number between 0 and 5 included (default=2)","Parallax Speed Preferences",setting)
	setting = clamp(p_speed, min_value, max_value)

/datum/preference_setting/enum/special_popup
	name = "Special popup"
	sql_name = "special" // HISTORICAL REASONS :tm:
	sql_table = "client"
	enabled = TRUE

	default_setting = SPECIAL_POPUP_USE_BOTH
	allowed_values = list(SPECIAL_POPUP_DISABLED, SPECIAL_POPUP_EXCLUSIVE, SPECIAL_POPUP_USE_BOTH)

/datum/preference_setting/enum/special_popup/choose_setting(mob/user)
	var/choice = input(user, "Set your special tab preferences:", "Settings") as null|anything in special_popup_text2num
	if(!isnull(choice))
		setting = special_popup_text2num[choice]

/datum/preference_setting/toggle/tooltips
	name = "Tooltips"
	sql_name = "tooltips"
	sql_table = "client"
	enabled = TRUE

	default_setting = TRUE

/datum/preference_setting/toggle/stumble
	name = "Stumble"
	sql_name = "stumble"
	sql_table = "client"
	enabled = TRUE

	default_setting = FALSE

/datum/preference_setting/toggle/hear_voicesound
	name = "Hear voicesound"
	sql_name = "hear_voicesound"
	sql_table = "client"
	enabled = TRUE

	default_setting = FALSE

/datum/preference_setting/numerical/volume
	name = "Music volume"
	sql_name = "volume"
	sql_table = "client"
	enabled = TRUE

	default_setting = 100
	min_value = 0
	max_value = 100

/datum/preference_setting/numerical/volume/choose_setting(var/mob/user)
	user.client.set_new_volume()

/datum/preference_setting/toggle/usewmp
	name = "Use WMP"
	sql_name = "usewmp"
	sql_table = "client"
	enabled = TRUE

	default_setting = FALSE

/datum/preference_setting/toggle/usewmp/choose_setting(var/mob/user)
	. = ..()
	if(!user.client.media)
		return
	user.client.media.stop_music()
	user.client.media.playerstyle = (setting ? PLAYER_OLD_HTML : PLAYER_HTML)
	var/datum/preference_setting/toggles = parent.get_pref_datum(/datum/preference_setting/binary_flag/toggles)
	if(toggles.setting & SOUND_STREAMING)
		user.client.media.open()
		user.client.media.update_music()


/datum/preference_setting/toggle/randomslot
	name = "Use random character slot"
	sql_name = "randomslot"
	sql_table = "client"
	enabled = TRUE

	default_setting = FALSE

/datum/preference_setting/toggle/usenanoui
	name = "Use nanoUI"
	sql_name = "usenanoui"
	sql_table = "client"
	enabled = TRUE

	default_setting = TRUE

/datum/preference_setting/toggle/progress_bars
	name = "Progress bars"
	sql_name = "progress_bars"
	sql_table = "client"
	enabled = TRUE

	default_setting = TRUE

// TRAINS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
/datum/preference_setting/enum/attack_animations
	name = "Attack animations"
	sql_name = "attack_animation"
	sql_table = "client"
	enabled = TRUE

	default_setting = ITEM_ANIMATION
	allowed_values = list(ITEM_ANIMATION, NO_ANIMATION, PERSON_ANIMATION)

/datum/preference_setting/enum/attack_animations/choose_setting(var/mob/user)
	if(setting == NO_ANIMATION)
		item_animation_viewers |= parent.client
		setting = ITEM_ANIMATION

	else if(setting == ITEM_ANIMATION)
		setting = PERSON_ANIMATION
		person_animation_viewers |= parent.client
		item_animation_viewers -= parent.client

	else if(setting == PERSON_ANIMATION)
		setting = NO_ANIMATION
		item_animation_viewers -= parent.client

/datum/preference_setting/toggle/pulltoggle
	name = "Pull toggle"
	sql_name = "pulltoggle"
	sql_table = "client"
	enabled = TRUE

	default_setting = TRUE

/datum/preference_setting/toggle/hear_instruments
	name = "Hear instruments"
	sql_name = "hear_instruments"
	sql_table = "client"
	enabled = TRUE

	default_setting = FALSE

/datum/preference_setting/numerical/ambience_volume
	name = "Ambience volume"
	sql_name = "ambience_volume"
	sql_table = "client"
	enabled = TRUE

	default_setting = 100
	min_value = 0
	max_value = 100

/datum/preference_setting/numerical/ambience_volume/choose_setting(var/mob/user)
	var/new_volume = input(user, "Enter the new volume you wish to use. (0-100)","Ambience Volume Preferences", setting)
	setting = clamp(new_volume, min_value, max_value)

/datum/preference_setting/numerical/credits_volume
	name = "Ambience volume"
	sql_name = "credits_volume"
	sql_table = "client"
	enabled = TRUE

	default_setting = 75
	min_value = 0
	max_value = 100

/datum/preference_setting/numerical/credits_volume/choose_setting(var/mob/user)
	var/credits_volume = input(user, "Enter the new volume you wish to use. (0-100, default is 75)","Credits/Jingle Volume", setting)
	setting = clamp(credits_volume, min_value, max_value)

/datum/preference_setting/enum/credits
	name = "Credits"
	sql_name = "credits"
	sql_table = "client"
	enabled = TRUE

	default_setting = CREDITS_ALWAYS
	allowed_values = list(CREDITS_NEVER, CREDITS_ALWAYS, CREDITS_NO_RERUNS)

	saved_as_string = FALSE

/datum/preference_setting/enum/credits/choose_setting(var/mob/user)
	switch(setting)
		if(CREDITS_NEVER)
			setting = CREDITS_ALWAYS
		if(CREDITS_ALWAYS)
			setting = CREDITS_NO_RERUNS
		if(CREDITS_NO_RERUNS)
			setting = CREDITS_NEVER

/datum/preference_setting/enum/jingle
	name = "Jingle"
	sql_name = "jingle"
	sql_table = "client"
	enabled = TRUE

	default_setting = JINGLE_CLASSIC
	allowed_values =  list(JINGLE_NEVER, JINGLE_CLASSIC, JINGLE_ALL)

	saved_as_string = FALSE

/datum/preference_setting/enum/jingle/choose_setting(var/mob/user)
	switch(setting)
		if(JINGLE_NEVER)
			setting = JINGLE_CLASSIC
		if(JINGLE_CLASSIC)
			setting = JINGLE_ALL
		if(JINGLE_ALL)
			setting = JINGLE_NEVER

/datum/preference_setting/numerical/headset_sound
	name = "Headset sound"
	sql_name = "headset_sound"
	sql_table = "client"
	enabled = TRUE

	default_setting = HEADSET_SOUND_TRANSMIT
	min_value = HEADSET_SOUND_DISABLED
	max_value = HEADSET_SOUND_ALL

	saved_as_string = FALSE

/datum/preference_setting/numerical/headset_sound/choose_setting(var/mob/user)
	var/choice = input(user, "Set your radio headset sound preferences:", "Settings") as null|anything in headset_sound_text2num
	if(!isnull(choice))
		setting = headset_sound_text2num[choice]

/datum/preference_setting/toggle/window_flashing
	name = "Window flashing"
	sql_name = "window_flashing"
	sql_table = "client"
	enabled = TRUE

	default_setting = TRUE

/datum/preference_setting/toggle/antag_objectives
	name = "Antag objectives"
	sql_name = "antag_objectives"
	sql_table = "client"
	enabled = TRUE

	default_setting = TRUE // This also has "historical reasons" but not code-related

/datum/preference_setting/toggle/typing_indicator
	name = "Typing indicator"
	sql_name = "typing_indicator"
	sql_table = "client"
	enabled = TRUE

	default_setting = TRUE // This also has "historical reasons" but not code-related

// -- Runechat things
/datum/preference_setting/toggle/mob_chat_on_map
	name = "Runechat on map"
	sql_name = "mob_chat_on_map"
	sql_table = "client"
	enabled = TRUE

	default_setting = TRUE // This also has "historical reasons" but not code-related

/datum/preference_setting/numerical/max_chat_length
	name = "Max runechat message length"
	sql_name = "max_chat_length"
	sql_table = "client"
	enabled = TRUE

	default_setting = CHAT_MESSAGE_MAX_LENGTH
	min_value = 0
	max_value = CHAT_MESSAGE_MAX_LENGTH

/datum/preference_setting/numerical/max_chat_length/choose_setting(mob/user)
	var/max_chat_length = input(user, "Choose the max character length of shown Runechat messages. Valid range is 1 to [CHAT_MESSAGE_MAX_LENGTH] (default: [default_setting]))", "Character Preference", setting)  as null|num
	setting = clamp(max_chat_length, min_value, max_value)

/datum/preference_setting/toggle/obj_chat_on_map
	name = "Object runechat"
	sql_name = "obj_chat_on_map"
	sql_table = "client"
	enabled = TRUE

	default_setting = TRUE

/datum/preference_setting/toggle/no_goonchat_for_obj
	name = "No goonchat for object"
	sql_name = "no_goonchat_for_obj"
	sql_table = "client"
	enabled = TRUE

	default_setting = FALSE

/datum/preference_setting/toggle/tgui_fancy
	name = "Fancy TGUI"
	sql_name = "tgui_fancy"
	sql_table = "client"
	enabled = TRUE

	default_setting = TRUE

/datum/preference_setting/numerical/fps
	name = "FPS"
	sql_name = "fps"
	sql_table = "client"
	enabled = TRUE

	default_setting = -1
	min_value = -1
	max_value = 1000

	saved_as_string = FALSE

/datum/preference_setting/numerical/fps/choose_setting(var/mob/user)
	var/desired_fps = input(user, "Choose your desired frames per second.\n\
	WARNING: BYOND versions earlier than 513.1523 might not work properly with values other than 0.\n\
	Set this to -1 to use the recommended value.\n\
	Set this to 0 to use the server's FPS (currently [world.fps])\n\
	Values up to 1000 are allowed.", "FPS", setting) as null|num
	if(isnull(desired_fps))
		return
	if(desired_fps < 0)
		desired_fps = -1
	desired_fps = sanitize_integer(desired_fps, -1, 1000, setting)
	setting = desired_fps
	parent.client.fps = (setting < 0) ? RECOMMENDED_CLIENT_FPS : setting

// THESE ARE UNIMPLEMENTED FROM tgui MIGRATIONS! TOFIX
/datum/preference_setting/toggle/tgui_input
	name = "tgui_input"
	sql_name = "tgui_input"
	sql_table = "client"
	enabled = FALSE

	default_setting = FALSE

/datum/preference_setting/toggle/tgui_input_swapped
	name = "tgui_input_swapped"
	sql_name = "tgui_input_swapped"
	sql_table = "client"
	enabled = FALSE

	default_setting = FALSE


/datum/preference_setting/toggle/tgui_input_large
	name = "tgui_input_large"
	sql_name = "tgui_input_large"

	sql_table = "client"

	enabled = FALSE

	default_setting = FALSE

/datum/preference_setting/toggle/tgui_lock
	name = "tgui_lock"
	sql_name = "tgui_lock"

	sql_table = "client"

	enabled = FALSE

	default_setting = FALSE

/datum/preference_setting/toggle/tgui_scale
	name = "tgui_scale"
	sql_name = "tgui_scale"

	sql_table = "client"

	enabled = FALSE

	default_setting = FALSE

/datum/preference_setting/toggle/layout_prefs_used
	name = "tgui_scale"
	sql_name = "tgui_scale"

	sql_table = "client"

	enabled = FALSE

	default_setting = FALSE
